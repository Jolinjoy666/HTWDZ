module asyn_fifo_rw_ctrl (
    //系统信号
    input                               wr_clk                     ,//写时钟
    input                               rd_clk                     ,//读时钟
    input                               wr_rst_n                   ,//写复位，低有效
    input                               rd_rst_n                   ,//读复位，低有效
    //FIFO控制信号
    input                               full_tone                  ,
    input                               empty_tone                 ,
    input                               almost_full_tone           ,
    input                               almost_empty_tone          ,
    input                               full_qpsk                  ,
    input                               empty_qpsk                 ,
    input                               almost_full_qpsk           ,
    input                               almost_empty_qpsk          ,

    input                               tone_signal_rd_valid       ,//开始读单音有效信号
    input                               qpsk_signal_rd_valid       ,//开始读QPSK信号
    output reg                          fifo_tone_wr_en            ,//存储单音信号FIFO写使能
    output reg                          fifo_qpsk_wr_en            ,//存储QPSK信号FIFO写使能

    input              [  10:0]         fifo_tone_rd_cnt           ,//存储单音信号读FIFO计数器
    input              [  13:0]         fifo_qpsk_rd_cnt           ,//存储QPSK信号读FIFO计数器
    input              [  10:0]         fifo_tone_wr_cnt           ,//存储单音信号写FIFO计数器
    input              [  13:0]         fifo_qpsk_wr_cnt           ,//存储QPSK信号写FIFO计数器

    output reg                          fifo_tone_rd_en            ,//存储单音信号FIFO读使能
    output reg                          fifo_qpsk_rd_en            ,//存储QPSK信号FIFO读使能

    input              [  11:0]         asyn_fifo_rd_data_tone_i0  ,
    input              [  11:0]         asyn_fifo_rd_data_tone_i1  ,
    input              [  11:0]         asyn_fifo_rd_data_tone_q0  ,
    input              [  11:0]         asyn_fifo_rd_data_tone_q1  ,
    output             [  11:0]         fifo_to_dac_data_tone_i0   ,
    output             [  11:0]         fifo_to_dac_data_tone_i1   ,
    output             [  11:0]         fifo_to_dac_data_tone_q0   ,
    output             [  11:0]         fifo_to_dac_data_tone_q1   ,
    input              [  11:0]         asyn_fifo_rd_data_qpsk_i0  ,
    input              [  11:0]         asyn_fifo_rd_data_qpsk_i1  ,
    input              [  11:0]         asyn_fifo_rd_data_qpsk_q0  ,
    input              [  11:0]         asyn_fifo_rd_data_qpsk_q1  ,
    output             [  11:0]         fifo_to_dac_data_qpsk_i0   ,
    output             [  11:0]         fifo_to_dac_data_qpsk_i1   ,
    output             [  11:0]         fifo_to_dac_data_qpsk_q0   ,
    output             [  11:0]         fifo_to_dac_data_qpsk_q1    
    // output reg         [  11:0]         fifo_to_dac_data_qpsk_i0   ,
    // output reg         [  11:0]         fifo_to_dac_data_qpsk_i1   ,
    // output reg         [  11:0]         fifo_to_dac_data_qpsk_q0   ,
    // output reg         [  11:0]         fifo_to_dac_data_qpsk_q1    

);
    
//reg define
/*reg [11:0] fifo_to_dac_data_i0;
reg [11:0] fifo_to_dac_data_i1;
reg [11:0] fifo_to_dac_data_q0;
reg [11:0] fifo_to_dac_data_q1;*/

reg [2:0] cnt_fifo_to_dac; //0-2，2发送
reg bram_tone_wea = 1'b1;
reg [8:0] bram_tone_addr;
reg [11:0] bram_tone_data_in_i0;
reg [11:0] bram_tone_data_in_i1;
reg [11:0] bram_tone_data_in_q0;
reg [11:0] bram_tone_data_in_q1;
reg bram_qpsk_wea = 1'b1;
reg [13:0] bram_qpsk_addr;
// reg [11:0] bram_qpsk_data_in_i0;
// reg [11:0] bram_qpsk_data_in_i1;
// reg [11:0] bram_qpsk_data_in_q0;
// reg [11:0] bram_qpsk_data_in_q1;
wire [11:0] bram_qpsk_data_in_i0;
wire [11:0] bram_qpsk_data_in_i1;
wire [11:0] bram_qpsk_data_in_q0;
wire [11:0] bram_qpsk_data_in_q1;

//wire define


//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------

//开始读QPSK信号
//assign fifo_qpsk_wr_en = qpsk_signal_rd_valid;

assign bram_qpsk_data_in_i0 = asyn_fifo_rd_data_qpsk_i0; 
assign bram_qpsk_data_in_i1 = asyn_fifo_rd_data_qpsk_i1; 
assign bram_qpsk_data_in_q0 = asyn_fifo_rd_data_qpsk_q0; 
assign bram_qpsk_data_in_q1 = asyn_fifo_rd_data_qpsk_q1; 


//bram_qpsk_wea
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        bram_qpsk_wea <= 1'b1;
    end
    else begin
        if (bram_qpsk_addr == 14'd8191) begin
            bram_qpsk_wea <= 1'b0;
        end    
        else begin
            bram_qpsk_wea <= bram_qpsk_wea;
        end
    end
end

//bram_qpsk_addr
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        bram_qpsk_addr <= 14'b0;
    end
    else begin
        if (bram_qpsk_addr == 14'd8191) begin
            bram_qpsk_addr <= 14'b0;
        end    
        else if (fifo_qpsk_rd_cnt >= 14'd511) begin
            bram_qpsk_addr <= bram_qpsk_addr + 14'b1;
        end
        else begin
            bram_qpsk_addr <= bram_qpsk_addr;
        end
    end
end


//bram_tone_wea
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        bram_tone_wea <= 1'b1;
    end
    else begin
        if (bram_tone_addr == 9'd511) begin
            bram_tone_wea <= 1'b0;
        end    
        else begin
            bram_tone_wea <= bram_tone_wea;
        end
    end
end

//bram_tone_addr
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        bram_tone_addr <= 9'b0;
    end
    else begin
        if (bram_tone_addr == 9'd511) begin
            bram_tone_addr <= 9'b0;
        end    
        else if (fifo_tone_rd_cnt >= 11'd511) begin
            bram_tone_addr <= bram_tone_addr + 9'b1;
        end
        else begin
            bram_tone_addr <= bram_tone_addr;
        end
    end
end

//cnt_fifo_to_dac
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        cnt_fifo_to_dac <= 3'b0;
    end
    else begin
        if (cnt_fifo_to_dac == 3'd3) begin
            cnt_fifo_to_dac <= 3'b0;
        end    
        else begin
            cnt_fifo_to_dac <= cnt_fifo_to_dac + 3'b1;
        end
    end
end


//tone
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        bram_tone_data_in_i0 <= 12'b0;
        bram_tone_data_in_i1 <= 12'b0;
        bram_tone_data_in_q0 <= 12'b0;
        bram_tone_data_in_q1 <= 12'b0;
    end
    else begin
        if (cnt_fifo_to_dac == 3'd1) begin
            bram_tone_data_in_i0 <= asyn_fifo_rd_data_tone_i0;
            bram_tone_data_in_i1 <= asyn_fifo_rd_data_tone_i1;
            bram_tone_data_in_q0 <= asyn_fifo_rd_data_tone_q0;
            bram_tone_data_in_q1 <= asyn_fifo_rd_data_tone_q1;
        end
        else begin
            bram_tone_data_in_i0 <= bram_tone_data_in_i0;
            bram_tone_data_in_i1 <= bram_tone_data_in_i1;
            bram_tone_data_in_q0 <= bram_tone_data_in_q0;
            bram_tone_data_in_q1 <= bram_tone_data_in_q1;
        end      
    end
end


// //qpsk
// always @(posedge rd_clk or negedge rd_rst_n) begin
//     if (!rd_rst_n) begin
//         bram_qpsk_data_in_i0 <= 12'b0;
//         bram_qpsk_data_in_i1 <= 12'b0;
//         bram_qpsk_data_in_q0 <= 12'b0;
//         bram_qpsk_data_in_q1 <= 12'b0;
//     end
//     else begin
//         if (cnt_fifo_to_dac == 3'd1) begin
//             bram_qpsk_data_in_i0 <= asyn_fifo_rd_data_qpsk_i0;
//             bram_qpsk_data_in_i1 <= asyn_fifo_rd_data_qpsk_i1;
//             bram_qpsk_data_in_q0 <= asyn_fifo_rd_data_qpsk_q0;
//             bram_qpsk_data_in_q1 <= asyn_fifo_rd_data_qpsk_q1;
//         end
//         else begin
//             bram_qpsk_data_in_i0 <= bram_qpsk_data_in_i0;
//             bram_qpsk_data_in_i1 <= bram_qpsk_data_in_i1;
//             bram_qpsk_data_in_q0 <= bram_qpsk_data_in_q0;
//             bram_qpsk_data_in_q1 <= bram_qpsk_data_in_q1;
//         end
//     end
// end

//存储单音信号FIFO写使能
always @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        fifo_tone_wr_en <= 1'b0;
    end
    else begin
        if ((full_tone == 1'b1) | (almost_full_tone == 1'b1)) begin
            fifo_tone_wr_en <= 1'b0;
        end 
        else begin
            fifo_tone_wr_en <= tone_signal_rd_valid;
        end  
    end
end

//存储QPSK信号FIFO写使能
always @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        fifo_qpsk_wr_en <= 1'b0;
    end
    else begin
        if ((full_qpsk == 1'b1) | (almost_full_qpsk == 1'b1)) begin
            fifo_qpsk_wr_en <= 1'b0;
        end 
        else begin
            fifo_qpsk_wr_en <= qpsk_signal_rd_valid;
        end  
    end
end

//存储单音信号FIFO读使能
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        fifo_tone_rd_en <= 1'b0;
    end
    else begin
        if (fifo_tone_rd_cnt >= 11'd500) begin
            if (cnt_fifo_to_dac == 3'd3) begin
                fifo_tone_rd_en <= 1'b1;
            end
            else begin
                fifo_tone_rd_en <= 1'b0;
            end
        end
        else begin
            fifo_tone_rd_en <= 1'b0;
        end      
    end
end

//存储QPSK信号FIFO读使能
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        fifo_qpsk_rd_en <= 1'b0;
    end
    else begin
        if (fifo_qpsk_rd_cnt >= 14'd511) begin
            if (cnt_fifo_to_dac == 3'd3) begin
                fifo_qpsk_rd_en <= 1'b1;
            end
            else begin
                fifo_qpsk_rd_en <= 1'b0;
            end
        end
        else begin
            fifo_qpsk_rd_en <= 1'b0;
        end      
    end
end


bram_tone u_bram_tone_i0 (
    .clka                              (rd_clk                    ),// input wire clka
    .wea                               (bram_tone_wea             ),// input wire [0 : 0] wea
    .addra                             (bram_tone_addr            ),// input wire [8 : 0] addra
    .dina                              (bram_tone_data_in_i0      ),// input wire [11 : 0] dina
    .douta                             (fifo_to_dac_data_tone_i0  ) // output wire [11 : 0] douta
);

bram_tone u_bram_tone_i1 (
    .clka                              (rd_clk                    ),// input wire clka
    .wea                               (bram_tone_wea             ),// input wire [0 : 0] wea
    .addra                             (bram_tone_addr            ),// input wire [8 : 0] addra
    .dina                              (bram_tone_data_in_i1      ),// input wire [11 : 0] dina
    .douta                             (fifo_to_dac_data_tone_i1  ) // output wire [11 : 0] douta
);

bram_tone u_bram_tone_q0 (
    .clka                              (rd_clk                    ),// input wire clka
    .wea                               (bram_tone_wea             ),// input wire [0 : 0] wea
    .addra                             (bram_tone_addr            ),// input wire [8 : 0] addra
    .dina                              (bram_tone_data_in_q0      ),// input wire [11 : 0] dina
    .douta                             (fifo_to_dac_data_tone_q0  ) // output wire [11 : 0] douta
);

bram_tone u_bram_tone_q1 (
    .clka                              (rd_clk                    ),// input wire clka
    .wea                               (bram_tone_wea             ),// input wire [0 : 0] wea
    .addra                             (bram_tone_addr            ),// input wire [8 : 0] addra
    .dina                              (bram_tone_data_in_q1      ),// input wire [11 : 0] dina
    .douta                             (fifo_to_dac_data_tone_q1  ) // output wire [11 : 0] douta
);


bram_qpsk u_bram_qpsk_i0 (
    .clka                              (rd_clk                    ),// input wire clka
    .wea                               (bram_qpsk_wea             ),// input wire [0 : 0] wea
    .addra                             (bram_qpsk_addr            ),// input wire [13 : 0] addra
    .dina                              (bram_qpsk_data_in_i0      ),// input wire [11 : 0] dina
    .douta                             (fifo_to_dac_data_qpsk_i0  ) // output wire [11 : 0] douta
);

bram_qpsk u_bram_qpsk_i1 (
    .clka                              (rd_clk                    ),// input wire clka
    .wea                               (bram_qpsk_wea             ),// input wire [0 : 0] wea
    .addra                             (bram_qpsk_addr            ),// input wire [13 : 0] addra
    .dina                              (bram_qpsk_data_in_i1      ),// input wire [11 : 0] dina
    .douta                             (fifo_to_dac_data_qpsk_i1  ) // output wire [11 : 0] douta
);

bram_qpsk u_bram_qpsk_q0 (
    .clka                              (rd_clk                    ),// input wire clka
    .wea                               (bram_qpsk_wea             ),// input wire [0 : 0] wea
    .addra                             (bram_qpsk_addr            ),// input wire [13 : 0] addra
    .dina                              (bram_qpsk_data_in_q0      ),// input wire [11 : 0] dina
    .douta                             (fifo_to_dac_data_qpsk_q0  ) // output wire [11 : 0] douta
);

bram_qpsk u_bram_qpsk_q1 (
    .clka                              (rd_clk                    ),// input wire clka
    .wea                               (bram_qpsk_wea             ),// input wire [0 : 0] wea
    .addra                             (bram_qpsk_addr            ),// input wire [13 : 0] addra
    .dina                              (bram_qpsk_data_in_q1      ),// input wire [11 : 0] dina
    .douta                             (fifo_to_dac_data_qpsk_q1  ) // output wire [11 : 0] douta
);



endmodule