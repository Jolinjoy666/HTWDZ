module amp_phase_correct(
    //系统信号
    input                               clk                        ,
    input                               rst_n                      ,
    //单音校正信号接口
    input       signed [  11:0]         channel_phase              ,//校正相位误差参数(fix12_8)
    input       signed [  11:0]         channel_amplitude          ,//校正幅度误差参数
    input                               channel_data_valid         ,//单音校正通道输出有效信号
    //参考信号接口
    input       signed [  11:0]         ref_phase                  ,//参考信号相位(fix12_8)
    input       signed [  11:0]         ref_amplitude              ,//参考信号幅度
    input       signed                  ref_valid                  ,//参考有效信号
    //qpsk信号接口
    input              [  11:0]         qpsk_signal_in_i           ,
    input              [  11:0]         qpsk_signal_in_q           ,
    input                               qpsk_signal_in_valid       ,//qpsk输入有效信号
    output             [  11:0]         qpsk_signal_out_i          ,
    output             [  11:0]         qpsk_signal_out_q          ,
    output                              qpsk_signal_out_valid      ,//qpsk输出有效信号
    //指示信号接口
    output                              s_amp_phase_ready          ,//幅相校正模块就绪信号
    output reg         [  16:0]         signal_out_index            //输出信号索引
    );

//reg define
reg             signed [  11:0]         delta_amp                  ;//fix12_10
reg             signed [  11:0]         delta_phase                ;//fix12_8
reg                                     delta_amp_valid            ;
reg                                     qpsk_amp_corrected_valid   ;
reg                                     qpsk_amp_corrected_valid_buf1;
reg                                     qpsk_amp_corrected_valid_buf2;
reg             signed [  11:0]         delta_rotation             ;//fix12_8

//wire define
wire                                    div_out_valid              ;
wire                   [  11:0]         div_quotient               ;
wire                   [  10:0]         div_fractional             ;
wire                   [  23:0]         div_data_out               ;
wire            signed [  23:0]         qpsk_amp_corrected_i       ;//10位小数位
wire            signed [  23:0]         qpsk_amp_corrected_q       ;//10位小数位
wire            signed [  11:0]         qpsk_amp_corrected_i_tru   ;//量化之后12位整数位
wire            signed [  11:0]         qpsk_amp_corrected_q_tru   ;//量化之后12位整数位
wire            signed [  11:0]         negative_pi                ;//-pi,fix12_8
wire            signed [  11:0]         pix2                       ;//2pi，量化2*pi(6.2832)为fix12_8
wire                   [  31:0]         cordic_rotation_dout_tdata ;
wire                   [  11:0]         delta_rotation12_9         ;

//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------

//取整数部分和小数部分
assign div_quotient = div_data_out[22:11];
assign div_fractional = div_data_out[10:0];

//判断幅相校正是否就绪
assign s_amp_phase_ready = delta_amp_valid;

//幅度校正结果量化(去掉10位小数位,实际去掉11位，防溢出)
assign qpsk_amp_corrected_i_tru = $signed({qpsk_amp_corrected_i[23],qpsk_amp_corrected_i[21:11]});
assign qpsk_amp_corrected_q_tru = $signed({qpsk_amp_corrected_q[23],qpsk_amp_corrected_q[21:11]});

//-pi赋值、2*pi赋值
assign negative_pi = $signed(12'b1100_1101_1100); //-pi
assign pix2 = $signed(12'b0110_0100_1000); //2*pi

//qpsk校正完成输出
assign qpsk_signal_out_i = {cordic_rotation_dout_tdata[11],cordic_rotation_dout_tdata[9:0],cordic_rotation_dout_tdata[0]};
assign qpsk_signal_out_q = {cordic_rotation_dout_tdata[27],cordic_rotation_dout_tdata[25:16],cordic_rotation_dout_tdata[16]};

//delta_rotation量化
assign delta_rotation12_9 = {delta_rotation[11],delta_rotation[9:0],1'b0};

//模块例化
//cordic ip核例化
cordic_rotation u_cordic_rotation (
    .aclk                              (clk                       ),// input wire aclk
    .aresetn                           (rst_n                     ),// input wire aresetn
    .s_axis_phase_tvalid               (qpsk_amp_corrected_valid  ),// input wire s_axis_phase_tvalid
    .s_axis_phase_tdata                ({4'b0,delta_rotation12_9} ),// input wire [15 : 0] s_axis_phase_tdata,phase[11:0](fix12_9)
    .s_axis_cartesian_tvalid           (qpsk_amp_corrected_valid  ),// input wire s_axis_cartesian_tvalid
    .s_axis_cartesian_tdata            ({4'b0,qpsk_amp_corrected_q_tru,4'b0,qpsk_amp_corrected_i_tru}),// input wire [31 : 0] s_axis_cartesian_tdata,imag[27:16],real[11:0](fix12_9)
    .m_axis_dout_tvalid                (qpsk_signal_out_valid     ),// output wire m_axis_dout_tvalid
    .m_axis_dout_tdata                 (cordic_rotation_dout_tdata) // output wire [31 : 0] m_axis_dout_tdata
);

//乘法器例化
mult_12x12bit u_mult_12x12bit_i (
    .CLK                               (clk                       ),// input wire CLK
    .A                                 (qpsk_signal_in_i          ),// input wire [11 : 0] A
    .B                                 (delta_amp                 ),// input wire [11 : 0] B
    .P                                 (qpsk_amp_corrected_i      ) // output wire [23 : 0] P
);

mult_12x12bit u_mult_12x12bit_q (
    .CLK                               (clk                       ),// input wire CLK
    .A                                 (qpsk_signal_in_q          ),// input wire [11 : 0] A
    .B                                 (delta_amp                 ),// input wire [11 : 0] B
    .P                                 (qpsk_amp_corrected_q      ) // output wire [23 : 0] P
);

//除法器例化
div_12bit u_div_12bit (
    .aclk                              (clk                       ),// input wire aclk
    .aresetn                           (rst_n                     ),// input wire aresetn
    .s_axis_divisor_tvalid             (channel_data_valid        ),// input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata              ({4'b0,channel_amplitude}  ),// input wire [15 : 0] s_axis_divisor_tdata
    .s_axis_dividend_tvalid            (ref_valid                 ),// input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata             ({4'b0,ref_amplitude}      ),// input wire [15 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid                (div_out_valid             ),// output wire m_axis_dout_tvalid
    .m_axis_dout_tdata                 (div_data_out              ) // output wire [23 : 0] m_axis_dout_tdata
);

//qpsk幅度校正完成有效信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        qpsk_amp_corrected_valid <= 1'b0;
        qpsk_amp_corrected_valid_buf1 <= 1'b0;
        qpsk_amp_corrected_valid_buf2 <= 1'b0;
    end
    else begin
        if ((s_amp_phase_ready == 1'b1)&(qpsk_signal_in_valid == 1'b1)) begin
            qpsk_amp_corrected_valid <= qpsk_amp_corrected_valid_buf1;
            qpsk_amp_corrected_valid_buf1 <= qpsk_amp_corrected_valid_buf2;
            qpsk_amp_corrected_valid_buf2 <= 1'b1;
        end
        else begin
            qpsk_amp_corrected_valid <= qpsk_amp_corrected_valid;
            qpsk_amp_corrected_valid_buf1 <= qpsk_amp_corrected_valid_buf1;
            qpsk_amp_corrected_valid_buf2 <= qpsk_amp_corrected_valid_buf2;
        end        
    end
end

//计算delta_phase
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        delta_phase <= $signed(12'b0);
    end
    else begin
        if (channel_data_valid == 1'b1) begin
            delta_phase <= ref_phase - channel_phase;
        end
        else begin
            delta_phase <= delta_phase;
        end
    end
end

//计算旋转因子
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        delta_rotation <= $signed(12'b0);
    end
    else begin
        if (channel_data_valid == 1'b1) begin
            if (delta_phase >= negative_pi) begin
                delta_rotation <= delta_phase;
            end
            else begin
                delta_rotation <= delta_phase + pix2;
            end
        end
        else begin
            delta_rotation <= delta_rotation;
        end        
    end
end

//计算delta_amp
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        delta_amp <= $signed(12'b0);
    end
    else begin
        if (div_out_valid == 1'b1) begin
            delta_amp <= $signed({div_quotient[11],div_quotient[0],div_fractional[9:0]}); //取整数部分的符号位和最低位，以及小数部分的非符号位，得到1个符号位、1个整数位、10个小数位(fix12_10)。
        end
        else begin
            delta_amp <= delta_amp;
        end        
    end
end

//delta_amp有效信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        delta_amp_valid <= 1'b0;
    end
    else begin
        if (div_out_valid == 1'b1) begin
            delta_amp_valid <= 1'b1;
        end
        else begin
            delta_amp_valid <= delta_amp_valid;
        end        
    end
end

//计算输出信号索引
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        signal_out_index <= 17'b0;
    end
    else begin
        if (signal_out_index >= 17'd79999) begin
            signal_out_index <= 17'd79999;
        end
        else if (qpsk_signal_out_valid == 1'b1) begin
            signal_out_index <= signal_out_index + 1'b1;
        end
        else begin
            signal_out_index <= signal_out_index;
        end        
    end
end

endmodule
