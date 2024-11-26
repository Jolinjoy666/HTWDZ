/***************************************************************************//**
 *   @file   common.h
 *   @brief  Header file of Common Driver.
*******************************************************************************/
#ifndef COMMON_H_
#define COMMON_H_

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>

/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/
#define EIO			5	/* I/O error */
#define EAGAIN		11	/* Try again */
#define ENOMEM		12	/* Out of memory */
#define EFAULT		14	/* Bad address */
#define ENODEV		19	/* No such device */
#define EINVAL		22	/* Invalid argument */
#define EOPNOTSUPP	45	/* Operation not supported on transport endpoint */
#define ETIMEDOUT	110	/* Connection timed out */

/******************************************************************************/
/*************************** Types Declarations *******************************/
/******************************************************************************/
#if defined (__STDC__) && (__STDC_VERSION__ >= 199901L)
#include <stdbool.h>
#else
typedef enum { false, true } bool;
#endif

struct clk {
	const char	*name;
	uint32_t	rate;
};

struct clk_hw {
		struct clk *clk;
};

struct clk_init_data {
	const char				*name;
	const struct clk_ops	*ops;
	const char				**parent_names;
	uint8_t					num_parents;
	uint32_t				flags;
};

struct clk_onecell_data {
	struct clk		**clks;
	uint32_t		clk_num;
};

#endif
