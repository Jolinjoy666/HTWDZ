module uart_tx_ctrl(
    //系统信号
    input                               clk                        ,//系统时钟
    input                               rst_n                      ,//系统复位，低有效
    //uart_tx模块接口
    input                               uart_tx_busy               ,//发送忙状态信号
    output                              uart_tx_en                 ,//UART发送使能
    output             [   7:0]         uart_tx_data               ,//UART要发送的数据
    //发送控制信号接口
    input                               tone_signal_wr_done        ,//输入单音信号完成信号
    input                               qpsk_signal_wr_done        ,//输入qpsk信号完成信号
    input                               s_amp_phase_ready          ,//幅相校正模块就绪信号
    input                               uart_tx_start_1            ,//uart发送数据开始信号    
    input                               uart_tx_start_2            ,//uart发送数据开始信号
    //幅相校正输出数据接口
    input                               qpsk_signal_wr_over        ,//幅相校正输出数据全部存入bram信号
    output reg                          uart_tx_24_done            ,//UART发送24bit数据完成信号
    input              [  11:0]         qpsk_signal_out_a          ,//幅相校正完成输出数据a
    input              [  11:0]         qpsk_signal_out_b           //幅相校正完成输出数据b
);

//reg define
reg                                     uart_tx_en                 ;//UART发送使能
reg                    [   7:0]         uart_tx_data               ;//UART要发送的数据
reg                                     tone_signal_wr_done_buf    ;
reg                                     qpsk_signal_wr_done_buf    ;
reg                                     s_amp_phase_ready_buf      ;
reg                                     qpsk_signal_wr_over_buf    ;

reg                    [   7:0]         qpsk_signal_out_buf1       ;//幅相校正输出数据暂存
reg                    [   7:0]         qpsk_signal_out_buf2       ;
reg                    [   7:0]         qpsk_signal_out_buf3       ;

reg                    [   3:0]         qpsk_signal_out_index      ;//发送幅相校正数据索引

reg                    [  15:0]         qpsk_signal_out_cnt        ;//发送幅相校正数据计数器 

reg                                     uart_tx_start_buf          ;//UART开始发送信号暂存

//wire define

//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------

//UART开始发送信号暂存
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_tx_start_buf <= 1'b0;
    end
    else begin
        if (qpsk_signal_out_cnt < 16'd10000) begin
            uart_tx_start_buf <= uart_tx_start_1;
        end
        else if (qpsk_signal_out_cnt >= 16'd10000 && qpsk_signal_out_cnt < 16'd20000) begin
            uart_tx_start_buf <= uart_tx_start_2;
        end
        else begin
            uart_tx_start_buf <= 1'b0;
        end
    end
end

//发送幅相校正数据计数器
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_signal_out_cnt <= 16'b0;
    end
    else begin
        if (qpsk_signal_out_cnt >= 16'd20000) begin
            qpsk_signal_out_cnt <= 16'd20000;
        end
        else if (qpsk_signal_out_index == 4'd11) begin
            qpsk_signal_out_cnt <= qpsk_signal_out_cnt + 1'b1;
        end
        else begin
            qpsk_signal_out_cnt <= qpsk_signal_out_cnt;
        end
    end
end

//发送幅相校正数据索引
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_signal_out_index <= 4'b0;
    end
    else begin
        if (uart_tx_start_buf) begin
            if (qpsk_signal_out_index == 4'd11) begin
                qpsk_signal_out_index <= 4'b0;
            end
            else if (!uart_tx_busy) begin
                qpsk_signal_out_index <= qpsk_signal_out_index + 1'b1;
            end
            else begin
                qpsk_signal_out_index <= qpsk_signal_out_index;
            end
        end
        else begin
            qpsk_signal_out_index <= qpsk_signal_out_index;
        end
    end
end

//UART发送24bit数据完成信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_tx_24_done <= 1'b0;
    end
    else begin
        if (qpsk_signal_out_index == 4'd8) begin
            uart_tx_24_done <= 1'b1;
        end
        else begin
            uart_tx_24_done <= 1'b0;
        end
    end
end

//幅相校正输出数据暂存
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_signal_out_buf1 <= 8'b0;
        qpsk_signal_out_buf2 <= 8'b0;
        qpsk_signal_out_buf3 <= 8'b0;
    end
    else begin
        if (qpsk_signal_wr_over) begin
            qpsk_signal_out_buf1 <= qpsk_signal_out_a[11:4];
            qpsk_signal_out_buf2 <= {qpsk_signal_out_a[3:0],qpsk_signal_out_b[11:8]};
            qpsk_signal_out_buf3 <= qpsk_signal_out_b[7:0];
        end
        else begin
            qpsk_signal_out_buf1 <= qpsk_signal_out_buf1;
            qpsk_signal_out_buf2 <= qpsk_signal_out_buf2;
            qpsk_signal_out_buf3 <= qpsk_signal_out_buf3;
        end
    end
end

//s_amp_phase_ready暂存
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s_amp_phase_ready_buf <= 1'b0;
    end
    else begin
        s_amp_phase_ready_buf <= s_amp_phase_ready;
    end
end

//tone_signal_wr_done暂存
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tone_signal_wr_done_buf <= 1'b0;
    end
    else begin
        tone_signal_wr_done_buf <= tone_signal_wr_done;
    end
end

//qpsk_signal_wr_done暂存
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_signal_wr_done_buf <= 1'b0;
    end
    else begin
        qpsk_signal_wr_done_buf <= qpsk_signal_wr_done;
    end
end

//qpsk_signal_wr_over暂存
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_signal_wr_over_buf <= 1'b0;
    end
    else begin
        qpsk_signal_wr_over_buf <= qpsk_signal_wr_over;
    end
end

//UART发送使能
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_tx_en <= 1'b0;
    end
    else begin
        if (tone_signal_wr_done & ~tone_signal_wr_done_buf) begin
            uart_tx_en <= 1'b1;
        end
        else if (qpsk_signal_wr_done & ~qpsk_signal_wr_done_buf) begin
            uart_tx_en <= 1'b1;
        end
        else if (s_amp_phase_ready & ~s_amp_phase_ready_buf) begin
            uart_tx_en <= 1'b1;
        end
        else if (qpsk_signal_wr_over & ~qpsk_signal_wr_over_buf) begin
            uart_tx_en <= 1'b1;
        end
        else begin
            if (qpsk_signal_out_cnt < 16'd20000) begin
                if (uart_tx_start_buf == 1'b1 && qpsk_signal_out_index == 4'd2) begin
                    uart_tx_en <= 1'b1;
                end
                else if (uart_tx_start_buf == 1'b1 && qpsk_signal_out_index == 4'd5) begin
                    uart_tx_en <= 1'b1;
                end
                else if (uart_tx_start_buf == 1'b1 && qpsk_signal_out_index == 4'd8) begin
                    uart_tx_en <= 1'b1;
                end
                else begin
                    uart_tx_en <= 1'b0;
                end
            end
            else begin
                uart_tx_en <= 1'b0;
            end
        end
    end
end

//UART发送数据
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_tx_data <= 8'b0;
    end
    else begin
        if (tone_signal_wr_done & ~tone_signal_wr_done_buf) begin
            uart_tx_data <= 8'b0000_0001;
        end
        else if (qpsk_signal_wr_done & ~qpsk_signal_wr_done_buf) begin
            uart_tx_data <= 8'b0000_0010;
        end
        else if (s_amp_phase_ready & ~s_amp_phase_ready_buf) begin
            uart_tx_data <= 8'b0000_0011;
        end
        else if (qpsk_signal_wr_over & ~qpsk_signal_wr_over_buf) begin
            uart_tx_data <= 8'b0000_0100;
        end
        else begin
            if (qpsk_signal_out_cnt < 16'd20000) begin
                if (uart_tx_start_buf == 1'b1 && qpsk_signal_out_index == 4'd2) begin
                    uart_tx_data <= qpsk_signal_out_buf1;
                end
                else if (uart_tx_start_buf == 1'b1 && qpsk_signal_out_index == 4'd5) begin
                    uart_tx_data <= qpsk_signal_out_buf2;
                end
                else if (uart_tx_start_buf == 1'b1 && qpsk_signal_out_index == 4'd8) begin
                    uart_tx_data <= qpsk_signal_out_buf3;
                end
                else begin
                    uart_tx_data <= 8'b0;
                end
            end
            else begin
                uart_tx_data <= 8'b0;
            end
        end
    end
end

endmodule