clc
clear
close all
N=256;%常规FFT采样数目
t=-N+1:N-1;%apFFT需要采样的点数为2N-1
A0=1;
p0=1;
A0=A0*(2^11-1); %转化为12bit整数  其实不用？
p0=p0*2*pi; 
f=16;
y=round(A0*cos(2*pi*t*f/N+p0));%采样
figure(1)
plot(y)
y_y=y;
for i = 1 :length(y )
    if(y (i) <0)
        y_y (i) = y_y (i) + 2^12;
    end
end
y_y_2=dec2bin(y_y,12);
dlmwrite('sin_wave.txt',y_y_2,'delimiter','','precision',3)
%y_y_3 = dec2hex(y_y,3);
%y_y_4 = reshape(y_y_3',[1,3*511]);
%dlmwrite('y4_hex.txt',y_y_4,'delimiter','','precision',3)


%% 预处理部分
% hanning窗
win=hanning(N)';
winn=conv(win,win);
win2=round(winn/sum(winn)*(350000));%扩大win2的值，量化为12bit整数（乘法器是否可以简化为高6位相乘）
figure(2)


plot(win2)
win3=dec2bin(win2,12);
dlmwrite('win2.txt',win3,'delimiter','','precision',3)


% 采样信号的处理
y2=y.*win2; %乘法+高位截位+整数量化

figure(3)
plot(y2)

y22=round((y2(N:end)+[0 y2(1:N-1)])./(2^12)); %移位相加 截位 量化
%y22_1=round(y2(N:end)+[0 y2(1:N-1)]); %256：511 + {0 1：255}
%y22=[y2(N+1:end) 0]+y2(1:N); %移位相加
figure(4)
plot(y22);


%% FFT
y2_fft=round(fft(y22,N)); %fft（输入为2路12bit的数据，输出为2路21bit的数据，IP核缩放为12bit）
%y2_fft=flip(y2_fft);
figure(5)
plot(y2_fft)
y2_fft_I=imag(y2_fft);
y2_fft_Q=real(y2_fft);

%% 后处理
%a2=round(abs(y2_fft)); %取模（量化？硬件计算：直接平方相加，不用开根号）
a2=(y2_fft_I.*y2_fft_I+y2_fft_Q.*y2_fft_Q);
%a3=sqrt(y2_fft_I.*y2_fft_I+y2_fft_Q.*y2_fft_Q);
figure(6)
plot(a2)
%figure(8)
%plot(a3)

%p2=mod(phase(y2_fft)*180/pi,360); %取相位（arctan和取余）（是否需要所有点？）
p2=mod(phase(y2_fft),2*pi);
%p2=atan(imag(y2_fft),real(y2_fft));
figure(7)
plot(p2)

[pks,locs]=max(a2(1:N/2)); %取最大值和最大值在数组中的位置
A=round(sqrt(pks)/2^6); %右移6位
%p=p2(locs);
%p=mod(atan2(imag(y2_fft(locs)),real(y2_fft(locs))),2*pi);
p=atan2(imag(y2_fft(locs)),real(y2_fft(locs))); % 求最大值所在频点的相角
if p<0,
    p=p+2*pi;
end