#ifndef _CONSTDEF_INC_
#define _CONSTDEF_INC_

;
; constant definitions
;
.equ DDRA_INIT = 0b10111111     ; LE, USCK, DO, and FET gates as outputs; PA6 unused
.equ PORTA_IDLE = 0b01001111    ; LE, USCK, DO low and all FETs off; internal pull-up enabled on unused pin PA6
.equ TIMER1_TOP = 12500         ; 12500 ticks at 1 tick = 16us -> 200ms
.equ FRAME_SIZE = 8

#endif  /* _CONSTDEF_INC_ */
