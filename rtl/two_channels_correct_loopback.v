module two_channels_correct_loopback(
    /*//系统时钟
    input                               sys_clk                    ,//系统时钟
    input                               sys_rst_n                  ,//系统复位
    //UART接口    
    input                               uart_rxd                   ,//UART接收端口
    output                              uart_txd                    //UART发送端口*/
  input                   sys_rst,
  input                   sys_clk_p,
  input                   sys_clk_n,

  input                   uart_sin,
  output                  uart_sout,
  output 				  fmc_vcc_enable,

  //inout       [16:0]      gpio_bd,

  input                   rx_clk_in_p,
  input                   rx_clk_in_n,
  input                   rx_frame_in_p,
  input                   rx_frame_in_n,
  input       [ 5:0]      rx_data_in_p,
  input       [ 5:0]      rx_data_in_n,

  output                  tx_clk_out_p,
  output                  tx_clk_out_n,
  output                  tx_frame_out_p,
  output                  tx_frame_out_n,
  output      [ 5:0]      tx_data_out_p,
  output      [ 5:0]      tx_data_out_n,

  inout                   gpio_resetb,
  inout                   gpio_sync,
  inout                   gpio_en_agc,
  inout       [ 3:0]      gpio_ctl,
  inout       [ 7:0]      gpio_status,

  output                  spi_csn_0,
  output                  spi_clk,
  output                  spi_mosi,
  input                   spi_miso);

//parameter define
parameter                               CLK_FREQ = 100000000       ;//定义系统时钟频率
parameter                               UART_BPS = 115200          ;//定义串口波特率

//wire define
wire                                    uart_rx_done               ;///UART接收完成
wire                   [   7:0]         uart_rx_data               ;///UART接收数据
wire                   [  11:0]         uart_recv_data_12b_a       ;//UART接收数据(12bit)
wire                   [  11:0]         uart_recv_data_12b_b       ;//UART接收数据(12bit)
wire                                    uart_recv_data_12b_valid   ;//UART接收数据有效信号

wire                                    tone_signal_wr_done        ;//输入单音信号完成信号
wire                                    qpsk_signal_wr_done        ;//输入qpsk信号完成信号
       
wire                                    tone_signal_rd_valid       ;//读单音信号有效信号
wire                                    qpsk_signal_rd_valid       ;//读QPSK信号有效信号
//单音校正输出参数
wire            signed [  11:0]         channel_phase_1            ;
wire            signed [  11:0]         channel_amplitude_1        ;
wire                                    channel_data_valid_1       ;
wire            signed [  11:0]         channel_phase_2            ;
wire            signed [  11:0]         channel_amplitude_2        ;
wire                                    channel_data_valid_2       ;

wire                   [  16:0]         signal_out_index_1         ;
wire                                    s_amp_phase_ready_1        ;
wire                                    uart_tx_start_1            ;
wire                   [  16:0]         signal_out_index_2         ;
wire                                    s_amp_phase_ready_2        ;
wire                                    uart_tx_start_2            ;

//UART模块控制信号
wire                                    qpsk_signal_wr_over        ;
wire                                    uart_tx_24_done            ;
wire                   [  11:0]         qpsk_signal_out_a          ;
wire                   [  11:0]         qpsk_signal_out_b          ;
//qpsk_signal_out_1
wire            signed [  11:0]         qpsk_signal_out_i_1        ;
wire            signed [  11:0]         qpsk_signal_out_q_1        ;
wire                                    qpsk_signal_out_valid_1    ;
//qpsk_signal_out_2
wire            signed [  11:0]         qpsk_signal_out_i_2        ;
wire            signed [  11:0]         qpsk_signal_out_q_2        ;
wire                                    qpsk_signal_out_valid_2    ;

//bram_tone_1
wire                   [   9:0]         ram_addr_a_1               ;//BRAM读写地址a
wire                   [   9:0]         ram_addr_b_1               ;//BRAM读写地址b
wire                   [  11:0]         ram_wr_data_a_1            ;//BRAM写数据a
wire                   [  11:0]         ram_wr_data_b_1            ;//BRAM写数据b
wire                                    bram_en_1                  ;//BRAM使能
wire                                    bram_wea_1                 ;//BRAM读写控制信号
wire                   [  11:0]         ram_rd_data_a_1            ;//BRAM读数据a
wire                   [  11:0]         ram_rd_data_b_1            ;//BRAM读数据b
//bram_tone_2
wire                   [   9:0]         ram_addr_a_2               ;//BRAM读写地址a
wire                   [   9:0]         ram_addr_b_2               ;//BRAM读写地址b
wire                   [  11:0]         ram_wr_data_a_2            ;//BRAM写数据a
wire                   [  11:0]         ram_wr_data_b_2            ;//BRAM写数据b
wire                                    bram_en_2                  ;//BRAM使能
wire                                    bram_wea_2                 ;//BRAM读写控制信号
wire                   [  11:0]         ram_rd_data_a_2            ;//BRAM读数据a
wire                   [  11:0]         ram_rd_data_b_2            ;//BRAM读数据b
//bram_tone_3
wire                   [   9:0]         ram_addr_a_3               ;//BRAM读写地址a
wire                   [   9:0]         ram_addr_b_3               ;//BRAM读写地址b
wire                   [  11:0]         ram_wr_data_a_3            ;//BRAM写数据a
wire                   [  11:0]         ram_wr_data_b_3            ;//BRAM写数据b
wire                                    bram_en_3                  ;//BRAM使能
wire                                    bram_wea_3                 ;//BRAM读写控制信号
wire                   [  11:0]         ram_rd_data_a_3            ;//BRAM读数据a
wire                   [  11:0]         ram_rd_data_b_3            ;//BRAM读数据b
//bram_tone_4
wire                   [   9:0]         ram_addr_a_4               ;//BRAM读写地址a
wire                   [   9:0]         ram_addr_b_4               ;//BRAM读写地址b
wire                   [  11:0]         ram_wr_data_a_4            ;//BRAM写数据a
wire                   [  11:0]         ram_wr_data_b_4            ;//BRAM写数据b
wire                                    bram_en_4                  ;//BRAM使能
wire                                    bram_wea_4                 ;//BRAM读写控制信号
wire                   [  11:0]         ram_rd_data_a_4            ;//BRAM读数据a
wire                   [  11:0]         ram_rd_data_b_4            ;//BRAM读数据b

//bram_qpsk_1
wire                   [  14:0]         ram_addr_a_qpsk_1          ;//BRAM读写地址a
wire                   [  14:0]         ram_addr_b_qpsk_1          ;//BRAM读写地址b
wire                   [  11:0]         ram_wr_data_a_qpsk_1       ;//BRAM写数据a
wire                   [  11:0]         ram_wr_data_b_qpsk_1       ;//BRAM写数据b
wire                                    bram_en_qpsk_1             ;//BRAM使能
wire                                    bram_wea_qpsk_1            ;//BRAM读写控制信号
wire                   [  11:0]         ram_rd_data_a_qpsk_1       ;//BRAM读数据a
wire                   [  11:0]         ram_rd_data_b_qpsk_1       ;//BRAM读数据b
//bram_qpsk_2
wire                   [  14:0]         ram_addr_a_qpsk_2          ;//BRAM读写地址a
wire                   [  14:0]         ram_addr_b_qpsk_2          ;//BRAM读写地址b
wire                   [  11:0]         ram_wr_data_a_qpsk_2       ;//BRAM写数据a
wire                   [  11:0]         ram_wr_data_b_qpsk_2       ;//BRAM写数据b
wire                                    bram_en_qpsk_2             ;//BRAM使能
wire                                    bram_wea_qpsk_2            ;//BRAM读写控制信号
wire                   [  11:0]         ram_rd_data_a_qpsk_2       ;//BRAM读数据a
wire                   [  11:0]         ram_rd_data_b_qpsk_2       ;//BRAM读数据b

//bram_qpsk_out_1
wire                   [  14:0]         ram_addr_a_qpsk_out_1      ;//BRAM读写地址a
wire                   [  14:0]         ram_addr_b_qpsk_out_1      ;//BRAM读写地址b
wire                   [  11:0]         ram_wr_data_a_qpsk_out_1   ;//BRAM写数据a
wire                   [  11:0]         ram_wr_data_b_qpsk_out_1   ;//BRAM写数据b
wire                                    bram_en_qpsk_out_1         ;//BRAM使能
wire                                    bram_wea_qpsk_out_1        ;//BRAM读写控制信号
wire                   [  11:0]         ram_rd_data_a_qpsk_out_1   ;//BRAM读数据a
wire                   [  11:0]         ram_rd_data_b_qpsk_out_1   ;//BRAM读数据b
//bram_qpsk_out_2
wire                   [  14:0]         ram_addr_a_qpsk_out_2      ;//BRAM读写地址a
wire                   [  14:0]         ram_addr_b_qpsk_out_2      ;//BRAM读写地址b
wire                   [  11:0]         ram_wr_data_a_qpsk_out_2   ;//BRAM写数据a
wire                   [  11:0]         ram_wr_data_b_qpsk_out_2   ;//BRAM写数据b
wire                                    bram_en_qpsk_out_2         ;//BRAM使能
wire                                    bram_wea_qpsk_out_2        ;//BRAM读写控制信号
wire                   [  11:0]         ram_rd_data_a_qpsk_out_2   ;//BRAM读数据a
wire                   [  11:0]         ram_rd_data_b_qpsk_out_2   ;//BRAM读数据b

//asyn_fifo
wire [11:0] asyn_fifo_rd_data_tone_i0 ;
wire [11:0] asyn_fifo_rd_data_tone_i1 ;
wire [11:0] asyn_fifo_rd_data_tone_q0 ;
wire [11:0] asyn_fifo_rd_data_tone_q1 ;

wire [11:0] asyn_fifo_rd_data_qpsk_i0 ;
wire [11:0] asyn_fifo_rd_data_qpsk_i1 ;
wire [11:0] asyn_fifo_rd_data_qpsk_q0 ;
wire [11:0] asyn_fifo_rd_data_qpsk_q1 ;

wire asyn_fifo_rd_valid_i0 ;
wire asyn_fifo_rd_valid_i1 ;
wire asyn_fifo_rd_valid_q0 ;
wire asyn_fifo_rd_valid_q1 ;

// internal signals
wire    [63:0]  gpio_i;
wire    [63:0]  gpio_o;
wire    [63:0]  gpio_t;
wire    [ 7:0]  spi_csn;
wire            spi_clk;
wire            spi_mosi;
wire            spi_miso;


wire l_clk;
wire l_clk_div4;
wire [15:0] adc_data_i0;
wire [15:0] adc_data_i1;
wire [15:0] adc_data_q0;
wire [15:0] adc_data_q1;
wire adc_enable_i0;
wire adc_enable_i1;
wire adc_enable_q0;
wire adc_enable_q1;
wire adc_valid_i0 ;
wire adc_valid_i1 ;
wire adc_valid_q0 ;
wire adc_valid_q1 ;
wire [15:0] dac_data_i0;
wire [15:0] dac_data_i1;
wire [15:0] dac_data_q0;
wire [15:0] dac_data_q1;
wire dac_enable_i0;
wire dac_enable_i1;
wire dac_enable_q0;
wire dac_enable_q1;
wire dac_valid_i0 ;
wire dac_valid_i1 ;
wire dac_valid_q0 ;
wire dac_valid_q1 ;
wire clk_100M;

//FIFO
wire full_tone;
wire almost_full_tone;
wire empty_tone;
wire almost_empty_tone;
wire full_qpsk;
wire empty_qpsk;
wire almost_full_qpsk;
wire almost_empty_qpsk;

wire [10 : 0] rd_data_count;
wire [10 : 0] wr_data_count;
wire [13 : 0] wr_data_count_qpsk;

//FIFO_ctrl
wire          fifo_tone_wr_en;//存储单音信号FIFO写使能
wire          fifo_qpsk_wr_en;//存储QPSK信号FIFO写使能
wire [10:0]   fifo_tone_rd_cnt;//存储单音信号FIFO计数器
wire [13:0]   fifo_qpsk_rd_cnt;//存储QPSK信号FIFO计数器
wire          fifo_tone_rd_en;//存储单音信号FIFO读使能
wire          fifo_qpsk_rd_en; //存储QPSK信号FIFO读使能

wire [11:0] fifo_to_dac_data_tone_i0;
wire [11:0] fifo_to_dac_data_tone_i1;
wire [11:0] fifo_to_dac_data_tone_q0;
wire [11:0] fifo_to_dac_data_tone_q1;
wire [11:0] fifo_to_dac_data_qpsk_i0;
wire [11:0] fifo_to_dac_data_qpsk_i1;
wire [11:0] fifo_to_dac_data_qpsk_q0;
wire [11:0] fifo_to_dac_data_qpsk_q1;

wire fifo_wr_en;      
wire fifo_rd_en;     

wire                   [  11:0]         fifo_data_out_i0           ;
wire                   [  11:0]         fifo_data_out_i1           ;
wire                   [  11:0]         fifo_data_out_q0           ;
wire                   [  11:0]         fifo_data_out_q1           ;
wire                                    fifo_almost_full           ;
wire                                    fifo_almost_empty          ;
wire                                    fifo_full                  ;
wire                                    fifo_empty                 ;
wire                   [  13:0]         fifo_rd_cnt                ;
wire                   [  13:0]         fifo_wr_cnt                ;

wire [11:0] qpsk_signal_in_i0;
wire [11:0] qpsk_signal_in_q0;
wire [11:0] qpsk_signal_in_i1;
wire [11:0] qpsk_signal_in_q1;
wire qpsk_signal_in_valid;

wire [11:0] qpsk_in_i0;
wire [11:0] qpsk_in_q0;
wire [11:0] qpsk_in_i1;
wire [11:0] qpsk_in_q1;

//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------


// default logic
assign spi_csn_0 = spi_csn[0];

// assign fmc_vcc_enable = 1'b1;

//asyn_fifo_rd_data select
assign dac_data_i0[15:0] = (qpsk_signal_rd_valid == 1'b0) ? {fifo_to_dac_data_tone_i0, 4'b0} : {fifo_to_dac_data_qpsk_i0, 4'b0}; 
assign dac_data_i1[15:0] = (qpsk_signal_rd_valid == 1'b0) ? {fifo_to_dac_data_tone_i1, 4'b0} : {fifo_to_dac_data_qpsk_i1, 4'b0};
assign dac_data_q0[15:0] = (qpsk_signal_rd_valid == 1'b0) ? {fifo_to_dac_data_tone_q0, 4'b0} : {fifo_to_dac_data_qpsk_q0, 4'b0};
assign dac_data_q1[15:0] = (qpsk_signal_rd_valid == 1'b0) ? {fifo_to_dac_data_tone_q1, 4'b0} : {fifo_to_dac_data_qpsk_q1, 4'b0};

/*assign dac_data_i0[15:0] = {fifo_to_dac_data_tone_i0, 4'b0}; 
assign dac_data_i1[15:0] = {fifo_to_dac_data_tone_i1, 4'b0};
assign dac_data_q0[15:0] = {fifo_to_dac_data_tone_q0, 4'b0};
assign dac_data_q1[15:0] = {fifo_to_dac_data_tone_q1, 4'b0};*/
assign qpsk_in_i0 = ram_rd_data_a_qpsk_1;
assign qpsk_in_q0 = ram_rd_data_b_qpsk_1;
assign qpsk_in_i1 = ram_rd_data_a_qpsk_2;
assign qpsk_in_q1 = ram_rd_data_b_qpsk_2;


// instantiations
ad_iobuf #(.DATA_WIDTH(15)) i_iobuf (
    .dio_t                             (gpio_t[46:32]             ),
    .dio_i                             (gpio_o[46:32]             ),
    .dio_o                             (gpio_i[46:32]             ),
    .dio_p                             ({ gpio_resetb,
                                          gpio_sync,
                                          gpio_en_agc,
                                          gpio_ctl,
                                          gpio_status}            )
);

//  ad_iobuf #(.DATA_WIDTH(17)) i_iobuf_bd (
//    .dio_t (gpio_t[16:0]),
//    .dio_i (gpio_o[16:0]),
//    .dio_o (gpio_i[16:0]),
//    .dio_p (gpio_bd));

system_wrapper i_system_wrapper (
    .gpio0_o                           (gpio_o[31:0]              ),
    .gpio0_t                           (gpio_t[31:0]              ),
    .gpio0_i                           (gpio_i[31:0]              ),
    .gpio1_o                           (gpio_o[63:32]             ),
    .gpio1_t                           (gpio_t[63:32]             ),
    .gpio1_i                           (gpio_i[63:32]             ),
    .spi_clk_i                         (spi_clk                   ),
    .spi_clk_o                         (spi_clk                   ),
    .spi_csn_i                         (spi_csn                   ),
    .spi_csn_o                         (spi_csn                   ),
    .spi_sdi_i                         (spi_miso                  ),
    .spi_sdo_i                         (spi_mosi                  ),
    .spi_sdo_o                         (spi_mosi                  ),
    .sys_clk_n                         (sys_clk_n                 ),
    .sys_clk_p                         (sys_clk_p                 ),
    .clk_100M                          (clk_100M                  ),
    .sys_rst                           (1'b1                      ),
    .vcc_enable                        (fmc_vcc_enable            ),
    .rx_clk_in_n                       (rx_clk_in_n               ),
    .rx_clk_in_p                       (rx_clk_in_p               ),
    .rx_data_in_n                      (rx_data_in_n              ),
    .rx_data_in_p                      (rx_data_in_p              ),
    .rx_frame_in_n                     (rx_frame_in_n             ),
    .rx_frame_in_p                     (rx_frame_in_p             ),
    .tx_clk_out_n                      (tx_clk_out_n              ),
    .tx_clk_out_p                      (tx_clk_out_p              ),
    .tx_data_out_n                     (tx_data_out_n             ),
    .tx_data_out_p                     (tx_data_out_p             ),
    .tx_frame_out_n                    (tx_frame_out_n            ),
    .tx_frame_out_p                    (tx_frame_out_p            ),
    .l_clk                             (l_clk                     ),
    .adc_data_i0                       (adc_data_i0               ),
    .adc_data_i1                       (adc_data_i1               ),
    .adc_data_q0                       (adc_data_q0               ),
    .adc_data_q1                       (adc_data_q1               ),
    .adc_enable_i0                     (adc_enable_i0             ),
    .adc_enable_i1                     (adc_enable_i1             ),
    .adc_enable_q0                     (adc_enable_q0             ),
    .adc_enable_q1                     (adc_enable_q1             ),
    .adc_valid_i0                      (adc_valid_i0              ),
    .adc_valid_i1                      (adc_valid_i1              ),
    .adc_valid_q0                      (adc_valid_q0              ),
    .adc_valid_q1                      (adc_valid_q1              ),
    .dac_data_i0                       (dac_data_i0               ),
    .dac_data_i1                       (dac_data_i1               ),
    .dac_data_q0                       (dac_data_q0               ),
    .dac_data_q1                       (dac_data_q1               ),
    .dac_enable_i0                     (dac_enable_i0             ),
    .dac_enable_i1                     (dac_enable_i1             ),
    .dac_enable_q0                     (dac_enable_q0             ),
    .dac_enable_q1                     (dac_enable_q1             ),
    .dac_valid_i0                      (dac_valid_i0              ),
    .dac_valid_i1                      (dac_valid_i1              ),
    .dac_valid_q0                      (dac_valid_q0              ),
    .dac_valid_q1                      (dac_valid_q1              ),
    .uart_sin                          (uart_sin                  ),
    .uart_sout                         (                          ),
    .up_enable                         (                          ),
    .up_txnrx                          (                          ) 
);


//uart模块
uart u_uart(
    .clk                               (clk_100M                  ),
    .rst_n                             (sys_rst                   ),
    .uart_rxd                          (uart_sin                  ),
    .uart_txd                          (uart_sout                 ),
    .dout_12_a                         (uart_recv_data_12b_a      ),
    .dout_12_b                         (uart_recv_data_12b_b      ),
    .dout_12_valid                     (uart_recv_data_12b_valid  ),
    .tone_signal_wr_done               (tone_signal_wr_done       ),
    .qpsk_signal_wr_done               (qpsk_signal_wr_done       ),
    .s_amp_phase_ready                 (s_amp_phase_ready_1       ),
    .qpsk_signal_wr_over               (qpsk_signal_wr_over       ),
    .uart_tx_24_done                   (uart_tx_24_done           ),
    .qpsk_signal_out_a                 (qpsk_signal_out_a         ),
    .qpsk_signal_out_b                 (qpsk_signal_out_b         ),
    .uart_tx_start_1                   (uart_tx_start_1           ),
    .uart_tx_start_2                   (uart_tx_start_2           )
);

//bram读写控制模块
bram_wr_ctrl u_bram_wr_ctrl(
    .clk                               (clk_100M                  ),
    .rst_n                             (sys_rst                   ),
    .dout_12_valid                     (uart_recv_data_12b_valid  ),
    .dout_12_a                         (uart_recv_data_12b_a      ),
    .dout_12_b                         (uart_recv_data_12b_b      ),

    .ram_addr_a_1                      (ram_addr_a_1              ),
    .ram_addr_b_1                      (ram_addr_b_1              ),
    .ram_wr_data_a_1                   (ram_wr_data_a_1           ),
    .ram_wr_data_b_1                   (ram_wr_data_b_1           ),
    .bram_en_1                         (bram_en_1                 ),
    .bram_wea_1                        (bram_wea_1                ),

    .ram_addr_a_2                      (ram_addr_a_2              ),
    .ram_addr_b_2                      (ram_addr_b_2              ),
    .ram_wr_data_a_2                   (ram_wr_data_a_2           ),
    .ram_wr_data_b_2                   (ram_wr_data_b_2           ),
    .bram_en_2                         (bram_en_2                 ),
    .bram_wea_2                        (bram_wea_2                ),
    
    .ram_addr_a_3                      (ram_addr_a_3              ),
    .ram_addr_b_3                      (ram_addr_b_3              ),
    .ram_wr_data_a_3                   (ram_wr_data_a_3           ),
    .ram_wr_data_b_3                   (ram_wr_data_b_3           ),
    .bram_en_3                         (bram_en_3                 ),
    .bram_wea_3                        (bram_wea_3                ),

    .ram_addr_a_4                      (ram_addr_a_4              ),
    .ram_addr_b_4                      (ram_addr_b_4              ),
    .ram_wr_data_a_4                   (ram_wr_data_a_4           ),
    .ram_wr_data_b_4                   (ram_wr_data_b_4           ),
    .bram_en_4                         (bram_en_4                 ),
    .bram_wea_4                        (bram_wea_4                ),

    .ram_addr_a_qpsk_1                 (ram_addr_a_qpsk_1         ),
    .ram_addr_b_qpsk_1                 (ram_addr_b_qpsk_1         ),
    .ram_wr_data_a_qpsk_1              (ram_wr_data_a_qpsk_1      ),
    .ram_wr_data_b_qpsk_1              (ram_wr_data_b_qpsk_1      ),
    .bram_en_qpsk_1                    (bram_en_qpsk_1            ),
    .bram_wea_qpsk_1                   (bram_wea_qpsk_1           ),

    .ram_addr_a_qpsk_2                 (ram_addr_a_qpsk_2         ),
    .ram_addr_b_qpsk_2                 (ram_addr_b_qpsk_2         ),
    .ram_wr_data_a_qpsk_2              (ram_wr_data_a_qpsk_2      ),
    .ram_wr_data_b_qpsk_2              (ram_wr_data_b_qpsk_2      ),
    .bram_en_qpsk_2                    (bram_en_qpsk_2            ),
    .bram_wea_qpsk_2                   (bram_wea_qpsk_2           ),

    .tone_signal_wr_done               (tone_signal_wr_done       ),
    .qpsk_signal_wr_done               (qpsk_signal_wr_done       ),
    .tone_signal_rd_valid              (tone_signal_rd_valid      ),
    .qpsk_signal_rd_valid              (qpsk_signal_rd_valid      ),

    .uart_tx_start_1                   (uart_tx_start_1           ),
    .uart_tx_start_2                   (uart_tx_start_2           )
);

//bram_qpsk_out读写控制模块
post_bram_rw_ctrl u_post_bram_rw_ctrl(
    .clk                               (clk_100M                  ),
    .rst_n                             (sys_rst                   ),

    .qpsk_signal_out_valid_1           (qpsk_signal_out_valid_1   ),
    .qpsk_signal_out_i_1               (qpsk_signal_out_i_1       ),
    .qpsk_signal_out_q_1               (qpsk_signal_out_q_1       ),
    .signal_out_index_1                (signal_out_index_1        ),
    .ram_addr_a_qpsk_out_1             (ram_addr_a_qpsk_out_1     ),
    .ram_addr_b_qpsk_out_1             (ram_addr_b_qpsk_out_1     ),
    .ram_wr_data_a_qpsk_out_1          (ram_wr_data_a_qpsk_out_1  ),
    .ram_wr_data_b_qpsk_out_1          (ram_wr_data_b_qpsk_out_1  ),
    .bram_en_qpsk_out_1                (bram_en_qpsk_out_1        ),
    .bram_wea_qpsk_out_1               (bram_wea_qpsk_out_1       ),
    .ram_rd_data_a_qpsk_out_1          (ram_rd_data_a_qpsk_out_1  ),
    .ram_rd_data_b_qpsk_out_1          (ram_rd_data_b_qpsk_out_1  ), 

    .qpsk_signal_out_valid_2           (qpsk_signal_out_valid_2   ),
    .qpsk_signal_out_i_2               (qpsk_signal_out_i_2       ),
    .qpsk_signal_out_q_2               (qpsk_signal_out_q_2       ),
    .signal_out_index_2                (signal_out_index_2        ),
    .ram_addr_a_qpsk_out_2             (ram_addr_a_qpsk_out_2     ),
    .ram_addr_b_qpsk_out_2             (ram_addr_b_qpsk_out_2     ),
    .ram_wr_data_a_qpsk_out_2          (ram_wr_data_a_qpsk_out_2  ),
    .ram_wr_data_b_qpsk_out_2          (ram_wr_data_b_qpsk_out_2  ),
    .bram_en_qpsk_out_2                (bram_en_qpsk_out_2        ),
    .bram_wea_qpsk_out_2               (bram_wea_qpsk_out_2       ),
    .ram_rd_data_a_qpsk_out_2          (ram_rd_data_a_qpsk_out_2  ),
    .ram_rd_data_b_qpsk_out_2          (ram_rd_data_b_qpsk_out_2  ),

    .qpsk_signal_wr_over               (qpsk_signal_wr_over       ),
    .uart_tx_24_done                   (uart_tx_24_done           ),
    .qpsk_signal_out_a                 (qpsk_signal_out_a         ),
    .qpsk_signal_out_b                 (qpsk_signal_out_b         ),

    .uart_tx_start_1                   (uart_tx_start_1           ),
    .uart_tx_start_2                   (uart_tx_start_2           )
);


//BRAM模块
bram_1024x12bit bram_tone_1 (
    .clka                              (clk_100M                  ),// input wire clka
    .ena                               (bram_en_1                 ),// input wire ena
    .wea                               (bram_wea_1                ),// input wire [0 : 0] wea
    .addra                             (ram_addr_a_1              ),// input wire [9 : 0] addra
    .dina                              (ram_wr_data_a_1           ),// input wire [11 : 0] dina
    .douta                             (ram_rd_data_a_1           ),// output wire [11 : 0] douta
    .clkb                              (clk_100M                  ),// input wire clkb
    .enb                               (bram_en_1                 ),// input wire enb
    .web                               (bram_wea_1                ),// input wire [0 : 0] web
    .addrb                             (ram_addr_b_1              ),// input wire [9 : 0] addrb
    .dinb                              (ram_wr_data_b_1           ),// input wire [11 : 0] dinb
    .doutb                             (ram_rd_data_b_1           ) // output wire [11 : 0] doutb
);

bram_1024x12bit bram_tone_2 (
    .clka                              (clk_100M                  ),// input wire clka
    .ena                               (bram_en_2                 ),// input wire ena
    .wea                               (bram_wea_2                ),// input wire [0 : 0] wea
    .addra                             (ram_addr_a_2              ),// input wire [9 : 0] addra
    .dina                              (ram_wr_data_a_2           ),// input wire [11 : 0] dina
    .douta                             (ram_rd_data_a_2           ),// output wire [11 : 0] douta
    .clkb                              (clk_100M                  ),// input wire clkb
    .enb                               (bram_en_2                 ),// input wire enb
    .web                               (bram_wea_2                ),// input wire [0 : 0] web
    .addrb                             (ram_addr_b_2              ),// input wire [9 : 0] addrb
    .dinb                              (ram_wr_data_b_2           ),// input wire [11 : 0] dinb
    .doutb                             (ram_rd_data_b_2           ) // output wire [11 : 0] doutb
);

bram_1024x12bit bram_tone_3 (
    .clka                              (clk_100M                  ),// input wire clka
    .ena                               (bram_en_3                 ),// input wire ena
    .wea                               (bram_wea_3                ),// input wire [0 : 0] wea
    .addra                             (ram_addr_a_3              ),// input wire [9 : 0] addra
    .dina                              (ram_wr_data_a_3           ),// input wire [11 : 0] dina
    .douta                             (ram_rd_data_a_3           ),// output wire [11 : 0] douta
    .clkb                              (clk_100M                  ),// input wire clkb
    .enb                               (bram_en_3                 ),// input wire enb
    .web                               (bram_wea_3                ),// input wire [0 : 0] web
    .addrb                             (ram_addr_b_3              ),// input wire [9 : 0] addrb
    .dinb                              (ram_wr_data_b_3           ),// input wire [11 : 0] dinb
    .doutb                             (ram_rd_data_b_3           ) // output wire [11 : 0] doutb
);

bram_1024x12bit bram_tone_4 (
    .clka                              (clk_100M                  ),// input wire clka
    .ena                               (bram_en_4                 ),// input wire ena
    .wea                               (bram_wea_4                ),// input wire [0 : 0] wea
    .addra                             (ram_addr_a_4              ),// input wire [9 : 0] addra
    .dina                              (ram_wr_data_a_4           ),// input wire [11 : 0] dina
    .douta                             (ram_rd_data_a_4           ),// output wire [11 : 0] douta
    .clkb                              (clk_100M                  ),// input wire clkb
    .enb                               (bram_en_4                 ),// input wire enb
    .web                               (bram_wea_4                ),// input wire [0 : 0] web
    .addrb                             (ram_addr_b_4              ),// input wire [9 : 0] addrb
    .dinb                              (ram_wr_data_b_4           ),// input wire [11 : 0] dinb
    .doutb                             (ram_rd_data_b_4           ) // output wire [11 : 0] doutb
);

bram_20000x12bit bram_qpsk_1 (
    .clka                              (clk_100M                  ),// input wire clka
    .ena                               (bram_en_qpsk_1            ),// input wire ena
    .wea                               (bram_wea_qpsk_1           ),// input wire [0 : 0] wea
    .addra                             (ram_addr_a_qpsk_1         ),// input wire [14 : 0] addra
    .dina                              (ram_wr_data_a_qpsk_1      ),// input wire [11 : 0] dina
    .douta                             (ram_rd_data_a_qpsk_1      ),// output wire [11 : 0] douta
    .clkb                              (clk_100M                  ),// input wire clkb
    .enb                               (bram_en_qpsk_1            ),// input wire enb
    .web                               (bram_wea_qpsk_1           ),// input wire [0 : 0] web
    .addrb                             (ram_addr_b_qpsk_1         ),// input wire [14 : 0] addrb
    .dinb                              (ram_wr_data_b_qpsk_1      ),// input wire [11 : 0] dinb
    .doutb                             (ram_rd_data_b_qpsk_1      ) // output wire [11 : 0] doutb
);

bram_20000x12bit bram_qpsk_2 (
    .clka                              (clk_100M                  ),// input wire clka
    .ena                               (bram_en_qpsk_2            ),// input wire ena
    .wea                               (bram_wea_qpsk_2           ),// input wire [0 : 0] wea
    .addra                             (ram_addr_a_qpsk_2         ),// input wire [14 : 0] addra
    .dina                              (ram_wr_data_a_qpsk_2      ),// input wire [11 : 0] dina
    .douta                             (ram_rd_data_a_qpsk_2      ),// output wire [11 : 0] douta
    .clkb                              (clk_100M                  ),// input wire clkb
    .enb                               (bram_en_qpsk_2            ),// input wire enb
    .web                               (bram_wea_qpsk_2           ),// input wire [0 : 0] web
    .addrb                             (ram_addr_b_qpsk_2         ),// input wire [14 : 0] addrb
    .dinb                              (ram_wr_data_b_qpsk_2      ),// input wire [11 : 0] dinb
    .doutb                             (ram_rd_data_b_qpsk_2      ) // output wire [11 : 0] doutb
);

bram_20000x12bit bram_qpsk_out_1 (
    .clka                              (clk_100M                  ),// input wire clka
    .ena                               (bram_en_qpsk_out_1        ),// input wire ena
    .wea                               (bram_wea_qpsk_out_1       ),// input wire [0 : 0] wea
    .addra                             (ram_addr_a_qpsk_out_1     ),// input wire [14 : 0] addra
    .dina                              (ram_wr_data_a_qpsk_out_1  ),// input wire [11 : 0] dina
    .douta                             (ram_rd_data_a_qpsk_out_1  ),// output wire [11 : 0] douta
    .clkb                              (clk_100M                  ),// input wire clkb
    .enb                               (bram_en_qpsk_out_1        ),// input wire enb
    .web                               (bram_wea_qpsk_out_1       ),// input wire [0 : 0] web
    .addrb                             (ram_addr_b_qpsk_out_1     ),// input wire [14 : 0] addrb
    .dinb                              (ram_wr_data_b_qpsk_out_1  ),// input wire [11 : 0] dinb
    .doutb                             (ram_rd_data_b_qpsk_out_1  ) // output wire [11 : 0] doutb
);

bram_20000x12bit bram_qpsk_out_2 (
    .clka                              (clk_100M                  ),// input wire clka
    .ena                               (bram_en_qpsk_out_2        ),// input wire ena
    .wea                               (bram_wea_qpsk_out_2       ),// input wire [0 : 0] wea
    .addra                             (ram_addr_a_qpsk_out_2     ),// input wire [14 : 0] addra
    .dina                              (ram_wr_data_a_qpsk_out_2  ),// input wire [11 : 0] dina
    .douta                             (ram_rd_data_a_qpsk_out_2  ),// output wire [11 : 0] douta
    .clkb                              (clk_100M                  ),// input wire clkb
    .enb                               (bram_en_qpsk_out_2        ),// input wire enb
    .web                               (bram_wea_qpsk_out_2       ),// input wire [0 : 0] web
    .addrb                             (ram_addr_b_qpsk_out_2     ),// input wire [14 : 0] addrb
    .dinb                              (ram_wr_data_b_qpsk_out_2  ),// input wire [11 : 0] dinb
    .doutb                             (ram_rd_data_b_qpsk_out_2  ) // output wire [11 : 0] doutb
);

//单音校正模块    
tone_signal_correct u_tone_signal_correct_1(
    .clk                               (clk_100M                  ),
    .rst_n                             (sys_rst                   ),
    .tone_signal                       ($signed(ram_rd_data_a_1)  ),
    .tone_signal_valid                 (tone_signal_rd_valid      ),
    .channel_phase                     (channel_phase_1           ),
    .channel_amplitude                 (channel_amplitude_1       ),
    .channel_data_valid                (channel_data_valid_1      )
); 

tone_signal_correct u_tone_signal_correct_2(
    .clk                               (clk_100M                  ),
    .rst_n                             (sys_rst                   ),
    .tone_signal                       ($signed(ram_rd_data_a_2)  ),
    .tone_signal_valid                 (tone_signal_rd_valid      ),
    .channel_phase                     (channel_phase_2           ),
    .channel_amplitude                 (channel_amplitude_2       ),
    .channel_data_valid                (channel_data_valid_2      )
); 

//qpsk幅相校正模块
amp_phase_correct u_amp_phase_correct_1(
    .clk                               (clk_100M                  ),
    .rst_n                             (sys_rst                   ),
    .channel_phase                     (channel_phase_1           ),
    .channel_amplitude                 (channel_amplitude_1       ),
    .channel_data_valid                (channel_data_valid_1      ),
    .ref_phase                         (channel_phase_1           ),
    .ref_amplitude                     (channel_amplitude_1       ),
    .ref_valid                         (channel_data_valid_1      ),

    .qpsk_signal_in_i                  (qpsk_in_i0                ),
    .qpsk_signal_in_q                  (qpsk_in_q0                ),
    .qpsk_signal_in_valid              (qpsk_signal_rd_valid      ),

    // .qpsk_signal_in_i                  (qpsk_signal_in_i0         ),
    // .qpsk_signal_in_q                  (qpsk_signal_in_q0         ),
    // .qpsk_signal_in_valid              (qpsk_signal_in_valid      ),

    .qpsk_signal_out_i                 (qpsk_signal_out_i_1       ),
    .qpsk_signal_out_q                 (qpsk_signal_out_q_1       ),
    .qpsk_signal_out_valid             (qpsk_signal_out_valid_1   ),
    .s_amp_phase_ready                 (s_amp_phase_ready_1       ),
    .signal_out_index                  (signal_out_index_1        ) 
);

amp_phase_correct u_amp_phase_correct_2(
    .clk                               (clk_100M                  ),
    .rst_n                             (sys_rst                   ),
    .channel_phase                     (channel_phase_2           ),
    .channel_amplitude                 (channel_amplitude_2       ),
    .channel_data_valid                (channel_data_valid_2      ),
    .ref_phase                         (channel_phase_1           ),
    .ref_amplitude                     (channel_amplitude_1       ),
    .ref_valid                         (channel_data_valid_1      ),

    .qpsk_signal_in_i                  (qpsk_in_i1                ),
    .qpsk_signal_in_q                  (qpsk_in_q1                ),
    .qpsk_signal_in_valid              (qpsk_signal_rd_valid      ),

    // .qpsk_signal_in_i                  (qpsk_signal_in_i1         ),
    // .qpsk_signal_in_q                  (qpsk_signal_in_q1         ),
    // .qpsk_signal_in_valid              (qpsk_signal_in_valid      ),

    .qpsk_signal_out_i                 (qpsk_signal_out_i_2       ),
    .qpsk_signal_out_q                 (qpsk_signal_out_q_2       ),
    .qpsk_signal_out_valid             (qpsk_signal_out_valid_2   ),
    .s_amp_phase_ready                 (s_amp_phase_ready_2       ),
    .signal_out_index                  (signal_out_index_2        ) 
);

//FIFO控制模块
asyn_fifo_rw_ctrl u_asyn_fifo_rw_ctrl(
    .wr_clk                            (clk_100M                  ),//写时钟
    .rd_clk                            (l_clk_div4                ),//读时钟
    .wr_rst_n                          (sys_rst                   ),//写复位，低有效
    .rd_rst_n                          (1'b1                      ),//读复位，低有效
    .tone_signal_rd_valid              (tone_signal_rd_valid      ),//开始读单音有效信号
    .qpsk_signal_rd_valid              (qpsk_signal_rd_valid      ),//开始读QPSK信号
    .fifo_tone_wr_en                   (fifo_tone_wr_en           ),//存储单音信号FIFO写使能
    .fifo_qpsk_wr_en                   (fifo_qpsk_wr_en           ),//存储QPSK信号FIFO写使能
    .fifo_tone_rd_cnt                  (fifo_tone_rd_cnt          ),//存储单音信号读FIFO计数器
    .fifo_qpsk_rd_cnt                  (fifo_qpsk_rd_cnt          ),//存储QPSK信号读FIFO计数器
    .fifo_tone_wr_cnt                  (wr_data_count             ),//存储单音信号写FIFO计数器
    .fifo_qpsk_wr_cnt                  (wr_data_count_qpsk        ),//存储QPSK信号写FIFO计数器
    .fifo_tone_rd_en                   (fifo_tone_rd_en           ),//存储单音信号FIFO读使能
    .fifo_qpsk_rd_en                   (fifo_qpsk_rd_en           ),//存储QPSK信号FIFO读使能
    .full_tone                         (full_tone                 ),
    .empty_tone                        (empty_tone                ),
    .almost_full_tone                  (almost_full_tone          ),
    .almost_empty_tone                 (almost_empty_tone         ),
    .full_qpsk                         (full_qpsk                 ),
    .empty_qpsk                        (empty_qpsk                ),
    .almost_full_qpsk                  (almost_full_qpsk          ),
    .almost_empty_qpsk                 (almost_empty_qpsk         ),
    .asyn_fifo_rd_data_tone_i0         (asyn_fifo_rd_data_tone_i0 ),
    .asyn_fifo_rd_data_tone_i1         (asyn_fifo_rd_data_tone_i1 ),
    .asyn_fifo_rd_data_tone_q0         (asyn_fifo_rd_data_tone_q0 ),
    .asyn_fifo_rd_data_tone_q1         (asyn_fifo_rd_data_tone_q1 ),
    .fifo_to_dac_data_tone_i0          (fifo_to_dac_data_tone_i0  ),
    .fifo_to_dac_data_tone_i1          (fifo_to_dac_data_tone_i1  ),
    .fifo_to_dac_data_tone_q0          (fifo_to_dac_data_tone_q0  ),
    .fifo_to_dac_data_tone_q1          (fifo_to_dac_data_tone_q1  ),
    .asyn_fifo_rd_data_qpsk_i0         (asyn_fifo_rd_data_qpsk_i0 ),
    .asyn_fifo_rd_data_qpsk_i1         (asyn_fifo_rd_data_qpsk_i1 ),
    .asyn_fifo_rd_data_qpsk_q0         (asyn_fifo_rd_data_qpsk_q0 ),
    .asyn_fifo_rd_data_qpsk_q1         (asyn_fifo_rd_data_qpsk_q1 ),
    .fifo_to_dac_data_qpsk_i0          (fifo_to_dac_data_qpsk_i0  ),
    .fifo_to_dac_data_qpsk_i1          (fifo_to_dac_data_qpsk_i1  ),
    .fifo_to_dac_data_qpsk_q0          (fifo_to_dac_data_qpsk_q0  ),
    .fifo_to_dac_data_qpsk_q1          (fifo_to_dac_data_qpsk_q1  ) 
);

// ///
asyn_fifo_rw_adc_ctrl u_asyn_fifo_rw_adc_ctrl(
    .wr_clk                            (l_clk                     ),//写时钟
    .rd_clk                            (clk_100M                  ),//读时钟
    .wr_rst_n                          (sys_rst                   ),//写复位，低有效
    .rd_rst_n                          (1'b1                      ),//读复位，低有效
    .fifo_to_apcorrect_data_i0         (qpsk_signal_in_i0         ),
    .fifo_to_apcorrect_data_i1         (qpsk_signal_in_i1         ),
    .fifo_to_apcorrect_data_q0         (qpsk_signal_in_q0         ),
    .fifo_to_apcorrect_data_q1         (qpsk_signal_in_q1         ),
    .ap_correct_valid                  (qpsk_signal_in_valid      ),//幅相校正模块启动信号
    .adc_data_i0_valid                 (adc_valid_i0              ),
    .adc_data_i1_valid                 (adc_valid_i1              ),
    .adc_data_q0_valid                 (adc_valid_q0              ),
    .adc_data_q1_valid                 (adc_valid_q1              ),
    .fifo_wr_en                        (fifo_wr_en                ),
    .fifo_rd_en                        (fifo_rd_en                ),
    .fifo_data_out_i0                  (fifo_data_out_i0          ),
    .fifo_data_out_i1                  (fifo_data_out_i1          ),
    .fifo_data_out_q0                  (fifo_data_out_q0          ),
    .fifo_data_out_q1                  (fifo_data_out_q1          ),
    .fifo_almost_full                  (fifo_almost_full          ),
    .fifo_almost_empty                 (fifo_almost_empt          ),
    .fifo_full                         (fifo_full                 ),
    .fifo_empty                        (fifo_empty                ),
    .fifo_rd_cnt                       (fifo_rd_cnt               ),
    .fifo_wr_cnt                       (fifo_wr_cnt               ),
    .fifo_qpsk_rd_cnt                  (fifo_qpsk_rd_cnt          ) //存储QPSK信号读FIFO计数器（DAC端）
);



//异步FIFO
asyn_fifo_12x1024 u_asyn_fifo_12x1024_tone_i0 (
    .rst                               (!sys_rst                  ),// input wire rst
    .wr_clk                            (clk_100M                  ),// input wire wr_clk
    .rd_clk                            (l_clk_div4                ),// input wire rd_clk
    .din                               (ram_rd_data_a_1           ),// input wire [11 : 0] din
    .wr_en                             (fifo_tone_wr_en           ),// input wire wr_en
    .rd_en                             (fifo_tone_rd_en           ),// input wire rd_en
    .dout                              (asyn_fifo_rd_data_tone_i0 ),// output wire [11 : 0] dout
    .full                              (full_tone                 ),// output wire full
    .almost_full                       (almost_full_tone          ),// output wire almost_full
    .empty                             (empty_tone                ),// output wire empty
    .almost_empty                      (almost_empty_tone         ),// output wire almost_empty
    .rd_data_count                     (fifo_tone_rd_cnt          ),// output wire [10 : 0] rd_data_count
    .wr_data_count                     (wr_data_count             ) // output wire [10 : 0] wr_data_count
);

asyn_fifo_12x1024 u_asyn_fifo_12x1024_tone_i1 (
    .rst                               (!sys_rst                  ),// input wire rst
    .wr_clk                            (clk_100M                  ),// input wire wr_clk
    .rd_clk                            (l_clk_div4                ),// input wire rd_clk
    .din                               (ram_rd_data_a_2           ),// input wire [11 : 0] din
    .wr_en                             (fifo_tone_wr_en           ),// input wire wr_en
    .rd_en                             (fifo_tone_rd_en           ),// input wire rd_en
    .dout                              (asyn_fifo_rd_data_tone_i1 ),// output wire [11 : 0] dout
    .full                              (                          ),// output wire full
    .almost_full                       (                          ),// output wire almost_full
    .empty                             (                          ),// output wire empty
    .almost_empty                      (                          ),// output wire almost_empty
    .rd_data_count                     (                          ),// output wire [10 : 0] rd_data_count
    .wr_data_count                     (                          ) // output wire [10 : 0] wr_data_count
);

asyn_fifo_12x1024 u_asyn_fifo_12x1024_tone_q0 (
    .rst                               (!sys_rst                  ),// input wire rst
    .wr_clk                            (clk_100M                  ),// input wire wr_clk
    .rd_clk                            (l_clk_div4                ),// input wire rd_clk
    .din                               (ram_rd_data_a_3           ),// input wire [11 : 0] din
    .wr_en                             (fifo_tone_wr_en           ),// input wire wr_en
    .rd_en                             (fifo_tone_rd_en           ),// input wire rd_en
    .dout                              (asyn_fifo_rd_data_tone_q0 ),// output wire [11 : 0] dout
    .full                              (                          ),// output wire full
    .almost_full                       (                          ),// output wire almost_full
    .empty                             (                          ),// output wire empty
    .almost_empty                      (                          ),// output wire almost_empty
    .rd_data_count                     (                          ),// output wire [10 : 0] rd_data_count
    .wr_data_count                     (                          ) // output wire [10 : 0] wr_data_count
);

asyn_fifo_12x1024 u_asyn_fifo_12x1024_tone_q1 (
    .rst                               (!sys_rst                  ),// input wire rst
    .wr_clk                            (clk_100M                  ),// input wire wr_clk
    .rd_clk                            (l_clk_div4                ),// input wire rd_clk
    .din                               (ram_rd_data_a_4           ),// input wire [11 : 0] din
    .wr_en                             (fifo_tone_wr_en           ),// input wire wr_en
    .rd_en                             (fifo_tone_rd_en           ),// input wire rd_en
    .dout                              (asyn_fifo_rd_data_tone_q1 ),// output wire [11 : 0] dout
    .full                              (                          ),// output wire full
    .almost_full                       (                          ),// output wire almost_full
    .empty                             (                          ),// output wire empty
    .almost_empty                      (                          ),// output wire almost_empty
    .rd_data_count                     (                          ),// output wire [10 : 0] rd_data_count
    .wr_data_count                     (                          ) // output wire [10 : 0] wr_data_count
);

asyn_fifo_12x16384 u_asyn_fifo_12x16384_qpsk_i0 (
    .rst                               (!sys_rst                  ),// input wire rst
    .wr_clk                            (clk_100M                  ),// input wire wr_clk
    .rd_clk                            (l_clk_div4                ),// input wire rd_clk
    .din                               (ram_rd_data_a_qpsk_1      ),// input wire [11 : 0] din
    .wr_en                             (fifo_qpsk_wr_en           ),// input wire wr_en
    .rd_en                             (fifo_qpsk_rd_en           ),// input wire rd_en
    .dout                              (asyn_fifo_rd_data_qpsk_i0 ),// output wire [11 : 0] dout
    .full                              (full_qpsk                 ),// output wire full
    .almost_full                       (almost_full_qpsk          ),// output wire almost_full
    .empty                             (empty_qpsk                ),// output wire empty
    .almost_empty                      (almost_empty_qpsk         ),// output wire almost_full
    .rd_data_count                     (fifo_qpsk_rd_cnt          ),// output wire [13 : 0] rd_data_count
    .wr_data_count                     (wr_data_count_qpsk        ) // output wire [13 : 0] wr_data_count
);

asyn_fifo_12x16384 u_asyn_fifo_12x16384_qpsk_i1 (
    .rst                               (!sys_rst                  ),// input wire rst
    .wr_clk                            (clk_100M                  ),// input wire wr_clk
    .rd_clk                            (l_clk_div4                ),// input wire rd_clk
    .din                               (ram_rd_data_a_qpsk_2      ),// input wire [11 : 0] din
    .wr_en                             (fifo_qpsk_wr_en           ),// input wire wr_en
    .rd_en                             (fifo_qpsk_rd_en           ),// input wire rd_en
    .dout                              (asyn_fifo_rd_data_qpsk_i1 ),// output wire [11 : 0] dout
    .full                              (                          ),// output wire full
    .almost_full                       (                          ),// output wire almost_full
    .empty                             (                          ),// output wire empty
    .almost_empty                      (                          ),// output wire almost_full
    .rd_data_count                     (                          ),// output wire [13 : 0] rd_data_count
    .wr_data_count                     (                          ) // output wire [13 : 0] wr_data_count
);

asyn_fifo_12x16384 u_asyn_fifo_12x16384_qpsk_q0 (
    .rst                               (!sys_rst                  ),// input wire rst
    .wr_clk                            (clk_100M                  ),// input wire wr_clk
    .rd_clk                            (l_clk_div4                ),// input wire rd_clk
    .din                               (ram_rd_data_b_qpsk_1      ),// input wire [11 : 0] din
    .wr_en                             (fifo_qpsk_wr_en           ),// input wire wr_en
    .rd_en                             (fifo_qpsk_rd_en           ),// input wire rd_en
    .dout                              (asyn_fifo_rd_data_qpsk_q0 ),// output wire [11 : 0] dout
    .full                              (                          ),// output wire full
    .almost_full                       (                          ),// output wire almost_full
    .empty                             (                          ),// output wire empty
    .almost_empty                      (                          ),// output wire almost_full
    .rd_data_count                     (                          ),// output wire [13 : 0] rd_data_count
    .wr_data_count                     (                          ) // output wire [13 : 0] wr_data_count
);

asyn_fifo_12x16384 u_asyn_fifo_12x16384_qpsk_q1 (
    .rst                               (!sys_rst                  ),// input wire rst
    .wr_clk                            (clk_100M                  ),// input wire wr_clk
    .rd_clk                            (l_clk_div4                ),// input wire rd_clk
    .din                               (ram_rd_data_b_qpsk_2      ),// input wire [11 : 0] din
    .wr_en                             (fifo_qpsk_wr_en           ),// input wire wr_en
    .rd_en                             (fifo_qpsk_rd_en           ),// input wire rd_en
    .dout                              (asyn_fifo_rd_data_qpsk_q1 ),// output wire [11 : 0] dout
    .full                              (                          ),// output wire full
    .almost_full                       (                          ),// output wire almost_full
    .empty                             (                          ),// output wire empty
    .almost_empty                      (                          ),// output wire almost_full
    .rd_data_count                     (                          ),// output wire [13 : 0] rd_data_count
    .wr_data_count                     (                          ) // output wire [13 : 0] wr_data_count
);
////
asyn_fifo_12x16384 u_asyn_fifo_12x16384_adc_i0 (
    .rst                               (!sys_rst                  ),// input wire rst
    .wr_clk                            (l_clk                     ),// input wire wr_clk
    .rd_clk                            (clk_100M                  ),// input wire rd_clk
    .din                               (adc_data_i0               ),// input wire [11 : 0] din
    .wr_en                             (fifo_wr_en                ),// input wire wr_en
    .rd_en                             (fifo_rd_en                ),// input wire rd_en
    .dout                              (fifo_data_out_i0          ),// output wire [11 : 0] dout
    .full                              (fifo_full                 ),// output wire full
    .almost_full                       (fifo_almost_full          ),// output wire almost_full
    .empty                             (fifo_empty                ),// output wire empty
    .almost_empty                      (fifo_almost_empty         ),// output wire almost_full
    .rd_data_count                     (fifo_rd_cnt               ),// output wire [13 : 0] rd_data_count
    .wr_data_count                     (fifo_wr_cnt               ) // output wire [13 : 0] wr_data_count
);

asyn_fifo_12x16384 u_asyn_fifo_12x16384_adc_i1 (
    .rst                               (!sys_rst                  ),// input wire rst
    .wr_clk                            (l_clk                     ),// input wire wr_clk
    .rd_clk                            (clk_100M                  ),// input wire rd_clk
    .din                               (~adc_data_i1               ),// input wire [11 : 0] din
    .wr_en                             (fifo_wr_en                ),// input wire wr_en
    .rd_en                             (fifo_rd_en                ),// input wire rd_en
    .dout                              (fifo_data_out_i1          ),// output wire [11 : 0] dout
    .full                              (                          ),// output wire full
    .almost_full                       (                          ),// output wire almost_full
    .empty                             (                          ),// output wire empty
    .almost_empty                      (                          ),// output wire almost_full
    .rd_data_count                     (                          ),// output wire [13 : 0] rd_data_count
    .wr_data_count                     (                          ) // output wire [13 : 0] wr_data_count
);

asyn_fifo_12x16384 u_asyn_fifo_12x16384_adc_q0 (
    .rst                               (!sys_rst                  ),// input wire rst
    .wr_clk                            (l_clk                     ),// input wire wr_clk
    .rd_clk                            (clk_100M                  ),// input wire rd_clk
    .din                               (adc_data_q0               ),// input wire [11 : 0] din
    .wr_en                             (fifo_wr_en                ),// input wire wr_en
    .rd_en                             (fifo_rd_en                ),// input wire rd_en
    .dout                              (fifo_data_out_q0          ),// output wire [11 : 0] dout
    .full                              (                          ),// output wire full
    .almost_full                       (                          ),// output wire almost_full
    .empty                             (                          ),// output wire empty
    .almost_empty                      (                          ),// output wire almost_full
    .rd_data_count                     (                          ),// output wire [13 : 0] rd_data_count
    .wr_data_count                     (                          ) // output wire [13 : 0] wr_data_count
);

asyn_fifo_12x16384 u_asyn_fifo_12x16384_adc_q1 (
    .rst                               (!sys_rst                  ),// input wire rst
    .wr_clk                            (l_clk                     ),// input wire wr_clk
    .rd_clk                            (clk_100M                  ),// input wire rd_clk
    .din                               (~adc_data_q1               ),// input wire [11 : 0] din
    .wr_en                             (fifo_wr_en                ),// input wire wr_en
    .rd_en                             (fifo_rd_en                ),// input wire rd_en
    .dout                              (fifo_data_out_q1          ),// output wire [11 : 0] dout
    .full                              (                          ),// output wire full
    .almost_full                       (                          ),// output wire almost_full
    .empty                             (                          ),// output wire empty
    .almost_empty                      (                          ),// output wire almost_full
    .rd_data_count                     (                          ),// output wire [13 : 0] rd_data_count
    .wr_data_count                     (                          ) // output wire [13 : 0] wr_data_count
);

//pll
clk_div4 u_clk_div4
   (
    // Clock out ports
    .clk_out1                          (l_clk_div4                ),// output clk_out1
    // Status and control signals
    .reset                             (1'b0                      ),// input reset
    .locked                            (                          ),// output locked
   // Clock in ports
    .clk_in1                           (l_clk                     ) // input clk_in1               
);



//ila
// ila_asyn_fifo_tone u_ila_asyn_fifo_tone_wr_i0 (
//     .clk                               (clk_100M                  ),// input wire clk


//     .probe0                            (fifo_tone_wr_en           ),// input wire [0:0]  probe0  
//     .probe1                            (ram_rd_data_a_1           ),// input wire [11:0]  probe1 
//     .probe2                            (full_tone                 ),// input wire [0:0]  probe2 
//     .probe3                            (wr_data_count             ),// input wire [10:0]  probe3 
//     .probe4                            (almost_full_tone          ) // input wire [0:0]  probe4
// );

// ila_asyn_fifo_tone u_ila_asyn_fifo_tone_rd_i0 (
//     .clk                               (l_clk_div4                     ),// input wire clk


//     .probe0                            (fifo_tone_rd_en           ),// input wire [0:0]  probe0  
//     .probe1                            (asyn_fifo_rd_data_tone_i0 ),// input wire [11:0]  probe1 
//     .probe2                            (empty_tone                ),// input wire [0:0]  probe2 
//     .probe3                            (fifo_tone_rd_cnt          ),// input wire [10:0]  probe3
//     .probe4                            (almost_empty_tone         ) // input wire [0:0]  probe4
// );

// ila_asyn_fifo_qpsk u_ila_asyn_fifo_qpsk_wr_i0 (
//     .clk                               (clk_100M                  ),// input wire clk


//     .probe0                            (fifo_qpsk_wr_en           ),// input wire [0:0]  probe0  
//     .probe1                            (ram_rd_data_a_qpsk_1      ),// input wire [11:0]  probe1 
//     .probe2                            (full_qpsk                 ),// input wire [0:0]  probe2 
//     .probe3                            (wr_data_count_qpsk        ),// input wire [13:0]  probe3
//     .probe4                            (almost_full_qpsk          ) // input wire [0:0]  probe4
// );

// ila_asyn_fifo_qpsk u_ila_asyn_fifo_qpsk_rd_i0 (
//     .clk                               (l_clk_div4                     ),// input wire clk


//     .probe0                            (fifo_qpsk_rd_en           ),// input wire [0:0]  probe0  
//     .probe1                            (asyn_fifo_rd_data_qpsk_i0 ),// input wire [11:0]  probe1 
//     .probe2                            (empty_qpsk                 ),// input wire [0:0]  probe2 
//     .probe3                            (fifo_qpsk_rd_cnt           ),// input wire [9:0]  probe3
//     .probe4                            (almost_empty_qpsk         ) // input wire [0:0]  probe4
// );

// ila_tone_out u_ila_tone_out (
//     .clk                               (clk_100M                  ),// input wire clk


//     .probe0                            (tone_signal_rd_valid      ),// input wire [0:0]  probe0  
//     .probe1                            (ram_rd_data_a_1           ),// input wire [11:0]  probe1 
//     .probe2                            (tone_signal_rd_valid      ),// input wire [0:0]  probe2 
//     .probe3                            (ram_rd_data_a_2           ),// input wire [11:0]  probe3 
//     .probe4                            (tone_signal_rd_valid      ),// input wire [0:0]  probe4 
//     .probe5                            (ram_rd_data_a_3           ),// input wire [11:0]  probe5 
//     .probe6                            (tone_signal_rd_valid      ),// input wire [0:0]  probe6 
//     .probe7                            (ram_rd_data_a_4           ) // input wire [11:0]  probe7
// );

ila_qpsk_out u_qpsk_out (
    .clk                               (clk_100M                   ),// input wire clk

    .probe0                            (qpsk_signal_out_valid_1   ),// input wire [0:0]  probe0  
    .probe1                            (qpsk_signal_out_i_1       ),// input wire [11:0]  probe1 
    .probe2                            (qpsk_signal_out_q_1       ),// input wire [11:0]  probe2 
    .probe3                            (qpsk_signal_out_valid_2   ),// input wire [0:0]  probe3 
    .probe4                            (qpsk_signal_out_i_2       ),// input wire [11:0]  probe4 
    .probe5                            (qpsk_signal_out_q_2       )// input wire [11:0]  probe5 
);

ila_qpsk_in u_ila_qpsk_in (
    .clk                               (clk_100M                  ),// input wire clk


    .probe0                            (qpsk_signal_rd_valid      ),// input wire [0:0]  probe0  
    .probe1                            (qpsk_in_i0                ),// input wire [11:0]  probe1 
    .probe2                            (qpsk_in_q0                ),// input wire [11:0]  probe2 
    .probe3                            (qpsk_signal_rd_valid      ),// input wire [0:0]  probe3 
    .probe4                            (qpsk_in_i1                ),// input wire [11:0]  probe4 
    .probe5                            (qpsk_in_q1                ) // input wire [11:0]  probe5
);

// ila_qpsk_in u_ila_adc_to_apcorrect (
//     .clk                               (clk_100M                  ),// input wire clk


//     .probe0                            (qpsk_signal_in_valid      ),// input wire [0:0]  probe0  
//     .probe1                            (qpsk_signal_in_i0         ),// input wire [11:0]  probe1 
//     .probe2                            (qpsk_signal_in_i1         ),// input wire [11:0]  probe2 
//     .probe3                            (qpsk_signal_in_valid      ),// input wire [0:0]  probe3 
//     .probe4                            (qpsk_signal_in_q0         ),// input wire [11:0]  probe4 
//     .probe5                            (qpsk_signal_in_q1         ) // input wire [11:0]  probe5
// );

ila_debug ila_debug_adc (
    .clk                               (l_clk                     ),// input wire clk


    .probe0                            (adc_data_i0[15:0]         ),// input wire [11:0]  probe0  
    .probe1                            (adc_data_q0[15:0]         ),// input wire [11:0]  probe1 
    .probe2                            (adc_data_i1[15:0]         ),// input wire [11:0]  probe2 
    .probe3                            (adc_data_q1[15:0]         ),// input wire [11:0]  probe3 
    .probe4                            (adc_enable_i0             ),// input wire [0:0]  probe4 
    .probe5                            (adc_enable_i1             ),// input wire [0:0]  probe5 
    .probe6                            (adc_enable_q0             ),// input wire [0:0]  probe6 
    .probe7                            (adc_enable_q1             ),// input wire [0:0]  probe7 
    .probe8                            (adc_valid_i0              ),// input wire [0:0]  probe8 
    .probe9                            (adc_valid_i1              ),// input wire [0:0]  probe9 
    .probe10                           (adc_valid_q0              ),// input wire [0:0]  probe10 
    .probe11                           (adc_valid_q1              ) // input wire [0:0]  probe11
);

ila_debug ila_debug_dac (
    .clk                               (l_clk                     ),// input wire clk


    .probe0                            (dac_data_i0[15:4]         ),// input wire [11:0]  probe0  
    .probe1                            (dac_data_q0[15:4]         ),// input wire [11:0]  probe1 
    .probe2                            (dac_data_i1[15:4]         ),// input wire [11:0]  probe2 
    .probe3                            (dac_data_q1[15:4]         ),// input wire [11:0]  probe3 
    .probe4                            (dac_enable_i0             ),// input wire [0:0]  probe4 
    .probe5                            (dac_enable_i1             ),// input wire [0:0]  probe5 
    .probe6                            (dac_enable_q0             ),// input wire [0:0]  probe6 
    .probe7                            (dac_enable_q1             ),// input wire [0:0]  probe7 
    .probe8                            (dac_valid_i0              ),// input wire [0:0]  probe8 
    .probe9                            (dac_valid_i1              ),// input wire [0:0]  probe9 
    .probe10                           (dac_valid_q0              ),// input wire [0:0]  probe10 
    .probe11                           (dac_valid_q1              ) // input wire [0:0]  probe11
);

// ila_spi U_SPI_ILA (
//     .clk                               (clk_100M                  ),// input wire clk


//     .probe0                            (spi_csn_0                 ),// input wire [0:0]  probe0  
//     .probe1                            (spi_clk                   ),// input wire [0:0]  probe1 
//     .probe2                            (spi_mosi                  ),// input wire [0:0]  probe2 
//     .probe3                            (spi_miso                  ) // input wire [0:0]  probe3
// );


endmodule
