TOOLPATH = ../z_tools/
RULEPATH =./haribote/

MAKE     = $(TOOLPATH)make.exe -r
NASK     = $(TOOLPATH)nask.exe
CC1      = $(TOOLPATH)cc1.exe -I$(RULEPATH) -Os -Wall -quiet
GAS2NASK = $(TOOLPATH)gas2nask.exe -a
OBJ2BIM  = $(TOOLPATH)obj2bim.exe
BIM2HRB  = $(TOOLPATH)bim2hrb.exe
RULEFILE = $(RULEPATH)haribote.rul
EDIMG    = $(TOOLPATH)edimg.exe
IMGTOL   = $(TOOLPATH)imgtol.com
COPY     = copy
DEL      = del
VMWARE   = vmware



default :
	$(MAKE) img


Loader.bin : Loader.asm Makefile
	NASM Loader.asm -o Loader.bin

Kernela.bin : Kernela.asm Makefile
	NASM Kernela.asm -o Kernela.bin


Kernelc.gas : Kernelc.c Makefile
	$(CC1) -o Kernelc.gas Kernelc.c

Kernelc.nas : Kernelc.gas Makefile
	$(GAS2NASK) Kernelc.gas Kernelc.nas

Kernelc.obj : Kernelc.nas Makefile
	$(NASK) Kernelc.nas Kernelc.obj Kernelc.lst

naskfunc.obj : naskfunc.nas Makefile
	$(NASK) naskfunc.nas naskfunc.obj naskfunc.lst

Kernelc.bim : Kernelc.obj naskfunc.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:Kernelc.bim stack:3136k map:Kernelc.map Kernelc.obj naskfunc.obj
# 3MB+64KB=3136KB

Kernelc.hrb : Kernelc.bim Makefile
	$(BIM2HRB) Kernelc.bim Kernelc.hrb 0

Kernel.bin : Kernela.bin Kernelc.hrb Makefile
	copy /B Kernela.bin+Kernelc.hrb Kernel.bin

JiangOS.img : Loader.bin Kernel.bin Makefile
	$(EDIMG)   imgin:../z_tools/fdimg0at.tek \
		wbinimg src:Loader.bin len:512 from:0 to:0 \
		copy from:Kernel.bin to:@: \
		imgout:JiangOS.img


img :
	$(MAKE) JiangOS.img

run :
	$(MAKE) img
	VMWARE  -x  ../../VWare/JiangOS/JiangOS.vmx

install :
	$(MAKE) img
	$(IMGTOL) w a: JiangOS.img

clean :
	-$(DEL) *.bin
	-$(DEL) *.lst
	-$(DEL) *.gas
	-$(DEL) *.obj
	-$(DEL) *.map
	-$(DEL) *.bim
	-$(DEL) *.hrb
	-$(DEL) Kernelc.nas

onlycode :
	$(MAKE) clean
	-$(DEL) JiangOS.img
