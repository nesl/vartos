#/*
#    FreeRTOS V7.3.0 - Copyright (C) 2012 Real Time Engineers Ltd.
#	
#
#    ***************************************************************************
#     *                                                                       *
#     *    FreeRTOS tutorial books are available in pdf and paperback.        *
#     *    Complete, revised, and edited pdf reference manuals are also       *
#     *    available.                                                         *
#     *                                                                       *
#     *    Purchasing FreeRTOS documentation will not only help you, by       *
#     *    ensuring you get running as quickly as possible and with an        *
#     *    in-depth knowledge of how to use FreeRTOS, it will also help       *
#     *    the FreeRTOS project to continue with its mission of providing     *
#     *    professional grade, cross platform, de facto standard solutions    *
#     *    for microcontrollers - completely free of charge!                  *
#     *                                                                       *
#     *    >>> See http://www.FreeRTOS.org/Documentation for details. <<<     *
#     *                                                                       *
#     *    Thank you for using FreeRTOS, and thank you for your support!      *
#     *                                                                       *
#    ***************************************************************************
#
#
#    This file is part of the FreeRTOS distribution.
#
#    FreeRTOS is free software; you can redistribute it and/or modify it under
#    the terms of the GNU General Public License (version 2) as published by the
#    Free Software Foundation AND MODIFIED BY the FreeRTOS exception.
#    >>>NOTE<<< The modification to the GPL is included to allow you to
#    distribute a combined work that includes FreeRTOS without being obliged to
#    provide the source code for proprietary components outside of the FreeRTOS
#    kernel.  FreeRTOS is distributed in the hope that it will be useful, but
#    WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#    or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#    more details. You should have received a copy of the GNU General Public
#    License and the FreeRTOS license exception along with FreeRTOS; if not it
#    can be viewed here: http://www.freertos.org/a00114.html and also obtained
#    by writing to Richard Barry, contact details for whom are available on the
#    FreeRTOS WEB site.
#
#    1 tab == 4 spaces!
#
#    http://www.FreeRTOS.org - Documentation, latest information, license and
#    contact details.
#
#    http://www.SafeRTOS.com - A version that is certified for use in safety
#    critical systems.
#
#    http://www.OpenRTOS.com - Commercial support, development, porting,
#    licensing and training services.
#*/


#/************************************************************************* 
# * Please ensure to read http://www.freertos.org/portLM3Sxxxx_Eclipse.html
# * which provides information on configuring and running this demo for the
# * various Luminary Micro EKs.
# *************************************************************************/

RTOS_SOURCE_DIR=../../SourceVar
DEMO_COMMON_DIR=../Common/Minimal
DEMO_INCLUDE_DIR=../Common/include
#HW_INCLUDE_DIR=../../../lm3s6965/inc
#LIB_DIR=${HW_INCLUDE_DIR}/../driverlib
UTIL_DIR=../../../util
VEMU_DIR=../../../vemu
LUMINARY_DRIVER_DIR=../Common/drivers/LuminaryMicro


CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy
LDSCRIPT=standalone.ld

# should use --gc-sections but the debugger does not seem to be able to cope with the option.
LINKER_FLAGS=-nostartfiles -Xlinker -oRTOSDemo.axf -Xlinker -M -Xlinker -Map=rtosdemo.map -Xlinker --gc-sections -lm

DEBUG=
#DEBUG=-g
OPTIM=-Os

CFLAGS=$(DEBUG) -I . -I $(RTOS_SOURCE_DIR)/include -I $(RTOS_SOURCE_DIR)/portable/GCC/ARM_CM3 \
		-I $(DEMO_INCLUDE_DIR) -I $(LUMINARY_DRIVER_DIR) -I $(UTIL_DIR) -I $(VEMU_DIR) \
		-D GCC_ARMCM3_LM3S102 -D inline= -mthumb -mcpu=cortex-m3 $(OPTIM) -T$(LDSCRIPT) \
		-D PACK_STRUCT_END=__attribute\(\(packed\)\) -D ALIGN_STRUCT_END=__attribute\(\(aligned\(4\)\)\)  \
		-ffunction-sections -fdata-sections
	    #-DUSE_VARTOS	

#-D sprintf=usprintf -D snprintf=usnprintf -D printf=uipprintf

SOURCE=	main.c \
		$(UTIL_DIR)/uart_put.c \
		$(VEMU_DIR)/vemu.c \
		$(RTOS_SOURCE_DIR)/list.c \
		$(RTOS_SOURCE_DIR)/tasks.c \
		$(RTOS_SOURCE_DIR)/portable/GCC/ARM_CM3/port.c \
		$(RTOS_SOURCE_DIR)/portable/MemMang/heap_1.c		

#		$(DEMO_COMMON_DIR)/BlockQ.c \
#		$(DEMO_COMMON_DIR)/death.c \
#		$(DEMO_COMMON_DIR)/PollQ.c \
#		$(DEMO_COMMON_DIR)/QPeek.c \
#		$(DEMO_COMMON_DIR)/semtest.c \
#		$(LUMINARY_DRIVER_DIR)/ustdlib.c \
#		$(DEMO_COMMON_DIR)/integer.c \
#		$(RTOS_SOURCE_DIR)/queue.c \


LIBS= ../../../lm3s6965/driverlib/gcc-cm3/libdriver-cm3.a 

#$(LUMINARY_DRIVER_DIR)/arm-none-eabi-gcc/libdriver.a 

#$(LUMINARY_DRIVER_DIR)/arm-none-eabi-gcc/libgr.a


OBJS = $(SOURCE:.c=.o)

all: RTOSDemo.bin
	 
RTOSDemo.bin : RTOSDemo.axf
	$(OBJCOPY) RTOSDemo.axf -O binary RTOSDemo.bin

RTOSDemo.axf : $(OBJS) startup.o Makefile
	$(CC) $(CFLAGS) $(OBJS) startup.o $(LIBS) $(LINKER_FLAGS)

$(OBJS) : %.o : %.c Makefile FreeRTOSConfig.h
	$(CC) -c $(CFLAGS) $< -o $@

startup.o : startup.c Makefile
	$(CC) -c $(CFLAGS) -O1 startup.c -o startup.o
		
clean :
	rm $(OBJS)
	
prog :
	openocd -f lm3s6965-program.cfg

debug :
	openocd -f lm3s6965-debug.cfg


