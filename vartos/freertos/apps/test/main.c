/*
 * Example preemptive scheduling with variability-aware duty cycling
 * For use with VarOS, the variability scheduler based on FreeRTOS
 * Authors: Paul Martin and Lucas Wanner
 * Affiliation: NESL, UCLA
 * Contact: pdmartin@ucla.edu
 *
 * Designed to be emulated on QEMU. we make no guarantees of hardware
 * implementations.
 */

// ========================== PREPROCESSOR ========================
/* Environment includes */
//#include "DriverLib.h"

/* Scheduler includes */
#include "FreeRTOS.h"
#include "vemu.h"
#include "task.h"
#include "hw_memmap.h"
#include "hw_types.h"
#include "hw_sysctl.h"
#include "sysctl.h"
#include "gpio.h"

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
unsigned long getPowerConsumed( portPOWER_ARGS_TYPE params );
unsigned long getTemperature (portTEMP_ARGS_TYPE params );


// ============================ GLOBAL VARIABLES ==========================
/* handles pointing to tasks in TCB */
xTaskHandle handleTask1;
xTaskHandle handleTask2;
xTaskHandle handleTask3;

/* knob values for scheduler to tune */
portKNOB_TYPE task1_knob;
portKNOB_TYPE task2_knob;
portKNOB_TYPE task3_knob;

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
	//xTaskCreate( vHookTask1, "Optimize", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask1, &task1_knob, 50, 500, 1);
    xTaskCreate( vHookTask3, "Task3", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask3, &task3_knob, 1, 1000, 1);
	xTaskCreate( vHookTask2, "Task2", configMINIMAL_STACK_SIZE, NULL, mainTASK_PRIORITY, &handleTask2, &task2_knob, 1, 1000, 1);

	/* Start the scheduler. */
	// power function, temp function, desired lifetime (hours), battery capacity (mWh)
	vTaskStartScheduler( getPowerConsumed , getTemperature , 100*24 , 600 );
	
	/* Will only get here if there was insufficient heap to start the
	scheduler. */
    uputs("INSUFFICIENT HEAP\n");
	return 0;
}

// ======================== INITIALIZATION ROUTINES ======================


static void prvSetupHardware( void )
{
	/* Setup the PLL. */
	SysCtlClockSet( SYSCTL_SYSDIV_10 | SYSCTL_USE_PLL | SYSCTL_OSC_MAIN | SYSCTL_XTAL_6MHZ );
    /* set up user led PORTF PIN 0 */

             SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);
                    GPIODirModeSet( GPIO_PORTF_BASE, GPIO_PIN_0, GPIO_DIR_MODE_OUT );
                           GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_0);
}
// ============================== TASK HOOKS ============================

/* TASK 1 */
static void vHookTask1( void *pvParameters )
{
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
		/* Enforce task frequency */
		vTaskDelayUntil( &xLastExecutionTime, TASK1_DELAY );

        /* Update varEMU stats */
        tp = pp;
        pp = cp;
        cp = tp;
        vemu_read_state(cp);
        vemu_delta(dp, cp, pp);

        uputs("vVemuTask ");
		uputi(taskid);
		uputs("     ");
		
		unsigned long long number = cp->total_cycles;
		
		
		uputs("C: "); 
		uputi(number);
		uputs("   ");
		uputs("D: "); 
		uputi(dp->total_cycles);
		uputs("   ");
		uputs("S: "); 
		uputi(cp->slp_time);
		uputs("   ");
		uputs("D: "); 
		uputi(dp->slp_time);
		uputs("   ");
		uputs("AE: "); 
		uputi(cp->total_act_energy);
		uputs("   ");
		uputs("D: "); 
		uputi(dp->total_act_energy);
		uputs("   ");
		uputs("SE: "); 
		uputi(cp->slp_energy);
		uputs("   ");
		uputs("D: "); 
		uputi(dp->slp_energy);

		uputs("\n");

	}
}

/* TASK 2 */
static void vHookTask2( void *pvParameters )
{
	portTickType xLastExecutionTime = xTaskGetTickCount();
    unsigned int i;
    char led_status = 0;

	for( ;; )
	{
		/* Enforce task frequency */
		vTaskDelayUntil( &xLastExecutionTime, TASK2_DELAY );
        uputs("Task2 ");
        uputs("knob: ");
        uputi(task2_knob);
        uputs(" inst: ");
        uputi(getMiscVal());
        uputs("\n");
        for( i=0; i<task2_knob; i++){__asm__("nop");}
        led_status = !led_status;
        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_0, led_status);

	}
}

/* TASK 3 */
static void vHookTask3( void *pvParameters )
{
    portTickType xLastExecutionTime = xTaskGetTickCount();
    unsigned int i;
    for( ;; )
    {
        /* Enforce task frequency */
        vTaskDelayUntil( &xLastExecutionTime, TASK3_DELAY );
        uputs("Task3 ");
        uputs("knob: ");
        uputi(task3_knob);
        uputs(" inst: ");
        uputi(getMiscVal());
        uputs("\n");
        for( i=0; i<task3_knob; i++){__asm__("nop");}

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
}

// ============================== POWER MANAGEMENT ==========================
static void enterSleepMode( void ){
	SysCtlSleep();
}

static void configSleepMode( void ){
}

// ======================== POWER AND TEMP MEASUREMENT ======================
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



// ========================== ISR HOOKS (UNUSED) ==============================


// ================= CONFIGURE AND QUERY FASTER TIMER FOR STATS ===============
void vConfigureTimerForRunTimeStats( void ){
    // do nothing (we'll just use vemu)
}

unsigned long long vGetTimerValue( void ){
    /* Currently we use the instruction counter from VarEMU */
    //vemu_regs curr;
    //vemu_read_state(&curr);
	//return(	curr.total_cycles );
    return( 0 );
}

// ============================ EXAMPLE TASK ISR ==============================
void taskISR( void ){
    // assign to a task
    taskEnterISR( handleTask3 );
    // do whatever

    // end task assignment
    taskExitISR( handleTask3 );
}
