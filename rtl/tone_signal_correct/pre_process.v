module pre_process(
    //系统信号
    input                               clk                        ,
    input                               rst_n                      ,
    //bram读信号
    input signed       [  11:0]         tone_signal                ,//单音校正信号(bram读数据)
    input                               tone_signal_valid          ,//单音校正信号输入有效信号(bram读数据有效信号)
    //FFT接口信号
    input                               fft_s_data_tready          ,//FFT准备接收数据
    output reg         [  31:0]         fft_s_data_tdata           ,//FFT输入数据
    output reg                          fft_s_data_tvalid          ,//FFT输入有效信号
    output reg                          fft_s_data_tlast            //FFT输入最后一个数据时拉高信号
);

//reg define
reg                    [   9:0]         mul_index                  ;//汉宁窗乘法索引
reg                    [   8:0]         rom_addr                   ;//ROM地址信号
reg                    [   8:0]         fft_data_index             ;//FFT输入数据索引
reg             signed [  23:0]         hanning_mul_result         ;//汉宁窗乘法结果暂存
reg                                     mul_out_valid              ;//乘法器输出有效信号
reg                                     mul_out_valid_buf1         ;//乘法器输出有效信号缓存1
reg                                     mul_out_valid_buf2         ;//乘法器输出有效信号缓存2
reg                    [   7:0]         hanning_mul_bram_addr      ;//汉宁窗乘积暂存地址
reg                                     hanning_mul_bram_wea       ;//汉宁窗乘积暂存bram读写控制信号
reg             signed [  23:0]         mul_result_buf1            ;//乘法器输出缓存1
reg             signed [  23:0]         mul_result_buf2            ;//乘法器输出缓存2

//wire define
wire            signed [  11:0]         rom_rd_data                ;//不截位
wire            signed [  23:0]         mul_result                 ;
wire            signed [  23:0]         hanning_mul_bram_dout      ;//汉宁窗乘积暂存bram输出信号

//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------

//模块例化
//移位相加暂存BRAM
bram_24x256b u_bram_24x256b (
    .clka                              (clk                       ),// input wire clka
    .wea                               (hanning_mul_bram_wea      ),// input wire [0 : 0] wea
    .addra                             (hanning_mul_bram_addr     ),// input wire [7 : 0] addra
    .dina                              (hanning_mul_result        ),// input wire [23 : 0] dina
    .douta                             (hanning_mul_bram_dout     ) // output wire [23 : 0] douta
);

//乘法器例化
mult_12x12bit u_mult_12x12bit (
    .CLK                               (clk                       ),// input wire CLK
    .A                                 (tone_signal               ),// input wire [11 : 0] A
    .B                                 (rom_rd_data               ),// input wire [11 : 0] B
    .P                                 (mul_result                ) // output wire [23 : 0] P
);

//汉宁窗存储BRAM(有效数据为511个)
bram_512x12bit u_bram_512x12bit (
    .clka                              (clk                       ),// input wire clka
    .addra                             (rom_addr                  ),// input wire [8 : 0] addra
    .douta                             (rom_rd_data               ) // output wire [11 : 0] douta
);

//FFT输入有效信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_s_data_tvalid <= 1'b0;
    end
    else begin
        if (mul_index == 10'd259) begin
            fft_s_data_tvalid <= 1'b1;
        end
        else begin
            fft_s_data_tvalid <= fft_s_data_tvalid;
        end        
    end
end

//FFT最后输入拉高信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_s_data_tlast <= 1'b0;
    end
    else begin
        if (fft_data_index == 9'd256) begin
            fft_s_data_tlast <= 1'b1;
        end
        else begin
            fft_s_data_tlast <= 1'b0;
        end        
    end
end

//FFT输入数据索引
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_data_index <= 9'b0;
    end
    else begin
        if (fft_data_index == 9'd256) begin
            fft_data_index <= 9'b0;
        end
        else if (mul_index >= 10'd259) begin
            fft_data_index <= fft_data_index + 1'b1;
        end
        else begin
            fft_data_index <= fft_data_index;
        end        
    end
end

//乘法计数器(索引)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_index <= 10'b0;
    end
    else begin
        if ((mul_out_valid == 1'b1) & (mul_index <= 10'd515)) begin
            mul_index <= mul_index + 1'b1;
        end
        else begin
            mul_index <= mul_index;
        end        
    end
end

//汉宁窗乘加计算
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        hanning_mul_result <= $signed(24'b0);
    end
    else begin
        if ((mul_out_valid == 1'b1) & (mul_index <= 10'd255)) begin
            hanning_mul_result <= mul_result;
        end
        else if ((mul_out_valid == 1'b1) & (mul_index == 10'd256)) begin
            hanning_mul_result <= mul_result;
        end
        else if ((mul_out_valid == 1'b1) & (mul_index > 10'd256) & (mul_index <= 10'd515)) begin
            hanning_mul_result <= mul_result_buf2 + hanning_mul_bram_dout;
        end
        else begin
            hanning_mul_result <= hanning_mul_result;
        end
    end
end

//ROM地址
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rom_addr <= 9'b0;
    end
    else begin
        if (tone_signal_valid) begin
            rom_addr <= rom_addr + 1'b1;
        end
        else if (rom_addr == 9'd511) begin
            rom_addr <= 9'd0;
        end
        else begin
            rom_addr <= rom_addr;
        end    
    end
end

//FFT输入数据
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_s_data_tdata <= 32'b0;
    end
    else begin
        if (mul_index > 10'd256) begin
            fft_s_data_tdata <= {4'd0,hanning_mul_result[23:12],16'd0};
        end
        else begin
            fft_s_data_tdata <= fft_s_data_tdata;
        end        
    end
end

//乘法器输出有效信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out_valid <= 1'b0;
        mul_out_valid_buf1 <= 1'b0;
        mul_out_valid_buf2 <= 1'b0;
    end
    else begin
        if (tone_signal_valid) begin
            mul_out_valid <= mul_out_valid_buf1;
            mul_out_valid_buf1 <= mul_out_valid_buf2;
            mul_out_valid_buf2 <= tone_signal_valid;
        end
        else begin
            mul_out_valid <= mul_out_valid;
            mul_out_valid_buf1 <= mul_out_valid_buf1;
            mul_out_valid_buf2 <= mul_out_valid_buf2;
        end        
    end
end

//乘法器输出缓存1
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_result_buf1 <= $signed(24'b0);
    end
    else begin
        if (mul_index >= 10'd256) begin
            mul_result_buf1 <= mul_result;
        end
        else begin
            mul_result_buf1 <= mul_result_buf1;
        end
    end
end

//乘法器输出缓存2
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_result_buf2 <= $signed(24'b0);
    end
    else begin
        if (mul_index >= 10'd256) begin
            mul_result_buf2 <= mul_result_buf1;
        end
        else begin
            mul_result_buf2 <= mul_result_buf2;
        end        
    end
end

//汉宁窗乘积暂存BRAM地址
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        hanning_mul_bram_addr <= 8'b0;
    end
    else begin
        if ((mul_out_valid == 1'b1) & (mul_index <= 10'd255) & (mul_index > 10'd0)) begin
            hanning_mul_bram_addr <= hanning_mul_bram_addr + 1'b1;
        end
        else if ((mul_out_valid == 1'b1) & (mul_index >= 10'd257)) begin
            hanning_mul_bram_addr <= hanning_mul_bram_addr + 1'b1;
        end
        else if ((mul_out_valid == 1'b1) & (mul_index == 10'd256)) begin
            hanning_mul_bram_addr <= 8'b0;
        end
        else begin
            hanning_mul_bram_addr <= hanning_mul_bram_addr;
        end        
    end
end

//汉宁窗乘积暂存BRAM读写控制信号(高为写，低为读)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        hanning_mul_bram_wea <= 1'b0;
    end
    else begin
        if ((mul_out_valid == 1'b1) & (mul_index < 10'd256)) begin
            hanning_mul_bram_wea <= 1'b1;
        end
        else if ((mul_out_valid == 1'b1) & (mul_index == 10'd256)) begin
            hanning_mul_bram_wea <= 1'b0;
        end
        else begin
            hanning_mul_bram_wea <= hanning_mul_bram_wea;
        end        
    end
end

/*ila_pre u_ila_pre (
	.clk(clk), // input wire clk


	.probe0(tone_signal), // input wire [11:0]  probe0  
	.probe1(rom_rd_data), // input wire [11:0]  probe1 
	.probe2(mul_result), // input wire [23:0]  probe2 
	.probe3(tone_signal_valid), // input wire [0:0]  probe3 
	.probe4(rom_addr), // input wire [8:0]  probe4 
	.probe5(mul_out_valid), // input wire [0:0]  probe5 
	.probe6(mul_index), // input wire [9:0]  probe6 
	.probe7(mul_out_valid_buf2), // input wire [0:0]  probe7 
	.probe8(mul_out_valid_buf1) // input wire [0:0]  probe8
);*/


endmodule