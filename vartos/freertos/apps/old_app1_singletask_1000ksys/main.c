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

//__aeabi_unwind_cpp_pr0[0];

/* Task priorities */
#define mainTASK_PRIORITY	( tskIDLE_PRIORITY + 1 )

/* Task delays */
#define TASK1_DELAY ((portTickType) 100 / portTICK_RATE_MS )
#define TASK2_DELAY ((portTickType) 1000 / portTICK_RATE_MS )
#define TASK3_DELAY ((portTickType) 2000 / portTICK_RATE_MS )
/* VaRTOS helper periods */
#define READPOWTEMP_DELAY ((portTickType) 1000 / portTICK_RATE_MS )
//#define LEARNKNOBTIME_DELAY ((portTickType) 1000 / portTICK_RATE_MS )
// (the above will take from task.h, which defines sysMONITOR_TIME_STEP_MS
#define CHECKERRORS_DELAY ((portTickType) 2000 / portTICK_RATE_MS )

/* High freq. timer freq */
#define tmrTIMER_2_FREQUENCY ( 1UL )
#define MAX_32_BIT_VALUE ( 4294967295 )
unsigned int timer_num_overflows = 0;

// ========================== FUNCTION DECLARATIONS ========================

/* Configure the processor and peripherals */
static void prvSetupHardware( void );

/* Example empty task */
static void vHookTask1( void *pvParameters );
static void vHookTask2( void *pvParameters );
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
#endif

// ============================ GLOBAL VARIABLES ==========================
/* handles pointing to tasks in TCB */
xTaskHandle handleTask1;
xTaskHandle handleTask2;
xTaskHandle handleTask3;
/* model learning tasks */
xTaskHandle handle_readPowTemp;
xTaskHandle handle_learnKnobTime;
xTaskHandle handle_checkErrors;

/* knob values for scheduler to tune */
#ifdef USE_VARTOS
portKNOB_TYPE task1_knob;
portKNOB_TYPE task2_knob;
portKNOB_TYPE task3_knob;
#else
unsigned int task1_knob = 10;
unsigned int task2_knob = 10; 
unsigned int task3_knob = 10;
#endif

/* model arrays and variables */
#ifdef USE_VARTOS
#define POWER_MODEL_POINTS 20
typedef struct power_model_t {
    // arrays for model construction
    unsigned char temps[POWER_MODEL_POINTS];
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
} power_model_t;
power_model_t PowerModel = {.num=0, .powerModelDone=0};
#endif

/* debugging pin states */
char pin_status;

// ================================= MAIN =================================
int main( void )
{
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
	xTaskCreate( vHookTask1, "Task1", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask1, &task1_knob, 1, 200, 1);
	//xTaskCreate( vHookTask2, "Task2", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask2, &task2_knob, 50, 500, 1);
    #else
    xTaskCreate( vHookTask1, "Task1", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask1);
    //xTaskCreate( vHookTask2, "Task2", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask2);
    #endif

	/* Start the scheduler. */
	// power function, temp function, desired lifetime (hours), battery capacity (mWh)
    #ifdef USE_VARTOS
    PowerModel.lifetime_hours = 110*24;
    PowerModel.energy_joules = 2592;
	vTaskStartScheduler( getPowerConsumed , getTemperature , rom_temp_model , 100*24 , 600 );
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
/* TASK 1 */
static void vHookTask1( void *pvParameters )
{
	portTickType xLastExecutionTime = xTaskGetTickCount();
    unsigned int i,j;
    char led_status = 0;
    unsigned long long old_time = vGetTimerValue();
	vemu_regs d,p,c;
	vemu_regs *dp,*pp,*cp,*tp;	
    vemu_sensors s;
	dp = &d;
	pp = &p;
	cp = &c;
	vemu_read_registers(cp);
	for( ;; )
	{
		/* Enforce task frequency */
		vTaskDelayUntil( &xLastExecutionTime, TASK1_DELAY );
		tp = cp;
		cp = pp;
		pp = tp;
        vemu_read_registers(cp);
        vemu_read_sensors(&s);
		vemu_delta(dp, cp, pp);
        
        led_status = !led_status;
        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_0, led_status);

        // task body, does a NOP loop
        for( i=0; i<task1_knob; i++ ){
            for( j=0; j<100; j++){
                __asm__("nop");
            }
        }

        uputs("\n--TASK1--\n");
        uputs("\nKnob :");
        uputi(task1_knob);
        uputs("\nMisc :");
        uputi(getMiscVal());
        uputs("\nA t: ");
        uputi(dp->at);
        uputs("\nA e: ");
        uputi(dp->ae);   
        uputs("\nS t: ");
        uputi(dp->st);
        uputs("\nS e: ");
        uputi(dp->se); 
        uputs("\nT  : ");
        uputi(s.t); 
        uputs("\nPa : ");
        uputi(s.ap); 
        uputs("\nPs : ");
        uputi(s.sp);                 
	}
}

/* TASK 2 */
static void vHookTask2( void *pvParameters )
{
	portTickType xLastExecutionTime = xTaskGetTickCount();
    unsigned int i;
    char led_status = 0;
	vemu_regs d,p,c;
	vemu_regs *dp,*pp,*cp,*tp;	
    vemu_sensors s;
	dp = &d;
	pp = &p;
	cp = &c;
	vemu_read_registers(cp);
	for( ;; )
	{
		/* Enforce task frequency */
		vTaskDelayUntil( &xLastExecutionTime, TASK3_DELAY );
    	tp = cp;
		cp = pp;
		pp = tp;
        vemu_read_registers(cp);
        vemu_read_sensors(&s);
		vemu_delta(dp, cp, pp);
        /*
        uputs("Task2 ");
        uputs("knob: ");
        uputi(task2_knob);
        uputs(" inst: ");
        uputi(getMiscVal());
        uputs("\n");
        */
        led_status = !led_status;
        GPIOPinWrite(GPIO_PORTE_BASE, GPIO_PIN_0, led_status);

        uputs("\n--TASK2--\n");
         uputs("\nA t: ");
        uputi(dp->at);
        uputs("\nA e: ");
        uputi(dp->ae);   
        uputs("\nS t: ");
        uputi(dp->st);
        uputs("\nS e: ");
        uputi(dp->se); 
        uputs("\nT  : ");
        uputi(s.t); 
        uputs("\nPa : ");
        uputi(s.ap); 
        uputs("\nPs : ");
        uputi(s.sp);                 
        uputs("\ncounter : ");
        uputi(getMiscVal());
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
    return( vemu_active_time() );
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

    for( ;; )
    {
        // Enforce task frequency
		vTaskDelayUntil( &xLastExecutionTime, READPOWTEMP_DELAY );
        // enforce power model busy flag
        PowerModel.powerModelDone = 0;
        // read sensors
        vemu_read_sensors(&s);
        PowerModel.temps[PowerModel.num] = s.t;
        PowerModel.ps[PowerModel.num] = s.sp;
        PowerModel.pa[PowerModel.num] = s.ap;
        // if points are collected, fit the models
        if( ++PowerModel.num == POWER_MODEL_POINTS ){
            // fit sleep power model
            fitPsModel();
            // fit active power model
            fitPaModel();
            // print results
            uputs("\n\n<<<       slope / offset :       >>>\n");
            uputi((int)(1000*PowerModel.psslope));
            uputs("\n");
            uputi((int)(1000*PowerModel.psoffset));
            uputs("\n");
            uputi((int)(1000*PowerModel.paslope));
            uputs("\n");
            uputi((int)(1000*PowerModel.paoffset));
            uputs("\n");
            // find optimal DC
            PowerModel.optimalDC = findOptimalDC( PowerModel.lifetime_hours,
                    PowerModel.energy_joules );
            uputs("optimal DC x 1000\n");
            uputi((int)(1000*PowerModel.optimalDC));
            uputs("\n");

            // indicate that the model has converged
            PowerModel.powerModelDone = 1;
            // reset power model
            PowerModel.num = 0;
            // suspend our own operation until someone wakes us up
            vTaskSuspend( NULL );
        }
    }
}

static void learnKnobTime ( void *pvParameters ){
    portTickType xLastExecutionTime = xTaskGetTickCount();
    char modelIsFull = 0;

    for( ;; )
    {
        // Enforce task frequency
		vTaskDelayUntil( &xLastExecutionTime, sysMONITOR_TIME_STEP_MS );
        
        // take a snapshot of each task's active time and restart
        modelIsFull = taskActiveTimeSnapshot(3600);

        if( modelIsFull && PowerModel.powerModelDone ){
            // optimize task knobs
            optimizeTaskKnobs( &PowerModel.optimalDC );
            // reset model
            taskResetActiveTimeModel(); 
            modelIsFull = 0;
            // suspend our own operation until someone wakes us up
            vTaskSuspend( NULL );
        }
        
    }

}

static void checkErrors ( void *pvParameters ){
    portTickType xLastExecutionTime = xTaskGetTickCount();

    for( ;; )
    {
        // Enforce task frequency
		vTaskDelayUntil( &xLastExecutionTime, CHECKERRORS_DELAY );

        // TODO: check if we need to rerun our optimization routines
        
    }

}


/* linear regression to find T->Ps curve for processor instance */
void fitPsModel( void ){

    char* x = PowerModel.temps;
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
  
}

/* linear regression to find T->Pa curve for processor instance */
void fitPaModel( void ){
    //TODO: how should we fit this?
    // the active power model is fit by linear regression after subtracting
    // what the sleep power model predicts for Ps. In other words, this cannot
    // be called until Ps has been modeled
    float pa_minus_ps[POWER_MODEL_POINTS];
    char j;
    for(j=0; j<POWER_MODEL_POINTS; j++){
        pa_minus_ps[j] = PowerModel.pa[j] - PowerModel.ps[j];
    }

    char* x = PowerModel.temps;
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
}

/* optimize system-wide duty cycle */
float findOptimalDC( unsigned int hours, unsigned int joules ){
    float sum1 = 0.0;
    float sum2 = 0.0;
    float temp;
    float ps,pa,gamma;
    unsigned int i;

    for( i=0; i<TEMP_MODEL_NUM_BINS; i++ ){
        temp = TEMP_MODEL_START_TEMP + i*TEMP_MODEL_BIN_WIDTH;
        ps = exp(PowerModel.psoffset + PowerModel.psslope*temp);
        pa = PowerModel.paoffset + PowerModel.paslope*temp;
        // get sum1
        sum1 += 1e-9*ps*0.5*(float)rom_temp_model[i]/255.0;
        // get sum2
        sum2 += (0.5*(float)rom_temp_model[i]/255.0)*1e-9*pa;
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









#endif

