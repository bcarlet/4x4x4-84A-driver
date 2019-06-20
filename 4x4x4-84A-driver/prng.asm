;
; place pseudorandom byte in r3; the SREG is clobbered
;
.cseg
rand:
    .def rand_return = r3
    lds rand_return, prng_s

    mov uprtempL, rand_return
    lsl uprtempL
    lsl uprtempL
    lsl uprtempL
    eor rand_return, uprtempL

    mov rand_return, uprtempL
    swap uprtempL
    lsr uprtempL
    andi uprtempL, 0b111
    eor rand_return, uprtempL
    
    lds uprtempL, prng_a
    inc uprtempL
    sts prng_a, uprtempL

    lsr uprtempL
    lsr uprtempL
    eor rand_return, uprtempL

    sts prng_s, rand_return

    .undef rand_return

    ret
