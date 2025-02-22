/*
 * asm_func.s
 *
 *  Created on: 7/2/2025
 *      Author: Hou Linxin
 */
   .syntax unified
	.cpu cortex-m4
	.fpu softvfp
	.thumb

		.global asm_func

@ Start of executable code
.section .text

@ CG/[T]EE2028 Assignment 1, Sem 2, AY 2024/25
@ (c) ECE NUS, 2025

@ Write Student 1’s Name here: A0254452H LIU SIYI
@ Write Student 2’s Name here:

@ Look-up table for registers:

@ R0 Building pointer; later used as temporary register for array size calculation
@ R1 Entry pointer; also used to hold constant 12 when filling a section
@ R2 Exit pointer
@ R3 Result pointer
@ R4 Constant SECTION_MAX (12)
@ R5 End pointer of the building array
@ R6 Loop counter for entry values (5 entries)
@ R7 Working pointer into the building array during entry processing
@ R8 Backup copy of the original building pointer (for resetting R7)
@ R10 Temporary register for updated section value during exit processing
@ R11 Temporary register for exit value during exit processing
@ R12 Temporary register for current entry value (number of cars to allocate)
@ LR  Link register (holds return address)

@ write your program from here:

asm_func:
        PUSH    {R4-R12, LR}
        MOV     R8, R0				// preserve original building pointer in R8
        MOV     R7, R0				// working pointer
        MOV     R4, #12				// SECTION_MAX
        MOV     R0, #6				// Total section
        LSL     R0, R0, #2			// Byte size of the building array
        ADD     R5, R7, R0			// Store the end address of building array
        MOV     R6, #5				// No. of entry value
entry_loop:
        CMP     R6, #0				// Check if loop complete
        BEQ     entries_done		// branch to entries done when there is no more entry
        LDR     R12, [R1], #4		// load the entry into R12 then increase R1 to get next entry
entry_inner_loop:
        CMP     R12, #0				// check if the current entry are slot in
        BEQ     entry_done			// if all slot in, branch to entry_done
        LDR     R0, [R7]			// load the current section's car number into R0
        SUB     R0, R4, R0			// check how many empty slot left
        CMP     R0, #0				// if no more empty slot
        BEQ     no_space			// branch to no_space
        CMP     R12, R0				// check if it is enough to fit in
        BLE     add_partial			// If R12 is less than or equal to the available space branch to add_partial
        MOV     R1, R4				// use R1 to temporaily store 12, which is SECTION_MAX
        STR     R1, [R7]			// change the current section's car number to 12
        SUB     R12, R12, R0		// check how many car is left unparked in current entry
no_space:
        ADD     R7, R7, #4			// No space in current section, move to next
        CMP     R7, R5				// Compares the updated section pointer with the end pointer
        BLT     entry_inner_loop	// if updated section pointer is lesser, branch to entry_inner_loop
        MOV     R12, #0				// if updated section exceed last section, set R12 to 0 to stop the program
        B       entry_inner_loop	// branch back to entry_inner_loop
add_partial:
        LDR     R0, [R7]			// load the current section's car number into R0
        ADD     R0, R0, R12			// add in the car entry into current section
        STR     R0, [R7]			// store the new current section's car number
        MOV     R12, #0				// R12 convert to 0
        B       entry_inner_loop	// branch back to entry_inner_loop
entry_done:
        SUBS    R6, R6, #1			// mark one entry done
        B       entry_loop			// branch back to entry_loop
entries_done:
        MOV     R7, R8				// Resets the pointer R7 back to the start of the building array
        MOV     R0, #6				// Loads the value 6 into R0 to set up a loop counter for processing all 6 sections during exit processing.
exit_loop:
        CMP     R0, #0				// Check if exit loop counter is 0
        BEQ     finish				// if so branch to finish
        LDR     R10, [R7], #4		// Loads the updated parked-car count from the current section into R10 and increase R7 to get next section
        LDR     R11, [R2], #4		// Loads the current exit value into R11
        SUB     R10, R10, R11		// subtract to update the cuurent section's car number after car exits
        STR     R10, [R3], #4		// store the final section's car number into result array
        SUBS    R0, R0, #1			// drease the exit counter by 1
        B       exit_loop			// branch back to exit_loop
finish:
        POP     {R4-R12, LR}
        BX      LR
