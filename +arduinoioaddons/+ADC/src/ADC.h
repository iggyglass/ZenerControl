#include "LibraryBase.h"

const char MSG_UNKNOWN_CMD[] PROGMEM = "ADC/ADCControl[%d]->Unknown Command\n";

class ADCLib : public LibraryBase
{
private:
    enum CmdID
    {
        READ_ADC = 0x01,
        SET_ADC_BITS = 0x02
    };

    const uint8_t NUM_ADC_BITS = 10;

    uint8_t adcShift = 0;

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
                byte pin = dataIn[0];
                uint16_t val = analogRead(pin) >> this->adcShift;

                // Who needs standards compliance anyways
                sendResponseMsg(cmdID, (uint8_t*)(&val), 2);
                break;
            }
            case CmdID::SET_ADC_BITS:
            {
                byte bits = dataIn[0];

                this->adcShift = NUM_ADC_BITS > bits ? NUM_ADC_BITS - bits : NUM_ADC_BITS;
                sendResponseMsg(cmdID, nullptr, 0);

                break;
            }
            default:
                debugPrint(MSG_UNKNOWN_CMD);
        }
    }
};
