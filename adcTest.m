% File used for testing the custom ADC Arduino/MATLAB interface library
clear; clc; close all;

a = arduino();
adc = addon(a, 'ADC/ADCControl');

setADCBits(adc, 10);

data = readADCSamples(adc, 'A0', 0.01);
fprintf('%g, ', data);
fprintf('\n');
