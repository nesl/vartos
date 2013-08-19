#include "uart_put.h"
#include "hw_memmap.h"
#include "hw_types.h"
#include "hw_sysctl.h"
#include "hw_uart.h"
#include "sysctl.h"
#include "gpio.h"
#include "uart.h"


#include <string.h>

int uart_is_initialized = 0;

#define ALPHANUMS "zyxwvutsrqponmlkjihgfedcba9876543210123456789abcdefghijklmnopqrstuvwxyz"

/** 
 * itoa from libpsyc
 * converts an integer to a string, using a base of 10 by default.
 *
 * if you NULL out the output buffer it will return the expected
 * output string length anyway.
 */
int itoa(int number, char* out, int base) {
    int t, count;
    char *p, *q;
    char c;

    p = q = out;
    if (base < 2 || base > 36) base = 10;

    do {
        t = number;
        number /= base;
        if (out) *p = ALPHANUMS[t+35 - number*base];
        p++;
    } while (number);

    if (t < 0) {
         if (out) *p = '-';
         p++;
    }
    count = p-out;
    if (out) {
        *p-- = '\0';
        while(q < p) {
            c = *p;
            *p-- = *q;
            *q++ = c;
        }
    }
    return count;
}

// ======================== UART PUTS EMULATION (QEMU) ======================
/* initialize uart puts */
void _uart_init( void ){
	/* Enable the UART.  */
	SysCtlPeripheralEnable(SYSCTL_PERIPH_UART0);
	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOA);

	/* Set GPIO A0 and A1 as peripheral function.  They are used to output the
	UART signals. */
	GPIODirModeSet( GPIO_PORTA_BASE, GPIO_PIN_0 | GPIO_PIN_1, GPIO_DIR_MODE_HW );

	/* Configure the UART for 8-N-1 operation. */
	UARTConfigSet( UART0_BASE, mainBAUD_RATE, UART_CONFIG_WLEN_8 | UART_CONFIG_PAR_NONE | UART_CONFIG_STOP_ONE );
	uart_is_initialized = 1;
}
/* write a string char by char to uart */
int _uart_puts(char *ptr, int len) {
  int todo;
  for (todo = 0; todo < len; todo++) {
		while( HWREG( UART0_BASE + UART_O_FR ) & UART_FR_TXFF );
		HWREG( UART0_BASE + UART_O_DR ) = *ptr++;	  
  }
  return len;
}

int uputs(char *s)
{
	//if(!uart_is_initialized) {
	//	_uart_init();
	//}
	_uart_puts(s, strlen(s));
}

static char buf[64];

int uputi(int i)
{
    int res;
	res = itoa(i, buf, 10);
    if( res == 0 )
        uputs("zero\n");
	uputs(buf);	
}

int uputx(int i)
{
	itoa(i, buf, 16);
	uputs("0x");
	uputs(buf);
}
