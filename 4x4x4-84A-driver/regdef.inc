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
.equ LAYER_OFFSET_IOREG = GPIOR0

#endif  /* _REGDEF_INC_ */
