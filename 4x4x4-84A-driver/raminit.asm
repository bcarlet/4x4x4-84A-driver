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

    ; back buffer pointer (initialized to front buffer)
    st X+, uprtempL

    ; prng s
    ldi uprtempL, $fd
    st X+, uprtempL

    ldi uprtempL, 4             ; size of clear section

loop_sram_clear:
    st X+, zeroreg
    dec uprtempL
    brne loop_sram_clear
