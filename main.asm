.model small
.stack 100h
.data
    ; Menu text data
    line1         db 13, 10, " _____________________________________", 13, 10, "$"
    line2         db "|            Phone Book               |", 13, 10, "$"
    line3         db "|_____________________________________|", 13, 10, "$"
    line4         db "|   |                                 |", 13, 10, "$"
    line5         db "| 1 |  New Contact                    |", 13, 10, "$"
    line6         db "| 2 |  Edit a contact                 |", 13, 10, "$"
    line7         db "| 3 |  Search Contact                 |", 13, 10, "$"
    line8         db "| 4 |  List all Contacts              |", 13, 10, "$"
    line9         db "| 0 |  Exit                           |", 13, 10, "$"
    line10        db "|   |                                 |", 13, 10, "$"
    line11        db "|___|_________________________________|", 13, 10, "$"
    line12        db "Press a key to continue : $"
    choice_msg    db 13, 10, "Your choice is: $"
    choice        db ?


    prompt_msg    db "Enter password: $"
    error_msg     db "Incorrect password. Attempts left: $"
    success_msg   db "Access granted.$"
    terminate_msg db "Access denied. Program terminated.$"
    input         db 4, ?, 3 dup('?')                                                 ; Buffer for user input (4 bytes: length + 3 characters)
    password      db "123"


.code
main proc
                        mov  ax, @data
                        mov  ds, ax

                        call user_authentication

    ; Display the menu and get user choice
                        call display_menu

    ; Print the user's choice message
                        mov  dx, offset choice_msg
                        call print_string

    ; Output stored choice
                        mov  dl, choice                  ; Move the stored choice into DL
                        call print_choice

    ; Wait for key press before exiting
                        mov  ah, 1
                        int  21h

    ; Exit program
                        mov  ah, 4Ch
                        int  21h
main endp

display_menu proc
    ; Display each line of the menu
                        mov  dx, offset line1
                        call print_string

                        mov  dx, offset line2
                        call print_string

                        mov  dx, offset line3
                        call print_string

                        mov  dx, offset line4
                        call print_string

                        mov  dx, offset line5
                        call print_string

                        mov  dx, offset line6
                        call print_string

                        mov  dx, offset line7
                        call print_string

                        mov  dx, offset line8
                        call print_string

                        mov  dx, offset line9
                        call print_string

                        mov  dx, offset line10
                        call print_string

                        mov  dx, offset line11
                        call print_string
    
                        mov  dx, offset line12
                        call print_string

    ; Prompt for choice and store it in the choice variable
                        mov  ah, 1                       ; Function to read character
                        int  21h
                        mov  choice, al                  ; Store the choice in choice variable

                        ret
display_menu endp

print_string proc
    ; Print string pointed to by DX
                        mov  ah, 09h
                        int  21h
                        ret
print_string endp

print_choice proc
    ; Print the user's choice
                        mov  ah, 02h
                        int  21h
                        ret
print_choice endp

user_authentication proc
                        mov  cx, 3                       ; Set the number of attempts to 3

    auth_loop:          
    ; Display prompt message
                        mov  dx, offset prompt_msg
                        call print_string
                        call newline                     ; Move to new line after prompt

    ; Read user input (3 characters for password)
                        mov  si, offset input            ; Set SI to input buffer

    ; Loop to read 3 characters and store in the input array
                        mov  bx, 3                       ; Password length
    read_chars:         
                        mov  ah, 1                       ; Function to read single character
                        int  21h
                        add  al, '0'                     ; Convert input to ASCII
                        mov  [si], al                    ; Store character in input buffer
                        inc  si                          ; Move to next position in buffer
                        dec  bx                          ; Decrement character count
                        jnz  read_chars                  ; Loop until all characters are read

    ; Reset SI to start of input and compare with password
                        mov  si, offset input
                        mov  di, offset password
                        mov  cx, 3                       ; Length of password for comparison
                        repe cmpsb                       ; Compare input with password
                        jne  incorrect                   ; If password is incorrect, jump to `incorrect`

    success:            
                        mov  dx, offset success_msg
                        call print_string
                        call newline
                        ret

    incorrect:          
    ; Password incorrect, decrement attempts and show error message
                        dec  cx
                        cmp  cx, 0
                        je   terminate                   ; If attempts reach 0, terminate

    ; Display error message
                        mov  dx, offset error_msg
                        call print_string
                        call newline

    ; Display remaining attempts
                        mov  al, cl
                        add  al, '0'                     ; Convert remaining attempts to ASCII
                        mov  dl, al
                        call print_choice                ; Display remaining attempts
                        call newline                     ; New line after attempt count

                        jmp  auth_loop                   ; Retry loop

    terminate:          
                        mov  dx, offset terminate_msg
                        call print_string
                        call newline
                        mov  ah, 4Ch                     ; DOS interrupt to exit program
                        int  21h
user_authentication endp

end main
