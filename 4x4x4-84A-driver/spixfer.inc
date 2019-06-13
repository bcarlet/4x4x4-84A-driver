#ifndef _SPIXFER_INC_
#define _SPIXFER_INC_

;
; transfer one byte over USI as SPI; the register parameter is clobbered
;
.macro spi_xfer
    out USIDR, @0

    ldi @0, (1<<USIOIF)
    out USISR, @0

    ldi @0, (1<<USIWM0) | (1<<USICS1) | (1<<USICLK) | (1<<USITC)

    out USICR, @0
    sbis USISR, USIOIF
    rjmp PC - 2
.endmacro

#endif  /* _SPIXFER_INC_ */
