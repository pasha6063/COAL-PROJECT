.model small
.stack 100h
.data
    ; Menu text data
    line1               db 13, 10, "   _____________________________________", 13, 10, "$"
    line2               db "  |            Phone Book               |", 13, 10, "$"
    line3               db "  |_____________________________________|", 13, 10, "$"
    line4               db "  |   |                                 |", 13, 10, "$"
    line5               db "  | 1 |  New Contact                    |", 13, 10, "$"
    line6               db "  | 2 |  Edit a contact                 |", 13, 10, "$"
    line7               db "  | 3 |  Show Contact                   |", 13, 10, "$"
    line8               db "  | 4 |  Delete Contact                 |", 13, 10, "$"
    line9               db "  | 0 |  Exit                           |", 13, 10, "$"
    line10              db "  |   |                                 |", 13, 10, "$"
    line11              db "  |___|_________________________________|", 13, 10, "$"
    line12              db 13, 10, "  Press a key to continue : $"
    choice              db ?
    
    
    
    ; Welcome text data
    welcome_text        db 13, 10, "       Welcome to Contact Book Application", 13, 10,13, 10, "$"
    created_by          db "  Created by:", 13, 10,13, 10, "$"
    abrar               db "  Abrar Ali                                 (55843)", 13, 10, "$"
    ghaznfar            db "  Ghazanfar Pasha                            (55590)", 13, 10, "$"
    haroon              db "  Haroon Abbas                              (55780)", 13, 10, "$"
    saad                db "  Saad Ali                                  (56673)", 13, 10,13, 10, "$"
          
          
    delete_contact_msg  db 13, 10, '  Deleting contact...',13, 10, '$'
    delete_success_msg  db '  Contact deleted successfully.',13, 10, '$'
                                                                   
    
    success_msg_edit    db 13, 10,'  Contact edited successfully.$'
    edit_contact_msg    db 13, 10, "  Editing an existing contact...", 13, 10, "$"
                                                                 
    ;Athuntication text data
    prompt_msg          db '  Enter password: $'
    error_msg           db '  Incorrect password. Attempts left: $'
    success_msg         db '  Authentication successful. Logged in.$'
    terminate_msg       db '  Access denied. Program terminated.$'
    defaultPassword     db 'Ali'                                                                          ; Input buffer (first byte for length, 3 bytes for input)
    inputPassword       db 3 dup (?)
       
       
    
    ; Variables to store the name and phone number of the contact
    contact_name        db 30 dup('$')                                                                    ; Reserve 30 bytes for name
    contact_phone       db 12 dup('$')
    
    show_contact_msg    db 13, 10, "  Displaying contact list...", 13, 10, "$"
    contact_name_label  db 13, 10, "  Name: ", '$'
    contact_phone_label db "  Number: ", '$'
    no_contact_msg      db 13, 10,"  No contact saved.", '$'                                              ; Reserve 12 bytes for phone number (11 + null terminator)
        
          
                        
    prompt_name         db 13, 10,13, 10,"  Enter name: $"
    prompt_mobile       db 13, 10,"  Enter mobile number: $"
    invalid_input_msg   db 13, 10,"  Invalid character, please enter digits only : $"
    invalid_length_msg  db 13, 10,"  Invalid mobile number, must be 11 digits: $"
    success_msg_add     db 13, 10,"  Contact added successfully.", 13, 10, "$"

  
    
    exit_message        db 13, 10, "  Thanks for using the existing phone book app.", 13, 10, "$"
    invalid_option_msg  db 13, 10, "  Invalid option. Please enter a valid choice (0-4).", 13, 10, "$"
    add_contact_msg     db 13, 10, "  Adding a new contact...", 13, 10, "$"
    enter_name_msg      db 13, 10, "  Enter contact name: ", "$"
    invalid_name_msg    db 13, 10, "  Invalid name. Please enter a valid name.", 13, 10, "$"
    enter_number_msg    db 13, 10, "  Enter contact number: ", "$"
    invalid_number_msg  db 13, 10, "  Invalid number. Please enter digits only.", 13, 10, "$"
    contact_added_msg   db 13, 10, "  Contact added successfully!", 13, 10, "$"


    ; Buffer for adjusted numeric values

.code

main proc
                             mov  ax, @data
                             mov  ds, ax
                             call print_welcome                    ; Display welcome message
                             call user_authentication              ; Authenticate user

    menu_loop:               
                             call display_menu                     ; Display menu

    ; Read and store user choice
                             mov  ah, 1                            ; Function to read character
                             int  21h
                             mov  choice, al                       ; Store user choice

                             cmp  choice, '1'                      ; Check if choice is '1' (Add Contact)
                             je   add_contact_handler

                             cmp  choice, '2'                      ; Check if choice is '2' (Edit Contact)
                             je   edit_contact_handler

                             cmp  choice, '3'                      ; Check if choice is '3' (Show Contact)
                             je   show_contact_handler

                             cmp  choice, '4'                      ; Check if choice is '4' (Delete Contact)
                             je   delete_contact_handler

                             cmp  choice, '0'                      ; Check if choice is '0' (Exit)
                             je   exit_program                     ; Exit program if choice is '0'

    ; Invalid input handling
                             lea  dx, invalid_option_msg           ; Display invalid option message
                             call print_string
                             jmp  menu_loop                        ; Go back to menu loop

    ; Handlers for each choice
    add_contact_handler:     
                             call add_contact                      ; Call add_contact procedure
                             jmp  menu_loop                        ; Go back to menu

    edit_contact_handler:    
                             call edit_contact                     ; Call edit_contact procedure
                             jmp  menu_loop                        ; Go back to menu

    show_contact_handler:    
                             call show_contact                     ; Call show_contact procedure
                             jmp  menu_loop                        ; Go back to menu

    delete_contact_handler:  
                             call delete_contact                   ; Call delete_contact procedure
                             jmp  menu_loop                        ; Go back to menu

    ; Exit program
    exit_program:            
                             lea  dx, exit_message                 ; Display exit message
                             call print_string
                             mov  ah, 4Ch                          ; Exit program
                             int  21h
main endp

add_contact proc
    ; Prompt for name input
                             mov  dx, offset prompt_name
                             call print_string                     ; Print prompt for name

    ; Initialize the buffer for storing the name
                             lea  si, contact_name
                             mov  cx, 30                           ; Set CX to the size of the name buffer

    input_name_loop:         
                             call get_char                         ; Call get_char to read a character
                             cmp  al, 13                           ; Check if Enter key (Carriage return)
                             je   name_input_complete              ; If Enter is pressed, finish input

    ; Store the character in the contact_name buffer
                             mov  [si], al
                             inc  si                               ; Move to the next buffer position
                             loop input_name_loop                  ; Continue loop until CX is zero

    name_input_complete:     
    ; Null-terminate the string
                             mov  al, '$'
                             mov  [si], al

    ; Prompt for mobile number input
                             mov  dx, offset prompt_mobile
                             call print_string                     ; Print prompt for mobile number
                             call get_mobile_number                ; Call procedure to get valid mobile number

    ; Show success message
                             mov  dx, offset success_msg_add
                             call print_string                     ; Print success message

                             ret
add_contact endp

    ; Mobile number input procedure
get_mobile_number proc
    ; Initialize the buffer for storing the mobile number
                             mov  si, offset contact_phone         ; Point SI to mobile_number buffer
                             mov  cx, 0                            ; Clear CX (for counting characters)

    input_mobile_loop:       
                             call get_char                         ; Call get_char to read a character
                             cmp  al, 13                           ; Check if Enter key (Carriage return)
                             je   validate_mobile                  ; If Enter is pressed, validate the number

    ; Check if the character is a digit (ASCII values for '0' to '9' are 30h to 39h)
                             cmp  al, '0'
                             jl   invalid_char                     ; If less than '0', it's an invalid character
                             cmp  al, '9'
                             jg   invalid_char                     ; If greater than '9', it's an invalid character

    ; If valid digit, store it in the mobile number buffer
                             mov  [si], al
                             inc  si                               ; Move to the next buffer position
                             inc  cx                               ; Increment character count

    ; Check if we've reached 11 digits (valid mobile number length)
                             cmp  cx, 11
                             je   validate_mobile                  ; If 11 digits entered, validate the mobile number

    ; Continue asking for mobile number if less than 11 digits
                             jmp  input_mobile_loop

    invalid_char:            
    ; Display error message for invalid character input
                             mov  dx, offset invalid_input_msg
                             call print_string                     ; Print "Invalid character, please enter a digit."

    ; Reset buffer and start input again
                             mov  si, offset contact_phone         ; Reset the buffer pointer
                             mov  cx, 0                            ; Reset the character counter
                             jmp  input_mobile_loop                ; Restart input

    validate_mobile:         
    ; Mobile number validation (check length and content)
                             cmp  cx, 11                           ; Validate if exactly 11 digits entered
                             je   mobile_valid                     ; If valid, proceed to next step
    ; If invalid, display error and ask for input again
                             mov  dx, offset invalid_length_msg
                             call print_string                     ; Print "Invalid mobile number, must be 11 digits."
                             jmp  get_mobile_number                ; Restart mobile number input

    mobile_valid:            
    ; Proceed with valid mobile number
    ; You can add the logic to store the contact here
                             ret
get_mobile_number endp

get_char proc
    ; Function to read a single character from user input
                             mov  ah, 01h                          ; DOS function to read character from standard input
                             int  21h                              ; Call DOS interrupt
                             ret
get_char endp

edit_contact proc
    
    ; Check if the first character of the contact name is '$'
                             mov  al, [contact_name]
                             cmp  al, '$'
                             je   no_contact_to_edit
    
    
    ; Display edit contact message
                             lea  dx, edit_contact_msg
                             call print_string



    ; Store '$' in contact_name array to delete existing contact
                             lea  si, contact_name
                             mov  cx, 30                           ; Size of the contact_name buffer

    store_dollar_name_edit:  
                             mov  [si], '$'
                             inc  si
                             loop store_dollar_name_edit

    ; Store '$' in contact_phone array to delete existing contact
                             lea  si, contact_phone
                             mov  cx, 12                           ; Size of the contact_phone buffer

    store_dollar_phone_edit: 
                             mov  [si], '$'
                             inc  si
                             loop store_dollar_phone_edit

    ; Prompt for new name input
                             mov  dx, offset prompt_name
                             call print_string                     ; Print prompt for name

    ; Initialize the buffer for storing the new name
                             lea  si, contact_name
                             mov  cx, 30                           ; Set CX to the size of the name buffer

    input_name_loop_edit:    
                             call get_char                         ; Call get_char to read a character
                             cmp  al, 13                           ; Check if Enter key (Carriage return)
                             je   name_input_complete_edit         ; If Enter is pressed, finish input

    ; Store the character in the contact_name buffer
                             mov  [si], al
                             inc  si                               ; Move to the next buffer position
                             loop input_name_loop_edit             ; Continue loop until CX is zero

    name_input_complete_edit:
    ; Null-terminate the string
                             mov  al, '$'
                             mov  [si], al

    ; Prompt for new mobile number input
                             mov  dx, offset prompt_mobile
                             call print_string                     ; Print prompt for mobile number
                             call get_mobile_number                ; Call procedure to get valid mobile number

    ; Show success message
                             mov  dx, offset success_msg_edit
                             call print_string                     ; Print success message

                             ret

    no_contact_to_edit:      
                             lea  dx, no_contact_msg
                             call print_string
                             ret
edit_contact endp


show_contact proc
 
    ; Check if the first character of the contact name is '$'
                             mov  al, contact_phone
                             cmp  al, '$'
                             je   no_contact_saved
    ; Display show contact message
                             lea  dx, show_contact_msg
                             call print_string



    ; Display contact name
                             lea  dx, contact_name_label
                             call print_string
                             lea  dx, contact_name
                             call print_string

    ; New line
                             call newline

    ; Display contact phone number
                             lea  dx, contact_phone_label
                             call print_string
                             lea  dx, contact_phone
                             call print_string

                             ret

    no_contact_saved:        
                             lea  dx, no_contact_msg
                             call print_string
                             ret
show_contact endp




delete_contact proc
    
    ; Check if the first character of the contact name is '$'
                             mov  al, [contact_name]
                             cmp  al, '$'
                             je   no_contact_to_delete
    
    
    ; Display delete contact message
                             lea  dx, delete_contact_msg           ; Display delete contact message
                             call print_string

    
    ; Store '$' in contact_name array
                             lea  si, contact_name
                             mov  cx, 30                           ; Size of the contact_name buffer

    store_dollar_name:       
                             mov  [si], '$'
                             inc  si
                             loop store_dollar_name

    ; Store '$' in contact_phone array
                             lea  si, contact_phone
                             mov  cx, 12                           ; Size of the contact_phone buffer

    store_dollar_phone:      
                             mov  [si], '$'
                             inc  si
                             loop store_dollar_phone

    ; Show success message
                             lea  dx, delete_success_msg
                             call print_string
                             ret

    no_contact_to_delete:    
                             lea  dx, no_contact_msg
                             call print_string
                             ret
delete_contact endp



display_menu proc
    ; Display every line of the menu
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

                             ret
display_menu endp

print_string proc
    ; Print string pointed to by DX
                             mov  ah, 09h
                             int  21h
                             ret
print_string endp

print_welcome proc
    ; Display welcome text
                             mov  dx, offset welcome_text
                             call print_string

                             mov  dx, offset created_by
                             call print_string

                             mov  dx, offset abrar
                             call print_string

                             mov  dx, offset ghaznfar
                             call print_string

                             mov  dx, offset haroon
                             call print_string

                             mov  dx, offset saad
                             call print_string

                             ret
print_welcome endp

newline proc
                             mov  dl, 13                           ; Carriage return
                             mov  ah, 2                            ; Function to display character
                             int  21h

                             mov  dl, 10                           ; Line feed
                             mov  ah, 2                            ; Function to display character
                             int  21h
                             ret
newline endp

print_choice proc
    ; Print the user's choice
                             mov  ah, 02h
                             int  21h
                             ret
print_choice endp

read_string proc
    ; Read string from user input into buffer pointed by DX
                             mov  ah, 0Ah
                             int  21h
                             ret
read_string endp

user_authentication proc
                             mov  bx, 3                            ; Set the number of attempts to 3

    auth_loop:               
    ; Reset input pointer to the start of the inputPassword buffer
                             lea  si, inputPassword

    ; Display prompt message
                             lea  dx, prompt_msg
                             call print_string

    ; Collect each character one by one
                             mov  ah, 1                            ; Function to read character from input
                             int  21h
                             mov  [si], al                         ; Store first character
                             inc  si                               ; Move to next position in buffer

                             int  21h
                             mov  [si], al                         ; Store second character
                             inc  si                               ; Move to next position in buffer

                             int  21h
                             mov  [si], al                         ; Store third character
                             call newline                          ; New line after reading input

    ; Reset SI and DI for comparison
                             lea  si, inputPassword                ; Point SI to start of input buffer
                             lea  di, defaultPassword              ; Point DI to start of default password

    ; Compare each character in forward order
                             mov  cx, 3                            ; Number of characters to compare
    compare_loop:            
                             mov  al, [si]                         ; Load input character
                             cmp  al, [di]                         ; Compare with password character
                             jne  incorrect_password               ; Jump if not equal
                             inc  si                               ; Move to next input character
                             inc  di                               ; Move to next password character
                             loop compare_loop                     ; Loop until all characters are compared

    ; If all characters match, go to success
                             jmp  auth_success

    incorrect_password:      
                             dec  bx                               ; Decrement attempts counter
                             call newline                          ; New line
                             lea  dx, error_msg
                             call print_string

    ; Display remaining attempts
                             mov  dl, '0'
                             add  dl, bl                           ; Convert remaining attempts to ASCII
                             mov  ah, 2                            ; Display character
                             int  21h

                             call newline                          ; New line
                             cmp  bx, 0                            ; Check if attempts exhausted
                             je   terminate_program                ; Jump to termination if no attempts left
                             jmp  auth_loop                        ; Retry authentication

    terminate_program:       
                             lea  dx, terminate_msg                ; Display termination message
                             call print_string
                             mov  ah, 4Ch                          ; Exit program
                             int  21h

    auth_success:            
                             call newline
                             lea  dx, success_msg
                             call print_string
                             ret
user_authentication endp

end main
