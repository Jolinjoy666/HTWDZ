module uart(
    //系统信号
    input                               clk                        ,//系统时钟
    input                               rst_n                      ,//系统复位，低有效
    //uart接口
    input                               uart_rxd                   ,//UART接收端口
    output                              uart_txd                   ,//UART发送端口
    //8转12接口
    output             [  11:0]         dout_12_a                  ,//输出数据a
    output             [  11:0]         dout_12_b                  ,//输出数据b
    output                              dout_12_valid              ,//输出数据有效信号
    //uart发送控制信号接口
    input                               tone_signal_wr_done        ,//输入单音信号完成信号
    input                               qpsk_signal_wr_done        ,//输入qpsk信号完成信号
    input                               s_amp_phase_ready          ,//幅相校正模块就绪信号
    input                               uart_tx_start_1            ,//uart发送数据开始信号
    input                               uart_tx_start_2            ,//uart发送数据开始信号
    //幅相校正输出数据接口
    input                               qpsk_signal_wr_over        ,//幅相校正输出数据全部存入bram信号
    output                              uart_tx_24_done            ,//UART发送24bit数据完成信号
    input              [  11:0]         qpsk_signal_out_a          ,//幅相校正完成输出数据a
    input              [  11:0]         qpsk_signal_out_b           //幅相校正完成输出数据b
);

//parameter define
parameter                               CLK_FREQ = 100000000       ;//定义系统时钟频率
parameter                               UART_BPS = 115200          ;//定义串口波特率

//reg define

//wire define
wire                                    uart_tx_en                 ;
wire                   [   7:0]         uart_tx_data               ;
wire                                    uart_rx_done               ;///UART接收完成
wire                   [   7:0]         uart_rx_data               ;///UART接收数据
wire                                    uart_tx_busy               ;

//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------

//串口接收模块
uart_rx #(
    .CLK_FREQ                          (CLK_FREQ                  ),
    .UART_BPS                          (UART_BPS                  ) 
    )
    u_uart_rx(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .uart_rxd                          (uart_rxd                  ),
    .uart_rx_done                      (uart_rx_done              ),
    .uart_rx_data                      (uart_rx_data              ) 
    );

//串口发送模块 
uart_tx #(
    .CLK_FREQ                          (CLK_FREQ                  ),
    .UART_BPS                          (UART_BPS                  ) 
    )
    u_uart_tx(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .uart_tx_en                        (uart_tx_en                ),
    .uart_tx_data                      (uart_tx_data              ),
    .uart_txd                          (uart_txd                  ),
    .uart_tx_busy                      (uart_tx_busy              ) 
    );

//串口发送控制模块
uart_tx_ctrl u_uart_tx_ctrl(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .tone_signal_wr_done               (tone_signal_wr_done       ),
    .qpsk_signal_wr_done               (qpsk_signal_wr_done       ),
    .s_amp_phase_ready                 (s_amp_phase_ready         ),
    .uart_tx_en                        (uart_tx_en                ),
    .uart_tx_data                      (uart_tx_data              ),
    .uart_tx_busy                      (uart_tx_busy              ),
    .uart_tx_24_done                   (uart_tx_24_done           ),
    .qpsk_signal_wr_over               (qpsk_signal_wr_over       ),
    .qpsk_signal_out_a                 (qpsk_signal_out_a         ),
    .qpsk_signal_out_b                 (qpsk_signal_out_b         ),
    .uart_tx_start_1                   (uart_tx_start_1           ),
    .uart_tx_start_2                   (uart_tx_start_2           )
);

//串口接收控制模块（8位数据转12位数据）
uart_rx_ctrl u_uart_rx_ctrl(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .uart_done                         (uart_rx_done              ),
    .uart_data                         (uart_rx_data              ),
    .dout_12_a                         (dout_12_a                 ),
    .dout_12_b                         (dout_12_b                 ),
    .dout_12_valid                     (dout_12_valid             ) 
);

endmodule