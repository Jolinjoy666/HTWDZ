function [A,p]=dan_cor(Am,pm,f)
N=256;%����FFT������Ŀ
t=-N+1:N-1;%apFFT��Ҫ�����ĵ���Ϊ2N-1
p0=pm;
A0=Am;
y=round(A0*cos(2*pi*t*f/N+p0));%���� ��������

%% Ԥ����ģ��
% hanning��
win=hanning(N)';
winn=conv(win,win);
win2=round(winn/sum(winn)*350000);%����win2��ֵ������Ϊ12bit����

% �����źŵĴ���
y2=y.*win2; %�˷�+��λ��λ(����12λ)+��������
y22=round((y2(N:end)+[0 y2(1:N-1)])./(2^12)); %��λ���

%% FFTģ��
y2_fft=round(fft(y22,N)); %fft������Ϊ2·12bit�����ݣ����Ϊ2·21bit�����ݣ�IP������Ϊ12bit��
y2_fft_I=imag(y2_fft);
y2_fft_Q=real(y2_fft);

%% ����ģ��
%a2=abs(y2_fft); %ȡģ��������Ӳ�����㣺ֱ��ƽ����ӣ����ÿ����ţ�
a2=(y2_fft_I.*y2_fft_I+y2_fft_Q.*y2_fft_Q);
%p2=mod(phase(y2_fft)*180/pi,360); %ȡ��λ��arctan��ȡ�ࣩ
%p2=mod(phase(y2_fft),2*pi); %ȡ��λ��arctan��ȡ�ࣩ
[pks,locs]=max(a2(1:N/2)); %ȡ���ֵ�����ֵ�������е�λ��
A=round(sqrt(pks)/2^6); %����6λ���Ƚ�����12bit�ķ�Χ
%p=p2(locs);
%p=mod(atan2(imag(y2_fft(locs)),real(y2_fft(locs))),2*pi); % �����ֵ����Ƶ������
p=atan2(imag(y2_fft(locs)),real(y2_fft(locs))); % �����ֵ����Ƶ������ȡ��λ��arctan��ȡ�ࣩ
if p<0
    p=p+2*pi;
end
