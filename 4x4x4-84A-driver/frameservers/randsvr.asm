;
; random voxels animation
;

.cseg
randsvr_init:
randsvr:
    lds XH, back_buffer + 1
    lds XL, back_buffer

    .def frame_byte = r18
    ldi frame_byte, FRAME_SIZE

randsvr_fill_loop:
    rcall rand                  ; place pseudorandom byte in r3
    st X+, r3
    dec frame_byte
    brne randsvr_fill_loop
    
    .undef frame_byte

    ret
