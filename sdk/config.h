/***************************************************************************//**
 *   @file   config.h
 *   @brief  Config file of B9361/API Driver.
*******************************************************************************/
#ifndef CONFIG_H_
#define CONFIG_H_

#define HAVE_VERBOSE_MESSAGES /* Recommended during development prints errors and warnings */
//#define HAVE_DEBUG_MESSAGES /* For Debug purposes only */

/*
 * In case memory footprint is a concern these options allow
 * to disable unused functionality which may free up a few kb
 */

#define HAVE_SPLIT_GAIN_TABLE	1 /* only set to 0 in case split_gain_table_mode_enable = 0*/
#define HAVE_TDD_SYNTH_TABLE	1 /* only set to 0 in case split_gain_table_mode_enable = 0*/

#define B9361_DEVICE			1 /* set it 1 if B9361 device is used, 0 otherwise */
#define B9364_DEVICE			0 /* set it 1 if B9364 device is used, 0 otherwise */
#define B9363A_DEVICE			0 /* set it 1 if B9363A device is used, 0 otherwise */

//#define CONSOLE_COMMANDS
#define XILINX_PLATFORM
//#define ALTERA_PLATFORM
//#define FMCOMMS5
//#define BMTI_RF_SOM
//#define BMTI_RF_SOM_CMOS
//#define ADC_DMA_EXAMPLE
//#define ADC_DMA_IRQ_EXAMPLE
//#define DAC_DMA_EXAMPLE
#define AXI_ADC_NOT_PRESENT
//#define TDD_SWITCH_STATE_EXAMPLE

#endif
