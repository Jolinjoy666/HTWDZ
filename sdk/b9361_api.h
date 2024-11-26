/***************************************************************************//**
 *   @file   b9361_api.h
 *   @brief  Header file of B9361 API Driver.
*******************************************************************************/
#ifndef B9361_API_H_
#define B9361_API_H_

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include "util.h"

/******************************************************************************/
/*************************** Types Declarations *******************************/
/******************************************************************************/
typedef struct {
	/* Device selection */
	enum dev_id	dev_sel;
	/* Identification number */
	uint8_t		id_no;
	/* Reference Clock */
	uint32_t	reference_clk_rate;
	/* Base Configuration */
	uint8_t		two_rx_two_tx_mode_enable;	/* bmti,2rx-2tx-mode-enable */
	uint8_t		one_rx_one_tx_mode_use_rx_num;	/* bmti,1rx-1tx-mode-use-rx-num */
	uint8_t		one_rx_one_tx_mode_use_tx_num;	/* bmti,1rx-1tx-mode-use-tx-num */
	uint8_t		frequency_division_duplex_mode_enable;	/* bmti,frequency-division-duplex-mode-enable */
	uint8_t		frequency_division_duplex_independent_mode_enable;	/* bmti,frequency-division-duplex-independent-mode-enable */
	uint8_t		tdd_use_dual_synth_mode_enable;	/* bmti,tdd-use-dual-synth-mode-enable */
	uint8_t		tdd_skip_vco_cal_enable;		/* bmti,tdd-skip-vco-cal-enable */
	uint32_t	tx_fastlock_delay_ns;	/* bmti,tx-fastlock-delay-ns */
	uint32_t	rx_fastlock_delay_ns;	/* bmti,rx-fastlock-delay-ns */
	uint8_t		rx_fastlock_pincontrol_enable;	/* bmti,rx-fastlock-pincontrol-enable */
	uint8_t		tx_fastlock_pincontrol_enable;	/* bmti,tx-fastlock-pincontrol-enable */
	uint8_t		external_rx_lo_enable;	/* bmti,external-rx-lo-enable */
	uint8_t		external_tx_lo_enable;	/* bmti,external-tx-lo-enable */
	uint8_t		dc_offset_tracking_update_event_mask;	/* bmti,dc-offset-tracking-update-event-mask */
	uint8_t		dc_offset_attenuation_high_range;	/* bmti,dc-offset-attenuation-high-range */
	uint8_t		dc_offset_attenuation_low_range;	/* bmti,dc-offset-attenuation-low-range */
	uint8_t		dc_offset_count_high_range;			/* bmti,dc-offset-count-high-range */
	uint8_t		dc_offset_count_low_range;			/* bmti,dc-offset-count-low-range */
	uint8_t		split_gain_table_mode_enable;	/* bmti,split-gain-table-mode-enable */
	uint32_t	trx_synthesizer_target_fref_overwrite_hz;	/* bmti,trx-synthesizer-target-fref-overwrite-hz */
	uint8_t		qec_tracking_slow_mode_enable;	/* bmti,qec-tracking-slow-mode-enable */
	/* ENSM Control */
	uint8_t		ensm_enable_pin_pulse_mode_enable;	/* bmti,ensm-enable-pin-pulse-mode-enable */
	uint8_t		ensm_enable_txnrx_control_enable;	/* bmti,ensm-enable-txnrx-control-enable */
	/* LO Control */
	uint64_t	rx_synthesizer_frequency_hz;	/* bmti,rx-synthesizer-frequency-hz */
	uint64_t	tx_synthesizer_frequency_hz;	/* bmti,tx-synthesizer-frequency-hz */
	uint8_t		tx_lo_powerdown_managed_enable;	/* bmti,tx-lo-powerdown-managed-enable */
	/* Rate & BW Control */
	uint32_t	rx_path_clock_frequencies[6];	/* bmti,rx-path-clock-frequencies */
	uint32_t	tx_path_clock_frequencies[6];	/* bmti,tx-path-clock-frequencies */
	uint32_t	rf_rx_bandwidth_hz;	/* bmti,rf-rx-bandwidth-hz */
	uint32_t	rf_tx_bandwidth_hz;	/* bmti,rf-tx-bandwidth-hz */
	/* RF Port Control */
	uint32_t	rx_rf_port_input_select;	/* bmti,rx-rf-port-input-select */
	uint32_t	tx_rf_port_input_select;	/* bmti,tx-rf-port-input-select */
	/* TX Attenuation Control */
	int32_t		tx_attenuation_mdB;	/* bmti,tx-attenuation-mdB */
	uint8_t		update_tx_gain_in_alert_enable;	/* bmti,update-tx-gain-in-alert-enable */
	/* Reference Clock Control */
	uint8_t		xo_disable_use_ext_refclk_enable;	/* bmti,xo-disable-use-ext-refclk-enable */
	uint32_t	dcxo_coarse_and_fine_tune[2];	/* bmti,dcxo-coarse-and-fine-tune */
	uint32_t	clk_output_mode_select;		/* bmti,clk-output-mode-select */
	/* Gain Control */
	uint8_t		gc_rx1_mode;	/* bmti,gc-rx1-mode */
	uint8_t		gc_rx2_mode;	/* bmti,gc-rx2-mode */
	uint8_t		gc_adc_large_overload_thresh;	/* bmti,gc-adc-large-overload-thresh */
	uint8_t		gc_adc_ovr_sample_size;	/* bmti,gc-adc-ovr-sample-size */
	uint8_t		gc_adc_small_overload_thresh;	/* bmti,gc-adc-small-overload-thresh */
	uint16_t	gc_dec_pow_measurement_duration;	/* bmti,gc-dec-pow-measurement-duration */
	uint8_t		gc_dig_gain_enable;	/* bmti,gc-dig-gain-enable */
	uint16_t	gc_lmt_overload_high_thresh;	/* bmti,gc-lmt-overload-high-thresh */
	uint16_t	gc_lmt_overload_low_thresh;	/* bmti,gc-lmt-overload-low-thresh */
	uint8_t		gc_low_power_thresh;	/* bmti,gc-low-power-thresh */
	uint8_t		gc_max_dig_gain;	/* bmti,gc-max-dig-gain */
	/* Gain MGC Control */
	uint8_t		mgc_dec_gain_step;	/* bmti,mgc-dec-gain-step */
	uint8_t		mgc_inc_gain_step;	/* bmti,mgc-inc-gain-step */
	uint8_t		mgc_rx1_ctrl_inp_enable;	/* bmti,mgc-rx1-ctrl-inp-enable */
	uint8_t		mgc_rx2_ctrl_inp_enable;	/* bmti,mgc-rx2-ctrl-inp-enable */
	uint8_t		mgc_split_table_ctrl_inp_gain_mode;	/* bmti,mgc-split-table-ctrl-inp-gain-mode */
	/* Gain AGC Control */
	uint8_t		agc_adc_large_overload_exceed_counter;	/* bmti,agc-adc-large-overload-exceed-counter */
	uint8_t		agc_adc_large_overload_inc_steps;	/* bmti,agc-adc-large-overload-inc-steps */
	uint8_t		agc_adc_lmt_small_overload_prevent_gain_inc_enable;	/* bmti,agc-adc-lmt-small-overload-prevent-gain-inc-enable */
	uint8_t		agc_adc_small_overload_exceed_counter;	/* bmti,agc-adc-small-overload-exceed-counter */
	uint8_t		agc_dig_gain_step_size;	/* bmti,agc-dig-gain-step-size */
	uint8_t		agc_dig_saturation_exceed_counter;	/* bmti,agc-dig-saturation-exceed-counter */
	uint32_t	agc_gain_update_interval_us; /* bmti,agc-gain-update-interval-us */
	uint8_t		agc_immed_gain_change_if_large_adc_overload_enable;	/* bmti,agc-immed-gain-change-if-large-adc-overload-enable */
	uint8_t		agc_immed_gain_change_if_large_lmt_overload_enable;	/* bmti,agc-immed-gain-change-if-large-lmt-overload-enable */
	uint8_t		agc_inner_thresh_high;	/* bmti,agc-inner-thresh-high */
	uint8_t		agc_inner_thresh_high_dec_steps;	/* bmti,agc-inner-thresh-high-dec-steps */
	uint8_t		agc_inner_thresh_low;	/* bmti,agc-inner-thresh-low */
	uint8_t		agc_inner_thresh_low_inc_steps;	/* bmti,agc-inner-thresh-low-inc-steps */
	uint8_t		agc_lmt_overload_large_exceed_counter;	/* bmti,agc-lmt-overload-large-exceed-counter */
	uint8_t		agc_lmt_overload_large_inc_steps;	/* bmti,agc-lmt-overload-large-inc-steps */
	uint8_t		agc_lmt_overload_small_exceed_counter;	/* bmti,agc-lmt-overload-small-exceed-counter */
	uint8_t		agc_outer_thresh_high;	/* bmti,agc-outer-thresh-high */
	uint8_t		agc_outer_thresh_high_dec_steps;	/* bmti,agc-outer-thresh-high-dec-steps */
	uint8_t		agc_outer_thresh_low;	/* bmti,agc-outer-thresh-low */
	uint8_t		agc_outer_thresh_low_inc_steps;	/* bmti,agc-outer-thresh-low-inc-steps */
	uint32_t	agc_attack_delay_extra_margin_us;	/* bmti,agc-attack-delay-extra-margin-us */
	uint8_t		agc_sync_for_gain_counter_enable;	/* bmti,agc-sync-for-gain-counter-enable */
	/* Fast AGC */
	uint32_t	fagc_dec_pow_measuremnt_duration;	/* bmti,fagc-dec-pow-measurement-duration */
	uint32_t	fagc_state_wait_time_ns;	/* bmti,fagc-state-wait-time-ns */
	/* Fast AGC - Low Power */
	uint8_t		fagc_allow_agc_gain_increase;	/* bmti,fagc-allow-agc-gain-increase-enable */
	uint32_t	fagc_lp_thresh_increment_time;	/* bmti,fagc-lp-thresh-increment-time */
	uint32_t	fagc_lp_thresh_increment_steps;	/* bmti,fagc-lp-thresh-increment-steps */
	/* Fast AGC - Lock Level (Lock Level is set via slow AGC inner high threshold) */
	uint8_t		fagc_lock_level_lmt_gain_increase_en;	/* bmti,fagc-lock-level-lmt-gain-increase-enable */
	uint32_t	fagc_lock_level_gain_increase_upper_limit;	/* bmti,fagc-lock-level-gain-increase-upper-limit */
	/* Fast AGC - Peak Detectors and Final Settling */
	uint32_t	fagc_lpf_final_settling_steps;	/* bmti,fagc-lpf-final-settling-steps */
	uint32_t	fagc_lmt_final_settling_steps;	/* bmti,fagc-lmt-final-settling-steps */
	uint32_t	fagc_final_overrange_count;	/* bmti,fagc-final-overrange-count */
	/* Fast AGC - Final Power Test */
	uint8_t		fagc_gain_increase_after_gain_lock_en;	/* bmti,fagc-gain-increase-after-gain-lock-enable */
	/* Fast AGC - Unlocking the Gain */
	uint32_t	fagc_gain_index_type_after_exit_rx_mode;	/* bmti,fagc-gain-index-type-after-exit-rx-mode */
	uint8_t		fagc_use_last_lock_level_for_set_gain_en;	/* bmti,fagc-use-last-lock-level-for-set-gain-enable */
	uint8_t		fagc_rst_gla_stronger_sig_thresh_exceeded_en;	/* bmti,fagc-rst-gla-stronger-sig-thresh-exceeded-enable */
	uint32_t	fagc_optimized_gain_offset;	/* bmti,fagc-optimized-gain-offset */
	uint32_t	fagc_rst_gla_stronger_sig_thresh_above_ll;	/* bmti,fagc-rst-gla-stronger-sig-thresh-above-ll */
	uint8_t		fagc_rst_gla_engergy_lost_sig_thresh_exceeded_en;	/* bmti,fagc-rst-gla-engergy-lost-sig-thresh-exceeded-enable */
	uint8_t		fagc_rst_gla_engergy_lost_goto_optim_gain_en;	/* bmti,fagc-rst-gla-engergy-lost-goto-optim-gain-enable */
	uint32_t	fagc_rst_gla_engergy_lost_sig_thresh_below_ll;	/* bmti,fagc-rst-gla-engergy-lost-sig-thresh-below-ll */
	uint32_t	fagc_energy_lost_stronger_sig_gain_lock_exit_cnt;	/* bmti,fagc-energy-lost-stronger-sig-gain-lock-exit-cnt */
	uint8_t		fagc_rst_gla_large_adc_overload_en;	/* bmti,fagc-rst-gla-large-adc-overload-enable */
	uint8_t		fagc_rst_gla_large_lmt_overload_en;	/* bmti,fagc-rst-gla-large-lmt-overload-enable */
	uint8_t		fagc_rst_gla_en_agc_pulled_high_en;	/* bmti,fagc-rst-gla-en-agc-pulled-high-enable */
	uint32_t	fagc_rst_gla_if_en_agc_pulled_high_mode;	/* bmti,fagc-rst-gla-if-en-agc-pulled-high-mode */
	uint32_t	fagc_power_measurement_duration_in_state5;	/* bmti,fagc-power-measurement-duration-in-state5 */
	/* RSSI Control */
	uint32_t	rssi_delay;	/* bmti,rssi-delay */
	uint32_t	rssi_duration;	/* bmti,rssi-duration */
	uint8_t		rssi_restart_mode;	/* bmti,rssi-restart-mode */
	uint8_t		rssi_unit_is_rx_samples_enable;	/* bmti,rssi-unit-is-rx-samples-enable */
	uint32_t	rssi_wait;	/* bmti,rssi-wait */
	/* Aux ADC Control */
	uint32_t	aux_adc_decimation;	/* bmti,aux-adc-decimation */
	uint32_t	aux_adc_rate;	/* bmti,aux-adc-rate */
	/* AuxDAC Control */
	uint8_t		aux_dac_manual_mode_enable;	/* bmti,aux-dac-manual-mode-enable */
	uint32_t	aux_dac1_default_value_mV;	/* bmti,aux-dac1-default-value-mV */
	uint8_t		aux_dac1_active_in_rx_enable;	/* bmti,aux-dac1-active-in-rx-enable */
	uint8_t		aux_dac1_active_in_tx_enable;	/* bmti,aux-dac1-active-in-tx-enable */
	uint8_t		aux_dac1_active_in_alert_enable;	/* bmti,aux-dac1-active-in-alert-enable */
	uint32_t	aux_dac1_rx_delay_us;	/* bmti,aux-dac1-rx-delay-us */
	uint32_t	aux_dac1_tx_delay_us;	/* bmti,aux-dac1-tx-delay-us */
	uint32_t	aux_dac2_default_value_mV;	/* bmti,aux-dac2-default-value-mV */
	uint8_t		aux_dac2_active_in_rx_enable;	/* bmti,aux-dac2-active-in-rx-enable */
	uint8_t		aux_dac2_active_in_tx_enable;	/* bmti,aux-dac2-active-in-tx-enable */
	uint8_t		aux_dac2_active_in_alert_enable;	/* bmti,aux-dac2-active-in-alert-enable */
	uint32_t	aux_dac2_rx_delay_us;	/* bmti,aux-dac2-rx-delay-us */
	uint32_t	aux_dac2_tx_delay_us;	/* bmti,aux-dac2-tx-delay-us */
	/* Temperature Sensor Control */
	uint32_t	temp_sense_decimation;	/* bmti,temp-sense-decimation */
	uint16_t	temp_sense_measurement_interval_ms;	/* bmti,temp-sense-measurement-interval-ms */
	int8_t		temp_sense_offset_signed;	/* bmti,temp-sense-offset-signed */
	uint8_t		temp_sense_periodic_measurement_enable;	/* bmti,temp-sense-periodic-measurement-enable */
	/* Control Out Setup */
	uint8_t		ctrl_outs_enable_mask;	/* bmti,ctrl-outs-enable-mask */
	uint8_t		ctrl_outs_index;	/* bmti,ctrl-outs-index */
	/* External LNA Control */
	uint32_t	elna_settling_delay_ns;	/* bmti,elna-settling-delay-ns */
	uint32_t	elna_gain_mdB;	/* bmti,elna-gain-mdB */
	uint32_t	elna_bypass_loss_mdB;	/* bmti,elna-bypass-loss-mdB */
	uint8_t		elna_rx1_gpo0_control_enable;	/* bmti,elna-rx1-gpo0-control-enable */
	uint8_t		elna_rx2_gpo1_control_enable;	/* bmti,elna-rx2-gpo1-control-enable */
	uint8_t		elna_gaintable_all_index_enable;	/* bmti,elna-gaintable-all-index-enable */
	/* Digital Interface Control */
	uint8_t		digital_interface_tune_skip_mode;	/* bmti,digital-interface-tune-skip-mode */
	uint8_t		digital_interface_tune_fir_disable;	/* bmti,digital-interface-tune-fir-disable */
	uint8_t		pp_tx_swap_enable;	/* bmti,pp-tx-swap-enable */
	uint8_t		pp_rx_swap_enable;	/* bmti,pp-rx-swap-enable */
	uint8_t		tx_channel_swap_enable;	/* bmti,tx-channel-swap-enable */
	uint8_t		rx_channel_swap_enable;	/* bmti,rx-channel-swap-enable */
	uint8_t		rx_frame_pulse_mode_enable;	/* bmti,rx-frame-pulse-mode-enable */
	uint8_t		two_t_two_r_timing_enable;	/* bmti,2t2r-timing-enable */
	uint8_t		invert_data_bus_enable;	/* bmti,invert-data-bus-enable */
	uint8_t		invert_data_clk_enable;	/* bmti,invert-data-clk-enable */
	uint8_t		fdd_alt_word_order_enable;	/* bmti,fdd-alt-word-order-enable */
	uint8_t		invert_rx_frame_enable;	/* bmti,invert-rx-frame-enable */
	uint8_t		fdd_rx_rate_2tx_enable;	/* bmti,fdd-rx-rate-2tx-enable */
	uint8_t		swap_ports_enable;	/* bmti,swap-ports-enable */
	uint8_t		single_data_rate_enable;	/* bmti,single-data-rate-enable */
	uint8_t		lvds_mode_enable;	/* bmti,lvds-mode-enable */
	uint8_t		half_duplex_mode_enable;	/* bmti,half-duplex-mode-enable */
	uint8_t		single_port_mode_enable;	/* bmti,single-port-mode-enable */
	uint8_t		full_port_enable;	/* bmti,full-port-enable */
	uint8_t		full_duplex_swap_bits_enable;	/* bmti,full-duplex-swap-bits-enable */
	uint32_t	delay_rx_data;	/* bmti,delay-rx-data */
	uint32_t	rx_data_clock_delay;	/* bmti,rx-data-clock-delay */
	uint32_t	rx_data_delay;	/* bmti,rx-data-delay */
	uint32_t	tx_fb_clock_delay;	/* bmti,tx-fb-clock-delay */
	uint32_t	tx_data_delay;	/* bmti,tx-data-delay */
	uint32_t	lvds_bias_mV;	/* bmti,lvds-bias-mV */
	uint8_t		lvds_rx_onchip_termination_enable;	/* bmti,lvds-rx-onchip-termination-enable */
	uint8_t		rx1rx2_phase_inversion_en;	/* bmti,rx1-rx2-phase-inversion-enable */
	uint8_t		lvds_invert1_control;	/* bmti,lvds-invert1-control */
	uint8_t		lvds_invert2_control;	/* bmti,lvds-invert2-control */
	/* GPO Control */
	uint8_t		gpo0_inactive_state_high_enable;	/* bmti,gpo0-inactive-state-high-enable */
	uint8_t		gpo1_inactive_state_high_enable;	/* bmti,gpo1-inactive-state-high-enable */
	uint8_t		gpo2_inactive_state_high_enable;	/* bmti,gpo2-inactive-state-high-enable */
	uint8_t		gpo3_inactive_state_high_enable;	/* bmti,gpo3-inactive-state-high-enable */
	uint8_t		gpo0_slave_rx_enable;	/* bmti,gpo0-slave-rx-enable */
	uint8_t		gpo0_slave_tx_enable;	/* bmti,gpo0-slave-tx-enable */
	uint8_t		gpo1_slave_rx_enable;	/* bmti,gpo1-slave-rx-enable */
	uint8_t		gpo1_slave_tx_enable;	/* bmti,gpo1-slave-tx-enable */
	uint8_t		gpo2_slave_rx_enable;	/* bmti,gpo2-slave-rx-enable */
	uint8_t		gpo2_slave_tx_enable;	/* bmti,gpo2-slave-tx-enable */
	uint8_t		gpo3_slave_rx_enable;	/* bmti,gpo3-slave-rx-enable */
	uint8_t		gpo3_slave_tx_enable;	/* bmti,gpo3-slave-tx-enable */
	uint8_t		gpo0_rx_delay_us;	/* bmti,gpo0-rx-delay-us */
	uint8_t		gpo0_tx_delay_us;	/* bmti,gpo0-tx-delay-us */
	uint8_t		gpo1_rx_delay_us;	/* bmti,gpo1-rx-delay-us */
	uint8_t		gpo1_tx_delay_us;	/* bmti,gpo1-tx-delay-us */
	uint8_t		gpo2_rx_delay_us;	/* bmti,gpo2-rx-delay-us */
	uint8_t		gpo2_tx_delay_us;	/* bmti,gpo2-tx-delay-us */
	uint8_t		gpo3_rx_delay_us;	/* bmti,gpo3-rx-delay-us */
	uint8_t		gpo3_tx_delay_us;	/* bmti,gpo3-tx-delay-us */
	/* Tx Monitor Control */
	uint32_t	low_high_gain_threshold_mdB;	/* bmti,txmon-low-high-thresh */
	uint32_t	low_gain_dB;	/* bmti,txmon-low-gain */
	uint32_t	high_gain_dB;	/* bmti,txmon-high-gain */
	uint8_t		tx_mon_track_en;	/* bmti,txmon-dc-tracking-enable */
	uint8_t		one_shot_mode_en;	/* bmti,txmon-one-shot-mode-enable */
	uint32_t	tx_mon_delay;	/* bmti,txmon-delay */
	uint32_t	tx_mon_duration;	/* bmti,txmon-duration */
	uint32_t	tx1_mon_front_end_gain;	/* bmti,txmon-1-front-end-gain */
	uint32_t	tx2_mon_front_end_gain;	/* bmti,txmon-2-front-end-gain */
	uint32_t	tx1_mon_lo_cm;	/* bmti,txmon-1-lo-cm */
	uint32_t	tx2_mon_lo_cm;	/* bmti,txmon-2-lo-cm */
	/* GPIO definitions */
	int32_t		gpio_resetb;	/* reset-gpios */
	/* MCS Sync */
	int32_t		gpio_sync;		/* sync-gpios */
	int32_t		gpio_cal_sw1;	/* cal-sw1-gpios */
	int32_t		gpio_cal_sw2;	/* cal-sw2-gpios */
	/* External LO clocks */
	uint32_t	(*b9361_rfpll_ext_recalc_rate)(struct refclk_scale *clk_priv);
	int32_t		(*b9361_rfpll_ext_round_rate)(struct refclk_scale *clk_priv,
			uint32_t rate);
	int32_t		(*b9361_rfpll_ext_set_rate)(struct refclk_scale *clk_priv,
			uint32_t rate);
} B9361_InitParam;

typedef struct {
	uint32_t	rx;				/* 1, 2, 3(both) */
	int32_t		rx_gain;		/* -12, -6, 0, 6 */
	uint32_t	rx_dec;			/* 1, 2, 4 */
	int16_t		rx_coef[128];
	uint8_t		rx_coef_size;
	uint32_t	rx_path_clks[6];
	uint32_t	rx_bandwidth;
} B9361_RXFIRConfig;

typedef struct {
	uint32_t	tx;				/* 1, 2, 3(both) */
	int32_t		tx_gain;		/* -6, 0 */
	uint32_t	tx_int;			/* 1, 2, 4 */
	int16_t		tx_coef[128];
	uint8_t		tx_coef_size;
	uint32_t	tx_path_clks[6];
	uint32_t	tx_bandwidth;
} B9361_TXFIRConfig;

enum b9361_ensm_mode {
	ENSM_MODE_TX,
	ENSM_MODE_RX,
	ENSM_MODE_ALERT,
	ENSM_MODE_FDD,
	ENSM_MODE_WAIT,
	ENSM_MODE_SLEEP,
	ENSM_MODE_PINCTRL,
	ENSM_MODE_PINCTRL_FDD_INDEP,
};

#define ENABLE		1
#define DISABLE		0

#define RX1			0
#define RX2			1

#define TX1			0
#define TX2			1

#define A_BALANCED	0
#define B_BALANCED	1
#define C_BALANCED	2
#define A_N			3
#define A_P			4
#define B_N			5
#define B_P			6
#define C_N			7
#define C_P			8
#define TX_MON1		9
#define TX_MON2		10
#define TX_MON1_2	11

#define TXA			0
#define TXB			1

#define MODE_1x1	1
#define MODE_2x2	2

#define HIGHEST_OSR	0
#define NOMINAL_OSR	1

#define INT_LO		0
#define EXT_LO		1

#define ON			0
#define OFF			1

/******************************************************************************/
/************************ Functions Declarations ******************************/
/******************************************************************************/
/* Initialize the B9361 part. */
int32_t b9361_init (struct b9361_rf_phy **b9361_phy,
		     B9361_InitParam *init_param);
/* Set the Enable State Machine (ENSM) mode. */
int32_t b9361_set_en_state_machine_mode (struct b9361_rf_phy *phy,
		uint32_t mode);
/* Get the Enable State Machine (ENSM) mode. */
int32_t b9361_get_en_state_machine_mode (struct b9361_rf_phy *phy,
		uint32_t *mode);
/* Set the receive RF gain for the selected channel. */
int32_t b9361_set_rx_rf_gain (struct b9361_rf_phy *phy, uint8_t ch,
			       int32_t gain_db);
/* Get current receive RF gain for the selected channel. */
int32_t b9361_get_rx_rf_gain (struct b9361_rf_phy *phy, uint8_t ch,
			       int32_t *gain_db);
/* Set the RX RF bandwidth. */
int32_t b9361_set_rx_rf_bandwidth (struct b9361_rf_phy *phy,
				    uint32_t bandwidth_hz);
/* Get the RX RF bandwidth. */
int32_t b9361_get_rx_rf_bandwidth (struct b9361_rf_phy *phy,
				    uint32_t *bandwidth_hz);
/* Set the RX sampling frequency. */
int32_t b9361_set_rx_sampling_freq (struct b9361_rf_phy *phy,
				     uint32_t sampling_freq_hz);
/* Get current RX sampling frequency. */
int32_t b9361_get_rx_sampling_freq (struct b9361_rf_phy *phy,
				     uint32_t *sampling_freq_hz);
/* Set the RX LO frequency. */
int32_t b9361_set_rx_lo_freq (struct b9361_rf_phy *phy, uint64_t lo_freq_hz);
/* Get current RX LO frequency. */
int32_t b9361_get_rx_lo_freq (struct b9361_rf_phy *phy, uint64_t *lo_freq_hz);
/* Switch between internal and external LO. */
int32_t b9361_set_rx_lo_int_ext(struct b9361_rf_phy *phy, uint8_t int_ext);
/* Get the RSSI for the selected channel. */
int32_t b9361_get_rx_rssi (struct b9361_rf_phy *phy, uint8_t ch,
			    struct rf_rssi *rssi);
/* Set the gain control mode for the selected channel. */
int32_t b9361_set_rx_gain_control_mode (struct b9361_rf_phy *phy, uint8_t ch,
		uint8_t gc_mode);
/* Get the gain control mode for the selected channel. */
int32_t b9361_get_rx_gain_control_mode (struct b9361_rf_phy *phy, uint8_t ch,
		uint8_t *gc_mode);
/* Set the RX FIR filter configuration. */
int32_t b9361_set_rx_fir_config (struct b9361_rf_phy *phy,
				  B9361_RXFIRConfig fir_cfg);
/* Get the RX FIR filter configuration. */
int32_t b9361_get_rx_fir_config(struct b9361_rf_phy *phy, uint8_t rx_ch,
				 B9361_RXFIRConfig *fir_cfg);
/* Enable/disable the RX FIR filter. */
int32_t b9361_set_rx_fir_en_dis (struct b9361_rf_phy *phy, uint8_t en_dis);
/* Get the status of the RX FIR filter. */
int32_t b9361_get_rx_fir_en_dis (struct b9361_rf_phy *phy, uint8_t *en_dis);
/* Enable/disable the RX RFDC Tracking. */
int32_t b9361_set_rx_rfdc_track_en_dis (struct b9361_rf_phy *phy,
		uint8_t en_dis);
/* Get the status of the RX RFDC Tracking. */
int32_t b9361_get_rx_rfdc_track_en_dis (struct b9361_rf_phy *phy,
		uint8_t *en_dis);
/* Enable/disable the RX BasebandDC Tracking. */
int32_t b9361_set_rx_bbdc_track_en_dis (struct b9361_rf_phy *phy,
		uint8_t en_dis);
/* Get the status of the RX BasebandDC Tracking. */
int32_t b9361_get_rx_bbdc_track_en_dis (struct b9361_rf_phy *phy,
		uint8_t *en_dis);
/* Enable/disable the RX Quadrature Tracking. */
int32_t b9361_set_rx_quad_track_en_dis (struct b9361_rf_phy *phy,
		uint8_t en_dis);
/* Get the status of the RX Quadrature Tracking. */
int32_t b9361_get_rx_quad_track_en_dis (struct b9361_rf_phy *phy,
		uint8_t *en_dis);
/* Set the RX RF input port. */
int32_t b9361_set_rx_rf_port_input (struct b9361_rf_phy *phy, uint32_t mode);
/* Get the selected RX RF input port. */
int32_t b9361_get_rx_rf_port_input (struct b9361_rf_phy *phy, uint32_t *mode);
/* Store RX fastlock profile. */
int32_t b9361_rx_fastlock_store(struct b9361_rf_phy *phy, uint32_t profile);
/* Recall RX fastlock profile. */
int32_t b9361_rx_fastlock_recall(struct b9361_rf_phy *phy, uint32_t profile);
/* Load RX fastlock profile. */
int32_t b9361_rx_fastlock_load(struct b9361_rf_phy *phy, uint32_t profile,
				uint8_t *values);
/* Save RX fastlock profile. */
int32_t b9361_rx_fastlock_save(struct b9361_rf_phy *phy, uint32_t profile,
				uint8_t *values);
/* Power down the RX Local Oscillator. */
int32_t b9361_rx_lo_powerdown(struct b9361_rf_phy *phy, uint8_t option);
/* Get the RX Local Oscillator power status. */
int32_t b9361_get_rx_lo_power(struct b9361_rf_phy *phy, uint8_t *option);
/* Set the transmit attenuation for the selected channel. */
int32_t b9361_set_tx_attenuation (struct b9361_rf_phy *phy, uint8_t ch,
				   uint32_t attenuation_mdb);
/* Get current transmit attenuation for the selected channel. */
int32_t b9361_get_tx_attenuation (struct b9361_rf_phy *phy, uint8_t ch,
				   uint32_t *attenuation_mdb);
/* Set the TX RF bandwidth. */
int32_t b9361_set_tx_rf_bandwidth (struct b9361_rf_phy *phy,
				    uint32_t bandwidth_hz);
/* Get the TX RF bandwidth. */
int32_t b9361_get_tx_rf_bandwidth (struct b9361_rf_phy *phy,
				    uint32_t *bandwidth_hz);
/* Set the TX sampling frequency. */
int32_t b9361_set_tx_sampling_freq (struct b9361_rf_phy *phy,
				     uint32_t sampling_freq_hz);
/* Get current TX sampling frequency. */
int32_t b9361_get_tx_sampling_freq (struct b9361_rf_phy *phy,
				     uint32_t *sampling_freq_hz);
/* Set the TX LO frequency. */
int32_t b9361_set_tx_lo_freq (struct b9361_rf_phy *phy, uint64_t lo_freq_hz);
/* Get current TX LO frequency. */
int32_t b9361_get_tx_lo_freq (struct b9361_rf_phy *phy, uint64_t *lo_freq_hz);
/* Switch between internal and external LO. */
int32_t b9361_set_tx_lo_int_ext(struct b9361_rf_phy *phy, uint8_t int_ext);
/* Set the TX FIR filter configuration. */
int32_t b9361_set_tx_fir_config (struct b9361_rf_phy *phy,
				  B9361_TXFIRConfig fir_cfg);
/* Get the TX FIR filter configuration. */
int32_t b9361_get_tx_fir_config(struct b9361_rf_phy *phy, uint8_t tx_ch,
				 B9361_TXFIRConfig *fir_cfg);
/* Enable/disable the TX FIR filter. */
int32_t b9361_set_tx_fir_en_dis (struct b9361_rf_phy *phy, uint8_t en_dis);
/* Get the status of the TX FIR filter. */
int32_t b9361_get_tx_fir_en_dis (struct b9361_rf_phy *phy, uint8_t *en_dis);
/* Get the TX RSSI for the selected channel. */
int32_t b9361_get_tx_rssi (struct b9361_rf_phy *phy, uint8_t ch,
			    uint32_t *rssi_db_x_1000);
/* Set the TX RF output port. */
int32_t b9361_set_tx_rf_port_output (struct b9361_rf_phy *phy, uint32_t mode);
/* Get the selected TX RF output port. */
int32_t b9361_get_tx_rf_port_output (struct b9361_rf_phy *phy,
				      uint32_t *mode);
/* Enable/disable the auto calibration. */
int32_t b9361_set_tx_auto_cal_en_dis (struct b9361_rf_phy *phy,
				       uint8_t en_dis);
/* Get the status of the auto calibration flag. */
int32_t b9361_get_tx_auto_cal_en_dis (struct b9361_rf_phy *phy,
				       uint8_t *en_dis);
/* Store TX fastlock profile. */
int32_t b9361_tx_fastlock_store(struct b9361_rf_phy *phy, uint32_t profile);
/* Recall TX fastlock profile. */
int32_t b9361_tx_fastlock_recall(struct b9361_rf_phy *phy, uint32_t profile);
/* Load TX fastlock profile. */
int32_t b9361_tx_fastlock_load(struct b9361_rf_phy *phy, uint32_t profile,
				uint8_t *values);
/* Save TX fastlock profile. */
int32_t b9361_tx_fastlock_save(struct b9361_rf_phy *phy, uint32_t profile,
				uint8_t *values);
/* Power down the TX Local Oscillator. */
int32_t b9361_tx_lo_powerdown(struct b9361_rf_phy *phy, uint8_t option);
/* Get the TX Local Oscillator power status. */
int32_t b9361_get_tx_lo_power(struct b9361_rf_phy *phy, uint8_t *option);
/* Set the RX and TX path rates. */
int32_t b9361_set_trx_path_clks(struct b9361_rf_phy *phy,
				 uint32_t *rx_path_clks, uint32_t *tx_path_clks);
/* Get the RX and TX path rates. */
int32_t b9361_get_trx_path_clks(struct b9361_rf_phy *phy,
				 uint32_t *rx_path_clks, uint32_t *tx_path_clks);
/* Set the number of channels mode. */
int32_t b9361_set_no_ch_mode(struct b9361_rf_phy *phy, uint8_t no_ch_mode);
/* Do multi chip synchronization. */
int32_t b9361_do_mcs(struct b9361_rf_phy *phy_master,
		      struct b9361_rf_phy *phy_slave);
/* Enable/disable the TRX FIR filters. */
int32_t b9361_set_trx_fir_en_dis (struct b9361_rf_phy *phy, uint8_t en_dis);
/* Set the OSR rate governor. */
int32_t b9361_set_trx_rate_gov (struct b9361_rf_phy *phy, uint32_t rate_gov);
/* Get the OSR rate governor. */
int32_t b9361_get_trx_rate_gov (struct b9361_rf_phy *phy, uint32_t *rate_gov);
/* Perform the selected calibration. */
int32_t b9361_do_calib(struct b9361_rf_phy *phy, uint32_t cal, int32_t arg);
/* Load and enable TRX FIR filters configurations. */
int32_t b9361_trx_load_enable_fir(struct b9361_rf_phy *phy,
				   B9361_RXFIRConfig rx_fir_cfg,
				   B9361_TXFIRConfig tx_fir_cfg);
/* Do DCXO coarse tuning. */
int32_t b9361_do_dcxo_tune_coarse(struct b9361_rf_phy *phy,
				   uint32_t coarse);
/* Do DCXO fine tuning. */
int32_t b9361_do_dcxo_tune_fine(struct b9361_rf_phy *phy,
				 uint32_t fine);
/* Get the temperature. */
int32_t b9361_get_temperature(struct b9361_rf_phy *phy,
			       int32_t *temp);
#endif
