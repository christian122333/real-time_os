;/*****************************************************************************/
; OSasm.s: low-level OS commands, written in assembly                       */
; Runs on LM4F120/TM4C123/MSP432
; Lab 4 starter file
; March 25, 2016

;


        AREA |.text|, CODE, READONLY, ALIGN=2
        THUMB
        REQUIRE8
        PRESERVE8

        EXTERN  RunPt            ; currently running thread
        EXPORT  StartOS
        EXPORT  SysTick_Handler
        IMPORT  Scheduler


SysTick_Handler                ; 1) Saves R0-R3,R12,LR,PC,PSR
    CPSID   I                  ; 2) Prevent interrupt during switch
	PUSH 	{R4-R11}		   ; 3) Save remaining regs r4-r11
	LDR 	R0, =RunPt		   ; 4) R0 = pointer to RunPt
	LDR     R1, [R0]		   ;    R1 = RunPt
	STR 	SP, [R1]		   ; 5) Store SP into TCB
	;LDR     R1, [R1, #4]      ; 6)	R1 = RunPt, new thread
	;STR     R1, [R0] 
	PUSH 	{R0,LR}
	BL		Scheduler
    POP 	{R0, LR}
	LDR     R1, [R0]
	LDR     SP, [R1]		   ; 7) new thread SP; SP = RunPt
	POP 	{R4-R11}		   ; 8) restore regs r4-r11
	CPSIE   I                  ; 9) tasks run with interrupts enabled
    BX      LR                 ; 10) restore R0-R3,R12,LR,PC,PSR

StartOS
    ;YOU IMPLEMENT THIS (same as Lab 3)
    LDR 	R0, =RunPt		   ; R0 = pointer to RunPt
	LDR		R1, [R0]		   ; R1 = RunPt
	LDR 	SP, [R1]		   ; SP = RunPt->sp
	POP     {R4-R11}		   ; Save registers R4-R11
	POP     {R0-R3}			   ; Save registers R0-R3
	POP 	{R12}			   ; Save register R12
	ADD     SP, SP, #4		   ; Skip LR and increment SP to point to PC
	POP		{LR}			   ; Pop PC into LR
	ADD     SP, SP, #4		   ; Skip PSR so SP points just below the stack
	CPSIE   I                  ; Enable interrupts at processor level
    BX      LR                 ; start first thread

    ALIGN
    END
