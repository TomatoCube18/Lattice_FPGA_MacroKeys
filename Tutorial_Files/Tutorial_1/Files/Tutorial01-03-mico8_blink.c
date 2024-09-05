/**************************************************************
 * This example Blink LED on 6-Key Macro-KeyPad Development   *
 * board.                                                     *
 --------------------------------------------------------------
 * PREREQUISITES:                                             *
 * - GPIO with 1-bit output named LED connected to the        *
 *   board's LED pins.                                        *
 *                                                            *
 **************************************************************/

#include "MicoUtils.h"
#include "MicoGPIO.h"
#include "DDStructs.h"

int main(void)
{
    unsigned char ledVal = 0x01;
    unsigned char buttonsVal = 0x00;

    /* Fetch GPIO instance named "LED" */
    MicoGPIOCtx_t *led = &gpio_LED;
    if (led == 0)
    {
        return (0);
    }
    /* Fetch GPIO instance named "BUTTON" */
    MicoGPIOCtx_t *buttons = &gpio_BUTTON;
    if (buttons == 0)
    {
        return (0);
    }

    /* Blink the LEDs, every 100 or 250 msecs controlled by Button_U forever */
    while (1)
    {
        MICO_GPIO_WRITE_DATA_BYTE0(led->base, ledVal);
        MICO_GPIO_READ_DATA_BYTE0(buttons->base, buttonsVal);

        MicoSleepMilliSecs((buttonsVal & 0x40) ? 100 : 250);

        ledVal = (ledVal == 0x01) ? 0x00 : 0x01;
    }

    /* all done */
    return (0);
}