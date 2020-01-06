;
; Test for VXCO frequency delta of 1.46 Hz.
;		   
; 				
;  
;  Gene Marcus W3PM GM4YRE
;  17 March, 2010
;
;  Clock Frequency: 4 MHz
;
; 
;
; 					       PIC16F628A                             
;                          __________                                          
;     Not used	   ---RA2 |1       18| RA1---------Not used                   
;     Not used     ---RA3 |2       17| RA0---------Not used                   
;     Not used     ---RA4 |3       16| OSC1--------XTAL                        
;     +5V-----------!MCLR |4       15| OSC2--------XTAL                        
;     Ground----------Vss |5       14| VDD---------+5 V                        
;     Not used     ---RB0 |6       13| RB7---------Not used                    
;     Not used     ---RB1 |7       12| RB6---------Not used    
;     Not used     ---RB2 |8       11| RB5---------Not used           
;     PWM output   ---RB3 |9       10| RB4---------Not used         
;                          ----------                                          
; 

;=====================================================================

		processor		16f628a		
		include			<p16f628a.inc>
		__config		_CP_OFF & _LVP_OFF & _BODEN_OFF & _MCLRE_ON & _XT_OSC & _WDT_OFF & _PWRTE_ON

;		movlw		0x07
;		movwf		CMCON		; Turn off comparator

pwm_out 	equ     0x03        ; PWM output

   
		cblock 		H'40'

			count
			temp				;
			timer1				;
			timer2				;

		endc

		goto		start	


; ___________________________________________________________________
start


;---------------------------------------------------------------------
;	Set up I/O 
;---------------------------------------------------------------------

		banksel	TRISA                        
        movlw   B'00000000'       ; Tristate PORTA for all outputs  
        movwf   TRISA             ;
 		movlw	B'00000000'
        movwf   TRISB             ; Set port B to all outputs
		banksel	PORTA
		clrf	PORTA
		clrf	PORTB

; Set PWM period to 3.906 KHz
		banksel	PR2
		movlw	0xff
		movwf	PR2

; Set MSB bits of duty cycle of 50%
		banksel	CCPR1L
		movlw	B'01111111'
		movwf	CCPR1L

; Set LSB 2 bits of duty cycle 50%
;  and turn on PWM
		movlw	B'00111100'
		movwf	CCP1CON

;		bsf		CCP1CON,CCP1X
;		bsf		CCP1CON,CCP1Y

; Clear TRISB<3>
		banksel	TRISB
		bcf		TRISB,3			  


; Turn on timer 2, prescale=1, postscale=1
		banksel	T2CON
		movlw	B'00000100'
		movwf	T2CON




;---------------------------------------------------------------------
;	PWM test 
;---------------------------------------------------------------------





loop

		movlw	D'120'
		movwf	CCPR1L

		call	wait_a_sec
		call	wait_a_sec
		call	wait_a_sec
		call	wait_a_sec
		call	wait_a_sec

		movlw	D'157'
		movwf	CCPR1L
		call	wait_a_sec
		call	wait_a_sec
		call	wait_a_sec
		call	wait_a_sec
		call	wait_a_sec

		movlw	D'194'
		movwf	CCPR1L
		call	wait_a_sec
		call	wait_a_sec
		call	wait_a_sec
		call	wait_a_sec
		call	wait_a_sec

		movlw	D'231'
		movwf	CCPR1L
		call	wait_a_sec
		call	wait_a_sec
		call	wait_a_sec
		call	wait_a_sec
		call	wait_a_sec



		goto	loop
		
		


stop
		goto	stop


;
; *****************************************************************************
; *                                                                           *
; * Purpose:  Wait for a specified number of milliseconds.                    *
; *                                                                           *
; *           Entry point wait_a_sec:  Wait for 1 second                      *
; *           Entry point wait_256ms:  Wait for 256 msec                      *
; *           Entry point wait_128ms:  Wait for 128 msec                      *
; *           Entry point wait_64ms :  Wait for 64 msec                       *
; *           Entry point wait_32ms :  Wait for 32 msec                       *
; *           Entry point wait_16ms :  Wait for 16 msec                       *
; *           Entry point wait_8ms  :  Wait for 8 msec                        *
; *                                                                           *
; *   Input:  None                                                            *
; *                                                                           *
; *  Output:  None                                                            *
; *                                                                           *
; *****************************************************************************
;
wait_a_sec  ; ****** Entry point ******    
        call    wait_256ms        ;       
        call    wait_256ms        ;       
        call    wait_256ms        ;       
        call    wait_256ms        ;       
        return
wait_256ms  ; ****** Entry point ******    
        call    wait_128ms        ;
        call    wait_128ms        ;
        return
wait_128ms  ; ****** Entry point ******    
        movlw   0xFF              ; Set up outer loop 
        movwf   timer1            ;   counter to 255
        goto    outer_loop        ; Go to wait loops
wait_64ms  ; ****** Entry point ******     
        movlw   0x80              ; Set up outer loop
        movwf   timer1            ;   counter to 128
        goto    outer_loop        ; Go to wait loops
wait_32ms   ; ****** Entry point ******    
        movlw   0x40              ; Set up outer loop
        movwf   timer1            ;   counter to 64
        goto    outer_loop        ; Go to wait loops
wait_16ms   ; ****** Entry point ******    
        movlw   0x20              ; Set up outer loop
        movwf   timer1            ;   counter to 32  
        goto    outer_loop        ; Go to wait loops
wait_8ms   ; ****** Entry point ******     
        movlw   0x10              ; Set up outer loop
        movwf   timer1            ;   counter to 16
                                  ; Fall through into wait loops
;
; Wait loops used by other wait routines
;  - 1 microsecond per instruction (with a 4 MHz microprocessor crystal)
;  - 510 instructions per inner loop
;  - (Timer1 * 514) instructions (.514 msec) per outer loop
;  - Round off to .5 ms per outer loop
;
outer_loop                        
        movlw   0xFF              ; Set up inner loop counter
        movwf   timer2            ;   to 255
inner_loop
        decfsz  timer2,f          ; Decrement inner loop counter
        goto    inner_loop        ; If inner loop counter not down to zero, 
                                  ;   then go back to inner loop again
        decfsz  timer1,f          ; Yes, Decrement outer loop counter
        goto    outer_loop        ; If outer loop counter not down to zero,
                                  ;   then go back to outer loop again
        return                    ; Yes, return to caller
;       
; *****************************************************************************
;

		NOP
		END
 
