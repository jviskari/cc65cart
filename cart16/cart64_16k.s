;
; Startup code for cc65 (C64 version)
;

	.export		_exit
        .export         __STARTUP__ : absolute = 1      ; Mark as startup
	.import		initlib, donelib, callirq
       	.import	       	zerobss
	.import	     	callmain, pushax
        .import         RESTOR, BSOUT, CLRCH
	.import	       	__INTERRUPTOR_COUNT__
	.import		__RAM_START__, __RAM_SIZE__	; Linker generated

	.import		_cgetc, _puts, _memcpy

	.import		__DATA_LOAD__, __DATA_RUN__, __DATA_SIZE__

        .include        "zeropage.inc"
	.include     	"c64.inc"


.segment	"HEADERDATA"

HeaderB:
@magic:
	;.byt	"C64  CARTRIDGE  "
	.byt	$43,$36,$34,$20, $43,$41,$52,$54
	.byt	$52,$49,$44,$47, $45,$20,$20,$20
@headelen:
	.byt	$00,$00,$00,$40
@ver:
	.byt	$01,$00
@carttye:
	.byt	$00,$00
@EXROM:
	.byt	$01
@GAME:
	.byt	$01
@reserved1:
	.byt	$00,$00,$00,$00,$00,$00
@Name:	;You put the name of the cartridge here.
	.byt	"TEST CODE"


.segment	"CHIP0"
ChipB:
@magic:
	.byt	$43,$48,$49,$50 ;"CHIP"
@size:
	.byt	$00,$00,$20,$10	;Use for 8k carridge
	;.byt	$00,$00,$40,$10	;Use for 16k carridge
@chiptype:	;ROM
	.byt	$00,$00
@bank:
	.word	$0000
@start:
	.byt	$80,$00
@size2:
	.byt	$40,$00

.segment	"STARTUP"
	.word	startup		;Cold start
	.word	$FEBC		;Warm start, default calls NMI exit.
	.byt	$C3,$C2,$CD,$38,$30 ;magic to identify cartridge

startup:
	jsr	$FF84		;Init. I/O
	jsr	$FF87		;Init. RAM
	jsr	$FF8A		;Restore vectors
	jsr	$FF81		;Init. screen
	
; Switch to second charset

	lda	#14
	jsr	BSOUT

; Clear the BSS data

	jsr	zerobss

	lda    	#<(__RAM_START__ + __RAM_SIZE__)
	sta	sp
	lda	#>(__RAM_START__ + __RAM_SIZE__)
       	sta	sp+1   		; Set argument stack ptr

; If we have IRQ functions, chain our stub into the IRQ vector

;        lda     #<__INTERRUPTOR_COUNT__
;      	beq	NoIRQ1
;      	lda	IRQVec
;       	ldx	IRQVec+1
;      	sta	IRQInd+1
;      	stx	IRQInd+2
;      	lda	#<IRQStub
;      	ldx	#>IRQStub
;      	sei
;      	sta	IRQVec
;      	stx	IRQVec+1
;      	cli

; Call module constructors

	
NoIRQ1:
	lda	#<__DATA_RUN__
	ldx	#>__DATA_RUN__
	jsr	pushax
	lda	#<__DATA_LOAD__
	ldx	#>__DATA_LOAD__
	jsr	pushax
	lda	#<__DATA_SIZE__
	ldx	#>__DATA_SIZE__
	jsr	_memcpy
	

	jsr	initlib

; Push arguments and call main
;ra:
;	inc	$D021
;	jmp	ra


        jsr     callmain

; Back from main (This is also the _exit entry). Run module destructors

_exit:  jsr	donelib


; Reset the IRQ vector if we chained it.

;        ;pha  			; Save the return code on stack
;	lda     #<__INTERRUPTOR_COUNT__
;	beq	NoIRQ2
;	lda	IRQInd+1
;	ldx	IRQInd+2
;	sei
;	sta	IRQVec
;	stx	IRQVec+1
;	cli


NoIRQ2:	
	lda	#<exitmsg
	ldx	#>exitmsg
	jsr	_puts
	jsr	_cgetc
	jmp	64738		;Kernal reset address as best I know it.

.rodata
exitmsg:
	.byt	"Your program has ended.  Press any key",13,"to continue...",0

