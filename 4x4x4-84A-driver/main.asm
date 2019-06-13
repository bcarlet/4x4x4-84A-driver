;
; Written for ATtiny84A @ 16 MHz.
;

.nolist
.include "tn84Adef.inc"
.include "portdef.inc"
.include "constdef.inc"
.include "regdef.inc"
.include "spixfer.inc"
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

    ; increment layer_index modulo 4
    lds r16, layer_index
    inc r16
    andi r16, 0b11
    sts layer_index, r16

    ; load layer data address
    lds XH, front_buffer + 1
    lds XL, front_buffer
    add r16, r16
    add XL, r16                 ; a and b buffer alignment guarantees no carry

    ld r16, X+
    spi_xfer r16
    ld r16, X
    spi_xfer r16

    ; turn off all FETs and transfer serial data to LED driver latches
    ldi r16, PORTA_IDLE | (1<<LE)
    out PORTA, r16

    cbi PORTA, LE               ; latch drivers

    ; toggle FET for current layer
    lds r16, layer_index
    ldi XH, 0x01
    sbrc r16, 1
    ldi XH, 0x04
    sbrc r16, 0
    lsl XH
    out PINA, XH

    lds XH, poll_history + 1
    lds XL, poll_history
    
    lsl XL
    rol XH

    ; read inverted J2 state into poll history LSB
    sbis PINB, J2
    ori XL, 1

    sts poll_history + 1, XH
    sts poll_history, XL

    pop r16                     ; load SREG

    ; compare XH:XL and ~(1<<15)
    cpi XL, $ff                 ; carry set if XL != $ff; zero set if XL == $ff
    sbci XH, ~(1<<7)            ; zero cleared if result is not zero, otherwise clear if XL != $ff

    brne skip_server_inc        ; branch if XH:XL != ~(1<<15)

    ; rotate frameserver
    lds XL, server_index
    inc XL
    cpi XL, SERVER_COUNT
    brlo PC + 2
    clr XL
    sts server_index, XL

    ori r16, (1<<SREG_T)        ; set T flag in SREG

skip_server_inc:
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

    .include "raminit.asm"

    rcall server_init_table     ; initialize front buffer with first server

    ; reinitialize back buffer pointer
    ldi uprtempL, LOW(frame_buffer_b)   ; a and b buffer addresses share common upper byte
    sts back_buffer, uprtempL

    ; set USI to 3-wire mode 0
    ldi uprtempL, (1<<USIWM0) | (1<<USICS1) | (1<<USICLK)
    out USICR, uprtempL

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

;
; main program loop
;
loop_main:
    ldi ZH, HIGH(frameserver_table)
    ldi ZL, LOW(frameserver_table)
    
    cli

    ; load address of current table
    brtc PC + 3
    sbiw ZH:ZL, server_count    ; switch to init table
    clt

    ; load address of current table entry
    lds uprtempL, server_index
    add ZL, uprtempL            ; jump table alignment guarantees no carry

    sei

    icall                       ; call frameserver routine

timer1_capture_loop:
    ; loop until timer1 input capture flag is set
    sbis TIFR1, ICF1
    rjmp timer1_capture_loop

    sbi TIFR1, ICF1             ; reset flag

    brts loop_main              ; don't swap buffers if frameserver has been changed

    lds uprtempL, front_buffer
    lds uprtempH, back_buffer

    ; swap buffers (front and back buffer pointers share common upper byte)
    sts front_buffer, uprtempH
    sts back_buffer, uprtempL

    rjmp loop_main

.include "frameservers.asm"
.include "prng.asm"
