.equ SERVER_COUNT = 2

;
; server initializer jump table
;
.cseg
server_init_table:
    rjmp testsvr_init
    rjmp randsvr_init

;
; frameserver jump table
;
frameserver_table:
    rjmp testsvr
    rjmp randsvr

.nolist

; addresses of all initializer table entries should share common upper byte
.if HIGH(server_init_table) != HIGH(server_init_table + SERVER_COUNT - 1)
.error "addresses of initializer table entries have differing upper bytes"
.endif

; addresses of all frameserver table entries should share common upper byte
.if HIGH(frameserver_table) != HIGH(frameserver_table + SERVER_COUNT- 1)
.error "addresses of frameserver table entries have differing upper bytes"
.endif

.list

;
; frameserver implementations
;
.include "frameservers\testsvr.asm"
.include "frameservers\randsvr.asm"
