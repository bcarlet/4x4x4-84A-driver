#ifndef _REGDEF_INC_
#define _REGDEF_INC_

;
; register definitions
;

; temporary registers may be clobbered by subroutines but will be saved and restored by ISRs
.def uprtempH = r17
.def uprtempL = r16
.def lwrtempH = r1
.def lwrtempL = r0

#endif  /* _REGDEF_INC_ */
