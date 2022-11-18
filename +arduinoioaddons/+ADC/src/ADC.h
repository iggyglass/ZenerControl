#include "LibraryBase.h"

#define SAMPLE_COUNT 512
#define NUM_ADC_BITS 10

const char MSG_UNKNOWN_CMD[] PROGMEM = "ADC/ADCControl[%d]->Unknown Command\n";

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

                // Who needs standards compliance anyways
                sendResponseMsg(cmdID, (uint8_t*)(&val), 2);
                break;
            }
            case CmdID::SET_ADC_BITS:
            {
                uint8_t bits = dataIn[0];

                this->adcShift = NUM_ADC_BITS >= bits ? NUM_ADC_BITS - bits : NUM_ADC_BITS;
                sendResponseMsg(cmdID, nullptr, 0);

                break;
            }
            case CmdID::READ_SAMPLES:
            {
                uint8_t pin = dataIn[0];
                uint16_t waitTime = *((uint16_t*)&dataIn[1]);

                for (int i = 0; i < SAMPLE_COUNT; i++)
                {
                    samples[i] = readAdcValue(pin);
                    delayMicroseconds(waitTime);
                }

                // TODO: send wait time in response to check endianness
                sendResponseMsg(cmdID, (uint8_t*)(&samples[0]), SAMPLE_COUNT * 2);
                break;
            }
            default:
                debugPrint(MSG_UNKNOWN_CMD);
        }
    }
};
