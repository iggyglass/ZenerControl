clear; clc; close all;

a = arduino();
adc = addon(a, 'ADC/ADCControl');

setADCBits(adc, 10);

