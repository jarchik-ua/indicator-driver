   1               		.file	"main.c"
   2               	__SP_H__ = 0x3e
   3               	__SP_L__ = 0x3d
   4               	__SREG__ = 0x3f
   5               	__tmp_reg__ = 0
   6               	__zero_reg__ = 1
   7               		.text
   8               	.Ltext0:
   9               		.cfi_sections	.debug_frame
  10               		.section	.text.__vector_11,"ax",@progbits
  11               	.global	__vector_11
  13               	__vector_11:
  14               	.LFB6:
  15               		.file 1 "main.c"
   1:main.c        **** #define F_CPU 16000000L
   2:main.c        **** //#define __AVR_ATmega168__
   3:main.c        **** 
   4:main.c        **** #include <inttypes.h>
   5:main.c        **** #include <avr/io.h>
   6:main.c        **** #include <avr/interrupt.h>
   7:main.c        **** #include <avr/sleep.h>
   8:main.c        **** #include <util/delay.h>
   9:main.c        **** 
  10:main.c        **** #include <drivers/indicator.h>
  11:main.c        **** 
  12:main.c        **** 
  13:main.c        **** 
  14:main.c        **** #define TIM1_OCR_PRESC      ( 15 ) // 1,0s for presc 1024
  15:main.c        **** 
  16:main.c        **** 
  17:main.c        **** static uint16_t  timer_counter = 0;
  18:main.c        **** 
  19:main.c        **** 
  20:main.c        **** 
  21:main.c        **** ISR (TIMER1_COMPA_vect)
  22:main.c        **** {
  16               		.loc 1 22 1 view -0
  17               		.cfi_startproc
  18 0000 8F93 8FB7 		__gcc_isr 1
  18      8F93 
  19 0006 9F93      		push r25
  20               	.LCFI0:
  21               		.cfi_def_cfa_offset 3
  22               		.cfi_offset 25, -2
  23               	/* prologue: Signal */
  24               	/* frame size = 0 */
  25               	/* stack size = 1...5 */
  26               	.L__stack_usage = 1 + __gcc_isr.n_pushed
  23:main.c        ****    timer_counter ++;
  27               		.loc 1 23 4 view .LVU1
  28               		.loc 1 23 18 is_stmt 0 view .LVU2
  29 0008 8091 0000 		lds r24,timer_counter
  30 000c 9091 0000 		lds r25,timer_counter+1
  31 0010 0196      		adiw r24,1
  32 0012 9093 0000 		sts timer_counter+1,r25
  33 0016 8093 0000 		sts timer_counter,r24
  34               	/* epilogue start */
  24:main.c        **** }
  35               		.loc 1 24 1 view .LVU3
  36 001a 9F91      		pop r25
  37 001c 8F91 8FBF 		__gcc_isr 2
  37      8F91 
  38 0022 1895      		reti
  39               		__gcc_isr 0,r24
  40               		.cfi_endproc
  41               	.LFE6:
  43               		.section	.text.tim1_init,"ax",@progbits
  44               	.global	tim1_init
  46               	tim1_init:
  47               	.LFB7:
  25:main.c        **** 
  26:main.c        **** 
  27:main.c        **** 
  28:main.c        **** void
  29:main.c        **** tim1_init( void )
  30:main.c        **** {
  48               		.loc 1 30 1 is_stmt 1 view -0
  49               		.cfi_startproc
  50               	/* prologue: function */
  51               	/* frame size = 0 */
  52               	/* stack size = 0 */
  53               	.L__stack_usage = 0
  31:main.c        ****    //
  32:main.c        ****    // Ftim = Fcpu / 1024
  33:main.c        ****    // CTC mode
  34:main.c        ****    //
  35:main.c        ****    TCCR1B = ( 1<<WGM12 );
  54               		.loc 1 35 4 view .LVU5
  55               		.loc 1 35 11 is_stmt 0 view .LVU6
  56 0000 E1E8      		ldi r30,lo8(-127)
  57 0002 F0E0      		ldi r31,0
  58 0004 88E0      		ldi r24,lo8(8)
  59 0006 8083      		st Z,r24
  36:main.c        **** 
  37:main.c        ****    OCR1AH = TIM1_OCR_PRESC >> 8;
  60               		.loc 1 37 4 is_stmt 1 view .LVU7
  61               		.loc 1 37 11 is_stmt 0 view .LVU8
  62 0008 1092 8900 		sts 137,__zero_reg__
  38:main.c        ****    OCR1AL = TIM1_OCR_PRESC & 0xff;
  63               		.loc 1 38 4 is_stmt 1 view .LVU9
  64               		.loc 1 38 11 is_stmt 0 view .LVU10
  65 000c 8FE0      		ldi r24,lo8(15)
  66 000e 8093 8800 		sts 136,r24
  39:main.c        **** 
  40:main.c        ****    TCCR1B |= ( 1<<CS12 ) | ( 0<<CS11 ) | ( 1<<CS10 );
  67               		.loc 1 40 4 is_stmt 1 view .LVU11
  68               		.loc 1 40 11 is_stmt 0 view .LVU12
  69 0012 8081      		ld r24,Z
  70 0014 8560      		ori r24,lo8(5)
  71 0016 8083      		st Z,r24
  41:main.c        ****    TIMSK1 |= ( 1<<OCIE1A );
  72               		.loc 1 41 4 is_stmt 1 view .LVU13
  73               		.loc 1 41 11 is_stmt 0 view .LVU14
  74 0018 EFE6      		ldi r30,lo8(111)
  75 001a F0E0      		ldi r31,0
  76 001c 8081      		ld r24,Z
  77 001e 8260      		ori r24,lo8(2)
  78 0020 8083      		st Z,r24
  79               	/* epilogue start */
  42:main.c        **** }
  80               		.loc 1 42 1 view .LVU15
  81 0022 0895      		ret
  82               		.cfi_endproc
  83               	.LFE7:
  85               		.section	.text.led_timer,"ax",@progbits
  86               	.global	led_timer
  88               	led_timer:
  89               	.LFB8:
  43:main.c        **** 
  44:main.c        **** 
  45:main.c        **** void
  46:main.c        **** led_timer(void)
  47:main.c        **** {
  90               		.loc 1 47 1 is_stmt 1 view -0
  91               		.cfi_startproc
  92               	/* prologue: function */
  93               	/* frame size = 0 */
  94               	/* stack size = 0 */
  95               	.L__stack_usage = 0
  48:main.c        ****     static uint16_t  timer_leds_one = 0;
  96               		.loc 1 48 5 view .LVU17
  49:main.c        ****     static uint16_t  timer_leds_two = 0;
  97               		.loc 1 49 5 view .LVU18
  50:main.c        ****     static uint16_t  timer_leds_three = 0;
  98               		.loc 1 50 5 view .LVU19
  51:main.c        **** 
  52:main.c        ****     static uint16_t  light_one;
  99               		.loc 1 52 5 view .LVU20
  53:main.c        ****     static uint16_t  light_two;
 100               		.loc 1 53 5 view .LVU21
  54:main.c        ****     static uint16_t  light_three;
 101               		.loc 1 54 5 view .LVU22
  55:main.c        **** 
  56:main.c        **** 
  57:main.c        ****     if( ( timer_counter ) - timer_leds_one >= 500 )
 102               		.loc 1 57 5 view .LVU23
 103               		.loc 1 57 27 is_stmt 0 view .LVU24
 104 0000 8091 0000 		lds r24,timer_counter
 105 0004 9091 0000 		lds r25,timer_counter+1
 106 0008 2091 0000 		lds r18,timer_leds_one.1186
 107 000c 3091 0000 		lds r19,timer_leds_one.1186+1
 108 0010 AC01      		movw r20,r24
 109 0012 421B      		sub r20,r18
 110 0014 530B      		sbc r21,r19
 111 0016 9A01      		movw r18,r20
 112               		.loc 1 57 7 view .LVU25
 113 0018 243F      		cpi r18,-12
 114 001a 3140      		sbci r19,1
 115 001c 00F0      		brlo .L4
 116 001e 4091 0000 		lds r20,light_one.1189
 117 0022 5091 0000 		lds r21,light_one.1189+1
  58:main.c        ****     {
  59:main.c        ****         timer_leds_one = timer_counter;
 118               		.loc 1 59 9 is_stmt 1 view .LVU26
 119               		.loc 1 59 24 is_stmt 0 view .LVU27
 120 0026 9093 0000 		sts timer_leds_one.1186+1,r25
 121 002a 8093 0000 		sts timer_leds_one.1186,r24
  60:main.c        ****         light_one = light_one ? 0 : 1;
 122               		.loc 1 60 9 is_stmt 1 view .LVU28
 123               		.loc 1 60 35 is_stmt 0 view .LVU29
 124 002e 21E0      		ldi r18,lo8(1)
 125 0030 30E0      		ldi r19,0
 126 0032 452B      		or r20,r21
 127 0034 01F0      		breq .L5
 128 0036 30E0      		ldi r19,0
 129 0038 20E0      		ldi r18,0
 130               	.L5:
 131               		.loc 1 60 19 view .LVU30
 132 003a 3093 0000 		sts light_one.1189+1,r19
 133 003e 2093 0000 		sts light_one.1189,r18
 134               	.L4:
  61:main.c        ****     }
  62:main.c        **** 
  63:main.c        **** 
  64:main.c        ****     if( timer_counter - timer_leds_two >= 333 )
 135               		.loc 1 64 5 is_stmt 1 view .LVU31
 136               		.loc 1 64 23 is_stmt 0 view .LVU32
 137 0042 2091 0000 		lds r18,timer_leds_two.1187
 138 0046 3091 0000 		lds r19,timer_leds_two.1187+1
 139 004a AC01      		movw r20,r24
 140 004c 421B      		sub r20,r18
 141 004e 530B      		sbc r21,r19
 142 0050 9A01      		movw r18,r20
 143               		.loc 1 64 7 view .LVU33
 144 0052 2D34      		cpi r18,77
 145 0054 3140      		sbci r19,1
 146 0056 00F0      		brlo .L6
  65:main.c        ****     {
  66:main.c        ****         timer_leds_two = timer_counter;
 147               		.loc 1 66 9 is_stmt 1 view .LVU34
 148               		.loc 1 66 24 is_stmt 0 view .LVU35
 149 0058 9093 0000 		sts timer_leds_two.1187+1,r25
 150 005c 8093 0000 		sts timer_leds_two.1187,r24
  67:main.c        ****         light_two = light_two ? 0 : 1;
 151               		.loc 1 67 9 is_stmt 1 view .LVU36
 152               		.loc 1 67 35 is_stmt 0 view .LVU37
 153 0060 21E0      		ldi r18,lo8(1)
 154 0062 30E0      		ldi r19,0
 155 0064 4091 0000 		lds r20,light_two.1190
 156 0068 5091 0000 		lds r21,light_two.1190+1
 157 006c 452B      		or r20,r21
 158 006e 01F0      		breq .L7
 159 0070 30E0      		ldi r19,0
 160 0072 20E0      		ldi r18,0
 161               	.L7:
 162               		.loc 1 67 19 view .LVU38
 163 0074 3093 0000 		sts light_two.1190+1,r19
 164 0078 2093 0000 		sts light_two.1190,r18
 165               	.L6:
  68:main.c        ****     }
  69:main.c        **** 
  70:main.c        **** 
  71:main.c        **** 
  72:main.c        ****     if( timer_counter - timer_leds_three >= 100 )
 166               		.loc 1 72 5 is_stmt 1 view .LVU39
 167               		.loc 1 72 23 is_stmt 0 view .LVU40
 168 007c 2091 0000 		lds r18,timer_leds_three.1188
 169 0080 3091 0000 		lds r19,timer_leds_three.1188+1
 170 0084 AC01      		movw r20,r24
 171 0086 421B      		sub r20,r18
 172 0088 530B      		sbc r21,r19
 173               		.loc 1 72 7 view .LVU41
 174 008a 4436      		cpi r20,100
 175 008c 5105      		cpc r21,__zero_reg__
 176 008e 00F0      		brlo .L8
  73:main.c        ****     {
  74:main.c        ****         timer_leds_three = timer_counter;
 177               		.loc 1 74 9 is_stmt 1 view .LVU42
 178               		.loc 1 74 26 is_stmt 0 view .LVU43
 179 0090 9093 0000 		sts timer_leds_three.1188+1,r25
 180 0094 8093 0000 		sts timer_leds_three.1188,r24
  75:main.c        ****         light_three = light_three ? 0 : 1;
 181               		.loc 1 75 9 is_stmt 1 view .LVU44
 182               		.loc 1 75 39 is_stmt 0 view .LVU45
 183 0098 81E0      		ldi r24,lo8(1)
 184 009a 90E0      		ldi r25,0
 185 009c 2091 0000 		lds r18,light_three.1191
 186 00a0 3091 0000 		lds r19,light_three.1191+1
 187 00a4 232B      		or r18,r19
 188 00a6 01F0      		breq .L9
 189 00a8 90E0      		ldi r25,0
 190 00aa 80E0      		ldi r24,0
 191               	.L9:
 192               		.loc 1 75 21 view .LVU46
 193 00ac 9093 0000 		sts light_three.1191+1,r25
 194 00b0 8093 0000 		sts light_three.1191,r24
 195               	.L8:
  76:main.c        ****     }
  77:main.c        **** 
  78:main.c        **** 
  79:main.c        ****     ind_led_set(LED_1, light_one);
 196               		.loc 1 79 5 is_stmt 1 view .LVU47
 197 00b4 6091 0000 		lds r22,light_one.1189
 198 00b8 86E0      		ldi r24,lo8(6)
 199 00ba 0E94 0000 		call ind_led_set
 200               	.LVL0:
  80:main.c        ****     ind_led_set(LED_2, light_two);
 201               		.loc 1 80 5 view .LVU48
 202 00be 6091 0000 		lds r22,light_two.1190
 203 00c2 84E0      		ldi r24,lo8(4)
 204 00c4 0E94 0000 		call ind_led_set
 205               	.LVL1:
  81:main.c        ****     ind_led_set(LED_3, light_three);
 206               		.loc 1 81 5 view .LVU49
 207 00c8 6091 0000 		lds r22,light_three.1191
 208 00cc 85E0      		ldi r24,lo8(5)
 209 00ce 0E94 0000 		call ind_led_set
 210               	.LVL2:
 211               	/* epilogue start */
  82:main.c        **** }
 212               		.loc 1 82 1 is_stmt 0 view .LVU50
 213 00d2 0895      		ret
 214               		.cfi_endproc
 215               	.LFE8:
 217               		.section	.rodata
 218               	.LC0:
 219 0000 4641 554C 		.string	"FAUL"
 219      00
 220 0005 4845 4154 		.string	"HEAT"
 220      00
 221 000a 434F 4C44 		.string	"COLD"
 221      00
 222 000f 3132 3334 		.string	"1234"
 222      00
 223 0014 2048 4920 		.string	" HI "
 223      00
 224 0019 204C 4F20 		.string	" LO "
 224      00
 225               		.section	.text.startup.main,"ax",@progbits
 226               	.global	main
 228               	main:
 229               	.LFB9:
  83:main.c        **** 
  84:main.c        **** 
  85:main.c        **** int main( void )
  86:main.c        **** {
 230               		.loc 1 86 1 is_stmt 1 view -0
 231               		.cfi_startproc
 232 0000 CDB7      		in r28,__SP_L__
 233 0002 DEB7      		in r29,__SP_H__
 234               	.LCFI1:
 235               		.cfi_def_cfa_register 28
 236 0004 A297      		sbiw r28,34
 237               	.LCFI2:
 238               		.cfi_def_cfa_offset 36
 239 0006 0FB6      		in __tmp_reg__,__SREG__
 240 0008 F894      		cli
 241 000a DEBF      		out __SP_H__,r29
 242 000c 0FBE      		out __SREG__,__tmp_reg__
 243 000e CDBF      		out __SP_L__,r28
 244               	/* prologue: function */
 245               	/* frame size = 34 */
 246               	/* stack size = 34 */
 247               	.L__stack_usage = 34
  87:main.c        ****     uint16_t  timer = 0;
 248               		.loc 1 87 5 view .LVU52
 249               	.LVL3:
  88:main.c        ****     char message[6][5] = {"FAUL", "HEAT", "COLD", "1234", " HI ", " LO "};
 250               		.loc 1 88 5 view .LVU53
 251               		.loc 1 88 10 is_stmt 0 view .LVU54
 252 0010 8EE1      		ldi r24,lo8(30)
 253 0012 E0E0      		ldi r30,lo8(.LC0)
 254 0014 F0E0      		ldi r31,hi8(.LC0)
 255 0016 DE01      		movw r26,r28
 256 0018 1196      		adiw r26,1
 257               		0:
 258 001a 0190      		ld r0,Z+
 259 001c 0D92      		st X+,r0
 260 001e 8A95      		dec r24
 261 0020 01F4      		brne 0b
  89:main.c        ****     char word[4];
 262               		.loc 1 89 5 is_stmt 1 view .LVU55
  90:main.c        ****     int8_t  j = 0;
 263               		.loc 1 90 5 view .LVU56
 264               	.LVL4:
  91:main.c        **** 
  92:main.c        **** 
  93:main.c        ****     DDRB = (1 << 1) | (1 << 0);
 265               		.loc 1 93 5 view .LVU57
 266               		.loc 1 93 10 is_stmt 0 view .LVU58
 267 0022 83E0      		ldi r24,lo8(3)
 268 0024 84B9      		out 0x4,r24
  94:main.c        **** 
  95:main.c        **** 
  96:main.c        ****     ind_init();
 269               		.loc 1 96 5 is_stmt 1 view .LVU59
 270 0026 0E94 0000 		call ind_init
 271               	.LVL5:
  97:main.c        ****     tim1_init();
 272               		.loc 1 97 5 view .LVU60
 273 002a 0E94 0000 		call tim1_init
 274               	.LVL6:
  98:main.c        **** 
  99:main.c        ****     sei();
 275               		.loc 1 99 5 view .LVU61
 276               	/* #APP */
 277               	 ;  99 "main.c" 1
 278 002e 7894      		sei
 279               	 ;  0 "" 2
  90:main.c        **** 
 280               		.loc 1 90 13 is_stmt 0 view .LVU62
 281               	/* #NOAPP */
 282 0030 10E0      		ldi r17,0
  87:main.c        ****     char message[6][5] = {"FAUL", "HEAT", "COLD", "1234", " HI ", " LO "};
 283               		.loc 1 87 15 view .LVU63
 284 0032 90E0      		ldi r25,0
 285 0034 80E0      		ldi r24,0
 286               	.LBB2:
 100:main.c        **** 
 101:main.c        ****     while( 1 )
 102:main.c        ****     {
 103:main.c        ****             for( int8_t i = 0; i < 4; i++ )
 104:main.c        ****             {
 105:main.c        ****                 word[i] = message[j][i];
 287               		.loc 1 105 37 view .LVU64
 288 0036 05E0      		ldi r16,lo8(5)
 289               	.LVL7:
 290               	.L21:
 291               		.loc 1 105 37 view .LVU65
 292               	.LBE2:
 101:main.c        ****     {
 293               		.loc 1 101 5 is_stmt 1 view .LVU66
 103:main.c        ****             {
 294               		.loc 1 103 13 view .LVU67
 295               	.LBB3:
 103:main.c        ****             {
 296               		.loc 1 103 18 view .LVU68
 297               		.loc 1 105 17 view .LVU69
 298               		.loc 1 105 37 is_stmt 0 view .LVU70
 299 0038 1003      		mulsu r17,r16
 300 003a F001      		movw r30,r0
 301 003c 1124      		clr __zero_reg__
 302 003e 21E0      		ldi r18,lo8(1)
 303 0040 30E0      		ldi r19,0
 304 0042 2C0F      		add r18,r28
 305 0044 3D1F      		adc r19,r29
 306 0046 E20F      		add r30,r18
 307 0048 F31F      		adc r31,r19
 308               		.loc 1 105 25 view .LVU71
 309 004a 2081      		ld r18,Z
 310 004c 2F8F      		std Y+31,r18
 311               	.LVL8:
 312               		.loc 1 105 17 is_stmt 1 view .LVU72
 313               		.loc 1 105 25 is_stmt 0 view .LVU73
 314 004e 2181      		ldd r18,Z+1
 315 0050 28A3      		std Y+32,r18
 316               	.LVL9:
 317               		.loc 1 105 17 is_stmt 1 view .LVU74
 318               		.loc 1 105 25 is_stmt 0 view .LVU75
 319 0052 2281      		ldd r18,Z+2
 320 0054 29A3      		std Y+33,r18
 321               	.LVL10:
 322               		.loc 1 105 17 is_stmt 1 view .LVU76
 323               		.loc 1 105 25 is_stmt 0 view .LVU77
 324 0056 2381      		ldd r18,Z+3
 325 0058 2AA3      		std Y+34,r18
 326               	.LVL11:
 327               		.loc 1 105 25 view .LVU78
 328               	.LBE3:
 106:main.c        ****             }
 107:main.c        **** 
 108:main.c        **** 
 109:main.c        ****             if( timer_counter - timer >= 2000 )
 329               		.loc 1 109 13 is_stmt 1 view .LVU79
 330               		.loc 1 109 31 is_stmt 0 view .LVU80
 331 005a E090 0000 		lds r14,timer_counter
 332 005e F090 0000 		lds r15,timer_counter+1
 333 0062 9701      		movw r18,r14
 334 0064 281B      		sub r18,r24
 335 0066 390B      		sbc r19,r25
 336               		.loc 1 109 15 view .LVU81
 337 0068 203D      		cpi r18,-48
 338 006a 3740      		sbci r19,7
 339 006c 00F0      		brlo .L22
 340 006e 1F5F      		subi r17,lo8(-(1))
 110:main.c        ****             {
 111:main.c        **** 
 112:main.c        ****                 timer = timer_counter;
 341               		.loc 1 112 17 is_stmt 1 view .LVU82
 342               	.LVL12:
 113:main.c        **** 
 114:main.c        ****                 j += 1;
 343               		.loc 1 114 17 view .LVU83
 115:main.c        **** 
 116:main.c        ****                 if( j > 6 )
 344               		.loc 1 116 17 view .LVU84
 345               		.loc 1 116 19 is_stmt 0 view .LVU85
 346 0070 1730      		cpi r17,lo8(7)
 347 0072 00F4      		brsh .L23
 348               	.LVL13:
 349               	.L20:
 117:main.c        ****                 {
 118:main.c        ****                     j = 0;
 119:main.c        ****                 }
 120:main.c        ****             }
 121:main.c        **** 
 122:main.c        ****             ind_print_string(word);
 350               		.loc 1 122 13 is_stmt 1 view .LVU86
 351 0074 CE01      		movw r24,r28
 352 0076 4F96      		adiw r24,31
 353 0078 0E94 0000 		call ind_print_string
 354               	.LVL14:
 123:main.c        ****             led_timer();
 355               		.loc 1 123 13 view .LVU87
 356 007c 0E94 0000 		call led_timer
 357               	.LVL15:
 103:main.c        ****             {
 358               		.loc 1 103 13 is_stmt 0 view .LVU88
 359 0080 C701      		movw r24,r14
 360 0082 00C0      		rjmp .L21
 361               	.LVL16:
 362               	.L22:
 103:main.c        ****             {
 363               		.loc 1 103 13 view .LVU89
 364 0084 7C01      		movw r14,r24
 365 0086 00C0      		rjmp .L20
 366               	.LVL17:
 367               	.L23:
 118:main.c        ****                 }
 368               		.loc 1 118 23 view .LVU90
 369 0088 10E0      		ldi r17,0
 370 008a 00C0      		rjmp .L20
 371               		.cfi_endproc
 372               	.LFE9:
 374               		.section	.bss.light_three.1191,"aw",@nobits
 377               	light_three.1191:
 378 0000 0000      		.zero	2
 379               		.section	.bss.timer_leds_three.1188,"aw",@nobits
 382               	timer_leds_three.1188:
 383 0000 0000      		.zero	2
 384               		.section	.bss.light_two.1190,"aw",@nobits
 387               	light_two.1190:
 388 0000 0000      		.zero	2
 389               		.section	.bss.timer_leds_two.1187,"aw",@nobits
 392               	timer_leds_two.1187:
 393 0000 0000      		.zero	2
 394               		.section	.bss.light_one.1189,"aw",@nobits
 397               	light_one.1189:
 398 0000 0000      		.zero	2
 399               		.section	.bss.timer_leds_one.1186,"aw",@nobits
 402               	timer_leds_one.1186:
 403 0000 0000      		.zero	2
 404               		.section	.bss.timer_counter,"aw",@nobits
 407               	timer_counter:
 408 0000 0000      		.zero	2
 409               		.text
 410               	.Letext0:
 411               		.file 2 "c:\\bin\\avr-gcc-8.3.0-x64-mingw\\lib\\gcc\\avr\\8.3.0\\include\\stdint-gcc.h"
 412               		.file 3 "./drivers/indicator.h"
DEFINED SYMBOLS
                            *ABS*:0000000000000000 main.c
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:2      *ABS*:000000000000003e __SP_H__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:3      *ABS*:000000000000003d __SP_L__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:4      *ABS*:000000000000003f __SREG__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:5      *ABS*:0000000000000000 __tmp_reg__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:6      *ABS*:0000000000000001 __zero_reg__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:13     .text.__vector_11:0000000000000000 __vector_11
                            *ABS*:0000000000000002 __gcc_isr.n_pushed.001
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:407    .bss.timer_counter:0000000000000000 timer_counter
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:46     .text.tim1_init:0000000000000000 tim1_init
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:88     .text.led_timer:0000000000000000 led_timer
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:402    .bss.timer_leds_one.1186:0000000000000000 timer_leds_one.1186
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:397    .bss.light_one.1189:0000000000000000 light_one.1189
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:392    .bss.timer_leds_two.1187:0000000000000000 timer_leds_two.1187
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:387    .bss.light_two.1190:0000000000000000 light_two.1190
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:382    .bss.timer_leds_three.1188:0000000000000000 timer_leds_three.1188
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:377    .bss.light_three.1191:0000000000000000 light_three.1191
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccReNjD5.s:228    .text.startup.main:0000000000000000 main

UNDEFINED SYMBOLS
ind_led_set
ind_init
ind_print_string
__do_copy_data
__do_clear_bss
