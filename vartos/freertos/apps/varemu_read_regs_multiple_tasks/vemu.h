/*
 * variability.h
 *
 * VarEMU driver for Stellaris
 * Lucas Wanner, 02/06/13
 *
 */

#ifndef _VARIABILITY_H_
#define _VARIABILITY_H_

#define VARMOD_BASE         0x40022000       /* Variability Module */

#define ACT_TIME			0x000
#define ACT_EN				(ACT_TIME + 8*MAX_INSTR_CLASSES)
#define CYCLES				(ACT_EN + 8*MAX_INSTR_CLASSES)
#define TOTAL_ACT_TIME		(CYCLES + 8*MAX_INSTR_CLASSES)
#define TOTAL_ACT_EN		(TOTAL_ACT_TIME + 8)
#define TOTAL_CYCLES		(TOTAL_ACT_EN + 8)
#define SLP_TIME			(TOTAL_CYCLES + 8)
#define SLP_ENERGY			(SLP_TIME + 8)
#define ERRORS_EN			(SLP_ENERGY + 8)
#define TEMPERATURE			(ERRORS_EN + 8)
#define ACT_P				(TEMPERATURE + 8)
#define SLP_P				(ACT_P + 8)


#define READ_CMD       		(0xD00)
#define EXIT_CMD           	(0xF00)

#define	READ_HW				(0x1000000)
#define	READ_SYS			(0x0100000)
#define	READ_PROC			(0x0010000)


#define	MAX_INSTR_CLASSES	8

typedef unsigned long long uint64_t;
typedef unsigned int uint32_t;
typedef unsigned char uint8_t;

typedef struct {
	uint64_t at;
	uint64_t ae;
	uint64_t st;
	uint64_t se;  
} vemu_regs;


typedef struct {
	uint32_t ap;
	uint32_t sp;
	uint32_t t;
} vemu_sensors;

typedef union {
	vemu_regs variables;
	uint32_t array32[4*2];
	uint64_t array64[4];
} vemu_state;

uint8_t *base_pointer = (uint8_t *)VARMOD_BASE;

inline void vemu_start_read() 
{
	*(uint32_t*)(base_pointer + READ_CMD) = 1;
}

uint64_t vemu_read_reg(int reg)
{
	uint64_t lo, hi, val;
	lo = (uint64_t)*(uint32_t*)(base_pointer + reg);
	hi = (uint64_t)*(uint32_t*)(base_pointer + reg + 4);
	val = (hi << 32) | lo;
	return val;
}

void vemu_read_registers(vemu_regs * target) 
{
	vemu_state *t = (vemu_state*)target;
	*(uint32_t*)(base_pointer + READ_CMD) = 1;
	t->array32[0] = *(uint32_t*)(base_pointer + TOTAL_ACT_TIME);
	t->array32[1] = *(uint32_t*)(base_pointer + TOTAL_ACT_TIME + 4);
	t->array32[2] = *(uint32_t*)(base_pointer + TOTAL_ACT_EN);
	t->array32[3] = *(uint32_t*)(base_pointer + TOTAL_ACT_EN + 4);		
	t->array32[4] = *(uint32_t*)(base_pointer + SLP_TIME);
	t->array32[5] = *(uint32_t*)(base_pointer + SLP_TIME + 4);
	t->array32[6] = *(uint32_t*)(base_pointer + SLP_ENERGY);
	t->array32[7] = *(uint32_t*)(base_pointer + SLP_ENERGY + 4);				
}

void vemu_read_sensors(vemu_sensors * target) 
{
	target->ap = *(uint32_t*)(base_pointer + ACT_P);		
	target->sp = *(uint32_t*)(base_pointer + SLP_P);			
	target->t = *(uint32_t*)(base_pointer + TEMPERATURE);			
}

void vemu_delta(vemu_regs * target, vemu_regs * curr, vemu_regs * prev)
{
	int i;
	for (i = 0; i < 4; i++) 
	{
		((vemu_state*)target)->array64[i] = (((vemu_state*)curr)->array64[i] - ((vemu_state*)prev)->array64[i]);
	}
} 

inline uint64_t vemu_active_time()
{
	return vemu_read_reg(TOTAL_ACT_TIME);
}

inline uint64_t vemu_active_energy()
{
	return vemu_read_reg(TOTAL_ACT_EN);
}

inline uint64_t vemu_sleep_time()
{
	return vemu_read_reg(SLP_TIME);
}

inline uint64_t vemu_sleep_energy()
{
	return vemu_read_reg(SLP_ENERGY);
}



#endif /* _VARIABILITY_H_ */
