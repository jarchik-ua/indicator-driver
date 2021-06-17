
#ifndef DRIVERS_INDICATOR_H_
#define DRIVERS_INDICATOR_H_


#define LIGHT_ON                    1
#define LIGHT_OFF                   0

#define LED_1                       6
#define LED_2                       4
#define LED_3                       5


void  ind_led_set( uint8_t led, int8_t state );
void  ind_print_string( char * number );
void  ind_print_dec( uint16_t number );
void  ind_init( void );



#endif /* DRIVERS_INDICATOR_H_ */
