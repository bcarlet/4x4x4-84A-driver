#ifndef _SPIXFER_INC_
#define _SPIXFER_INC_

;
; transfer a byte stored in an upper register over USI as SPI; the register is clobbered
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

;
; prepare two upper registers for a fast transfer over USI
;
.macro spi_fast_init
    ldi @0, (1<<USIWM0) | (1<<USITC)
    ldi @1, (1<<USIWM0) | (1<<USITC) | (1<<USICLK)
.endmacro

;
; perform a fast transfer of the current contents of the USI data register using two auxiliary
; registers initialized with spi_fast_init
;
.macro spi_fast_xfer
    out USICR, @0
    out USICR, @1
    out USICR, @0
    out USICR, @1
    out USICR, @0
    out USICR, @1
    out USICR, @0
    out USICR, @1
    out USICR, @0
    out USICR, @1
    out USICR, @0
    out USICR, @1
    out USICR, @0
    out USICR, @1
    out USICR, @0
    out USICR, @1
.endmacro

#endif  /* _SPIXFER_INC_ */
