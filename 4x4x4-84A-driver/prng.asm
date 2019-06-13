;
; place pseudorandom byte in uprtempL; the SREG is clobbered
;
.cseg
rand:
    lds uprtempL, prng_s

    mov uprtempH, uprtempL
    lsl uprtempH
    lsl uprtempH
    lsl uprtempH
    eor uprtempL, uprtempH

    mov uprtempL, uprtempH
    swap uprtempH
    lsr uprtempH
    andi uprtempH, 0b111
    eor uprtempL, uprtempH
    
    lds uprtempH, prng_a
    inc uprtempH
    sts prng_a, uprtempH

    lsr uprtempH
    lsr uprtempH
    eor uprtempL, uprtempH

    sts prng_s, uprtempL
    ret
