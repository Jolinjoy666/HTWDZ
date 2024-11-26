module uart_rx_ctrl(
    //系统信号
    input                               clk                        ,//系统时钟
    input                               rst_n                      ,//系统复位，低电平有效
    //UART控制信号
    input                               uart_done                  ,//接收一帧数据完成标志
    input              [   7:0]         uart_data                  ,//接收的数据
    //8转12接口
    output reg         [  11:0]         dout_12_a                  ,//输出数据a
    output reg         [  11:0]         dout_12_b                  ,//输出数据b
    output reg                          dout_12_valid               //输出数据有效信号
    );

//reg define
reg                    [   1:0]         data_8bit_cnt              ;//输入8bit数据计数器
reg                    [   7:0]         data_buf                   ;
reg                    [   7:0]         data_buf_1                 ;
reg                    [   7:0]         data_buf_2                 ;
reg                    [   7:0]         data_buf_3                 ;

//wire define

//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------

//输入8bit数据计数器
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_8bit_cnt <= 2'b0;
    end
    else begin
        if (uart_done) begin
            data_8bit_cnt <= data_8bit_cnt + 1'b1;
        end
        else if (data_8bit_cnt == 2'd3) begin
            data_8bit_cnt <= 2'b0;
        end
        else begin
            data_8bit_cnt <= data_8bit_cnt;
        end
    end
end

//data_buf赋值
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_buf <= 8'b0;
    end
    else begin
        if (uart_done) begin
            data_buf <= uart_data;
        end
        else begin
            data_buf <= data_buf;
        end
    end
end

//dout_12赋值
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dout_12_a <= 12'b0;
        dout_12_b <= 12'b0;
    end
    else begin
        case (data_8bit_cnt)
            1: begin
                dout_12_a[11:4] <= data_buf;
                dout_12_b <= dout_12_b;
            end
            2: begin
                dout_12_a[3:0] <= data_buf[7:4];
                dout_12_b[11:8] <= data_buf[3:0];
            end
            3: begin
                dout_12_a <= dout_12_a;
                dout_12_b[7:0] <= data_buf;
            end
            default: begin
                dout_12_a <= dout_12_a;
                dout_12_b <= dout_12_b;
            end
        endcase
    end
end

//dout_12_valid赋值
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dout_12_valid <= 1'b0;
    end
    else begin
        if (data_8bit_cnt == 2'd3) begin
            dout_12_valid <= 1'b1;
        end
        else begin
            dout_12_valid <= 1'b0;
        end
    end
end

endmodule