
.model small
.stack 100h
.data
 
    number      db  215d    ; variabila 'number' memoram numarul noroc
 
    ; declaratii pentru a adauga LineBreak in siruri
    CR          equ 13d
    LF          equ 10d
 
    ;Mesaje de tip string utilizate in aplicatie
    prompt      db  CR, LF,'Ghiceste numarul meu norocos : $'
    lessMsg     db  CR, LF,'Numarul meu norocos este mai mic ','$'
    moreMsg     db  CR, LF,'Numarul meu norocos este mai mare ', '$'
    equalMsg    db  CR, LF,'Ai ghicit!', '$'
    overflowMsg db  CR, LF,'Ai depasit intervalul [0:250]!', '$'
    retry       db  CR, LF,'Vrei sa incercam dinou? [y/n] ? ' ,'$'
 
    guess       db  0d      ;variabila 'guess; in care stocam ce a introdus user-ul
    errorChk    db  0d      ;variabila 'errorChk' in care verificam daca numarul introdus este in intervalul dorit
 
    param       label Byte
 
.code     
           
start:
 
    ; Punem registrii si variabilele pe 0h
    MOV ax, 0h
    MOV bx, 0h
    MOV cx, 0h
    MOV dx, 0h
 
    MOV BX, OFFSET guess    ;   setam adresa variabilei 'guess' in BX
    MOV BYTE PTR [BX], 0d   ;  setam 'guess' la 0 (decimal)
 
    MOV BX, OFFSET errorChk ;    setam adresa variabilei 'errorChk' in BX
    MOV BYTE PTR [BX], 0d   ;    setam 'errorChk' la 0 (decimal)
    ; --- END resting
 
    MOV ax, @data           ;  setam adresa data in AX
    MOV ds, ax              ;   setam data segmentul la valoarea lui AX
    MOV dx, offset prompt   ;  incarcam adresa mesajului 'prompt' in DX
 
    MOV ah, 9h              ;  scriem sir pe STDOUT ( pentru intreruperi DOS) 
    INT 21h                 ;   setam DOS int 21h ( pentru intreruperi DOS ) 
 
    MOV cl, 0h              ;setam CL la 0 (Counter) 
    MOV dx, 0h              ;   setam DX la 0 ( registru de date folosit pentru a stroca datele introduse de user)
 
;  Incepem sa citim datele introduse de user
while:
 
    CMP     cl, 5d          ; comparam CL cu 10d ( 5 este numarl maxid de cifre permise )
    JG      endwhile        ;  daca CL > 5 atunci sarim la 'endwhile' 
 
    MOV     ah, 1h          ;  citim caracterul din STDIN in AL ( pentru intreruperi DOS ) 
    INT     21h             ; Dos int 21h ( pentru intreruperi DOS ) 
 
    CMP     al, 0Dh         ;  comparam valoarea introdusa cu 0Dh care reprezinta tasta Enter in codul ASCII
    JE      endwhile        ;    daca AL = 0Dh , inseamna ca a fost apasata tasta enter deci sarim la 'endwhile'
 
    SUB     al, 30h         ;  substragem 30h din niput in codul ASCII si obtinem numarul actual ( deoarece in codul ASCII 30 h = numarul 0 )
    MOV     dl, al          ;  mutam valoarea introdusa in DL 
    PUSH    dx              ; impingem DL in stiva , ca sa citim urmatorul input
    INC     cl              ; incrementam CL ( counter ) 
 
    JMP while               ;    sarim inapoi la label-ul 'while' daca este ajuns
 
endwhile:
; -- terminam citirea de la tastatura 
 
    DEC cl                  ; decrementam CL cu 1 pentru a reduce incrementarea facuta la ultima iteratie
 
    CMP cl, 02h             ; comparam CL cu 02 , deoarece numai 3 numere pot fi acceptate in raza 
    JG  overflow            ;  daca CL ( numarul introdus de caractere ) e mai mare decat 3 atunci sarim la 'overflow'
 
    MOV BX, OFFSET errorChk ;  obtinem adresa variabilei 'errorChk' in BX
    MOV BYTE PTR [BX], cl   ;  setam valoarea 'errorChk' la CL 
 
    MOV cl, 0h              ;  setam CL la 0 , deoarece counter-ul este folosit in urmatoarea sectiune dinou
 
; -- Incepem sa procesam datele introduse de user 
 
;    Creem reprezentarea numerica a numarului citit de la user

while2:
 
    CMP cl,errorChk
    JG endwhile2
 
    POP dx                  ; POP DX valoarea stocata in stiva
 
    MOV ch, 0h              ;stergem CH care este folosit in loop-ul interior ca counter
    MOV al, 1d              ;    setam AL la 1 (decimal)
    MOV dh, 10d             ;     setam DH la 10 (decimal)
 
 ;  incepem bucla pentru a creea puterile lui 10 
 ;     daca CL este 2 
 ;     1 bucla va produce 10^0
 ;    a 2-a bucla va produce 10^1
 ;     a 3-a bucla va produce 10^2
 while3:
 
    CMP ch, cl              ; comparam CH with CL 
    JGE endwhile3           ; daca CH >= CL , sarim la 'endwhile3'
 
    MUL dh                  ; AX = AL * DH      
 
    INC ch                  ; incrementam CH
    JMP while3
 
 endwhile3:
 ; --terminam bucla de calcul al puterilor
 
    ;acum AL contine 10^0 , 10^1 sau 10^2 depinzand de valoarea din CL 
 
    MUL dl                  ; AX = AL * DL
 
    JO  overflow            ;daca este un overflow sarim la 'overflow'
 
    MOV dl, al              ;    mutam restlt multiplicat in DL 
    ADD dl, guess           ; adaugam rezultatul valorii in variabila 'guess'
  
    JC  overflow            ; daca avem un overflow sarim iar la 'overflow' 
 
    MOV BX, OFFSET guess    ;  luam adresa variabilei 'guess' in BX 
    MOV BYTE PTR [BX], dl   ; setam 'errorChk' la valoarea lui DL 
 
    INC cl                  ;          incrementam CL ( counter ) 
 
    JMP while2              ;           sarim inapoi la label-ul 'while2'
 
endwhile2:
; -- terminam procesarea datelor introduse de user 
 
    MOV ax, @data           ;       luam adresa datei din AX 
    MOV ds, ax              ;   setam 'data segment' la valoare lui AX 
 
    MOV dl, number          ;        incarcam 'number' original in DL 
    MOV dh, guess           ;     incarcam 'number' ghicit in DH 
 
    CMP dh, dl              ; commparam DH si DL (DH - DL)               
 
    JC greater              ; Daca DH (GUESS) > DL (NUMBER) printam ca numarul este mai mare
    JE equal                ; Daca DH (GUESS) = DL (NUMBER) printam ca numarul ghicit este corect
    JG lower                ; Daca DH (GUESS) < DL (NUMBER) printam ca numarul este mai mic 
 
equal:
    mov ah, 02
    mov dl, 07h ;07h este valoarea care produce sunet
    int 21h ;producem sunet
    int 21h ;producem sunet
    int 21h ;producem sunet
    int 21h ;producem sunet
    MOV dx, offset equalMsg ;   incarcam adresa 'equalMsg'   in DX
    MOV ah, 9h              ;    scriem situl in STDOUT 
    INT 21h                 ; DOS INT 21h (DOS interrupt)         
    
    
     mov     ax, 3
    int     10h
    

    mov     ax, 1003h
    mov     bx, 0      ; disable blinking.
    int     10h
    
    
                   
    mov     dl, 0   ; coloana curenta
    mov     dh, 0   ;  randul curent
    
    mov     bl, 0   ; atributele curente
    
    jmp     next_char
    
    next_row:
    inc     dh
    cmp     dh, 16
    je      stop_print
    mov     dl, 0
    
    next_char:
    
    ;setam pozitia cursonului la (dl,dh):
    mov     ah, 02h
    int     10h
    
    mov     al, 'a'
    mov     bh, 0
    mov     cx, 1
    mov     ah, 09h
    int     10h
    
    inc     bl      ; urmatoarele atribute
    
    inc     dl
    cmp     dl, 16
    je      next_row
    jmp     next_char
    
    stop_print:
    
    ; ssetam pozitia cursonului la (dl,dh):
    mov     dl, 10  ; column.
    mov     dh, 5   ; row.
    mov     ah, 02h
    int     10h
    
  ; folosim atribute colorate pe pozitia curenta a cursonului 
    mov     al, 'x'
    mov     ah, 0eh
    int     10h
    
    
    ; asteptam apasarea unui buton : 
    mov ah, 0
    int 16h
      
    
    JMP exit                ;sarim la sfarsitul programului 
 
greater:
    
    mov ah, 02
    mov dl, 07h ;07h este valoarea care produce sunet
    int 21h ;producem sunet
    int 21h ;producem sunet
    int 21h ;producem sunet
    int 21h ;producem sunet
    MOV dx, offset moreMsg  
    MOV ah, 9h             
    INT 21h                 ; DOS INT 21h (DOS interrupt)
    JMP start              
 
lower:     

    mov ah, 02
    mov dl, 07h ;07h este valoarea care produce sunet
    int 21h ;producem sunet
    int 21h ;producem sunet
    int 21h ;producem sunet
    int 21h ;producem sunet
    MOV dx, offset lessMsg  
    MOV ah, 9h             
    INT 21h                 
    JMP start               ; sarim la sfarsit
 
overflow:
 
    MOV dx, offset overflowMsg 
    MOV ah, 9h              
    INT 21h                 
    JMP start               
 
exit: 
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
; intrebam userul daca vrea sa incerce dinou dupa ce a ghicit numarul 
retry_while:
 
    MOV dx, offset retry    ; incarcam adresele 'prompt' in DX 
 
    MOV ah, 9h              ;   scriem sirul in STDOUT
    INT 21h                 ; DOS INT 21h (DOS interrupt)
 
    MOV ah, 1h              ;  citim caracterele din STDIN in AL 
    INT 21h                 ; DOS INT 21h (DOS interrupt)
 
    CMP al, 6Eh             ;    verificam daca user-ul a introdus 'n'
    JE return_to_DOS        
    
    CMP al, 79h             ;  verificam daca user-ul a introdus 'y'
    JE restart              
 
    JMP retry_while         ; daca nu a introdus nici y nici n , repunem intrebarea 
 
retry_endwhile:
 
restart:
    JMP start               ; JUMP to begining of program
return_to_DOS:
    MOV ax, 4c00h           ; Return to ms-dos
    INT 21h                 ; DOS INT 21h (DOS interrupt)
    end start  
    
print:
    
 
RET
