module bram_wr_ctrl_qpsk(
    //系统信号
    input                               clk                        ,//系统时钟
    input                               rst_n                      ,//系统复位信号，低电平有效 
    //UART接口
    input                               uart_rev_12_valid          ,//uart接收数据有效信号
    input              [  11:0]         uart_rev_12_a              ,//uart接收到的12bit数据
    input              [  11:0]         uart_rev_12_b              ,//uart接收到的12bit数据
    //bram_qpsk
    output reg         [  14:0]         ram_addr_a                 ,//ram 读写地址a  
    output reg         [  14:0]         ram_addr_b                 ,//ram 读写地址b
    output reg         [  11:0]         ram_wr_data_a              ,//ram 写数据a
    output reg         [  11:0]         ram_wr_data_b              ,//ram 写数据b
    output reg                          bram_en                    ,//bram使能信号
    output reg                          bram_wea                   ,//bram读写选择信号
    output reg                          bram_wr_done               ,//bram写入数据完成信号
    
    input                               bram_rd_start_en            //bram开始读使能信号
);

//reg define
reg                    [  15:0]         uart_rev_cnt               ;//uart接收到数据计数器（一个时钟周期接收2个数据）
reg                                     uart_rev_12_valid_buf      ;
reg                                     bram_rd_start_en_buf       ;

//wire define

//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------

//bram写入数据完成信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bram_wr_done <= 1'b0;
    end
    else begin
        if (uart_rev_cnt == 16'd10000) begin
            bram_wr_done <= 1'b1;
        end
        else begin
            bram_wr_done <= bram_wr_done;
        end
    end
end

//uart_rev_12_valid_buf
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_rev_12_valid_buf <= 1'b0;
    end
    else begin
        if (uart_rev_12_valid) begin
            uart_rev_12_valid_buf <= uart_rev_12_valid;
        end
        else begin
            uart_rev_12_valid_buf <= 1'b0;
        end
    end
end

//bram_rd_start_en_buf
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bram_rd_start_en_buf <= 1'b0;
    end
    else begin
        if (bram_rd_start_en) begin
            bram_rd_start_en_buf <= bram_rd_start_en;
        end
        else begin
            bram_rd_start_en_buf <= 1'b0;
        end
    end
end

//uart接收到数据计数器
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_rev_cnt <= 16'b0;
    end
    else begin
        if (uart_rev_12_valid) begin
            uart_rev_cnt <= uart_rev_cnt + 1'b1;
        end
        else begin
            uart_rev_cnt <= uart_rev_cnt;
        end
    end
end

//bram使能信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bram_en <= 1'b0;
    end
    else begin
        if (uart_rev_12_valid) begin
            bram_en <= 1'b1;
        end
        else if (bram_rd_start_en) begin
            bram_en <= 1'b1;
        end
        else begin
            bram_en <= 1'b0;
        end
    end
end

//bram读写控制信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bram_wea <= 1'b1;
    end
    else begin
        if (uart_rev_cnt < 16'd10000) begin
            bram_wea <= 1'b1;
        end
        else if (bram_rd_start_en) begin
            bram_wea <= 1'b0;
        end
        else begin
            bram_wea <= 1'b0;
        end
    end
end

//bram写数据
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ram_wr_data_a <= 12'b0;
        ram_wr_data_b <= 12'b0;
    end
    else begin
        if (uart_rev_12_valid) begin
            ram_wr_data_a <= uart_rev_12_a;
            ram_wr_data_b <= uart_rev_12_b;
        end
        else begin
            ram_wr_data_a <= ram_wr_data_a;
            ram_wr_data_b <= ram_wr_data_b;
        end
    end
end

//bram写地址
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ram_addr_a <= 15'b0;
        ram_addr_b <= 15'b1;
    end
    else begin
        if (bram_rd_start_en_buf) begin
            if (ram_addr_a == 15'd9999 && ram_addr_b == 15'd19999) begin
                ram_addr_a <= 15'b0;
                ram_addr_b <= 15'd10000;
            end
            else begin
                ram_addr_a <= ram_addr_a + 15'd1;
                ram_addr_b <= ram_addr_b + 15'd1;
            end
        end
        else if (uart_rev_cnt == 16'd10000) begin
            ram_addr_a <= 15'b0;
            ram_addr_b <= 15'd10000;
        end
        else if (uart_rev_12_valid_buf) begin
            ram_addr_a <= ram_addr_a + 15'd2;
            ram_addr_b <= ram_addr_b + 15'd2;
        end
        else begin
            ram_addr_a <= ram_addr_a;
            ram_addr_b <= ram_addr_b;
        end
    end
end

endmodule