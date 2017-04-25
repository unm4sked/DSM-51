LED EQU P1.7

CSDS EQU 0FF30H 		

CSDB EQU 0FF38H 		

D7OFF BIT P1.6  		

D7BM EQU 7FH			

DCL  EQU 7EH            	

DCH  EQU 7DH            	

D7IX EQU 7CH            	

CZAS EQU 75H

GODZ EQU 74H

STO EQU 73H

DZIESIEC EQU 72H

USTAWS EQU 71H			

T0IB BIT 7FH				

BITPRACY BIT 70H		

STANK EQU 6FH			

PSTANK EQU 6EH			

KSEQ BIT P3.5                   	

SEK EQU 6DH

MIN EQU 6CH

GOD EQU 6BH





	ORG 0			;reset

	LJMP START      	

;=======================================

;	TIMER 0 INTERRUPT

	ORG	0BH



	LJMP	TI0MAIN	





;=======================================

;	TIMER 0 INTERRUPT MAIN

	ORG	0B0H			



TI0MAIN:



	PUSH	ACC			

	PUSH	PSW			

	MOV	TH0, #255 - 3	

	MOV	A, #256 - 154 + 1	

	ADD	A, TL0		

	MOV	TL0, A		

	JNC	TI0MAIN_TH0_OK	

	INC	TH0			



TI0MAIN_TH0_OK:			



	POP	PSW			

	POP	ACC			



	SETB	T0IB			



	RETI				



;=======================================

;	PROGRAM

	ORG 100H



START:

                	;program wlasciwy

        MOV	IE,	#00h	

	MOV	TMOD,	#71h	

	MOV	TCON,	#10h	

	SETB	ET0		

	SETB	EA		



	MOV D7BM, #40h   	

	MOV D7IX, #0   	

	MOV CZAS, #5      	

	MOV CZAS+1, #5        

	MOV CZAS+2, #9         

	MOV CZAS+3, #5        

	MOV CZAS+4, #3          

	MOV CZAS+5, #2          

	MOV R1, #CZAS    

  	MOV STO, #100       

	MOV DZIESIEC, #10

	MOV USTAWS, #1		

      	CLR BITPRACY            

      	MOV STANK, #0           

      	MOV PSTANK, #0          

      	MOV GOD, #23



MAIN:

     	MOV A, @R1

	INC R1

	MOV DPTR, #WZORY     	

	MOVC A, @A+DPTR      	



	JNB BITPRACY, TRYBNORMALNY

	MOV R2, A           		

	MOV A, USTAWS

	CJNE A, #1, MINUTYK

	MOV A, D7BM

	JB ACC.0, USTAWIANIEKROPKI

MINUTYK:

	MOV A, USTAWS

	CJNE A, #2, GODZINYK

	MOV A, D7BM

	JB ACC.2, USTAWIANIEKROPKI

GODZINYK:

	MOV A, USTAWS

	CJNE A, #3, NIESTAWIAJKROPEK

	MOV A, D7BM

	JB ACC.4, USTAWIANIEKROPKI

NIESTAWIAJKROPEK:

	MOV A, R2                     

	SJMP TRYBNORMALNY              	

USTAWIANIEKROPKI:

	MOV A, R2                     

	SETB ACC.7



TRYBNORMALNY:

        SETB D7OFF           	

 	MOV DPTR, #CSDB      	

	MOVX @DPTR, A       	

	MOV A, D7BM           

  	MOV DPTR, #CSDS       	

	MOVX @DPTR, A         	

	MOV C, KSEQ            

	JNC BEZKLAWISZA        

	MOV R2, A                    

	ORL A, STANK        		

	MOV STANK, A                 

	MOV A,R2                   



BEZKLAWISZA:

	CLR D7OFF             	

	RL A                  	

	JNB ACC.7, mlAneq128    

	RL A                    

        MOV R1, #CZAS           

        MOV R2,A                     	

	LCALL NACISNIETY       		

	MOV A,R2                     	

	MOV STANK,#0                  



mlAneq128:

	MOV D7BM, A             



LoopRun:

	JNB T0IB, MAIN		

	CLR T0IB		

        DEC STO

	MOV A, STO

	CJNE A, #0, MAIN



Zliczanie:

 	MOV STO, #100

  	DEC DZIESIEC

        MOV A, DZIESIEC

 	CJNE A, #0, MAIN

 	MOV DZIESIEC, #10



  	JB BITPRACY, MAIN        



JSEKUNDY:

        MOV A,CZAS

        INC CZAS

	CJNE A,#9,WSTECZ



DSEKUND:

	MOV CZAS, #0

	MOV A,CZAS+1

	INC CZAS+1



	CJNE A,#5,WSTECZ



JMINUT:



	MOV CZAS, #0

	MOV CZAS+1, #0

	MOV A, CZAS+2

	INC CZAS+2



	CJNE A, #9, WSTECZ

	SJMP DMINUT

WSTECZ:

	LJMP MAIN

DMINUT:

	MOV CZAS,  #0

	MOV CZAS+1,#0

	MOV CZAS+2,#0

	MOV A,CZAS+3

	INC CZAS+3



	CJNE A,#5,WSTECZ

	SJMP GODZINY

GODZINY:

	MOV CZAS,  #0

	MOV CZAS+1,#0

	MOV CZAS+2,#0

        MOV CZAS+3,#0

        INC GOD

        MOV B, #10

        MOV A, GOD

        DIV AB

        MOV CZAS+4, B

        MOV CZAS+5, A

        MOV A, GOD

        CJNE A, #24, WSTECZ

        MOV GOD, #0

        MOV CZAS+4,#0

        MOV CZAS+5,#0



	LJMP MAIN          



NACISNIETY:                           	

        MOV A, STANK        

	CJNE A, PSTANK, NACISNIETYINNY	



NACISNIETYINNY:

	MOV PSTANK, A          

	LCALL EENTER

	LCALL EESC

	JNB BITPRACY, WSTECZ3

	LCALL PRAWO

	LCALL GORA

	LCALL DOL

	LCALL LEWO

	RET

WSTECZ3:

	RET

EENTER:

      	CJNE A, #1, WSTECZ3

        MOV DZIESIEC, #10           

 	MOV STO, #100               

	CLR BITPRACY               

	RET

EESC:

    	CJNE A, #2, WSTECZ3

    	SETB BITPRACY                

 	MOV USTAWS, #1              

	RET

PRAWO:

      	CJNE A, #4, WSTECZ3

      	DEC USTAWS                  

      	MOV A, USTAWS

      	CJNE A, #0, WSTECZ3         

      	MOV USTAWS, #1              

      	RET

GORA:

      CJNE A, #8, WSTECZ3

      MOV A, USTAWS

      CJNE A, #1, GORAMINUTY

      MOV B, #10

      MOV A, CZAS+1

      MUL AB

      ADD A, CZAS

      MOV SEK, A

      INC SEK

      MOV A, SEK

      MOV B, #60

      DIV AB

      MOV SEK, B

      MOV A, SEK

      MOV B, #10

      DIV AB

      MOV CZAS+1, A

      MOV CZAS, B

      RET

GORAMINUTY:

      MOV A, USTAWS

      CJNE A, #2, GORAGODZ

      MOV B, #10

      MOV A, CZAS+3

      MUL AB

      ADD A, CZAS+2

      MOV MIN, A

      INC MIN

      MOV A, MIN

      MOV B, #60

      DIV AB

      MOV MIN, B

      MOV A, MIN

      MOV B, #10

      DIV AB

      MOV CZAS+3, A

      MOV CZAS+2, B

      RET

GORAGODZ:

      MOV B, #10

      MOV A, CZAS+5

      MUL AB

      ADD A, CZAS+4

      MOV GOD, A

      INC GOD

      MOV A, GOD

      MOV B, #24

      DIV AB

      MOV GOD, B

      MOV A, GOD

      MOV B, #10

      DIV AB

      MOV CZAS+5, A

      MOV CZAS+4, B

      RET

DOL:

      CJNE A, #16, WSTECZ2

      MOV A, USTAWS

      CJNE A, #1, DOLMINUTY

      MOV B, #10

      MOV A, CZAS+1

      MUL AB

      ADD A, CZAS

      MOV SEK, A

      DEC SEK

      MOV A, SEK

      MOV B, #196

      DIV AB

      MOV SEK, B

      MOV A, SEK

      MOV B, #10

      DIV AB

      MOV CZAS+1, A

      MOV CZAS, B

      RET

DOLMINUTY:

      MOV A, USTAWS

      CJNE A, #2, DOLGODZ

      MOV B, #10

      MOV A, CZAS+3

      MUL AB

      ADD A, CZAS+2

      MOV MIN, A

      DEC MIN

      MOV A, MIN

      MOV B, #196

      DIV AB

      MOV MIN, B

      MOV A, MIN

      MOV B, #10

      DIV AB

      MOV CZAS+3, A

      MOV CZAS+2, B

      RET

DOLGODZ:

      MOV B, #10

      MOV A, CZAS+5

      MUL AB

      ADD A, CZAS+4

      MOV GOD, A

      DEC GOD

      MOV A, GOD

      MOV B, #232

      DIV AB

      MOV GOD, B

      MOV A, GOD

      MOV B, #10

      DIV AB

      MOV CZAS+5, A

      MOV CZAS+4, B

      RET

LEWO:

      CJNE A, #32, WSTECZ2

      INC USTAWS                

      MOV A, USTAWS

      CJNE A, #4, WSTECZ2       

      MOV USTAWS, #3            

      RET



WSTECZ2:

	RET



WZORY:

	DB	00111111B, 00000110B, 01011011B, 01001111B	;0123

	DB	01100110B, 01101101B, 01111101B, 00000111B	;4567

	DB	01111111B, 01101111B, 01110111B, 01111100B	;89Ab

	DB	01011000B, 01011110B, 01111001B, 01110001B	;cdEF

END
