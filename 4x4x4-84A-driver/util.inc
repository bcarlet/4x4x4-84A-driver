#ifndef _UTIL_INC_
#define _UTIL_INC_

;
; exchange the contents of two registers
;
.macro swap_regs
    eor @0, @1
    eor @1, @0
    eor @0, @1
.endmacro

#endif  /* _UTIL_INC_ */
