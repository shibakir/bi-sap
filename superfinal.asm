.cseg ; nasledujici umistit do pameti programu (implicitni) 
; Zacatek programu - po resetu 
.org 0 
    jmp start 
.include "printlib.inc" 
     
; Zacatek programu - hlavni program 
.org 0x100 
 
write_text: 
    ldi r16, 's' 
    ldi r17, 4 
    call show_char 
    ldi r16, 't' 
    ldi r17, 5 
    call show_char 
    ldi r16, 'o' 
    ldi r17, 6 
    call show_char 
    ldi r16, 'p' 
    ldi r17, 7 
    call show_char 
    ldi r16, 'w' 
    ldi r17, 8 
    call show_char 
    ldi r16, 'a' 
    ldi r17, 9 
    call show_char 
    ldi r16, 't' 
    ldi r17, 10 
    call show_char 
    ldi r16, 'c' 
    ldi r17, 11 
    call show_char 
    ldi r16, 'h' 
    ldi r17, 12 
    call show_char 
     
init_button: 
    push r16 
    lds r16, ADCSRA 
    ori r16, (1<<ADEN) 
    sts ADCSRA, r16 
    ldi r16, (0b01<<REFS0) | (1<<ADLAR) 
    sts ADMUX, r16 
    pop r16 
    ret 
     
start: 
    call init_disp 
    call init_button 
    call write_text 
     
    ldi r18, 0 ; states 
        ; 0 - PAUSE 
        ; 1 - PLAY 
      
    ldi r19, 0 ; delay sec 1 
    ldi r20, 0 ; delay sec 10 
    ldi r21, 0 ; sec 1 
    ldi r22, 0 ; sec 10 
    ldi r23, 0 ; min 1 
    ldi r24, 0 ; min 10 
     
read_button: 
    lds r16, ADCSRA 
    ori r16, (1<<ADSC) 
    sts ADCSRA, r16 
    call wait 
 
cycle: 
    lds r16, ADCSRA 
    andi r16, (1<<ADSC) 
    breq continue 
    jmp cycle 
     
continue: 
    lds r16, ADCH 
    andi r16, 0b11110000 
    cpi r16, 0b00010000 
    breq play 
    cpi r16, 0b00110000 
    breq pause 
    cpi r16, 0b00000000 
    breq reset 
    jmp no_button 
 
play: 
    ldi r16, 'P' 
    ldi r17, 0 
    call show_char 
    ldi r16, 'L' 
    ldi r17, 1 
    call show_char 
    ldi r18, 1 ; set status as PLAY 
    ; increase data 
    inc r19 
    cpi r19, 10 
    brne continue_play 
    ldi r19, 0 
    inc r20 
    cpi r20, 10 
    brne continue_play 
    ldi r20, 0 
    inc r21 
    cpi r21, 10 
    brne continue_play 
    ldi r21, 0 
    inc r22 
    cpi r22, 6 
    brne continue_play 
    ldi r22, 0 
    inc r23 
    cpi r23, 10 
    brne continue_play 
    ldi r23, 0 
    inc r24 
    cpi r24, 6 
    brne continue_play 
    ldi r24, 0 
continue_play: 
    call show_time 
    rjmp read_button 
 
pause: 
    ldi r16, 'P' 
    ldi r17, 0 
    call show_char 
    ldi r16, 'A' 
    ldi r17, 1 
    call show_char 
    ldi r18, 0 ; set status as PAUSE 
    call show_time 
    rjmp read_button 
 
reset: 
    ldi r16, 'R' 
    ldi r17, 0 
    call show_char 
    ldi r16, 'E' 
    ldi r17, 1 
    call show_char 
    ldi r18, 0 ; states     
    ldi r19, 0 ; delay sec 1 
    ldi r20, 0 ; delay sec 10 
    ldi r21, 0 ; sec 1 
    ldi r22, 0 ; sec 10 
    ldi r23, 0 ; min 1 
    ldi r24, 0 ; min 10 
    call show_time 
    rjmp read_button 
 
no_button: 
    ldi r16, '-' 
    ldi r17, 0 
    call show_char 
    ldi r16, ' ' 
    ldi r17, 1 
    call show_char 
    cpi r18, 0 
    breq continue_no_button 
    ; increase data 
    inc r19 
    cpi r19, 10 
    brne continue_no_button 
    ldi r19, 0 
    inc r20 
    cpi r20, 10 
    brne continue_no_button 
    ldi r20, 0 
    inc r21 
    cpi r21, 10 
    brne continue_no_button 
    ldi r21, 0 
    inc r22 
    cpi r22, 6 
    brne continue_no_button 
    ldi r22, 0 
    inc r23 
    cpi r23, 10 
    brne continue_no_button 
    ldi r23, 0 
    inc r24 
    cpi r24, 6 
    brne continue_no_button 
    ldi r24, 0 
continue_no_button: 
    call show_time 
    rjmp read_button 
     
wait:  
    ldi r25, 0 
time_cycle: 
    ldi r26, 180 
    cek2: ldi r27, 240 
    cek: dec r27 
    brne cek 
    dec r26 
    brne cek2 
    inc r25 
    cpi r25, 1 
    brne time_cycle 
    ret 
 
show_time: 
    ; minutes 
    mov r16, r24 
    ldi r25, 48 
    add r16, r25 
    ldi r17, 0x40 
    call show_char 
     
    mov r16, r23 
    ldi r25, 48 
    add r16, r25 
    ldi r17, 0x41 
    call show_char 
     
    ldi r16, ':' 
    ldi r17, 0x42 
    call show_char 
     
    ; seconds 
    mov r16, r22 
    ldi r25, 48 
    add r16, r25 
    ldi r17, 0x43 
    call show_char
    
    mov r16, r21    
    ldi r25, 48
    add r16, r25    
    
    ldi r17, 0x44
    call show_char  
    
    ldi r16, '.'    
    ldi r17, 0x45
    call show_char    
    ; delay seconds   
    mov r16, r20
    ldi r25, 48    
    add r16, r25
    
    ldi r17, 0x46    
    call show_char
    mov r16, r19
    ldi r25, 48    
    add r16, r25
    ldi r17, 0x47    
    call show_char
    ret
    
  end: jmp end
