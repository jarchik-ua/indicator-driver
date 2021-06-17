   1               		.file	"indicator.c"
   2               	__SP_H__ = 0x3e
   3               	__SP_L__ = 0x3d
   4               	__SREG__ = 0x3f
   5               	__tmp_reg__ = 0
   6               	__zero_reg__ = 1
   7               		.text
   8               	.Ltext0:
   9               		.cfi_sections	.debug_frame
  10               		.section	.text.clock_signal,"ax",@progbits
  12               	clock_signal:
  13               	.LFB4:
  14               		.file 1 "drivers/indicator.c"
   1:drivers/indicator.c **** 
   2:drivers/indicator.c **** #include <inttypes.h>
   3:drivers/indicator.c **** #include <avr/io.h>
   4:drivers/indicator.c **** #include <avr/interrupt.h>
   5:drivers/indicator.c **** 
   6:drivers/indicator.c **** #include "indicator.h"
   7:drivers/indicator.c **** 
   8:drivers/indicator.c **** 
   9:drivers/indicator.c **** #define IND_PORT                    PORTD
  10:drivers/indicator.c **** 
  11:drivers/indicator.c **** #define CLK                         PD2  // clock
  12:drivers/indicator.c **** #define DS                          PD3  // data
  13:drivers/indicator.c **** #define E                           PD4  // Enter
  14:drivers/indicator.c **** 
  15:drivers/indicator.c **** 
  16:drivers/indicator.c **** 
  17:drivers/indicator.c **** static const uint8_t ind_ascii_table[/* 65 */] =
  18:drivers/indicator.c **** {
  19:drivers/indicator.c ****         0xff /*   */, 0x79 /* ! */, 0xdd /* " */, 0x9d /* # */,
  20:drivers/indicator.c ****         0x93 /* $ */, 0xad /* % */, 0xe3 /* & */, 0xfd /* ' */,
  21:drivers/indicator.c ****         0xc6 /* ( */, 0xf0 /* ) */, 0x9c /* * */, 0xb9 /* + */,
  22:drivers/indicator.c ****         0x7f /* , */, 0xbf /* - */, 0x7f /* . */, 0xad /* / */,
  23:drivers/indicator.c ****         0xc0 /* 0 */, 0xf9 /* 1 */, 0xa4 /* 2 */, 0xb0 /* 3 */,
  24:drivers/indicator.c ****         0x99 /* 4 */, 0x92 /* 5 */, 0x82 /* 6 */, 0xf8 /* 7 */,
  25:drivers/indicator.c ****         0x80 /* 8 */, 0x90 /* 9 */,
  26:drivers/indicator.c **** 
  27:drivers/indicator.c ****         0x00 /* : */, 0x00 /* ; */, 0x00 /* < */, 0xb7 /* = */,
  28:drivers/indicator.c ****         0x00 /* > */, 0x3c /* ? */, 0x30 /* @ */,
  29:drivers/indicator.c **** 
  30:drivers/indicator.c ****         0x88 /* A */, 0x83 /* B */, 0xc6 /* C */, 0xa1 /* d */,
  31:drivers/indicator.c ****         0x86 /* E */, 0x8e /* F */, 0xc3 /* G */, 0x89 /* H */,
  32:drivers/indicator.c ****         0xcf /* I */, 0xe1 /* J */, 0x8a /* K */, 0xc7 /* L */,
  33:drivers/indicator.c ****         0x8d /* M */, 0xab /* N */, 0xc0 /* O */, 0x8c /* P */,
  34:drivers/indicator.c ****         0x98 /* Q */, 0xaf /* R */, 0x92 /* S */, 0x87 /* T */,
  35:drivers/indicator.c ****         0xc1 /* U */, 0xe1 /* V */, 0xff /* W */, 0xb6 /* X */,
  36:drivers/indicator.c ****         0x91 /* Y */, 0xb7 /* Z */,
  37:drivers/indicator.c **** 
  38:drivers/indicator.c ****         0xa7 /* [ */, 0x9b /* \ */, 0xb3 /* ] */, 0xfe /* ^ */,
  39:drivers/indicator.c ****         0xf7 /* _ */, 0x9f /* ` */,
  40:drivers/indicator.c **** };
  41:drivers/indicator.c **** 
  42:drivers/indicator.c **** static uint8_t  indicator_data[4];
  43:drivers/indicator.c **** static uint8_t  ind_led_state;
  44:drivers/indicator.c **** 
  45:drivers/indicator.c **** 
  46:drivers/indicator.c **** 
  47:drivers/indicator.c **** 
  48:drivers/indicator.c **** void
  49:drivers/indicator.c **** ind_led_set( uint8_t led, int8_t state )
  50:drivers/indicator.c **** {
  51:drivers/indicator.c ****     if ( state )
  52:drivers/indicator.c ****         ind_led_state |= (1 << led);
  53:drivers/indicator.c ****     else
  54:drivers/indicator.c ****         ind_led_state &= ~(1 << led);
  55:drivers/indicator.c **** }
  56:drivers/indicator.c **** 
  57:drivers/indicator.c **** 
  58:drivers/indicator.c **** void
  59:drivers/indicator.c **** ind_print_string( char * number )
  60:drivers/indicator.c **** {
  61:drivers/indicator.c **** 
  62:drivers/indicator.c ****     for ( int8_t i = 0; i < 4; i++ )
  63:drivers/indicator.c ****     {
  64:drivers/indicator.c ****         indicator_data[i] = ind_ascii_table[ number [i] - 32];
  65:drivers/indicator.c ****     }
  66:drivers/indicator.c **** 
  67:drivers/indicator.c **** }
  68:drivers/indicator.c **** 
  69:drivers/indicator.c **** 
  70:drivers/indicator.c **** static int8_t
  71:drivers/indicator.c **** ind_number_step_get( int16_t x )
  72:drivers/indicator.c **** {
  73:drivers/indicator.c ****     int8_t  step = 3;
  74:drivers/indicator.c **** 
  75:drivers/indicator.c ****     if( x < 1000 )
  76:drivers/indicator.c ****         step = 3;
  77:drivers/indicator.c ****     if( x < 100 )
  78:drivers/indicator.c ****         step = 2;
  79:drivers/indicator.c ****     if( x < 10 )
  80:drivers/indicator.c ****         step = 1;
  81:drivers/indicator.c **** 
  82:drivers/indicator.c ****     return step;
  83:drivers/indicator.c **** }
  84:drivers/indicator.c **** 
  85:drivers/indicator.c **** 
  86:drivers/indicator.c **** void
  87:drivers/indicator.c **** ind_print_dec( uint16_t number )
  88:drivers/indicator.c **** {
  89:drivers/indicator.c ****     uint8_t  string[4];
  90:drivers/indicator.c ****     uint8_t step;
  91:drivers/indicator.c **** 
  92:drivers/indicator.c ****     string[0] = number / 1000;
  93:drivers/indicator.c ****     string[1] = number % 1000 / 100;
  94:drivers/indicator.c ****     string[2] = number % 100 / 10;
  95:drivers/indicator.c ****     string[3] = number % 10;
  96:drivers/indicator.c **** 
  97:drivers/indicator.c ****     step = ind_number_step_get(number);
  98:drivers/indicator.c ****     step = 4 - step;
  99:drivers/indicator.c **** 
 100:drivers/indicator.c **** 
 101:drivers/indicator.c ****     for( int8_t i = 0; i < 4; i++ )
 102:drivers/indicator.c ****     {
 103:drivers/indicator.c ****         if( i < step )
 104:drivers/indicator.c ****         {
 105:drivers/indicator.c ****             string[i] = ind_ascii_table[0];
 106:drivers/indicator.c ****         }
 107:drivers/indicator.c ****         else
 108:drivers/indicator.c ****         {
 109:drivers/indicator.c ****             string[i] = ind_ascii_table[string[i]+16];
 110:drivers/indicator.c ****         }
 111:drivers/indicator.c **** 
 112:drivers/indicator.c **** 
 113:drivers/indicator.c ****  //       string[i] += 48;
 114:drivers/indicator.c ****     }
 115:drivers/indicator.c **** 
 116:drivers/indicator.c **** 
 117:drivers/indicator.c ****     for( int8_t i = 0; i < 4; i++ )
 118:drivers/indicator.c ****     {
 119:drivers/indicator.c ****         indicator_data[i] = string[i];
 120:drivers/indicator.c ****     }
 121:drivers/indicator.c **** }
 122:drivers/indicator.c **** 
 123:drivers/indicator.c **** 
 124:drivers/indicator.c **** static void
 125:drivers/indicator.c **** clock_signal(void)
 126:drivers/indicator.c **** {
  15               		.loc 1 126 1 view -0
  16               		.cfi_startproc
  17               	/* prologue: function */
  18               	/* frame size = 0 */
  19               	/* stack size = 0 */
  20               	.L__stack_usage = 0
 127:drivers/indicator.c ****    IND_PORT &= ~(1<<CLK);
  21               		.loc 1 127 4 view .LVU1
  22               		.loc 1 127 13 is_stmt 0 view .LVU2
  23 0000 5A98      		cbi 0xb,2
 128:drivers/indicator.c ****    __asm volatile("nop");
  24               		.loc 1 128 4 is_stmt 1 view .LVU3
  25               	/* #APP */
  26               	 ;  128 "drivers/indicator.c" 1
  27 0002 0000      		nop
  28               	 ;  0 "" 2
 129:drivers/indicator.c ****    __asm volatile("nop");
  29               		.loc 1 129 4 view .LVU4
  30               	 ;  129 "drivers/indicator.c" 1
  31 0004 0000      		nop
  32               	 ;  0 "" 2
 130:drivers/indicator.c ****    __asm volatile("nop");
  33               		.loc 1 130 4 view .LVU5
  34               	 ;  130 "drivers/indicator.c" 1
  35 0006 0000      		nop
  36               	 ;  0 "" 2
 131:drivers/indicator.c ****    __asm volatile("nop");
  37               		.loc 1 131 4 view .LVU6
  38               	 ;  131 "drivers/indicator.c" 1
  39 0008 0000      		nop
  40               	 ;  0 "" 2
 132:drivers/indicator.c ****    IND_PORT |= (1<<CLK);
  41               		.loc 1 132 4 view .LVU7
  42               		.loc 1 132 13 is_stmt 0 view .LVU8
  43               	/* #NOAPP */
  44 000a 5A9A      		sbi 0xb,2
  45               	/* epilogue start */
 133:drivers/indicator.c **** }
  46               		.loc 1 133 1 view .LVU9
  47 000c 0895      		ret
  48               		.cfi_endproc
  49               	.LFE4:
  51               		.section	.text.ind_led_set,"ax",@progbits
  52               	.global	ind_led_set
  54               	ind_led_set:
  55               	.LVL0:
  56               	.LFB0:
  50:drivers/indicator.c ****     if ( state )
  57               		.loc 1 50 1 is_stmt 1 view -0
  58               		.cfi_startproc
  59               	/* prologue: function */
  60               	/* frame size = 0 */
  61               	/* stack size = 0 */
  62               	.L__stack_usage = 0
  51:drivers/indicator.c ****         ind_led_state |= (1 << led);
  63               		.loc 1 51 5 view .LVU11
  64 0000 21E0      		ldi r18,lo8(1)
  65 0002 30E0      		ldi r19,0
  66 0004 A901      		movw r20,r18
  67 0006 00C0      		rjmp 2f
  68               		1:
  69 0008 440F      		lsl r20
  70 000a 551F      		rol r21
  71               		2:
  72 000c 8A95      		dec r24
  73 000e 02F4      		brpl 1b
  74 0010 CA01      		movw r24,r20
  75               	.LVL1:
  51:drivers/indicator.c ****         ind_led_state |= (1 << led);
  76               		.loc 1 51 5 is_stmt 0 view .LVU12
  77 0012 2091 0000 		lds r18,ind_led_state
  51:drivers/indicator.c ****         ind_led_state |= (1 << led);
  78               		.loc 1 51 8 view .LVU13
  79 0016 6623      		tst r22
  80 0018 01F0      		breq .L3
  52:drivers/indicator.c ****     else
  81               		.loc 1 52 9 is_stmt 1 view .LVU14
  52:drivers/indicator.c ****     else
  82               		.loc 1 52 23 is_stmt 0 view .LVU15
  83 001a 822B      		or r24,r18
  84               	.L5:
  54:drivers/indicator.c **** }
  85               		.loc 1 54 23 view .LVU16
  86 001c 8093 0000 		sts ind_led_state,r24
  87               	/* epilogue start */
  55:drivers/indicator.c **** 
  88               		.loc 1 55 1 view .LVU17
  89 0020 0895      		ret
  90               	.L3:
  54:drivers/indicator.c **** }
  91               		.loc 1 54 9 is_stmt 1 view .LVU18
  54:drivers/indicator.c **** }
  92               		.loc 1 54 23 is_stmt 0 view .LVU19
  93 0022 8095      		com r24
  94 0024 8223      		and r24,r18
  95 0026 00C0      		rjmp .L5
  96               		.cfi_endproc
  97               	.LFE0:
  99               		.section	.text.ind_print_string,"ax",@progbits
 100               	.global	ind_print_string
 102               	ind_print_string:
 103               	.LVL2:
 104               	.LFB1:
  60:drivers/indicator.c **** 
 105               		.loc 1 60 1 is_stmt 1 view -0
 106               		.cfi_startproc
  60:drivers/indicator.c **** 
 107               		.loc 1 60 1 is_stmt 0 view .LVU21
 108 0000 CF93      		push r28
 109               	.LCFI0:
 110               		.cfi_def_cfa_offset 3
 111               		.cfi_offset 28, -2
 112 0002 DF93      		push r29
 113               	.LCFI1:
 114               		.cfi_def_cfa_offset 4
 115               		.cfi_offset 29, -3
 116               	/* prologue: function */
 117               	/* frame size = 0 */
 118               	/* stack size = 2 */
 119               	.L__stack_usage = 2
  62:drivers/indicator.c ****     {
 120               		.loc 1 62 5 is_stmt 1 view .LVU22
 121               	.LBB2:
  62:drivers/indicator.c ****     {
 122               		.loc 1 62 11 view .LVU23
 123               	.LVL3:
  62:drivers/indicator.c ****     {
 124               		.loc 1 62 11 is_stmt 0 view .LVU24
 125 0004 A0E0      		ldi r26,lo8(indicator_data)
 126 0006 B0E0      		ldi r27,hi8(indicator_data)
 127 0008 9C01      		movw r18,r24
 128 000a 2C5F      		subi r18,-4
 129 000c 3F4F      		sbci r19,-1
 130               	.LVL4:
 131               	.L7:
  64:drivers/indicator.c ****     }
 132               		.loc 1 64 9 is_stmt 1 discriminator 3 view .LVU25
  64:drivers/indicator.c ****     }
 133               		.loc 1 64 53 is_stmt 0 discriminator 3 view .LVU26
 134 000e EC01      		movw r28,r24
 135 0010 E991      		ld r30,Y+
 136 0012 CE01      		movw r24,r28
 137               	.LVL5:
  64:drivers/indicator.c ****     }
 138               		.loc 1 64 53 discriminator 3 view .LVU27
 139 0014 F0E0      		ldi r31,0
  64:drivers/indicator.c ****     }
 140               		.loc 1 64 44 discriminator 3 view .LVU28
 141 0016 E050      		subi r30,lo8(-(ind_ascii_table-32))
 142 0018 F040      		sbci r31,hi8(-(ind_ascii_table-32))
  64:drivers/indicator.c ****     }
 143               		.loc 1 64 27 discriminator 3 view .LVU29
 144 001a 4081      		ld r20,Z
 145 001c 4D93      		st X+,r20
 146               	.LVL6:
  62:drivers/indicator.c ****     {
 147               		.loc 1 62 5 discriminator 3 view .LVU30
 148 001e C217      		cp r28,r18
 149 0020 D307      		cpc r29,r19
 150 0022 01F4      		brne .L7
 151               	/* epilogue start */
 152               	.LBE2:
  67:drivers/indicator.c **** 
 153               		.loc 1 67 1 view .LVU31
 154 0024 DF91      		pop r29
 155 0026 CF91      		pop r28
 156 0028 0895      		ret
 157               		.cfi_endproc
 158               	.LFE1:
 160               		.section	.text.ind_print_dec,"ax",@progbits
 161               	.global	ind_print_dec
 163               	ind_print_dec:
 164               	.LVL7:
 165               	.LFB3:
  88:drivers/indicator.c ****     uint8_t  string[4];
 166               		.loc 1 88 1 is_stmt 1 view -0
 167               		.cfi_startproc
  88:drivers/indicator.c ****     uint8_t  string[4];
 168               		.loc 1 88 1 is_stmt 0 view .LVU33
 169 0000 A4E0      		ldi r26,lo8(4)
 170 0002 B0E0      		ldi r27,0
 171 0004 E0E0      		ldi r30,lo8(gs(1f))
 172 0006 F0E0      		ldi r31,hi8(gs(1f))
 173 0008 0C94 0000 		jmp __prologue_saves__+((18 - 2) * 2)
 174               	1:
 175               	.LCFI2:
 176               		.cfi_offset 28, -2
 177               		.cfi_offset 29, -3
 178               		.cfi_def_cfa 28, 8
 179               	/* prologue: function */
 180               	/* frame size = 4 */
 181               	/* stack size = 6 */
 182               	.L__stack_usage = 6
 183 000c 9C01      		movw r18,r24
  89:drivers/indicator.c ****     uint8_t step;
 184               		.loc 1 89 5 is_stmt 1 view .LVU34
  90:drivers/indicator.c **** 
 185               		.loc 1 90 5 view .LVU35
  92:drivers/indicator.c ****     string[1] = number % 1000 / 100;
 186               		.loc 1 92 5 view .LVU36
  92:drivers/indicator.c ****     string[1] = number % 1000 / 100;
 187               		.loc 1 92 24 is_stmt 0 view .LVU37
 188 000e 68EE      		ldi r22,lo8(-24)
 189 0010 73E0      		ldi r23,lo8(3)
 190 0012 0E94 0000 		call __udivmodhi4
 191               	.LVL8:
  92:drivers/indicator.c ****     string[1] = number % 1000 / 100;
 192               		.loc 1 92 15 view .LVU38
 193 0016 6983      		std Y+1,r22
  93:drivers/indicator.c ****     string[2] = number % 100 / 10;
 194               		.loc 1 93 5 is_stmt 1 view .LVU39
  93:drivers/indicator.c ****     string[2] = number % 100 / 10;
 195               		.loc 1 93 31 is_stmt 0 view .LVU40
 196 0018 E4E6      		ldi r30,lo8(100)
 197 001a F0E0      		ldi r31,0
 198 001c BF01      		movw r22,r30
 199 001e 0E94 0000 		call __udivmodhi4
  93:drivers/indicator.c ****     string[2] = number % 100 / 10;
 200               		.loc 1 93 15 view .LVU41
 201 0022 6A83      		std Y+2,r22
  94:drivers/indicator.c ****     string[3] = number % 10;
 202               		.loc 1 94 5 is_stmt 1 view .LVU42
  94:drivers/indicator.c ****     string[3] = number % 10;
 203               		.loc 1 94 24 is_stmt 0 view .LVU43
 204 0024 C901      		movw r24,r18
 205 0026 BF01      		movw r22,r30
 206 0028 0E94 0000 		call __udivmodhi4
  94:drivers/indicator.c ****     string[3] = number % 10;
 207               		.loc 1 94 30 view .LVU44
 208 002c EAE0      		ldi r30,lo8(10)
 209 002e F0E0      		ldi r31,0
 210 0030 BF01      		movw r22,r30
 211 0032 0E94 0000 		call __udivmodhi4
  94:drivers/indicator.c ****     string[3] = number % 10;
 212               		.loc 1 94 15 view .LVU45
 213 0036 6B83      		std Y+3,r22
  95:drivers/indicator.c **** 
 214               		.loc 1 95 5 is_stmt 1 view .LVU46
  95:drivers/indicator.c **** 
 215               		.loc 1 95 24 is_stmt 0 view .LVU47
 216 0038 C901      		movw r24,r18
 217 003a BF01      		movw r22,r30
 218 003c 0E94 0000 		call __udivmodhi4
  95:drivers/indicator.c **** 
 219               		.loc 1 95 15 view .LVU48
 220 0040 8C83      		std Y+4,r24
  97:drivers/indicator.c ****     step = 4 - step;
 221               		.loc 1 97 5 is_stmt 1 view .LVU49
 222               	.LVL9:
 223               	.LBB7:
 224               	.LBI7:
  71:drivers/indicator.c **** {
 225               		.loc 1 71 1 view .LVU50
 226               	.LBB8:
  73:drivers/indicator.c **** 
 227               		.loc 1 73 5 view .LVU51
  75:drivers/indicator.c ****         step = 3;
 228               		.loc 1 75 5 view .LVU52
  77:drivers/indicator.c ****         step = 2;
 229               		.loc 1 77 5 view .LVU53
  77:drivers/indicator.c ****         step = 2;
 230               		.loc 1 77 7 is_stmt 0 view .LVU54
 231 0042 83E0      		ldi r24,lo8(3)
 232 0044 2436      		cpi r18,100
 233 0046 3105      		cpc r19,__zero_reg__
 234 0048 04F4      		brge .L10
  78:drivers/indicator.c ****     if( x < 10 )
 235               		.loc 1 78 9 is_stmt 1 view .LVU55
 236               	.LVL10:
  79:drivers/indicator.c ****         step = 1;
 237               		.loc 1 79 5 view .LVU56
  80:drivers/indicator.c **** 
 238               		.loc 1 80 14 is_stmt 0 view .LVU57
 239 004a 81E0      		ldi r24,lo8(1)
  79:drivers/indicator.c ****         step = 1;
 240               		.loc 1 79 7 view .LVU58
 241 004c 2A30      		cpi r18,10
 242 004e 3105      		cpc r19,__zero_reg__
 243 0050 04F0      		brlt .L10
  78:drivers/indicator.c ****     if( x < 10 )
 244               		.loc 1 78 14 view .LVU59
 245 0052 82E0      		ldi r24,lo8(2)
 246               	.LVL11:
 247               	.L10:
  82:drivers/indicator.c **** }
 248               		.loc 1 82 5 is_stmt 1 view .LVU60
  82:drivers/indicator.c **** }
 249               		.loc 1 82 5 is_stmt 0 view .LVU61
 250               	.LBE8:
 251               	.LBE7:
  98:drivers/indicator.c **** 
 252               		.loc 1 98 5 is_stmt 1 view .LVU62
  98:drivers/indicator.c **** 
 253               		.loc 1 98 10 is_stmt 0 view .LVU63
 254 0054 24E0      		ldi r18,lo8(4)
 255               	.LVL12:
  98:drivers/indicator.c **** 
 256               		.loc 1 98 10 view .LVU64
 257 0056 281B      		sub r18,r24
 258               	.LVL13:
 101:drivers/indicator.c ****     {
 259               		.loc 1 101 5 is_stmt 1 view .LVU65
 260               	.LBB9:
 101:drivers/indicator.c ****     {
 261               		.loc 1 101 10 view .LVU66
 101:drivers/indicator.c ****     {
 262               		.loc 1 101 10 is_stmt 0 view .LVU67
 263               	.LBE9:
  98:drivers/indicator.c **** 
 264               		.loc 1 98 10 view .LVU68
 265 0058 90E0      		ldi r25,0
 266 005a 80E0      		ldi r24,0
 267               	.LBB10:
 103:drivers/indicator.c ****         {
 268               		.loc 1 103 15 view .LVU69
 269 005c 30E0      		ldi r19,0
 105:drivers/indicator.c ****         }
 270               		.loc 1 105 23 view .LVU70
 271 005e 4FEF      		ldi r20,lo8(-1)
 272               	.LVL14:
 273               	.L13:
 103:drivers/indicator.c ****         {
 274               		.loc 1 103 9 is_stmt 1 view .LVU71
 103:drivers/indicator.c ****         {
 275               		.loc 1 103 11 is_stmt 0 view .LVU72
 276 0060 8217      		cp r24,r18
 277 0062 9307      		cpc r25,r19
 278 0064 04F4      		brge .L11
 105:drivers/indicator.c ****         }
 279               		.loc 1 105 13 is_stmt 1 view .LVU73
 105:drivers/indicator.c ****         }
 280               		.loc 1 105 23 is_stmt 0 view .LVU74
 281 0066 E1E0      		ldi r30,lo8(1)
 282 0068 F0E0      		ldi r31,0
 283 006a EC0F      		add r30,r28
 284 006c FD1F      		adc r31,r29
 285 006e E80F      		add r30,r24
 286 0070 F91F      		adc r31,r25
 287 0072 4083      		st Z,r20
 288               	.L12:
 289               	.LVL15:
 105:drivers/indicator.c ****         }
 290               		.loc 1 105 23 view .LVU75
 291 0074 0196      		adiw r24,1
 292               	.LVL16:
 101:drivers/indicator.c ****     {
 293               		.loc 1 101 5 discriminator 2 view .LVU76
 294 0076 8430      		cpi r24,4
 295 0078 9105      		cpc r25,__zero_reg__
 296 007a 01F4      		brne .L13
 297               	.LVL17:
 101:drivers/indicator.c ****     {
 298               		.loc 1 101 5 discriminator 2 view .LVU77
 299               	.LBE10:
 300               	.LBB11:
 119:drivers/indicator.c ****     }
 301               		.loc 1 119 9 is_stmt 1 view .LVU78
 119:drivers/indicator.c ****     }
 302               		.loc 1 119 27 is_stmt 0 view .LVU79
 303 007c 8981      		ldd r24,Y+1
 304               	.LVL18:
 119:drivers/indicator.c ****     }
 305               		.loc 1 119 27 view .LVU80
 306 007e 8093 0000 		sts indicator_data,r24
 307               	.LVL19:
 119:drivers/indicator.c ****     }
 308               		.loc 1 119 9 is_stmt 1 view .LVU81
 119:drivers/indicator.c ****     }
 309               		.loc 1 119 27 is_stmt 0 view .LVU82
 310 0082 8A81      		ldd r24,Y+2
 311 0084 8093 0000 		sts indicator_data+1,r24
 312               	.LVL20:
 119:drivers/indicator.c ****     }
 313               		.loc 1 119 9 is_stmt 1 view .LVU83
 119:drivers/indicator.c ****     }
 314               		.loc 1 119 27 is_stmt 0 view .LVU84
 315 0088 8B81      		ldd r24,Y+3
 316 008a 8093 0000 		sts indicator_data+2,r24
 317               	.LVL21:
 119:drivers/indicator.c ****     }
 318               		.loc 1 119 9 is_stmt 1 view .LVU85
 119:drivers/indicator.c ****     }
 319               		.loc 1 119 27 is_stmt 0 view .LVU86
 320 008e 8C81      		ldd r24,Y+4
 321 0090 8093 0000 		sts indicator_data+3,r24
 322               	.LVL22:
 323               	/* epilogue start */
 119:drivers/indicator.c ****     }
 324               		.loc 1 119 27 view .LVU87
 325               	.LBE11:
 121:drivers/indicator.c **** 
 326               		.loc 1 121 1 view .LVU88
 327 0094 2496      		adiw r28,4
 328 0096 E2E0      		ldi r30, lo8(2)
 329 0098 0C94 0000 		jmp __epilogue_restores__ + ((18 - 2) * 2)
 330               	.LVL23:
 331               	.L11:
 332               	.LBB12:
 109:drivers/indicator.c ****         }
 333               		.loc 1 109 13 is_stmt 1 view .LVU89
 334 009c A1E0      		ldi r26,lo8(1)
 335 009e B0E0      		ldi r27,0
 336 00a0 AC0F      		add r26,r28
 337 00a2 BD1F      		adc r27,r29
 338 00a4 A80F      		add r26,r24
 339 00a6 B91F      		adc r27,r25
 109:drivers/indicator.c ****         }
 340               		.loc 1 109 47 is_stmt 0 view .LVU90
 341 00a8 EC91      		ld r30,X
 342 00aa F0E0      		ldi r31,0
 109:drivers/indicator.c ****         }
 343               		.loc 1 109 40 view .LVU91
 344 00ac E050      		subi r30,lo8(-(ind_ascii_table))
 345 00ae F040      		sbci r31,hi8(-(ind_ascii_table))
 109:drivers/indicator.c ****         }
 346               		.loc 1 109 23 view .LVU92
 347 00b0 5089      		ldd r21,Z+16
 348 00b2 5C93      		st X,r21
 349 00b4 00C0      		rjmp .L12
 350               	.LBE12:
 351               		.cfi_endproc
 352               	.LFE3:
 354               		.section	.text.ind_init,"ax",@progbits
 355               	.global	ind_init
 357               	ind_init:
 358               	.LFB7:
 134:drivers/indicator.c **** 
 135:drivers/indicator.c **** 
 136:drivers/indicator.c **** static void
 137:drivers/indicator.c **** latch_enable(void)
 138:drivers/indicator.c **** {
 139:drivers/indicator.c ****    IND_PORT |= (1<<E);
 140:drivers/indicator.c ****    __asm volatile("nop");
 141:drivers/indicator.c ****    __asm volatile("nop");
 142:drivers/indicator.c ****    __asm volatile("nop");
 143:drivers/indicator.c ****    __asm volatile("nop");
 144:drivers/indicator.c ****    IND_PORT &= ~(1<<E);
 145:drivers/indicator.c **** }
 146:drivers/indicator.c **** 
 147:drivers/indicator.c **** 
 148:drivers/indicator.c **** static void
 149:drivers/indicator.c **** indicator_data_send( void )
 150:drivers/indicator.c **** {
 151:drivers/indicator.c ****     static int8_t  digit;
 152:drivers/indicator.c ****     uint8_t  control_shift_reg = 0;
 153:drivers/indicator.c **** 
 154:drivers/indicator.c **** 
 155:drivers/indicator.c ****     control_shift_reg = (1 << digit);
 156:drivers/indicator.c ****     control_shift_reg |= ind_led_state;
 157:drivers/indicator.c **** 
 158:drivers/indicator.c ****     control_shift_reg = ~control_shift_reg;
 159:drivers/indicator.c **** 
 160:drivers/indicator.c ****      int8_t i;
 161:drivers/indicator.c ****     // Загрузка данных во втотрой сдвиговый регистр
 162:drivers/indicator.c ****     for( i = 0 ; i < 4 ; i++ )
 163:drivers/indicator.c ****     {
 164:drivers/indicator.c ****       IND_PORT = ( (control_shift_reg << i) & (0x80) ) ? IND_PORT | (1<<DS) : IND_PORT & ~(1<<DS);
 165:drivers/indicator.c ****       clock_signal();
 166:drivers/indicator.c ****     }
 167:drivers/indicator.c **** 
 168:drivers/indicator.c ****     for( i = 4 ; i < 8 ; i++ )
 169:drivers/indicator.c ****     {
 170:drivers/indicator.c ****       IND_PORT = ( (control_shift_reg << i) & (0x80) ) ? IND_PORT | (1<<DS) : IND_PORT & ~(1<<DS);
 171:drivers/indicator.c ****       clock_signal();
 172:drivers/indicator.c ****     }
 173:drivers/indicator.c **** 
 174:drivers/indicator.c **** 
 175:drivers/indicator.c ****     // Загрузка данных в первый сдвиговый регистр
 176:drivers/indicator.c ****     for(  i = 0 ; i < 8 ; i++ )
 177:drivers/indicator.c ****     {
 178:drivers/indicator.c ****       IND_PORT = ( (indicator_data[digit] << i) & (0x80) ) ? IND_PORT | (1<<DS) : IND_PORT & ~(1<<D
 179:drivers/indicator.c ****       clock_signal();
 180:drivers/indicator.c ****     }
 181:drivers/indicator.c **** 
 182:drivers/indicator.c ****     latch_enable(); // Data finally submitted
 183:drivers/indicator.c **** 
 184:drivers/indicator.c **** 
 185:drivers/indicator.c ****     if( ++digit >= 4 )
 186:drivers/indicator.c ****     {
 187:drivers/indicator.c ****         digit = 0;
 188:drivers/indicator.c ****     }
 189:drivers/indicator.c **** }
 190:drivers/indicator.c **** 
 191:drivers/indicator.c **** 
 192:drivers/indicator.c **** void
 193:drivers/indicator.c **** ind_init( void )
 194:drivers/indicator.c **** {
 359               		.loc 1 194 1 is_stmt 1 view -0
 360               		.cfi_startproc
 361               	/* prologue: function */
 362               	/* frame size = 0 */
 363               	/* stack size = 0 */
 364               	.L__stack_usage = 0
 195:drivers/indicator.c ****     DDRD |= (1 << CLK) | (1 << DS) | (1 << E); // output
 365               		.loc 1 195 5 view .LVU94
 366               		.loc 1 195 10 is_stmt 0 view .LVU95
 367 0000 8AB1      		in r24,0xa
 368 0002 8C61      		ori r24,lo8(28)
 369 0004 8AB9      		out 0xa,r24
 196:drivers/indicator.c **** 
 197:drivers/indicator.c ****     // TIM0 Initialization
 198:drivers/indicator.c ****     // Fcpu / 1024 = 15625 HZ
 199:drivers/indicator.c ****     TCCR0B = (1 << CS02) | (0 << CS01) | (0 << CS00);
 370               		.loc 1 199 5 is_stmt 1 view .LVU96
 371               		.loc 1 199 12 is_stmt 0 view .LVU97
 372 0006 84E0      		ldi r24,lo8(4)
 373 0008 85BD      		out 0x25,r24
 200:drivers/indicator.c **** 
 201:drivers/indicator.c ****     TIMSK0 |= ( 1<<0 );
 374               		.loc 1 201 5 is_stmt 1 view .LVU98
 375               		.loc 1 201 12 is_stmt 0 view .LVU99
 376 000a EEE6      		ldi r30,lo8(110)
 377 000c F0E0      		ldi r31,0
 378 000e 8081      		ld r24,Z
 379 0010 8160      		ori r24,lo8(1)
 380 0012 8083      		st Z,r24
 381               	/* epilogue start */
 202:drivers/indicator.c **** }
 382               		.loc 1 202 1 view .LVU100
 383 0014 0895      		ret
 384               		.cfi_endproc
 385               	.LFE7:
 387               		.section	.text.__vector_16,"ax",@progbits
 388               	.global	__vector_16
 390               	__vector_16:
 391               	.LFB8:
 203:drivers/indicator.c **** 
 204:drivers/indicator.c **** 
 205:drivers/indicator.c **** ISR (TIMER0_OVF_vect)
 206:drivers/indicator.c **** {
 392               		.loc 1 206 1 is_stmt 1 view -0
 393               		.cfi_startproc
 394 0000 1F92      		push r1
 395               	.LCFI3:
 396               		.cfi_def_cfa_offset 3
 397               		.cfi_offset 1, -2
 398 0002 0F92      		push r0
 399               	.LCFI4:
 400               		.cfi_def_cfa_offset 4
 401               		.cfi_offset 0, -3
 402 0004 0FB6      		in r0,__SREG__
 403 0006 0F92      		push r0
 404 0008 1124      		clr __zero_reg__
 405 000a 0F93      		push r16
 406               	.LCFI5:
 407               		.cfi_def_cfa_offset 5
 408               		.cfi_offset 16, -4
 409 000c 1F93      		push r17
 410               	.LCFI6:
 411               		.cfi_def_cfa_offset 6
 412               		.cfi_offset 17, -5
 413 000e 2F93      		push r18
 414               	.LCFI7:
 415               		.cfi_def_cfa_offset 7
 416               		.cfi_offset 18, -6
 417 0010 3F93      		push r19
 418               	.LCFI8:
 419               		.cfi_def_cfa_offset 8
 420               		.cfi_offset 19, -7
 421 0012 4F93      		push r20
 422               	.LCFI9:
 423               		.cfi_def_cfa_offset 9
 424               		.cfi_offset 20, -8
 425 0014 5F93      		push r21
 426               	.LCFI10:
 427               		.cfi_def_cfa_offset 10
 428               		.cfi_offset 21, -9
 429 0016 6F93      		push r22
 430               	.LCFI11:
 431               		.cfi_def_cfa_offset 11
 432               		.cfi_offset 22, -10
 433 0018 7F93      		push r23
 434               	.LCFI12:
 435               		.cfi_def_cfa_offset 12
 436               		.cfi_offset 23, -11
 437 001a 8F93      		push r24
 438               	.LCFI13:
 439               		.cfi_def_cfa_offset 13
 440               		.cfi_offset 24, -12
 441 001c 9F93      		push r25
 442               	.LCFI14:
 443               		.cfi_def_cfa_offset 14
 444               		.cfi_offset 25, -13
 445 001e AF93      		push r26
 446               	.LCFI15:
 447               		.cfi_def_cfa_offset 15
 448               		.cfi_offset 26, -14
 449 0020 BF93      		push r27
 450               	.LCFI16:
 451               		.cfi_def_cfa_offset 16
 452               		.cfi_offset 27, -15
 453 0022 CF93      		push r28
 454               	.LCFI17:
 455               		.cfi_def_cfa_offset 17
 456               		.cfi_offset 28, -16
 457 0024 DF93      		push r29
 458               	.LCFI18:
 459               		.cfi_def_cfa_offset 18
 460               		.cfi_offset 29, -17
 461 0026 EF93      		push r30
 462               	.LCFI19:
 463               		.cfi_def_cfa_offset 19
 464               		.cfi_offset 30, -18
 465 0028 FF93      		push r31
 466               	.LCFI20:
 467               		.cfi_def_cfa_offset 20
 468               		.cfi_offset 31, -19
 469               	/* prologue: Signal */
 470               	/* frame size = 0 */
 471               	/* stack size = 19 */
 472               	.L__stack_usage = 19
 207:drivers/indicator.c ****     indicator_data_send();
 473               		.loc 1 207 5 view .LVU102
 474               	.LBB17:
 475               	.LBI17:
 149:drivers/indicator.c **** {
 476               		.loc 1 149 1 view .LVU103
 477               	.LBB18:
 151:drivers/indicator.c ****     uint8_t  control_shift_reg = 0;
 478               		.loc 1 151 5 view .LVU104
 152:drivers/indicator.c **** 
 479               		.loc 1 152 5 view .LVU105
 480               	.LVL24:
 155:drivers/indicator.c ****     control_shift_reg |= ind_led_state;
 481               		.loc 1 155 5 view .LVU106
 155:drivers/indicator.c ****     control_shift_reg |= ind_led_state;
 482               		.loc 1 155 28 is_stmt 0 view .LVU107
 483 002a 8091 0000 		lds r24,digit.1088
 484 002e 01E0      		ldi r16,lo8(1)
 485 0030 10E0      		ldi r17,0
 486 0032 9801      		movw r18,r16
 487 0034 00C0      		rjmp 2f
 488               		1:
 489 0036 220F      		lsl r18
 490 0038 331F      		rol r19
 491               		2:
 492 003a 8A95      		dec r24
 493 003c 02F4      		brpl 1b
 494               	.LVL25:
 156:drivers/indicator.c **** 
 495               		.loc 1 156 5 is_stmt 1 view .LVU108
 156:drivers/indicator.c **** 
 496               		.loc 1 156 23 is_stmt 0 view .LVU109
 497 003e 0091 0000 		lds r16,ind_led_state
 498 0042 022B      		or r16,r18
 499               	.LVL26:
 158:drivers/indicator.c **** 
 500               		.loc 1 158 5 is_stmt 1 view .LVU110
 158:drivers/indicator.c **** 
 501               		.loc 1 158 23 is_stmt 0 view .LVU111
 502 0044 0095      		com r16
 503               	.LVL27:
 160:drivers/indicator.c ****     // Загрузка данных во втотрой сдвиговый регистр
 504               		.loc 1 160 6 is_stmt 1 view .LVU112
 162:drivers/indicator.c ****     {
 505               		.loc 1 162 5 view .LVU113
 158:drivers/indicator.c **** 
 506               		.loc 1 158 23 is_stmt 0 view .LVU114
 507 0046 D0E0      		ldi r29,0
 508 0048 C0E0      		ldi r28,0
 164:drivers/indicator.c ****       clock_signal();
 509               		.loc 1 164 39 view .LVU115
 510 004a 10E0      		ldi r17,0
 511               	.LVL28:
 512               	.L21:
 164:drivers/indicator.c ****       clock_signal();
 513               		.loc 1 164 7 is_stmt 1 view .LVU116
 164:drivers/indicator.c ****       clock_signal();
 514               		.loc 1 164 39 is_stmt 0 view .LVU117
 515 004c C801      		movw r24,r16
 516 004e 0C2E      		mov r0,r28
 517 0050 00C0      		rjmp 2f
 518               		1:
 519 0052 880F      		lsl r24
 520               		2:
 521 0054 0A94      		dec r0
 522 0056 02F4      		brpl 1b
 164:drivers/indicator.c ****       clock_signal();
 523               		.loc 1 164 16 view .LVU118
 524 0058 87FF      		sbrs r24,7
 525 005a 00C0      		rjmp .L19
 164:drivers/indicator.c ****       clock_signal();
 526               		.loc 1 164 58 view .LVU119
 527 005c 8BB1      		in r24,0xb
 164:drivers/indicator.c ****       clock_signal();
 528               		.loc 1 164 16 view .LVU120
 529 005e 8860      		ori r24,lo8(8)
 530               	.L20:
 531 0060 8BB9      		out 0xb,r24
 165:drivers/indicator.c ****     }
 532               		.loc 1 165 7 is_stmt 1 view .LVU121
 533 0062 0E94 0000 		call clock_signal
 534               	.LVL29:
 165:drivers/indicator.c ****     }
 535               		.loc 1 165 7 is_stmt 0 view .LVU122
 536 0066 2196      		adiw r28,1
 537               	.LVL30:
 162:drivers/indicator.c ****     {
 538               		.loc 1 162 5 view .LVU123
 539 0068 C430      		cpi r28,4
 540 006a D105      		cpc r29,__zero_reg__
 541 006c 01F4      		brne .L21
 542               	.LVL31:
 543               	.L24:
 170:drivers/indicator.c ****       clock_signal();
 544               		.loc 1 170 7 is_stmt 1 view .LVU124
 170:drivers/indicator.c ****       clock_signal();
 545               		.loc 1 170 39 is_stmt 0 view .LVU125
 546 006e C801      		movw r24,r16
 547 0070 0C2E      		mov r0,r28
 548 0072 00C0      		rjmp 2f
 549               		1:
 550 0074 880F      		lsl r24
 551               		2:
 552 0076 0A94      		dec r0
 553 0078 02F4      		brpl 1b
 170:drivers/indicator.c ****       clock_signal();
 554               		.loc 1 170 16 view .LVU126
 555 007a 87FF      		sbrs r24,7
 556 007c 00C0      		rjmp .L22
 170:drivers/indicator.c ****       clock_signal();
 557               		.loc 1 170 58 view .LVU127
 558 007e 8BB1      		in r24,0xb
 170:drivers/indicator.c ****       clock_signal();
 559               		.loc 1 170 16 view .LVU128
 560 0080 8860      		ori r24,lo8(8)
 561               	.L23:
 562 0082 8BB9      		out 0xb,r24
 171:drivers/indicator.c ****     }
 563               		.loc 1 171 7 is_stmt 1 view .LVU129
 564 0084 0E94 0000 		call clock_signal
 565               	.LVL32:
 171:drivers/indicator.c ****     }
 566               		.loc 1 171 7 is_stmt 0 view .LVU130
 567 0088 2196      		adiw r28,1
 568               	.LVL33:
 168:drivers/indicator.c ****     {
 569               		.loc 1 168 5 view .LVU131
 570 008a C830      		cpi r28,8
 571 008c D105      		cpc r29,__zero_reg__
 572 008e 01F4      		brne .L24
 573 0090 D0E0      		ldi r29,0
 574 0092 C0E0      		ldi r28,0
 575               	.LVL34:
 576               	.L27:
 178:drivers/indicator.c ****       clock_signal();
 577               		.loc 1 178 7 is_stmt 1 view .LVU132
 178:drivers/indicator.c ****       clock_signal();
 578               		.loc 1 178 35 is_stmt 0 view .LVU133
 579 0094 E091 0000 		lds r30,digit.1088
 580 0098 0E2E      		mov __tmp_reg__,r30
 581 009a 000C      		lsl r0
 582 009c FF0B      		sbc r31,r31
 583 009e E050      		subi r30,lo8(-(indicator_data))
 584 00a0 F040      		sbci r31,hi8(-(indicator_data))
 585 00a2 8081      		ld r24,Z
 178:drivers/indicator.c ****       clock_signal();
 586               		.loc 1 178 43 view .LVU134
 587 00a4 0C2E      		mov r0,r28
 588 00a6 00C0      		rjmp 2f
 589               		1:
 590 00a8 880F      		lsl r24
 591               		2:
 592 00aa 0A94      		dec r0
 593 00ac 02F4      		brpl 1b
 178:drivers/indicator.c ****       clock_signal();
 594               		.loc 1 178 16 view .LVU135
 595 00ae 87FF      		sbrs r24,7
 596 00b0 00C0      		rjmp .L25
 178:drivers/indicator.c ****       clock_signal();
 597               		.loc 1 178 62 view .LVU136
 598 00b2 8BB1      		in r24,0xb
 178:drivers/indicator.c ****       clock_signal();
 599               		.loc 1 178 16 view .LVU137
 600 00b4 8860      		ori r24,lo8(8)
 601               	.L26:
 602 00b6 8BB9      		out 0xb,r24
 179:drivers/indicator.c ****     }
 603               		.loc 1 179 7 is_stmt 1 view .LVU138
 604 00b8 0E94 0000 		call clock_signal
 605               	.LVL35:
 179:drivers/indicator.c ****     }
 606               		.loc 1 179 7 is_stmt 0 view .LVU139
 607 00bc 2196      		adiw r28,1
 608               	.LVL36:
 176:drivers/indicator.c ****     {
 609               		.loc 1 176 5 view .LVU140
 610 00be C830      		cpi r28,8
 611 00c0 D105      		cpc r29,__zero_reg__
 612 00c2 01F4      		brne .L27
 182:drivers/indicator.c **** 
 613               		.loc 1 182 5 is_stmt 1 view .LVU141
 614               	.LBB19:
 615               	.LBI19:
 137:drivers/indicator.c **** {
 616               		.loc 1 137 1 view .LVU142
 617               	.LBB20:
 139:drivers/indicator.c ****    __asm volatile("nop");
 618               		.loc 1 139 4 view .LVU143
 139:drivers/indicator.c ****    __asm volatile("nop");
 619               		.loc 1 139 13 is_stmt 0 view .LVU144
 620 00c4 5C9A      		sbi 0xb,4
 140:drivers/indicator.c ****    __asm volatile("nop");
 621               		.loc 1 140 4 is_stmt 1 view .LVU145
 622               	/* #APP */
 623               	 ;  140 "drivers/indicator.c" 1
 624 00c6 0000      		nop
 625               	 ;  0 "" 2
 141:drivers/indicator.c ****    __asm volatile("nop");
 626               		.loc 1 141 4 view .LVU146
 627               	 ;  141 "drivers/indicator.c" 1
 628 00c8 0000      		nop
 629               	 ;  0 "" 2
 142:drivers/indicator.c ****    __asm volatile("nop");
 630               		.loc 1 142 4 view .LVU147
 631               	 ;  142 "drivers/indicator.c" 1
 632 00ca 0000      		nop
 633               	 ;  0 "" 2
 143:drivers/indicator.c ****    IND_PORT &= ~(1<<E);
 634               		.loc 1 143 4 view .LVU148
 635               	 ;  143 "drivers/indicator.c" 1
 636 00cc 0000      		nop
 637               	 ;  0 "" 2
 144:drivers/indicator.c **** }
 638               		.loc 1 144 4 view .LVU149
 144:drivers/indicator.c **** }
 639               		.loc 1 144 13 is_stmt 0 view .LVU150
 640               	/* #NOAPP */
 641 00ce 5C98      		cbi 0xb,4
 642               	.LBE20:
 643               	.LBE19:
 185:drivers/indicator.c ****     {
 644               		.loc 1 185 5 is_stmt 1 view .LVU151
 185:drivers/indicator.c ****     {
 645               		.loc 1 185 9 is_stmt 0 view .LVU152
 646 00d0 8091 0000 		lds r24,digit.1088
 647 00d4 8F5F      		subi r24,lo8(-(1))
 185:drivers/indicator.c ****     {
 648               		.loc 1 185 7 view .LVU153
 649 00d6 8430      		cpi r24,lo8(4)
 650 00d8 04F4      		brge .L28
 651 00da 8093 0000 		sts digit.1088,r24
 652               	.LVL37:
 653               	.L18:
 654               	/* epilogue start */
 185:drivers/indicator.c ****     {
 655               		.loc 1 185 7 view .LVU154
 656               	.LBE18:
 657               	.LBE17:
 208:drivers/indicator.c **** }
 658               		.loc 1 208 1 view .LVU155
 659 00de FF91      		pop r31
 660 00e0 EF91      		pop r30
 661 00e2 DF91      		pop r29
 662 00e4 CF91      		pop r28
 663 00e6 BF91      		pop r27
 664 00e8 AF91      		pop r26
 665 00ea 9F91      		pop r25
 666 00ec 8F91      		pop r24
 667 00ee 7F91      		pop r23
 668 00f0 6F91      		pop r22
 669 00f2 5F91      		pop r21
 670 00f4 4F91      		pop r20
 671 00f6 3F91      		pop r19
 672 00f8 2F91      		pop r18
 673 00fa 1F91      		pop r17
 674 00fc 0F91      		pop r16
 675 00fe 0F90      		pop r0
 676 0100 0FBE      		out __SREG__,r0
 677 0102 0F90      		pop r0
 678 0104 1F90      		pop r1
 679 0106 1895      		reti
 680               	.LVL38:
 681               	.L19:
 682               	.LBB22:
 683               	.LBB21:
 164:drivers/indicator.c ****       clock_signal();
 684               		.loc 1 164 79 view .LVU156
 685 0108 8BB1      		in r24,0xb
 164:drivers/indicator.c ****       clock_signal();
 686               		.loc 1 164 16 view .LVU157
 687 010a 877F      		andi r24,lo8(-9)
 688 010c 00C0      		rjmp .L20
 689               	.L22:
 170:drivers/indicator.c ****       clock_signal();
 690               		.loc 1 170 79 view .LVU158
 691 010e 8BB1      		in r24,0xb
 170:drivers/indicator.c ****       clock_signal();
 692               		.loc 1 170 16 view .LVU159
 693 0110 877F      		andi r24,lo8(-9)
 694 0112 00C0      		rjmp .L23
 695               	.L25:
 178:drivers/indicator.c ****       clock_signal();
 696               		.loc 1 178 83 view .LVU160
 697 0114 8BB1      		in r24,0xb
 178:drivers/indicator.c ****       clock_signal();
 698               		.loc 1 178 16 view .LVU161
 699 0116 877F      		andi r24,lo8(-9)
 700 0118 00C0      		rjmp .L26
 701               	.L28:
 187:drivers/indicator.c ****     }
 702               		.loc 1 187 9 is_stmt 1 view .LVU162
 187:drivers/indicator.c ****     }
 703               		.loc 1 187 15 is_stmt 0 view .LVU163
 704 011a 1092 0000 		sts digit.1088,__zero_reg__
 705               	.LVL39:
 187:drivers/indicator.c ****     }
 706               		.loc 1 187 15 view .LVU164
 707               	.LBE21:
 708               	.LBE22:
 709               		.loc 1 208 1 view .LVU165
 710 011e 00C0      		rjmp .L18
 711               		.cfi_endproc
 712               	.LFE8:
 714               		.section	.bss.digit.1088,"aw",@nobits
 717               	digit.1088:
 718 0000 00        		.zero	1
 719               		.section	.bss.ind_led_state,"aw",@nobits
 722               	ind_led_state:
 723 0000 00        		.zero	1
 724               		.section	.bss.indicator_data,"aw",@nobits
 727               	indicator_data:
 728 0000 0000 0000 		.zero	4
 729               		.section	.rodata.ind_ascii_table,"a"
 732               	ind_ascii_table:
 733 0000 FF        		.byte	-1
 734 0001 79        		.byte	121
 735 0002 DD        		.byte	-35
 736 0003 9D        		.byte	-99
 737 0004 93        		.byte	-109
 738 0005 AD        		.byte	-83
 739 0006 E3        		.byte	-29
 740 0007 FD        		.byte	-3
 741 0008 C6        		.byte	-58
 742 0009 F0        		.byte	-16
 743 000a 9C        		.byte	-100
 744 000b B9        		.byte	-71
 745 000c 7F        		.byte	127
 746 000d BF        		.byte	-65
 747 000e 7F        		.byte	127
 748 000f AD        		.byte	-83
 749 0010 C0        		.byte	-64
 750 0011 F9        		.byte	-7
 751 0012 A4        		.byte	-92
 752 0013 B0        		.byte	-80
 753 0014 99        		.byte	-103
 754 0015 92        		.byte	-110
 755 0016 82        		.byte	-126
 756 0017 F8        		.byte	-8
 757 0018 80        		.byte	-128
 758 0019 90        		.byte	-112
 759 001a 00        		.byte	0
 760 001b 00        		.byte	0
 761 001c 00        		.byte	0
 762 001d B7        		.byte	-73
 763 001e 00        		.byte	0
 764 001f 3C        		.byte	60
 765 0020 30        		.byte	48
 766 0021 88        		.byte	-120
 767 0022 83        		.byte	-125
 768 0023 C6        		.byte	-58
 769 0024 A1        		.byte	-95
 770 0025 86        		.byte	-122
 771 0026 8E        		.byte	-114
 772 0027 C3        		.byte	-61
 773 0028 89        		.byte	-119
 774 0029 CF        		.byte	-49
 775 002a E1        		.byte	-31
 776 002b 8A        		.byte	-118
 777 002c C7        		.byte	-57
 778 002d 8D        		.byte	-115
 779 002e AB        		.byte	-85
 780 002f C0        		.byte	-64
 781 0030 8C        		.byte	-116
 782 0031 98        		.byte	-104
 783 0032 AF        		.byte	-81
 784 0033 92        		.byte	-110
 785 0034 87        		.byte	-121
 786 0035 C1        		.byte	-63
 787 0036 E1        		.byte	-31
 788 0037 FF        		.byte	-1
 789 0038 B6        		.byte	-74
 790 0039 91        		.byte	-111
 791 003a B7        		.byte	-73
 792 003b A7        		.byte	-89
 793 003c 9B        		.byte	-101
 794 003d B3        		.byte	-77
 795 003e FE        		.byte	-2
 796 003f F7        		.byte	-9
 797 0040 9F        		.byte	-97
 798               		.text
 799               	.Letext0:
 800               		.file 2 "c:\\bin\\avr-gcc-8.3.0-x64-mingw\\lib\\gcc\\avr\\8.3.0\\include\\stdint-gcc.h"
DEFINED SYMBOLS
                            *ABS*:0000000000000000 indicator.c
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:2      *ABS*:000000000000003e __SP_H__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:3      *ABS*:000000000000003d __SP_L__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:4      *ABS*:000000000000003f __SREG__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:5      *ABS*:0000000000000000 __tmp_reg__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:6      *ABS*:0000000000000001 __zero_reg__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:12     .text.clock_signal:0000000000000000 clock_signal
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:54     .text.ind_led_set:0000000000000000 ind_led_set
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:722    .bss.ind_led_state:0000000000000000 ind_led_state
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:102    .text.ind_print_string:0000000000000000 ind_print_string
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:727    .bss.indicator_data:0000000000000000 indicator_data
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:732    .rodata.ind_ascii_table:0000000000000000 ind_ascii_table
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:163    .text.ind_print_dec:0000000000000000 ind_print_dec
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:357    .text.ind_init:0000000000000000 ind_init
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:390    .text.__vector_16:0000000000000000 __vector_16
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccz5u8Un.s:717    .bss.digit.1088:0000000000000000 digit.1088

UNDEFINED SYMBOLS
__prologue_saves__
__udivmodhi4
__epilogue_restores__
__do_copy_data
__do_clear_bss
