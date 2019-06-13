;
; SRAM definitions
;

.dseg
.org SRAM_START

;
; no init section
;
sram_no_init:
    frame_buffer_a: .byte 8
    frame_buffer_b: .byte 8
    server_working_mem: .byte 64
    layer_index: .byte 1

.nolist

; addresses in a and b buffers should share common upper byte
.if HIGH(frame_buffer_a) != HIGH(frame_buffer_b + 7)
.error "addresses in a and b buffers have differing upper bytes"
.endif

; addresses in server working memory should share common upper byte
.if HIGH(server_working_mem) != HIGH(server_working_mem + 63)
.error "addresses in server working memory have differing upper bytes"
.endif

.list

;
; init section; exact order of definitions must be maintained for initialization
;
sram_init:
    front_buffer: .byte 2
    back_buffer: .byte 2
    prng_s: .byte 1

;
; clear section
;
sram_clear:
    prng_a: .byte 1
    server_index: .byte 1
    poll_history: .byte 2
