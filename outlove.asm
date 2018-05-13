; Outline 2k18
; F#READY march 2018

; little scroller within 128 bytes, graphics 2

; revision history
; 1.0 - some optimisations, 126 bytes
; 2.0 - more optimisations, 117 bytes
; 3.0 - added bleep, changed colors, 128 bytes - could be released.
; 4.0 - more optimisations, 123 bytes (same fx as 3.0)
; 5.0 - optimised to 120 bytes, but used to set raster colors and change 708, now again 127 bytes
; 6.0 - text changed to "outlove", changed sound, 128 bytes
; 7.0 - fixed scroll speed, changed sound, code cleanup, 128 bytes
; 8.0 - optimised 3 bytes, now wide screen, 128 bytes
; 9.0 - new idea to loose the copy character routine, whoaaa!! now 116 bytes
; 9.1 smooth - added smooth scrolling by directly poking DL memory, 128 bytes
; 9.2 smooth - experimented with sound, not completely lame now, 127 bytes
; 9.3 smooth - 2 bytes optimised, thanks to ivop, 125 bytes
; 9.4 smooth - used 2 bytes to improve the sound, happy now :), 127 bytes
; 9.5 smooth - optimised 5 bytes by JAC! after party release, 122 bytes
; 9.6 smooth - set RAMTOP to be compatible with 600XL/ BASIC ON, init.pokey, 127 bytes

	org $80
	
main
; ugly hack to set graphics 2 (XL OS only!)
	lda #$32
	sta $6a		; lda #$12, sta RAMTOP - could be used to make this prog compatible with 16K and BASIC ON...
;	sta $2b		; ICAX2Z
	jsr $ef8e+2	; jsr $f3f4 works for Altirra OS (but plz use original Rev.2 XL/XE OS!)
	
	lda #$e2
	sta 756

	inc 559

loop
;	sta $d40a
	asl
	sta $d018
;	ror
	lda $d40b
	bne loop
	sta 708

	clc			; carry must be 0 for the first ror instruction!
	lda 20
	eor #$ff

	and #$af
	sta $d201
	
	and #7
	sta $d404
	eor #7

	bne loop
			
; main idea for this scroller
	tay
all_up
	lda (88),y
	sta $305c+19,y		; $be6f,y
	iny
	bne all_up
	
; select next bit column
	ror bit_mask+1
	bcc bitsleft
; carry set, init bit_mask to 128
	ror bit_mask+1
		
; next char when enough bits shifted
	dec char_index+1
char_index
	lda #0
	and #7
	tax
	
; x = index to char
	lda text_offsets,x
	sta lo_font+1
	
bitsleft

; copy bitmap bits into last screen column
; assuming the bit mask is set to the right bit
; y is het rightmost position of the screen

	ldx #7
	stx $d20f				; fixes init problem with sio2sd

	ldy #(10*24)-1			;159+40

all_rows
	
bit_mask
	lda #1			; bitmask, init.1 to make sure ror fills carry the first time
	sta $d200

lo_font
	and $e100,x
	beq zero_bit	
	lda #128
zero_bit
	sta (88),y

	lda #$17
	sta $305c+7,x		; was:$be63, DL=$be5c (BASIC OFF), $9e5c (BASIC ON). zp $58=$be70,9e70

; next row
	tya
	adc #-25
	tay
	
	dex
	bpl all_rows

	bmi loop	; endless
				
; limited to one page in font, so offset should be 0,8,16..250
text_offsets
	dta 5*8,22*8,15*8,12*8,20*8,21*8,15*8
	dta 246

	run main
