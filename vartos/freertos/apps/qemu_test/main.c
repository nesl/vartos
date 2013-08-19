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

/* Task priorities */
#define mainTASK_PRIORITY	( tskIDLE_PRIORITY + 1 )

/* Task delays */
#define TASK1_DELAY ((portTickType) 1000 / portTICK_RATE_MS )
#define TASK2_DELAY ((portTickType) 1000 / portTICK_RATE_MS )
#define TASK3_DELAY ((portTickType) 2000 / portTICK_RATE_MS )
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
#endif

// ============================ GLOBAL VARIABLES ==========================
/* handles pointing to tasks in TCB */
xTaskHandle handleTask1;
xTaskHandle handleTask2;
xTaskHandle handleTask3;

/* knob values for scheduler to tune */
#ifdef USE_VARTOS
portKNOB_TYPE task1_knob;
portKNOB_TYPE task2_knob;
portKNOB_TYPE task3_knob;
#else
unsigned int task1_knob = 10;
unsigned int task2_knob = 10; unsigned int task3_knob = 10;
#endif

char pin_status;
unsigned int dummy_counter = 0;

// ============================= T -> Ps MAPPING ==========================

//#include "temp_power_model.h"

// ================================= MAIN =================================
int main( void )
{
	/* Configure the clocks, UART and GPIO. */
	prvSetupHardware();

	/* Start the tasks defined within the file. */
	// arguments: hook, name, stack_size, hook_arguments, priority, return_handle, knob_handle, knob_min, knob_max, utility_scalar
	// *Note: task_knob values are initialized to task_knob_min by task creation API
    #ifdef USE_VARTOS
	xTaskCreate( vHookTask2, "Task2", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask2, &task2_knob, 50, 500, 1);
	xTaskCreate( vHookTask3, "Task3", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask3, &task3_knob, 50, 500, 1);
    #else
    xTaskCreate( vHookTask2, "Task2", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask2);
    xTaskCreate( vHookTask3, "Task3", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask3);
    #endif

	/* Start the scheduler. */
	// power function, temp function, desired lifetime (hours), battery capacity (mWh)
    #ifdef USE_VARTOS
	vTaskStartScheduler( getPowerConsumed , getTemperature , 100*24 , 600 );
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
    /*
    int taskid = *(int *)pvParameters;
	portTickType xLastExecutionTime = xTaskGetTickCount();
    
    vemu_regs curr, prev, delta;
    
    //memset(&curr, 0, sizeof(vemu_regs));
    //memset(&prev, 0, sizeof(vemu_regs));
    //memset(&delta, 0, sizeof(vemu_regs));

    vemu_regs *cp, *pp, *tp, *dp;
    cp = &curr;
    pp = &prev;
    dp = &delta;
    
	for( ;; )
	{
		// Enforce task frequency //
		vTaskDelayUntil( &xLastExecutionTime, TASK1_DELAY );

        // Update varEMU stats //
        
        tp = pp;
        pp = cp;
        cp = tp;
        vemu_read_state(cp);
        //vemu_delta(dp, cp, pp);

        //uputs("vVemuTask ");
		//uputi(taskid);
		uputs("     ");
		
		unsigned long long number = cp->total_cycles;
        number = 3; // broken for now
        //uputs("T: ");
        //uputi(cp->total_act_time);
        //uputs("\n");
		
        uputs("A: ");
        uputi(32);
        //uputi((int)cp->total_act_time);
        uputs("   ");
        uputs("B: ");
        uputi(43);
        //uputi((int)cp->total_cycles);
        uputs("   ");
        uputs("C: ");
        uputi(58);
        uputs("\n");

        uputs("here\n");
	}
    */
}

/* TASK 2 */
static void vHookTask2( void *pvParameters )
{
	portTickType xLastExecutionTime = xTaskGetTickCount();
    unsigned int i;
    char led_status = 0;
    unsigned long long old_time = vGetTimerValue();

	for( ;; )
	{
		/* Enforce task frequency */
		vTaskDelayUntil( &xLastExecutionTime, TASK2_DELAY );
        /*
        uputs("Task2 ");
        uputs("knob: ");
        uputi(task2_knob);
        uputs(" inst: ");
        uputi(getMiscVal());
        uputs("\n");
        */
        led_status = !led_status;
        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_0, led_status);
        uputs("Fire!\n");

	}
}

/* TASK 3 */
static void vHookTask3( void *pvParameters )
{
    portTickType xLastExecutionTime = xTaskGetTickCount();
    unsigned int i;
    //char pin_status = 0;

    for( ;; )
    {
        /* Enforce task frequency */
        vTaskDelayUntil( &xLastExecutionTime, TASK3_DELAY );
        /*
        uputs("Task3 ");
        uputs("knob: ");
        uputi(task3_knob);
        uputs(" inst: ");
        uputi(getMiscVal());
        uputs("\n");
        */
        uputs("I'm task3, bitch!\n");
    }
}

// ============================= SCHEDULER HOOKS ============================
void vApplicationIdleHook( void ){
	/* Enter low power sleep (with clock) whenever idle
	   WFI could well be unimplemented in QEMU, and more than likely is.
	   the best we can do may just be to print out the time we entered idle. */
	//uart_puts_num("Entered idle task at time: ", 0);
	//__asm__("WFI");
//	enterSleepMode();
	
}

void vApplicationTickHook( void ){
	//uart_puts_num("Counter: ", timerTIMER_1_COUNT_VALUE);
	//uart_puts_num("macro = ", PROG_GET_REG(0x28));
    dummy_counter++;
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
    /* Currently we use the instruction counter from VarEMU */
    //vemu_regs curr;
    //vemu_read_state(&curr);
	//return(	curr.total_cycles );
    return( 0 );
    return( timer_num_overflows*MAX_32_BIT_VALUE + TimerValueGet( TIMER2_BASE, TIMER_A ) );
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

