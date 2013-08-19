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
#include "vemu.h"
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

/* High freq. timer freq */
#define tmrTIMER_2_FREQUENCY ( 3UL )
#define MAX_32_BIT_VALUE ( 4294967295 )
unsigned int timer_num_overflows = 0;

// ========================== FUNCTION DECLARATIONS ========================

/* Configure the processor and peripherals */
static void prvSetupHardware( void );
void vConfigureTimerForRunTimeStats( void );
unsigned int vGetTimerValue( void );
void ConfigureSysTick( void );
void SysTickISR( void );

// ============================ GLOBAL VARIABLES ==========================
char pin_status;

// ================================= MAIN =================================
int main( void )
{
    int i;

	/* Configure the clocks, UART and GPIO. */
	prvSetupHardware();

    while(1){
        //GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_0, pin_status);
        //pin_status = !pin_status;
        //for( i=0; i<100000; i++){
        //    __asm__("nop");
        //}    
    }

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

    /* configure timer */
    //vConfigureTimerForRunTimeStats();
    ConfigureSysTick();
}
// ============================== TASK HOOKS ============================



// ================= CONFIGURE AND QUERY FASTER TIMER FOR STATS ===============
/*
void vConfigureTimerForRunTimeStats( void ){
    unsigned long ulFrequency;

    // we will use Timer 2
    SysCtlPeripheralEnable( SYSCTL_PERIPH_TIMER2 );
    TimerConfigure( TIMER2_BASE, TIMER_CFG_32_BIT_PER );

    // set timer interrupt to be above the kernel
    //IntPrioritySet( INT_TIMER2A, configMAX_SYSCALL_INTERRUPT_PRIORITY + (1 << 5) );

    // set timer interrupt period (freq. appears to be sysclk/2 for now)
    // we just set timer to maximum period and count overflows
    ulFrequency = 8000000 / tmrTIMER_2_FREQUENCY;
    TimerLoadSet( TIMER2_BASE, TIMER_A, ulFrequency );
    IntEnable( INT_TIMER2A );
    TimerIntEnable( TIMER2_BASE, TIMER_TIMA_TIMEOUT );

    // disable all interupts
    IntMasterDisable();

    // enable Timer 2
    TimerEnable( TIMER2_BASE, TIMER_A );

    // enable all interrupts
    IntMasterEnable();

}
*/

void ConfigureSysTick( void ){

    SysTickPeriodSet(8000);
    SysTickEnable();
    SysTickIntEnable();

    SysTickIntRegister( SysTickISR );
}

void SysTickISR( void ){
     
    pin_status = !pin_status;
    GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_0, pin_status);
    timer_num_overflows++;
    uputs("ST: ");
   //uputi( vGetTimerValue() );
    uputs("\n");
}

void vT2InterruptHandler( void ){
    TimerIntClear( TIMER2_BASE, TIMER_TIMA_TIMEOUT );
    // increase overflow
    //UARTCharPutNonBlocking(UART0_BASE, ' ');
    pin_status = !pin_status;
    GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_0, pin_status);
    timer_num_overflows++;
    uputs("T: ");
    uputi( vGetTimerValue() );
    uputs("\n");

}



unsigned int vGetTimerValue( void ){
    /* Currently we use the instruction counter from VarEMU */
    //vemu_regs curr;
    //vemu_read_state(&curr);
	//return(	curr.total_cycles );
    //return( timer_num_overflows*MAX_32_BIT_VALUE + TimerValueGet( TIMER2_BASE, TIMER_A ) );
    return( TimerValueGet( TIMER2_BASE, TIMER_A ) );
}

