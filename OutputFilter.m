% MATLAB doesn't have any built-in cryptographic hashing functions, but
% allows calls to be made to the .NET standard library, which does have
% built-in cryptographic hashing functions. This code works by calling
% those .NET functions meaning, due to MATLAB-.NET interoperability,
% !THIS FILE WILL ONLY RUN ON WINDOWS MACHINES!
clear; clc; close all;

%% Global Constants
inputFilename = 'log.csv';
outputFilename = 'data.csv';
filter = 0.1; % Throw out row if autocorrelation is greater than value

%% Global Variables
% .NET specific
sha256 = System.Security.Cryptography.SHA256Managed;

%% Open Log file
[fid, errMsg] = fopen(outputFilename, 'w');

if (fid == -1)
    fprintf('Could not open %s because %s.\n', outputFilename, errMsg);
    return;
end

%% Read data, hash, output
data = uint16(readmatrix(inputFilename));

for i = 1:size(data, 1)
    % Filter data
    if data(i, 1) < filter
        % Hash data
        dataBytes = typecast(data(i, 2:end), 'uint8');
        hash = uint8(sha256.ComputeHash(dataBytes));

        % Output data
        fprintf(fid, '%g, ', hash(1:end-1));
        fprintf(fid, '%g\n', hash(end));
    end
end

% Clean up file handle
fclose(fid);
