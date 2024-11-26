module bram_rw_ctrl_dout(
    //系统信号
    input                               clk                        ,//系统时钟
    input                               rst_n                      ,//系统复位信号，低电平有效 
    //幅相校正数据接口
    input                               qpsk_signal_out_valid      ,//qpsk输出有效信号
    input              [  11:0]         qpsk_signal_out_i          ,
    input              [  11:0]         qpsk_signal_out_q          ,
    input              [  16:0]         signal_out_index           ,//幅相校正输出信号索引
    //bram_qpsk_out_1
    output reg         [  14:0]         ram_addr_a_qpsk_out        ,//ram 读写地址a  
    output reg         [  14:0]         ram_addr_b_qpsk_out        ,//ram 读写地址b
    output             [  11:0]         ram_wr_data_a_qpsk_out     ,//ram 写数据a
    output             [  11:0]         ram_wr_data_b_qpsk_out     ,//ram 写数据b
    output                              bram_en_qpsk_out           ,//bram使能信号
    output reg                          bram_wea_qpsk_out          ,//bram读写选择信号
    //uart发送控制模块接口
    output reg                          qpsk_signal_wr_over        ,//幅相校正输出数据全部存入bram信号
    input                               uart_tx_24_done            ,//uart发送一次数据完成信号
    input                               uart_tx_start               //通道uart发送数据开始信号
);

//reg define
reg                                     qpsk_signal_wr_over_buf    ;//幅相校正输出数据全部存入bram信号暂存

//wire define


//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------

//bram使能信号
assign bram_en_qpsk_out = qpsk_signal_out_valid;

//ram 写数据
assign ram_wr_data_a_qpsk_out = qpsk_signal_out_i;
assign ram_wr_data_b_qpsk_out = qpsk_signal_out_q;

//幅相校正输出数据全部存入bram信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_signal_wr_over <= 1'b0;
    end
    else begin
        qpsk_signal_wr_over <= qpsk_signal_wr_over_buf;
    end
end

//幅相校正输出数据全部存入bram信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_signal_wr_over_buf <= 1'b0;
    end
    else begin
        if (signal_out_index >= 17'd9999) begin
            qpsk_signal_wr_over_buf <= 1'b1;
        end
        else begin
            qpsk_signal_wr_over_buf <= qpsk_signal_wr_over_buf;
        end
    end
end

//bram读写控制信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bram_wea_qpsk_out <= 1'b1;
    end
    else begin
        if (signal_out_index < 17'd9999) begin
            bram_wea_qpsk_out <= 1'b1;
        end
        else begin
            bram_wea_qpsk_out <= 1'b0;
        end
    end
end

//bram写地址
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ram_addr_a_qpsk_out <= 15'd0;
        ram_addr_b_qpsk_out <= 15'd10000;
    end
    else begin
        if (signal_out_index > 17'd9999) begin
            if ((ram_addr_a_qpsk_out == 15'd19998) && (ram_addr_b_qpsk_out == 15'd19999)) begin
                ram_addr_a_qpsk_out <= ram_addr_a_qpsk_out;
                ram_addr_b_qpsk_out <= ram_addr_b_qpsk_out;
            end
            else begin
                if (uart_tx_start) begin
                    if (uart_tx_24_done) begin
                        ram_addr_a_qpsk_out <= ram_addr_a_qpsk_out + 15'd2;
                        ram_addr_b_qpsk_out <= ram_addr_b_qpsk_out + 15'd2;
                    end
                    else begin
                        ram_addr_a_qpsk_out <= ram_addr_a_qpsk_out;
                        ram_addr_b_qpsk_out <= ram_addr_b_qpsk_out;
                    end
                end
                else begin
                    ram_addr_a_qpsk_out <= ram_addr_a_qpsk_out;
                    ram_addr_b_qpsk_out <= ram_addr_b_qpsk_out;
                end
            end
        end
        else if (signal_out_index == 17'd9999) begin
            ram_addr_a_qpsk_out <= 15'd0;
            ram_addr_b_qpsk_out <= 15'd1;
        end
        else begin
            if (qpsk_signal_out_valid) begin
                ram_addr_a_qpsk_out <= ram_addr_a_qpsk_out + 15'd1;
                ram_addr_b_qpsk_out <= ram_addr_b_qpsk_out + 15'd1;
            end
            else begin
                ram_addr_a_qpsk_out <= ram_addr_a_qpsk_out;
                ram_addr_b_qpsk_out <= ram_addr_b_qpsk_out;
            end
        end
    end
end

endmodule