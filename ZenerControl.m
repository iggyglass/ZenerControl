% Script to control sample autocorrelation of Zener noise on an Arduino
% Iggy Glassman, Nov. '22
clear; clc; close all;

%% Approximation Constants
resistance = 100e3;    % Resistance of pulldown resistor used in Ohms
capacitance = 10e-12;  % Junction capacitance of Zener diode in Farads
numBits = 10;          % Maximum ADC resolution in bits

%% LQR Heuristics 
stateCosts = 1.74e5;
inputCosts = [2.5e5,  0;
              0,      1e3];

%% LQR Setup
A = 0;

% The 1/(pi*r*c) term comes from the Zener circuit (with modeled junciton
% capacitance) acting as a LPF (-3dB cutoff=1/(2pi*r*c)) thus we need to
% sample below 2x the cutoff frequency (Shannon-Nyquist), and we need
% inverse proportionality to period (since period is what we control, not
% frequency), 1/1/2/(2pi*r*c)=1/(pi*r*c)
B = [-1/(pi*resistance*capacitance), -1/numBits];

% Find optimal gain matrix
K = lqr(A, B, stateCosts, inputCosts);

%% Data Logging Setup
dataFile = 'log.csv';

[fid, errMsg] = fopen(dataFile, 'w');

if (fid == -1)
    fprintf('Could not open %s because %s.\n', dataFile, errMsg);
    return;
end

% Cleanup file after exiting program
cleanup = onCleanup(@()fclose(fid));

%% Control the noise

% Setup arduino stuff
pinNumber = 'A0';
device = arduino();
adc = addon(device, 'ADC/ADCControl');
setADCBits(adc, 10);

% Init variables and do the thing
readings = zeros(1, 512);
inputs = [0; 0];

while (true)
    % Read Data
    readings = double(readADCSamples(adc, pinNumber, inputs(2)));
    %readings = readings - mean(readings);
    [acf, lags] = autocorr(readings);
    maxAcf = max(abs(acf(2:end)));

    % Control System
    inputs = -K * maxAcf;
    setADCBits(adc, 10 - floor(inputs(2)));

    % Log Data
    fprintf('Period: %d\nBits: %d\nACF: %d\n\n', inputs(1), inputs(2), maxAcf);

    fprintf(fid, '%g, ', maxAcf, readings(1:end-1));
    fprintf(fid, '%g\n', readings(end));
end
