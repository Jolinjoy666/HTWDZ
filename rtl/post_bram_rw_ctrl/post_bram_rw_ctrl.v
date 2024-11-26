module post_bram_rw_ctrl(
    //系统信号
    input                               clk                        ,//系统时钟
    input                               rst_n                      ,//系统复位信号，低电平有效 
    //幅相校正数据接口
    input                               qpsk_signal_out_valid_1    ,//qpsk输出有效信号
    input              [  11:0]         qpsk_signal_out_i_1        ,
    input              [  11:0]         qpsk_signal_out_q_1        ,
    input              [  16:0]         signal_out_index_1         ,//幅相校正输出信号索引
    
    input                               qpsk_signal_out_valid_2    ,//qpsk输出有效信号
    input              [  11:0]         qpsk_signal_out_i_2        ,
    input              [  11:0]         qpsk_signal_out_q_2        ,
    input              [  16:0]         signal_out_index_2         ,//幅相校正输出信号索引

    //bram_qpsk_out_1
    output             [  14:0]         ram_addr_a_qpsk_out_1      ,//ram 读写地址a  
    output             [  14:0]         ram_addr_b_qpsk_out_1      ,//ram 读写地址b
    output             [  11:0]         ram_wr_data_a_qpsk_out_1   ,//ram 写数据a
    output             [  11:0]         ram_wr_data_b_qpsk_out_1   ,//ram 写数据b
    output                              bram_en_qpsk_out_1         ,//bram使能信号
    output                              bram_wea_qpsk_out_1        ,//bram读写选择信号
    input              [  11:0]         ram_rd_data_a_qpsk_out_1   ,//ram 读数据a
    input              [  11:0]         ram_rd_data_b_qpsk_out_1   ,//ram 读数据b
    //bram_qpsk_out_2
    output             [  14:0]         ram_addr_a_qpsk_out_2      ,//ram 读写地址a  
    output             [  14:0]         ram_addr_b_qpsk_out_2      ,//ram 读写地址b
    output             [  11:0]         ram_wr_data_a_qpsk_out_2   ,//ram 写数据a
    output             [  11:0]         ram_wr_data_b_qpsk_out_2   ,//ram 写数据b
    output                              bram_en_qpsk_out_2         ,//bram使能信号
    output                              bram_wea_qpsk_out_2        ,//bram读写选择信号
    input              [  11:0]         ram_rd_data_a_qpsk_out_2   ,//ram 读数据a
    input              [  11:0]         ram_rd_data_b_qpsk_out_2   ,//ram 读数据b

    //uart发送控制模块接口
    output                              qpsk_signal_wr_over        ,//幅相校正输出数据全部存入bram信号
    input                               uart_tx_24_done            ,//uart发送一次数据完成信号
    output             [  11:0]         qpsk_signal_out_a          ,//幅相校正完成输出数据a
    output             [  11:0]         qpsk_signal_out_b          ,//幅相校正完成输出数据b
    //uart发送启动信号
    input                               uart_tx_start_1            ,//uart发送数据开始信号
    input                               uart_tx_start_2             //uart发送数据开始信号
);

//reg define

//wire define
wire                                    qpsk_signal_wr_over_1      ;
wire                                    qpsk_signal_wr_over_2      ;
wire                                    qpsk_signal_wr_over_3      ;
wire                                    qpsk_signal_wr_over_4      ;
wire                                    qpsk_signal_wr_over_5      ;
wire                                    qpsk_signal_wr_over_6      ;

//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------

//幅相校正输出数据全部存入bram信号
assign qpsk_signal_wr_over = qpsk_signal_wr_over_1;

//幅相校正完成输出数据赋值
assign qpsk_signal_out_a = (uart_tx_start_2 == 1'b1) ? ram_rd_data_a_qpsk_out_2
                         : ((uart_tx_start_1 == 1'b1) ? ram_rd_data_a_qpsk_out_1
                         : 12'b0);

assign qpsk_signal_out_b = (uart_tx_start_2 == 1'b1) ? ram_rd_data_b_qpsk_out_2
                         : ((uart_tx_start_1 == 1'b1) ? ram_rd_data_b_qpsk_out_1
                         : 12'b0);

//模块例化
//幅相校正输出数据BRAM控制模块1
bram_rw_ctrl_dout u_bram_rw_ctrl_dout_1(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .qpsk_signal_out_valid             (qpsk_signal_out_valid_1   ),
    .qpsk_signal_out_i                 (qpsk_signal_out_i_1       ),
    .qpsk_signal_out_q                 (qpsk_signal_out_q_1       ),
    .signal_out_index                  (signal_out_index_1        ),
    .ram_addr_a_qpsk_out               (ram_addr_a_qpsk_out_1     ),
    .ram_addr_b_qpsk_out               (ram_addr_b_qpsk_out_1     ),
    .ram_wr_data_a_qpsk_out            (ram_wr_data_a_qpsk_out_1  ),
    .ram_wr_data_b_qpsk_out            (ram_wr_data_b_qpsk_out_1  ),
    .bram_en_qpsk_out                  (bram_en_qpsk_out_1        ),
    .bram_wea_qpsk_out                 (bram_wea_qpsk_out_1       ),
    .qpsk_signal_wr_over               (qpsk_signal_wr_over_1     ),
    .uart_tx_24_done                   (uart_tx_24_done           ),
    .uart_tx_start                     (uart_tx_start_1           ) 
);
//幅相校正输出数据BRAM控制模块2
bram_rw_ctrl_dout u_bram_rw_ctrl_dout_2(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .qpsk_signal_out_valid             (qpsk_signal_out_valid_2   ),
    .qpsk_signal_out_i                 (qpsk_signal_out_i_2       ),
    .qpsk_signal_out_q                 (qpsk_signal_out_q_2       ),
    .signal_out_index                  (signal_out_index_2        ),
    .ram_addr_a_qpsk_out               (ram_addr_a_qpsk_out_2     ),
    .ram_addr_b_qpsk_out               (ram_addr_b_qpsk_out_2     ),
    .ram_wr_data_a_qpsk_out            (ram_wr_data_a_qpsk_out_2  ),
    .ram_wr_data_b_qpsk_out            (ram_wr_data_b_qpsk_out_2  ),
    .bram_en_qpsk_out                  (bram_en_qpsk_out_2        ),
    .bram_wea_qpsk_out                 (bram_wea_qpsk_out_2       ),
    .qpsk_signal_wr_over               (qpsk_signal_wr_over_2     ),
    .uart_tx_24_done                   (uart_tx_24_done           ),
    .uart_tx_start                     (uart_tx_start_2           ) 
);

endmodule