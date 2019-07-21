;
; floating columns animation
;

.set floatsvr_frame         = server_working_mem + 0    ; width 8
.set floatsvr_target_layers = server_working_mem + 8    ; width 4
.set floatsvr_shift_masks   = server_working_mem + 12   ; width 2
.set floatsvr_timer         = server_working_mem + 14   ; width 1

.nolist

.if floatsvr_frame & 0b111 != 0
.error "floatsvr_frame not aligned to eight-byte block"
.endif

.if floatsvr_target_layers & 0b111 != 0
.error "floatsvr_target_layers not aligned to eight-byte block"
.endif

.list

.cseg
floatsvr_init:
    ldi ZH, HIGH(floatsvr_target_layers)
    ldi ZL, LOW(floatsvr_target_layers)

    ldi uprtempH, 4

floatsvr_init_rand_loop:
    rcall rand                  ; place pseudorandom byte in r3
    st Z+, r3
    dec uprtempH
    brne floatsvr_init_rand_loop

    ldi uprtempL, 3
    std Z+2, uprtempL           ; Z+2 points to floatsvr_timer

    ldi XH, BUFFER_ADDR_HIGH
    lds XL, back_buffer

    ldi YH, HIGH(floatsvr_frame)
    ldi YL, LOW(floatsvr_frame)

    ldi uprtempL, FRAME_SIZE

floatsvr_init_frame_loop:
    andi ZL, ~0b100
    ld lwrtempL, Z+
    ld lwrtempH, Z+

    sbrs YL, 1
    com lwrtempL
    sbrs YL, 2
    com lwrtempH

    and lwrtempL, lwrtempH

    st X+, lwrtempL
    st Y+, lwrtempL
    
    dec uprtempL
    brne floatsvr_init_frame_loop

    ret

floatsvr:
    ldi ZH, HIGH(floatsvr_target_layers)
    ldi ZL, LOW(floatsvr_target_layers)

    ldi YH, HIGH(floatsvr_frame)
    ldi YL, LOW(floatsvr_frame)

    .def shift_mask_a = r18
    .def shift_mask_b = r19

    ldd shift_mask_a, Z+4       ; Z+4 points to floatsvr_shift_masks
    ldd shift_mask_b, Z+5

    ldi uprtempL, 6

floatsvr_rise_loop:
    andi ZL, ~0b100
    ld lwrtempL, Z+
    ld lwrtempH, Z+

    sbrc YL, 1
    com lwrtempL
    sbrc YL, 2
    com lwrtempH

    or lwrtempL, lwrtempH
    and shift_mask_a, lwrtempL

    ld lwrtempL, Y

    mov lwrtempH, shift_mask_a
    com lwrtempH
    and lwrtempH, lwrtempL
    st Y+, lwrtempH

    ldd lwrtempH, Y+1
    and lwrtempL, shift_mask_a
    or lwrtempH, lwrtempL
    std Y+1, lwrtempH

    com lwrtempL
    and shift_mask_a, lwrtempL

    eor shift_mask_a, shift_mask_b
    eor shift_mask_b, shift_mask_a
    eor shift_mask_a, shift_mask_b

    dec uprtempL
    brne floatsvr_rise_loop
    
    ldi ZL, LOW(floatsvr_target_layers + 2)

    ldd shift_mask_a, Z+2       ; Z+2 points to floatsvr_shift_masks
    ldd shift_mask_b, Z+3

    ldi uprtempL, 6

floatsvr_fall_loop:
    andi ZL, ~0b100
    ld lwrtempL, Z+
    ld lwrtempH, Z+

    mov uprtempH, YL
    inc uprtempH

    sbrc uprtempH, 1
    com lwrtempL
    sbrc uprtempH, 2
    com lwrtempH

    or lwrtempL, lwrtempH
    and shift_mask_b, lwrtempL
    
    ldd lwrtempL, Y+1

    mov lwrtempH, shift_mask_b
    com lwrtempH
    and lwrtempH, lwrtempL
    std Y+1, lwrtempH
    
    ld lwrtempH, -Y
    and lwrtempL, shift_mask_b
    or lwrtempH, lwrtempL
    st Y, lwrtempH

    com lwrtempL
    and shift_mask_b, lwrtempL

    eor shift_mask_a, shift_mask_b
    eor shift_mask_b, shift_mask_a
    eor shift_mask_a, shift_mask_b

    dec uprtempL
    brne floatsvr_fall_loop

    .undef shift_mask_a
    .undef shift_mask_b

    .def timer = r18

    ldd timer, Y+14             ; Y+14 points to polarsvr_timer
    inc timer
    cpi timer, 6
    brlo floatsvr_skip_rand

    clr timer

    ldi ZL, LOW(floatsvr_target_layers)

    ldi uprtempH, 6

floatsvr_rand_loop:
    rcall rand
    st Z+, r3
    dec uprtempH
    brne floatsvr_rand_loop

floatsvr_skip_rand:
    std Y+14, timer

    .undef timer

    ldi XH, BUFFER_ADDR_HIGH
    lds XL, back_buffer

    ldi uprtempL, FRAME_SIZE

floatsvr_copy_loop:
    ld uprtempH, Y+
    st X+, uprtempH
    dec uprtempL
    brne floatsvr_copy_loop

    ret
