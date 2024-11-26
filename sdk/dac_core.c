/***************************************************************************//**
 *   @file   dac_core.c
 *   @brief  Implementation of DAC Core Driver.
*******************************************************************************/

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include <xil_cache.h>
#include <xil_io.h>
#include "dac_core.h"
#include "parameters.h"
#include "util.h"

/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/
//#define FMCOMMS5

/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/
struct dds_state dds_st[2];


/***************************************************************************//**
 * @brief dac_read
*******************************************************************************/
void dac_read(struct b9361_rf_phy *phy, uint32_t regAddr, uint32_t *data)
{
	switch (phy->id_no)
	{
	case 0:
		*data = Xil_In32(B9361_TX_0_BASEADDR + regAddr);
		break;
	case 1:
		*data = Xil_In32(B9361_TX_1_BASEADDR + regAddr);
		break;
	default:
		break;
	}
}

/***************************************************************************//**
 * @brief dac_write
*******************************************************************************/
void dac_write(struct b9361_rf_phy *phy, uint32_t regAddr, uint32_t data)
{
	switch (phy->id_no)
	{
	case 0:
		Xil_Out32(B9361_TX_0_BASEADDR + regAddr, data);
		break;
	case 1:
		Xil_Out32(B9361_TX_1_BASEADDR + regAddr, data);
		break;
	default:
		break;
	}
}

/***************************************************************************//**
 * @brief dds_default_setup
*******************************************************************************/
int32_t dds_default_setup(struct b9361_rf_phy *phy,
							 uint32_t chan, uint32_t phase,
							 uint32_t freq, int32_t scale)
{
	dds_set_phase(phy, chan, phase);
	dds_set_frequency(phy, chan, freq);
	dds_set_scale(phy, chan, scale);
	dds_st[phy->id_no].cached_freq[chan] = freq;
	dds_st[phy->id_no].cached_phase[chan] = phase;
	dds_st[phy->id_no].cached_scale[chan] = scale;

	return 0;
}

/***************************************************************************//**
 * @brief dac_stop
*******************************************************************************/
void dac_stop(struct b9361_rf_phy *phy)
{
	if (PCORE_VERSION_MAJOR(dds_st[phy->id_no].pcore_version) < 8)
	{
		dac_write(phy, DAC_REG_CNTRL_1, 0);
	}
}

/***************************************************************************//**
 * @brief dac_start_sync
*******************************************************************************/
void dac_start_sync(struct b9361_rf_phy *phy, bool force_on)
{
	if (PCORE_VERSION_MAJOR(dds_st[phy->id_no].pcore_version) < 8)
	{
		dac_write(phy, DAC_REG_CNTRL_1, (dds_st[phy->id_no].enable || force_on) ? DAC_ENABLE : 0);
	}
	else
	{
		dac_write(phy, DAC_REG_CNTRL_1, DAC_SYNC);
	}
}

/***************************************************************************//**
 * @brief dac_init
*******************************************************************************/
void dac_init(struct b9361_rf_phy *phy, uint8_t data_sel, uint8_t config_dma)
{
	uint32_t tx_count;
	uint32_t index;
	uint32_t index_i1;
	uint32_t index_q1;
	uint32_t index_i2;
	uint32_t index_q2;
	uint32_t index_mem;
	uint32_t data_i1;
	uint32_t data_q1;
	uint32_t data_i2;
	uint32_t data_q2;
	uint32_t length;
	uint32_t reg_ctrl_2;

	dac_write(phy, DAC_REG_RSTN, 0x0);
	dac_write(phy, DAC_REG_RSTN, DAC_RSTN | DAC_MMCM_RSTN);

	dds_st[phy->id_no].dac_clk = &phy->clks[TX_SAMPL_CLK]->rate;
	dds_st[phy->id_no].rx2tx2 = phy->pdata->rx2tx2;
	dac_read(phy, DAC_REG_CNTRL_2, &reg_ctrl_2);
	if(dds_st[phy->id_no].rx2tx2)
	{
		dds_st[phy->id_no].num_buf_channels = 4;
		if(phy->pdata->port_ctrl.pp_conf[2] & LVDS_MODE)
			dac_write(phy, DAC_REG_RATECNTRL, DAC_RATE(3));
		else
			dac_write(phy, DAC_REG_RATECNTRL, DAC_RATE(1));
		reg_ctrl_2 &= ~DAC_R1_MODE;
	}
	else
	{
		dds_st[phy->id_no].num_buf_channels = 2;
		if(phy->pdata->port_ctrl.pp_conf[2] & LVDS_MODE)
			dac_write(phy, DAC_REG_RATECNTRL, DAC_RATE(1));
		else
			dac_write(phy, DAC_REG_RATECNTRL, DAC_RATE(0));
		reg_ctrl_2 |= DAC_R1_MODE;
	}
	dac_write(phy, DAC_REG_CNTRL_2, reg_ctrl_2);

	dac_read(phy, DAC_REG_VERSION, &dds_st[phy->id_no].pcore_version);

	dac_stop(phy);
	switch (data_sel) {
	case DATA_SEL_DMA:
			if(config_dma)
			{
			}
			dac_datasel(phy, -1, DATA_SEL_DMA);
			break;
	case DATA_SEL_DDS:
		dds_default_setup(phy, DDS_CHAN_TX1_I_F1, 90000, 1000000, 250000);
		dds_default_setup(phy, DDS_CHAN_TX1_I_F2, 90000, 0000000, 000000);
		dds_default_setup(phy, DDS_CHAN_TX1_Q_F1, 0, 1000000, 250000);
		dds_default_setup(phy, DDS_CHAN_TX1_Q_F2, 0, 0000000, 00000);
		if(dds_st[phy->id_no].rx2tx2)
		{
			dds_default_setup(phy, DDS_CHAN_TX2_I_F1, 90000, 0000000, 1000000);
			dds_default_setup(phy, DDS_CHAN_TX2_I_F2, 90000, 0000000, 000000);
			dds_default_setup(phy, DDS_CHAN_TX2_Q_F1, 30000, 0000000, 1000000);
			dds_default_setup(phy, DDS_CHAN_TX2_Q_F2, 0, 0000000, 000000);
		}
		dac_datasel(phy, -1, DATA_SEL_DDS);
		break;
	default:
		break;
	}
	dds_st[phy->id_no].enable = true;
	dac_start_sync(phy, 0);
}

/***************************************************************************//**
 * @brief dds_set_frequency
*******************************************************************************/
void dds_set_frequency(struct b9361_rf_phy *phy, uint32_t chan, uint32_t freq)
{
	uint64_t val64;
	uint32_t reg;

	dds_st[phy->id_no].cached_freq[chan] = freq;
	dac_stop(phy);
	dac_read(phy, DAC_REG_CHAN_CNTRL_2_IIOCHAN(chan), &reg);
	reg &= ~DAC_DDS_INCR(~0);
	val64 = (uint64_t) freq * 0xFFFFULL;
	do_div(&val64, *dds_st[phy->id_no].dac_clk);
	reg |= DAC_DDS_INCR(val64) | 1;
	dac_write(phy, DAC_REG_CHAN_CNTRL_2_IIOCHAN(chan), reg);
	dac_start_sync(phy, 0);
}

/***************************************************************************//**
 * @brief dds_get_frequency
*******************************************************************************/
void dds_get_frequency(struct b9361_rf_phy *phy, uint32_t chan, uint32_t *freq)
{
	*freq = dds_st[phy->id_no].cached_freq[chan];
}

/***************************************************************************//**
 * @brief dds_set_phase
*******************************************************************************/
void dds_set_phase(struct b9361_rf_phy *phy, uint32_t chan, uint32_t phase)
{
	uint64_t val64;
	uint32_t reg;

	dds_st[phy->id_no].cached_phase[chan] = phase;
	dac_stop(phy);
	dac_read(phy, DAC_REG_CHAN_CNTRL_2_IIOCHAN(chan), &reg);
	reg &= ~DAC_DDS_INIT(~0);
	val64 = (uint64_t) phase * 0x10000ULL + (360000 / 2);
	do_div(&val64, 360000);
	reg |= DAC_DDS_INIT(val64);
	dac_write(phy, DAC_REG_CHAN_CNTRL_2_IIOCHAN(chan), reg);
	dac_start_sync(phy, 0);
}

/***************************************************************************//**
 * @brief dds_get_phase
*******************************************************************************/
void dds_get_phase(struct b9361_rf_phy *phy, uint32_t chan, uint32_t *phase)
{
	*phase = dds_st[phy->id_no].cached_phase[chan];
}

/***************************************************************************//**
 * @brief dds_set_phase
*******************************************************************************/
void dds_set_scale(struct b9361_rf_phy *phy, uint32_t chan, int32_t scale_micro_units)
{
	uint32_t scale_reg;
	uint32_t sign_part;
	uint32_t int_part;
	uint32_t fract_part;

	if (PCORE_VERSION_MAJOR(dds_st[phy->id_no].pcore_version) > 6)
	{
		if(scale_micro_units >= 1000000)
		{
			sign_part = 0;
			int_part = 1;
			fract_part = 0;
			dds_st[phy->id_no].cached_scale[chan] = 1000000;
			goto set_scale_reg;
		}
		if(scale_micro_units <= -1000000)
		{
			sign_part = 1;
			int_part = 1;
			fract_part = 0;
			dds_st[phy->id_no].cached_scale[chan] = -1000000;
			goto set_scale_reg;
		}
		dds_st[phy->id_no].cached_scale[chan] = scale_micro_units;
		if(scale_micro_units < 0)
		{
			sign_part = 1;
			int_part = 0;
			scale_micro_units *= -1;
		}
		else
		{
			sign_part = 0;
			int_part = 0;
		}
		fract_part = (uint32_t)(((uint64_t)scale_micro_units * 0x4000) / 1000000);
	set_scale_reg:
		scale_reg = (sign_part << 15) | (int_part << 14) | fract_part;
	}
	else
	{
		if(scale_micro_units >= 1000000)
		{
			scale_reg = 0;
			scale_micro_units = 1000000;
		}
		if(scale_micro_units <= 0)
		{
			scale_reg = 0;
			scale_micro_units = 0;
		}
		dds_st[phy->id_no].cached_scale[chan] = scale_micro_units;
		fract_part = (uint32_t)(scale_micro_units);
		if(fract_part != 0){
			scale_reg = 500000 / fract_part;
		}	
	}
	dac_stop(phy);
	dac_write(phy, DAC_REG_CHAN_CNTRL_1_IIOCHAN(chan), DAC_DDS_SCALE(scale_reg));
	dac_start_sync(phy, 0);
}

/***************************************************************************//**
 * @brief dds_get_phase
*******************************************************************************/
void dds_get_scale(struct b9361_rf_phy *phy, uint32_t chan, int32_t *scale_micro_units)
{
	*scale_micro_units = dds_st[phy->id_no].cached_scale[chan];
}

/***************************************************************************//**
 * @brief dds_update
*******************************************************************************/
void dds_update(struct b9361_rf_phy *phy)
{
	uint32_t chan;

	for(chan = DDS_CHAN_TX1_I_F1; chan <= DDS_CHAN_TX2_Q_F2; chan++)
	{
		dds_set_frequency(phy, chan, dds_st[phy->id_no].cached_freq[chan]);
		dds_set_phase(phy, chan, dds_st[phy->id_no].cached_phase[chan]);
		dds_set_scale(phy, chan, dds_st[phy->id_no].cached_scale[chan]);
	}
}

/***************************************************************************//**
 * @brief dac_datasel
*******************************************************************************/
int32_t dac_datasel(struct b9361_rf_phy *phy, int32_t chan, enum dds_data_select sel)
{
	int32_t i;

	if (PCORE_VERSION_MAJOR(dds_st[phy->id_no].pcore_version) > 7) {
		if (chan < 0) { /* ALL */
			for (i = 0; i < dds_st[phy->id_no].num_buf_channels; i++) {
				dac_write(phy, DAC_REG_CHAN_CNTRL_7(i), sel);
				dds_st[phy->id_no].cached_datasel[i] = sel;
			}
		} else {
			dac_write(phy, DAC_REG_CHAN_CNTRL_7(chan), sel);
			dds_st[phy->id_no].cached_datasel[chan] = sel;
		}
	} else {
		uint32_t reg;

		switch(sel) {
		case DATA_SEL_DDS:
		case DATA_SEL_SED:
		case DATA_SEL_DMA:
			dac_read(phy, DAC_REG_CNTRL_2, &reg);
			reg &= ~DAC_DATA_SEL(~0);
			reg |= DAC_DATA_SEL(sel);
			dac_write(phy, DAC_REG_CNTRL_2, reg);
			break;
		default:
			return -EINVAL;
		}
		for (i = 0; i < dds_st[phy->id_no].num_buf_channels; i++) {
			dds_st[phy->id_no].cached_datasel[i] = sel;
		}
	}

	return 0;
}

/***************************************************************************//**
 * @brief dac_get_datasel
*******************************************************************************/
void dac_get_datasel(struct b9361_rf_phy *phy, int32_t chan, enum dds_data_select *sel)
{
	*sel = dds_st[phy->id_no].cached_datasel[chan];
}

/***************************************************************************//**
 * @brief dds_to_signed_mag_fmt
*******************************************************************************/
uint32_t dds_to_signed_mag_fmt(int32_t val, int32_t val2)
{
	uint32_t i;
	uint64_t val64;

	/* format is 1.1.14 (sign, integer and fractional bits) */

	switch (val) {
	case 1:
		i = 0x4000;
		break;
	case -1:
		i = 0xC000;
		break;
	case 0:
		i = 0;
		if (val2 < 0) {
				i = 0x8000;
				val2 *= -1;
		}
		break;
	default:
		/* Invalid Value */
		i = 0;
	}

	val64 = (uint64_t)val2 * 0x4000UL + (1000000UL / 2);
	do_div(&val64, 1000000UL);

	return i | val64;
}

/***************************************************************************//**
 * @brief dds_from_signed_mag_fmt
*******************************************************************************/
void dds_from_signed_mag_fmt(uint32_t val,
							 int32_t *r_val,
							 int32_t *r_val2)
{
	uint64_t val64;
	int32_t sign;

	if (val & 0x8000)
		sign = -1;
	else
		sign = 1;

	if (val & 0x4000)
		*r_val = 1 * sign;
	else
		*r_val = 0;

	val &= ~0xC000;

	val64 = val * 1000000ULL + (0x4000 / 2);
	do_div(&val64, 0x4000);

	if (*r_val == 0)
		*r_val2 = val64 * sign;
	else
		*r_val2 = val64;
}

/***************************************************************************//**
 * @brief dds_set_calib_scale_phase
*******************************************************************************/
int32_t dds_set_calib_scale_phase(struct b9361_rf_phy *phy,
								  uint32_t phase,
								  uint32_t chan,
								  int32_t val,
								  int32_t val2)
{
	uint32_t reg;
	uint32_t i;

	if (PCORE_VERSION_MAJOR(dds_st[phy->id_no].pcore_version) < 8) {
		return -1;
	}

	i = dds_to_signed_mag_fmt(val, val2);

	dac_read(phy, DAC_REG_CHAN_CNTRL_8(chan), &reg);

	if (!((chan + phase) % 2)) {
		reg &= ~DAC_IQCOR_COEFF_1(~0);
		reg |= DAC_IQCOR_COEFF_1(i);
	} else {
		reg &= ~DAC_IQCOR_COEFF_2(~0);
		reg |= DAC_IQCOR_COEFF_2(i);
	}
	dac_write(phy, DAC_REG_CHAN_CNTRL_8(chan), reg);
	dac_write(phy, DAC_REG_CHAN_CNTRL_6(chan), DAC_IQCOR_ENB);

	return 0;
}

/***************************************************************************//**
 * @brief dds_get_calib_scale_phase
*******************************************************************************/
int32_t dds_get_calib_scale_phase(struct b9361_rf_phy *phy,
								  uint32_t phase,
								  uint32_t chan,
								  int32_t *val,
								  int32_t *val2)
{
	uint32_t reg;

	if (PCORE_VERSION_MAJOR(dds_st[phy->id_no].pcore_version) < 8) {
		return -1;
	}

	dac_read(phy, DAC_REG_CHAN_CNTRL_8(chan), &reg);

	/* format is 1.1.14 (sign, integer and fractional bits) */

	if (!((phase + chan) % 2)) {
		reg = DAC_TO_IQCOR_COEFF_1(reg);
	} else {
		reg = DAC_TO_IQCOR_COEFF_2(reg);
	}

	dds_from_signed_mag_fmt(reg, val, val2);

	return 0;
}

/***************************************************************************//**
 * @brief dds_set_calib_scale
*******************************************************************************/
int32_t dds_set_calib_scale(struct b9361_rf_phy *phy,
							uint32_t chan,
							int32_t val,
							int32_t val2)
{
	return dds_set_calib_scale_phase(phy, 0, chan, val, val2);
}

/***************************************************************************//**
 * @brief dds_get_calib_scale
*******************************************************************************/
int32_t dds_get_calib_scale(struct b9361_rf_phy *phy,
							uint32_t chan,
							int32_t *val,
							int32_t *val2)
{
	return dds_get_calib_scale_phase(phy, 0, chan, val, val2);
}

/***************************************************************************//**
 * @brief dds_set_calib_phase
*******************************************************************************/
int32_t dds_set_calib_phase(struct b9361_rf_phy *phy,
							uint32_t chan,
							int32_t val,
							int32_t val2)
{
	return dds_set_calib_scale_phase(phy, 1, chan, val, val2);
}

/***************************************************************************//**
 * @brief dds_get_calib_phase
*******************************************************************************/
int32_t dds_get_calib_phase(struct b9361_rf_phy *phy,
							uint32_t chan,
							int32_t *val,
							int32_t *val2)
{
	return dds_get_calib_scale_phase(phy, 1, chan, val, val2);
}
