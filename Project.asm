ORG 0H


LCALL LCD_ON
LCALL KEYPAD
MOV 39H, A								   ; FIRST OPERAND(* OR #)=39H 

CJNE A, #2AH, ELEMENTARY_MATH			   ; SELECTION FOR ARITHMETIC OR BASE CONVERSION  #=ARITHMETIC, *=BASE CONVERSION
;LJMP BASE_CONVERSION

ELEMENTARY_MATH:
				ACALL KEYPAD			   ; FIRST VALUE INPUT
                MOV 40H, A				   ; FIRST VALUE STORED
				ACALL KEYPAD			   ; SECOND OPCODE
				CJNE A, #2AH, SUB_DIV	   ; #=SUB OR DIV
				SJMP ADD_MUL			   ; *=ADD OR MUL
				RET

ADD_MUL:
		ACALL KEYPAD
		CJNE A, #2AH, ADDITION			   ; #*=ADD
		SJMP MULTIPLICATION				   ; **=MUL
        RET
		
ADDITION:
		 ACALL KEYPAD					   ; SECOND VALUE INPUT
		 MOV 41H, A						   ; SECOND VALUE STORED
		 MOV A, 40H
		 ADD A, 41H
		 MOV 35H, A
		 ANL A, #0F0H
		 SWAP A
		 ADD A, #30H
		 LCALL LCD_DISPLAY
		 MOV A, 35H
		 ANL A, #0FH
		 ADD A, 30H
		 LCALL LCD_DISPLAY
		 RET 
		 
MULTIPLICATION:
			   ACALL KEYPAD				   ; SECOND VALUE INPUT
			   MOV 41H, A				   ; SECOND VALUE STORED
			   MOV A, 40H
			   MOV B, 41H
			   MUL AB
			   MOV 35H, A
	 		 ANL A, #0F0H
			 SWAP A
			 ADD A, #30H
			 LCALL LCD_DISPLAY
			 MOV A, 35H
			 ANL A, #0FH
			 ADD A, 30H
		   	   LCALL LCD_DISPLAY
			   RET

SUB_DIV:
		ACALL KEYPAD
		CJNE A, #2AH, SUBTRACTION	       ; ##=SUB
		SJMP DIVISION 				       ; *#=DIV
        RET

DIVISION:								   
		 ACALL KEYPAD					   ; SECOND VALUE INPUT
		 MOV 41H, A						   ; SECOND VALUE STORED
	     MOV A, 40H
	     MOV B, 41H
		 DIV AB
		 MOV 35H, A
		 ANL A, #0F0H
		 SWAP A
		 ADD A, #30H
		 LCALL LCD_DISPLAY
		 MOV A, 35H
		 ANL A, #0FH
		 ADD A, 30H
		 LCALL LCD_DISPLAY
	     RET

SUBTRACTION: 
			ACALL KEYPAD				   ; SECOND VALUE INPUT
		    MOV 41H, A					   ; SECOND VALUE STORED
			CLR CY
		    MOV A, 40H
		    SUBB A, 41H
			MOV 35H, A
			JC SUB_CORRECTION
			JNC SUB_DISPLAY
RET

KEYPAD:
MOV P2, #0FFH                              ; INPUT PORT

K1: MOV P1, #0							   ; OUTPUT PORT
	MOV A, P2
	ANL A, #00001111B
	CJNE A, #00001111B, K1

K2: ACALL DELAY_IN
	MOV A, P2
	ANL A, #00001111B
	CJNE A, #00001111B, OVER
	SJMP K2

OVER: ACALL DELAY_IN
	  MOV A, P2
	  ANL A, #00001111B
	  CJNE A, #00001111B, OVER1
	  SJMP K2

OVER1: MOV P1, #11111110B
	   MOV A, P2
	   ANL A, #00001111B
	   CJNE A, #00001111B, ROW_0
	   
	   MOV P1, #11111101B
	   MOV A, P2
	   ANL A, #00001111B
	   CJNE A, #00001111B, ROW_1
	   
	   MOV P1, #11111011B
	   MOV A, P2
	   ANL A, #00001111B
	   CJNE A, #00001111B, ROW_2
	   
	   MOV P1, #11110111B
	   MOV A, P2
	   ANL A, #00001111B
	   CJNE A, #00001111B, ROW_3
	   LJMP K2

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
	   LJMP K1

DELAY_IN: MOV R5,#45
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
SUB_DISPLAY:
		 ANL A, #0F0H
		 SWAP A
		 ADD A, #30H
		 LCALL LCD_DISPLAY
		 MOV A, 35H
		 ANL A, #0FH
		 ADD A, 30H
		 LCALL LCD_DISPLAY

RET
SUB_CORRECTION:
		 MOV 35H, A
		 MOV A, #'-'
		 LCALL LCD_DISPLAY
		 MOV A, 35H
		 CPL A
		 MOV 32H,#1
		 ADD A, 32H
		 MOV 35H, A
		 ANL A, #0F0H
		 SWAP A
		 ADD A, #30H
		 LCALL LCD_DISPLAY
		 MOV A, 35H
		 ANL A, #0FH
		 ADD A, 30H
		 LCALL LCD_DISPLAY
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


RET
LCD_DISPLAY:
		MOV P0, A
		ACALL DATA1
		ACALL DELAY
RET

COM:
	MOV P2, A
	CLR P3.0
	CLR P3.1
	SETB P3.2
	ACALL DELAY
	CLR P3.2
RET

DATA1:
	MOV P2, A
	SETB P3.0
	CLR P3.1
	SETB P3.2
	ACALL DELAY
	CLR P3.2
RET

DELAY:
	MOV R3, #50
	L2: MOV R4, #255
		DJNZ R4, $
		DJNZ R3, L2
RET

END    