; maze13h
; simple ray-casting maze, written in 8086 assembly 
; project for Assembly course at AGH UST

.286

; Data segment
_data segment
    linebreak   db  10, 13, "$"
_data ends

; Code segment
_code segment
    start:
        call init_segments


        mov ax, 0ABCDh
        call debug
        jmp exit

    ; =========================================================================
    ; init_segments initializes values of segment registers with addresses of our segments
    ; -------------------------------------------------------------------------
    init_segments:
        ; Initialize value of segment registers with our values
        ; We can only mov value from different register to segment register
        ; so let's store them in accumulator first and move them from there

        ; initialize ds - data segment register with address of our data segment
        mov ax, seg _data
        mov ds, ax

        ; initialize ss - stack segment register with address of our stack segment
        mov ax, seg _stack
        mov ss, ax

        ; set stack pointer to top of our stack
        lea sp, _stack_top
        ret

    ; =========================================================================
    ; debug prints value to standard output, followed by line break
    ; params:
    ;   ax  value to be written to standard output
    ; -------------------------------------------------------------------------
    debug:
        pusha               ; call convention - store all registers
        mov ch, 4           ; 4 hexadecimal digits
    debug__loop:
        dec ch              ; decerease counter

        ; extract appropiate digit
        mov cl, ch          ; in BX we will calculate by how much bytes we have to shift
        shl cl, 2           ; one digit - 4 bytes, we have to multiply our shift by 4
        mov dx, ax          ; in DX we will store value we'll operate on
        shr dx, cl          ; shift copy of our value by appropiate, previously calculated offset
        and dx, 000Fh       ; extract digit only
        
        ; convert digit to ASCII
        add dl, "0"         ; add ASCII code of 0 to digit
        cmp dl, ":"         ; check if not decimal digit
        jge debug__print_AF_digit
        jmp debug__print_digit_end
    debug__print_AF_digit:
        add dl, 07h         ; there are 7 characters between 9 and A
    debug__print_digit_end:
        ; print digit
        push ax             ; we need our number later, and we have to use ax to call appropiate 21h procedure
        mov ah, 02h         ; DOS - WRITE CHARACTER TO STANDARD OUTPUT
        int 21h             ; syscall
        pop ax              ; restore our number

        ; check exit condition
        cmp ch, 0           ; check if current digit is 0 - then all digits are printed
        jz debug__end       ; finish loop when all digits were already printed
        jmp debug__loop

    debug__end:
        ; print linebreak
        mov ah, 09h         ; DOS WRITE STRING TO STANDARD OUTPUT
        mov dx, offset linebreak    ; we want to print linebreak
        int 21h             ; syscall

        popa                ; call convention - restore all registers
        ret
    
    ; =========================================================================
    ; exit exists from maze13h
    ; -------------------------------------------------------------------------
    exit:
        ; wait for key being pressed
        xor ax, ax  ; 0 - KEYBOARD - GET KEYSTROKE
        int 16h     ; BIOS keyboard interrupt
        
        ; call DOS exit
        mov ax, 4c00h ; 7ch - EXIT - TERMINATE WITH RETURN CODE
        int 21h
    
    ; =========================================================================
_code ends

; Stack segment
_stack segment stack
    dw 255 dup(?)
	_stack_top	dw ?
_stack ends
    end start
