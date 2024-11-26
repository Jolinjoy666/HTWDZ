/***************************************************************************//**
 *   @file   adc_core.c
 *   @brief  Implementation of ADC Core Driver.
*******************************************************************************/

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include <stdlib.h>
#include <xil_cache.h>
#include <xil_io.h>
#include "adc_core.h"
#include "parameters.h"
#include "util.h"
#include "config.h"
#ifdef ADC_DMA_IRQ_EXAMPLE
#ifdef _XPARAMETERS_PS_H_
#include <xscugic.h>
#elif defined _MICROBLAZE_INTERFACE_H_
#include <xintc.h>
#endif
#endif

/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/
#ifdef ADC_DMA_IRQ_EXAMPLE
#ifdef _XPARAMETERS_PS_H_
#define ADC_DMA_INT_ID			89
#elif defined _MICROBLAZE_INTERFACE_H_
#define ADC_DMA_INT_ID			12
#endif
#define ADC_DMA_TRANSFER_SIZE	32768
#endif

/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/
struct adc_state adc_st;
#ifdef ADC_DMA_IRQ_EXAMPLE
uint8_t  dma_transfer_queued_flag		= 0;
uint8_t  dma_transfer_completed_flag	= 0;
uint32_t dma_start_address				= 0;
#endif

/***************************************************************************//**
 * @brief adc_read
*******************************************************************************/
void adc_read(struct b9361_rf_phy *phy, uint32_t regAddr, uint32_t *data)
{
	switch (phy->id_no)
	{
	case 0:
		*data = Xil_In32(B9361_RX_0_BASEADDR + regAddr);
		break;
	case 1:
		*data = Xil_In32(B9361_RX_1_BASEADDR + regAddr);
		break;
	default:
		break;
	}
}

/***************************************************************************//**
 * @brief adc_write
*******************************************************************************/
void adc_write(struct b9361_rf_phy *phy, uint32_t regAddr, uint32_t data)
{
	switch (phy->id_no)
	{
	case 0:
		Xil_Out32(B9361_RX_0_BASEADDR + regAddr, data);
		break;
	case 1:
		Xil_Out32(B9361_RX_1_BASEADDR + regAddr, data);
		break;
	default:
		break;
	}
}

/***************************************************************************//**
 * @brief adc_init
*******************************************************************************/
void adc_init(struct b9361_rf_phy *phy)
{
	adc_write(phy, ADC_REG_RSTN, 0);
	adc_write(phy, ADC_REG_RSTN, ADC_RSTN);

	adc_write(phy, ADC_REG_CHAN_CNTRL(0),
		ADC_IQCOR_ENB | ADC_FORMAT_SIGNEXT | ADC_FORMAT_ENABLE | ADC_ENABLE);
	adc_write(phy, ADC_REG_CHAN_CNTRL(1),
		ADC_IQCOR_ENB | ADC_FORMAT_SIGNEXT | ADC_FORMAT_ENABLE | ADC_ENABLE);
	adc_st.rx2tx2 = phy->pdata->rx2tx2;
	if(adc_st.rx2tx2)
	{
		adc_write(phy, ADC_REG_CHAN_CNTRL(2),
			ADC_IQCOR_ENB | ADC_FORMAT_SIGNEXT | ADC_FORMAT_ENABLE | ADC_ENABLE);
		adc_write(phy, ADC_REG_CHAN_CNTRL(3),
			ADC_IQCOR_ENB | ADC_FORMAT_SIGNEXT | ADC_FORMAT_ENABLE | ADC_ENABLE);
	}
	else
	{
		adc_write(phy, ADC_REG_CHAN_CNTRL(2), 0);
		adc_write(phy, ADC_REG_CHAN_CNTRL(3), 0);
	}
}


/***************************************************************************//**
 * @brief adc_capture
*******************************************************************************/
int32_t adc_capture(uint32_t size, uint32_t start_address)
{
	uint32_t reg_val;
	uint32_t transfer_id;
	uint32_t length;

	if(adc_st.rx2tx2)
	{
		length = (size * 8);
	}
	else
	{
		length = (size * 4);
	}

	return 0;
}

/***************************************************************************//**
 * @brief adc_set_calib_scale_phase
*******************************************************************************/
int32_t adc_set_calib_scale_phase(struct b9361_rf_phy *phy,
								  uint32_t phase,
								  uint32_t chan,
								  int32_t val,
								  int32_t val2)
{
	uint32_t fract;
	uint64_t llval;
	uint32_t tmp;

	switch (val) {
	case 1:
		fract = 0x4000;
		break;
	case -1:
		fract = 0xC000;
		break;
	case 0:
		fract = 0;
		if (val2 < 0) {
			fract = 0x8000;
			val2 *= -1;
		}
		break;
	default:
		return -1;
	}

	llval = (uint64_t)val2 * 0x4000UL + (1000000UL / 2);
	do_div(&llval, 1000000UL);
	fract |= llval;

	adc_read(phy, ADC_REG_CHAN_CNTRL_2(chan), &tmp);

	if (!((chan + phase) % 2)) {
		tmp &= ~ADC_IQCOR_COEFF_1(~0);
		tmp |= ADC_IQCOR_COEFF_1(fract);
	} else {
		tmp &= ~ADC_IQCOR_COEFF_2(~0);
		tmp |= ADC_IQCOR_COEFF_2(fract);
	}

	adc_write(phy, ADC_REG_CHAN_CNTRL_2(chan), tmp);

	return 0;
}

/***************************************************************************//**
 * @brief adc_get_calib_scale_phase
*******************************************************************************/
int32_t adc_get_calib_scale_phase(struct b9361_rf_phy *phy,
								  uint32_t phase,
								  uint32_t chan,
								  int32_t *val,
								  int32_t *val2)
{
	uint32_t tmp;
	int32_t sign;
	uint64_t llval;

	adc_read(phy, ADC_REG_CHAN_CNTRL_2(chan), &tmp);

	/* format is 1.1.14 (sign, integer and fractional bits) */

	if (!((phase + chan) % 2)) {
		tmp = ADC_TO_IQCOR_COEFF_1(tmp);
	} else {
		tmp = ADC_TO_IQCOR_COEFF_2(tmp);
	}

	if (tmp & 0x8000)
		sign = -1;
	else
		sign = 1;

	if (tmp & 0x4000)
		*val = 1 * sign;
	else
		*val = 0;

	tmp &= ~0xC000;

	llval = tmp * 1000000ULL + (0x4000 / 2);
	do_div(&llval, 0x4000);
	if (*val == 0)
		*val2 = llval * sign;
	else
		*val2 = llval;

	return 0;
}

/***************************************************************************//**
 * @brief adc_set_calib_scale
*******************************************************************************/
int32_t adc_set_calib_scale(struct b9361_rf_phy *phy,
							uint32_t chan,
							int32_t val,
							int32_t val2)
{
	return adc_set_calib_scale_phase(phy, 0, chan, val, val2);
}

/***************************************************************************//**
 * @brief adc_get_calib_scale
*******************************************************************************/
int32_t adc_get_calib_scale(struct b9361_rf_phy *phy,
							uint32_t chan,
							int32_t *val,
							int32_t *val2)
{
	return adc_get_calib_scale_phase(phy, 0, chan, val, val2);
}

/***************************************************************************//**
 * @brief adc_set_calib_phase
*******************************************************************************/
int32_t adc_set_calib_phase(struct b9361_rf_phy *phy,
							uint32_t chan,
							int32_t val,
							int32_t val2)
{
	return adc_set_calib_scale_phase(phy, 1, chan, val, val2);
}

/***************************************************************************//**
 * @brief adc_get_calib_phase
*******************************************************************************/
int32_t adc_get_calib_phase(struct b9361_rf_phy *phy,
							uint32_t chan,
							int32_t *val,
							int32_t *val2)
{
	return adc_get_calib_scale_phase(phy, 1, chan, val, val2);
}
