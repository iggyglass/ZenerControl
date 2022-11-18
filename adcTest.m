clear; clc;

a = arduino();
adc = addon(a, 'ADC/ADCControl');

setADCBits(adc, 10);

readings = zeros(1,100);

for i = 1:100
    readings(i) = readADC(adc, 'A0');
    pause(0.1);
end

plot(1:100,readings);
