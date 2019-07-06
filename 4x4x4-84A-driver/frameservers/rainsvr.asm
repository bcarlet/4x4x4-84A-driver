;
; rain animation
;

.set rainsvr_frame      = server_working_mem + 0    ; width 8
.set rainsvr_next_layer = server_working_mem + 8    ; width 2

.cseg
rainsvr_init:
    lds XH, back_buffer + 1
    lds XL, back_buffer

    ldi YH, HIGH(rainsvr_frame)
    ldi YL, LOW(rainsvr_frame)

    ldi uprtempL, FRAME_SIZE

rainsvr_clear_loop:
    st X+, zeroreg
    st Y+, zeroreg
    dec uprtempL
    brne rainsvr_clear_loop

    st Y+, zeroreg              ; Y points to rainsvr_next_layer
    st Y, zeroreg

    ret

rainsvr:
    lds XH, back_buffer + 1
    lds XL, back_buffer

    ldi YH, HIGH(rainsvr_frame)
    ldi YL, LOW(rainsvr_frame)

    ldi uprtempL, 6

rainsvr_shift_loop:
    ldd uprtempH, Y+2
    st Y+, uprtempH
    st X+, uprtempH
    dec uprtempL
    brne rainsvr_shift_loop

    .def next_layer_a = r18
    .def next_layer_b = r19

    ldd next_layer_a, Y+2       ; Y+2 points to rainsvr_next_layer
    ldd next_layer_b, Y+3
    
    rcall rand                  ; place pseudorandom byte in r3
    
    ldi uprtempH, $01
    sbrc r3, 1
    ldi uprtempH, $04
    sbrc r3, 0
    lsl uprtempH
    sbrc r3, 2
    swap uprtempH

    ldi uprtempL, $01
    sbrc r3, 4
    ldi uprtempL, $04
    sbrc r3, 3
    lsl uprtempL
    sbrc r3, 5
    swap uprtempL

    sbrs r3, 6
    rjmp rainsvr_skip_combine

    or uprtempH, uprtempL
    clr uprtempL

rainsvr_skip_combine:
    sbrs r3, 7
    rjmp rainsvr_skip_swap

    eor uprtempL, uprtempH
    eor uprtempH, uprtempL
    eor uprtempL, uprtempH

rainsvr_skip_swap:
    .def last_top_a = r20
    .def last_top_b = r21

    ld last_top_a, Y
    ldd last_top_b, Y+1

    com last_top_a
    com last_top_b

    and uprtempL, last_top_a
    and uprtempH, last_top_b

    .undef last_top_a
    .undef last_top_b

    or next_layer_a, uprtempL
    or next_layer_b, uprtempH

    st Y+, next_layer_a
    st X+, next_layer_a
    st Y+, next_layer_b
    st X, next_layer_b

    st Y+, uprtempL             ; Y points to next_layer
    st Y, uprtempH

    .undef next_layer_a
    .undef next_layer_b

    ret
