/*
 * Example preemptive scheduling with variability-aware duty cycling
 * For use with VarOS, the variability scheduler based on FreeRTOS
 * Authors: Paul Martin and Lucas Wanner
 * Affiliation: NESL, UCLA
 * Contact: pdmartin@ucla.edu
 *
 */

// ========================== PREPROCESSOR ========================

/* Scheduler includes */
#include "FreeRTOS.h"
#include "vemu.h"
#include "task.h"
#include "hw_memmap.h"
#include "hw_types.h"
#include "hw_sysctl.h"
#include "hw_ints.h"
#include "sysctl.h"
#include "gpio.h"
#include "lmi_timer.h"
#include "uart.h"

/* Standard library includes */
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

/* VarEMU includes */
#include "vemu.h"

/* Temperature Profile Model */
#include "temp_model.h"

/* System Specs */
#include "system_specs.h"
#include "energy_matrix.h"

//__aeabi_unwind_cpp_pr0[0];

/* Task priorities */
#define mainTASK_PRIORITY	( tskIDLE_PRIORITY + 1 )

/* Task delays */
#define RADIO_DELAY ((portTickType) 1000 / portTICK_RATE_MS )
#define SENSOR_DELAY ((portTickType) 200 / portTICK_RATE_MS )
#define TASK3_DELAY ((portTickType) 2000 / portTICK_RATE_MS )
/* VaRTOS helper periods */
#define READPOWTEMP_DELAY ((portTickType) 1000 / portTICK_RATE_MS )
//#define LEARNKNOBTIME_DELAY ((portTickType) 1000 / portTICK_RATE_MS )
// (the above will take from task.h, which defines sysMONITOR_TIME_STEP_MS
#define LEARNKNOBTIME_DELAY ((portTickType) sysMONITOR_TIME_STEP_MS / portTICK_RATE_MS )
#define CHECKERRORS_DELAY ((portTickType) 168000 / portTICK_RATE_MS ) // 24000*7 = 168000 (1 week)
#define SECONDS_PER_ERRORCHECK ((3600*CHECKERRORS_DELAY)/1000)

/* High freq. timer freq */
#define tmrTIMER_2_FREQUENCY ( 1UL )
#define MAX_32_BIT_VALUE ( 4294967295 )
unsigned int timer_num_overflows = 0;

/* tick count for radio time-keeping */
unsigned int tick_count = 0;

// ========================== FUNCTION DECLARATIONS ========================

/* Configure the processor and peripherals */
static void prvSetupHardware( void );

/* Example empty task */
static void vHookRadio( void *pvParameters );
static void vHookSensor( void *pvParameters );
static void vHookTask3( void *pvParameters );

/* Scheduler hooks */
void vApplicationIdleHook( void );
void vApplicationTickHook( void );

/* Power management */
static void configSleepMode( void );
static void enterSleepMode( void );
#ifdef USE_VARTOS
unsigned long getPowerConsumed( portPOWER_ARGS_TYPE params );
unsigned long getTemperature (portTEMP_ARGS_TYPE params );
static void readPowTemp ( void *pvParameters );
static void learnKnobTime ( void *pvParameters );
static void checkErrors ( void *pvParameters );
void fitPsModel( void );
float findOptimalDC( unsigned int hours, unsigned int joules );
unsigned long getPs(char temp);
unsigned long getPa(char temp);

#endif

// ============================ GLOBAL VARIABLES ==========================
/* handles pointing to tasks in TCB */
xTaskHandle handleRadio;
xTaskHandle handleSensor;
xTaskHandle handleTask3;
/* model learning tasks */
xTaskHandle handle_readPowTemp;
xTaskHandle handle_learnKnobTime;
xTaskHandle handle_checkErrors;

/* knob values for scheduler to tune */
#ifdef USE_VARTOS
portKNOB_TYPE radio_knob;
portKNOB_TYPE sensor_knob;
portKNOB_TYPE task3_knob;
#else
unsigned int task1_knob = 10;
unsigned int task2_knob = 10; 
unsigned int task3_knob = 10;
#endif

/* model arrays and variables */
#ifdef USE_VARTOS
#define POWER_MODEL_POINTS (40)
#define POWER_MODEL_ERROR_THRESHOLD (0.01) // %
#define POWER_MODEL_ERROR_KP (0.0) // for 4e-5 dc per 40 mW error
#define ABS_VAL(x) ((x>0)? x: -x)
typedef struct power_model_t {
    // arrays for model construction
    float temps[POWER_MODEL_POINTS];
    float ps[POWER_MODEL_POINTS];
    float pa[POWER_MODEL_POINTS];
    char num;
    // for sleep power model (uW)
    float psslope;
    float psoffset;
    // for actie power (mW)
    float paslope;
    float paoffset;
    // goals
    unsigned int lifetime_hours;
    unsigned int energy_joules;
    // optimal DC
    float optimalDC;
    // model convergence flag
    char powerModelDone;
    // model indices
    char iidx;
    char jidx;
    char kidx;
} power_model_t;
power_model_t PowerModel = {.num=0, .powerModelDone=0};
#endif

/* debugging pin states */
char pin_status;

// ================================= MAIN =================================
int main( void )
{
    unsigned int misc;
	/* Configure the clocks, UART and GPIO. */
	prvSetupHardware();

	/* Start the tasks defined within the file. */
	// arguments: hook, name, stack_size, hook_arguments, priority, return_handle, knob_handle, knob_min, knob_max, utility_scalar
	// *Note: task_knob values are initialized to task_knob_min by task creation API
    #ifdef USE_VARTOS
    // VaRTOS-specific helper tasks
    xTaskCreate( readPowTemp, "readPT", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handle_readPowTemp, NULL, 2,2,1 );
    xTaskCreate( learnKnobTime, "learnKt", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handle_learnKnobTime, NULL, 3,3,1 );
    xTaskCreate( checkErrors, "checkE", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handle_checkErrors, NULL, 4,4,1 );
    // Generic tasks
	xTaskCreate( vHookRadio, "Task1", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleRadio, &radio_knob, 100, 5000, 1);//10s-0.2s periods
	xTaskCreate( vHookSensor, "Task2", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleSensor, &sensor_knob, 1, 100, 1);
    #else
    //xTaskCreate( vHookTask1, "Task1", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask1);
    //xTaskCreate( vHookTask2, "Task2", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask2);
    #endif

	/* Start the scheduler. */
	// power function, temp function, desired lifetime (hours), battery capacity (mWh)
    #ifdef USE_VARTOS
    PowerModel.lifetime_hours = SYSTEM_SPECS_LIFETIME;
    //PowerModel.energy_joules = SYSTEM_SPECS_ENERGY;
    misc = vemu_read_extra();
    PowerModel.iidx = (char)(misc >> 16);
    PowerModel.jidx = (char)(misc >> 8);
    PowerModel.kidx = (char)(misc >> 0);
    PowerModel.energy_joules = energy_matrix[PowerModel.iidx][PowerModel.jidx][PowerModel.kidx];
    PowerModel.energy_joules = 12960; // 2 AAA batteries
    //uputs("misc.\n");
    //uputi((int)misc);
    //uputs("i,j,k\n");
    //uputi(PowerModel.iidx);
    //uputs(",");
    //uputi(PowerModel.jidx);
    //uputs(",");
    //uputi(PowerModel.kidx);
    //uputs("\n");
    uputs("energy read:\n");
    uputi(PowerModel.energy_joules);
	vTaskStartScheduler( getPowerConsumed , getTemperature , NULL , 100*24 , 600 );
    #else
    vTaskStartScheduler();
    #endif    

	/* Will only get here if there was insufficient heap to start the
	scheduler. */
    uputs("INSUFFICIENT HEAP\n");
	return 0;
}

// ======================== INITIALIZATION ROUTINES ======================


static void prvSetupHardware( void )
{
	/* Setup the PLL. */
	SysCtlClockSet( SYSCTL_SYSDIV_1 | SYSCTL_USE_OSC | SYSCTL_OSC_MAIN | SYSCTL_XTAL_8MHZ );
    /* set up user led PF0 */
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);
    GPIODirModeSet( GPIO_PORTF_BASE, GPIO_PIN_0, GPIO_DIR_MODE_OUT );
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_0);
    /* set up pin PE0 (PWM4) for output */
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOE);
    GPIODirModeSet( GPIO_PORTE_BASE, GPIO_PIN_0, GPIO_DIR_MODE_OUT );
    GPIOPinTypeGPIOOutput(GPIO_PORTE_BASE, GPIO_PIN_0);
    /* set up UART1 (attached to FTDI VCP) , 115200/8N1 */
    SysCtlPeripheralEnable( SYSCTL_PERIPH_UART0 );
    SysCtlPeripheralEnable( SYSCTL_PERIPH_GPIOA );
    GPIODirModeSet( GPIO_PORTA_BASE, ( GPIO_PIN_0 | GPIO_PIN_1 ), GPIO_DIR_MODE_HW );
    GPIOPinTypeUART( GPIO_PORTA_BASE, ( GPIO_PIN_0 | GPIO_PIN_1 ));
    UARTConfigSetExpClk( UART0_BASE, SysCtlClockGet(), 115200,
            (UART_CONFIG_WLEN_8 | UART_CONFIG_STOP_ONE | UART_CONFIG_PAR_NONE));
    

}
// ============================== TASK HOOKS ============================
/* RADIO TRANSMISSION HOOK */
static void vHookRadio( void *pvParameters )
{
	portTickType xLastExecutionTime = xTaskGetTickCount();
    unsigned int i,j;
    // sensor to measure time

    // start radio_freq
    unsigned long radio_delay = 1000*(1000/portTICK_RATE_MS)/radio_knob;

   	for( ;; )
	{
		/* Enforce task frequency */
        // THIS IS A VARIABLE FREQUENCY TASK, SIMULATING A RADIO
		vTaskDelayUntil( &xLastExecutionTime, radio_delay );

        // calculate radio delay (knob acts as freq., measured in mHz)
        radio_delay = 1000*(1000/portTICK_RATE_MS)/radio_knob;

       	// task body, does a NOP loop to simulate packet transmission
        for( i=0; i<200; i++ ){
            for( j=0; j<1000; j++ ){
                __asm__("nop");
            }
        }

        // print out time so we know radio fired, we figure out how to interpret this in matlab
        uputs("\n1,");
        uputi((int)radio_knob);
        uputs(",0,"); // dummy val
        uputi((int)tick_count);

        //uputs("\n");
        //uputi(getMiscVal());

        //uputs("\n -- radio -- ");
        //uputs("\nslope:");
        //uputi((int)getMySlope());
        //uputs("\noffset:");
        //uputi((int)getMyOffset());

        //uputs("\n1,");
        //uputi((int)(getMyActiveTime()/1000000.0));
    

	}
}

/* SENSOR READING HOOK */
static void vHookSensor( void *pvParameters )
{
	portTickType xLastExecutionTime = xTaskGetTickCount();
    unsigned int i,j;
    float sensor_val_avg = 0.0;
    float sensor_val_sum = 0.0;
    int sensor_val_raw = -1;
    unsigned int sensor_num = 0;

   	for( ;; )
	{
		/* Enforce task frequency */
		vTaskDelayUntil( &xLastExecutionTime, SENSOR_DELAY );

        // reset sensor_sum
        sensor_val_sum = 0.0;

        // THIS IS A VARIABLE PERIOD TASK SIMULATING A SENSOR
        sensor_val_sum = 0.0;
        sensor_val_avg = 0.0;
        sensor_num = 0;
        
        for( i=0; i<sensor_knob; i++ ){
            // here's some random work to simulate work needed to acquire reading
            for( j=0; j<2000; j++ ){
                __asm__("nop");
            }
            // now call the getSensor function while averaging values
            sensor_val_raw = getSensorValue();
            if( sensor_val_raw != -1 ){
                sensor_val_sum += (float)sensor_val_raw;
                sensor_num++;
            }
        }
        //uputi(getMiscVal());
        //uputs("\n");
        if( sensor_num > 0 ){
            sensor_val_avg = sensor_val_sum/((float)sensor_num);
            // now print the sensor value as output
            uputs("\n0,");
            uputi((int)sensor_knob);
            uputs(",");
            uputi( (int)sensor_val_avg );
        }else{
            // print a -1 so we know no sensor value was read
            uputs("\n0,");
            uputi((int)sensor_knob);
            uputs(",");
            uputi(-1);
        }
        uputs(",");
        uputi((int)tick_count);

        //uputs("\n -- sensor -- ");
        //uputs("\nslope:");
        //uputi((int)getMySlope());
        //uputs("\noffset:");
        //uputi((int)getMyOffset());
        //uputs("\n0,");
        //uputi((int)(getMyActiveTime()/1000000.0));

        
   	}
}


// ============================= SCHEDULER HOOKS ============================
void vApplicationIdleHook( void ){
	/* Enter low power sleep (with clock) whenever idle
	   WFI could well be unimplemented in QEMU, and more than likely is.
	   the best we can do may just be to print out the time we entered idle. */
	//uart_puts_num("Entered idle task at time: ", 0);
	__asm__("WFI");
//	enterSleepMode();
	
}

void vApplicationTickHook( void ){
	//uart_puts_num("Counter: ", timerTIMER_1_COUNT_VALUE);
	//uart_puts_num("macro = ", PROG_GET_REG(0x28));
    tick_count++;
}

// ============================== POWER MANAGEMENT ==========================
static void enterSleepMode( void ){
	SysCtlSleep();
}

static void configSleepMode( void ){
}

// ======================== POWER AND TEMP MEASUREMENT ======================
#ifdef USE_VARTOS
unsigned long getPowerConsumed( portPOWER_ARGS_TYPE params ){
	/* in reality here we'd query a sensor and report power usage.
	   for simulation purposes we'll have to emulate power usage based
	   on tasks currently scheduled and knob values */
	__asm__("NOP");
}

unsigned long getTemperature (portTEMP_ARGS_TYPE params ){
	/* in reality here we'd query a sensor and report temperature.
	   for simulation purposes we'll have to emulate temperature */
	__asm__("NOP");	
}
#endif


// ========================== ISR HOOKS (UNUSED) ==============================


// ================= CONFIGURE AND QUERY FASTER TIMER FOR STATS ===============
void vConfigureTimerForRunTimeStats( void ){
    unsigned long ulFrequency;

    // we will use Timer 2
    SysCtlPeripheralEnable( SYSCTL_PERIPH_TIMER2 );
    TimerConfigure( TIMER2_BASE, TIMER_CFG_32_BIT_PER );

    // set timer interrupt to be above the kernel
    IntPrioritySet( INT_TIMER2A, configMAX_SYSCALL_INTERRUPT_PRIORITY + (1 << 5) );

    // set timer interrupt period (freq. appears to be sysclk/2 for now)
    // we just set timer to maximum period and count overflows
    ulFrequency = configCPU_CLOCK_HZ / tmrTIMER_2_FREQUENCY;
    TimerLoadSet( TIMER2_BASE, TIMER_A, MAX_32_BIT_VALUE );
    IntEnable( INT_TIMER2A );
    TimerIntEnable( TIMER2_BASE, TIMER_TIMA_TIMEOUT );

    // disable until schedule runs and enables the interrupts
    portDISABLE_INTERRUPTS();

    // enable Timer 2
    TimerEnable( TIMER2_BASE, TIMER_A );

}

void vT2InterruptHandler( void ){
    TimerIntClear( TIMER2_BASE, TIMER_TIMA_TIMEOUT );
    // increase overflow
    //UARTCharPutNonBlocking(UART0_BASE, ' ');
    //pin_status = !pin_status;
    //GPIOPinWrite(GPIO_PORTE_BASE, GPIO_PIN_0, pin_status);
    timer_num_overflows++;

}

unsigned long long vGetTimerValue( void ){
    vemu_start_read();
    return( vemu_active_time() >> 10);
}

// ============================ EXAMPLE TASK ISR ==============================
void taskISR( void ){
    // assign to a task
    #ifdef USE_VARTOS
    taskEnterISR( handleTask3 );
    #endif
    // do whatever

    // end task assignment
    #ifdef USE_VARTOS
    taskExitISR( handleTask3 );
    #endif
}

// ============================ VaRTOS Helpers ==============================
#ifdef USE_VARTOS
static void readPowTemp ( void *pvParameters ){
    portTickType xLastExecutionTime = xTaskGetTickCount();
    vemu_sensors s;
    float temperature;
    char i;

    for( ;; )
    {
        // Enforce task frequency
		vTaskDelayUntil( &xLastExecutionTime, READPOWTEMP_DELAY );
        // enter critical region
        taskENTER_CRITICAL();
        vemu_time_scale(1);

        // always measure temperature and at least append to the windowed histogram
        vemu_read_sensors(&s);
        temperature = ( ( (float)((int)s.t) ) )/10.0;
        //uputs("\ntemperature: ");
        //uputi( ((int)(10*temperature)) );
        //uputs("\n");
        

        // update windowed temperature histogram
        for( i=0; i<TEMP_MODEL_NUM_BINS; i++ ){
            if( temperature < temp_model_leftmost_edge[PowerModel.jidx] + 
                    temp_model_bin_width[PowerModel.jidx]*(i+1) ){
                temp_hist_windowed[i]++;
                temp_hist_numpoints++;
                break;
            }
        }

        // if the power models have not yet converged, append to appropriate matrices
        if( !PowerModel.powerModelDone ){

            // enforce power model busy flag
            PowerModel.powerModelDone = 0;
            // append sleep and active powers
            PowerModel.temps[PowerModel.num] = temperature;
            PowerModel.ps[PowerModel.num] = s.sp;
            PowerModel.pa[PowerModel.num] = s.ap;
            // if enough points are collected, fit the models
            if( ++PowerModel.num == POWER_MODEL_POINTS ){
                // fit sleep power model
                fitPsModel();
                // fit active power model
                fitPaModel();
                // find optimal DC
                PowerModel.optimalDC = findOptimalDC( PowerModel.lifetime_hours,
                        PowerModel.energy_joules );
                uputs("optimal DC:\n");
                uputi((int)(10000*PowerModel.optimalDC));
                uputs("\n");
                // indicate that the model has converged
                PowerModel.powerModelDone = 1;
                // reset power model
                PowerModel.num = 0;
            }
        }

        // exit critical region
        vemu_time_scale(3600);
        taskEXIT_CRITICAL();
    }
}

static void learnKnobTime ( void *pvParameters ){
    portTickType xLastExecutionTime = xTaskGetTickCount();
    char modelIsFull = 0;

    for( ;; )
    {
        // Enforce task frequency
		vTaskDelayUntil( &xLastExecutionTime, LEARNKNOBTIME_DELAY );
   
        // enter critical region
        taskENTER_CRITICAL();
        vemu_time_scale(1);

        // take a snapshot of each task's active time and restart
        modelIsFull = taskActiveTimeSnapshot(3600);

        if( modelIsFull && PowerModel.powerModelDone ){
            // optimize task knobs
            optimizeTaskKnobs( &PowerModel.optimalDC );
            // reset model
            taskResetActiveTimeModel(); 
            modelIsFull = 0;
            // exit critical region
            vemu_time_scale(3600);
            taskEXIT_CRITICAL();

            // suspend our own operation until someone wakes us up
            vTaskSuspend( NULL );
        }
        
        // exit critical region
        vemu_time_scale(3600);
        taskEXIT_CRITICAL();

    }

}

static void checkErrors ( void *pvParameters ){
    portTickType xLastExecutionTime = xTaskGetTickCount();
    char i;
    unsigned long ps,pa;
    float average_power, predicted_power;
    vemu_sensors s;
    float temperature, freq;

    for( ;; )
    {
        // Enforce task frequency
		vTaskDelayUntil( &xLastExecutionTime, CHECKERRORS_DELAY );
        // enter critical region
        taskENTER_CRITICAL();
        vemu_time_scale(1);

        
        // check the windowed histogram + power curves + energy monitor
        // to see if we're doing as predicted. If not, scale optimal DC and
        // reoptimize as needed
	    vemu_read_sensors(&s);
        average_power = (float)s.avp;
        predicted_power = 0.0;
        // calculate predicted energy & reset windowed histogram for the next time interval
        for( i=0; i<TEMP_MODEL_NUM_BINS; i++ ){
            freq = ((float)temp_hist_windowed[i])/((float)temp_hist_numpoints);
            temperature = temp_model_leftmost_edge[PowerModel.jidx] + 
                temp_model_bin_width[PowerModel.jidx]*(i+1);
            // calculate sleep and active powers for this temp.
            ps = getPs(temperature);
            pa = getPa(temperature);
            // add sleep energy
            predicted_power += (float)(1-PowerModel.optimalDC)*freq*ps;
            // add active energy
            predicted_power += (float)PowerModel.optimalDC*freq*pa;
        }
        //uputs("\n");
        //uputi((int)predicted_power);
        //uputs("\n");
        //uputi((int)average_power);
        //uputs("\n");

        // compare actual and predicted to see if there is an error
        //
        //uputs("\n");
        //uputi((int)(1000*predicted_power));
        //uputs(",");
        //uputi((int)(1000*average_power));
        //uputs(",");
        //uputi((int)(10000*PowerModel.optimalDC));

        //if( ABS_VAL( (predicted_power - average_power)/predicted_power ) > POWER_MODEL_ERROR_THRESHOLD ){
            // KP must be > 0 so that predicted-actual being large will mean we can add to optDC
        //    PowerModel.optimalDC += -POWER_MODEL_ERROR_KP*( (predicted_power - average_power)/1e6 );
            // now we have to reoptimize
        //    optimizeTaskKnobs( &PowerModel.optimalDC );
        //}
        
        // exit critical region
        vemu_time_scale(3600);
        taskEXIT_CRITICAL();

    }

}


/* linear regression to find T->Ps curve for processor instance */
void fitPsModel( void ){

    float* x = PowerModel.temps;
    // y = resulting time spent
    float* y = PowerModel.ps;
    // ndata = number of points (length of array)
    int ndata = PowerModel.num;

    float a, b, siga, sigb, chi2, q;
    int i;
    float t, sxoss, sx=0.0, sy=0.0, st2=0.0, ss, sigdat;

    b = 0.0;
    for(i=0; i<ndata; i++){
        sx += x[i];
        sy += log(y[i]);
    }
    ss = ndata;
    sxoss = sx/ss;
    for(i=0; i<ndata; i++){
        t = x[i]-sxoss;
        st2 += t*t;
        b += t*log(y[i]);
    }
    b /= st2;
    a = (sy-sx*(b))/ss;
    // assign offset and sloap
    PowerModel.psoffset = a;
    PowerModel.psslope = b;
    uputs("sleep offset, slope:\n");
    uputi((int)(100*a));
    uputs("\n");
    uputi((int)(1000*b));
    uputs("\n");
    // override the slope number
    PowerModel.psslope = 0.01723;

}

/* linear regression to find T->Pa curve for processor instance */
void fitPaModel( void ){
    // the active power model is fit by linear regression after subtracting
    // what the sleep power model predicts for Ps. In other words, this cannot
    // be called until Ps has been modeled
    float pa_minus_ps[POWER_MODEL_POINTS];
    char j;
    for(j=0; j<POWER_MODEL_POINTS; j++){
        pa_minus_ps[j] = PowerModel.pa[j] - PowerModel.ps[j];
    }

    float* x = PowerModel.temps;
    // y = resulting time spent
    float* y = pa_minus_ps;
    // ndata = number of points (length of array)
    int ndata = PowerModel.num;

    float a, b, siga, sigb, chi2, q;
    int i;
    float t, sxoss, sx=0.0, sy=0.0, st2=0.0, ss, sigdat;

    b = 0.0;
    for(i=0; i<ndata; i++){
        sx += x[i];
        sy += y[i];
    }
    ss = ndata;
    sxoss = sx/ss;
    for(i=0; i<ndata; i++){
        t = x[i]-sxoss;
        st2 += t*t;
        b += t*y[i];
    }
    b /= st2;
    a = (sy-sx*(b))/ss;
    // assign offset and sloap
    PowerModel.paoffset = a;
    PowerModel.paslope = b;
    uputs("active offset, slope:\n");
    uputi((int)(1*a));
    uputs("\n");
    uputi((int)(1000*b));
    uputs("\n");
}

/* optimize system-wide duty cycle */
float findOptimalDC( unsigned int hours, unsigned int joules ){
    float sum1 = 0.0;
    float sum2 = 0.0;
    float temp;
    float ps,pa,gamma;
    unsigned int i;

    for( i=0; i<TEMP_MODEL_NUM_BINS; i++ ){
        temp = temp_model_start_temp[PowerModel.jidx] + 
            i*temp_model_bin_width[PowerModel.jidx];
        ps = getPs(temp);
        pa = getPa(temp);
        // get sum1
        sum1 += 1e-9*ps*0.5*(float)temp_model_hist[PowerModel.jidx][i]/255.0;
        // get sum2
        sum2 += (0.5*(float)temp_model_hist[PowerModel.jidx][i]/255.0)*1e-9*pa;
    }

    gamma = (joules - (hours*60*60)*sum1 )/( (hours*60*60)*sum2 );
    if( gamma > 1 ){
        return 1.0;
    }else if( gamma < 0 ){
        return 0.0;
    }else{
        return gamma;
    }
}

unsigned long getPa(char temp){

    return(1187500);
    //return(PowerModel.paoffset + PowerModel.paslope*temp);
}

unsigned long getPs(char temp){

    return(330000);
    //return(exp(PowerModel.psoffset + PowerModel.psslope*temp));
}







#endif

