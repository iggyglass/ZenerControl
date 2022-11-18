% Script to control sampled autocorrelation of Zener noise on an Arduino
% Iggy Glassman, Nov. '22
clear; clc; close all;

%% Approximation Constants
resistance = 1000;   % Resistance of pulldown resistor used
capacitance = 1e-7;  % Junction capacitance of Zener diode
numBits = 10;        % Total number of ADC bits

%% LQR Heuristics 
stateCosts = 1; % TODO: find a good number
inputCosts = [2;3]; % TODO: same lol

%% LQR Setup
A = 0; % TODO: make sure system matrices are correct

% The 1/(pi*r*c) term comes from the Zener circuit (with modeled junciton capacitance)
% acting as a LPF (-3dB cutoff=1/(2pi*r*c)) thus we need to sample below 2x the
% cutoff frequency (Shannon-Nyquist), and we need inverse proportionality to period
% (since period is what we control, not frequency), 1/1/2/(2pi*r*c)=1/(pi*r*c)
B = [1/(pi*resistance*capacitance); 1/numBits];

K = lqr(A, B, stateCosts, inputCosts); % TODO: use lqrd()?

%% Data Logging Setup
dataFile = 'log.csv';

[fid, errMsg] = fopen(dataFile, 'w');

% Cleanup file after exiting program
cleanup = onCleanup(@()fclose(fid));

if (fid == -1)
    fprintf('Could not open %s because %s.\n', dataFile, errMsg);
    return;
end

%% Control the noise

% Setup arduino stuff
pinNumber = 'A0';
device = arduino();
adc = addon(device, 'ADC/ADCControl');
setADCBits(adc, 10);

% Init variables and do the thing
readings = zeros(1, 512);
inputs = [0, 10];

while (true)
    % Read Data
    readings = readADCSamples(device, pinNumber, inputs(1));
    [acf, lags] = autocorr(readings);
    maxAcf = max(abs(acf));

    % Control System
    inputs = K * maxAcf;
    setADCBits(adc, inputs(2));

    % Log Data
    fprintf(fid, '%g, ', maxAcf, readings(1:end-1));
    fprintf(fid, '%g\n', readings(end));
end
