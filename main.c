#define F_CPU 16000000L
//#define __AVR_ATmega168__

#include <inttypes.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <util/delay.h>

#include <drivers/indicator.h>



#define TIM1_OCR_PRESC      ( 15 ) // 1,0s for presc 1024


static uint16_t  timer_counter = 0;



ISR (TIMER1_COMPA_vect)
{
   timer_counter ++;
}



void
tim1_init( void )
{
   //
   // Ftim = Fcpu / 1024
   // CTC mode
   //
   TCCR1B = ( 1<<WGM12 );

   OCR1AH = TIM1_OCR_PRESC >> 8;
   OCR1AL = TIM1_OCR_PRESC & 0xff;

   TCCR1B |= ( 1<<CS12 ) | ( 0<<CS11 ) | ( 1<<CS10 );
   TIMSK1 |= ( 1<<OCIE1A );
}


void
led_timer(void)
{
    static uint16_t  timer_leds_one = 0;
    static uint16_t  timer_leds_two = 0;
    static uint16_t  timer_leds_three = 0;

    static uint16_t  light_one;
    static uint16_t  light_two;
    static uint16_t  light_three;


    if( ( timer_counter ) - timer_leds_one >= 500 )
    {
        timer_leds_one = timer_counter;
        light_one = light_one ? 0 : 1;
    }


    if( timer_counter - timer_leds_two >= 333 )
    {
        timer_leds_two = timer_counter;
        light_two = light_two ? 0 : 1;
    }



    if( timer_counter - timer_leds_three >= 100 )
    {
        timer_leds_three = timer_counter;
        light_three = light_three ? 0 : 1;
    }


    ind_led_set(LED_1, light_one);
    ind_led_set(LED_2, light_two);
    ind_led_set(LED_3, light_three);
}


int main( void )
{
    uint16_t  timer = 0;
    char message[6][5] = {"FAUL", "HEAT", "COLD", "1234", " HI ", " LO "};
    char word[4];
    int8_t  j = 0;


    DDRB = (1 << 1) | (1 << 0);


    ind_init();
    tim1_init();

    sei();

    while( 1 )
    {
            for( int8_t i = 0; i < 4; i++ )
            {
                word[i] = message[j][i];
            }


            if( timer_counter - timer >= 2000 )
            {

                timer = timer_counter;

                j += 1;

                if( j > 6 )
                {
                    j = 0;
                }
            }

            ind_print_string(word);
            led_timer();
    }

    return 0;
}
