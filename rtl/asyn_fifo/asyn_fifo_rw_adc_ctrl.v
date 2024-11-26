module asyn_fifo_rw_adc_ctrl (
    //系统信号
    input                               wr_clk                     ,//写时钟
    input                               rd_clk                     ,//读时钟
    input                               wr_rst_n                   ,//写复位，低有效
    input                               rd_rst_n                   ,//读复位，低有效
    //幅相校正模块接口
    output             [  11:0]         fifo_to_apcorrect_data_i0  ,
    output             [  11:0]         fifo_to_apcorrect_data_i1  ,
    output             [  11:0]         fifo_to_apcorrect_data_q0  ,
    output             [  11:0]         fifo_to_apcorrect_data_q1  ,
    output                              ap_correct_valid           ,//幅相校正模块启动信号
    //ADC接口
    input                               adc_data_i0_valid          ,
    input                               adc_data_i1_valid          ,
    input                               adc_data_q0_valid          ,
    input                               adc_data_q1_valid          ,
    //FIFO接口
    output reg                          fifo_wr_en                 ,
    output reg                          fifo_rd_en                 ,

    input              [  11:0]         fifo_data_out_i0           ,
    input              [  11:0]         fifo_data_out_i1           ,
    input              [  11:0]         fifo_data_out_q0           ,
    input              [  11:0]         fifo_data_out_q1           ,

    input                               fifo_almost_full           ,
    input                               fifo_almost_empty          ,
    input                               fifo_full                  ,
    input                               fifo_empty                 ,
    input              [  13:0]         fifo_rd_cnt                ,
    input              [  13:0]         fifo_wr_cnt                ,

    input              [  13:0]         fifo_qpsk_rd_cnt            //存储QPSK信号读FIFO计数器（DAC端）

);

reg [11:0] bram_data_in_i0;
reg [11:0] bram_data_in_i1;
reg [11:0] bram_data_in_q0;
reg [11:0] bram_data_in_q1;
reg bram_wea = 1'b1;
reg [13:0] bram_addr;

reg [13:0] delay_cnt;

assign ap_correct_valid = ~bram_wea;

//delay_cnt
always @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        delay_cnt <= 14'b0;
    end
    else begin
        if (delay_cnt >= 14'd16300) begin
            delay_cnt <= delay_cnt;
        end
        else if (fifo_qpsk_rd_cnt >= 14'd16300) begin
            delay_cnt <= delay_cnt + 14'b1;
        end    
        else begin
            delay_cnt <= delay_cnt;
        end
    end
end

//fifo_wr_en
always @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        fifo_wr_en <= 1'b0;
    end
    else begin
        if (delay_cnt >= 14'd16300) begin
            if ((fifo_full == 1'b1) | (fifo_almost_full == 1'b1)) begin
                fifo_wr_en <= 1'b0;
            end 
            else begin
                fifo_wr_en <= adc_data_i0_valid;
            end 
        end    
        else begin
            fifo_wr_en <= fifo_wr_en;
        end
    end
end

//fifo_rd_en
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        fifo_rd_en <= 1'b0;
    end
    else begin
        if (fifo_rd_cnt >= 14'd8191) begin
            fifo_rd_en <= 1'b1;
        end    
        else begin
            fifo_rd_en <= fifo_rd_en;
        end
    end
end

//bram_data_in
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        bram_data_in_i0 <= 12'b0;
        bram_data_in_i1 <= 12'b0;
        bram_data_in_q0 <= 12'b0;
        bram_data_in_q1 <= 12'b0;
    end
    else begin
        if (fifo_rd_en == 1'b1) begin
            bram_data_in_i0 <= fifo_data_out_i0;
            bram_data_in_i1 <= fifo_data_out_i1;
            bram_data_in_q0 <= fifo_data_out_q0;
            bram_data_in_q1 <= fifo_data_out_q1;
        end
        else begin
            bram_data_in_i0 <= bram_data_in_i0;
            bram_data_in_i1 <= bram_data_in_i1;
            bram_data_in_q0 <= bram_data_in_q0;
            bram_data_in_q1 <= bram_data_in_q1;
        end      
    end
end

//bram_wea
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        bram_wea <= 1'b1;
    end
    else begin
        if (bram_addr == 14'd8192) begin
            bram_wea <= 1'b0;
        end    
        else begin
            bram_wea <= bram_wea;
        end
    end
end

//bram_addr
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        bram_addr <= 14'b0;
    end
    else begin
        if (bram_addr == 14'd8192) begin
            bram_addr <= 14'b1;
        end    
        else if (fifo_rd_en == 1'b1) begin
            bram_addr <= bram_addr + 14'b1;
        end
        else begin
            bram_addr <= bram_addr;
        end
    end
end



bram_qpsk u_bram_adc_out_i0 (
    .clka                              (rd_clk                    ),// input wire clka
    .wea                               (bram_wea                  ),// input wire [0 : 0] wea
    .addra                             (bram_addr                 ),// input wire [13 : 0] addra
    .dina                              (bram_data_in_i0           ),// input wire [11 : 0] dina
    .douta                             (fifo_to_apcorrect_data_i0 ) // output wire [11 : 0] douta
);

bram_qpsk u_bram_adc_out_i1 (
    .clka                              (rd_clk                    ),// input wire clka
    .wea                               (bram_wea                  ),// input wire [0 : 0] wea
    .addra                             (bram_addr                 ),// input wire [13 : 0] addra
    .dina                              (bram_data_in_i1           ),// input wire [11 : 0] dina
    .douta                             (fifo_to_apcorrect_data_i1 ) // output wire [11 : 0] douta
);

bram_qpsk u_bram_adc_out_q0 (
    .clka                              (rd_clk                    ),// input wire clka
    .wea                               (bram_wea                  ),// input wire [0 : 0] wea
    .addra                             (bram_addr                 ),// input wire [13 : 0] addra
    .dina                              (bram_data_in_q0           ),// input wire [11 : 0] dina
    .douta                             (fifo_to_apcorrect_data_q0 ) // output wire [11 : 0] douta
);

bram_qpsk u_bram_adc_out_q1 (
    .clka                              (rd_clk                    ),// input wire clka
    .wea                               (bram_wea                  ),// input wire [0 : 0] wea
    .addra                             (bram_addr                 ),// input wire [13 : 0] addra
    .dina                              (bram_data_in_q1           ),// input wire [11 : 0] dina
    .douta                             (fifo_to_apcorrect_data_q1 ) // output wire [11 : 0] douta
);



endmodule