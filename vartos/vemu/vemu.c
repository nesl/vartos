#include "vemu.h"
#include <string.h>

static uint8_t *base_pointer = (uint8_t *)VARMOD_BASE;
static uint8_t hw_in_use = FALSE;



uint64_t vemu_read_reg(int offset) {
    
	while(hw_in_use) {}
	hw_in_use = TRUE;    
    uint64_t retval = 0;
    
    *(uint32_t*)(base_pointer + READ_CMD) = 1;
    memcpy(&retval, (uint32_t *)(base_pointer + offset), 8);
	hw_in_use = FALSE;
        
    return retval;
} 

void vemu_write_reg(int offset, uint64_t val) {
	while(hw_in_use) {}
	hw_in_use = TRUE;
    *(uint32_t*)(base_pointer + offset) = (uint32_t)val;
	hw_in_use = FALSE;
    
}

void vemu_read_state(vemu_regs * target)
{
	while(hw_in_use) {}
	hw_in_use = TRUE;
    //*(uint32_t*)(base_pointer + READ_CMD) = 1;
    //target->total_act_time      = ((uint64_t *)base_pointer)[MAX_INSTR_CLASSES*3  ];
    //target->total_act_energy    = ((uint64_t *)base_pointer)[MAX_INSTR_CLASSES*3+1];
    //target->total_cycles        = ((uint64_t *)base_pointer)[MAX_INSTR_CLASSES*3+2];
    //target->slp_time            = ((uint64_t *)base_pointer)[MAX_INSTR_CLASSES*3+3];
    //target->slp_energy          = ((uint64_t *)base_pointer)[MAX_INSTR_CLASSES*3+4];
    //target->error_status        = ((uint64_t *)base_pointer)[MAX_INSTR_CLASSES*3+5];
    // target->total_act_time = 1;
    //target->total_act_energy = 2;
    // target->total_cycles = 3;
    //target->slp_time = 4;
    //target->slp_energy = 5;
    // target->error_status = 6;
	hw_in_use = FALSE;
    
}

void vemu_delta(vemu_regs * target, vemu_regs * new, vemu_regs * old)
{
	int i;
	for (i = 0; i < VEMU_STATE_N_VARS - 1; i++) 
	{
		((vemu_state*)target)->array64[i] = (((vemu_state*)new)->array64[i] - ((vemu_state*)old)->array64[i]);
	}
} 

