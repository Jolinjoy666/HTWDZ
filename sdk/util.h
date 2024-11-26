/***************************************************************************//**
 *   @file   util.h
 *   @brief  Header file of Util driver.
*******************************************************************************/
#ifndef __NO_OS_PORT_H__
#define __NO_OS_PORT_H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "b9361.h"
#include "common.h"
#include "config.h"


/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/
#define SUCCESS									0
#define ARRAY_SIZE(arr)							(sizeof(arr) / sizeof((arr)[0]))
#define min(x, y)								(((x) < (y)) ? (x) : (y))
#define min_t(type, x, y)						(type)min((type)(x), (type)(y))
#define max(x, y)								(((x) > (y)) ? (x) : (y))
#define max_t(type, x, y)						(type)max((type)(x), (type)(y))
#define clamp(val, min_val, max_val)			(max(min((val), (max_val)), (min_val)))
#define clamp_t(type, val, min_val, max_val)	(type)clamp((type)(val), (type)(min_val), (type)(max_val))
#define DIV_ROUND_UP(x, y)						(((x) + (y) - 1) / (y))
#define DIV_ROUND_CLOSEST(x, divisor)			(((x) + (divisor) / 2) / (divisor))
#define BIT(x)									(1 << (x))
#define CLK_IGNORE_UNUSED						BIT(3)
#define CLK_GET_RATE_NOCACHE					BIT(6)

#if defined(HAVE_VERBOSE_MESSAGES)
#define dev_err(dev, format, ...)		({printf(format, ## __VA_ARGS__);printf("\n"); })
#define dev_warn(dev, format, ...)		({printf(format, ## __VA_ARGS__);printf("\n"); })
#if defined(HAVE_DEBUG_MESSAGES)
#define dev_dbg(dev, format, ...)		({printf(format, ## __VA_ARGS__);printf("\n"); })
#else
#define dev_dbg(dev, format, ...)	({ if (0) printf(format, ## __VA_ARGS__); })
#endif
#define printk(format, ...)			printf(format, ## __VA_ARGS__)
#else
#define dev_err(dev, format, ...)	({ if (0) printf(format, ## __VA_ARGS__); })
#define dev_warn(dev, format, ...)	({ if (0) printf(format, ## __VA_ARGS__); })
#define dev_dbg(dev, format, ...)	({ if (0) printf(format, ## __VA_ARGS__); })
#define printk(format, ...)			({ if (0) printf(format, ## __VA_ARGS__); })
#endif

struct device {
};

struct spi_device {
	struct device	dev;
	uint8_t 		id_no;
};

struct axiadc_state {
	struct b9361_rf_phy	*phy;
	uint32_t				pcore_version;
};

struct axiadc_chip_info {
	char		*name;
	int32_t		num_channels;
};

struct axiadc_converter {
	struct axiadc_chip_info	*chip_info;
	uint32_t				scratch_reg[16];
};

#ifdef WIN32
#include "basetsd.h"
typedef SSIZE_T ssize_t;
#define strsep(s, ct)				0
#define snprintf(s, n, format, ...)	0
#define __func__ __FUNCTION__
#endif

/******************************************************************************/
/************************ Functions Declarations ******************************/
/******************************************************************************/
int32_t clk_prepare_enable(struct clk *clk);
uint32_t clk_get_rate(struct b9361_rf_phy *phy,
					  struct refclk_scale *clk_priv);
int32_t clk_set_rate(struct b9361_rf_phy *phy,
					 struct refclk_scale *clk_priv,
					 uint32_t rate);
uint32_t int_sqrt(uint32_t x);
int32_t ilog2(int32_t x);
uint64_t do_div(uint64_t* n,
				uint64_t base);
uint32_t find_first_bit(uint32_t word);
void * ERR_PTR(long error);
void *zmalloc(size_t size);

#endif
