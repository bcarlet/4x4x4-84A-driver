;
; Written for ATtiny84A @ 16 MHz.
;

.nolist
.include "tn84Adef.inc"
.include "constdef.inc"
.include "portdef.inc"
.include "regdef.inc"
.include "spixfer.inc"
.include "util.inc"
.list

.listmac

.include "ramdef.asm"

;
; ISR vector table
;
.cseg
.org $0000
    rjmp main                   ; reset vector
    reti                        ; unused
    reti                        ; unused
    reti                        ; unused
    reti                        ; unused
    reti                        ; unused
    reti                        ; unused
    reti                        ; unused
    reti                        ; unused
    reti                        ; unused
    reti                        ; unused
    rjmp TIM0_OVF               ; timer0 overflow interrupt
    reti                        ; unused
    reti                        ; unused
    reti                        ; unused
    reti                        ; unused
    reti                        ; unused

;
; timer0 overflow ISR
;
TIM0_OVF:
    push XH
    push XL
    push r16
    in r16, SREG
    push r16

    ; advance layer
    in r16, LAYER_OFFSET
    subi r16, -2
    andi r16, 0b110
    out LAYER_OFFSET, r16

    ; load layer data address
    ldi XH, BUFFER_ADDR_HIGH
    lds XL, front_buffer
    add XL, r16                 ; a and b buffer alignment guarantees no carry
    
    ; prepare first byte for transfer
    ld r16, X+
    out USIDR, r16

    ld r16, X                   ; load second byte

    spi_fast_init XL, XH
    spi_fast_xfer XL, XH        ; transfer first byte

    out USIDR, r16

    spi_fast_xfer XL, XH        ; transfer second byte
    
    ; turn off all FETs and transfer serial data to LED driver latches
    ldi r16, PORTA_IDLE | (1<<LE)
    out PORTA, r16

    cbi PORTA, LE               ; latch drivers
    
    in r16, LAYER_OFFSET

    ; 2 to 4 decode
    ldi XH, $01
    sbrc r16, 2
    ldi XH, $04
    sbrc r16, 1
    lsl XH

    out PINA, XH                ; toggle FET for current layer
    
    lds XH, poll_history + 1
    lds XL, poll_history
    
    lsl XL
    rol XH

    ; read inverted J2 state into poll history LSB
    sbis PINB, J2
    ori XL, 1

    sts poll_history + 1, XH
    sts poll_history, XL

    cpi XL, $ff                 ; carry set if XL != $ff; zero set if XL == $ff
    sbci XH, ~(1<<7)            ; zero cleared if result is not zero, otherwise clear if XL != $ff

    brne PC+2                   ; branch if XH:XL != ~(1<<15)
    sbi SOFTWARE_FLAGS, FCRF

    pop r16
    out SREG, r16
    pop r16
    pop XL
    pop XH
    reti

;
; main program start
;
main:
    ; initialize PORTA
    ldi uprtempL, DDRA_INIT
    ldi uprtempH, PORTA_IDLE
    out DDRA, uprtempL
    out PORTA, uprtempH

    ; initialize stack pointer
    ldi uprtempL, HIGH(RAMEND)
    out SPH, uprtempL
    ldi uprtempL, LOW(RAMEND)
    out SPL, uprtempL

    clr zeroreg

    .include "raminit.asm"

    rcall server_init_table     ; initialize front buffer with first server

    ; reinitialize back buffer pointer
    ldi uprtempL, LOW(frame_buffer_b)
    sts back_buffer, uprtempL

    ; set timer0 prescaler to 64 (1 tick = 4us at 16MHz -> 1.024ms until overflow)
    ldi uprtempL, (1<<CS01) | (1<<CS00)
    out TCCR0B, uprtempL

    ; enable timer0 overflow interrupt
    ldi uprtempL, (1<<TOIE0)
    out TIMSK0, uprtempL

    ; set timer1 TOP value
    ldi uprtempL, HIGH(TIMER1_TOP)
    out ICR1H, uprtempL
    ldi uprtempL, LOW(TIMER1_TOP)
    out ICR1L, uprtempL

    ; set timer1 prescaler to 256 (1 tick = 16us at 16MHz) and set mode to CTC with ICR1 as TOP
    ldi uprtempL, (1<<WGM13) | (1<<WGM12) | (1<<CS12)
    out TCCR1B, uprtempL

    sei

;
; main program loop
;
loop_main:
    ldi ZH, HIGH(frameserver_table)
    ldi ZL, LOW(frameserver_table)

    lds uprtempL, server_index

    sbis SOFTWARE_FLAGS, FCRF
    rjmp skip_server_change

    ; rotate frameserver
    inc uprtempL
    cpi uprtempL, SERVER_COUNT
    brlo PC+2
    clr uprtempL
    sts server_index, uprtempL

    sbiw ZH:ZL, SERVER_COUNT    ; switch to init table

    cbi SOFTWARE_FLAGS, FCRF
    sbi SOFTWARE_FLAGS, SFDF

skip_server_change:
    add ZL, uprtempL            ; jump table alignment guarantees no carry

    icall                       ; call frameserver routine

frame_delay_loop:
    sbic SOFTWARE_FLAGS, FCRF
    rjmp loop_main

    sbic SOFTWARE_FLAGS, SFDF
    rjmp break_frame_delay

    sbis TIFR1, ICF1
    rjmp frame_delay_loop

break_frame_delay:
    out TCNT1H, zeroreg
    out TCNT1L, zeroreg

    sbi TIFR1, ICF1             ; reset flag
    cbi SOFTWARE_FLAGS, SFDF

    lds lwrtempL, front_buffer
    lds lwrtempH, back_buffer

    ; swap buffers
    sts front_buffer, lwrtempH
    sts back_buffer, lwrtempL

    rjmp loop_main

.include "frameservers.asm"
.include "prng.asm"
