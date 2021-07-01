colorfuncport equ 3c8h   ;设置调色板功能端口
colorsetport equ 3c9h    ;设置调色板颜色端口
displayadd equ 0xa000    ;320*200下显示缓冲区地址
dptseg         equ    7e0h     ;DPT区段地址


jmp   start

gdt_size dw 32-1     ;GDT 表的大小 ;（总字节数减一）
gdt_base dd 0x00007e00 ;GDT的物理地址


start:
mov  ax, cs     ;从MBR跳转到此内核之后,CS=c20h ,IP=0。也即程序从偏移地址为0的地方开始放置
mov  ds, ax     ;那么就无需指定ORG，只需要把DS,ES和CS指向同一段即可。

call  setmode320
call  backgroud
call  colorset

;call   drawimg

mov     ax,dptseg
mov     es,ax          ;es用于gpt区寻址    gpt存放起始地址:0x00007e00h
call    createdpt

jmp     protectmode


setmode320:
mov ah,0
mov al,13h         ;320*200
int 10h
ret


setmode640:
mov AX,4F02H
mov bx,4101H        ;640*480  256色   第1个值4表示为要使用线性地址模式
int 10h
ret





;通过普通的0xa000方式演示画图
drawimg:           ;满屏画同一颜色
mov bl,2
mov ax,displayadd
mov es,ax
mov cx,0xffff
mov di,0
nextpoint:
mov  [es:di],bl   ;调色板颜色索引送往显存地址
inc di
loop  nextpoint
ret


backgroud:         ;背景色设置
mov dx,  colorfuncport
mov al,  0           ;建调色板索引0号
out dx,al

mov dx,  colorsetport   ;设置蓝色背景
mov al,0           ;R分量
out dx,al
mov al,0           ;G分量
out dx,al
mov al,35          ;B分量
out dx,al
ret

colorset:             ;显示色设置
mov dx,  colorfuncport
mov al,  1              ;建调色板索引1号
out dx,al

mov dx,  colorsetport     ;设置白色调色板
mov al,63           ;R分量
out dx,al
mov al,63           ;G分量
out dx,al
mov al,63          ;B分量
out dx,al

mov dx,  colorfuncport
mov al,  2                 ;建调色板索引2号
out dx,al

mov dx,  colorsetport     ;设置红色调色板
mov al,63           ;R分量
out dx,al
mov al,0           ;G分量
out dx,al
mov al,0          ;B分量
out dx,al

mov dx,  colorfuncport
mov al, 3           ;建调色板索引3号
out dx,al

mov dx,  colorsetport     ;设置黄色
mov al,30           ;R分量
out dx,al
mov al,30           ;G分量
out dx,al
mov al,0          ;B分量
out dx,al

mov dx,  colorfuncport
mov al, 4              ;建调色板索引4号
out dx,al

mov dx,  colorsetport     ;设置黑色
mov al,0           ;R分量
out dx,al
mov al,0           ;G分量
out dx,al
mov al,0          ;B分量
out dx,al

ret


;创建DPT子程序
createdpt:

lgdt [gdt_size] ;将DPT的地址和大小写入gdtr生效     默认DS

;创建0#描述符，它是空描述符，这是处理器的要求
mov dword [es:0x00],0x00
mov dword [es:0x04],0x00

;创建#1描述符，保护模式下的代码段描述符
mov dword [es:0x08],0xc200ffff
mov dword [es:0x0c],0x00409800

;创建#2描述符，保护模式下的数据段描述符（文本模式下的显示缓冲区）
;mov dword [es:0x10],0x8000ffff
;mov dword [es:0x14],0x0040920b

mov dword [es:0x10],0x0000ffff  ;（把DS的基地址定义为0）
mov dword [es:0x14],0x00c09200  ; (标志位G=1,表示以KB为单位)

;创建#3描述符，保护模式下的堆栈段描述符
mov dword [es:0x18],0x00007a00
mov dword [es:0x1c],0x00409600
ret

protectmode:
in al,0x92    ;打开A20地址线
or al,0000_0010B
out 0x92,al

cli ;保护模式下中断机制尚未建立，应禁止中断

mov eax,cr0  ;打开保护模式开关
or eax,1
mov cr0,eax

;进入保护模式... ...

jmp dword 0x0008:inprotectmode ;16位的描述符选择子：32位偏移

[bits 32]
inprotectmode:


;在屏幕上显示"Protect mode",验证保护模式下的数据段设置正确
mov ax,00000000000_10_000B ;加载数据段选择子(0x10)
mov ds,ax


;通过堆栈操作,验证保护模式下的堆栈段设置正确
mov ax,00000000000_11_000B ;加载堆栈段选择子
mov ss,ax                  ;7a00-7c00为此次设计的堆栈区
mov esp,0x7c00             ;7c00固定地址为栈底，


over :
jmp over  +0x24
