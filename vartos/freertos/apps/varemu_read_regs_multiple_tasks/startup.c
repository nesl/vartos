//*****************************************************************************
//
// startup.c - Boot code for Stellaris.
//
// Copyright (c) 2005-2007 Luminary Micro, Inc.  All rights reserved.
// 
// Software License Agreement
// 
// Luminary Micro, Inc. (LMI) is supplying this software for use solely and
// exclusively on LMI's microcontroller products.
// 
// The software is owned by LMI and/or its suppliers, and is protected under
// applicable copyright laws.  All rights are reserved.  Any use in violation
// of the foregoing restrictions may subject the user to criminal sanctions
// under applicable laws, as well as to civil liability for the breach of the
// terms and conditions of this license.
// 
// THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
// OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
// LMI SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR
// CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
// 
// This is part of revision 1392 of the Stellaris Peripheral Driver Library.
//
//*****************************************************************************

//*****************************************************************************
//
// Forward declaration of the default fault handlers.
//
//*****************************************************************************
void ResetISR(void);
static void NmiSR(void);
static void FaultISR(void);
static void IntDefaultHandler(void);

//*****************************************************************************
//
// The entry point for the application.
//
//*****************************************************************************
extern int main(void);
extern void xPortPendSVHandler(void);
extern void xPortSysTickHandler(void);
extern void vPortSVCHandler( void );
extern void Timer0IntHandler( void );
extern void vT2InterruptHandler( void );
extern void vT3InterruptHandler( void );
extern void vEMAC_ISR(void);

//*****************************************************************************
//
// Reserve space for the system stack.
//
//*****************************************************************************
#ifndef STACK_SIZE
#define STACK_SIZE                              120
#endif
static unsigned long pulStack[STACK_SIZE];

static void IntDefaultHandler1(void) {    uputs("IntDefaultHandler1\n"); while(1){}; }
static void IntDefaultHandler2(void) {    uputs("IntDefaultHandler2\n"); while(1){}; }
static void IntDefaultHandler3(void) {   /* uputs("IntDefaultHandler3\n"); */ while(1){}; }
static void IntDefaultHandler4(void) {    uputs("IntDefaultHandler4\n"); while(1){}; }
static void IntDefaultHandler5(void) {    uputs("IntDefaultHandler5\n"); while(1){}; }
static void IntDefaultHandler6(void) {    uputs("IntDefaultHandler6\n"); while(1){}; }
static void IntDefaultHandler7(void) {    uputs("IntDefaultHandler7\n"); while(1){}; }
static void IntDefaultHandler8(void) {    uputs("IntDefaultHandler8\n"); while(1){}; }
static void IntDefaultHandler9(void) {    uputs("IntDefaultHandler9\n"); while(1){}; }
static void IntDefaultHandler10(void) {    uputs("IntDefaultHandler10\n"); while(1){}; }
static void IntDefaultHandler11(void) {    uputs("IntDefaultHandler11\n"); while(1){}; }
static void IntDefaultHandler12(void) {    uputs("IntDefaultHandler12\n"); while(1){}; }
static void IntDefaultHandler13(void) {    uputs("IntDefaultHandler13\n"); while(1){}; }
static void IntDefaultHandler14(void) {    uputs("IntDefaultHandler14\n"); while(1){}; }
static void IntDefaultHandler15(void) {    uputs("IntDefaultHandler15\n"); while(1){}; }
static void IntDefaultHandler16(void) {    uputs("IntDefaultHandler16\n"); while(1){}; }
static void IntDefaultHandler17(void) {    uputs("IntDefaultHandler17\n"); while(1){}; }
static void IntDefaultHandler18(void) {    uputs("IntDefaultHandler18\n"); while(1){}; }
static void IntDefaultHandler19(void) {    uputs("IntDefaultHandler19\n"); while(1){}; }
static void IntDefaultHandler20(void) {    uputs("IntDefaultHandler20\n"); while(1){}; }
static void IntDefaultHandler21(void) {    uputs("IntDefaultHandler21\n"); while(1){}; }
static void IntDefaultHandler22(void) {    uputs("IntDefaultHandler22\n"); while(1){}; }
static void IntDefaultHandler23(void) {    uputs("IntDefaultHandler23\n"); while(1){}; }
static void IntDefaultHandler24(void) {    uputs("IntDefaultHandler24\n"); while(1){}; }
static void IntDefaultHandler25(void) {    uputs("IntDefaultHandler25\n"); while(1){}; }
static void IntDefaultHandler26(void) {    uputs("IntDefaultHandler26\n"); while(1){}; }
static void IntDefaultHandler27(void) {    uputs("IntDefaultHandler27\n"); while(1){}; }
static void IntDefaultHandler28(void) {    uputs("IntDefaultHandler28\n"); while(1){}; }
static void IntDefaultHandler29(void) {    uputs("IntDefaultHandler29\n"); while(1){}; }
static void IntDefaultHandler30(void) {    uputs("IntDefaultHandler30\n"); while(1){}; }
static void IntDefaultHandler31(void) {    uputs("IntDefaultHandler31\n"); while(1){}; }
static void IntDefaultHandler32(void) {    uputs("IntDefaultHandler32\n"); while(1){}; }
static void IntDefaultHandler33(void) {    uputs("IntDefaultHandler33\n"); while(1){}; }
static void IntDefaultHandler34(void) {    uputs("IntDefaultHandler34\n"); while(1){}; }
static void IntDefaultHandler35(void) {    uputs("IntDefaultHandler35\n"); while(1){}; }
static void IntDefaultHandler36(void) {    uputs("IntDefaultHandler36\n"); while(1){}; }
static void IntDefaultHandler37(void) {    uputs("IntDefaultHandler37\n"); while(1){}; }
static void IntDefaultHandler38(void) {    uputs("IntDefaultHandler38\n"); while(1){}; }
static void IntDefaultHandler39(void) {    uputs("IntDefaultHandler39\n"); while(1){}; }
static void IntDefaultHandler40(void) {    uputs("IntDefaultHandler40\n"); while(1){}; }
static void IntDefaultHandler41(void) {    uputs("IntDefaultHandler41\n"); while(1){}; }
static void IntDefaultHandler42(void) {    uputs("IntDefaultHandler42\n"); while(1){}; }
static void IntDefaultHandler43(void) {    uputs("IntDefaultHandler43\n"); while(1){}; }
static void IntDefaultHandler44(void) {    uputs("IntDefaultHandler44\n"); while(1){}; }
static void IntDefaultHandler45(void) {    uputs("IntDefaultHandler45\n"); while(1){}; }

//*****************************************************************************
//
// The minimal vector table for a Cortex-M3.  Note that the proper constructs
// must be placed on this to ensure that it ends up at physical address
// 0x0000.0000.
//
//*****************************************************************************
__attribute__ ((section(".isr_vector")))
void (* const g_pfnVectors[])(void) =
{
    (void (*)(void))((unsigned long)pulStack + sizeof(pulStack)),
                                            // The initial stack pointer
    ResetISR,                               // The reset handler
    NmiSR,                                  // The NMI handler
    FaultISR,                               // The hard fault handler
    IntDefaultHandler1,                      // The MPU fault handler
    IntDefaultHandler2,                      // The bus fault handler
    IntDefaultHandler3,                      // The usage fault handler
    0,                                      // Reserved
    0,                                      // Reserved
    0,                                      // Reserved
    0,                                      // Reserved
    vPortSVCHandler,						// SVCall handler
    IntDefaultHandler4,                      // Debug monitor handler
    0,                                      // Reserved
    xPortPendSVHandler,                     // The PendSV handler
    xPortSysTickHandler,                    // The SysTick handler
    IntDefaultHandler5,                      // GPIO Port A
    IntDefaultHandler6,                      // GPIO Port B
    IntDefaultHandler7,                      // GPIO Port C
    IntDefaultHandler8,                      // GPIO Port D
    IntDefaultHandler9,                      // GPIO Port E
    IntDefaultHandler10,                      // UART0 Rx and Tx
    IntDefaultHandler11,                      // UART1 Rx and Tx
    IntDefaultHandler12,                      // SSI Rx and Tx
    IntDefaultHandler13,                      // I2C Master and Slave
    IntDefaultHandler14,                      // PWM Fault
    IntDefaultHandler15,                      // PWM Generator 0
    IntDefaultHandler16,                      // PWM Generator 1
    IntDefaultHandler17,                      // PWM Generator 2
    IntDefaultHandler18,                      // Quadrature Encoder
    IntDefaultHandler19,                      // ADC Sequence 0
    IntDefaultHandler20,                      // ADC Sequence 1
    IntDefaultHandler21,                      // ADC Sequence 2
    IntDefaultHandler22,                      // ADC Sequence 3
    IntDefaultHandler23,                      // Watchdog timer
    IntDefaultHandler24,                      // Timer 0 subtimer A
    IntDefaultHandler25,                      // Timer 0 subtimer B
    IntDefaultHandler26,                      // Timer 1 subtimer A
    IntDefaultHandler27,                      // Timer 1 subtimer B
    vT2InterruptHandler,                      // Timer 2 subtimer A
    IntDefaultHandler29,                      // Timer 2 subtimer B
    IntDefaultHandler30,                      // Analog Comparator 0
    IntDefaultHandler31,                      // Analog Comparator 1
    IntDefaultHandler32,                      // Analog Comparator 2
    IntDefaultHandler33,                      // System Control (PLL, OSC, BO)
    IntDefaultHandler34,                      // FLASH Control
    IntDefaultHandler35,                      // GPIO Port F
    IntDefaultHandler36,                      // GPIO Port G
    IntDefaultHandler37,                      // GPIO Port H
    IntDefaultHandler38,                      // UART2 Rx and Tx
    IntDefaultHandler39,                      // SSI1 Rx and Tx
    IntDefaultHandler40,                    // Timer 3 subtimer A
    IntDefaultHandler41,                      // Timer 3 subtimer B
    IntDefaultHandler42,                      // I2C1 Master and Slave
    IntDefaultHandler43,                      // Quadrature Encoder 1
    IntDefaultHandler44,                      // CAN0
    IntDefaultHandler45,                      // CAN1
    0,                                      // Reserved
    IntDefaultHandler,                              // Ethernet
    IntDefaultHandler                       // Hibernate
};

//*****************************************************************************
//
// The following are constructs created by the linker, indicating where the
// the "data" and "bss" segments reside in memory.  The initializers for the
// for the "data" segment resides immediately following the "text" segment.
//
//*****************************************************************************
extern unsigned long _etext;
extern unsigned long _data;
extern unsigned long _edata;
extern unsigned long _bss;
extern unsigned long _ebss;

//*****************************************************************************
//
// This is the code that gets called when the processor first starts execution
// following a reset event.  Only the absolutely necessary set is performed,
// after which the application supplied main() routine is called.  Any fancy
// actions (such as making decisions based on the reset cause register, and
// resetting the bits in that register) are left solely in the hands of the
// application.
//
//*****************************************************************************
void
ResetISR(void)
{
    unsigned long *pulSrc, *pulDest;

    //
    // Copy the data segment initializers from flash to SRAM.
    //
    pulSrc = &_etext;
    for(pulDest = &_data; pulDest < &_edata; )
    {
        *pulDest++ = *pulSrc++;
    }

    //
    // Zero fill the bss segment.
    //
    for(pulDest = &_bss; pulDest < &_ebss; )
    {
        *pulDest++ = 0;
    }

    //
    // Call the application's entry point.
    //
    main();
}

//*****************************************************************************
//
// This is the code that gets called when the processor receives a NMI.  This
// simply enters an infinite loop, preserving the system state for examination
// by a debugger.
//
//*****************************************************************************
static void
NmiSR(void)
{
    //
    // Enter an infinite loop.
    //
    while(1)
    {
    }
}

//*****************************************************************************
//
// This is the code that gets called when the processor receives a fault
// interrupt.  This simply enters an infinite loop, preserving the system state
// for examination by a debugger.
//
//*****************************************************************************
static void
FaultISR(void)
{
    //
    // Enter an infinite loop.
    //
    while(1)
    {
    }
}

//*****************************************************************************
//
// This is the code that gets called when the processor receives an unexpected
// interrupt.  This simply enters an infinite loop, preserving the system state
// for examination by a debugger.
//
//*****************************************************************************
static void
IntDefaultHandler(void)
{
    //
    // Go into an infinite loop.
    //
	return;
    
    while(1)
    {
    }
}




//*****************************************************************************
//
// A dummy printf function to satisfy the calls to printf from uip.  This
// avoids pulling in the run-time library.
//
//*****************************************************************************
int
uipprintf(const char *fmt, ...)
{
    return(0);
}

