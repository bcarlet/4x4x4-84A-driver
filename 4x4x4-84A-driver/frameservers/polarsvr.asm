;
; pole swap animation
;

.set polarsvr_frame      = server_working_mem + 0       ; width 8
.set polarsvr_directions = server_working_mem + 8       ; width 2
.set polarsvr_timer      = server_working_mem + 10      ; width 1

.cseg
polarsvr_init:
    ldi XH, BUFFER_ADDR_HIGH
    lds XL, back_buffer

    ldi YH, HIGH(polarsvr_frame)
    ldi YL, LOW(polarsvr_frame)

    rcall rand                  ; place pseudorandom byte in r3
    mov lwrtempL, r3
    rcall rand

    std Y+8, lwrtempL           ; Y+8 points to polarsvr_directions
    std Y+9, r3

    std Y+10, zeroreg           ; Y+10 points to polarsvr_timer

    st X+, lwrtempL
    st Y+, lwrtempL
    st X+, r3
    st Y+, r3

    ldi uprtempL, 4

polarsvr_clear_loop:
    st X+, zeroreg
    st Y+, zeroreg
    dec uprtempL
    brne polarsvr_clear_loop

    com lwrtempL
    com r3

    st X+, lwrtempL
    st Y+, lwrtempL
    st X, r3
    st Y, r3

    ret

polarsvr:
    ldi YH, HIGH(polarsvr_frame)
    ldi YL, LOW(polarsvr_frame)

    .def directions_a = r18
    .def directions_b = r19

    ldd directions_a, Y+8       ; Y+8 points to polarsvr_directions
    ldd directions_b, Y+9

    ldi uprtempL, 4

polarsvr_fall_loop:
    ldd lwrtempL, Y+2

    mov lwrtempH, directions_a
    com lwrtempH
    and lwrtempH, lwrtempL
    
    and lwrtempL, directions_a
    std Y+2, lwrtempL

    ld lwrtempL, Y
    or lwrtempL, lwrtempH
    st Y+, lwrtempL

    eor directions_a, directions_b
    eor directions_b, directions_a
    eor directions_a, directions_b

    dec uprtempL
    brne polarsvr_fall_loop

    ldi YL, LOW(rainsvr_frame + 6)      ; server working memory shares common upper byte

    ldi uprtempL, 4

polarsvr_rise_loop:
    ld lwrtempL, -Y

    mov lwrtempH, directions_b
    com lwrtempH
    and lwrtempH, lwrtempL
    st Y, lwrtempH

    ldd lwrtempH, Y+2
    and lwrtempL, directions_b
    or lwrtempH, lwrtempL
    std Y+2, lwrtempH

    eor directions_a, directions_b
    eor directions_b, directions_a
    eor directions_a, directions_b

    dec uprtempL
    brne polarsvr_rise_loop

    ldi YL, LOW(rainsvr_frame)

    ld lwrtempL, Y
    or directions_a, lwrtempL

    ldd lwrtempL, Y+1
    or directions_b, lwrtempL

    ldd lwrtempL, Y+6
    com lwrtempL
    and directions_a, lwrtempL

    ldd lwrtempL, Y+7
    com lwrtempL
    and directions_b, lwrtempL

    std Y+8, directions_a       ; Y+8 points to polarsvr_directions
    std Y+9, directions_b

    .undef directions_a
    .undef directions_b

    ldd uprtempL, Y+10          ; Y+10 points to polarsvr_timer
    inc uprtempL
    andi uprtempL, 0b1111       ; zero set if result is $00; cleared otherwise
    std Y+10, uprtempL

    brne polarsvr_skip_initiate

    rcall rand

    .def mask = r18

    ldi mask, $01
    sbrc r3, 1
    ldi mask, $04
    sbrc r3, 0
    lsl mask
    sbrc r3, 2
    swap mask

    sbrc r3, 3
    ldi YL, LOW(rainsvr_frame + 1)

    ld uprtempL, Y
    ldd uprtempH, Y+6

    mov lwrtempL, uprtempL
    and lwrtempL, mask
    
    ldd lwrtempH, Y+2
    or lwrtempH, lwrtempL
    std Y+2, lwrtempH

    mov lwrtempH, uprtempH
    and lwrtempH, mask

    ldd lwrtempL, Y+4
    or lwrtempL, lwrtempH
    std Y+4, lwrtempL

    com mask

    and uprtempL, mask
    st Y, uprtempL
    and uprtempH, mask
    std Y+6, uprtempH

    .undef mask
    
    ldi YL, LOW(rainsvr_frame)

polarsvr_skip_initiate:
    ldi XH, BUFFER_ADDR_HIGH
    lds XL, back_buffer

    ldi uprtempL, FRAME_SIZE

polarsvr_copy_loop:
    ld uprtempH, Y+
    st X+, uprtempH
    dec uprtempL
    brne polarsvr_copy_loop

    ret
