;___________________________________________
;  Ports Allocation
;        1. P0, P2.5, P2.6 for LCD
;		 2. P2.0 - 3 , P3.0 - 2 for KEYPAD
;___________________________________________
;  OPCODES:
;        1.ARITHMETIC	     #
;                 #*		  ADD
;				  ##		  SUBTRACT
;				  **		  MULTIPLY
;				  *#  		  DIVIDE
;        2.	CONVERSION		  *
;                 **          B TO D
;                 *#          D TO B
;				   #          B TO HD
;____________________________________________

ORG 0H

LCALL LCD_ON
LCALL INPUT_KEYPAD

CJNE A, #2AH, ERROR_CHECK
LJMP BASE_CONVERSION
 
ERROR_CHECK:
            CJNE A, #23H, INVALID_IN
			LJMP ELEMENTARY_MATH                    

INVALID_IN:
		  ACALL LCD_ON

		  MOV A, #'E'
		  ACALL DATA1
	      ACALL DELAY
		  
		  MOV A, #'R'
		  ACALL DATA1
	      ACALL DELAY
		  
		  MOV A, #'R'
		  ACALL DATA1
	      ACALL DELAY
		  
		  MOV A, #'O'
		  ACALL DATA1
	      ACALL DELAY
		  
		  MOV A, #'R'
		  ACALL DATA1
	      ACALL DELAY
		  
		  MOV A, #'!'
		  ACALL DATA1
	      ACALL DELAY
LCALL TERMINATE

ELEMENTARY_MATH:
LCALL LCD_ON

MOV R1, #40H				  ;VALUES OF TWO INPUTS				40H & 41H

MOV R2, #2
START:
	  MOV R7, #3
	  MOV R0, #30H              ;VALUES 30H, 31H, 32H	
      INNER:
	  		LCALL INPUT_KEYPAD
			CLR CY
			SUBB A, #30H
			MOV @R0, A
			INC R0
	  DJNZ R7, INNER
	  
	  MOV A, #0C0H
	  LCALL COM
	  LCALL DELAY

	  MOV B, #100
	  MOV A, 30H
	  MUL AB
	  MOV 50H, A

	  MOV B, #10
	  MOV A, 31H
	  MUL AB
	  
	  ADD A, 50H
	  ADD A, 32H
	  MOV @R1, A
	  INC R1
DJNZ R2, START

LCALL LCD_ON

OPCODE:
	   		ACALL INPUT_KEYPAD
			CJNE A, #2AH, ADD_SUB	   
			LJMP DIV_MUL

ADD_SUB:
		ACALL INPUT_KEYPAD
		MOV 65H, A

		MOV A, #0C0H
	    LCALL COM
	    LCALL DELAY

		MOV A, 65H
		CJNE A, #2AH, SUBTRACTION			   ; ## SUB
		SJMP ADDITION    				       ; #* ADD
RET
		
ADDITION:
					
		 MOV A, 40H
		 ADD A, 41H
		 MOV 42H, A
		 
		 MOV B, #100
     	 DIV AB
		 ADD A, #30H
         LCALL LCD_DISPLAY

		 MOV B, #10
		 MOV A, 42H
     	 DIV AB
         MOV B, #10
		 DIV AB
		 MOV A, B
		 ADD A, #30H
         LCALL LCD_DISPLAY

		 MOV B, #10
		 MOV A, 42H
     	 DIV AB
		 MOV A, B
		 ADD A, #30H
         LCALL LCD_DISPLAY
		 LCALL DELAY_5S

		 LCALL TERMINATE
RET 

SUBTRACTION:
	     CLR CY
	     MOV A, 40H
   	     SUBB A, 41H
	     
		 JC CORRECTION
		 MOV 42H, A
	     
	     MOV B, #100
	     MOV A, 42H
     	 DIV AB
	     ADD A, #30H
         LCALL LCD_DISPLAY

	     MOV B, #10
	     MOV A, 42H
     	 DIV AB
         MOV B, #10
	     DIV AB
		 MOV A, B
		 ADD A, #30H
         LCALL LCD_DISPLAY

		 MOV B, #10
		 MOV A, 42H
     	 DIV AB
		 MOV A, B
		 ADD A, #30H
         LCALL LCD_DISPLAY
		 LCALL DELAY_5S

		 LCALL TERMINATE
RET

CORRECTION:
	     CLR CY
	     MOV A, 41H
   	     SUBB A, 40H
		 MOV 42H, A

		 MOV A, #'-'
		 LCALL LCD_DISPLAY

		 MOV A, 42H
		 MOV B, #100
	     MOV A, 42H
     	 DIV AB
	     ADD A, #30H
         LCALL LCD_DISPLAY

	     MOV B, #10
	     MOV A, 42H
     	 DIV AB
         MOV B, #10
	     DIV AB
		 MOV A, B
		 ADD A, #30H
         LCALL LCD_DISPLAY

		 MOV B, #10
		 MOV A, 42H
     	 DIV AB
		 MOV A, B
		 ADD A, #30H
         LCALL LCD_DISPLAY
		 LCALL DELAY_5S

		 LCALL TERMINATE
RET

DIV_MUL:
		ACALL INPUT_KEYPAD
		MOV 65H, A

		MOV A, #0C0H
	    LCALL COM
	    LCALL DELAY

		MOV A, 65H
		CJNE A, #2AH, DIVISION	       ;*# DIV
		SJMP MULTIPLICATION 	       ;** MUL		
RET
		 
MULTIPLICATION:
		 MOV A, 40H
   	     MOV B, 41H
	     MUL AB
	     MOV 42H, A

		 MOV A, #14H
		 LCALL COM
		 LCALL DELAY
		 
		 MOV B, #100
		 MOV A, 42H
         DIV AB
		 ADD A, #30H
         LCALL LCD_DISPLAY

		 MOV B, #10
		 MOV A, 42H
         DIV AB
         MOV B, #10
		 DIV AB
		 MOV A, B
		 ADD A, #30H
         LCALL LCD_DISPLAY

		 MOV B, #10
		 MOV A, 42H
         DIV AB
		 MOV A, B
		 ADD A, #30H
         LCALL LCD_DISPLAY
		 LCALL DELAY_5S	
		 
		 LCALL TERMINATE		   
RET


DIVISION:
	     MOV A, 40H
	     MOV B, 41H
	     DIV AB
		 ADD A, #30H
	     LCALL LCD_DISPLAY
		 LCALL DELAY_5S
		 
		 LCALL TERMINATE
RET

BASE_CONVERSION:
LCALL LCD_ON

	OPCODE1:
		ACALL INPUT_KEYPAD
		CJNE A, #2AH, BINTOHEX	   
		LJMP DEC_BIN

	RET
	DEC_BIN:
        ACALL INPUT_KEYPAD
		CJNE A, #2AH, DECTOBIN	   
		LJMP BINTODEC
	RET

RET

BINTOHEX:
LCALL BINTOHEX1

DECTOBIN:
      LCALL LCD_ON
      ACALL START1
		 	  
	  MOV A, #0C0H
	  LCALL COM
	  LCALL DELAY

MOV A, 40H
MOV 69H, A
CLR CY
MOV R2, #8
DECTOBIN1:
		MOV A, 69H
		RLC A
		MOV 69H, A
		JNC DISPLAY_0
		JC DISPLAY_1
		
		RETURN:
		
        DJNZ R2, DECTOBIN1

LCALL DELAY_5S
LCALL TERMINATE

DISPLAY_0:
	  MOV A, #0
	  ADD A, #30H
	  LCALL LCD_DISPLAY
	  ACALL RETURN
RET

DISPLAY_1:
	  MOV A, #1
	  ADD A, #30H
	  LCALL LCD_DISPLAY

	  ACALL RETURN
RET


START1:
	  MOV R7, #3
	  MOV R0, #35H              ;VALUES 35H, 36H, 37H	
      INNER1:
	  		LCALL INPUT_KEYPAD
			CLR CY
			SUBB A, #30H
			MOV @R0, A
			INC R0
	  DJNZ R7, INNER1

	  MOV B, #100
	  MOV A, 35H
	  MUL AB
	  MOV 50H, A

	  MOV B, #10
	  MOV A, 36H
	  MUL AB
	  
	  ADD A, 50H
	  ADD A, 37H

	  MOV 40H, A
RET

INPUT_KEYPAD:
MOV P3, #0FFH                              ; INPUT PORT

K1: MOV P2, #0							   ; OUTPUT PORT
	MOV A, P3
	ANL A, #00000111B
	CJNE A, #00000111B, K1

K2: ACALL DELAY_KEYPAD
	MOV A, P3
	ANL A, #00000111B
	CJNE A, #00000111B, OVER
	SJMP K2

OVER: ACALL DELAY_KEYPAD
	  MOV A, P3
	  ANL A, #00000111B
      CJNE A, #00000111B, OVER1
	  SJMP K2

OVER1: MOV P2, #11111110B
	   MOV A, P3
	   ANL A, #00000111B
	   CJNE A, #00000111B, ROW_0
	   
	   MOV P2, #11111101B
	   MOV A, P3
	   ANL A, #00000111B
	   CJNE A, #00000111B, ROW_1
	   
	   MOV P2, #11111011B
	   MOV A, P3
	   ANL A, #00000111B
	   CJNE A, #00000111B, ROW_2
	   
	   MOV P2, #11110111B
	   MOV A, P3
	   ANL A, #00000111B
	   CJNE A, #00000111B, ROW_3
	   LJMP K1

ROW_0: MOV DPTR, #KCODE0
	   SJMP FIND

ROW_1: MOV DPTR, #KCODE1
	   SJMP FIND

ROW_2: MOV DPTR, #KCODE2
	   SJMP FIND

ROW_3: MOV DPTR, #KCODE3
	   SJMP FIND

FIND: RRC A
	  JNC MATCH
	  INC DPTR
	  SJMP FIND

MATCH: CLR A
	   MOVC A, @A+DPTR
	   ACALL LCD_DISPLAY

RET

DELAY_KEYPAD: MOV R5,#45
       LOOOP:
              MOV R6,#255
              DJNZ R6,$
              DJNZ R5, LOOOP
RET

		ORG 300H
KCODE0: DB  '1', '2', '3'
KCODE1: DB  '4', '5', '6' 
KCODE2: DB  '7', '8', '9'  
KCODE3: DB  '*', '0', '#'

RET
LCD_ON:
MOV A, #38H
ACALL COM
ACALL DELAY

MOV A, #0EH
ACALL COM
ACALL DELAY

MOV A, #01H
ACALL COM
ACALL DELAY

MOV A, #06H
ACALL COM
ACALL DELAY

MOV A, #80H
ACALL COM
ACALL DELAY

MOV A, #0
RET

BINTODEC:
	   LCALL LCD_ON
	   LCALL START2
	   BACK:
	   MOV A, #0C0H
	   LCALL COM
	   LCALL DELAY

       MOV A, 40H
       MOV R6, #0
BDLOOP:
       SUBB A, #00000010B
	   INC R6
	   CJNE A, #00000001B, BDLOOP
	   MOV 41H, A

 	   MOV B, R6
	   MOV A, #2
	   MUL AB
	   ADD A, 41H

  	   MOV 42H, A
		 
	   MOV B, #100
       DIV AB
	   ADD A, #30H
       LCALL LCD_DISPLAY

	   MOV B, #10
	   MOV A, 42H
       DIV AB
       MOV B, #10
	   DIV AB
	   MOV A, B
	   ADD A, #30H
       LCALL LCD_DISPLAY

	   MOV B, #10
	   MOV A, 42H
       DIV AB
	   MOV A, B
	   ADD A, #30H
       LCALL LCD_DISPLAY
	   LCALL DELAY_5S

LCALL TERMINATE

START2:
	  MOV R7, #8
	  MOV 40H, #0
	  	
      INNER2:
	  		LCALL INPUT_KEYPAD
			SUBB A, #30H
			CLR CY
			CJNE A, #0, RCARRY
			ACALL CLRCARRY
	        
			RETURN2:
			        MOV A, 40H
			        RLC A
			        MOV 40H, A

	        DJNZ R7, INNER2

	  MOV 40H, A
	  LCALL	BACK
RET
RCARRY:
	   SETB CY
	   ACALL RETURN2
RET
CLRCARRY:
	   CLR CY
       ACALL RETURN2
RET

BINTOHEX1:
	   LCALL LCD_ON
	   LCALL START3
	   
	   BACK4:
	   MOV A, #0C0H
	   LCALL COM
	   LCALL DELAY

MOV A, 40H
MOV R6, #0
BDLOOP1:
       SUBB A, #00000010B
	   INC R6
	   CJNE A, #00000001B, BDLOOP1
	   MOV 41H, A

 	   MOV B, R6
	   MOV A, #2
	   MUL AB
	   ADD A, 41H
	  ;-------------------------------
	   MOV B, #10H
	   DIV AB
	   MOV 42H, A
	   MOV 43H, B

	   MOV B, #0AH
	   MOV A, 42H
	   DIV AB
	   CJNE A, #0, MUL_CORRECTION1
	   MOV A, 42H
	   ADD A, #30H
	   BACK6:
			 LCALL LCD_DISPLAY

		;___________________________
	   
	   MOV B, #0AH
	   MOV A, 43H
	   DIV AB
	   CJNE A, #0, MUL_CORRECTION2
	   MOV A, 43H
	   ADD A, #30H
	   BACK7:
			 LCALL LCD_DISPLAY
			 LCALL DELAY_5S
LCALL TERMINATE

RET

MUL_CORRECTION1:
       MOV A, 42H
	   ADD A, #37H
	   ACALL BACK6
RET

MUL_CORRECTION2:
       MOV A, 43H
	   ADD A, #37H
	   ACALL BACK7
RET

START3:
	  MOV R7, #8
	  MOV 40H, #0
	  	
      INNER3:
	  		LCALL INPUT_KEYPAD
			SUBB A, #30H
			CLR CY
			CJNE A, #0, RCARRY1
			ACALL CLRCARRY1
	        
			RETURN4:
			        MOV A, 40H
			        RLC A
			        MOV 40H, A

	        DJNZ R7, INNER3

	  MOV 40H, A
	  LCALL	BACK4
RET
RCARRY1:
	   SETB CY
	   ACALL RETURN4
RET
CLRCARRY1:
	   CLR CY
       ACALL RETURN4
RET


LCD_DISPLAY:
		ACALL DATA1
		ACALL DELAY
RET
DELAY_5S:
	    MOV R3, #255
LOOOOP: MOV R4, #255
LOP:	MOV R5, #35
        DJNZ R5, $
		DJNZ R4, LOP
		DJNZ R3, LOOOOP

RET
COM:
	MOV P0, A
	CLR P2.5
	SETB P2.6
	ACALL DELAY
	CLR P2.6
RET

DATA1:
	MOV P0, A
	SETB P2.5
	SETB P2.6
	ACALL DELAY
	CLR P2.6
RET

DELAY:
	MOV R3, #50
	L2: MOV R4, #255
		DJNZ R4, $
		DJNZ R3, L2
RET


TERMINATE:
SJMP $
END  