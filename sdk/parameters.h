/***************************************************************************//**
 *   @file   parameters.h
 *   @brief  Parameters Definitions.
*******************************************************************************/
#ifndef __PARAMETERS_H__
#define __PARAMETERS_H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <xparameters.h>

/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/
#ifdef XPAR_AXI_B9361_0_BASEADDR
#define B9361_RX_0_BASEADDR		XPAR_AXI_B9361_0_BASEADDR
#define B9361_TX_0_BASEADDR		XPAR_AXI_B9361_0_BASEADDR + 0x4000
#else
#define B9361_RX_0_BASEADDR		XPAR_AXI_B9361_BASEADDR
#define B9361_TX_0_BASEADDR		XPAR_AXI_B9361_BASEADDR + 0x4000
#endif
#ifdef XPAR_AXI_B9361_1_BASEADDR
#define B9361_RX_1_BASEADDR		XPAR_AXI_B9361_1_BASEADDR
#define B9361_TX_1_BASEADDR		XPAR_AXI_B9361_1_BASEADDR + 0x4000
#else
#ifdef XPAR_AXI_B9361_0_BASEADDR
#define B9361_RX_1_BASEADDR		XPAR_AXI_B9361_0_BASEADDR
#define B9361_TX_1_BASEADDR		XPAR_AXI_B9361_0_BASEADDR + 0x4000
#else
#define B9361_RX_1_BASEADDR		XPAR_AXI_B9361_BASEADDR
#define B9361_TX_1_BASEADDR		XPAR_AXI_B9361_BASEADDR + 0x4000
#endif
#endif
#ifdef _XPARAMETERS_PS_H_
#define ADC_DDR_BASEADDR			XPAR_DDR_MEM_BASEADDR + 0x800000
#define DAC_DDR_BASEADDR			XPAR_DDR_MEM_BASEADDR + 0xA000000

#ifdef XPS_BOARD_ZCU102
#define GPIO_DEVICE_ID				XPAR_PSU_GPIO_0_DEVICE_ID
#define GPIO_RESET_PIN				124
#define GPIO_SYNC_PIN				123
#define GPIO_ENABLE_PIN				125
#define GPIO_TXNRX_PIN        		126
#define SPI_DEVICE_ID				XPAR_PSU_SPI_0_DEVICE_ID
#else
#define GPIO_DEVICE_ID				XPAR_PS7_GPIO_0_DEVICE_ID
#define GPIO_RESET_PIN				100
#define GPIO_SYNC_PIN				99
#define GPIO_ENABLE_PIN				101
#define GPIO_TXNRX_PIN        		102
#define SPI_DEVICE_ID				XPAR_PS7_SPI_0_DEVICE_ID
#endif
#define GPIO_RESET_PIN_ZC702		84
#define GPIO_RESET_PIN_ZC706		83
#define GPIO_RESET_PIN_ZED			100
#define GPIO_RESET_PIN_2			113
#define GPIO_CAL_SW1_PIN			107
#define GPIO_CAL_SW2_PIN			108
#define GPIO_CTL0_PIN				94
#define GPIO_CTL1_PIN				95
#define GPIO_CTL2_PIN				96
#define GPIO_CTL3_PIN				97

#else
#ifdef XPAR_DDR3_SDRAM_S_AXI_BASEADDR
#define ADC_DDR_BASEADDR			XPAR_DDR3_SDRAM_S_AXI_BASEADDR + 0x800000
#define DAC_DDR_BASEADDR			XPAR_DDR3_SDRAM_S_AXI_BASEADDR + 0xA000000
#else

#endif
#define GPIO_DEVICE_ID				0
#define GPIO_RESET_PIN				46
#ifdef XPAR_AXI_SPI_0_DEVICE_ID
#define SPI_DEVICE_ID				XPAR_AXI_SPI_0_DEVICE_ID
#else
#define SPI_DEVICE_ID				XPAR_SPI_0_DEVICE_ID
#endif
#endif

#endif // __PARAMETERS_H__
