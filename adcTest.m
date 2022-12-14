% File used for testing the custom ADC Arduino/MATLAB interface library
clear; clc; close all;

a = arduino();
adc = addon(a, 'ADC/ADCControl');

setADCBits(adc, 10);

data = readADCSamples(adc, 'A0', 0);
times = [1:512]';

plot(times, data);
