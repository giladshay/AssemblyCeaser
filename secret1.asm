IDEAL
MODEL small
STACK 100h

DATASEG
    key db ?
    message db 23 dup (?)
    encrypted db 23 dup(?)
    enter_msg db 'please type your message: $'
    encrypted_msg db 'the encrypted message is: $'
    
    isLet db 0
CODESEG

proc isLetter
    cmp al, 'A'
    jl no
    cmp al, 'z'
    jg no
    cmp al, 'a'
    jl upper
    lower:
    mov [isLet], 1 ; lowercase
    ret
    upper:
    cmp al, 'Z'
    jg no
    mov [isLet], 2 ; uppercase
    ret
    no:
    mov [isLet], 0 ; no
    ret
endp isLetter

    start:
        mov ax, @data
        mov ds, ax
        
        ; get key
        mov ah, 2
        mov dl, 'a'
        int 21h
        mov dl, '='
        int 21h
        
        mov ah, 1
        int 21h
        
        mov [key], al
        sub [key], 'a'
        
        ; new line
        mov ah, 2
        mov dl, 0Ah
        int 21h
        mov dl, 0Dh
        int 21h
        
        ; get input
        mov ah, 9
        mov dx, offset enter_msg
        int 21h
        
        mov ah, 0Ah
        mov dx, offset message
        mov bx, dx
        mov [byte ptr bx], 21
        int 21h
        
        ; encrypt
        xor cx, cx
        mov bx, offset message
        mov si, offset encrypted
        inc bx
        mov cl, [bx] ; get message length
        encrypt:
            inc bx
            mov al, [bx]
            call isLetter ; check whether uppercase, lowercase or not letter
            cmp [isLet], 0 ; no letter
            je final
            letter:
                cmp [isLet], 1 ; lowercase
                jne uppercase
                add al, [key]
                cmp al, 'z'
                jbe final
                sub al, 26
                jmp final
                uppercase:
                    add al, [key]
                    cmp al, 'Z'
                    jbe final
                    sub al, 26
                    final:
                        mov [si], al
                        inc si
                        loop encrypt
        mov [byte ptr si], '$' ; finish the message
        
        ; new line
        mov ah, 2
        mov dl, 0Ah
        int 21h
        mov dl, 0Dh
        int 21h
        
        ; print answer
        mov ah, 9
        mov dx, offset encrypted_msg
        int 21h
        mov dx, offset encrypted
        int 21h
        
    exit:
        mov ax, 4C00h
        int 21h
END start
