clc
clear
close all
N=256;%����FFT������Ŀ
t=-N+1:N-1;%apFFT��Ҫ�����ĵ���Ϊ2N-1
A0=1;
p0=1;
A0=A0*(2^11-1); %ת��Ϊ12bit����  ��ʵ���ã�
p0=p0*2*pi; 
f=16;
y=round(A0*cos(2*pi*t*f/N+p0));%����
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


%% Ԥ������
% hanning��
win=hanning(N)';
winn=conv(win,win);
win2=round(winn/sum(winn)*(350000));%����win2��ֵ������Ϊ12bit�������˷����Ƿ���Լ�Ϊ��6λ��ˣ�
figure(2)


plot(win2)
win3=dec2bin(win2,12);
dlmwrite('win2.txt',win3,'delimiter','','precision',3)


% �����źŵĴ���
y2=y.*win2; %�˷�+��λ��λ+��������

figure(3)
plot(y2)

y22=round((y2(N:end)+[0 y2(1:N-1)])./(2^12)); %��λ��� ��λ ����
%y22_1=round(y2(N:end)+[0 y2(1:N-1)]); %256��511 + {0 1��255}
%y22=[y2(N+1:end) 0]+y2(1:N); %��λ���
figure(4)
plot(y22);


%% FFT
y2_fft=round(fft(y22,N)); %fft������Ϊ2·12bit�����ݣ����Ϊ2·21bit�����ݣ�IP������Ϊ12bit��
%y2_fft=flip(y2_fft);
figure(5)
plot(y2_fft)
y2_fft_I=imag(y2_fft);
y2_fft_Q=real(y2_fft);

%% ����
%a2=round(abs(y2_fft)); %ȡģ��������Ӳ�����㣺ֱ��ƽ����ӣ����ÿ����ţ�
a2=(y2_fft_I.*y2_fft_I+y2_fft_Q.*y2_fft_Q);
%a3=sqrt(y2_fft_I.*y2_fft_I+y2_fft_Q.*y2_fft_Q);
figure(6)
plot(a2)
%figure(8)
%plot(a3)

%p2=mod(phase(y2_fft)*180/pi,360); %ȡ��λ��arctan��ȡ�ࣩ���Ƿ���Ҫ���е㣿��
p2=mod(phase(y2_fft),2*pi);
%p2=atan(imag(y2_fft),real(y2_fft));
figure(7)
plot(p2)

[pks,locs]=max(a2(1:N/2)); %ȡ���ֵ�����ֵ�������е�λ��
A=round(sqrt(pks)/2^6); %����6λ
%p=p2(locs);
%p=mod(atan2(imag(y2_fft(locs)),real(y2_fft(locs))),2*pi);
p=atan2(imag(y2_fft(locs)),real(y2_fft(locs))); % �����ֵ����Ƶ������
if p<0,
    p=p+2*pi;
end