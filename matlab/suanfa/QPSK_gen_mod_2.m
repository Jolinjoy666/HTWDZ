
clc
clear

%% 参数配置
data_length = 1e4;  %基带数据总长度
fs = 30.72e6;       %采样率30.72MHz （9361最大采样率为61.44MHz）
Rs = 1.92e6;        %符号速率1.92MHz
OSR = fs/Rs;        %过采样率（整数，一般不小于4）
alpha = 0.3;        %根升余弦成型系数 取值一般0.3~1之间  信号双边带带宽B=Rs*（1+alpha）
atten = 1;          %幅度衰减，默认atten = 1为数字的最大输出功率
phase = 0.1;        %取值0~1 随机相位


%% QPSK数据产生
trans_data_bit = randi([0 1],1,data_length);                %产生随机数据流
trans_data_bio = 1-2*trans_data_bit;                        %基带数据两极化
trans_data_IQ_matrix = reshape(trans_data_bio,2,[]);        %qpsk串并转换
trans_data_I = trans_data_IQ_matrix(1,:);
trans_data_Q = trans_data_IQ_matrix(2,:);
rcosfir = rcosdesign(alpha,6,OSR,'sqrt');                       %根升余弦成型滤波器例化
trans_data_upsample_I = upsample(trans_data_I,OSR,0);                  %I路基带上采样    
trans_data_forming_I = conv(trans_data_upsample_I,rcosfir,'same');     %I路成型   
trans_data_upsample_Q = upsample(trans_data_Q,OSR,0);                  %Q路基带上采样 
trans_data_forming_Q = conv(trans_data_upsample_Q,rcosfir,'same');     %Q路成型 
trans_data_complex = trans_data_forming_I + 1j*trans_data_forming_Q;   %复基带数据生成
trans_data_complex = trans_data_complex .* exp(1j*2*pi*phase);                  %添加随机相位

pwelch(trans_data_complex)

%% 输出数据 16进制

trans_data_max = max([real(trans_data_complex) imag(trans_data_complex)]);
trans_data_forming_I_12bit = round(atten*round(real(trans_data_complex)/trans_data_max * (2^11-1)));  %归一化添加幅度变量
trans_data_forming_Q_12bit = round(atten*round(imag(trans_data_complex)/trans_data_max * (2^11-1)));  %归一化添加幅度变量

trans_data_I_12bit_c(trans_data_forming_I_12bit >= 0) = trans_data_forming_I_12bit(trans_data_forming_I_12bit >= 0);
trans_data_I_12bit_c(trans_data_forming_I_12bit < 0) = trans_data_forming_I_12bit(trans_data_forming_I_12bit < 0) + 2^12;
trans_data_Q_12bit_c(trans_data_forming_Q_12bit >= 0) = trans_data_forming_Q_12bit(trans_data_forming_Q_12bit >= 0);
trans_data_Q_12bit_c(trans_data_forming_Q_12bit < 0) = trans_data_forming_Q_12bit(trans_data_forming_Q_12bit < 0) + 2^12;
trans_data_I_12bit_h_out = dec2hex(trans_data_I_12bit_c);
trans_data_q_12bit_h_out = dec2hex(trans_data_Q_12bit_c);

dlmwrite('QPSK_I_12bit_h_out.txt',trans_data_I_12bit_h_out,'delimiter','','precision',3)
dlmwrite('QPSK_Q_12bit_h_out.txt',trans_data_q_12bit_h_out,'delimiter','','precision',3)

trans_data_I_12bit_h_out_1 = reshape(trans_data_I_12bit_h_out',1,80000*3);
dlmwrite('QPSK_I_12bit_h_out_1.txt',trans_data_I_12bit_h_out_1,'delimiter','','precision',3)
plot(trans_data_I_12bit_c)



