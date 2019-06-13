;
; SRAM initialization
;

.cseg
    ; initialize the X pointer register to the beginning of the SRAM init section
    ldi XH, HIGH(sram_init)
    ldi XL, LOW(sram_init)

    ; front buffer pointer
    ldi uprtempL, LOW(frame_buffer_a)
    st X+, uprtempL
    ldi uprtempH, HIGH(frame_buffer_a)
    st X+, uprtempH

    ; back buffer pointer (initialized to front buffer)
    st X+, uprtempL
    st X+, uprtempH

    ; prng s
    ldi uprtempL, $fd
    st X+, uprtempL

.nolist

; high byte of front buffer address used as zero
.if HIGH(frame_buffer_a) != $00
.error "incorrect value in zero register"
.endif

.list

    ldi uprtempL, 4             ; size of clear section

loop_sram_clear:
    st X+, uprtempH             ; uprtempH == $00
    dec uprtempL
    brne loop_sram_clear
