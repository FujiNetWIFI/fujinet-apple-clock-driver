; fujinet clock driver for apple2
;
; heavily based on:
;  - https://github.dev/a2stuff/prodos-drivers/blob/main/clocks/fujinet/fn.clock.system.s
;  - https://github.com/cc65/ip65/blob/main/apps/date65.c#L137-L164
;

        .export  _init_driver

        .import  _sp_get_clock_id
        .import  _sp_dispatch_address

        .include "apple2.inc"
        .include "zeropage.inc"

PATHNAME        := $0280
DATETIME        := $BF06
DEVNUM          := $BF30
DATELO          := $BF90
MACHID          := $BF98
ROMIN2          := $C082                        ; Read ROM; no write
RWRAM1          := $C08B                        ; Read/write RAM bank 1

SP_CMD_STATUS   := $00
SP_STATUS_P_CNT := $03
OPC_JMP_ABS     := $4C

.proc driver
        php
        sei

        jsr $ffff
driver_dispatch = *-2
        .byte   SP_CMD_STATUS
params_address:
        .word   params - driver

        ; on exit from dispatch, we return here
        sta     $CFFF                           ; release C8xx ROM space
        plp
        rts

; these are the command parameters for the STATUS command
params: .byte   SP_STATUS_P_CNT                 ; sp_status(dest, 'P') to invoke the PRODOS time status from FN
dest:   .byte   $00                             ; overwrite with clock device
        .word   DATELO                          ; location to write the PRODOS clock data to
        .byte   'P'                             ; PRODOS status
.endproc


.proc _init_driver
        ; use fujinet-lib to find the clock-id and fill in the dispatch address for the SP card
        jsr     _sp_get_clock_id
        beq     error

        ; save the clock device id
        sta     driver::dest

        ; save the dispatch address into our driver
        lda     _sp_dispatch_address
        sta     driver::driver_dispatch
        lda     _sp_dispatch_address + 1
        sta     driver::driver_dispatch + 1

        clc
        ; store the jump address of the datetime routine in ptr1, and add the params address location back into params_address so it points to the correct D742 + size to params
        lda     DATETIME + 1
        sta     ptr1
        adc     driver::params_address
        sta     driver::params_address

        lda     DATETIME + 2
        sta     ptr1 + 1
        adc     driver::params_address + 1
        sta     driver::params_address + 1

        ; copy the driver into correct location based on the jmp vector from DATETIME+1
        ; "Read/write RAM bank 1": https://www.kreativekorp.com/miscpages/a2info/iomemory.shtml
        lda     RWRAM1
        lda     RWRAM1
        ldy     #.sizeof(driver) - 1
:       lda     driver, y
        sta     (ptr1), y
        dey
        bpl     :-

        ; tell system there's a new clock in town
        lda     MACHID
        ora     #$01
        sta     MACHID

        ; change RTS to JMP at the DATETIME location
        lda     #OPC_JMP_ABS
        sta     DATETIME

        ; run the driver to initialise the clock
        jsr     DATETIME

        ; apple stuff! "Read ROM; no write": https://www.kreativekorp.com/miscpages/a2info/iomemory.shtml
        lda     ROMIN2

        clc
        rts

        ; no device found
error:
        sec
        rts
.endproc

