.model small
.stack 100h
.data
    fname         db 'contacts.txt', 0
    handle        dw ?

    ; Menu's main options
    welcome       db 10,13,'|>~~~~~~~~~~~~~~~~~~~~~~CONTACT MANAGEMENT SYSTEM~~~~~~~~~~~~~~~~~~~~~~~~<|'
                  db 10,13,'|            RIPHAH INTERNATIONAL UNIVERSTY |'
                  db 10,13,'|            COURSE:                                                   |'
                  db 10,13,'|                    COMPUTER ORGANIZATION AND ASSEMBLY LANGUAGE       |'
                  db 10,13,'|            INSTRUCTOR:                                               |'
                  db 10,13,'|                             SIR PASHA                        |'
                  db 10,13,'|                                   BSSE                           |'
                  db 10,13,'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                  db 10,13,10,13,'Press Enter to move forward>>>>>>$'

    heading       db 10,13,10,13,'                |**********CONTACT MANAGEMENT SYSTEM***********|'
                  db 10,13,'                |0. Exit                                        |'
                  db 10,13,'                |1. Add New Contact                             |'
                  db 10,13,'                |2. View Contact Details                        |'
                  db 10,13,'                |3. Update Contact                              |'
                  db 10,13,'                |4. Delete Contact                              |'
                  db 10,13,'                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~$'
                  
    inputmsg      db 10,13,10,13,'Choose an option >> $'
      
    ; Data details
    strName       db 'Enter Contact Name: $'
    strPhone      db 'Enter Contact Phone: $'
    strEmail      db 'Enter Contact Email: $'

    ; Temporary storage for contact data
    contactName   db 28 dup(' '), 0
    contactPhone  db 15 dup(' '), 0
    contactEmail  db 30 dup(' '), 0

    ; Display messages
    exitmsg       db 10,13,10,13, '               ~~~~~~~~~~~~~CONTACT MANAGEMENT SYSTEM CLOSED~~~~~~~~~~~~~~~ $'
    addmsg        db 10,13, '               **ADD NEW CONTACT** $'
    detailmsg     db 10,13, '               **CONTACT DETAILS** $'
    deletemsg     db 10,13, '               **DELETE CONTACT**  $'
    updatemsg     db 10,13, '               **UPDATE CONTACT**  $'

    delete_done   db 10,13, 'Contact Deleted Successfully $'
    update_done   db 10,13, 'Contact Updated Successfully $'
    add_done      db 10,13, 'Contact Added Successfully $'
    invalidoption db 10,13, 'Invalid option!$'
    not_found     db 10,13, 'Contact not found!$'

.code
main proc
    mov  ax,@data
    mov  ds,ax

    ; Displaying menu
    more: 
        lea  dx,welcome
        mov  ah,09
        int  21h

        mov  ah,01
        int  21h
        cmp  al,13
        jne  more

    Invalid: 
        lea  dx,heading
        call string_output

        ; Display the input prompt
        lea  dx,inputmsg
        mov  ah,09
        int  21h

        mov  ah,01h               ; Taking user input
        int  21h
        sub  al,30h

        cmp  al,0                 ; Exit the program
        je   ext

        cmp  al,1                 ; Add new contact
        je   write_data

        cmp  al,2                 ; View contact details
        je   read_data

        cmp  al,3                 ; Update contact
        je   update_data

        cmp  al,4                 ; Delete contact
        je   delete_data

        lea  dx,invalidoption
        mov  ah,09
        int  21h
        j ne  Invalid

    write_data: 
        lea  dx,addmsg
        mov  ah,09
        int  21h

        call input_form_user
        call writing_in_file

        lea  dx,add_done
        mov  ah,09
        int  21h
        jmp  ext

    read_data : 
        lea  dx, detailmsg
        mov  ah,09
        int 21h
        call new_line

        lea  dx,strName
        call string_output
        lea  di,contactName
        call string_input
        call read_from_file
        jmp  ext

    update_data: 
        lea  dx, updatemsg
        mov  ah,09
        int  21h

        call new_line
        lea  dx,strName
        call string_output
        lea  di,contactName
        call string_input
        call update_in_file

        lea  dx,update_done
        mov  ah,09
        int  21h
        jmp  ext

    delete_data: 
        lea  dx, deletemsg
        mov  ah,09
        int  21h
        call new_line

        lea  dx,strName
        call string_output
        lea  di,contactName
        call string_input

        call delete_from_file

        lea  dx, delete_done
        mov  ah,09
        int  21h

    ext: 
        lea  dx,exitmsg
        mov  ah,09
        int  21h

        mov  ah,4ch
        int  21h
main endp

; Procedures for input/output operations
string_input proc
    mov  cx,0
aa: 
    mov  ah,01h
    int  21h
    cmp  al,13
    je   exit
    mov  [di],al
    inc  cx
    inc  di
    jmp  aa
exit: 
    ret
string_input endp

string_output proc
    mov  ah,09h
    int  21h
    ret
string_output endp

file_output proc
    mov  ah,40h
    mov  bx,handle
    int  21h
    ret
file_output endp

file_input proc
    mov  ah,3fh
    mov  bx,handle
    int  21h
    ret
file_input endp

new_line proc
    mov  dl,10
    mov  ah,02h
    int  21h
    mov  dl,13
    mov  ah,02h
    int  21h
    ret
new_line endp

; Procedures for file operations
read_from_file proc
    ; Open existing file
    lea  dx,fname
    mov  ah,3dh
    mov  al,0
    int  21h
    mov  handle,ax

    ; Read contact details from file
    mov  cx,29d
    lea  dx,contactName
    call file_input

    ; Display contact details
    lea  dx,contactName
    call string_output
    call new_line

    ; Close file
    mov  dx,handle
    mov  ah,3eh
    int  21h
    ret
read_from_file endp

delete_from_file proc
    ; Open existing file
    lea  dx,fname
    mov  ah,3dh
    mov  al,0
    int  21h
    mov  handle,ax

    ; Read contact details from file
    mov  cx,29d
    lea  dx,contactName
    call file_input

    ; Check if contact exists
    lea  si,contactName
    lea  di,contactName
    mov  cx,29d
    repe cmpsb
    jne  not_found

    ; Delete contact from file
    mov  cx,29d
    lea  dx,contactName
    call file_output

    ; Close file
    mov  dx,handle
    mov  ah,3eh
    int  21h
    ret

not_found: 
    lea  dx,not_found
    mov  ah,09
    int  21h
    ret
delete_from_file endp

update_in_file proc
    ; Open existing file
    lea  dx,fname
    mov  ah,3dh
    mov  al,0
    int  21h
    mov  handle,ax

    ; Read contact details from file
    mov  cx,29d
    lea  dx,contactName
    call file_input

    ; Check if contact exists
    lea  si,contactName
    lea  di,contactName
    mov  cx,29d
    repe cmpsb
    jne  not_found

    ; Update contact details
    lea  dx,contactName
    call string_output
    call new_line

    ; Close file
    mov  dx,handle
    mov  ah,3eh
    int  21h
    ret

not_found: 
    lea  dx,not_found
    mov  ah,09
    int  21h
    ret
update_in_file endp

writing_in_file proc
    ; Open existing file
    lea  dx,fname
    mov  ah,3dh
    mov  al,1
    int  21h
    mov  handle,ax

    ; Write contact details to file
    mov  cx,29d
    lea  dx,contactName
    call file_output

    ; Close file
    mov  dx,handle
    mov  ah,3eh
    int  21h
    ret
writing_in_file endp

input_form_user proc
    ; Input contact details from user
    lea  dx,strName
    call string_output
    lea  di,contactName
    call string_input

    lea  dx,strPhone
    call string_output
    lea  di,contactPhone
    call string_input

    lea  dx,strEmail
    call string_output
    lea  di,contactEmail
    call string_input

    ret
input_form_user endp

end main