clear; clc;

a = arduino();
adc = addon(a, 'ADC/ADCControl');

setADCBits(adc, 6);

while (1)
    reading = readADC(adc, 'A0');

    display(reading);
    pause(0.5);
end
