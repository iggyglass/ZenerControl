#pragma once

#include "LibraryBase.h"

#define SAMPLE_COUNT 512
#define NUM_ADC_BITS 10

const char MSG_UNKNOWN_CMD[] PROGMEM = "ADC/ADCControl[%d]->Unknown Command\n";
const char MSG_TOO_FEW_PARAMS[] PROGMEM = "ADC/ADCControl[%d]->Not Enough Arguments\n";

class ADCLib : public LibraryBase
{
private:
    enum CmdID
    {
        READ_ADC = 0x01,
        SET_ADC_BITS = 0x02,
        READ_SAMPLES = 0x03
    };

    uint8_t adcShift = 0;
    uint16_t samples[SAMPLE_COUNT] = {};

private:
    inline uint16_t readAdcValue(uint8_t pin)
    {
        // RSH to make readings over a less precise scale
        return analogRead(pin) >> this->adcShift;
    }

public:
    ADCLib(MWArduinoClass& a)
    {
        libName = "ADC/ADCControl";
        a.registerLibrary(this);
    }

    void commandHandler(byte cmdID, byte* dataIn, unsigned int payloadSize)
    {
        switch (cmdID)
        {
            case CmdID::READ_ADC:
            {
                uint8_t pin = dataIn[0];
                uint16_t val = readAdcValue(pin);

                // Not standards compliant, but AVR-GCC will compile it and
                // it will work as x86-64 (the arch of our host computer)
                // has the same endianness as AVR (little)
                sendResponseMsg(cmdID, (uint8_t*)(&val), 2);
                break;
            }
            case CmdID::SET_ADC_BITS:
            {
                uint8_t bits = dataIn[0];

                // Set shift to 10 (max sample bits) minus the passed in
                // number of bits
                this->adcShift = NUM_ADC_BITS >= bits ? NUM_ADC_BITS - bits : NUM_ADC_BITS;
                sendResponseMsg(cmdID, nullptr, 0);

                break;
            }
            case CmdID::READ_SAMPLES:
            {
                uint8_t pin = dataIn[0];
                uint16_t waitTime = *((uint16_t*)&dataIn[1]);
                
                // Read samples and cache them in large array -- sending
                // data back to MATLAB through a serial port takes A LOT of
                // time relatively speaking, so do a bunch of readings and
                // send them all at once
                for (int i = 0; i < SAMPLE_COUNT; i++)
                {
                    this->samples[i] = readAdcValue(pin);
                    delayMicroseconds(waitTime);
                }

                sendResponseMsg(cmdID, (uint8_t*)(&this->samples[0]), SAMPLE_COUNT * 2);
                break;
            }
            default:
                debugPrint(MSG_UNKNOWN_CMD);
        }
    }
};
