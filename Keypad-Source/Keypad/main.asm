; Mk2.asm
;
; Created: 23/05/2018 14:35:13
; Author : Liam-Niklas Mannby
.include "m32Adef.inc"
.DSEG
;Keys            Defines variables to the hex code for the character being sent
.EQU leta=0x1c
.EQU letb=0x32
.EQU letc=0x21
.EQU letd=0x23
.EQU lete=0x24
.EQU letf=0x2b
.EQU letg=0x34
.EQU leth=0x33
.EQU leti=0x43
.EQU letj=0x3b
.EQU num0=0x45
.EQU num1=0x16
.EQU num2=0x1e
.EQU num3=0x26
.EQU num4=0x25
.EQU num5=0x2e
.EQU num6=0x36
.EQU num7=0x3d
.EQU num8=0x3e
.EQU num9=0x46
.EQU stop=0xf0 ;sent to signify next key byte is being released
;Responses
.EQU ACK=0xfa ;acknowlegde
.EQU BAT=0xaa ;self test passed
.EQU ECH=0xee ;echo, same as host command
.EQU RES=0xfe ;resend, same as host command
;Host Commands
.EQU LED1=0xed ;write LEDs, followed by another byte
.EQU RID=0xf2 ;read keyboard ID, respond with ack
.EQU SRR=0xf3 ;set repeat rate and delay
.EQU KEN=0xf4 ;enable keyboard after transmission failure
.EQU DIS=0xf5 ;disable keyboard
.EQU DEF=0xf6 ;resets keyboard to defaults
.EQU RST=0xff ;run self test
.CSEG
INIT:
	LDI r16, 0b00000000 ;Values for output/input ports
	LDI r17, 0b10000000
	LDI r18, 0b00000001
	OUT DDRA, r16 ;all pins in port A as inputs
	OUT DDRB, r17 ;only pin7 as output on port B
	OUT DDRC, r16 ;all pins in port C as inputs
	OUT DDRD, r18 ;only pin0 as output on port D
Main: ;Scans inputs and branch off if any pin on any port is activated, loops
	IN r23,PINA
	CPSE r23,r0 ;compares the value of the inputs on porta against zero, goes to next step if not equal
	jmp a_h
	IN r23,PINC
	CPse r23,r0
	jmp i_5
	IN r23,PIND
	CPse r23,r0
	jmp six_9
	jmp Main
Recieve: ;stores insctruction sent by the host
	LDI r30,8
	loop1:
	call Wait
	sbi PORTD,0
	call Wait
	cbi PORTD,0
	IN r25,PIND
	ANDI r25,0b00000010
	LSR r25
	ADD r22,r25
	LSL r22
	dec r30
	BRNE loop1
	LDI r30,8
	loop2:
	call Wait
	nop
	dec r30
	brne loop2
	jmp Incoming
Incoming: ;checks which instruction was sent by host where instruction  is stored in r22 and compared against constants
	CPI r22,LED1
	BREQ led2
	CPI r22,RID
	BREQ read_id
	CPI r22,SRR
	BREQ srr1
	CPI r22,KEN
	BREQ enable
	CPI r22,DIS
	BREQ disable
	CPI r22,DEF
	BREQ default
	CPI r22,RST
	BREQ self_test
	CPI r22,ECH
	BREQ echo_in
	CPI r22,RES
	BREQ resend_in
	LDI r19,RES
	call Send
	jmp Main
led2: ;waits for two bytes of data then responds with ack
	loop3:
	LDI r30,24
	call Wait
	dec r30
	brne loop3
	LDI r19, ACK
	call Send
	jmp Main
read_id:;haven't set an ID
	LDI r19, ACK
	call Send
	jmp Main
srr1:;waits for repeat rate and typematic dealy bits then responds with ack
	LDI r30,24
	loop4:
	call Wait
	dec r30
	brne loop4
	LDI r19, ACK
	call Send
	jmp Main	
enable:;ignoring this host command and just terminating giving correct response without doing anything
	LDI r19, ACK
	call Send
	jmp Main
disable:;ignoring this host command and just terminating giving correct response without doing anything
	LDI r19, ACK
	call Send
	jmp Main
default: ;defaults are irrelevent in this version so just respond with "acknowledge" signal
	LDI r19, ACK
	call Send
	jmp Main
self_test: ;Respond saying self test passed
	LDI r19,BAT
	call Send
	jmp Main
echo_in: ;respond with echo
	LDI r19,ECH
	call send
	jmp Main
resend_in:
	call Send
	jmp Main
a_h: ;Checks each pin in port a
	LDI r27,1
	CPse r23,r27 ;checks pin0
	cpse r0,r0
	jmp loada ;jumps to next stage if pin is active
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp loadb;jumps to next stage if pin is active
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp loadc;jumps to next stage if pin is active
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp loadd;jumps to next stage if pin is active
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp loade;jumps to next stage if pin is active
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp loadf;jumps to next stage if pin is active
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp loadg;jumps to next stage if pin is active
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp loadh;jumps to next stage if pin is active
	jmp Main ;returns to the start of the program if something went wrong
i_5: ;checks each pin in port c, same comments as block above
	LDI r27,1
	CPse r23,r27
	cpse r0,r0
	jmp loadi
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp loadj
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp load0
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp load1
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp load2
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp load3
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp load4
	LSL r27
	CPse r23,r27
	cpse r0,r0
	jmp load5
	jmp Main
six_9: ;checks the last four and second pins on port d, same comments as block above
	LDI r27,2
	CPse r23,r27
	cpse r0,r0
	jmp Recieve
	LDI r27,0b10000000
	CPse r23,r27
	cpse r0,r0
	jmp load6
	LSR r27
	CPse r23,r27
	cpse r0,r0
	jmp load7
	LSR r27
	CPse r23,r27
	cpse r0,r0
	jmp load8
	LSR r27
	CPse r23,r27
	cpse r0,r0
	jmp load9
	jmp Main
;the following load segments load r19 with the value of the key being pressed then use the send subroutine to send the key press and release signals then goes back to the start of the program
loada:
	LDI r19,leta
	call Send
	LDI r19,stop
	call send
	LDI r19,leta
	call Send
	jmp Main
loadb:
	LDI r19,letb
	call Send
	LDI r19,stop
	call send
	LDI r19,letb
	call Send
	jmp Main
loadc:
	LDI r19,letc
	call Send
	LDI r19,stop
	call send
	LDI r19,letc
	call Send
	jmp Main
loadd:
	LDI r19,letd
	call Send
	LDI r19,stop
	call send
	LDI r19,letd
	call Send
	jmp Main
loade:
	LDI r19,lete
	call Send
	LDI r19,stop
	call send
	LDI r19,lete
	call Send
	jmp Main
loadf:
	LDI r19,letf
	call Send
	LDI r19,stop
	call send
	LDI r19,letf
	call Send
	jmp Main
loadg:
	LDI r19,letg
	call Send
	LDI r19,stop
	call send
	LDI r19,letg
	call Send
	jmp Main
loadh:
	LDI r19,leth
	call Send
	LDI r19,stop
	call send
	LDI r19,leth
	call Send
	jmp Main
loadi:
	LDI r19,leti
	call Send
	LDI r19,stop
	call send
	LDI r19,leti
	call Send
	jmp Main
loadj:
	LDI r19,letj
	call Send
	LDI r19,stop
	call send
	LDI r19,letj
	call Send
	jmp Main
load0:
	LDI r19,num0
	call Send
	LDI r19,stop
	call send
	LDI r19,num0
	call Send
	jmp Main
load1:
	LDI r19,num1
	call Send
	LDI r19,stop
	call send
	LDI r19,num1
	call Send
	jmp Main
load2:
	LDI r19,num2
	call Send
	LDI r19,stop
	call send
	LDI r19,num2
	call Send
	jmp Main
load3:
	LDI r19,num3
	call Send
	LDI r19,stop
	call send
	LDI r19,num3
	call Send
	jmp Main
load4:
	LDI r19,num4
	call Send
	LDI r19,stop
	call send
	LDI r19,num4
	call Send
	jmp Main
load5:
	LDI r19,num5
	call Send
	LDI r19,stop
	call send
	LDI r19,num5
	call Send
	jmp Main
load6:
	LDI r19,num6
	call Send
	LDI r19,stop
	call send
	LDI r19,num6
	call Send
	jmp Main
load7:
	LDI r19,num7
	call Send
	LDI r19,stop
	call send
	LDI r19,num7
	call Send
	jmp Main
load8:
	LDI r19,num8
	call Send
	LDI r19,stop
	call send
	LDI r19,num8
	call Send
	jmp Main
load9:
	LDI r19,num9
	call Send
	LDI r19,stop
	call send
	LDI r19,num9
	call Send
	jmp Main
Send: ;controls clock and data line to send character
	LDI r31,0b11111111
	LDI r20,0b00001000 ;register used for counting down from 8
	cbi PORTD,0;start of signal
	call Wait
	cbi PORTB,7;bring data low, start bit
	call Wait
	sbi PORTD,0
	call Wait
	cbi PORTD,0
	loop_s:;loops 8 times
	call Wait
	sbi PORTD,0 ;Bring clock high
	nop ;Small time delay between clock up and data change
	nop
	nop
	nop
	nop
	OUT PORTB, r19 ;set data line to aappropraite value
	call Wait
	nop;extra time delay
	nop
	nop
	nop
	cbi PORTD,0 ;bring clock low
	LSL r19 ;shifts data along
	DEC r20 ;decreases counting register
	brne loop_s ;checks if counting register is zero, repeats if not
	LSR r19 ;returns r19 MSB to original place
	EOR r19,r31;checks if last bit sent is high or low
	call Wait
	sbi PORTD,0
	nop ;Small time delay between clock up and data change
	nop
	nop
	nop
	nop
	OUT PORTB,r19;sends opposite of last bit (parity bit)
	call Wait
	cbi PORTD,0
	call wait
	nop
	nop
	nop
	nop
	sbi PORTD,0 ;brings clockline high
	nop
	nop
	nop
	nop
	sbi PORTB,7 ;brings dataline high
	ret
Wait: ;waits for 3569 nanoseconds, 43 clocks
	LDI r21, 13
	loop:
	dec r21
	brne loop
	ret