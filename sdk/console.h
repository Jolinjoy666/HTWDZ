/***************************************************************************//**
 *   @file   console.h
 *   @brief  Header file of Console Driver.
*******************************************************************************/
#ifndef __CONSOLE_H__
#define __CONSOLE_H__

/******************************************************************************/
/******************** Macros and Constants Definitions ************************/
/******************************************************************************/
#define UNKNOWN_CMD	-1
#define DO_CMD	   	0
#define READ_CMD	1
#define WRITE_CMD	2

/******************************************************************************/
/************************ Functions Declarations ******************************/
/******************************************************************************/
/* Initializes the serial console. */
char console_init(unsigned long baud_rate);

/* Prints formatted data to console. */
void console_print(char* str, ...);

/* Reads one command from console. */
void console_get_command(char* command);

/* Compares two commands and returns the type of the command. */
int console_check_commands(char*	   received_cmd,
						   const char* expected_cmd,
						   double*	   param,
						   char*	   param_no);

#endif /*__CONSOLE_H__*/
