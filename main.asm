.model small
.stack 100h
.data
    ; Menu text data
    line1          db 13, 10, " _____________________________________", 13, 10, "$"
    line2          db "|            Phone Book               |", 13, 10, "$"
    line3          db "|_____________________________________|", 13, 10, "$"
    line4          db "|   |                                 |", 13, 10, "$"
    line5          db "| 1 |  New Contact                    |", 13, 10, "$"
    line6          db "| 2 |  Edit a contact                 |", 13, 10, "$"
    line7          db "| 3 |  Search Contact                 |", 13, 10, "$"
    line8          db "| 4 |  List all Contacts              |", 13, 10, "$"
    line9          db "| 0 |  Exit                           |", 13, 10, "$"
    line10         db "|   |                                 |", 13, 10, "$"
    line11         db "|___|_________________________________|", 13, 10, "$"
    line12         db "Press a key to continue : $"
    choice_msg     db 13, 10, "Your choice is: $"
    choice         db ?


    prompt_msg     db 'Enter password: $'
    error_msg      db 'Incorrect password. Attempts left: $'
    success_msg    db 'Authentication successful. Logged in.$'
    terminate_msg  db 'Access denied. Program terminated.$'
    password       db 1, 2, 3                                                          ; Correct password in numeric form
    input          db 4, ?, ?, ?, ?                                                    ; Input buffer (first byte for length, 3 bytes for input)
    adjusted_input db 3 dup (?)                                                        ; Buffer for adjusted numeric values


.code
main proc
                        mov   ax, @data
                        mov   ds, ax

                        call  user_authentication

    ; Display the menu and get user choice
                        call  display_menu

    ; Print the user's choice message
                        mov   dx, offset choice_msg
                        call  print_string

    ; Output stored choice
                        mov   dl, choice                   ; Move the stored choice into DL
                        call  print_choice

    ; Wait for key press before exiting
                        mov   ah, 1
                        int   21h

    ; Exit program
                        mov   ah, 4Ch
                        int   21h
main endp

display_menu proc
    ; Display each line of the menu
                        mov   dx, offset line1
                        call  print_string

                        mov   dx, offset line2
                        call  print_string

                        mov   dx, offset line3
                        call  print_string

                        mov   dx, offset line4
                        call  print_string

                        mov   dx, offset line5
                        call  print_string

                        mov   dx, offset line6
                        call  print_string

                        mov   dx, offset line7
                        call  print_string

                        mov   dx, offset line8
                        call  print_string

                        mov   dx, offset line9
                        call  print_string

                        mov   dx, offset line10
                        call  print_string

                        mov   dx, offset line11
                        call  print_string
    
                        mov   dx, offset line12
                        call  print_string

    ; Prompt for choice and store it in the choice variable
                        mov   ah, 1                        ; Function to read character
                        int   21h
                        mov   choice, al                   ; Store the choice in choice variable

                        ret
display_menu endp

print_string proc
    ; Print string pointed to by DX
                        mov   ah, 09h
                        int   21h
                        ret
print_string endp
newline proc
                        mov   dl, 13                       ; Carriage return
                        mov   ah, 2                        ; Function to display character
                        int   21h

                        mov   dl, 10                       ; Line feed
                        mov   ah, 2                        ; Function to display character
                        int   21h
                        ret
newline endp


print_choice proc
    ; Print the user's choice
                        mov   ah, 02h
                        int   21h
                        ret
print_choice endp

user_authentication proc
    mov cx, 3                    ; Set the number of attempts to 3

auth_loop:
    ; Display prompt message
    lea dx, prompt_msg
    call print_string

    ; Read 3-character password input
    mov ah, 0Ah                  ; DOS interrupt for reading a string
    lea dx, input                ; Load input buffer address
    int 21h

    ; Adjust ASCII input values
    mov si, offset input + 1     ; Set SI to start of user input (skip length byte)
    mov di, offset adjusted_input

    mov cx, 3                    ; Adjust each character from ASCII to numeric
adjust_loop:
    lodsb                        ; Load next character from input
    sub al, 30h                  ; Convert ASCII to numeric by subtracting 30h
    stosb                        ; Store converted character in adjusted_input
    loop adjust_loop             ; Repeat for each character

    ; Compare adjusted input with predefined password
    mov si, offset adjusted_input ; Set SI to start of adjusted input
    mov di, offset password       ; Set DI to start of predefined password
    mov ax, cx                   ; Backup attempts counter in AX

    mov cx, 3                    ; Compare 3 characters
    repe cmpsb                   ; Compare adjusted input with password
    je auth_success              ; If they match, jump to auth_success

    ; If password is incorrect
    mov cx, ax                   ; Restore attempts counter
    dec cx                       ; Decrement attempts counter

    call newline                 ; New line
    lea dx, error_msg
    call print_string

    ; Display remaining attempts
    mov dl, '0'
    add dl, cl                   ; Convert remaining attempts to ASCII
    mov ah, 2                    ; Display character
    int 21h

    call newline                 ; New line

    ; Check if no attempts are left
    cmp cx, 0
    je auth_terminate            ; If no attempts left, terminate

    jmp auth_loop                ; Retry loop

auth_success:
    call newline                 ; New line
    lea dx, success_msg
    call print_string
    ret                          ; Return to main after successful authentication

auth_terminate:
    call newline
    lea dx, terminate_msg
    call print_string
    mov ax, 4C00h                ; Exit program
    int 21h
user_authentication endp
end main
