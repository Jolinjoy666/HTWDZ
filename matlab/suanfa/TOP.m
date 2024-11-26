close all;clc;clear all;
f=16; %单音信号的频率 f的范围？单位？
N=4;  %通道数
AN0=[1 0.8 0.56 0.7]; %AN0即为不同通道atten的值，范围0-1，通道一为1
AN=AN0*(2^11-1); %转化为12bit整数（补码）
pN0=[0 0.3,0.29,0.5]; %pN0即为不同通道phase的值，范围0-1，通道一为0
pN=pN0*2*pi; 

%app.f=16; %单音信号的频率
%app.N=6;  %通道数
%app.AN0=[1 0.9 0.56 0.7 0.8 0.6]; %AN0即为不同通道atten的值，范围0.56-1，通道一为1
%app.AN=round(app.AN0*(2^11-1)); %转化为12bit整数
%app.pN0=[0 0.1,0.29,0.6 0.3 0.4]; %pN0即为不同通道phase的值，范围0-1，通道一为0
%app.pN=app.pN0*2*pi;

%% 单音校正
for i=1:N
   [A(i),p(i)]=dan_cor(AN(i),pN(i),f);  %调用单音校正函数来计算每个通道的幅度和相位
end
A0=A(1);p0=p(1);

%计算校正参数delta_A和delta_p （校正计算模块）
for i=1:N
    delta_A(i)=A0/A(i);
    delta_p(i)=p0-p(i);
end

%校准后的幅度和相位
AF=AN.*delta_A;
pF=pN+delta_p;

tt=0:0.001:0.2;
y1=AN(1)*cos(2*pi*tt*f+pN(1));
y2=AN(2)*cos(2*pi*tt*f+pN(2));
y3=AN(3)*cos(2*pi*tt*f+pN(3));
y4=AN(4)*cos(2*pi*tt*f+pN(4));
figure(1)
plot(tt,y1,tt,y2,tt,y3,tt,y4);
title('单音原信号')
legend('通道1','通道2','通道3','通道4')

y5=AF(1)*cos(2*pi*tt*f+pF(1));
y6=AF(2)*cos(2*pi*tt*f+pF(2));
y7=AF(3)*cos(2*pi*tt*f+pF(3));
y8=AF(4)*cos(2*pi*tt*f+pF(4));
figure(2)
plot(tt,y5,tt,y6,tt,y7,tt,y8);
title('单音校正后的信号')
legend('通道1','通道2','通道3','通道4')

%% QPSK校验  如何查看校正之后的误差？？ 输入单路数据量大于8192（取8800？）
 CI=[];
 CQ=[];
for i=1:N
   [I,Q]=QPSKroad(AN0(i),pN0(i)); %设置各个通道的幅度和相位误差
   CI(i,:)=I;
   CQ(i,:)=Q;
end
 figure(3)
 tn=1:4e2;
 subplot(2,1,1)
 plot(tn,CI(1,1:length(tn)),tn,CI(2,1:length(tn)),tn,CI(3,1:length(tn)),tn,CI(4,1:length(tn)));
 title('QPSK原信号I路')
 legend('通道1','通道2','通道3','通道4')
 subplot(2,1,2)
 plot(tn,CQ(1,1:length(tn)),tn,CQ(2,1:length(tn)),tn,CQ(3,1:length(tn)),tn,CQ(4,1:length(tn)));
 title('QPSK原信号Q路')
 legend('通道1','通道2','通道3','通道4')
 
 %生成用于通道测试的IQ数据
 CI_2=CI(2,:);
for i = 1 :length(CI_2 )
    if(CI_2 (i) <0)
        CI_2 (i) = CI_2 (i) + 2^12;
    end
end
 CI_2=dec2bin(CI_2,12);
 dlmwrite('CI_5.txt',CI_2,'delimiter','','precision',3)
 %CI_2_hex=dec2hex(CI_2,3);
 %CI_2_hex=reshape(CI_2_hex',[1,3*80000]);
 %dlmwrite('CI_4_hex.txt',CI_2_hex(1:30000),'delimiter','','precision',3)

 CQ_2=CQ(2,:);
for i = 1 :length(CQ_2 )
    if(CQ_2 (i) <0)
        CQ_2 (i) = CQ_2 (i) + 2^12;
    end
end
 CQ_2=dec2bin(CQ_2,12);
 dlmwrite('CQ_5.txt',CQ_2,'delimiter','','precision',3)
 %CQ_2_hex=dec2hex(CQ_2,3);
 %CQ_2_hex=reshape(CQ_2_hex',[1,3*80000]);
 %dlmwrite('CQ_4_hex.txt',CQ_2_hex(1:30000),'delimiter','','precision',3)
 
 % 根据delta_A,delta_p对QPSK信号进行校正 （校正计算模块）
 CC=CI+1j*CQ;
 
 for i=1:N
     CC_new(i,:)=round(CC(i,:)*delta_A(i)*exp(1j*delta_p(i))); %如何量化delta_A？相乘之后截位？是否是一个旋转？
 end
 
 figure(4)
 CC_new_real=real(CC_new);
 CC_new_imag=imag(CC_new);

 subplot(2,1,1)
 plot(tn,CC_new_real(1,1:length(tn)),tn,CC_new_real(2,1:length(tn)),tn,CC_new_real(3,1:length(tn)),tn,CC_new_real(4,1:length(tn)));
 title('QPSK校正后的信号I路')
 legend('通道1','通道2','通道3','通道4')
 subplot(2,1,2)
 plot(tn,CC_new_imag(1,1:length(tn)),tn,CC_new_imag(2,1:length(tn)),tn,CC_new_imag(3,1:length(tn)),tn,CC_new_imag(4,1:length(tn)));
 title('QPSK校正后的信号Q路')
 legend('通道1','通道2','通道3','通道4')
 
%% 硬件仿真校正信号
CI_OUT_1=textread('CI_OUT_1.txt','%s');
CI_OUT_1=bin2dec(CI_OUT_1);
for i = 1 :length(CI_OUT_1 )
    if(CI_OUT_1 (i) > 2^11)
        CI_OUT_1 (i) = CI_OUT_1 (i) - 2^12;
    end
end

CQ_OUT_1=textread('CQ_OUT_1.txt','%s');
CQ_OUT_1=bin2dec(CQ_OUT_1);
for i = 1 :length(CQ_OUT_1 )
    if(CQ_OUT_1 (i) > 2^11)
        CQ_OUT_1 (i) = CQ_OUT_1 (i) - 2^12;
    end
end

CI_OUT_2=textread('CI_OUT_2.txt','%s');
CI_OUT_2=bin2dec(CI_OUT_2);
for i = 1 :length(CI_OUT_2 )
    if(CI_OUT_2 (i) > 2^11)
        CI_OUT_2 (i) = CI_OUT_2 (i) - 2^12;
    end
end

CQ_OUT_2=textread('CQ_OUT_2.txt','%s');
CQ_OUT_2=bin2dec(CQ_OUT_2);
for i = 1 :length(CQ_OUT_2 )
    if(CQ_OUT_2 (i) > 2^11)
        CQ_OUT_2 (i) = CQ_OUT_2 (i) - 2^12;
    end
end

CI_OUT_3=textread('CI_OUT_3.txt','%s');
CI_OUT_3=bin2dec(CI_OUT_3);
for i = 1 :length(CI_OUT_3 )
    if(CI_OUT_3 (i) > 2^11)
        CI_OUT_3 (i) = CI_OUT_3 (i) - 2^12;
    end
end

CQ_OUT_3=textread('CQ_OUT_3.txt','%s');
CQ_OUT_3=bin2dec(CQ_OUT_3);
for i = 1 :length(CQ_OUT_3 )
    if(CQ_OUT_3 (i) > 2^11)
        CQ_OUT_3 (i) = CQ_OUT_3 (i) - 2^12;
    end
end

CI_OUT_4=textread('CI_OUT_4.txt','%s');
CI_OUT_4=bin2dec(CI_OUT_4);
for i = 1 :length(CI_OUT_4 )
    if(CI_OUT_4 (i) > 2^11)
        CI_OUT_4 (i) = CI_OUT_4 (i) - 2^12;
    end
end

CQ_OUT_4=textread('CQ_OUT_4.txt','%s');
CQ_OUT_4=bin2dec(CQ_OUT_4);
for i = 1 :length(CQ_OUT_4 )
    if(CQ_OUT_4 (i) > 2^11)
        CQ_OUT_4 (i) = CQ_OUT_4 (i) - 2^12;
    end
end

 figure(5)
 subplot(2,1,1)
 plot(tn,CI_OUT_1(1:length(tn)),tn,CI_OUT_2(1:length(tn)),tn,CI_OUT_3(1:length(tn)),tn,CI_OUT_4(1:length(tn)));
 title('QPSK硬件仿真校正后的信号I路')
 legend('通道1','通道2','通道3','通道4')
 subplot(2,1,2)
 plot(tn,CQ_OUT_1(1:length(tn)),tn,CQ_OUT_2(1:length(tn)),tn,CQ_OUT_3(1:length(tn)),tn,CQ_OUT_4(1:length(tn)));
 title('QPSK硬件仿真校正后的信号Q路')
 legend('通道1','通道2','通道3','通道4')
 set(gcf,'color','white');%白色
 
%% 硬件校正信号
CI_OUT_real_1=textread('CI_OUT_real_1.txt','%s');
CI_OUT_real_1=str2num(char(CI_OUT_real_1));
for i = 1 :length(CI_OUT_real_1 )
    if(CI_OUT_real_1 (i) > 2^11)
        CI_OUT_real_1 (i) = CI_OUT_real_1 (i) - 2^12;
    end
end

CI_OUT_real_2=textread('CI_OUT_real_2.txt','%s');
CI_OUT_real_2=str2num(char(CI_OUT_real_2));
for i = 1 :length(CI_OUT_real_2 )
    if(CI_OUT_real_2 (i) > 2^11)
        CI_OUT_real_2 (i) = CI_OUT_real_2 (i) - 2^12;
    end
end

CI_OUT_real_3=textread('CI_OUT_real_3.txt','%s');
CI_OUT_real_3=str2num(char(CI_OUT_real_3));
for i = 1 :length(CI_OUT_real_3 )
    if(CI_OUT_real_3 (i) > 2^11)
        CI_OUT_real_3 (i) = CI_OUT_real_3 (i) - 2^12;
    end
end

CI_OUT_real_4=textread('CI_OUT_real_4.txt','%s');
CI_OUT_real_4=str2num(char(CI_OUT_real_4));
for i = 1 :length(CI_OUT_real_4 )
    if(CI_OUT_real_4 (i) > 2^11)
        CI_OUT_real_4 (i) = CI_OUT_real_4 (i) - 2^12;
    end
end

CQ_OUT_real_1=textread('CQ_OUT_real_1.txt','%s');
CQ_OUT_real_1=str2num(char(CQ_OUT_real_1));
for i = 1 :length(CQ_OUT_real_1 )
    if(CQ_OUT_real_1 (i) > 2^11)
        CQ_OUT_real_1 (i) = CQ_OUT_real_1 (i) - 2^12;
    end
end

CQ_OUT_real_2=textread('CQ_OUT_real_2.txt','%s');
CQ_OUT_real_2=str2num(char(CQ_OUT_real_2));
for i = 1 :length(CQ_OUT_real_2 )
    if(CQ_OUT_real_2 (i) > 2^11)
        CQ_OUT_real_2 (i) = CQ_OUT_real_2 (i) - 2^12;
    end
end

CQ_OUT_real_3=textread('CQ_OUT_real_3.txt','%s');
CQ_OUT_real_3=str2num(char(CQ_OUT_real_3));
for i = 1 :length(CQ_OUT_real_3 )
    if(CQ_OUT_real_3 (i) > 2^11)
        CQ_OUT_real_3 (i) = CQ_OUT_real_3 (i) - 2^12;
    end
end

CQ_OUT_real_4=textread('CQ_OUT_real_4.txt','%s');
CQ_OUT_real_4=str2num(char(CQ_OUT_real_4));
for i = 1 :length(CQ_OUT_real_4 )
    if(CQ_OUT_real_4 (i) > 2^11)
        CQ_OUT_real_4 (i) = CQ_OUT_real_4 (i) - 2^12;
    end
end

 figure(6)
 subplot(2,1,1)
 plot(tn,CI_OUT_real_1(1:length(tn)),tn,CI_OUT_real_2(1:length(tn)),tn,CI_OUT_real_3(1:length(tn)),tn,CI_OUT_real_4(1:length(tn)));
 title('QPSK硬件校正后的信号I路')
 legend('通道1','通道2','通道3','通道4')
 subplot(2,1,2)
 plot(tn,CQ_OUT_real_1(1:length(tn)),tn,CQ_OUT_real_2(1:length(tn)),tn,CQ_OUT_real_3(1:length(tn)),tn,CQ_OUT_real_4(1:length(tn)));
 title('QPSK硬件校正后的信号Q路')
 legend('通道1','通道2','通道3','通道4')
 set(gcf,'color','white');%白色

  %% 指标检测(取前4000个数据)
 road1=CC_new_real(1,1:4000)+1i* CC_new_imag(1,1:4000);%通道1，参考信道
 road2=CC_new_real(2,1:4000)+1i* CC_new_imag(2,1:4000);%通道2
 road3=CC_new_real(3,1:4000)+1i* CC_new_imag(3,1:4000);%通道3
 road4=CC_new_real(4,1:4000)+1i* CC_new_imag(4,1:4000);%通道4
 road1_out=CI_OUT_1(1:400)+1i*CQ_OUT_1(1:400);%通道1硬件仿真输出
 road2_out=CI_OUT_2(1:400)+1i*CQ_OUT_2(1:400);%通道2硬件仿真输出
 road3_out=CI_OUT_3(1:400)+1i*CQ_OUT_3(1:400);%通道3硬件仿真输出
 road4_out=CI_OUT_4(1:400)+1i*CQ_OUT_4(1:400);%通道4硬件仿真输出
 road1_out_real=CI_OUT_real_1(1:10000)+1i*CQ_OUT_real_1(1:10000);%通道1硬件输出
 road2_out_real=CI_OUT_real_2(1:10000)+1i*CQ_OUT_real_2(1:10000);%通道2硬件输出
 road3_out_real=CI_OUT_real_3(1:10000)+1i*CQ_OUT_real_3(1:10000);%通道3硬件输出
 road4_out_real=CI_OUT_real_4(1:10000)+1i*CQ_OUT_real_4(1:10000);%通道4硬件输出
 
 %同步幅度误差（不大于+-0.5dB）
 ACC1=mean(abs(road1));
 ACC2=mean(abs(road2));
 ACC3=mean(abs(road3));
 ACC4=mean(abs(road4));
 ACC1_out=mean(abs(road1_out));
 ACC2_out=mean(abs(road2_out));
 ACC3_out=mean(abs(road5_out));
 ACC4_out=mean(abs(road6_out));
 ACC1_out_real=mean(abs(road1_out_real));
 ACC2_out_real=mean(abs(road2_out_real));
 ACC3_out_real=mean(abs(road3_out_real));
 ACC4_out_real=mean(abs(road4_out_real));
 ACC=[20*log(ACC1/ACC2),20*log(ACC1/ACC3),20*log(ACC1/ACC4),20*log(ACC1_out/ACC2_out),20*log(ACC1_out/ACC3_out),20*log(ACC1_out/ACC4_out),20*log(ACC1_out_real/ACC2_out_real),20*log(ACC1_out_real/ACC3_out_real),20*log(ACC1_out_real/ACC4_out_real)] %单位为dB
 
 %同步相位误差（不大于+-2度）
 PCC1=mean(phase(road1));
 PCC2=mean(phase(road2));
 PCC3=mean(phase(road3));
 PCC4=mean(phase(road4));
 PCC1_out=mean(phase(road1_out));
 PCC2_out=mean(phase(road2_out));
 PCC3_out=mean(phase(road5_out));
 PCC4_out=mean(phase(road6_out));
 PCC1_out_real=mean(mod(phase(road1_out_real),2*pi));
 PCC2_out_real=mean(mod(phase(road2_out_real),2*pi));
 PCC3_out_real=mean(mod(phase(road3_out_real),2*pi));
 PCC4_out_real=mean(mod(phase(road4_out_real),2*pi));
 PCC=180/pi*[PCC2-PCC1,PCC3-PCC1,PCC4-PCC1,PCC2_out-PCC1_out,PCC3_out-PCC1_out,PCC4_out-PCC1_out,PCC2_out_real-PCC1_out_real,PCC3_out_real-PCC1_out_real,PCC4_out_real-PCC1_out_real] %单位为度