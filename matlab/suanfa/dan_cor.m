function [A,p]=dan_cor(Am,pm,f)
N=256;%常规FFT采样数目
t=-N+1:N-1;%apFFT需要采样的点数为2N-1
p0=pm;
A0=Am;
y=round(A0*cos(2*pi*t*f/N+p0));%采样 整数量化

%% 预处理模块
% hanning窗
win=hanning(N)';
winn=conv(win,win);
win2=round(winn/sum(winn)*350000);%扩大win2的值，量化为12bit整数

% 采样信号的处理
y2=y.*win2; %乘法+高位截位(右移12位)+整数量化
y22=round((y2(N:end)+[0 y2(1:N-1)])./(2^12)); %移位相加

%% FFT模块
y2_fft=round(fft(y22,N)); %fft（输入为2路12bit的数据，输出为2路21bit的数据，IP核缩放为12bit）
y2_fft_I=imag(y2_fft);
y2_fft_Q=real(y2_fft);

%% 后处理模块
%a2=abs(y2_fft); %取模（量化？硬件计算：直接平方相加，不用开根号）
a2=(y2_fft_I.*y2_fft_I+y2_fft_Q.*y2_fft_Q);
%p2=mod(phase(y2_fft)*180/pi,360); %取相位（arctan和取余）
%p2=mod(phase(y2_fft),2*pi); %取相位（arctan和取余）
[pks,locs]=max(a2(1:N/2)); %取最大值和最大值在数组中的位置
A=round(sqrt(pks)/2^6); %右移6位，比较契合12bit的范围
%p=p2(locs);
%p=mod(atan2(imag(y2_fft(locs)),real(y2_fft(locs))),2*pi); % 求最大值所在频点的相角
p=atan2(imag(y2_fft(locs)),real(y2_fft(locs))); % 求最大值所在频点的相角取相位（arctan和取余）
if p<0
    p=p+2*pi;
end
