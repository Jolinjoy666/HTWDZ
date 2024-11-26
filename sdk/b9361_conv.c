/***************************************************************************//**
 *   @file   b9361_conv.c
 *   @brief  Implementation of B9361 Conv Driver.
*******************************************************************************/

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <inttypes.h>
#include <string.h>

#include "b9361.h"
#include "platform.h"
#include "config.h"

#ifndef AXI_ADC_NOT_PRESENT

/**
 * Get the number of PHY channels.
 * @return The number of PHY channels.
 */
static uint32_t b9361_num_phy_chan(struct axiadc_converter *conv)
{
	if (conv->chip_info->num_channels > 4)
		return 4;
	return conv->chip_info->num_channels;
}

/**
 * Check PN checker status.
 * @return 0 in case of success, negative error code otherwise.
 */
static int32_t b9361_check_pn(struct b9361_rf_phy *phy, bool tx,
			   unsigned int delay)
{
	struct axiadc_converter *conv = phy->adc_conv;
	struct axiadc_state *st = phy->adc_state;
	unsigned int num_chan = b9361_num_phy_chan(conv);
	unsigned int chan;

	for (chan = 0; chan < num_chan; chan++)
		axiadc_write(st, BMTI_REG_CHAN_STATUS(chan),
			     BMTI_PN_ERR | BMTI_PN_OOS);
	mdelay(delay);

	if (!tx && !(axiadc_read(st, BMTI_REG_STATUS) & BMTI_STATUS))
		return 1;

	for (chan = 0; chan < num_chan; chan++) {
		if (axiadc_read(st, BMTI_REG_CHAN_STATUS(chan)))
			return 1;
	}

	return 0;
}

/**
 * HDL loopback enable/disable.
 * @param phy The B9361 state structure.
 * @param enable Enable/disable option.
 * @return 0 in case of success, negative error code otherwise.
 */
int32_t b9361_hdl_loopback(struct b9361_rf_phy *phy, bool enable)
{
	struct axiadc_converter *conv = phy->adc_conv;
	struct axiadc_state *st = phy->adc_state;
	int32_t reg, addr, chan;

	uint32_t version = axiadc_read(st, 0x4000);

	/* Still there but implemented a bit different */
	if (PCORE_VERSION_MAJOR(version) > 7)
		addr = 0x4418;
	else
		addr = 0x4414;

	for (chan = 0; chan < conv->chip_info->num_channels; chan++) {
		reg = axiadc_read(st, addr + (chan) * 0x40);

		if (PCORE_VERSION_MAJOR(version) > 7) {
			if (enable && reg != 0x8) {
				conv->scratch_reg[chan] = reg;
				reg = 0x8;
			} else if (reg == 0x8) {
				reg = conv->scratch_reg[chan];
			}
		} else {
		/* DAC_LB_ENB If set enables loopback of receive data */
			if (enable)
				reg |= BIT(1);
			else
				reg &= ~BIT(1);
		}
		axiadc_write(st, addr + (chan) * 0x40, reg);
	}

	return 0;
}

/**
 * Set IO delay.
 * @param st The AXI ADC state structure.
 * @param lane Lane number.
 * @param val Value.
 * @param tx The Synthesizer TX = 1, RX = 0.
 * @return 0 in case of success, negative error code otherwise.
 */
static int32_t b9361_iodelay_set(struct axiadc_state *st, unsigned lane,
			      unsigned val, bool tx)
{
	if (tx) {
		if (PCORE_VERSION_MAJOR(st->pcore_version) > 8)
			axiadc_write(st, 0x4000 + BMTI_REG_DELAY(lane), val);
		else
			return -ENODEV;
	} else {
		axiadc_idelay_set(st, lane, val);
	}

	return 0;
}

/**
 * Set midscale IO delay.
 * @param phy The B9361 state structure.
 * @param tx The Synthesizer TX = 1, RX = 0.
 * @return 0 in case of success, negative error code otherwise.
 */
static int32_t b9361_midscale_iodelay(struct b9361_rf_phy *phy, bool tx)
{
	struct axiadc_state *st = phy->adc_state;
	int32_t ret = 0, i;

	for (i = 0; i < 7; i++)
		ret |= b9361_iodelay_set(st, i, 15, tx);

	return 0;
}

/**
 * Digital tune IO delay.
 * @param phy The B9361 state structure.
 * @param tx The Synthesizer TX = 1, RX = 0.
 * @return 0 in case of success, negative error code otherwise.
 */
static int32_t b9361_dig_tune_iodelay(struct b9361_rf_phy *phy, bool tx)
{
	struct axiadc_state *st = phy->adc_state;
	int32_t i, j;
	uint32_t s0, c0;
	uint8_t field[32];

	for (i = 0; i < 7; i++) {
		for (j = 0; j < 32; j++) {
			b9361_iodelay_set(st, i, j, tx);
			mdelay(1);
			field[j] = b9361_check_pn(phy, tx, 10);
		}

		c0 = b9361_find_opt(&field[0], 32, &s0);
		b9361_iodelay_set(st, i, s0 + c0 / 2, tx);

		dev_dbg(&phy->spi->dev,
			 "%s Lane %"PRId32", window cnt %"PRIu32" , start %"PRIu32", IODELAY set to %"PRIu32"\n",
			 tx ? "TX" :"RX",  i , c0, s0, s0 + c0 / 2);
	}

	return 0;
}

/**
 * Digital tune verbose print.
 * @param phy The B9361 state structure.
 * @param field Field.
 * @param tx The Synthesizer TX = 1, RX = 0.
 * @return 0 in case of success, negative error code otherwise.
 */
static void b9361_dig_tune_verbose_print(struct b9361_rf_phy *phy,
					  uint8_t field[][16], bool tx,
					  int32_t sel_clk, int32_t sel_data)
{
	int32_t i, j;
	char c;

	printk("SAMPL CLK: %"PRIu32" tuning: %s\n",
			clk_get_rate(phy, phy->ref_clk_scale[RX_SAMPL_CLK]), tx ? "TX" : "RX");
	printk("  ");
	for (i = 0; i < 16; i++)
		printk("%"PRIx32":", i);
	printk("\n");

	for (i = 0; i < 2; i++) {
		printk("%"PRIx32":", i);
		for (j = 0; j < 16; j++) {
			if (field[i][j])
			    c = '#';
			else if ((i == 0 && j == sel_data) ||
				 (i == 1 && j == sel_clk))
			    c = 'O';
			else
			    c = 'o';
			printk("%c ", c);
		}
		printk("\n");
	}
}

/**
 * Set intf delay.
 * @param phy The B9361 state structure.
 * @return None.
 */
static void b9361_set_intf_delay(struct b9361_rf_phy *phy, bool tx,
				  unsigned int clock_delay,
				  unsigned int data_delay, bool clock_changed)
{
	if (clock_changed)
		b9361_ensm_force_state(phy, ENSM_STATE_ALERT);
	b9361_spi_write(phy->spi,
			REG_RX_CLOCK_DATA_DELAY + (tx ? 1 : 0),
			RX_DATA_DELAY(data_delay) |
			DATA_CLK_DELAY(clock_delay));
	if (clock_changed)
		b9361_ensm_force_state(phy, ENSM_STATE_FDD);
}

/**
 * Digital interface timing analysis.
 * @param phy The B9361 state structure.
 * @param buf The buffer.
 * @param buflen The buffer length.
 * @return The size in case of success, negative error code otherwise.
 */
int32_t b9361_dig_interface_timing_analysis(struct b9361_rf_phy *phy,
	char *buf, int32_t buflen)
{
	uint32_t loopback, bist, ensm_state;
	int32_t i, j, len = 0;
	uint8_t field[16][16];
	uint8_t rx;

	dev_dbg(&phy->spi->dev, "%s:\n", __func__);

	loopback = phy->bist_loopback_mode;
	bist = phy->bist_config;
	ensm_state = b9361_ensm_get_state(phy);
	rx = b9361_spi_read(phy->spi, REG_RX_CLOCK_DATA_DELAY);

	/* Mute TX, we don't want to transmit the PRBS */
	b9361_tx_mute(phy, 1);

	if (!phy->pdata->fdd)
		b9361_set_ensm_mode(phy, true, false);

	b9361_bist_loopback(phy, 0);
	b9361_bist_prbs(phy, BIST_INJ_RX);

	for (i = 0; i < 16; i++) {
		for (j = 0; j < 16; j++) {
			b9361_set_intf_delay(phy, false, i, j, j == 0);
			field[j][i] = b9361_check_pn(phy, false, 1);
		}
	}

	b9361_ensm_force_state(phy, ENSM_STATE_ALERT);
	b9361_spi_write(phy->spi, REG_RX_CLOCK_DATA_DELAY, rx);
	b9361_bist_loopback(phy, loopback);
	b9361_spi_write(phy->spi, REG_BIST_CONFIG, bist);

	if (!phy->pdata->fdd)
		b9361_set_ensm_mode(phy, phy->pdata->fdd, phy->pdata->ensm_pin_ctrl);
	b9361_ensm_restore_state(phy, ensm_state);

	b9361_tx_mute(phy, 0);

	len += snprintf(buf + len, buflen, "CLK: %"PRIu32" Hz 'o' = PASS\n",
		clk_get_rate(phy, phy->ref_clk_scale[RX_SAMPL_CLK]));
	len += snprintf(buf + len, buflen, "DC");
	for (i = 0; i < 16; i++)
		len += snprintf(buf + len, buflen, "%"PRIx32":", i);
	len += snprintf(buf + len, buflen, "\n");

	for (i = 0; i < 16; i++) {
		len += snprintf(buf + len, buflen, "%"PRIx32":", i);
		for (j = 0; j < 16; j++) {
			len += snprintf(buf + len, buflen, "%c ",
				(field[i][j] ? '.' : 'o'));
		}
		len += snprintf(buf + len, buflen, "\n");
	}
	len += snprintf(buf + len, buflen, "\n");

	return len;
}

/**
 * Digital tune delay.
 * @param phy The B9361 state structure.
 * @param max_freq Maximum frequency.
 * @param flags Flags: BE_VERBOSE, BE_MOREVERBOSE, DO_IDELAY, DO_ODELAY.
 * @param tx Set if TX.
 * @return 0 in case of success, negative error code otherwise.
 */
static int32_t b9361_dig_tune_delay(struct b9361_rf_phy *phy,
		uint32_t max_freq, enum dig_tune_flags flags, bool tx)
{
	static const uint32_t rates[3] = {25000000U, 40000000U, 61440000U};
	uint32_t s0, s1, c0, c1;
	uint32_t i, j, r;
	bool half_data_rate;
	uint8_t field[2][16];

	if (((phy->pdata->port_ctrl.pp_conf[2] & LVDS_MODE) ||
	    !phy->pdata->rx2tx2))
	    half_data_rate = false;
	else
	    half_data_rate = true;

	memset(field, 0, 32);
	for (r = 0; r < (max_freq ? ARRAY_SIZE(rates) : 1); r++) {
		if (max_freq)
			b9361_set_trx_clock_chain_freq(phy,
				half_data_rate ? rates[r] / 2 : rates[r]);

		for (i = 0; i < 2; i++) {
			for (j = 0; j < 16; j++) {
				/*
				 * i == 0: clock delay = 0, data delay from 0 to 15
				 * i == 1: clock delay = 15, data delay from 15 to 0
				 */
				b9361_set_intf_delay(phy, tx, i ? 15 : 0,
						      i ? 15 - j : j, j == 0);
				field[i][j] |= b9361_check_pn(phy, tx, 4);
			}
		}

		if ((flags & BE_MOREVERBOSE) && max_freq) {
			b9361_dig_tune_verbose_print(phy, field, tx, -1, -1);
		}
	}

	c0 = b9361_find_opt(&field[0][0], 16, &s0);
	c1 = b9361_find_opt(&field[1][0], 16, &s1);

	if (!c0 && !c1) {
		b9361_dig_tune_verbose_print(phy, field, tx, -1, -1);
		dev_err(&phy->spi->dev, "%s: Tuning %s FAILED!", __func__,
			tx ? "TX" : "RX");
		return -EIO;
	} else if (flags & BE_VERBOSE) {
		if (c1 > c0)
			b9361_dig_tune_verbose_print(phy, field, tx, (s1 + c1 / 2), -1);
		else
			b9361_dig_tune_verbose_print(phy, field, tx, -1, (s0 + c0 / 2));
	}

	if (c1 > c0)
		b9361_set_intf_delay(phy, tx, s1 + c1 / 2, 0, true);
	else
		b9361_set_intf_delay(phy, tx, 0, s0 + c0 / 2, true);

	return 0;
}

/**
 * Digital tune RX.
 * @param phy The B9361 state structure.
 * @param max_freq Maximum frequency.
 * @param flags Flags: BE_VERBOSE, BE_MOREVERBOSE, DO_IDELAY, DO_ODELAY.
 * @return 0 in case of success, negative error code otherwise.
 */
static int32_t b9361_dig_tune_rx(struct b9361_rf_phy *phy, uint32_t max_freq,
			      enum dig_tune_flags flags)
{
	struct axiadc_state *st = phy->adc_state;
	int ret;

	b9361_bist_loopback(phy, 0);
	b9361_bist_prbs(phy, BIST_INJ_RX);

	ret = b9361_dig_tune_delay(phy, max_freq, flags, false);
	if (flags & DO_IDELAY)
		b9361_dig_tune_iodelay(phy, false);

	axiadc_write(st, BMTI_REG_RSTN, BMTI_MMCM_RSTN);
	axiadc_write(st, BMTI_REG_RSTN, BMTI_RSTN | BMTI_MMCM_RSTN);

	return ret;
}

/**
 * Digital tune TX.
 * @param phy The B9361 state structure.
 * @param max_freq Maximum frequency.
 * @param flags Flags: BE_VERBOSE, BE_MOREVERBOSE, DO_IDELAY, DO_ODELAY.
 * @return 0 in case of success, negative error code otherwise.
 */
static int32_t b9361_dig_tune_tx(struct b9361_rf_phy *phy, uint32_t max_freq,
			      enum dig_tune_flags flags)
{
	struct axiadc_converter *conv = phy->adc_conv;
	struct axiadc_state *st = phy->adc_state;
	uint32_t saved_dsel[4], saved_chan_ctrl6[4], saved_chan_ctrl0[4];
	unsigned int chan, num_chan;
	unsigned int hdl_dac_version;
	uint32_t tmp, saved = 0;
	int ret;

	num_chan = b9361_num_phy_chan(conv);
	hdl_dac_version = axiadc_read(st, 0x4000);

	b9361_bist_prbs(phy, BIST_DISABLE);
	b9361_bist_loopback(phy, 1);
	axiadc_write(st, 0x4000 + BMTI_REG_RSTN, BMTI_RSTN | BMTI_MMCM_RSTN);

	for (chan = 0; chan < num_chan; chan++) {
		saved_chan_ctrl0[chan] = axiadc_read(st, BMTI_REG_CHAN_CNTRL(chan));
		axiadc_write(st, BMTI_REG_CHAN_CNTRL(chan),
			BMTI_FORMAT_SIGNEXT | BMTI_FORMAT_ENABLE |
			BMTI_ENABLE | BMTI_IQCOR_ENB);
		axiadc_set_pnsel(st, chan, ADC_PN_CUSTOM);
		saved_chan_ctrl6[chan] = axiadc_read(st, 0x4414 + (chan) * 0x40);
		if (PCORE_VERSION_MAJOR(hdl_dac_version) > 7) {
			saved_dsel[chan] = axiadc_read(st, 0x4418 + (chan) * 0x40);
			axiadc_write(st, 0x4418 + (chan) * 0x40, 9);
			axiadc_write(st, 0x4414 + (chan) * 0x40, 0); /* !IQCOR_ENB */
			axiadc_write(st, 0x4044, 1);
		} else {
			axiadc_write(st, 0x4414 + (chan) * 0x40, 1); /* DAC_PN_ENB */
		}
	}
	if (PCORE_VERSION_MAJOR(hdl_dac_version) < 8) {
		saved = tmp = axiadc_read(st, 0x4048);
		tmp &= ~0xF;
		tmp |= 1;
		axiadc_write(st, 0x4048, tmp);
	}

	ret = b9361_dig_tune_delay(phy, max_freq, flags, true);
	if (flags & DO_ODELAY)
		b9361_dig_tune_iodelay(phy, true);

	if (PCORE_VERSION_MAJOR(hdl_dac_version) < 8)
		axiadc_write(st, 0x4048, saved);

	for (chan = 0; chan < num_chan; chan++) {
		axiadc_write(st, BMTI_REG_CHAN_CNTRL(chan),
			     saved_chan_ctrl0[chan]);
		axiadc_set_pnsel(st, chan, ADC_PN9);
		if (PCORE_VERSION_MAJOR(hdl_dac_version) > 7) {
			axiadc_write(st, 0x4418 + chan * 0x40,
				     saved_dsel[chan]);
			axiadc_write(st, 0x4044, 1);
		}

		axiadc_write(st, 0x4414 + chan * 0x40, saved_chan_ctrl6[chan]);
	}

	return ret;
}

/**
 * Digital tune.
 * @param phy The B9361 state structure.
 * @param max_freq Maximum frequency.
 * @param flags Flags: BE_VERBOSE, BE_MOREVERBOSE, DO_IDELAY, DO_ODELAY.
 * @return 0 in case of success, negative error code otherwise.
 */
int32_t b9361_dig_tune(struct b9361_rf_phy *phy, uint32_t max_freq,
		    enum dig_tune_flags flags)
{
	struct axiadc_converter *conv = phy->adc_conv;
	struct axiadc_state *st = phy->adc_state;
	uint32_t loopback, bist, ensm_state;
	bool restore = false;
	int32_t ret = 0;

	if (!conv)
		return -ENODEV;

	dev_dbg(&phy->spi->dev, "%s: freq %lu flags 0x%X\n", __func__,
		max_freq, flags);

	ensm_state = b9361_ensm_get_state(phy);

	if (phy->pdata->dig_interface_tune_skipmode == 2 ||
	    (flags & RESTORE_DEFAULT)) {
		/* skip completely and use defaults */
		restore = true;
	} else {
		loopback = phy->bist_loopback_mode;
		bist = phy->bist_config;

		/* Mute TX, we don't want to transmit the PRBS */
		b9361_tx_mute(phy, 1);

		if (!phy->pdata->fdd)
			b9361_set_ensm_mode(phy, true, false);

		if (flags & DO_IDELAY)
			b9361_midscale_iodelay(phy, false);

		if (flags & DO_ODELAY)
			b9361_midscale_iodelay(phy, true);

		ret = b9361_dig_tune_rx(phy, max_freq, flags);
		if (ret == 0 && !phy->pdata->dig_interface_tune_skipmode)
			ret = b9361_dig_tune_tx(phy, max_freq, flags);

		b9361_bist_loopback(phy, loopback);
		b9361_spi_write(phy->spi, REG_BIST_CONFIG, bist);

		if (ret == -EIO)
			restore = true;
		if (!max_freq)
			ret = 0;
	}

	if (restore) {
		b9361_ensm_force_state(phy, ENSM_STATE_ALERT);
		b9361_spi_write(phy->spi, REG_RX_CLOCK_DATA_DELAY,
				phy->pdata->port_ctrl.rx_clk_data_delay);
		b9361_spi_write(phy->spi, REG_TX_CLOCK_DATA_DELAY,
				phy->pdata->port_ctrl.tx_clk_data_delay);
	} else if (!(flags & SKIP_STORE_RESULT)) {
		phy->pdata->port_ctrl.rx_clk_data_delay =
			b9361_spi_read(phy->spi, REG_RX_CLOCK_DATA_DELAY);
		phy->pdata->port_ctrl.tx_clk_data_delay =
			b9361_spi_read(phy->spi, REG_TX_CLOCK_DATA_DELAY);
	}

	if (!phy->pdata->fdd)
		b9361_set_ensm_mode(phy, phy->pdata->fdd, phy->pdata->ensm_pin_ctrl);
	b9361_ensm_restore_state(phy, ensm_state);

	axiadc_write(st, BMTI_REG_RSTN, BMTI_MMCM_RSTN);
	axiadc_write(st, BMTI_REG_RSTN, BMTI_RSTN | BMTI_MMCM_RSTN);

	b9361_tx_mute(phy, 0);

	return ret;
}

/**
* Setup the B9361 device.
* @param phy The B9361 state structure.
* @return 0 in case of success, negative error code otherwise.
*/
int32_t b9361_post_setup(struct b9361_rf_phy *phy)
{
	struct axiadc_converter *conv = phy->adc_conv;
	struct axiadc_state *st = phy->adc_state;
	int32_t rx2tx2 = phy->pdata->rx2tx2;
	int32_t tmp, num_chan, flags;
	int32_t i, ret;

	num_chan = b9361_num_phy_chan(conv);

	axiadc_write(st, BMTI_REG_CNTRL, rx2tx2 ? 0 : BMTI_R1_MODE);
	tmp = axiadc_read(st, 0x4048);

	if (!rx2tx2) {
		axiadc_write(st, 0x4048, tmp | BIT(5)); /* R1_MODE */
		axiadc_write(st, 0x404c,
			     (phy->pdata->port_ctrl.pp_conf[2] & LVDS_MODE) ? 1 : 0); /* RATE */
	}
	else {
		tmp &= ~BIT(5);
		axiadc_write(st, 0x4048, tmp);
		axiadc_write(st, 0x404c,
			     (phy->pdata->port_ctrl.pp_conf[2] & LVDS_MODE) ? 3 : 1); /* RATE */
	}

#ifdef ALTERA_PLATFORM
	axiadc_write(st, 0x404c, 1);
#endif

	for (i = 0; i < num_chan; i++) {
		axiadc_write(st, BMTI_REG_CHAN_CNTRL_1(i),
			BMTI_DCFILT_OFFSET(0));
		axiadc_write(st, BMTI_REG_CHAN_CNTRL_2(i),
			(i & 1) ? 0x00004000 : 0x40000000);
		axiadc_write(st, BMTI_REG_CHAN_CNTRL(i),
			BMTI_FORMAT_SIGNEXT | BMTI_FORMAT_ENABLE |
			BMTI_ENABLE | BMTI_IQCOR_ENB);
	}

	flags = 0x0;

	ret = b9361_dig_tune(phy, (axiadc_read(st, BMTI_REG_ID)) ?
		0 : 61440000, flags);
	if (ret < 0)
		return ret;

	if (flags & (DO_IDELAY | DO_ODELAY)) {
		ret = b9361_dig_tune(phy, (axiadc_read(st, BMTI_REG_ID)) ?
			0 : 61440000, flags & BE_VERBOSE);
		if (ret < 0)
			return ret;
	}

	ret = b9361_set_trx_clock_chain(phy,
					 phy->pdata->rx_path_clks,
					 phy->pdata->tx_path_clks);

	b9361_ensm_force_state(phy, ENSM_STATE_ALERT);
	b9361_ensm_restore_prev_state(phy);

	return ret;
}
#else
/**
 * HDL loopback enable/disable.
 * @param phy The B9361 state structure.
 * @param enable Enable/disable option.
 * @return 0 in case of success, negative error code otherwise.
 */
int32_t b9361_hdl_loopback(struct b9361_rf_phy *phy, bool enable)
{
	return -ENODEV;
}

/**
 * Digital tune.
 * @param phy The B9361 state structure.
 * @param max_freq Maximum frequency.
 * @param flags Flags: BE_VERBOSE, BE_MOREVERBOSE, DO_IDELAY, DO_ODELAY.
 * @return 0 in case of success, negative error code otherwise.
 */
int32_t b9361_dig_tune(struct b9361_rf_phy *phy, uint32_t max_freq,
						enum dig_tune_flags flags)
{
	return 0;
}

/**
* Setup the B9361 device.
* @param phy The B9361 state structure.
* @return 0 in case of success, negative error code otherwise.
*/
int32_t b9361_post_setup(struct b9361_rf_phy *phy)
{
	return 0;
}
#endif
