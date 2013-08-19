#include "FreeRTOS.h"
#include "vemu.h"
#include "task.h"

#include "hw_memmap.h"
#include "hw_types.h"
#include "hw_sysctl.h"
#include "sysctl.h"
#include "gpio.h"

#include <math.h>

static void vVemuTask( void *pvParameters );
static void vDummyTask( void *pvParameters );


void prvSetupHardware( void )
{
	/* Set the clocking to run from the PLL at 50 MHz */
	SysCtlClockSet( SYSCTL_SYSDIV_4 | SYSCTL_USE_PLL | SYSCTL_OSC_MAIN | SYSCTL_XTAL_8MHZ );
}

void vApplicationIdleHook( void ){

	__asm__("WFI");
	
}

volatile unsigned long long x, y, m;

int main( void )
{
	prvSetupHardware();		
	
	static int vemu1 = 1;
	static int vemu2 = 2;
	static int vemu3 = 3;

		
	xTaskCreate( vVemuTask, "VEMU", configMINIMAL_STACK_SIZE, &vemu1, tskIDLE_PRIORITY + 1, NULL );
	//xTaskCreate( vVemuTask, "VEMU", configMINIMAL_STACK_SIZE, &vemu2, tskIDLE_PRIORITY + 2, NULL );
	//xTaskCreate( vVemuTask, "VEMU", configMINIMAL_STACK_SIZE, &vemu3, tskIDLE_PRIORITY + 3, NULL );
	
	//xTaskCreate( vDummyTask, "Dummy", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY + 4, NULL );
	
	int x,y;
	
	x = 1;

	y = exp(x);
	uputi(y);

	vTaskStartScheduler();



	return 0;

}

static void vDummyTask( void *pvParameters )
{
	while (1)
	{
		uputs("vDummyTask\n");
		portTickType xLastExecutionTime = xTaskGetTickCount();
		vTaskDelayUntil( &xLastExecutionTime, 1000 );
	}
} 


static void vVemuTask( void *pvParameters )
{
	
	vemu_regs curr, prev, delta;
	
	int taskid = *(int *)pvParameters;
	
	memset(&curr, 0, sizeof(vemu_regs));
	memset(&prev, 0, sizeof(vemu_regs));
	memset(&delta, 0, sizeof(vemu_regs));


	vemu_regs *cp, *pp, *tp, *dp;
	
	
	
	cp = &curr;
	pp = &prev;
	dp = &delta;
	
	unsigned long long cycles = 0;	

	while(1) {
		tp = pp;
		pp = cp;
		cp = tp;	
			
		vemu_read_state(cp);		
		//cycles = vemu_read_reg(TOTAL_CYCLES);		
		
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
		
		portTickType xLastExecutionTime = xTaskGetTickCount();
		vTaskDelayUntil( &xLastExecutionTime, 1000  );
		
		
	}

}
