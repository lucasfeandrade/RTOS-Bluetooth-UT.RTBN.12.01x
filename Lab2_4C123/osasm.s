;/*****************************************************************************/
; OSasm.s: low-level OS commands, written in assembly                       */
; Runs on LM4F120/TM4C123/MSP432
; Lab 2 starter file
; February 10, 2016



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
	PUSH	{R4-R11}		   ; 3) Saving R4 to R11 into stack
	LDR		R0, =RunPt		   ; 4) R0 now points to run pointer
	LDR		R1, [R0]		   ;	R1 = RunPt
	STR     SP, [R1]           ; 5) Save stack pointer into TCB
;    LDR     R1, [R1,#4]        ; 6) R1 = RunPt->next summing 4
;    STR     R1, [R0]           ;    RunPt = R1
	PUSH 	{R0, LR}
	BL 		Scheduler
	POP		{R0, LR}
	LDR		R1, [R0]		   ; 6) R1 = RunPt, new thread
    LDR     SP, [R1]           ; 7) SP = RunPt->sp;
    POP     {R4-R11}           ; 8) restore registers r4 to r11
    CPSIE   I                  ; 9) tasks run with interrupts enabled
    BX      LR                 ; 10) restore R0-R3,R12,LR,PC,PSR

StartOS

    CPSIE   I                  ; Enable interrupts at processor level
	LDR     R0, =RunPt         ; initiate currently running thread
    LDR     R2, [R0]           ; R2 receives the value of RunPt
    LDR     SP, [R2]           ; new thread SP; SP = RunPt->stackPointer;
    POP     {R4-R11}           ; restore registers r4 to r11
    POP     {R0-R3}            ; restore registers r0 to r3
    POP     {R12}
    ADD     SP,SP,#4           ; discard LR from initial stack
    POP     {LR}               ; start location
    ADD     SP,SP,#4           ; discard PSR
    CPSIE   I                  ; Enable interrupts at processor level
    BX      LR                 ; start first thread

    ALIGN
    END
