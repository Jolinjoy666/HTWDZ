module tone_signal_correct(
    //系统信号
    input                               clk                        ,
    input                               rst_n                      ,
    //bram读信号
    input       signed [  11:0]         tone_signal                ,//单音校正信号(bram读数据)
    input                               tone_signal_valid          ,//单音校正信号输入有效信号(bram读数据有效信号)
    
    //处理输出接口
    output     signed  [11:0]           channel_phase              ,//通道校正相位
    output     signed  [11:0]           channel_amplitude          ,//通道校正幅度
    output                              channel_data_valid          //通道数据输出有效信号
);

//reg define

//wire define
wire                   [  47:0]         fft_m_data_tdata           ;
wire                                    fft_m_data_tvalid          ;
wire                   [   7:0]         fft_m_data_tuser           ;
wire                                    fft_m_data_tlast           ;
wire                                    fft_m_data_tready          ;
  
wire                                    fft_s_config_tready        ;

wire                   [  31:0]         fft_s_data_tdata           ;
wire                                    fft_s_data_tvalid          ;
wire                                    fft_s_data_tready          ;
wire                                    fft_s_data_tlast           ;

wire                                    fft_event_frame_started    ;
wire                                    fft_event_tlast_unexpected ;
wire                                    fft_event_tlast_missing    ;
wire                                    fft_event_status_channel_halt;
wire                                    fft_event_data_in_channel_halt;
wire                                    fft_event_data_out_channel_halt;

wire                   [   7:0]         XK_INDEX                   ;

//---------------------------------------------------------------------------------------------------------------
//-----------------------------                   main code                         -----------------------------
//---------------------------------------------------------------------------------------------------------------

assign XK_INDEX = fft_m_data_tuser;

//预处理模块
pre_process  u_pre_process (
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .tone_signal                       (tone_signal               ),
    .tone_signal_valid                 (tone_signal_valid         ),
    .fft_s_data_tready                 (fft_s_data_tready         ),

    .fft_s_data_tdata                  (fft_s_data_tdata          ),
    .fft_s_data_tvalid                 (fft_s_data_tvalid         ),
    .fft_s_data_tlast                  (fft_s_data_tlast          ) 
);

//FFT模块
FFT_256 u_FFT_256 (
    //配置信号
    .aclk                              (clk                       ),// 时钟信号（input）
    .aresetn                           (rst_n                     ),// 复位信号，低有效（input）
    .s_axis_config_tdata               (8'd1                      ),// ip核设置参数内容，为1时做FFT运算，为0时做IFFT运算（input）
    .s_axis_config_tvalid              (1'b1                      ),// ip核配置输入有效，可直接设置为1（input）
    .s_axis_config_tready              (fft_s_config_tready       ),// output wire s_axis_config_tready
    //作为接收时域数据时是从设备
    .s_axis_data_tdata                 (fft_s_data_tdata          ),// 把时域信号往FFT IP核传输的数据通道,[27:16]为虚部，[11:0]为实部（input，主->从）
    .s_axis_data_tvalid                (fft_s_data_tvalid         ),// 表示主设备正在驱动一个有效的传输（input，主->从）
    .s_axis_data_tready                (fft_s_data_tready         ),// 表示从设备已经准备好接收一次数据传输（output，从->主），当tvalid和tready同时为高时，启动数据传输
    .s_axis_data_tlast                 (fft_s_data_tlast          ),// 主设备向从设备发送传输结束信号（input，主->从，拉高为结束）
    //作为发送频谱数据时是主设备
    .m_axis_data_tdata                 (fft_m_data_tdata          ),// FFT输出的频谱数据，[44:24]对应的是虚部数据，[20:0]对应的是实部数据(output，主->从)。
    .m_axis_data_tuser                 (fft_m_data_tuser          ),// 输出频谱的索引(output，主->从)，该值*fs/N即为对应频点,[7:0]携带XK_INDEX（输出数据索引）信息。
    .m_axis_data_tvalid                (fft_m_data_tvalid         ),// 表示主设备正在驱动一个有效的传输（output，主->从）
    .m_axis_data_tready                (fft_m_data_tready         ),// 表示从设备已经准备好接收一次数据传输（input，从->主），当tvalid和tready同时为高时，启动数据传输
    .m_axis_data_tlast                 (fft_m_data_tlast          ),// 主设备向从设备发送传输结束信号（output，主->从，拉高为结束）
    //其他输出数据
    .event_frame_started               (fft_event_frame_started   ),// output 拉高一个时钟周期，指示开启新的处理过程，一般用于更新配置信息。
    .event_tlast_unexpected            (fft_event_tlast_unexpected),// output 当ip核没有采集到足够点数就出现了s_axis_data_tlast拉高，会产生提示。
    .event_tlast_missing               (fft_event_tlast_missing   ),// output 当采集的数据足够但s_axis_data_tlast未拉高时，会产生提示。
    .event_status_channel_halt         (fft_event_status_channel_halt),// output 当内核准备好输出状态数据但是无法输出。
    .event_data_in_channel_halt        (fft_event_data_in_channel_halt),// output 当内核准备好接收数据但无有效数据输入时产生提示。
    .event_data_out_channel_halt       (fft_event_data_out_channel_halt) // output 当内核准备好输出数据但是无法输出。
);

//后处理模块
post_process u_post_process(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .fft_m_data_tdata                  (fft_m_data_tdata          ),
    .fft_m_data_tvalid                 (fft_m_data_tvalid         ),
    .fft_m_data_tuser                  (fft_m_data_tuser          ),
    .fft_m_data_tlast                  (fft_m_data_tlast          ),
    .fft_m_data_tready                 (fft_m_data_tready         ),
    .channel_phase                     (channel_phase             ),
    .channel_amplitude                 (channel_amplitude         ),
    .channel_data_valid                (channel_data_valid        ) 
);


endmodule
