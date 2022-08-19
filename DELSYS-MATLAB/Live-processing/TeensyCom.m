%% Communication with Teensy

function TeensyCom(ActL, ActR)

%MATLAB Code for Serial Communication between Arduino and MATLAB
gLeft = "g"+ActL;
gRight = "g"+ActR;
L = serialport('COM3', 57600);
R = serialport('COM8', 57600);

write(L,gLeft,"uint8")
write(R,gRight,"uint8")
