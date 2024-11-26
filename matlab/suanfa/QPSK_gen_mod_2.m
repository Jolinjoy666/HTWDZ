
clc
clear

%% ��������
data_length = 1e4;  %���������ܳ���
fs = 30.72e6;       %������30.72MHz ��9361��������Ϊ61.44MHz��
Rs = 1.92e6;        %��������1.92MHz
OSR = fs/Rs;        %�������ʣ�������һ�㲻С��4��
alpha = 0.3;        %�������ҳ���ϵ�� ȡֵһ��0.3~1֮��  �ź�˫�ߴ�����B=Rs*��1+alpha��
atten = 1;          %����˥����Ĭ��atten = 1Ϊ���ֵ�����������
phase = 0.1;        %ȡֵ0~1 �����λ


%% QPSK���ݲ���
trans_data_bit = randi([0 1],1,data_length);                %�������������
trans_data_bio = 1-2*trans_data_bit;                        %��������������
trans_data_IQ_matrix = reshape(trans_data_bio,2,[]);        %qpsk����ת��
trans_data_I = trans_data_IQ_matrix(1,:);
trans_data_Q = trans_data_IQ_matrix(2,:);
rcosfir = rcosdesign(alpha,6,OSR,'sqrt');                       %�������ҳ����˲�������
trans_data_upsample_I = upsample(trans_data_I,OSR,0);                  %I·�����ϲ���    
trans_data_forming_I = conv(trans_data_upsample_I,rcosfir,'same');     %I·����   
trans_data_upsample_Q = upsample(trans_data_Q,OSR,0);                  %Q·�����ϲ��� 
trans_data_forming_Q = conv(trans_data_upsample_Q,rcosfir,'same');     %Q·���� 
trans_data_complex = trans_data_forming_I + 1j*trans_data_forming_Q;   %��������������
trans_data_complex = trans_data_complex .* exp(1j*2*pi*phase);                  %��������λ

pwelch(trans_data_complex)

%% ������� 16����

trans_data_max = max([real(trans_data_complex) imag(trans_data_complex)]);
trans_data_forming_I_12bit = round(atten*round(real(trans_data_complex)/trans_data_max * (2^11-1)));  %��һ����ӷ��ȱ���
trans_data_forming_Q_12bit = round(atten*round(imag(trans_data_complex)/trans_data_max * (2^11-1)));  %��һ����ӷ��ȱ���

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



