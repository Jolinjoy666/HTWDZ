/***************************************************************************//**
 *   @file   main.c
 *   @brief  Implementation of Main Function.
*******************************************************************************/

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include "b9361_api.h"
#include "config.h"
#include "parameters.h"
#include "platform.h"
#ifdef CONSOLE_COMMANDS
#include "command.h"
#include "console.h"
#endif
#ifdef XILINX_PLATFORM
#include <xil_cache.h>
#endif
#if defined XILINX_PLATFORM || defined LINUX_PLATFORM || defined ALTERA_PLATFORM
#include "adc_core.h"
#include "dac_core.h"
#endif

#include "b9361.h"





/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/
#ifdef CONSOLE_COMMANDS
extern command	  	cmd_list[];
extern char			cmd_no;
extern cmd_function	cmd_functions[11];
unsigned char		cmd				 =  0;
double				param[5]		 = {0, 0, 0, 0, 0};
char				param_no		 =  0;
int					cmd_type		 = -1;
char				invalid_cmd		 =  0;
char				received_cmd[30] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
										0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
										0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
#endif

B9361_InitParam default_init_param = {
	/* Device selection */
	ID_B9361,	// dev_sel
	/* Identification number */
	0,		//id_no
	/* Reference Clock */
	40000000UL,	//reference_clk_rate
	/* Base Configuration */
	1,		//two_rx_two_tx_mode_enable *** bmti,2rx-2tx-mode-enable
	1,		//one_rx_one_tx_mode_use_rx_num *** bmti,1rx-1tx-mode-use-rx-num
	1,		//one_rx_one_tx_mode_use_tx_num *** bmti,1rx-1tx-mode-use-tx-num
	1,		//frequency_division_duplex_mode_enable *** bmti,frequency-division-duplex-mode-enable
	0,		//frequency_division_duplex_independent_mode_enable *** bmti,frequency-division-duplex-independent-mode-enable
	0,		//tdd_use_dual_synth_mode_enable *** bmti,tdd-use-dual-synth-mode-enable
	0,		//tdd_skip_vco_cal_enable *** bmti,tdd-skip-vco-cal-enable
	0,		//tx_fastlock_delay_ns *** bmti,tx-fastlock-delay-ns
	0,		//rx_fastlock_delay_ns *** bmti,rx-fastlock-delay-ns
	0,		//rx_fastlock_pincontrol_enable *** bmti,rx-fastlock-pincontrol-enable
	0,		//tx_fastlock_pincontrol_enable *** bmti,tx-fastlock-pincontrol-enable
	0,		//external_rx_lo_enable *** bmti,external-rx-lo-enable
	0,		//external_tx_lo_enable *** bmti,external-tx-lo-enable
	5,		//dc_offset_tracking_update_event_mask *** bmti,dc-offset-tracking-update-event-mask
	6,		//dc_offset_attenuation_high_range *** bmti,dc-offset-attenuation-high-range
	5,		//dc_offset_attenuation_low_range *** bmti,dc-offset-attenuation-low-range
	0x28,	//dc_offset_count_high_range *** bmti,dc-offset-count-high-range
	0x32,	//dc_offset_count_low_range *** bmti,dc-offset-count-low-range
	0,		//split_gain_table_mode_enable *** bmti,split-gain-table-mode-enable
	MAX_SYNTH_FREF,	//trx_synthesizer_target_fref_overwrite_hz *** bmti,trx-synthesizer-target-fref-overwrite-hz
	0,		// qec_tracking_slow_mode_enable *** bmti,qec-tracking-slow-mode-enable
	/* ENSM Control */
	0,		//ensm_enable_pin_pulse_mode_enable *** bmti,ensm-enable-pin-pulse-mode-enable
	0,		//ensm_enable_txnrx_control_enable *** bmti,ensm-enable-txnrx-control-enable
	/* LO Control */
	2400000000UL,	//rx_synthesizer_frequency_hz *** bmti,rx-synthesizer-frequency-hz
	2400000000UL,	//tx_synthesizer_frequency_hz *** bmti,tx-synthesizer-frequency-hz
	1,				//tx_lo_powerdown_managed_enable *** bmti,tx-lo-powerdown-managed-enable
	/* Rate & BW Control */
//	{983040000, 245760000, 122880000, 61440000, 30720000, 15360000},// rx_path_clock_frequencies[6] *** bmti,rx-path-clock-frequencies
//	{983040000, 122880000, 122880000, 61440000, 30720000, 15360000},// tx_path_clock_frequencies[6] *** bmti,tx-path-clock-frequencies
	{983040000, 245760000, 122880000, 61440000, 30720000, 30720000},// rx_path_clock_frequencies[6] *** bmti,rx-path-clock-frequencies
	{983040000, 122880000, 122880000, 61440000, 30720000, 30720000},// tx_path_clock_frequencies[6] *** bmti,tx-path-clock-frequencies

	10000000,//rf_rx_bandwidth_hz *** bmti,rf-rx-bandwidth-hz
	10000000,//rf_tx_bandwidth_hz *** bmti,rf-tx-bandwidth-hz
	/* RF Port Control */
	0,		//rx_rf_port_input_select *** bmti,rx-rf-port-input-select
	0,		//tx_rf_port_input_select *** bmti,tx-rf-port-input-select
	/* TX Attenuation Control */
	20000,	//tx_attenuation_mdB *** bmti,tx-attenuation-mdB
	0,		//update_tx_gain_in_alert_enable *** bmti,update-tx-gain-in-alert-enable
	/* Reference Clock Control */
	0,		//xo_disable_use_ext_refclk_enable *** bmti,xo-disable-use-ext-refclk-enable
	{8, 5920},	//dcxo_coarse_and_fine_tune[2] *** bmti,dcxo-coarse-and-fine-tune
	CLKOUT_DISABLE,	//clk_output_mode_select *** bmti,clk-output-mode-select
	/* Gain Control */
	2,		//gc_rx1_mode *** bmti,gc-rx1-mode
	2,		//gc_rx2_mode *** bmti,gc-rx2-mode
	58,		//gc_adc_large_overload_thresh *** bmti,gc-adc-large-overload-thresh
	4,		//gc_adc_ovr_sample_size *** bmti,gc-adc-ovr-sample-size
	47,		//gc_adc_small_overload_thresh *** bmti,gc-adc-small-overload-thresh
	8192,	//gc_dec_pow_measurement_duration *** bmti,gc-dec-pow-measurement-duration
	0,		//gc_dig_gain_enable *** bmti,gc-dig-gain-enable
	800,	//gc_lmt_overload_high_thresh *** bmti,gc-lmt-overload-high-thresh
	704,	//gc_lmt_overload_low_thresh *** bmti,gc-lmt-overload-low-thresh
	24,		//gc_low_power_thresh *** bmti,gc-low-power-thresh
	15,		//gc_max_dig_gain *** bmti,gc-max-dig-gain
	/* Gain MGC Control */
	2,		//mgc_dec_gain_step *** bmti,mgc-dec-gain-step
	2,		//mgc_inc_gain_step *** bmti,mgc-inc-gain-step
	0,		//mgc_rx1_ctrl_inp_enable *** bmti,mgc-rx1-ctrl-inp-enable
	0,		//mgc_rx2_ctrl_inp_enable *** bmti,mgc-rx2-ctrl-inp-enable
	0,		//mgc_split_table_ctrl_inp_gain_mode *** bmti,mgc-split-table-ctrl-inp-gain-mode
	/* Gain AGC Control */
	10,		//agc_adc_large_overload_exceed_counter *** bmti,agc-adc-large-overload-exceed-counter
	2,		//agc_adc_large_overload_inc_steps *** bmti,agc-adc-large-overload-inc-steps
	0,		//agc_adc_lmt_small_overload_prevent_gain_inc_enable *** bmti,agc-adc-lmt-small-overload-prevent-gain-inc-enable
	10,		//agc_adc_small_overload_exceed_counter *** bmti,agc-adc-small-overload-exceed-counter
	4,		//agc_dig_gain_step_size *** bmti,agc-dig-gain-step-size
	3,		//agc_dig_saturation_exceed_counter *** bmti,agc-dig-saturation-exceed-counter
	1000,	// agc_gain_update_interval_us *** bmti,agc-gain-update-interval-us
	0,		//agc_immed_gain_change_if_large_adc_overload_enable *** bmti,agc-immed-gain-change-if-large-adc-overload-enable
	0,		//agc_immed_gain_change_if_large_lmt_overload_enable *** bmti,agc-immed-gain-change-if-large-lmt-overload-enable
	10,		//agc_inner_thresh_high *** bmti,agc-inner-thresh-high
	1,		//agc_inner_thresh_high_dec_steps *** bmti,agc-inner-thresh-high-dec-steps
	12,		//agc_inner_thresh_low *** bmti,agc-inner-thresh-low
	1,		//agc_inner_thresh_low_inc_steps *** bmti,agc-inner-thresh-low-inc-steps
	10,		//agc_lmt_overload_large_exceed_counter *** bmti,agc-lmt-overload-large-exceed-counter
	2,		//agc_lmt_overload_large_inc_steps *** bmti,agc-lmt-overload-large-inc-steps
	10,		//agc_lmt_overload_small_exceed_counter *** bmti,agc-lmt-overload-small-exceed-counter
	5,		//agc_outer_thresh_high *** bmti,agc-outer-thresh-high
	2,		//agc_outer_thresh_high_dec_steps *** bmti,agc-outer-thresh-high-dec-steps
	18,		//agc_outer_thresh_low *** bmti,agc-outer-thresh-low
	2,		//agc_outer_thresh_low_inc_steps *** bmti,agc-outer-thresh-low-inc-steps
	1,		//agc_attack_delay_extra_margin_us; *** bmti,agc-attack-delay-extra-margin-us
	0,		//agc_sync_for_gain_counter_enable *** bmti,agc-sync-for-gain-counter-enable
	/* Fast AGC */
	64,		//fagc_dec_pow_measuremnt_duration ***  bmti,fagc-dec-pow-measurement-duration
	260,	//fagc_state_wait_time_ns ***  bmti,fagc-state-wait-time-ns
	/* Fast AGC - Low Power */
	0,		//fagc_allow_agc_gain_increase ***  bmti,fagc-allow-agc-gain-increase-enable
	5,		//fagc_lp_thresh_increment_time ***  bmti,fagc-lp-thresh-increment-time
	1,		//fagc_lp_thresh_increment_steps ***  bmti,fagc-lp-thresh-increment-steps
	/* Fast AGC - Lock Level (Lock Level is set via slow AGC inner high threshold) */
	1,		//fagc_lock_level_lmt_gain_increase_en ***  bmti,fagc-lock-level-lmt-gain-increase-enable
	5,		//fagc_lock_level_gain_increase_upper_limit ***  bmti,fagc-lock-level-gain-increase-upper-limit
	/* Fast AGC - Peak Detectors and Final Settling */
	1,		//fagc_lpf_final_settling_steps ***  bmti,fagc-lpf-final-settling-steps
	1,		//fagc_lmt_final_settling_steps ***  bmti,fagc-lmt-final-settling-steps
	3,		//fagc_final_overrange_count ***  bmti,fagc-final-overrange-count
	/* Fast AGC - Final Power Test */
	0,		//fagc_gain_increase_after_gain_lock_en ***  bmti,fagc-gain-increase-after-gain-lock-enable
	/* Fast AGC - Unlocking the Gain */
	0,		//fagc_gain_index_type_after_exit_rx_mode ***  bmti,fagc-gain-index-type-after-exit-rx-mode
	1,		//fagc_use_last_lock_level_for_set_gain_en ***  bmti,fagc-use-last-lock-level-for-set-gain-enable
	1,		//fagc_rst_gla_stronger_sig_thresh_exceeded_en ***  bmti,fagc-rst-gla-stronger-sig-thresh-exceeded-enable
	5,		//fagc_optimized_gain_offset ***  bmti,fagc-optimized-gain-offset
	10,		//fagc_rst_gla_stronger_sig_thresh_above_ll ***  bmti,fagc-rst-gla-stronger-sig-thresh-above-ll
	1,		//fagc_rst_gla_engergy_lost_sig_thresh_exceeded_en ***  bmti,fagc-rst-gla-engergy-lost-sig-thresh-exceeded-enable
	1,		//fagc_rst_gla_engergy_lost_goto_optim_gain_en ***  bmti,fagc-rst-gla-engergy-lost-goto-optim-gain-enable
	10,		//fagc_rst_gla_engergy_lost_sig_thresh_below_ll ***  bmti,fagc-rst-gla-engergy-lost-sig-thresh-below-ll
	8,		//fagc_energy_lost_stronger_sig_gain_lock_exit_cnt ***  bmti,fagc-energy-lost-stronger-sig-gain-lock-exit-cnt
	1,		//fagc_rst_gla_large_adc_overload_en ***  bmti,fagc-rst-gla-large-adc-overload-enable
	1,		//fagc_rst_gla_large_lmt_overload_en ***  bmti,fagc-rst-gla-large-lmt-overload-enable
	0,		//fagc_rst_gla_en_agc_pulled_high_en ***  bmti,fagc-rst-gla-en-agc-pulled-high-enable
	0,		//fagc_rst_gla_if_en_agc_pulled_high_mode ***  bmti,fagc-rst-gla-if-en-agc-pulled-high-mode
	64,		//fagc_power_measurement_duration_in_state5 ***  bmti,fagc-power-measurement-duration-in-state5
	/* RSSI Control */
	1,		//rssi_delay *** bmti,rssi-delay
	1000,	//rssi_duration *** bmti,rssi-duration
	3,		//rssi_restart_mode *** bmti,rssi-restart-mode
	0,		//rssi_unit_is_rx_samples_enable *** bmti,rssi-unit-is-rx-samples-enable
	1,		//rssi_wait *** bmti,rssi-wait
	/* Aux ADC Control */
	256,	//aux_adc_decimation *** bmti,aux-adc-decimation
	40000000UL,	//aux_adc_rate *** bmti,aux-adc-rate
	/* AuxDAC Control */
	1,		//aux_dac_manual_mode_enable ***  bmti,aux-dac-manual-mode-enable
	0,		//aux_dac1_default_value_mV ***  bmti,aux-dac1-default-value-mV
	0,		//aux_dac1_active_in_rx_enable ***  bmti,aux-dac1-active-in-rx-enable
	0,		//aux_dac1_active_in_tx_enable ***  bmti,aux-dac1-active-in-tx-enable
	0,		//aux_dac1_active_in_alert_enable ***  bmti,aux-dac1-active-in-alert-enable
	0,		//aux_dac1_rx_delay_us ***  bmti,aux-dac1-rx-delay-us
	0,		//aux_dac1_tx_delay_us ***  bmti,aux-dac1-tx-delay-us
	0,		//aux_dac2_default_value_mV ***  bmti,aux-dac2-default-value-mV
	0,		//aux_dac2_active_in_rx_enable ***  bmti,aux-dac2-active-in-rx-enable
	0,		//aux_dac2_active_in_tx_enable ***  bmti,aux-dac2-active-in-tx-enable
	0,		//aux_dac2_active_in_alert_enable ***  bmti,aux-dac2-active-in-alert-enable
	0,		//aux_dac2_rx_delay_us ***  bmti,aux-dac2-rx-delay-us
	0,		//aux_dac2_tx_delay_us ***  bmti,aux-dac2-tx-delay-us
	/* Temperature Sensor Control */
	256,	//temp_sense_decimation *** bmti,temp-sense-decimation
	1000,	//temp_sense_measurement_interval_ms *** bmti,temp-sense-measurement-interval-ms
	0xCE,	//temp_sense_offset_signed *** bmti,temp-sense-offset-signed
	1,		//temp_sense_periodic_measurement_enable *** bmti,temp-sense-periodic-measurement-enable
	/* Control Out Setup */
	0xFF,	//ctrl_outs_enable_mask *** bmti,ctrl-outs-enable-mask
	0,		//ctrl_outs_index *** bmti,ctrl-outs-index
	/* External LNA Control */
	0,		//elna_settling_delay_ns *** bmti,elna-settling-delay-ns
	0,		//elna_gain_mdB *** bmti,elna-gain-mdB
	0,		//elna_bypass_loss_mdB *** bmti,elna-bypass-loss-mdB
	0,		//elna_rx1_gpo0_control_enable *** bmti,elna-rx1-gpo0-control-enable
	0,		//elna_rx2_gpo1_control_enable *** bmti,elna-rx2-gpo1-control-enable
	0,		//elna_gaintable_all_index_enable *** bmti,elna-gaintable-all-index-enable
	/* Digital Interface Control */
	2,		//digital_interface_tune_skip_mode *** bmti,digital-interface-tune-skip-mode
	0,		//digital_interface_tune_fir_disable *** bmti,digital-interface-tune-fir-disable
	1,		//pp_tx_swap_enable *** bmti,pp-tx-swap-enable
	1,		//pp_rx_swap_enable *** bmti,pp-rx-swap-enable
	0,		//tx_channel_swap_enable *** bmti,tx-channel-swap-enable
	0,		//rx_channel_swap_enable *** bmti,rx-channel-swap-enable
	1,		//rx_frame_pulse_mode_enable *** bmti,rx-frame-pulse-mode-enable
	0,		//two_t_two_r_timing_enable *** bmti,2t2r-timing-enable
	0,		//invert_data_bus_enable *** bmti,invert-data-bus-enable
	0,		//invert_data_clk_enable *** bmti,invert-data-clk-enable
	0,		//fdd_alt_word_order_enable *** bmti,fdd-alt-word-order-enable
	0,		//invert_rx_frame_enable *** bmti,invert-rx-frame-enable
	0,		//fdd_rx_rate_2tx_enable *** bmti,fdd-rx-rate-2tx-enable
	0,		//swap_ports_enable *** bmti,swap-ports-enable
	0,		//single_data_rate_enable *** bmti,single-data-rate-enable
	1,		//lvds_mode_enable *** bmti,lvds-mode-enable
	0,		//half_duplex_mode_enable *** bmti,half-duplex-mode-enable
	0,		//single_port_mode_enable *** bmti,single-port-mode-enable
	0,		//full_port_enable *** bmti,full-port-enable
	0,		//full_duplex_swap_bits_enable *** bmti,full-duplex-swap-bits-enable
	0,		//delay_rx_data *** bmti,delay-rx-data
	0,		//rx_data_clock_delay *** bmti,rx-data-clock-delay
	4,		//rx_data_delay *** bmti,rx-data-delay
	7,		//tx_fb_clock_delay *** bmti,tx-fb-clock-delay
	0,		//tx_data_delay *** bmti,tx-data-delay
#ifdef ALTERA_PLATFORM
	300,	//lvds_bias_mV *** bmti,lvds-bias-mV
#else
	150,	//lvds_bias_mV *** bmti,lvds-bias-mV
#endif
	1,		//lvds_rx_onchip_termination_enable *** bmti,lvds-rx-onchip-termination-enable
	0,		//rx1rx2_phase_inversion_en *** bmti,rx1-rx2-phase-inversion-enable
	0xFF,	//lvds_invert1_control *** bmti,lvds-invert1-control
	0x0F,	//lvds_invert2_control *** bmti,lvds-invert2-control
	/* GPO Control */
	0,		//gpo0_inactive_state_high_enable *** bmti,gpo0-inactive-state-high-enable
	0,		//gpo1_inactive_state_high_enable *** bmti,gpo1-inactive-state-high-enable
	0,		//gpo2_inactive_state_high_enable *** bmti,gpo2-inactive-state-high-enable
	0,		//gpo3_inactive_state_high_enable *** bmti,gpo3-inactive-state-high-enable
	0,		//gpo0_slave_rx_enable *** bmti,gpo0-slave-rx-enable
	0,		//gpo0_slave_tx_enable *** bmti,gpo0-slave-tx-enable
	0,		//gpo1_slave_rx_enable *** bmti,gpo1-slave-rx-enable
	0,		//gpo1_slave_tx_enable *** bmti,gpo1-slave-tx-enable
	0,		//gpo2_slave_rx_enable *** bmti,gpo2-slave-rx-enable
	0,		//gpo2_slave_tx_enable *** bmti,gpo2-slave-tx-enable
	0,		//gpo3_slave_rx_enable *** bmti,gpo3-slave-rx-enable
	0,		//gpo3_slave_tx_enable *** bmti,gpo3-slave-tx-enable
	0,		//gpo0_rx_delay_us *** bmti,gpo0-rx-delay-us
	0,		//gpo0_tx_delay_us *** bmti,gpo0-tx-delay-us
	0,		//gpo1_rx_delay_us *** bmti,gpo1-rx-delay-us
	0,		//gpo1_tx_delay_us *** bmti,gpo1-tx-delay-us
	0,		//gpo2_rx_delay_us *** bmti,gpo2-rx-delay-us
	0,		//gpo2_tx_delay_us *** bmti,gpo2-tx-delay-us
	0,		//gpo3_rx_delay_us *** bmti,gpo3-rx-delay-us
	0,		//gpo3_tx_delay_us *** bmti,gpo3-tx-delay-us
	/* Tx Monitor Control */
	37000,	//low_high_gain_threshold_mdB *** bmti,txmon-low-high-thresh
	0,		//low_gain_dB *** bmti,txmon-low-gain
	24,		//high_gain_dB *** bmti,txmon-high-gain
	0,		//tx_mon_track_en *** bmti,txmon-dc-tracking-enable
	0,		//one_shot_mode_en *** bmti,txmon-one-shot-mode-enable
	511,	//tx_mon_delay *** bmti,txmon-delay
	8192,	//tx_mon_duration *** bmti,txmon-duration
	2,		//tx1_mon_front_end_gain *** bmti,txmon-1-front-end-gain
	2,		//tx2_mon_front_end_gain *** bmti,txmon-2-front-end-gain
	48,		//tx1_mon_lo_cm *** bmti,txmon-1-lo-cm
	48,		//tx2_mon_lo_cm *** bmti,txmon-2-lo-cm
	/* GPIO definitions */
	-1,		//gpio_resetb *** reset-gpios
	/* MCS Sync */
	-1,		//gpio_sync *** sync-gpios
	-1,		//gpio_cal_sw1 *** cal-sw1-gpios
	-1,		//gpio_cal_sw2 *** cal-sw2-gpios
	/* External LO clocks */
	NULL,	//(*b9361_rfpll_ext_recalc_rate)()
	NULL,	//(*b9361_rfpll_ext_round_rate)()
	NULL	//(*b9361_rfpll_ext_set_rate)()
};

B9361_RXFIRConfig rx_fir_config = {	// BPF PASSBAND 3/20 fs to 1/4 fs
	3, // rx
	0, // rx_gain
	2, // rx_dec
	{
	-9,-4,-4,20,35,46,24,-10,-40,-31,10,55,55,3,
	-67,-85,-23,76,122,56,-80,-164,-102,74,211,164,
	-55,-260,-244,17,307,343,44,-349,-462,-135,379,602,
	264,-390,-764,-440,373,950,677,-315,-1162,-997,194,
	1409,1440,27,-1706,-2085,-424,2091,3123,1178,-2724,
	-5257,-3053,4545,14417,21330,21330,14417,4545,-3053,
	-5257,-2724,1178,3123,2091,-424,-2085,-1706,27,1440,
	1409,194,-997,-1162,-315,677,950,373,-440,-764,-390,
	264,602,379,-135,-462,-349,44,343,307,17,-244,-260,-55,
	164,211,74,-102,-164,-80,56,122,76,-23,-85,-67,3,55,55,
	10,-31,-40,-10,24,46,35,20,-4,-4,-9
	}, // rx_coef[128]
	 128, // rx_coef_size
	 {983040000, 245760000, 122880000, 61440000, 30720000, 15360000}, // tx_path_clks[6]
	 10000000 // tx_bandwidth
};

B9361_TXFIRConfig tx_fir_config = {	// BPF PASSBAND 3/20 fs to 1/4 fs
	3, // tx
	-6, // tx_gain
	2, // tx_int
	{
	-9,-4,-4,20,35,46,24,-10,-40,-31,10,55,55,3,
	-67,-85,-23,76,122,56,-80,-164,-102,74,211,164,
	-55,-260,-244,17,307,343,44,-349,-462,-135,379,602,
	264,-390,-764,-440,373,950,677,-315,-1162,-997,194,
	1409,1440,27,-1706,-2085,-424,2091,3123,1178,-2724,
	-5257,-3053,4545,14417,21330,21330,14417,4545,-3053,
	-5257,-2724,1178,3123,2091,-424,-2085,-1706,27,1440,
	1409,194,-997,-1162,-315,677,950,373,-440,-764,-390,
	264,602,379,-135,-462,-349,44,343,307,17,-244,-260,-55,
	164,211,74,-102,-164,-80,56,122,76,-23,-85,-67,3,55,55,
	10,-31,-40,-10,24,46,35,20,-4,-4,-9
	}, // tx_coef[128]
	 128, // tx_coef_size
	 {983040000, 245760000, 122880000, 61440000, 30720000, 15360000}, // tx_path_clks[6]
	 10000000 // tx_bandwidth
};
struct b9361_rf_phy *b9361_phy;
#ifdef FMCOMMS5
struct b9361_rf_phy *b9361_phy_b;
#endif

/***************************************************************************//**
 * @brief main
*******************************************************************************/
int main(void)
{
#ifdef XILINX_PLATFORM
	Xil_ICacheEnable();
	Xil_DCacheEnable();
#endif

#ifdef ALTERA_PLATFORM
	if (altera_bridge_init()) {
		printf("Altera Bridge Init Error!\n");
		return -1;
	}
#endif

	// NOTE: The user has to choose the GPIO numbers according to desired
	// carrier board.
	default_init_param.gpio_resetb = GPIO_RESET_PIN;
#ifdef FMCOMMS5
	default_init_param.gpio_sync = GPIO_SYNC_PIN;
	default_init_param.gpio_cal_sw1 = GPIO_CAL_SW1_PIN;
	default_init_param.gpio_cal_sw2 = GPIO_CAL_SW2_PIN;
	default_init_param.rx1rx2_phase_inversion_en = 1;
#else
	default_init_param.gpio_sync = -1;
	default_init_param.gpio_cal_sw1 = -1;
	default_init_param.gpio_cal_sw2 = -1;
#endif

#ifdef LINUX_PLATFORM
	gpio_init(default_init_param.gpio_resetb);
#else
	gpio_init(GPIO_DEVICE_ID);
#endif
	gpio_direction(default_init_param.gpio_resetb, 1);

	spi_init(SPI_DEVICE_ID, 1, 0);

	if (B9364_DEVICE)
		default_init_param.dev_sel = ID_B9364;
	if (B9363A_DEVICE)
		default_init_param.dev_sel = ID_B9363A;

#if defined FMCOMMS5 || defined BMTI_RF_SOM || defined BMTI_RF_SOM_CMOS
	default_init_param.xo_disable_use_ext_refclk_enable = 1;
#endif

#ifdef BMTI_RF_SOM_CMOS
	default_init_param.swap_ports_enable = 1;
	default_init_param.lvds_mode_enable = 0;
	default_init_param.lvds_rx_onchip_termination_enable = 0;
	default_init_param.full_port_enable = 1;
	default_init_param.digital_interface_tune_fir_disable = 1;
#endif



	b9361_init(&b9361_phy, &default_init_param);
	//b9361_spi_write(b9361_phy->spi, 0x004, 0x43);
	//printf("004= %x \n",b9361_spi_read(b9361_phy->spi, 0x004));
    //	b9361_spi_write(b9361_phy->spi, 0x000, 0x00);
    // 	b9361_spi_write(b9361_phy->spi, 0x3f4, 0x3b);
	dac_init(b9361_phy, DATA_SEL_DMA, 1);
	b9361_spi_write(b9361_phy->spi, 0x3f4, 0x0);
	b9361_spi_write(b9361_phy->spi, 0x3f5, 0x0);
	b9361_spi_write(b9361_phy->spi, 0x3f6, 0x0);
    //	b9361_trx_load_enable_fir(b9361_phy, rx_fir_config,tx_fir_config);
	//b9361_set_tx_fir_config(b9361_phy, tx_fir_config);
	//b9361_set_rx_fir_config(b9361_phy, rx_fir_config);

//	u8 X;
//	X = b9361_spi_read(b9361_phy->spi, 0x0A1);
//	printf("0A1 = %x \n",X);
//	b9361_spi_write(b9361_phy->spi, 0x0A1, 0xE3);
//
//	X = b9361_spi_read(b9361_phy->spi, 0x0A1);
//	printf("0A1 = %x \n",X);
//
//
//	X = b9361_spi_read(b9361_phy->spi, 0x0A0);
//	printf("0A1 = %x \n",X);
//	b9361_spi_write(b9361_phy->spi, 0x0A0, 0x00);






//	b9361_bist_tone(b9361_phy,
//			BIST_INJ_RX, uint32_t freq_Hz,
//				 uint32_t level_dB, uint32_t mask)
//	b9361_bist_prbs(b9361_phy,BIST_INJ_RX);
//
//	while(1){
//
//
//
//
//	}


#ifdef FMCOMMS5
#ifdef LINUX_PLATFORM
	gpio_init(default_init_param.gpio_sync);
#endif
	gpio_direction(default_init_param.gpio_sync, 1);
	default_init_param.id_no = 1;
	default_init_param.gpio_resetb = GPIO_RESET_PIN_2;
#ifdef LINUX_PLATFORM
	gpio_init(default_init_param.gpio_resetb);
#endif
	default_init_param.gpio_sync = -1;
	default_init_param.gpio_cal_sw1 = -1;
	default_init_param.gpio_cal_sw2 = -1;
	default_init_param.rx_synthesizer_frequency_hz = 2300000000UL;
	default_init_param.tx_synthesizer_frequency_hz = 2300000000UL;
	gpio_direction(default_init_param.gpio_resetb, 1);
	b9361_init(&b9361_phy_b, &default_init_param);

	b9361_set_tx_fir_config(b9361_phy_b, tx_fir_config);
	b9361_set_rx_fir_config(b9361_phy_b, rx_fir_config);
#endif

#ifndef AXI_ADC_NOT_PRESENT
#if defined XILINX_PLATFORM || defined LINUX_PLATFORM || defined ALTERA_PLATFORM
#ifdef DAC_DMA_EXAMPLE
#ifdef FMCOMMS5
	dac_init(b9361_phy_b, DATA_SEL_DMA, 0);
#endif
	dac_init(b9361_phy, DATA_SEL_DMA, 1);
#else
#ifdef FMCOMMS5
	dac_init(b9361_phy_b, DATA_SEL_DDS, 0);
#endif
	dac_init(b9361_phy, DATA_SEL_DDS, 1);

//	b9361_spi_write(b9361_phy->spi, 0x3F4, 0x3);
#endif
#endif
#endif

#ifdef FMCOMMS5
	b9361_do_mcs(b9361_phy, b9361_phy_b);
#endif

#ifndef AXI_ADC_NOT_PRESENT
#if (defined XILINX_PLATFORM || defined ALTERA_PLATFORM) && \
	(defined ADC_DMA_EXAMPLE || defined ADC_DMA_IRQ_EXAMPLE)
    // NOTE: To prevent unwanted data loss, it's recommended to invalidate
    // cache after each adc_capture() call, keeping in mind that the
    // size of the capture and the start address must be alinged to the size
    // of the cache line.
	mdelay(1000);
	adc_capture(16384, ADC_DDR_BASEADDR);
#ifdef XILINX_PLATFORM
#ifdef FMCOMMS5
	Xil_DCacheInvalidateRange(ADC_DDR_BASEADDR, 16384 * 16);
#else
	Xil_DCacheInvalidateRange(ADC_DDR_BASEADDR,
			b9361_phy->pdata->rx2tx2 ? 16384 * 8 : 16384 * 4);
#endif
#endif
#endif
#endif

#ifdef CONSOLE_COMMANDS
	get_help(NULL, 0);

	while(1)
	{
		console_get_command(received_cmd);
		invalid_cmd = 0;
		for(cmd = 0; cmd < cmd_no; cmd++)
		{
			param_no = 0;
			cmd_type = console_check_commands(received_cmd, cmd_list[cmd].name,
											  param, &param_no);
			if(cmd_type == UNKNOWN_CMD)
			{
				invalid_cmd++;
			}
			else
			{
				cmd_list[cmd].function(param, param_no);
			}
		}
		if(invalid_cmd == cmd_no)
		{
			console_print("Invalid command!\n");
		}
	}
#endif

	printf("Done.\n");

#ifdef TDD_SWITCH_STATE_EXAMPLE
	uint32_t ensm_mode;
	if (!b9361_phy->pdata->fdd) {
		if (b9361_phy->pdata->ensm_pin_ctrl) {
			gpio_direction(GPIO_ENABLE_PIN, 1);
			gpio_direction(GPIO_TXNRX_PIN, 1);
			gpio_set_value(GPIO_ENABLE_PIN, 0);
			gpio_set_value(GPIO_TXNRX_PIN, 0);
			udelay(10);
			b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
			printf("TXNRX control - Alert: %s\n",
					ensm_mode == ENSM_MODE_ALERT ? "OK" : "Error");
			mdelay(1000);

			if (b9361_phy->pdata->ensm_pin_pulse_mode) {
				while(1) {
					gpio_set_value(GPIO_TXNRX_PIN, 0);
					udelay(10);
					gpio_set_value(GPIO_ENABLE_PIN, 1);
					udelay(10);
					gpio_set_value(GPIO_ENABLE_PIN, 0);
					b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
					printf("TXNRX Pulse control - RX: %s\n",
							ensm_mode == ENSM_MODE_RX ? "OK" : "Error");
					mdelay(1000);

					gpio_set_value(GPIO_ENABLE_PIN, 1);
					udelay(10);
					gpio_set_value(GPIO_ENABLE_PIN, 0);
					b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
					printf("TXNRX Pulse control - Alert: %s\n",
							ensm_mode == ENSM_MODE_ALERT ? "OK" : "Error");
					mdelay(1000);

					gpio_set_value(GPIO_TXNRX_PIN, 1);
					udelay(10);
					gpio_set_value(GPIO_ENABLE_PIN, 1);
					udelay(10);
					gpio_set_value(GPIO_ENABLE_PIN, 0);
					b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
					printf("TXNRX Pulse control - TX: %s\n",
							ensm_mode == ENSM_MODE_TX ? "OK" : "Error");
					mdelay(1000);

					gpio_set_value(GPIO_ENABLE_PIN, 1);
					udelay(10);
					gpio_set_value(GPIO_ENABLE_PIN, 0);
					b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
					printf("TXNRX Pulse control - Alert: %s\n",
							ensm_mode == ENSM_MODE_ALERT ? "OK" : "Error");
					mdelay(1000);
				}
			} else {
				while(1) {
					gpio_set_value(GPIO_TXNRX_PIN, 0);
					udelay(10);
					gpio_set_value(GPIO_ENABLE_PIN, 1);
					udelay(10);
					b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
					printf("TXNRX control - RX: %s\n",
							ensm_mode == ENSM_MODE_RX ? "OK" : "Error");
					mdelay(1000);

					gpio_set_value(GPIO_ENABLE_PIN, 0);
					udelay(10);
					b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
					printf("TXNRX control - Alert: %s\n",
							ensm_mode == ENSM_MODE_ALERT ? "OK" : "Error");
					mdelay(1000);

					gpio_set_value(GPIO_TXNRX_PIN, 1);
					udelay(10);
					gpio_set_value(GPIO_ENABLE_PIN, 1);
					udelay(10);
					b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
					printf("TXNRX control - TX: %s\n",
							ensm_mode == ENSM_MODE_TX ? "OK" : "Error");
					mdelay(1000);

					gpio_set_value(GPIO_ENABLE_PIN, 0);
					udelay(10);
					b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
					printf("TXNRX control - Alert: %s\n",
							ensm_mode == ENSM_MODE_ALERT ? "OK" : "Error");
					mdelay(1000);
				}
			}
		} else {
			while(1) {
				b9361_set_en_state_machine_mode(b9361_phy, ENSM_MODE_RX);
				b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
				printf("SPI control - RX: %s\n",
						ensm_mode == ENSM_MODE_RX ? "OK" : "Error");
				mdelay(1000);

				b9361_set_en_state_machine_mode(b9361_phy, ENSM_MODE_ALERT);
				b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
				printf("SPI control - Alert: %s\n",
						ensm_mode == ENSM_MODE_ALERT ? "OK" : "Error");
				mdelay(1000);

				b9361_set_en_state_machine_mode(b9361_phy, ENSM_MODE_TX);
				b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
				printf("SPI control - TX: %s\n",
						ensm_mode == ENSM_MODE_TX ? "OK" : "Error");
				mdelay(1000);

				b9361_set_en_state_machine_mode(b9361_phy, ENSM_MODE_ALERT);
				b9361_get_en_state_machine_mode(b9361_phy, &ensm_mode);
				printf("SPI control - Alert: %s\n",
						ensm_mode == ENSM_MODE_ALERT ? "OK" : "Error");
				mdelay(1000);
			}
		}
	}
#endif

#ifdef XILINX_PLATFORM
	Xil_DCacheDisable();
	Xil_ICacheDisable();
#endif

#ifdef ALTERA_PLATFORM
	if (altera_bridge_uninit()) {
		printf("Altera Bridge Uninit Error!\n");
		return -1;
	}
#endif

	return 0;
}
