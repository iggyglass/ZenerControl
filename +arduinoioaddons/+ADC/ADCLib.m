classdef ADCLib < matlabshared.addon.LibraryBase
    
    % Private properties for command types
    properties(Access=private, Constant=true)
        READ_ADC     = hex2dec('01')
        SET_ADC_BITS = hex2dec('02')
    end

    % Protected properties for setup
    properties(Access=protected, Constant=true)
        LibraryName = 'ADC/ADCControl'
        DependentLibraries = {}
        LibraryHeaderFiles = {}
        CppHeaderFile = fullfile(arduinoio.FilePath(mfilename('fullpath')), 'src', 'ADC.h')
        CppClassName = 'ADCLib'
    end

    % Constructor
    methods(Hidden, Access=public)
        function obj = ADCLib(parentObj)
            obj.Parent = parentObj;
        end
    end

    % Public/User methods
    methods(Access=public)
        % Read raw value from the ADC, with pre-deterimined number of
        % sample bits
        function val = readADC(obj, pin)
            cmdID = obj.READ_ADC;

            try
                terminal = getTerminalsFromPins(obj.Parent, pin);
                val = sendCommand(obj, obj.LibraryName, cmdID, terminal);
                val = typecast(uint8(val), 'uint16');
            catch e
                throwAsCaller(e);
            end
        end

        % Set the number of bits to use per sample in the ADC
        function setADCBits(obj, n)
            cmdID = obj.SET_ADC_BITS;

            try
                sendCommand(obj, obj.LibraryName, cmdID, uint8(n));
            catch e
                throwAsCaller(e);
            end
        end
    end
end
