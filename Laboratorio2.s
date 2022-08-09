;*******************************************************************************
; Universidad del Valle de Guatemala	
; IE2023 Programaci髇 de microcontroladores
; Autor: Michelle Serrano 
; Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
; Proyecto: Laboratorio 2
; Hardware: PIC16F887 
; Creado: 02/08/2022
; 趌tima modificaci髇: 02/08/2022
;*******************************************************************************
PROCESSOR 16F887
#include <xc.inc> 
;*******************************************************************************
;Configuracions
;*******************************************************************************
; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT 
  CONFIG  WDTE = OFF            
  CONFIG  PWRTE = ON           
  CONFIG  MCLRE = OFF           
  CONFIG  CP = OFF              
  CONFIG  CPD = OFF             
  CONFIG  BOREN = OFF           
  CONFIG  IESO = OFF            
  CONFIG  FCMEN = OFF           
  CONFIG  LVP = OFF             

; CONFIG2
  CONFIG  BOR4V = BOR40V        
  CONFIG  WRT = OFF    
;*******************************************************************************
; Variables
;******************************************************************************* 
PSECT udata_shr
   con_display:	DS 1 ; 1 byte
   val:	DS 1
;*******************************************************************************
; Vector Reset 
;*******************************************************************************     
PSECT CODE, delta=2, abs
 ORG 0x0000
    goto main
;*******************************************************************************
; C骴igo Pricipal
;*******************************************************************************       
PSECT CODE, delta=2, abs
 ORG 0x0100

main:
    call    PYE
    call    reloj
    call    Tm0_config
   
    clrf    PORTA   ; entradas pushbottons
    clrf    PORTB   ; salida contador 1
    clrf    PORTD
    movlw   3Fh
    movwf   PORTC   ; colocamos el contador en 0
    movlw   00h	    ; colocaci贸n de valores iniciales
    movwf   con_display
    movlw   16
    movwf   val
    
;*******************************************************************************
;				    LOOP PRINCIPAL
;*******************************************************************************
loop:
    call    contador_display
    call    Timer_auto
    call    comparar
    goto    loop
;*******************************************************************************
;				    SUBRUTINAS
;*******************************************************************************
PYE: 
    banksel ANSEL
    clrf    ANSEL   ; pines digitales
    clrf    ANSELH
    
    banksel TRISA
    movlw   03h	  
    movwf   TRISA   ; puertos RA<1:0> como entradas
    clrf    TRISB   ; se colocaron como salidas todos los pines de los puertos
    clrf    TRISC   ; B, C y D 
    clrf    TRISD
    return

reloj:
    bcf	    IRCF2
    bsf	    IRCF1
    bcf	    IRCF0   ; reloj a 250kHz
    return

Tm0_config:
    bcf	    T0CS    ; selecci贸n del reloj interno
    bcf	    PSA	    ; asignamos prescaler al Timer0
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0	    ; prescaler a 256
    banksel PORTA
    call    reset_Tm0
    return
    
reset_Tm0:
    movlw   134	    ; valor calculado con f贸rmula
    movwf   TMR0
    bcf	    T0IF    ; limpieza de la bandera
    return
    
Timer_auto: 
    btfss   T0IF    ; contador autom谩tico cada 0.5s
    goto    $-1
    call    reset_Tm0
    incf    PORTB
    return
    
contador_display:
    btfsc   PORTA,0
    call    incrementar_display   ; pushbotton para incrementar
    btfsc   PORTA,1
    call    decrementar_display   ; pushbotton para decrementar
    movf    con_display, W	    ; guardar valor en variable
    
    movwf   PORTC		    ; colocar el valor en PORTC
    return

incrementar_display:
    btfsc   PORTA, 0		; antirebote
    goto    $-1
    incf    con_display, F	; incrementa en 1 el valor de PORTB
    btfsc   con_display, 4	;verificaci贸n para observar si se paso de 4 bits
    clrf    con_display	; reseteo de nuestra variable
    return
    
decrementar_display:
    btfsc   PORTA, 1		; antirrebote
    goto    $-1
    decf    con_display, F	; incrementa en 1 el valor de PORTB
    btfsc   con_display, 4	;verificaci贸n para observar si se paso de 4 bits
    call    colocar_F
    return  
    
colocar_F:
    movlw   0Fh			; si se desea decrementar de 0 a F
    movwf   con_display
    return
    
comparar:
    movf    PORTB, w
    xorwf   con_display, w	; iguales = 0, diferentes = 1
    subwf   val, w	; si todos son iguales, el resutlado deber铆a ser
    movwf   PORTD		; 16, por ello se revisa el bit 4 de nuestro
    btfsc   PORTD, 4		; puerto D, si no esta encendido no son iguales
    call    resete
    return
    
resete:
    clrf    PORTB		; resetear el valor del contador
    call    reset_Tm0		; resetear Timer0
    return
END



    


   