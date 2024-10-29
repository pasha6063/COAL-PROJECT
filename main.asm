.model small
.stack 100h
.data
    ; Menu text data
    line1 db 13, 10, " _____________________________________", 13, 10, "$"
    line2 db "|            Phone Book               |", 13, 10, "$"
    line3 db "|_____________________________________|", 13, 10, "$"
    line4 db "|   |                                 |", 13, 10, "$"
    line5 db "| 1 |  New Contact                    |", 13, 10, "$"
    line6 db "| 2 |  Edit a contact                 |", 13, 10, "$"
    line7 db "| 3 |  Search Contact                 |", 13, 10, "$"
    line8 db "| 4 |  List all Contacts              |", 13, 10, "$"
    line9 db "| 0 |  Exit                           |", 13, 10, "$"
    line10 db "|   |                                 |", 13, 10, "$"
    line11 db "|___|_________________________________|", 13, 10, "$"
    line12 db "Press a key to continue : $"
    choice_msg db 13, 10, "Your choice is: $"

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Call the display menu procedure
    call display_menu

    ; Print the user's choice
    mov dx, offset choice_msg
    call print_string
    mov dl, al             ; Move the user's choice into DL for printing
    call print_choice

    ; Wait for key press before exiting
    mov ah, 1
    int 21h

    ; Exit program
    mov ah, 4Ch
    int 21h
main endp

display_menu proc
    ; Display each line of the menu
    call print_newline
    mov dx, offset line1
    call print_string

    mov dx, offset line2
    call print_string

    mov dx, offset line3
    call print_string

    mov dx, offset line4
    call print_string

    mov dx, offset line5
    call print_string

    mov dx, offset line6
    call print_string

    mov dx, offset line7
    call print_string

    mov dx, offset line8
    call print_string

    mov dx, offset line9
    call print_string

    mov dx, offset line10
    call print_string

    mov dx, offset line11
    call print_string
    
    mov dx, offset line12
    call print_string

    ; Prompt for choice after the menu is displayed
    mov ah, 1              ; Function to read character
    int 21h
    mov al, ah             ; Store the choice in AL

    ret
display_menu endp

print_string proc
    ; Print string pointed to by DX
    mov ah, 09h
    int 21h
    ret
print_string endp

print_choice proc
    ; Print the user's choice
    mov ah, 02h
    int 21h
    ret
print_choice endp

print_newline proc
    ; Print a new line
    mov ah, 02h
    mov dl, 13  ; Carriage return
    int 21h
    mov dl, 10  ; Line feed
    int 21h
    ret
print_newline endp

end main
