delete(SerialObj);
SerialObj = serialport("COM3",115200);   % 串口参数配置
AA=[0,0,4];
write(SerialObj,AA,'int8');
data = read(SerialObj,7500,"uint32" );  
% 一次读取一个字节，将每个字节解释为一个 8 位无符号整数 (uint8)，并返回一个 double 数组
% 此处读取了300个字节
data4_hex = dec2hex(data);