module post_process(
    //系统信号
    input                               clk                        ,
    input                               rst_n                      ,
    //FFT接口
    input              [  47:0]         fft_m_data_tdata           ,//FFT输出信号数据
    input                               fft_m_data_tvalid          ,//FFT输出数据有效信号
    input              [   7:0]         fft_m_data_tuser           ,//FFT输出用户信息
    input                               fft_m_data_tlast           ,//FFT输出最后一个信号
    output                              fft_m_data_tready          ,//FFT输出准备接收信号
    //处理输出接口
    output reg signed  [  11:0]         channel_phase              ,//通道校正相位(fix12_8)
    output reg         [  11:0]         channel_amplitude          ,//通道校正幅度
    output reg                          channel_data_valid          //通道数据输出有效信号(需要调整)
    );

//reg define
reg             signed [  20:0]         fft_i_out_next             ;
reg             signed [  20:0]         fft_q_out_next             ;
reg             signed [  20:0]         fft_i_out_curr             ;
reg             signed [  20:0]         fft_q_out_curr             ;
reg             signed [  20:0]         fft_i_out_prev             ;
reg             signed [  20:0]         fft_q_out_prev             ;
reg             signed [  20:0]         fft_i_out_prev_1           ;
reg             signed [  20:0]         fft_q_out_prev_1           ;
reg             signed [  20:0]         fft_i_out_prev_2           ;
reg             signed [  20:0]         fft_q_out_prev_2           ;
reg             signed [  20:0]         fft_i_out_prev_3           ;
reg             signed [  20:0]         fft_q_out_prev_3           ;
reg             signed [  20:0]         fft_i_out_max              ;
reg             signed [  20:0]         fft_q_out_max              ;

reg                    [  42:0]         fft_abs_buf                ;
reg                    [  42:0]         fft_abs_max                ;

reg                                     fft_abs_max_delay_1        ;//比较最大值延时,fft_m_data_tlast拉高后的第4个时钟周期比较出最大值
reg                                     fft_abs_max_delay_2        ;
reg                                     fft_abs_max_delay_3        ;
reg                                     fft_abs_max_delay_4        ;

reg                                     cordic_artan_tvalid        ;
reg                                     cordic_sqrt_tvalid         ;

reg                                     fft_out_half               ;//FFT输出一半数据标志信号（128）

//wire define
wire                   [  41:0]         fft_abs_i                  ;
wire                   [  41:0]         fft_abs_q                  ;
wire                   [  42:0]         fft_abs                    ;

wire                                    cordic_artan_dout_tvalid   ;
wire            signed [  15:0]         cordic_artan_dout_tdata    ;//弧度制,范围：-pi~pi,fix12_9
wire                                    cordic_sqrt_dout_tvalid    ;
wire            signed [  23:0]         cordic_sqrt_dout_tdata     ;//开方后结果,[21:0]为有效位数
wire            signed [  11:0]         cordic_artan_dout_tdata_true;//截取cordi输出的相角数据并将整数位扩展1位后的数据,fix12_8
wire            signed [  11:0]         pix2                       ;//2pi，量化2*pi(6.2832)为fix12_8

//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------

//从设备准备接收FFT输入的信号
assign fft_m_data_tready = 1'b1;

//截取cordi输出的相角数据并将整数位扩展1位
assign cordic_artan_dout_tdata_true = $signed({cordic_artan_dout_tdata[11],cordic_artan_dout_tdata[11:1]});

//2pi赋值
assign pix2 = $signed(12'b0110_0100_1000);

//实部、虚部平方相加
assign fft_abs = fft_abs_i + fft_abs_q;

//模块例化
//例化cordic_artan，共延时16个时钟周期
cordic_arctan u_cordic_arctan (
    .aclk                              (clk                       ),// input wire aclk
    .aresetn                           (rst_n                     ),// input wire aresetn
    .s_axis_cartesian_tvalid           (cordic_artan_tvalid       ),// input wire s_axis_cartesian_tvalid
    .s_axis_cartesian_tdata            ({3'b0,fft_q_out_max,3'b0,fft_i_out_max}),// input wire [47 : 0] s_axis_cartesian_tdata,[44:24]虚部,[20:0]实部,fix21_19
    .m_axis_dout_tvalid                (cordic_artan_dout_tvalid  ),// output wire m_axis_dout_tvalid
    .m_axis_dout_tdata                 (cordic_artan_dout_tdata   ) // output wire [15 : 0] m_axis_dout_tdata,[11:0]为phase,弧度制,范围：-pi~pi,fix12_9
);

//例化cordic_sqrt，共延时22个时钟周期
cordic_sqrt u_cordic_sqrt (
    .aclk                              (clk                       ),// input wire aclk
    .aresetn                           (rst_n                     ),// input wire aresetn
    .s_axis_cartesian_tvalid           (cordic_sqrt_tvalid        ),// input wire s_axis_cartesian_tvalid
    .s_axis_cartesian_tdata            ({5'b0,fft_abs_max}        ),// input wire [47 : 0] s_axis_cartesian_tdata,[42:0]为有效位数
    .m_axis_dout_tvalid                (cordic_sqrt_dout_tvalid   ),// output wire m_axis_dout_tvalid
    .m_axis_dout_tdata                 (cordic_sqrt_dout_tdata    ) // output wire [23 : 0] m_axis_dout_tdata,[21:0]为有效位数
);

//例化21bit乘法器求实部、虚部平方
mult_signed_21x21 u1_mult_signed_21x21 (
    .CLK                               (clk                       ),// input wire CLK
    .A                                 (fft_i_out_next            ),// input wire [20 : 0] A
    .B                                 (fft_i_out_next            ),// input wire [20 : 0] B
    .P                                 (fft_abs_i                 ) // output wire [41 : 0] P
);

mult_signed_21x21 u2_mult_signed_21x21 (
    .CLK                               (clk                       ),// input wire CLK
    .A                                 (fft_q_out_next            ),// input wire [20 : 0] A
    .B                                 (fft_q_out_next            ),// input wire [20 : 0] B
    .P                                 (fft_abs_q                 ) // output wire [41 : 0] P
);

//FFT输出一半数据标志信号（128）
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       fft_out_half <= 1'b0;
    end
    else begin
        if (fft_m_data_tuser == 8'd128) begin
           fft_out_half <= 1'b1;
        end
        else begin
            fft_out_half <= fft_out_half;
        end        
    end
end

//后处理完成输出有效信号
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       channel_data_valid <= 1'b0;
    end
    else begin
        if ((cordic_artan_dout_tvalid == 1'b1)&(cordic_sqrt_dout_tvalid == 1'b1)) begin
           channel_data_valid <= 1'b1;
        end
        else begin
            channel_data_valid <= channel_data_valid;
        end        
    end
end

//计算通道校正相位
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        channel_phase <= $signed(12'b0);
    end
    else begin
        if (cordic_artan_dout_tvalid == 1'b1) begin
            if ((cordic_artan_dout_tdata[11]==1'b0)||(cordic_artan_dout_tdata[11:0]==12'b0)) begin
                channel_phase <= cordic_artan_dout_tdata_true; //整数号位扩展一位,fix12_8
            end
            else begin
                channel_phase <= cordic_artan_dout_tdata_true + pix2; //量化2*pi(6.2832)为fix12_8。
            end
        end
        else begin
            channel_phase <= channel_phase;
        end        
    end
end

//计算通道校正幅度
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        channel_amplitude <= 12'b0;
    end
    else begin
        if (cordic_sqrt_dout_tvalid == 1'b1) begin
            channel_amplitude <= cordic_sqrt_dout_tdata[17:6];  //截取位数由matlab分析得
        end
        else begin
            channel_amplitude <= channel_amplitude;
        end        
    end
end

//cordic_arctan有效信号
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cordic_artan_tvalid <= 1'b0;
    end
    else begin
        if (fft_abs_max_delay_4 == 1'b1) begin
            cordic_artan_tvalid <= 1'b1;
        end
        else begin
            cordic_artan_tvalid <= cordic_artan_tvalid;
        end       
    end
end

//cordic_sqrt有效信号
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cordic_sqrt_tvalid <= 1'b0;
    end
    else begin
        if (fft_abs_max_delay_4 == 1'b1) begin
            cordic_sqrt_tvalid <= 1'b1;
        end
        else begin
            cordic_sqrt_tvalid <= cordic_sqrt_tvalid;
        end        
    end
end

//比较最大值的延时
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_abs_max_delay_1 <= 1'b0;
        fft_abs_max_delay_2 <= 1'b0;
        fft_abs_max_delay_3 <= 1'b0;
        fft_abs_max_delay_4 <= 1'b0;
    end
    else begin
        fft_abs_max_delay_1 <= fft_m_data_tlast;
        fft_abs_max_delay_2 <= fft_abs_max_delay_1;
        fft_abs_max_delay_3 <= fft_abs_max_delay_2;
        fft_abs_max_delay_4 <= fft_abs_max_delay_3;
    end
end

//模值暂存一拍
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_abs_buf <= 43'b0;
    end
    else begin
        if (fft_m_data_tvalid) begin
            fft_abs_buf <= fft_abs;
        end
        else begin
            fft_abs_buf <= fft_abs_buf;
        end        
    end
end

//模值大小比较
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_abs_max <= 43'b0;
        fft_i_out_max <= $signed(21'b0);
        fft_q_out_max <= $signed(21'b0);
    end
    else begin
        if (fft_out_half) begin
            if (fft_abs_buf >= fft_abs_max) begin
                fft_abs_max <= fft_abs_buf;
                fft_i_out_max <= fft_i_out_prev_3;
                fft_q_out_max <= fft_q_out_prev_3;
            end
            else begin
                fft_abs_max <= fft_abs_max;
                fft_i_out_max <= fft_i_out_max;
                fft_q_out_max <= fft_q_out_max;
            end
        end
        else begin
            fft_abs_max <= fft_abs_max;
            fft_i_out_max <= fft_i_out_max;
            fft_q_out_max <= fft_q_out_max;
        end
    end
end

//截取FFT输出有效数据
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_i_out_next <= $signed(21'b0);
        fft_q_out_next <= $signed(21'b0);
    end
    else begin
        if (fft_m_data_tvalid) begin
            fft_i_out_next <= $signed(fft_m_data_tdata[44:24]); //I+jQ
            fft_q_out_next <= $signed(fft_m_data_tdata[20:0]);
        end
        else begin
            fft_i_out_next <= fft_i_out_next;
            fft_q_out_next <= fft_q_out_next;
        end        
    end
end

//FFT输出暂存一拍
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_i_out_curr <= $signed(21'b0);
        fft_q_out_curr <= $signed(21'b0);
    end
    else begin
        if (fft_m_data_tvalid) begin
            fft_i_out_curr <= fft_i_out_next; 
            fft_q_out_curr <= fft_q_out_next;
        end
        else begin
            fft_i_out_curr <= fft_i_out_curr;
            fft_q_out_curr <= fft_q_out_curr;
        end        
    end
end

//FFT输出暂存第二拍
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_i_out_prev <= $signed(21'b0);
        fft_q_out_prev <= $signed(21'b0);
    end
    else begin
        if (fft_m_data_tvalid) begin
            fft_i_out_prev <= fft_i_out_curr; 
            fft_q_out_prev <= fft_q_out_curr;
        end
        else begin
            fft_i_out_prev <= fft_i_out_prev;
            fft_q_out_prev <= fft_q_out_prev;
        end        
    end
end

//FFT输出暂存第三拍
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_i_out_prev_1 <= $signed(21'b0);
        fft_q_out_prev_1 <= $signed(21'b0);
    end
    else begin
        if (fft_m_data_tvalid) begin
            fft_i_out_prev_1 <= fft_i_out_prev; 
            fft_q_out_prev_1 <= fft_q_out_prev;
        end
        else begin
            fft_i_out_prev_1 <= fft_i_out_prev_1;
            fft_q_out_prev_1 <= fft_q_out_prev_1;
        end        
    end
end

//FFT输出暂存第四拍
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_i_out_prev_2 <= $signed(21'b0);
        fft_q_out_prev_2 <= $signed(21'b0);
    end
    else begin
        if (fft_m_data_tvalid) begin
            fft_i_out_prev_2 <= fft_i_out_prev_1; 
            fft_q_out_prev_2 <= fft_q_out_prev_1;
        end
        else begin
            fft_i_out_prev_2 <= fft_i_out_prev_2;
            fft_q_out_prev_2 <= fft_q_out_prev_2;
        end        
    end
end

//FFT输出暂存第五拍
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_i_out_prev_3 <= $signed(21'b0);
        fft_q_out_prev_3 <= $signed(21'b0);
    end
    else begin
        if (fft_m_data_tvalid) begin
            fft_i_out_prev_3 <= fft_i_out_prev_2; 
            fft_q_out_prev_3 <= fft_q_out_prev_2;
        end
        else begin
            fft_i_out_prev_3 <= fft_i_out_prev_3;
            fft_q_out_prev_3 <= fft_q_out_prev_3;
        end        
    end
end

endmodule
