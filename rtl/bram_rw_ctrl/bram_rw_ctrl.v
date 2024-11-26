module bram_wr_ctrl(
    //系统信号
    input                               clk                        ,//系统时钟
    input                               rst_n                      ,//系统复位信号，低电平有效 
    //接收uart数据接口
    input                               dout_12_valid              ,//uart接收数据有效信号
    input              [  11:0]         dout_12_a                  ,//uart接收到的12bit数据
    input              [  11:0]         dout_12_b                  ,//uart接收到的12bit数据
    //bram_tone_1
    output             [   9:0]         ram_addr_a_1                 ,//ram 读写地址a  
    output             [   9:0]         ram_addr_b_1                 ,//ram 读写地址b
    output             [  11:0]         ram_wr_data_a_1              ,//ram 写数据a
    output             [  11:0]         ram_wr_data_b_1              ,//ram 写数据b
    output                              bram_en_1                    ,//bram使能信号
    output                              bram_wea_1                   ,//bram读写选择信号
    //bram_tone_2
    output             [   9:0]         ram_addr_a_2                 ,//ram 读写地址a  
    output             [   9:0]         ram_addr_b_2                 ,//ram 读写地址b
    output             [  11:0]         ram_wr_data_a_2              ,//ram 写数据a
    output             [  11:0]         ram_wr_data_b_2              ,//ram 写数据b
    output                              bram_en_2                    ,//bram使能信号
    output                              bram_wea_2                   ,//bram读写选择信号
    //bram_tone_3
    output             [   9:0]         ram_addr_a_3                 ,//ram 读写地址a  
    output             [   9:0]         ram_addr_b_3                 ,//ram 读写地址b
    output             [  11:0]         ram_wr_data_a_3              ,//ram 写数据a
    output             [  11:0]         ram_wr_data_b_3              ,//ram 写数据b
    output                              bram_en_3                    ,//bram使能信号
    output                              bram_wea_3                   ,//bram读写选择信号
    //bram_tone_4
    output             [   9:0]         ram_addr_a_4                 ,//ram 读写地址a  
    output             [   9:0]         ram_addr_b_4                 ,//ram 读写地址b
    output             [  11:0]         ram_wr_data_a_4              ,//ram 写数据a
    output             [  11:0]         ram_wr_data_b_4              ,//ram 写数据b
    output                              bram_en_4                    ,//bram使能信号
    output                              bram_wea_4                   ,//bram读写选择信号

    //bram_qpsk_1
    output             [  14:0]         ram_addr_a_qpsk_1            ,//ram 读写地址a  
    output             [  14:0]         ram_addr_b_qpsk_1            ,//ram 读写地址b
    output             [  11:0]         ram_wr_data_a_qpsk_1         ,//ram 写数据a
    output             [  11:0]         ram_wr_data_b_qpsk_1         ,//ram 写数据b
    output                              bram_en_qpsk_1               ,//bram使能信号
    output                              bram_wea_qpsk_1              ,//bram读写选择信号
    //bram_qpsk_2
    output             [  14:0]         ram_addr_a_qpsk_2            ,//ram 读写地址a  
    output             [  14:0]         ram_addr_b_qpsk_2            ,//ram 读写地址b
    output             [  11:0]         ram_wr_data_a_qpsk_2         ,//ram 写数据a
    output             [  11:0]         ram_wr_data_b_qpsk_2         ,//ram 写数据b
    output                              bram_en_qpsk_2               ,//bram使能信号
    output                              bram_wea_qpsk_2              ,//bram读写选择信号
    
    //控制信号
    output reg                          tone_signal_wr_done          ,//输入单音信号完成信号
    output reg                          qpsk_signal_wr_done          ,//输入qpsk信号完成信号
    output reg                          tone_signal_rd_valid         ,//bram读单音数据有效信号
    output reg                          qpsk_signal_rd_valid         ,//bram读qpsk数据有效信号
    output reg                          uart_tx_start_1              ,//uart发送数据开始信号
    output reg                          uart_tx_start_2              //uart发送数据开始信号
);

//reg define
reg                    [  15:0]         uart_rev_cnt               ;//uart接收到数据计数器（一个时钟周期接收2个数据）

reg                                     bram1_din_valid            ;
reg                    [  11:0]         bram1_din_a                ;
reg                    [  11:0]         bram1_din_b                ;
reg                                     bram2_din_valid            ;
reg                    [  11:0]         bram2_din_a                ;
reg                    [  11:0]         bram2_din_b                ;
reg                                     bram3_din_valid            ;
reg                    [  11:0]         bram3_din_a                ;
reg                    [  11:0]         bram3_din_b                ;
reg                                     bram4_din_valid            ;
reg                    [  11:0]         bram4_din_a                ;
reg                    [  11:0]         bram4_din_b                ;
reg                                     bram5_din_valid            ;
reg                    [  11:0]         bram5_din_a                ;
reg                    [  11:0]         bram5_din_b                ;
reg                                     bram6_din_valid            ;
reg                    [  11:0]         bram6_din_a                ;
reg                    [  11:0]         bram6_din_b                ;

reg                                     bram_qpsk_1_din_valid      ;
reg                    [  11:0]         bram_qpsk_1_din_a          ;
reg                    [  11:0]         bram_qpsk_1_din_b          ;
reg                                     bram_qpsk_2_din_valid      ;
reg                    [  11:0]         bram_qpsk_2_din_a          ;
reg                    [  11:0]         bram_qpsk_2_din_b          ;
reg                                     bram_qpsk_3_din_valid      ;
reg                    [  11:0]         bram_qpsk_3_din_a          ;
reg                    [  11:0]         bram_qpsk_3_din_b          ;
reg                                     bram_qpsk_4_din_valid      ;
reg                    [  11:0]         bram_qpsk_4_din_a          ;
reg                    [  11:0]         bram_qpsk_4_din_b          ;
reg                                     bram_qpsk_5_din_valid      ;
reg                    [  11:0]         bram_qpsk_5_din_a          ;
reg                    [  11:0]         bram_qpsk_5_din_b          ;
reg                                     bram_qpsk_6_din_valid      ;
reg                    [  11:0]         bram_qpsk_6_din_a          ;
reg                    [  11:0]         bram_qpsk_6_din_b          ;

reg                                     tone_signal_rd_start       ;//开始读出单音数据信号
reg                                     tone_signal_rd_start_buf1  ;
reg                                     tone_signal_rd_start_buf2  ;

reg                                     qpsk_signal_rd_start       ;//开始读出qpsk数据信号
reg                                     qpsk_signal_rd_start_buf1  ;
reg                                     qpsk_signal_rd_start_buf2  ;

//wire define
wire                                    bram_wr_done_1             ;//写入bram数据完成信号
wire                                    bram_wr_done_qpsk_1        ;//写入bram数据完成信号
wire                                    bram_wr_done_2             ;//写入bram数据完成信号
wire                                    bram_wr_done_qpsk_2        ;//写入bram数据完成信号
wire                                    bram_wr_done_3             ;//写入bram数据完成信号
wire                                    bram_wr_done_qpsk_3        ;//写入bram数据完成信号
wire                                    bram_wr_done_4             ;//写入bram数据完成信号
wire                                    bram_wr_done_qpsk_4        ;//写入bram数据完成信号
wire                                    bram_wr_done_5             ;//写入bram数据完成信号
wire                                    bram_wr_done_qpsk_5        ;//写入bram数据完成信号
wire                                    bram_wr_done_6             ;//写入bram数据完成信号
wire                                    bram_wr_done_qpsk_6        ;//写入bram数据完成信号

//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------

//uart_tx_start_1赋值
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_tx_start_1 <= 1'b0;
    end
    else begin
        //上位机发送6'h000001，启动通道1数据发送
        if ((dout_12_a == 12'd0) && (dout_12_b == 12'd1) && (qpsk_signal_wr_done == 1'b1)) begin
            uart_tx_start_1 <= 1'b1;
        end
        else begin
            uart_tx_start_1 <= uart_tx_start_1;
        end
    end
end

//uart_tx_start_2赋值
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_tx_start_2 <= 1'b0;
    end
    else begin
        //上位机发送6'h000002，启动通道2数据发送
        if ((dout_12_a == 12'd0) && (dout_12_b == 12'd2) && (qpsk_signal_wr_done == 1'b1)) begin
            uart_tx_start_2 <= 1'b1;
        end
        else begin
            uart_tx_start_2 <= uart_tx_start_2;
        end
    end
end

//bram读单音数据有效信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tone_signal_rd_start_buf1 <= 1'b0;
        tone_signal_rd_valid <= 1'b0;
    end
    else begin
        tone_signal_rd_start_buf1 <= tone_signal_rd_start;
        tone_signal_rd_valid <= tone_signal_rd_start_buf1;
    end
end

//开始读出单音数据信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tone_signal_rd_start <= 1'b0;
    end
    else begin
        //上位机发送6'hffffff，令单音信号通入单音校正模块
        if ((uart_rev_cnt >= 16'd21024) && (dout_12_a == 12'b1111_1111_1111) && (dout_12_b == 12'b1111_1111_1111)) begin
            tone_signal_rd_start <= 1'b1;
        end
        else begin
            tone_signal_rd_start <= tone_signal_rd_start;
        end
    end
end

//bram读qpsk数据有效信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_signal_rd_start_buf1 <= 1'b0;
        qpsk_signal_rd_start_buf2 <= 1'b0;
        qpsk_signal_rd_valid <= 1'b0;
    end
    else begin
        qpsk_signal_rd_start_buf1 <= qpsk_signal_rd_start;
        qpsk_signal_rd_start_buf2 <= qpsk_signal_rd_start_buf1;
        qpsk_signal_rd_valid <= qpsk_signal_rd_start_buf2;
    end
end

//开始读出qpsk数据信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_signal_rd_start <= 1'b0;
    end
    else begin
        //上位机发送6'h000fff，令QPSK信号通入幅相校正模块
        if ((uart_rev_cnt >= 16'd21024) && (dout_12_a == 12'b0000_0000_0000) && (dout_12_b == 12'b1111_1111_1111)) begin
            qpsk_signal_rd_start <= 1'b1;
        end
        else begin
            qpsk_signal_rd_start <= qpsk_signal_rd_start;
        end
    end
end

//单音信号输入完成信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tone_signal_wr_done <= 1'b0;
    end
    else begin
        if (bram_wr_done_2) begin
            tone_signal_wr_done <= 1'b1;
        end
        else begin
            tone_signal_wr_done <= tone_signal_wr_done;
        end
    end
end

//qpsk信号输入完成信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_signal_wr_done <= 1'b0;
    end
    else begin
        if (bram_wr_done_qpsk_2) begin
            qpsk_signal_wr_done <= 1'b1;
        end
        else begin
            qpsk_signal_wr_done <= qpsk_signal_wr_done;
        end
    end
end

//uart接收到数据计数器
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_rev_cnt <= 16'b0;
    end
    else begin
        if (dout_12_valid) begin
            uart_rev_cnt <= uart_rev_cnt + 1'b1;
        end
        else begin
            uart_rev_cnt <= uart_rev_cnt;
        end
    end
end

//单音BRAM1
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bram1_din_valid <= 1'b0;
        bram1_din_a <= 12'b0;
        bram1_din_b <= 12'b0;
    end
    else begin
        if (uart_rev_cnt < 16'd256) begin
            bram1_din_valid <= dout_12_valid;
            bram1_din_a <= dout_12_a;
            bram1_din_b <= dout_12_b;
        end
        else begin
            bram1_din_valid <= 1'b0;
            bram1_din_a <= 12'b0;
            bram1_din_b <= 12'b0;
        end
    end
end

//单音BRAM2
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bram2_din_valid <= 1'b0;
        bram2_din_a <= 12'b0;
        bram2_din_b <= 12'b0;
    end
    else begin
        if (uart_rev_cnt >= 16'd256 && uart_rev_cnt < 16'd512) begin
            bram2_din_valid <= dout_12_valid;
            bram2_din_a <= dout_12_a;
            bram2_din_b <= dout_12_b;
        end
        else begin
            bram2_din_valid <= 1'b0;
            bram2_din_a <= 12'b0;
            bram2_din_b <= 12'b0;
        end
    end
end

//单音BRAM3
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bram3_din_valid <= 1'b0;
        bram3_din_a <= 12'b0;
        bram3_din_b <= 12'b0;
    end
    else begin
        if (uart_rev_cnt >= 16'd512 && uart_rev_cnt < 16'd768) begin
            bram3_din_valid <= dout_12_valid;
            bram3_din_a <= dout_12_a;
            bram3_din_b <= dout_12_b;
        end
        else begin
            bram3_din_valid <= 1'b0;
            bram3_din_a <= 12'b0;
            bram3_din_b <= 12'b0;
        end
    end
end

//单音BRAM4
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bram4_din_valid <= 1'b0;
        bram4_din_a <= 12'b0;
        bram4_din_b <= 12'b0;
    end
    else begin
        if (uart_rev_cnt >= 16'd768 && uart_rev_cnt < 16'd1024) begin
            bram4_din_valid <= dout_12_valid;
            bram4_din_a <= dout_12_a;
            bram4_din_b <= dout_12_b;
        end
        else begin
            bram4_din_valid <= 1'b0;
            bram4_din_a <= 12'b0;
            bram4_din_b <= 12'b0;
        end
    end
end

//qpsk信号BRAM1
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bram_qpsk_1_din_valid <= 1'b0;
        bram_qpsk_1_din_a <= 12'b0;
        bram_qpsk_1_din_b <= 12'b0;
    end
    else begin
        if ((uart_rev_cnt >= 16'd1024) && (uart_rev_cnt < 16'd11024)) begin
            bram_qpsk_1_din_valid <= dout_12_valid;
            bram_qpsk_1_din_a <= dout_12_a;
            bram_qpsk_1_din_b <= dout_12_b;
        end
        else begin
            bram_qpsk_1_din_valid <= 1'b0;
            bram_qpsk_1_din_a <= 12'b0;
            bram_qpsk_1_din_b <= 12'b0;
        end
    end
end

//qpsk信号BRAM2
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bram_qpsk_2_din_valid <= 1'b0;
        bram_qpsk_2_din_a <= 12'b0;
        bram_qpsk_2_din_b <= 12'b0;
    end
    else begin
        if ((uart_rev_cnt >= 16'd11024) && (uart_rev_cnt < 16'd21024)) begin
            bram_qpsk_2_din_valid <= dout_12_valid;
            bram_qpsk_2_din_a <= dout_12_a;
            bram_qpsk_2_din_b <= dout_12_b;
        end
        else begin
            bram_qpsk_2_din_valid <= 1'b0;
            bram_qpsk_2_din_a <= 12'b0;
            bram_qpsk_2_din_b <= 12'b0;
        end
    end
end

//模块例化
//单音BRAM控制模块1
bram_wr_ctrl_tone u_bram_wr_ctrl_tone_1(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .uart_rev_12_valid                 (bram1_din_valid           ),
    .uart_rev_12_a                     (bram1_din_a               ),
    .uart_rev_12_b                     (bram1_din_b               ),
    .ram_addr_a                        (ram_addr_a_1              ),
    .ram_addr_b                        (ram_addr_b_1              ),
    .ram_wr_data_a                     (ram_wr_data_a_1           ),
    .ram_wr_data_b                     (ram_wr_data_b_1           ),
    .bram_en                           (bram_en_1                 ),
    .bram_wea                          (bram_wea_1                ),
    .bram_wr_done                      (bram_wr_done_1            ),
    .bram_rd_start_en                  (tone_signal_rd_start      ) 
);


//单音BRAM控制模块2
bram_wr_ctrl_tone u_bram_wr_ctrl_tone_2(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .uart_rev_12_valid                 (bram2_din_valid           ),
    .uart_rev_12_a                     (bram2_din_a               ),
    .uart_rev_12_b                     (bram2_din_b               ),
    .ram_addr_a                        (ram_addr_a_2              ),
    .ram_addr_b                        (ram_addr_b_2              ),
    .ram_wr_data_a                     (ram_wr_data_a_2           ),
    .ram_wr_data_b                     (ram_wr_data_b_2           ),
    .bram_en                           (bram_en_2                 ),
    .bram_wea                          (bram_wea_2                ),
    .bram_wr_done                      (bram_wr_done_2            ),
    .bram_rd_start_en                  (tone_signal_rd_start      ) 
);

//单音BRAM控制模块3
bram_wr_ctrl_tone u_bram_wr_ctrl_tone_3(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .uart_rev_12_valid                 (bram3_din_valid           ),
    .uart_rev_12_a                     (bram3_din_a               ),
    .uart_rev_12_b                     (bram3_din_b               ),
    .ram_addr_a                        (ram_addr_a_3              ),
    .ram_addr_b                        (ram_addr_b_3              ),
    .ram_wr_data_a                     (ram_wr_data_a_3           ),
    .ram_wr_data_b                     (ram_wr_data_b_3           ),
    .bram_en                           (bram_en_3                 ),
    .bram_wea                          (bram_wea_3                ),
    .bram_wr_done                      (bram_wr_done_3            ),
    .bram_rd_start_en                  (tone_signal_rd_start      ) 
);

//单音BRAM控制模块4
bram_wr_ctrl_tone u_bram_wr_ctrl_tone_4(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .uart_rev_12_valid                 (bram4_din_valid           ),
    .uart_rev_12_a                     (bram4_din_a               ),
    .uart_rev_12_b                     (bram4_din_b               ),
    .ram_addr_a                        (ram_addr_a_4              ),
    .ram_addr_b                        (ram_addr_b_4              ),
    .ram_wr_data_a                     (ram_wr_data_a_4           ),
    .ram_wr_data_b                     (ram_wr_data_b_4           ),
    .bram_en                           (bram_en_4                 ),
    .bram_wea                          (bram_wea_4                ),
    .bram_wr_done                      (bram_wr_done_4            ),
    .bram_rd_start_en                  (tone_signal_rd_start      ) 
);

//qpsk信号BRAM控制模块1
bram_wr_ctrl_qpsk u_bram_wr_ctrl_qpsk_1(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .uart_rev_12_valid                 (bram_qpsk_1_din_valid     ),
    .uart_rev_12_a                     (bram_qpsk_1_din_a         ),
    .uart_rev_12_b                     (bram_qpsk_1_din_b         ),
    .ram_addr_a                        (ram_addr_a_qpsk_1         ),
    .ram_addr_b                        (ram_addr_b_qpsk_1         ),
    .ram_wr_data_a                     (ram_wr_data_a_qpsk_1      ),
    .ram_wr_data_b                     (ram_wr_data_b_qpsk_1      ),
    .bram_en                           (bram_en_qpsk_1            ),
    .bram_wea                          (bram_wea_qpsk_1           ),
    .bram_wr_done                      (bram_wr_done_qpsk_1       ),
    .bram_rd_start_en                  (qpsk_signal_rd_start      ) 
);

//qpsk信号BRAM控制模块2
bram_wr_ctrl_qpsk u_bram_wr_ctrl_qpsk_2(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .uart_rev_12_valid                 (bram_qpsk_2_din_valid     ),
    .uart_rev_12_a                     (bram_qpsk_2_din_a         ),
    .uart_rev_12_b                     (bram_qpsk_2_din_b         ),
    .ram_addr_a                        (ram_addr_a_qpsk_2         ),
    .ram_addr_b                        (ram_addr_b_qpsk_2         ),
    .ram_wr_data_a                     (ram_wr_data_a_qpsk_2      ),
    .ram_wr_data_b                     (ram_wr_data_b_qpsk_2      ),
    .bram_en                           (bram_en_qpsk_2            ),
    .bram_wea                          (bram_wea_qpsk_2           ),
    .bram_wr_done                      (bram_wr_done_qpsk_2       ),
    .bram_rd_start_en                  (qpsk_signal_rd_start      ) 
);

endmodule