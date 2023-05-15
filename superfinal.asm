.dseg                ; prepnuti do pameti dat 1
.org 0x100           ; od adresy 0x100 (adresy 0 - 0x100 nepouzivejte)

flag: .byte 1        ; rezervovani mista pro 1 bajt

.cseg                ; prepnuti do pameti programu
; podprogramy pro praci s displejem
.org 0x1000
.include "printlib.inc"

; Zacatek programu - po resetu
.org 0
    jmp	start
.org 0x16            ; 2
    jmp interrupt

.org 0x100

start:
    ; Inicializace displeje
    call init_disp
    ; Inicializace preruseni od casovace
    call init_int
    
    call init_button
    
    //////////////////////////////
    
    ldi r18, 0       ; 3
    sts flag, r18

    ldi r17, 0
    //ldi r16, '0'
    ldi r18, '0'
    //call show_char
    
    ldi r22 , 0
    ldi r23 , 0
	
main_loop:
    
    ////////////////////////////////
    lds r16, ADCSRA        
    ori r16, (1<<ADSC)     
    sts ADCSRA, r16
    
loop:
    lds r16 , ADCSRA 
    andi r16 , ( 1 << ADSC )
    breq button_pressed

    continue:
    ////////////////////////////////
    
    lds r20, flag
    cpi r20, 0       ; nacteni a otestovani hodnoty flag-u
    breq main_loop   ; pokud neni flag -> navrat na zacatek
                     ; je flag
    ldi r20, 0       ; vycisteni flag-u
    sts flag, r20

    ; akce provedena 1x za sekundu 4
    
    
    inc r18
    mov r16 , r18 
    
    call show_char

    jmp main_loop

end: jmp end
    
print_data:
    mov r16 , r22
    ldi r17 , 3
    call show_char
    
    ldi r24 , '0'
    add r16 , r24
    
button_pressed:
    
    lds r21 , ADCH
    andi r21 , 0b11110000
    
    cpi r21 , 0b10010000 
    breq select_pressed // select pressed
    
    cpi r21 , 0b01100000 
    breq left_pressed // left pressed
    
    cpi r21 , 0b00000000 
    breq right_pressed // right pressed
    
    jmp continue // loop
    
select_pressed:
    mov r22 , r16
    ldi r16 , '1'
    ldi r17 , 5
    call show_char
    mov r16 , r22
    ldi r17, 0
    jmp continue
left_pressed:
    mov r22 , r16
    ldi r16 , '2'
    ldi r17 , 5
    call show_char
    mov r16 , r22
    ldi r17, 0
    jmp continue
right_pressed:
    mov r22 , r16
    ldi r16 , '3'
    ldi r17 , 5
    call show_char
    mov r16 , r22
    ldi r17, 0
    jmp continue
    
////////////////////////////////////////////////////////

init_button:
    
    push r16
    ; povoleni AD prevodniku (nastaveni bitu ADEN v pameti na adrese ADCSRA bez ovlivneni ostatnich bitu) 1
    lds r16, ADCSRA
    ori r16, (1<<ADEN); 2
    sts ADCSRA, r16
    ; nastaveni referencniho napeti (0b01<<REFS0)
    ; nastaveni zarovnani vystupu vlevo (1<<ADLAR); 3
    ldi r16, (0b01<<REFS0) | (1<<ADLAR); 4
    sts ADMUX, r16

    pop r16
    
    ret
    
init_int:            ; 5
    push r18
    cli ; globalni zakazani preruseni

    ; vycisteni aktualni hodnoty citace TCNT1 (aby prvni sekunda nezacala nekde "od pulky")
    clr r18
    ; Neprehazujte poradi nahravani TCNT1H a TCNT1L - hodnota by se nemusela spravne ulozit!
    sts TCNT1H, r18
    sts TCNT1L, r18

    ; povoleni preruseni ve chvili, kdy citac TCNT1 dosahne hodnoty OCR1A
    ldi r18, (1<<OCIE1A)
    sts TIMSK1, r18

    ; nastaveni cisteni citace TCNT1 ve chvili, kdy dosahne hodnoty OCR1A (1<<WGM12)
    ; nastaveni preddelicky na 1024 (0b101<<CS10 - bity CS12, CS11 a CS10 jsou za sebou)
    ldi r18, (1<<WGM12) | (0b010<<CS10)
    sts TCCR1B, r18

    ; nastaveni OCR1A, tj. vysledne frekvence preruseni
    ; frekvence preruseni = frekvence cipu 328P / preddelicka / (OCR1A+1)
    ; frekvence cipu 328P je 16 MHz, tj. 16000000
    ; preddelicka je nastavena na 1024
    ; frekvenci preruseni chceme na 1 Hz
    ; OCR1A = (frekvence cipu 328P / preddelicka / frekvence preruseni) - 1
    ; OCR1A = (16000000 / 1024 / 1) - 1
    ; OCR1A = 15624
    ; 16bitovou hodnotu je treba nastavit do dvou registru OCR1AH:OCR1AL
    ; 15624 = 61 * 256 + 8
    ; Neprehazujte poradi nahravani OCR1AH a OCR1AL - hodnota by se nemusela spravne ulozit!
    ldi r18, 61
    sts OCR1AH, r18
    ldi r18, 8
    sts OCR1AL, r18

    ; zakazani preruseni od tlacitek
    clr r18
    out EIMSK, r18

    sei ; globalni povoleni preruseni
    pop r18
    ret

interrupt:           ; 6
    ; uklid registru a SREG
    push r18
    in r18, SREG
    push r18

    ; nastav flag
    ldi r18, 1
    sts flag, r18

    ; obnoveni SREG a registru
    pop r18
    out SREG, r18
    pop r18
    reti             ; 7
