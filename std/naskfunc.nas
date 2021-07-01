[FORMAT "WCOFF"]				
[INSTRSET "i486p"]
[BITS 32]				
[FILE "naskfunc.nas"]		

GLOBAL	_asmfunc
GLOBAL	_asmfunc2
extern  _cfunc

[SECTION .text]

_asmfunc:	; void asmfunc(int addr, char data,int color);
		MOV		ECX,[ESP+4]		
		MOV		AL,[ESP+8]	
		MOV		[ECX],AL 
                INC             ECX
                MOV		AL,[ESP+12]
                MOV		[ECX],AL 
		RET


_asmfunc2: push            0x0c
           push            'A'
           push            0
           call            _cfunc
           pop             esi     ;这里pop指令只是为了平衡push
           pop             esi
           pop             esi

           push            0x0c
           push            '-'
           push            2
           call            _cfunc
           pop             esi     ;这里pop指令只是为了平衡push使ESP回到正确位置。
           pop             esi
           pop             esi

           push            0x0a
           push            '>'
           push            4
           call            _cfunc
           pop             esi     ;这里pop指令只是为了平衡push
           pop             esi
           pop             esi

           push            0x0a
           push            'C'
           push            6
           call            _cfunc
           pop             esi     ;这里pop指令只是为了平衡push
           pop             esi
           pop             esi

           ret
