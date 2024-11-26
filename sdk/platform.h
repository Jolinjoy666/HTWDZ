/***************************************************************************//**
 *   @file   platform.h
 *   @brief  Header file of Platform driver.
*******************************************************************************/
#ifndef PLATFORM_H_
#define PLATFORM_H_

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "util.h"

/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/
#define BMTI_REG_VERSION			0x0000

#define BMTI_REG_ID				0x0004

#define BMTI_REG_RSTN			0x0040
#define BMTI_RSTN				(1 << 0)
#define BMTI_MMCM_RSTN			(1 << 1)

#define BMTI_REG_CNTRL			0x0044
#define BMTI_R1_MODE				(1 << 2)
#define BMTI_DDR_EDGESEL			(1 << 1)
#define BMTI_PIN_MODE			(1 << 0)

#define BMTI_REG_STATUS			0x005C
#define BMTI_MUX_PN_ERR			(1 << 3)
#define BMTI_MUX_PN_OOS			(1 << 2)
#define BMTI_MUX_OVER_RANGE		(1 << 1)
#define BMTI_STATUS				(1 << 0)

#define BMTI_REG_DELAY_CNTRL		0x0060	/* <= v8.0 */
#define BMTI_DELAY_SEL			(1 << 17)
#define BMTI_DELAY_RWN			(1 << 16)
#define BMTI_DELAY_ADDRESS(x)	(((x) & 0xFF) << 8)
#define BMTI_TO_DELAY_ADDRESS(x)	(((x) >> 8) & 0xFF)
#define BMTI_DELAY_WDATA(x)		(((x) & 0x1F) << 0)
#define BMTI_TO_DELAY_WDATA(x)	(((x) >> 0) & 0x1F)

#define BMTI_REG_CHAN_CNTRL(c)	(0x0400 + (c) * 0x40)
#define BMTI_PN_SEL				(1 << 10) /* !v8.0 */
#define BMTI_IQCOR_ENB			(1 << 9)
#define BMTI_DCFILT_ENB			(1 << 8)
#define BMTI_FORMAT_SIGNEXT		(1 << 6)
#define BMTI_FORMAT_TYPE			(1 << 5)
#define BMTI_FORMAT_ENABLE		(1 << 4)
#define BMTI_PN23_TYPE			(1 << 1) /* !v8.0 */
#define BMTI_ENABLE				(1 << 0)

#define BMTI_REG_CHAN_STATUS(c)	(0x0404 + (c) * 0x40)
#define BMTI_PN_ERR				(1 << 2)
#define BMTI_PN_OOS				(1 << 1)
#define BMTI_OVER_RANGE			(1 << 0)

#define BMTI_REG_CHAN_CNTRL_1(c)		(0x0410 + (c) * 0x40)
#define BMTI_DCFILT_OFFSET(x)		(((x) & 0xFFFF) << 16)
#define BMTI_TO_DCFILT_OFFSET(x)		(((x) >> 16) & 0xFFFF)
#define BMTI_DCFILT_COEFF(x)			(((x) & 0xFFFF) << 0)
#define BMTI_TO_DCFILT_COEFF(x)		(((x) >> 0) & 0xFFFF)

#define BMTI_REG_CHAN_CNTRL_2(c)		(0x0414 + (c) * 0x40)
#define BMTI_IQCOR_COEFF_1(x)		(((x) & 0xFFFF) << 16)
#define BMTI_TO_IQCOR_COEFF_1(x)		(((x) >> 16) & 0xFFFF)
#define BMTI_IQCOR_COEFF_2(x)		(((x) & 0xFFFF) << 0)
#define BMTI_TO_IQCOR_COEFF_2(x)		(((x) >> 0) & 0xFFFF)

#define PCORE_VERSION(major, minor, letter) ((major << 16) | (minor << 8) | letter)
#define PCORE_VERSION_MAJOR(version) (version >> 16)
#define PCORE_VERSION_MINOR(version) ((version >> 8) & 0xff)
#define PCORE_VERSION_LETTER(version) (version & 0xff)

#define BMTI_REG_CHAN_CNTRL_3(c)		(0x0418 + (c) * 0x40) /* v8.0 */
#define BMTI_ADC_PN_SEL(x)			(((x) & 0xF) << 16)
#define BMTI_TO_ADC_PN_SEL(x)		(((x) >> 16) & 0xF)
#define BMTI_ADC_DATA_SEL(x)			(((x) & 0xF) << 0)
#define BMTI_TO_ADC_DATA_SEL(x)		(((x) >> 0) & 0xF)

/* PCORE Version > 8.00 */
#define BMTI_REG_DELAY(l)			(0x0800 + (l) * 0x4)

enum adc_pn_sel {
	ADC_PN9 = 0,
	ADC_PN23A = 1,
	ADC_PN7 = 4,
	ADC_PN15 = 5,
	ADC_PN23 = 6,
	ADC_PN31 = 7,
	ADC_PN_CUSTOM = 9,
	ADC_PN_END = 10,
};

enum adc_data_sel {
	ADC_DATA_SEL_NORM,
	ADC_DATA_SEL_LB, /* DAC loopback */
	ADC_DATA_SEL_RAMP, /* TBD */
};

/******************************************************************************/
/************************ Functions Declarations ******************************/
/******************************************************************************/
int32_t spi_init(uint32_t device_id,
				 uint8_t  clk_pha,
				 uint8_t  clk_pol);
int32_t spi_read(struct spi_device *spi,
				 uint8_t *data,
				 uint8_t bytes_number);
int spi_write_then_read(struct spi_device *spi,
		const unsigned char *txbuf, unsigned n_tx,
		unsigned char *rxbuf, unsigned n_rx);
void gpio_init(uint32_t device_id);
void gpio_direction(uint8_t pin, uint8_t direction);
bool gpio_is_valid(int number);
void gpio_set_value(unsigned gpio, int value);
void udelay(unsigned long usecs);
void mdelay(unsigned long msecs);
unsigned long msleep_interruptible(unsigned int msecs);
void axiadc_init(struct b9361_rf_phy *phy);
int axiadc_post_setup(struct b9361_rf_phy *phy);
unsigned int axiadc_read(struct axiadc_state *st, unsigned long reg);
void axiadc_write(struct axiadc_state *st, unsigned reg, unsigned val);
int axiadc_set_pnsel(struct axiadc_state *st, int channel, enum adc_pn_sel sel);
void axiadc_idelay_set(struct axiadc_state *st, unsigned lane, unsigned val);
#endif
