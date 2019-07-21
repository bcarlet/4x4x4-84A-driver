;
; server initializer jump table
;
.cseg
server_init_table:
    rjmp rainsvr_init
    rjmp floatsvr_init
    rjmp polarsvr_init
    rjmp randsvr_init

;
; frameserver jump table
;
frameserver_table:
    rjmp rainsvr
    rjmp floatsvr
    rjmp polarsvr
    rjmp randsvr

.equ SERVER_COUNT = 4

.nolist

; addresses of all initializer table entries should share common upper byte
.if HIGH(server_init_table) != HIGH(server_init_table + SERVER_COUNT - 1)
.error "addresses of initializer table entries have differing upper bytes"
.endif

; addresses of all frameserver table entries should share common upper byte
.if HIGH(frameserver_table) != HIGH(frameserver_table + SERVER_COUNT - 1)
.error "addresses of frameserver table entries have differing upper bytes"
.endif

.list

;
; frameserver implementations
;
.include "frameservers\rainsvr.asm"
.include "frameservers\floatsvr.asm"
.include "frameservers\polarsvr.asm"
.include "frameservers\randsvr.asm"
