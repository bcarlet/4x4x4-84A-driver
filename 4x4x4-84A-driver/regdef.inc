#ifndef _REGDEF_INC_
#define _REGDEF_INC_

;
; working register definitions
;
.def zeroreg = r2

.def uprtempH = r17
.def uprtempL = r16
.def lwrtempH = r1
.def lwrtempL = r0

;
; I/O register definitions
;
.equ SOFTWARE_FLAGS = GPIOR0
.equ LAYER_OFFSET = GPIOR1

;
; flag register bit definitions
;
.equ FCRF = 0                   ; Frameserver Change Request Flag
.equ SFDF = 1                   ; Skip Frame Delay Flag

#endif  /* _REGDEF_INC_ */
