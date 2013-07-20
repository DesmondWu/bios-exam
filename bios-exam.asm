;
; bios-exam 
; Copyright (C) 2011 Desmond Wu <wkunhui@gmail.com>
;
; This software is licensed under the terms of the GNU General Public
; License version 2, as published by the Free Software Foundation, and
; may be copied, distributed, and modified under those terms.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
.model small
.stack
.586p
.data
 gda dw      0018h,0000h,0000h
 gdt  db      000h,000h,00h,00h,00h,00h,00h,00h ;00 Null
         db      0ffh,0ffh,00h,00h,00h,92h,0h,00h ;08 mem 1M
         db      0ffh,0ffh,00h,00h,00h,92h,0h,00h ;10 data 
 
dbcolor db ? ;0X on,XX off
dbvar1 db ?
dwvar1 dw ?
ddvar1 dd ?
dwBusIdx dw ?
message0 db 'Exam Ver 0.13 by Desmond',0dh,0ah,'$'
message1 db 'SMBUS SLVA:A0	SMB_base:','$'
statusbar db 'id)vender',09h,'  device','  bus',09h,'  dev',09h,'  fun',0dh,0ah,'$'
mainMenu db 0dh,0ah
		 db '  1)PCI Scan',0dh,0ah
		 db '  2)SPD Read',0dh,0ah
		 db '  3)CPU Infor',0dh,0ah
		 db '  4)Memory Read',0dh,0ah
		 db '  5)EC Ram Dump',0dh,0ah
		 db '  6)ASPM detect',0dh,0ah
		 db '  7)SMI',0dh,0ah
		 db '  8)EDID',0dh,0ah
		 db '  9)VERB Table',0dh,0ah
		 db '  A)MicroCode',0dh,0ah
		 db '  B)SATA Info',0dh,0ah
		 db '  C)RTC Wake Up',0dh,0ah
		 db '  D)Display Device Control',0dh,0ah		 
		 db '$'
		 db '  ?)SMBIOS',0dh,0ah
		 db '  ?)CPU temprature',0dh,0ah

		 
		 
buffer dw 256 dup(0)
dbBusIdxCnt db ?
dbMenuIdxCnt db 13
count1 db ?
count2 db ?

row db ?
column db ?
menuLv db ? ;00 main 1x pci scan 2x spd read
subMenuLv db ?

SMB_STS db ?
SMB_base dw ?
SPD_Addr db ?

sCpuName db 'CPU: ','$'
sCpuFreq db 'Freq: XXXXMHZ','$'
ddTime   dd      ?
ddRtdsc1 dd ?
ddRtdsc2 dd ?

dbASPMtmp db ?
dbASPMtmp2 db ?
sMemAddr db 'Memory Addr:','$'

sECRam db 'EC Ram','$'

sAspmDt db 'ASPM Dectect',0dh,0ah
	db 'id)vender',09h,'  device','  bus',09h,'  dev',09h,'  fun',09h,'    sL0s  sL1   eL0s  eL1 ',0dh,0ah,'$'
sAspmT db'  true','$'
sAspmF db'  fals','$'

sSMImenu db 0dh,0ah
	 db '  1)Restart PC',0dh,0ah
	 db '  2)ShutDown PC','$'

dwMfID dw ?
dwPID dw ?
ddSN dd ?
dbWeek db ?
dbYear db ?
dbVersion db ?
dbReV db ?
sVerbCmdDone db 'Send Verb Commond done!!','$'
sEDIDtitle db 'EDID Raw Data',0dh,0ah,'$'
sEDIDInfor db 0dh,0ah,0dh,0ah
	   db 'Manufacturer ID:',0dh,0ah
	   db 'Product ID :',0dh,0ah
	   db 'Serial Number:',0dh,0ah
	   db 'Week:',0dh,0ah
	   db 'Year:',0dh,0ah
	   db 'EDID Version:',0dh,0ah
	   db 'Descriptor Block 1:',0dh,0ah
	   db 'Descriptor Block 2:',0dh,0ah
	   db 'Descriptor Block 3:',0dh,0ah
	   db 'Descriptor Block 4:',0dh,0ah,'$'
sEDIDstrBuf db 32 dup(0)

sVerbTitle db 'High Definition Audio / VerbTable',0dh,0ah
	   db 0dh,0ah
	   db 0dh,0ah;'CAd:   /  ,NID:   /  ',0dh,0ah
	   db 'Vendor ID:',0dh,0ah
	   db 'Device ID:',0dh,0ah
	   db 'Subsystem ID:',0dh,0ah
	   db 0dh,0ah,'$';'Config Default:','$'
ddVerbVar1 dd ?
dwSDIN dw ?
dbCAdidx db ?
dbCAdvar1 db ?
dbCAdTotal db ?
dbNidStart db ?
dbNidTotal db ?
dbNididx db ?
dbNidvar1 db ?
dwVerbVId dw ?
dwVerbDId dw ?
ddVerbSId dd ?
ddVerbCfg dd ?


sMicrotitle db 'Micro Code Data',0dh,0ah
	    db 0dh,0ah
	    db 'Processor ID:',0dh,0ah
	    db 'Version:',0dh,0ah
	    db '$'
ddMCVer dd 2 dup(0)

sSatastrBuf db 64 dup(0)
sSatatitle db 'SATA Info',0dh,0ah
	    db '$'
sSataName db 'Model number:',0dh,0ah
	  db 'Serial Number:',0dh,0ah
	  db 'Firmware revision:',0dh,0ah
	  db '$'

dbRTCH db ?
dbRTCM db ?
dbRTCS db ?
sRTCtitle db 'RTC WakeUp Confuguration',0dh,0ah
	  db '$'
sRTCDone db 'RTC Config done!!','$'
sRTCName db 'Hour:',0dh,0ah
	  db 'Minute:',0dh,0ah
	  db 'Second:',0dh,0ah
	  db '$'
dbDDCattach db ?
dbDDCstatus db ?
dbDDCcontrol db ?
sDDCtitle  db 'Display Device Control',0dh,0ah
;	  db '$'		  
;sDDCmenu db 0dh,0ah
	 db 'Device Status',0dh,0ah
	 db 'CRT:                                        ',0dh,0ah	 
	 db 'LCD:                                        ',0dh,0ah	 
	 db 0dh,0ah	
	 db 'Device Control',0dh,0ah
	 db 'CRT:',0dh,0ah	 
	 db 'LCD:',0dh,0ah		 
	 db '$'
sDDCattach db ' -Attached- ','$'
sDDCconnect db ' -Connected- ','$'
sDDCT db 'on ','$'
sDDCF db 'off','$'

dwSataCmdAdr dw ?
strBuffer db 256 dup(0)
strBlenth db 1 dup(0)
ddScanData dd ?
dbScanLen db 1 dup (0)
ddScanStatus db 1 dup(0) ;h:idx l: b1 on/off
ddScanCursor dw 1 dup(0) ;h x,l y

dwPoingCont dw ?
.code
main proc 
    mov ax,@data
    mov ds,ax
	

	call init
	call menu00	

	call funUserInterface

    mov ax, 0600h
    mov bh, 7
    mov cx, 0
    mov dx, 0184fh
    int 10h
	
    mov ah, 2
    mov bh, 0
    mov dx, 0
    int 10h

    mov ah, 4ch
    int 21h
main endp


init proc
	pusha

	
	popa
	ret
init endp

pollingfunc proc
	pusha
	mov ah,menuLv
	cmp ah,30h
    	jne pfNextSub1
	call pfCpuFreq
pfNextSub1:
	cmp ah,50h
	jne pfNextSub2
	call ecRead
pfNextSub2:
	cmp ah,90h
	jne pfNextSub3
	cmp dwPoingCont,1
	jne pfNextSub30
	call menu90
	mov dwPoingCont,0
	jmp pfNextSub3
pfNextSub30:
	cmp dwPoingCont,0
	je pfNextSub3
	dec dwPoingCont
pfNextSub3:
	cmp ah,0C0h
	jne pfNextSub4
	cmp dwPoingCont,1
	jne pfNextSub40
	call menuC0

	mov dx,dwvar1 ;clear rtc status
	add dx,01h
	mov al,4h
	out dx,al

	mov dx,dwvar1 ;shutdown
	add dx,05h
	mov al,34h
	out dx,al


	mov dwPoingCont,0
	jmp pfNextSub4
pfNextSub40:
	cmp dwPoingCont,0
	je pfNextSub4
	dec dwPoingCont
pfNextSub4:
	cmp ah,0D0h
	jne pfNextSub5
	dec dwPoingCont
	cmp dwPoingCont,0
	jne pfNextSub5
	mov dwPoingCont,0ffffh
	;call funUpdateDDC


pfNextSub5:
	popa
	ret
pollingfunc endp
funUserInterface proc
	pusha
pressKey:
	call pollingfunc
	in al, 60h     ; Read Status byte
        and al, 80h     ; Test IBF flag (Status<1>)
        jnz pressKey    ; Wait for IBF = 1
        in al, 60h     ; Read input buffer 
	mov ah,al
pkWaitLoop:
	in al,60h
	and al,80h
	jz pkWaitLoop

    	;mov ah,0
 ;interupt get key
	;int 16h
    cmp ah,01h ;exc
    je exitFUI
    cmp ah,10h ;q
    je exitFUI
    cmp ah,48h
    je upArrowAct
    cmp ah,50h
    je downArrowAct
    cmp ah,4bh
    je leftArrowAct         
    cmp ah,1ch
    je excAct   
    cmp ah,4dh
    je excAct     

	mov dl,ddScanStatus
	and dl,01h
	cmp dl,01h
	jne pressKey

	mov al,0ah
	cmp ah,1eh
	je pkScanNonZero
	mov al,0bh
	cmp ah,30h
	je pkScanNonZero
	mov al,0ch
	cmp ah,2eh
	je pkScanNonZero
	mov al,0dh
	cmp ah,20h
	je pkScanNonZero
	mov al,0eh
	cmp ah,12h
	je pkScanNonZero
	mov al,0fh
	cmp ah,21h
	je pkScanNonZero


	cmp ah,0bh
	ja pressKey
	mov al,ah
	dec al
	cmp ah,0bh
	jne pkScanNonZero
	mov al,0
pkScanNonZero:	



	mov edx,ddScanData
	shl edx,4 
	or al,dl
	mov dl,al
	mov ddScanData,edx
	mov ddvar1,edx
	mov dwvar1,dx
	mov dbvar1,dl

	call getdword
    jmp pressKey
    
leftArrowAct:
	mov ah,menuLv
	cmp ah,00h
    	je leftA_menu00

	cmp ah,11h
	je leftA_menu11
	and ah,0fh
	cmp ah,0
	je leftA_menuX0
	jmp pressKey
	
leftA_menu00:
	jmp pressKey
	

leftA_menuX0:
	call menu00
	jmp pressKey	
  
leftA_menu11:
	call menu10	
	jmp pressKey
	
excAct:
	mov ah,menuLv
    cmp ah,00h
    je excA_menu00
    cmp ah,20h
    je excA_menu20
    cmp ah,10h
    je excA_menu10     
	cmp ah,40h
	je excA_menu40
	cmp ah,70h
	je excA_menu70
	cmp ah,90h
	je excA_menu90
	cmp ah,0c0h
	je excA_menuC0
	cmp ah,0d0h
	je excA_menuD0	
    jmp pressKey

excA_menu00:
	mov ah,row
    	cmp ah,02h
   	je excAM_sub00
   	cmp ah,03h
    	je excAM_sub01
	cmp ah,04h
	je excAM_sub02
	cmp ah,05h
	je excAM_sub03
	cmp ah,06h
	je excAM_sub04
	cmp ah,07h
	je excAM_sub05
	cmp ah,08h
	je excAM_sub06
	cmp ah,09h
	je excAM_sub07
	cmp ah,0ah
	je excAM_sub08
	cmp ah,0bh
	je excAM_sub09
	cmp ah,0ch
	je excAM_sub0a
	cmp ah,0dh
	je excAM_sub0b
	cmp ah,0eh
	je excAM_sub0c
	jmp pressKey
	
excAM_sub00:
	call menu10
	jmp pressKey
	
excAM_sub01:
	mov  menuLv,20h
	call disableCursor
	call funCLS
	call getSMBbase
	call spdRead
	jmp pressKey
excAM_sub02:
	mov menuLv,30h
	call disableCursor
	call funCLS
	call CpuInfor	
	jmp pressKey
	
excAM_sub03:
	mov menuLv,40h
	call menu40
	jmp pressKey

excAM_sub04:
	mov menuLv,50h
	call disableCursor
	call ecRead
	jmp pressKey

excAM_sub05:
	mov menuLv,60h
	call disableCursor
	call aspmDectect
	jmp pressKey
excAM_sub06:
	mov menuLv,70h
	call funCLS
	mov dx,offset sSMImenu
    	mov ah,9
   	int 21h
	mov ax,0202h

	mov row,al
	mov column,ah
	call cursorDis
	jmp pressKey
excAM_sub07:
	mov menuLv,80h
	call disableCursor
	call funEDID
	jmp pressKey
excAM_sub08:
	mov menuLv,90h	
	mov ddScanCursor,0c03h
	mov subMenuLv,0
	call menu90
	jmp pressKey
excAM_sub09:
	mov menuLv,0A0h
	call disableCursor
	call funMicroCodeVN
	jmp pressKey
excAM_sub0a:
	mov menuLv,0B0h
	call disableCursor
	call funSataInfo
	jmp pressKey
excAM_sub0b:
	mov menuLv,0C0h
	mov ddScanCursor,0c03h
	mov subMenuLv,0
	call menuC0
	jmp pressKey
excAM_sub0c:
	mov menuLv,0D0h
	call funCLS
	call disableCursor
	mov ax,05f64h
	mov bh,01h
	int 10h	
	mov dbDDCcontrol,cl	
	call funUpdateDDC
	jmp pressKey	
excA_menuD0:
	call funSetDDC
	call funUpdateDDC
	jmp pressKey
excA_menuC0:
	call funRTCUpdate
	call funRTCWakeUp
	call menuC0
	mov row,5
	mov column,0
	call cursorDis 
	mov dx,offset sRTCDone
	mov ah,9
	int 21h
	mov dwPoingCont,0ffffh
	jmp pressKey
excA_menu90:
	call funWVerb
	mov row,9
	mov column,16
	call cursorDis 
	mov dx,offset sVerbCmdDone
	mov ah,9
	int 21h
	mov dwPoingCont,0ffffh
	jmp pressKey
excA_menu70:
	call funSMI
	jmp pressKey
excA_menu40:
	call protectMemRead
	call menu40
	jmp pressKey
excA_menu20:
	jmp pressKey
excA_menu10:	
    call funCLS
    call IdxToBusData
    call prtCRLF
    call prt_PciMem
	mov menuLv,11h	
	;menu 11h
    jmp pressKey
    
upArrowAct:
	mov ah,menuLv
    cmp ah,00h
    je upA_menu00
    cmp ah,20h
    je upA_menu20
    cmp ah,10h
    je upA_menu10   
	cmp ah,70h
	je upA_menu70
	cmp ah,90h
	je upA_menu90
	cmp ah,0C0h
	je upA_menuC0
	cmp ah,0D0h
	je upA_menuD0
    jmp pressKey
	
upAM00_sub00:	
	mov al,dbMenuIdxCnt
	add al,2
	mov row,al
upA_menu00:
    mov al,row
    cmp al,2
    jna upAM00_Sub00
    dec row
	call cursorDis
	jmp pressKey
upA_menuD0:
	mov al,dbDDCcontrol
	xor al,10h
	mov dbDDCcontrol,al
	call funUpdateDDC
	jmp pressKey
upA_menuC0:  
	call funRTCUpdate
 	dec subMenuLv
    	cmp subMenuLv,0ffh
    	je upAMC0_sub00  
	call menuC0
   	jmp pressKey
upAMC0_sub00:	
	mov subMenuLv,02h
	call menuC0
   	jmp pressKey

upA_menu90:  
 	dec subMenuLv
    	cmp subMenuLv,0ffh
    	je upAM90_sub00  
	call menu90
   	jmp pressKey
upAM90_sub00:	
	mov subMenuLv,03h
	call menu90
   	jmp pressKey
upA_menu70:
    mov al,row
    cmp al,2
    jna pressKey
    dec row
	call cursorDis
	jmp pressKey
	
upA_menu20:
	jmp pressKey
	
upA_menu10:
    mov al,row
    cmp al,2
    jna pressKey    
    dec row
    call IdxToBusData   
	call cursorDis		
    jmp pressKey
	
downArrowAct: 
	mov ah,menuLv
    cmp ah,00h
    je downA_menu00
    cmp ah,20h
    je downA_menu20
    cmp ah,10h
    je downA_menu10    
	cmp ah,70h
	je downA_menu70 
	cmp ah,90h
	je downA_menu90 
	cmp ah,0c0h
	je downA_menuC0
	cmp ah,0D0h
	je upA_menuD0
    jmp pressKey
downAM00_sub00:	
	mov row,1
downA_menu00:	
    mov al,row
    cmp al,dbMenuIdxCnt
    jnbe downAM00_sub00

    inc row   
	call cursorDis
	jmp pressKey

downA_menuC0:  
	call funRTCUpdate
   	inc subMenuLv
    	cmp subMenuLv,02h
    	jnbe downAMC0_sub00	
	call menuC0
   	jmp pressKey
downAMC0_sub00:	
	mov subMenuLv,0h
	call menuC0
   	jmp pressKey
downA_menu90:  
   	inc subMenuLv
    	cmp subMenuLv,03h
    	jnbe downAM90_sub00	
	call menu90
   	jmp pressKey
downAM90_sub00:	
	mov subMenuLv,0h
	call menu90
   	jmp pressKey
downA_menu70:  
    mov al,row
    cmp al,2
    jnbe pressKey
	call cursorDis
    inc row   
	call cursorDis
    jmp pressKey	
downA_menu20:
	jmp pressKey
downA_menu10:  
    mov al,row
    cmp al,dbBusIdxCnt
    jnbe pressKey
	call cursorDis
    inc row   
    call IdxToBusData    
	call cursorDis
    jmp pressKey
	
exitFUI:   
    popa
    ret	
funUserInterface endp

menuC0 proc
	pusha
	call funCLS
	mov dx,offset sRTCtitle
    	mov ah,9
   	int 21h   
	mov dx,offset sRTCName
    	mov ah,9
   	int 21h   
	mov dbcolor,80h

	mov row,2
	mov column,5
	call cursorDis
	mov dl,dbRTCH
	mov dbvar1,dl
	call prtbyte

	mov row,3
	mov column,7
	call cursorDis
	mov dl,dbRTCM  
	mov dbvar1,dl
	call prtbyte

	mov row,4
	mov column,7
	call cursorDis
	mov dl,dbRTCS  
	mov dbvar1,dl
	call prtbyte



	mov ddScanData,0 
	cmp subMenuLv,00h
	je menuC0sub00
	cmp subMenuLv,01h
	je menuC0sub01
	cmp subMenuLv,02h
	je menuC0sub02
	jmp menuC0Exit
menuC0sub00:
	mov ddScanCursor,0502h
	mov dbScanLen,2
	mov dl,dbRTCH
	mov dbvar1,dl
	call getdword
	jmp menuC0Exit
menuC0sub01:
	mov ddScanCursor,0703h
	mov dbScanLen,2
	mov dl,dbRTCM 
	mov dbvar1,dl
	call getdword
	jmp menuC0Exit
menuC0sub02:
	mov ddScanCursor,0704h
	mov dbScanLen,2
	mov dl,dbRTCS 
	mov dbvar1,dl
	call getdword
	jmp menuC0Exit

menuC0Exit:	


	popa
	ret
menuC0 endp

menu90 proc
	pusha
	call funCLS
	mov dx,offset sVerbTitle
	mov ah,9
	int 21h

	mov dbcolor,80h

;	mov row,8
;	mov column,16
;	call cursorDis
	mov ddVerbVar1,0f0000h
	call funVerbCmd;get CAd
;	mov edx,ddVerbVar1
;	mov ddvar1,edx
;	call prtdword


;	mov row,9
;	mov column,16
;	call cursorDis
;	mov dx,dwSDIN     
;	mov dwvar1,dx
;	call prtword

;	mov dl,subMenuLv
;	mov dbvar1,dl
;	call prtbyte

	
	call funRVerb
	
;	mov row,3
;	mov column,5
;	call cursorDis
;	mov dl,dbCAdidx 
;	inc dl
;	mov dbvar1,dl
;	call prtbyte
;
;	mov row,3
;	mov column,8
;	call cursorDis
;	mov dl,dbCAdTotal  
;	mov dbvar1,dl
;	call prtbyte
;
;	mov row,3
;	mov column,16
;	call cursorDis
;	mov dl,dbNididx 
;	inc dl
;	mov dbvar1,dl
;	call prtbyte
;
;	mov row,3
;	mov column,19
;	call cursorDis
;	mov dl,dbNidTotal 
;	mov dbvar1,dl
;	call prtbyte
;
	mov row,4
	mov column,11
	call cursorDis
	mov dx,dwVerbVId  
	mov dwvar1,dx
	call prtword

	mov row,5
	mov column,11
	call cursorDis
	mov dx,dwVerbDId   
	mov dwvar1,dx
	call prtword

	mov row,6
	mov column,14
	call cursorDis
	mov edx,ddVerbSId    
	mov ddvar1,edx
	call prtdword
;
;	mov row,7
;	mov column,16
;	call cursorDis
;	mov edx,ddVerbCfg     
;	mov ddvar1,edx
;	call prtdword
	;-s
	mov ddScanData,0
	mov ddScanCursor,0e06h
	mov dbScanLen,8
	mov edx,ddVerbSId 
	mov ddvar1,edx
	call getdword
	;-e

;	mov ddScanData,0
;	cmp subMenuLv,00h
;	je menu90sub00
;	cmp subMenuLv,01h
;	je menu90sub01
;	cmp subMenuLv,02h
;	je menu90sub02
;	cmp subMenuLv,03h
;	je menu90sub03
;	jmp menu90Exit
;menu90sub00:
;	mov ddScanCursor,0503h
;	mov dbScanLen,2
;	mov dl,dbCAdidx
;	inc dl
;	mov dbvar1,dl
;	call getdword
;	jmp menu90Exit
;menu90sub01:
;	mov ddScanCursor,1003h
;	mov dbScanLen,2
;	mov dl,dbNididx 
;	inc dl
;	mov dbvar1,dl
;	call getdword
;	jmp menu90Exit
;menu90sub02:
;	mov ddScanCursor,0e06h
;	mov dbScanLen,8
;	mov edx,ddVerbSId 
;	mov ddvar1,edx
;	call getdword
;	jmp menu90Exit
;menu90sub03:
;	mov ddScanCursor,1007h
;	mov dbScanLen,8
;	mov edx,ddVerbCfg  
;	mov ddvar1,edx
;	call getdword
;	jmp menu90Exit
;menu90Exit:	
;
	popa
	ret
menu90 endp
menu40 proc
	pusha
	mov ddScanStatus,01h
	mov ddScanCursor,0c01h
	call funCLS
	
	
	mov dx,offset sMemAddr
    	mov ah,9
   	int 21h
	call prtCRLF
	mov strBlenth,0ffh
	call prtPage

	mov dbScanLen,8
	call getdword
	popa
	ret
menu40 endp 
menu10 proc
	pusha
	mov menuLv,010h

	call funCLS
 
	
	mov dx,offset statusbar
    mov ah,9
    int 21h  	
	
	call ScanPciDev 
	mov row,2
	mov column,1
	call cursorDis
	popa
	ret
menu10 endp

menu00 proc
	pusha
	call enableCursor
	mov menuLv,0
	mov row,2
	mov column,2
	mov ddScanStatus,00h
    call funCLS
	
	mov dx,offset mainMenu
    mov ah,9
    int 21h
	call cursorDis	
	popa
	ret
menu00 endp
funUpdateDDC proc	
	pusha
	;call funCLS
	mov row,1
	mov column,0
	call cursorDis	
	mov dx,offset sDDCtitle
	mov ah,9
	int 21h	

		

	mov ax,05f64h
	mov bx,0200h
	int 10h
	
	; mov row,10
	; mov column,0
	; call cursorDis
	; mov dbvar1,al
	; call prtbyte	
	; mov dbvar1,ch
	; call prtbyte
	
	cmp al,5fh
	jne fudLable021
	mov dbDDCattach,ch
	
	mov ax,05f64h
	mov bh,01h
	int 10h	

	; mov row,11
	; mov column,0
	; call cursorDis	
	; mov dbvar1,al
	; call prtbyte
	; mov dbvar1,cl
	; call prtbyte
	
	mov dbDDCstatus,cl


	
	mov row,3
	mov column,4
	call cursorDis
	mov dl,dbDDCattach
	and dl,01h
	cmp dl,01h	
	jne fudLable011	
	mov dx,offset sDDCattach
	mov ah,9
	int 21h		
fudLable010:	
	mov ax,05f64h
	mov bh,01h
	int 10h
	cmp al,05fh
	jne fudLable011
	
	mov dl,dbDDCstatus
	and dl,01h
	cmp dl,01h	
	jne fudLable011	
	mov dx,offset sDDCconnect
	mov ah,9
	int 21h		
fudLable011:	
	mov row,4
	mov column,4
	call cursorDis	
	mov dl,dbDDCattach
	and dl,08h
	cmp dl,08h	
	jne fudLable021
	mov dx,offset sDDCattach
	mov ah,9
	int 21h		
fudLable020:	
	mov ax,05f64h
	mov bh,01h
	int 10h
	cmp al,05fh
	jne fudLable021
	
	mov dl,dbDDCstatus
	and dl,08h
	cmp dl,08h	
	jne fudLable021	
	mov dx,offset sDDCconnect
	mov ah,9
	int 21h		
fudLable021:	
	mov row,7
	mov column,5
	call cursorDis
	mov dbcolor,0Fh
	
	mov dl,dbDDCcontrol
	and dl,10h
	cmp dl,10h	
	je fudLable032
	mov dbcolor,24h
fudLable032:	

	mov ah,09h
	mov al,dl
	mov bh,0
	mov bl,dbcolor
	and bl,7fh
	;or bl,00h
	mov cx,0003h
	int 10h
	
	mov dl,dbDDCcontrol
	and dl,01h
	cmp dl,01h	
	jne fudLable030
	mov dx,offset sDDCT
	mov ah,9
	int 21h	
	jmp fudLable031
fudLable030:	
	mov dx,offset sDDCF
	mov ah,9
	int 21h	
fudLable031:
	mov row,8
	mov column,5
	call cursorDis
	mov dbcolor,0Fh
	
	mov dl,dbDDCcontrol
	and dl,10h
	cmp dl,10h	
	jNe fudLable042
	mov dbcolor,24h
fudLable042:		

	mov ah,09h
	mov al,dl
	mov bh,0
	mov bl,dbcolor
	and bl,7fh
	;or bl,00h
	mov cx,0003h
	int 10h
	
	mov dl,dbDDCcontrol
	and dl,08h
	cmp dl,08h	
	jne fudLable040
	mov dx,offset sDDCT
	mov ah,9
	int 21h	
	jmp fudLable041
fudLable040:	
	mov dx,offset sDDCF
	mov ah,9
	int 21h	
fudLable041:


	
	; mov row,10
	; mov column,0
	; call cursorDis
	; mov dl,dbDDCcontrol
	; mov dbvar1,dl
	; call prtbyte
	
	popa
	ret
funUpdateDDC endp
funMovDDC proc
	pusha

	popa
	ret
funMovDDC endp
funSetDDC proc
	pusha
	mov dl,dbDDCcontrol
	and dl,10h
	cmp dl,10h	
	je fsdLable00
	mov al,dbDDCcontrol
	xor al,01h;crt
	mov dbDDCcontrol,al
	jmp fsdLable01
fsdLable00:	
	mov al,dbDDCcontrol
	xor al,08h;lcd
	mov dbDDCcontrol,al
fsdLable01:	

	mov cx,0
	mov cl,dbDDCcontrol
	and cl,0fh
	mov ax,5f64h
	mov bx,0
	int 10h
	

	popa
	ret
funSetDDC endp
funBCDAdd proc
	pusha
	mov dx,dwvar1
	mov al,dh
	shr al,4
	mov cl,0ah
	mul cl
	mov ah,dh
	and ah,0fh
	add al,ah
	mov dh,al

	mov al,dl
	shr al,4
	mov cl,0ah
	mul cl
	mov ah,dl
	and ah,0fh
	add al,ah
	mov dl,al

	add dl,dh
	mov dbvar1,dl
	popa
	ret
funBCDAdd endp
funHexBCD proc
	pusha
	mov ax,0
	mov al,dbvar1
	mov bl,10
	div bl
	shl al,4
	add al,ah
	mov dbvar1,al
	popa
	ret
funHexBCD endp
funRTCWakeUp proc
	pusha
;	mov al,dbRTCS
;	mov ah,dbRTCM
;	mov dwvar1,ax
;	call funBCDAdd
;	call funHexBCD
;	mov dl,dbvar1
;	mov dbRTCH,dl
;	jmp frwuExit

	mov cx,0
	mov al,00h
	out 70h,al
	in al,71h
	mov ah,dbRTCS
	mov dwvar1,ax
	call funBCDAdd
	cmp dbvar1,60
	jb frwuLable1
	sub dbvar1,60
	inc cl
frwuLable1:
	call funHexBCD
	mov al,01h
	out 70h,al
	mov dl,dbvar1
	mov al,dl
	out 71h,al

;-M

	mov al,02h
	out 70h,al
	in al,71h
	mov ah,dbRTCM
	mov dwvar1,ax
	call funBCDAdd
	add dbvar1,cl ;sec carry
	mov cx,0
	cmp dbvar1,60
	jb frwuLable2
	sub dbvar1,60
	inc cl
frwuLable2:
	call funHexBCD
	mov al,03h
	out 70h,al
	mov dl,dbvar1
	mov al,dl
	out 71h,al


	mov al,04h
	out 70h,al
	in al,71h
	mov ah,dbRTCH
	mov dwvar1,ax
	call funBCDAdd
	add dbvar1,cl ;minu carry
	mov cx,0
	cmp dbvar1,24
	jb frwuLable3
	sub dbvar1,24
	inc cl
frwuLable3:
	call funHexBCD
	mov al,05h
	out 70h,al
	mov dl,dbvar1
	mov al,dl
	out 71h,al


	mov al,07h
	out 70h,al ;today
	in al,71h
	add al,cl ;h carry
	mov dl,al
	mov al,0dh
	out 70h,al
	mov al,dl
	out 71h,al

	mov al,0bh
	out 70h,al
	in al,71h
	or al,020h
	out 71h,al

	mov dx,0cd6h
	mov al,061h
	out dx,al ;acpi base addr
	mov dx,0cd7h
	in al,dx
	mov ah,al

	mov dx,0cd6h
	mov al,060h
	out dx,al ;acpi base addr
	mov dx,0cd7h
	in al,dx

	mov dx,ax
	mov dwvar1,ax
	add dx,03h
	in ax,dx
	or ax,04h
	out dx,ax
	
frwuExit:	
	popa
	ret
funRTCWakeUp endp
funRTCUpdate proc
	pusha
	cmp subMenuLv,00h
	je fruLable1
	cmp subMenuLv,01h
	je fruLable2
	cmp subMenuLv,02h
	je fruLable3
	jmp fruLableExit
fruLable1:
	mov dl,dbvar1
	mov dbRTCH,dl
	jmp fruLableExit
fruLable2:
	mov dl,dbvar1
	mov dbRTCM,dl
	jmp fruLableExit
fruLable3:
	mov dl,dbvar1
	mov dbRTCS,dl
	jmp fruLableExit
fruLableExit:
	popa
	ret
funRTCUpdate endp
funSataInfo proc
	pusha
	call funCLS
	mov dx,offset sSatatitle
    	mov ah,9
   	int 21h   
     	mov dbcolor,80h
	mov eax,080008810h
	mov dx,0cf8h
	out dx,eax
	mov dx,0cfch
	in eax,dx
	and ax,0fffeh
	mov dwSataCmdAdr,ax
	;mov dwSataCmdAdr,01f0h
	;mov dwvar1,ax
	;call prtword


	mov si,offset buffer
	xor cx,cx
	call SataReadWait
	mov dx,dwSataCmdAdr
	add dx,06h
	mov al,0a0h
	out dx,al
	
	mov dx,dwSataCmdAdr
	add dx,07h
	mov al,0ech
	out dx,al
	mov dx,dwSataCmdAdr
fsiLoop:
	call SataReadWait
	in ax,dx
	;mov dwvar1,ax
	;call prtword	
	mov [si],ax
	inc cx
	inc si
	inc si
	cmp cx,0100h
	jb fsiLoop
	mov strBlenth,0ffh
	call prtWordPage

	mov row,20
	mov column,0
	call cursorDis
	
	mov dx,offset sSataName
    	mov ah,9
   	int 21h   

;
;	mov si,offset [buffer+54]
;	mov di,offset strBuffer
;	mov cx,40
;	cld 
;
;fsiLoopS4:  
;	mov dl,byte ptr [si]        
;	mov byte ptr [di],dl
;	inc si
;	inc di
;        dec cx                                            
;	jnz fsiLoopS4  
;	inc di
;	mov byte ptr [di],'$'
;
;	mov strBlenth,040 	
;	call prtPage
;
;
	mov si,offset [buffer+54]
	mov di,offset sSatastrBuf
	mov cx,20
fsiLoopS1:                                   
	mov dx,word ptr [si]        
	mov byte ptr [di+1],dl
	mov byte ptr [di],dh
	inc si
	inc di
	inc si
	inc di
        dec cx                                            
	jnz fsiLoopS1 
	inc di
	mov byte ptr [di],'$'

	mov dx,offset sSatastrBuf
	mov row,20
	mov column,13
	call cursorDis
    	mov ah,9
   	int 21h 	


	mov si,offset [buffer+20]
	mov di,offset sSatastrBuf
	mov cx,10
fsiLoopS2:                                   
	mov dx,word ptr [si]        
	mov byte ptr [di+1],dl
	mov byte ptr [di],dh
	inc si
	inc di
	inc si
	inc di
        dec cx                                            
	jnz fsiLoopS2 
	inc di
	mov byte ptr [di],'$'

	mov dx,offset sSatastrBuf
	mov row,21
	mov column,14
	call cursorDis
    	mov ah,9
   	int 21h 


	mov si,offset [buffer+46]
	mov di,offset sSatastrBuf
	mov cx,4 
fsiLoopS3:                                   
	mov dx,word ptr [si]        
	mov byte ptr [di+1],dl
	mov byte ptr [di],dh
	inc si
	inc di
	inc si
	inc di
        dec cx                                            
	jnz fsiLoopS3 
	inc di
	mov byte ptr [di],'$'

	mov dx,offset sSatastrBuf
	mov row,22
	mov column,18
	call cursorDis
    	mov ah,9
   	int 21h 



	popa
	ret



	popa
	ret
funSataInfo endp
SataReadWait proc
	pusha 
	mov cx,1000h
srwLoop:
  
	mov dx,dwSataCmdAdr
	add dx,07h
	in al,dx     ; Read Status byte

    	and al,0A0h     ; Test IBF flag (Status<1>)
    	jz srwExit    ; Wait for IBF = 1

	dec cx
	jnz srwLoop
srwExit:	
	popa
	ret
SataReadWait endp

funMicroCodeVN proc
	pusha
	call funCLS
	mov dx,offset sMicrotitle
    	mov ah,9
   	int 21h        
	mov dbcolor,80h


;	mov ecx,08bh
;	xor eax,eax
;	xor edx,edx
;	wrmsr


 	mov eax,080000001h 	
 	cpuid
	mov edx,eax
	mov ddvar1,eax
	shr edx,16
	mov row,3
	mov column,13
	call cursorDis
	call prtdword
;	mov dbvar1,dl
;	call prtbyte
;	mov dbvar1,al
;	call prtbyte
	mov row,4
	mov column,8
	call cursorDis

	mov ecx, 08bh
	rdmsr
;	mov esi,offset ddMCVer
;	mov [esi],eax
;	mov [esi+4],edx

;
;	mov eax,edx
;	shr eax,16
;	mov dbvar1,ah
;	call prtbyte
;	mov dbvar1,al
;	call prtbyte
;	mov eax,edx
;	mov dbvar1,ah
;	call prtbyte
;	mov dbvar1,al
;	call prtbyte 
;
;
;	mov eax,ddvar1

	mov ddvar1,eax
	shr eax,16
	mov dbvar1,ah
	call prtbyte
	mov dbvar1,al
	call prtbyte
	mov eax,ddvar1
	mov dbvar1,ah
	call prtbyte
	mov dbvar1,al
	call prtbyte 

	popa
	ret
funMicroCodeVn endp
funWVerb proc
	pusha

	mov edx,0
	mov dl,dbNididx
	add dl,dbNidStart 
	shl edx,20
	mov cl,dbCAdvar1
	shl ecx,28
	or ecx,edx ;nid =start+idx
	or ecx,072000h ;get sid

	mov eax,ddScanData
	mov ch,20h
	mov cl,al
	mov ddVerbVar1,ecx 
	call funVerbCmd

	mov ch,21h
	mov cl,ah
	mov ddVerbVar1,ecx 
	call funVerbCmd

	shr eax,16
	mov ch,22h
	mov cl,al
	mov ddVerbVar1,ecx 
	call funVerbCmd

	mov ch,23h
	mov cl,ah
	mov ddVerbVar1,ecx 
	call funVerbCmd

	popa
	ret
funWVerb endp
funRVerb proc
	pusha



	mov cl,0h
	mov dbCAdTotal,00h

	mov ax,01h
	shl ax,cl
	and ax,dwSDIN 
	cmp ax,0
	je frCAdNext
	inc dbCAdTotal 
frCAdNext:
	inc cl
	cmp cl,10h
	ja frCAdExit
	mov ax,01h
	shl ax,cl
	and ax,dwSDIN 
	cmp ax,0
	je frCAdNext
	inc dbCAdTotal 
	jmp frCAdNext
frCAdExit:

	cmp dbCAdTotal,0
	je frExit

	mov cl,0h
	mov bl,dbCAdidx
	mov ax,01h
	shl ax,cl
	and ax,dwSDIN 
	cmp ax,0
	je frCAdFind;not find &next
	cmp bl,0 ;get idx var
	je frCAdFindGet
	dec bl
frCAdFind:
	inc cl
	cmp cl,10h
	ja frCAdExit;not find &end
	mov ax,01h
	shl ax,cl
	and ax,dwSDIN 
	cmp ax,0
	je frCAdFind;not find &next
	cmp bl,0 ;get idx var
	je frCAdFindGet
	dec bl
	jmp frCAdFind
frCAdFindGet:
	mov dbCAdvar1,cl

	mov cl,dbCAdvar1
	shl ecx,28
	or ecx,0f0000h ;get vid did,sdin ,root nid = 0
	mov ddVerbVar1,ecx
	call funVerbCmd
	mov edx,ddVerbVar1
	mov dwVerbDId,dx
	shr edx,16
	mov dwVerbVId,dx

	mov cl,dbCAdvar1
	shl ecx,28
	or ecx,0f0004h ;get nid start total ,root nid = 0
	mov ddVerbVar1,ecx
	call funVerbCmd
	mov edx,ddVerbVar1
	mov dbNidTotal,dl
	shr edx,16
	mov dbNidStart,dl


	mov edx,0
	mov dl,dbNididx
	add dl,dbNidStart 
	shl edx,20
	mov cl,dbCAdvar1
	shl ecx,28
	or ecx,edx ;nid =start+idx
	or ecx,0f2000h ;get sid
	mov ddVerbVar1,ecx 
	call funVerbCmd
	mov edx,ddVerbVar1
	mov ddVerbSID,edx

;	mov row,9
;	mov column,16
;	call cursorDis     
;	mov ddvar1,ecx
;	call prtdword
;
	mov edx,0
	mov dl,dbNididx
	add dl,dbNidStart 
	shl edx,20
	mov cl,dbCAdvar1
	shl ecx,28
	or ecx,edx ;nid =start+idx
	or ecx,0f1c00h  ;get cfg 
	mov ddVerbVar1,ecx
	call funVerbCmd
	mov edx,ddVerbVar1
	mov ddVerbCfg,edx

;	mov row,10
;	mov column,16
;	call cursorDis     
;	mov ddvar1,ecx
;	call prtdword
;
frExit:
	popa
	ret
funRverb endp
funVerbCmd proc
	pushad
	push ds

         xor eax,eax
         xor ebx,ebx
         mov ax,ds
         shl eax,04h
         mov bx,offset gdt
         add eax,ebx
         mov di,offset gda+02h
         mov ds:[di],eax
         NOP
         xor eax,eax
         xor ebx,ebx
         mov ax,@data
         shl eax,04h
         mov di,offset gdt+10h
         mov ds:[di+02h],ax
         shr eax,10h
         mov ds:[di+04h],al
         mov ds:[di+07h],ah

	mov eax,08000a210h ;Bus 0,Device 14h,Function 2,20h
	mov dx,0cf8h
	out dx,eax
	mov dx,0cfch
	in eax,dx
	  
	and eax, not 11111b ; clear bit 0 to bit 4
;	mov ddvar1,eax
;	call prtdword
         mov si,offset gdt+08h
         mov ds:[si+02h],ax
         shr eax,10h
         mov ds:[si+04h],al
         mov ds:[si+07h],ah	 
		 
	 lgdt fword ptr ds:gda
         cli
	 
	 in al,92h
	 or al,02h
	 out 92h,al
         mov eax,cr0
         or al,01h
         mov cr0,eax		 
         jmp fvcPM
fvcPM :
         mov ax,0008h		 
         mov es,ax ;hda
         mov ax,0010h
         mov ds,ax ;@data
	 mov edi,0
	 mov dx,word ptr es:[edi+0eh]
	 mov dwSDIN,dx

	 mov cx,1000h
fvcWait:
	 mov dl,2
	 mov byte ptr es:[edi+68h],dl
	 mov dl,byte ptr es:[edi+68h]
	 and dl,01h
	 cmp dl,0
	 je fvcCMD
	 dec cx
	 cmp cx,0
	 je fvcExitCMD
	 jmp fvcWait
fvcCMD:
	 mov dl,2
	 mov byte ptr es:[edi+68h],dl
	 mov edx,ddVerbVar1
	 mov dword ptr es:[edi+60h],edx
;	 mov dl,2
;	 mov byte ptr es:[edi+68h],dl
	
	 mov cx,1000h
fvcRWait:
	 mov byte ptr es:[edi+68h],dl
	 mov dl,byte ptr es:[edi+68h]
	 and dl,02h
	 cmp dl,02h
	 je fvcDone
	 dec cx
	 cmp cx,0
	 je fvcExitCMD
	 jmp fvcRWait
fvcDone:
	 mov edx,dword ptr es:[edi+64h]
	 mov ddVerbvar1,edx
                      

fvcExitCMD:
         NOP
         mov eax,cr0
         and al,0feh
         mov cr0,eax
         jmp fvcRM
fvcRM :
         sti
	 in al,92h
	 and al,not 02h
	 out 92h,al
       
	pop ds
	popad
	ret
funVerbCmd endp
funEDID proc
	pusha
	call funCLS

	mov di,offset strBuffer
	mov ax,@data
	mov es,ax
	mov bl,01h
	mov ax,04f15h
	mov cx,0h
	mov dx,0h
	int 10h
	
	mov si,offset [strBuffer+8]
	mov di,offset dwMfID
	mov cl,0cH
	cld 
loopFE:                                   
	lodsb                           
	stosb                           
	loop loopFE                      

	mov dx,offset sEDIDtitle
	mov ah,9
	int 21h

	mov strBlenth,07fh
	call prtPage

	mov dx,offset sEDIDInfor
	mov ah,9
	int 21h

	mov row,12
	mov column,16
	call cursorDis
	mov dx,dwMfID
	xor dl,dh
	xor dh,dl
	xor dl,dh
	mov dwMfID,dx
	shr dx,10
	and dl,01fh
	add dl,040h
	mov ah,2
	int 21h

	mov dx,dwMfID
	shr dx,5
	and dl,01fh
	add dl,040h
	mov ah,2
	int 21h

	mov dx,dwMfID
	and dl,01fh
	add dl,040h
	mov ah,2
	int 21h
	

	mov row,13
	mov column,12
	call cursorDis
	mov dx,dwPID
	mov dwvar1,dx
	mov dbcolor,80h
	call prtword

	mov row,14
	mov column,14
	call cursorDis
	mov edx,ddSN
	mov ddvar1,edx
	call prtdHexToDec

	mov row,15
	mov column,5
	call cursorDis
	mov edx,0
	mov dl,dbWeek
	mov ddvar1,edx
	call prtdHexToDec

	mov row,16
	mov column,5
	call cursorDis
	mov edx,0
	mov dl,dbYear
	add edx,1990
	mov ddvar1,edx
	call prtdHexToDec


	mov row,17
	mov column,13
	call cursorDis
	mov edx,0
	mov dl,dbVersion
	mov ddvar1,edx
	call prtdHexToDec

	inc column
	call cursorDis
	mov dl,'.'
	mov ah,2
	int 21h

	mov edx,0
	mov dl,dbReV
	mov ddvar1,edx
	call prtdHexToDec


	mov si,offset [strBuffer+55]
	cmp byte ptr [si],0feh
	jne nextFE1
	mov si,offset [strBuffer+56]
	mov di,offset sEDIDstrBuf
	mov cl,14
	cld 
loopFE1:                                   
	lodsb                           
	stosb                           
	loop loopFE1	
	inc di
	mov byte ptr [di],'$'
	mov dx,offset sEDIDstrBuf
	mov row,18
	mov column,19
	call cursorDis	
	mov ah,9
	int 21h

nextFE1:
	mov si,offset [strBuffer+75]
	cmp byte ptr [si],0feh
	jne nextFE2
	mov si,offset [strBuffer+76]
	mov di,offset sEDIDstrBuf
	mov cl,14
	cld 
loopFE2:                                   
	lodsb                           
	stosb                           
	loop loopFE2
	inc di
	mov byte ptr [di],'$'
	mov dx,offset sEDIDstrBuf
	mov row,19
	mov column,19
	call cursorDis	
	mov ah,9
	int 21h


nextFE2:
	mov si,offset [strBuffer+93]
	cmp byte ptr [si],0feh
	jne nextFE3
	mov si,offset [strBuffer+94]
	mov di,offset sEDIDstrBuf
	mov cl,14
	cld 
loopFE3:                                   
	lodsb                           
	stosb                           
	loop loopFE3
	inc di
	mov byte ptr [di],'$'
	mov dx,offset sEDIDstrBuf
	mov row,20
	mov column,19
	call cursorDis	
	mov ah,9
	int 21h

nextFE3:
	mov si,offset [strBuffer+111]
	cmp byte ptr [si],0feh
	jne nextFE4
	mov si,offset [strBuffer+112]
	mov di,offset sEDIDstrBuf
	mov cl,14
	cld 
loopFE4:                                   
	lodsb                           
	stosb                           
	loop loopFE4
	inc di
	mov byte ptr [di],'$'
	mov dx,offset sEDIDstrBuf
	mov row,21
	mov column,19
	call cursorDis	
	mov ah,9
	int 21h
nextFE4:
	popa
	ret
funEDID endp
funSMI proc
	pusha
	mov dbcolor,80h
	mov al,row
	cmp al,02h
	je fsRS
	cmp al,03h
	je fsSD
	jmp fsExit
fsRS:
	;mov dbvar1,01h
	;call prtbyte
	
	mov al,0h
	out 0b1h,al

	mov al,0d6h
	out 0b0h,al



	jmp fsExit
fsSD:

	mov al,0h
	out 0b1h,al

	mov al,0d7h
	out 0b0h,al



fsExit:
	popa
	ret
funSMI endp
aspmDectect proc
	pusha
	call funCLS
	
	mov dx,offset sAspmDt
    	mov ah,9
   	int 21h	

	call ScanPciDev2
	popa
	ret
aspmDectect endp
bytePciScan proc 	;dwvar1:fun addr dbvar1:offset
	pusha
	xor eax,eax
	mov ax,dwvar1
	shl eax,8
	mov al,dbvar1
	and al,0fch	
	or eax,080000000h
	mov dx,0cf8h
	out dx,eax
	mov al,dbvar1
	and al,03h
	mov dx,0cfch
	or dl,al
	in al,dx
	mov dbvar1,al
	popa
	ret
bytePciScan endp
ScanPciDev2 proc
    pusha
    mov si,offset buffer
    mov dbBusIdxCnt,0
    mov bx,0
loopSPD2:
	xor eax,eax
	mov ax,bx
	shl eax,8
	or eax,080000000h
	mov dx,0cf8h
	out dx,eax
	mov dx,0cfch
	in eax,dx	

	mov ecx,eax	
    	cmp cx,0ffffh
    	je nextSPD2
	cmp cx,0h
    	je nextSPD2


	mov dwvar1,bx
	mov dl,034h
	mov dbvar1,dl
	call bytePciScan
	;call prtbyte
nextPcie:   
	mov al,dbvar1
	cmp al,0h
	je nextSPD2
	mov dl,dbvar1
	call bytePciScan
	;call prtbyte
	mov al,dbvar1
	cmp al,10h ;PCIE CAD ID
	je pcieDectect
	inc dl
	mov dbvar1,dl
	call bytePciScan
	;call prtbyte
	jmp nextPcie

pcieDectect:
	mov dh,dl
	add dl,0dh
	mov dbvar1,dl
	call bytePciScan
	;call prtbyte
	mov al,dbvar1
	mov dbASPMtmp,al

	mov dl,dh
	add dl,10h
	mov dbvar1,dl
	call bytePciScan
	;call prtbyte
	mov al,dbvar1
	mov dbASPMtmp2,al


	mov al,dbBusIdxCnt
	inc al
	mov dbvar1,al
	mov dbcolor,07h
    	call prtbyte   
	mov dl,')'
    	mov ah,2
    	int 21h
	
    ;vender
    mov dwvar1,cx
	mov dbcolor,80h
    call prtword   
    call prtTab
	;device
	shr ecx,16  
    mov dwvar1,cx
	mov dbcolor,80h
    call prtword
  
    mov dbvar1, bh
    call prtbyte
    call prtTab
    
    mov al,bl
    mov cl,3
    shr al,cl
    mov dbvar1, al
    call prtbyte   
    call prtTab
    
    mov al,bl
    and ax,07h
    mov dbvar1, al
    call prtbyte   

    mov dwBusIdx,bx
    mov [si],bx
    add si,2   
    inc dbBusIdxCnt    

	call prtTab
	mov al,dbASPMtmp
	;mov dbvar1,al
	;call prtbyte
	and al,04h
	jz aspmDF1
	mov dx,offset sAspmT
    	mov ah,9
   	int 21h	
	jmp aspmNext1
aspmDF1:
	mov dx,offset sAspmF
    	mov ah,9
   	int 21h	
aspmNext1:
	mov al,dbASPMtmp
	;mov dbvar1,al
	;call prtbyte
	and al,08h
	jz aspmDF2
	mov dx,offset sAspmT
    	mov ah,9
   	int 21h	
	jmp aspmNext2
aspmDF2:
	mov dx,offset sAspmF
    	mov ah,9
   	int 21h	
aspmNext2:

	;call prtTab
	;mov al,dbASPMtmp2
	;mov dbvar1,al
;	call prtbyte
	mov al,dbASPMtmp2
	and al,01h
	jz aspmDF3
	mov dx,offset sAspmT
    	mov ah,9
   	int 21h	
	jmp aspmNext3
aspmDF3:
	mov dx,offset sAspmF
    	mov ah,9
   	int 21h	
aspmNext3:
	mov al,dbASPMtmp2
	;mov dbvar1,al
	;call prtbyte
	and al,02h
	jz aspmDF4
	mov dx,offset sAspmT
    	mov ah,9
   	int 21h	
	jmp aspmNext4
aspmDF4:
	mov dx,offset sAspmF
    	mov ah,9
   	int 21h	
aspmNext4:

    call prtCRLF   

nextSPD2:
    cmp bx,08ffh
    jz exitSPD2
    inc bx
    jmp loopSPD2
exitSPD2:
    popa
    ret
ScanPciDev2 endp


ecRead proc
	pusha
	call ecUpdate	
	mov ax,0001h

	mov row,al
	mov column,ah
	call cursorDis

	;call funCLS
	mov dx,offset sECRam
    	mov ah,9
   	int 21h	
	call prtCRLF
	mov strBlenth,0ffh
	call prtPage
	
	popa
	ret
ecRead endp
ecUpdate proc
	pusha
	mov si,offset strBuffer
	xor cx,cx
euLoop:
	call ecReadWait
	mov al,80h
	out 66h,al

	call ecReadWait
	mov al,cl
	out 62h,al
;erLoopW:
;	in al,66h
;	mov dbvar1,al
;	call prtbyte
;	and al,01h
;	jz erLoopW ;wait IBF
;
	in al,62h
	mov [si],al
	inc cx
	inc si
	cmp cx,0100h
	jb euLoop
	popa
	ret
ecUpdate endp
ecReadWait proc
	pusha
 
	mov cx,1000h
erwLoop:
  
	in al, 66h     ; Read Status byte
	;mov dbvar1,al
	;call prtbyte
        and al, 02h     ; Test IBF flag (Status<1>)
        jz erwExit    ; Wait for IBF = 1
	dec cx
	jnz erwLoop
erwExit:	
	popa
	ret
ecReadWait endp
protectMemRead proc
	pushad
	;mov si,offset strBuffer
	;mov ax,[si]
	;inc ax
	;mov [si],axgda
	push ds
         xor     eax,eax                 ;
         xor     ebx,ebx                 ;
         mov     ax,ds                   ;設定 gda
         shl     eax,04h                 ;
         mov     bx,offset gdt        ;
         add     eax,ebx                 ;
         mov     di,offset gda+02h   ;
         mov     ds:[di],eax             ;
         NOP
         xor     eax,eax                 ;
         xor     ebx,ebx                 ;
         mov     ax,@data                  ;
         shl     eax,04h                 ;
         mov     di,offset gdt+10h    ;設定 gdt 內的
         mov     ds:[di+02h],ax          ;兩個段落的記憶體起始位址
         shr     eax,10h                 ;
         mov     ds:[di+04h],al          ;
         mov     ds:[di+07h],ah          ;
		 mov 	 eax,ddScanData;
         mov     si,offset gdt+08h    ;設定 gdt 內的
         mov     ds:[si+02h],ax          ;兩個段落的記憶體起始位址
         shr     eax,10h                 ;
         mov     ds:[si+04h],al          ;
         mov     ds:[si+07h],ah          ;
		 
		 
		 lgdt    fword ptr ds:gda    ;載入 GDT 表格
         cli   
	 
		 in		al,92h
		 or		al,02h
		 out	92h,al
         mov     eax,cr0             ;
         or      al,01h              ;
         mov     cr0,eax             ;
		 
         jmp     protection_mode     ;進入保護模式
 protection_mode :     

	 mov     esi,0000h
         mov     ax,0008h                ;
		 
         mov     ds,ax                   ;
         mov     ax,0010h                ;
         mov     es,ax            
         
         mov     edi,offset strBuffer                ;
         
         mov     cx,0100h                ;
         cld                             ;
 L1 :                                    ;
         lodsb                           ;
         stosb                           ;
         loop    L1                      ;
         NOP
         mov     eax,cr0             ;
         and     al,0feh             ;
         mov     cr0,eax             ;回到真實模式
         jmp     return_real_mode    ;
 return_real_mode :    
	 
         sti
		 in		al,92h
		 and	al,not 02h
		 out	92h,al
       
	pop ds
	popad
	ret
protectMemRead endp
pfCpuFreq proc
	pusha
	mov column,6
	mov row,2
	call cursorDis
	
	xor ax,ax
	push ds
	mov ds,ax
	mov ecx,ds:[46ch]
	pop ds
	cmp ecx,ddTime
	je	pfcfExit
	push ecx
	
	sub ecx,ddTime
	mov eax,55000    
	mul ecx
	mov ecx,eax
	; mov dwvar1,cx
	; call prtword
	
	; shr ecx,16
	; mov dwvar1,cx
	; call prtword	
	rdtsc	
	sub eax,ddRtdsc1
	sbb edx,ddRtdsc2
	div ecx

	; mov dwvar1,ax
	; call prtword
	mov dwvar1,ax
	call prtwordDec
	pop ecx
	mov ddTime,ecx
	

	; mov dwvar1,ax
	; call prtword
	
	; shr eax,16
	; mov dwvar1,ax
	; call prtword		
	; mov dwvar1,dx
	; call prtword
	
	; shr edx,16
	; mov dwvar1,dx
	; call prtword	
	 rdtsc
	 mov ddRtdsc1,eax
	 mov ddRtdsc2,edx
pfcfExit:	
	popa
	ret
pfCpuFreq endp


CpuInfor proc
	pusha
	mov dx,offset sCpuName
	mov ah,9
 	int 21h 
	
	push ds
	mov ds,ax
	mov ecx,ds:[46ch]
	mov ddTime,ecx
	pop ds
	rdtsc
	;mov di,offset ddRtdsc
	mov ddRtdsc1,eax
	mov ddRtdsc2,edx
	
	mov si,offset buffer
 	mov eax,080000002h
 	
 	cpuid
 	mov [si+0],eax
 	mov [si+4],ebx
 	mov [si+8],ecx
 	mov [si+12],edx

 	mov eax,080000003h
 	
 	cpuid
 	mov [si+16],eax
 	mov [si+20],ebx
 	mov [si+24],ecx
 	mov [si+28],edx
 	
 	mov eax,080000004h
 	
 	cpuid
 	mov [si+32],eax
 	mov [si+36],ebx
 	mov [si+40],ecx
 	mov [si+44],edx
 	
 	mov al,'$'
 	mov [si+45],al
 	
 	mov dx,offset buffer
 	mov ah,9
 	int 21h    
	call prtCRLF
	
	mov dx,offset sCpuFreq
	mov ah,9
 	int 21h 	
	popa
	ret
CpuInfor endp
; 1.Reference by Inter ICH7 section 5.21.1.1 Command Protocol /page 202
; Read Byte/Word
; Reading data is slightly more complicated than writing data. First the ICH7 must write a command
; to the slave device. Then it must follow that command with a repeated start condition to denote a
; read from that device's address. The slave then returns 1 or 2 bytes of data. Software must force the
; I2C_EN bit to 0 when running this command.

; When programmed for the read byte/word command, the Transmit Slave Address and Device
; Command Registers are sent. Data is received into the DATA0 on the read byte, and the DAT0 and
; DATA1 registers on the read word.


; 2.Reference by http://blog.csdn.net/HarmonyHu/archive/2010/09/05/5864371.aspx
; 1st. Set Hst_STS(00H) to 1EH(clear all flag),if sucess regs Hst_STS value will change to 40H
; 2st. Set XMIT_SLVA(04H) to A1H for reading SPD data
; 3st. Set HST_CMD(03H) to 00H for SPD data offset address,if set to 01h mean read SPD address 01h's data
; 4st. Set HST_CNT(02H) to 48H for determind use read byte/word mode(including send start taken),
;      then HST_CNT will retun 08H,HST_STS return 42H at the same time,and HST_D0 return the SPD data
spdRead proc
	pusha
	
	call prtSpace
	call prtSpace
	call prtSpace
	mov cl,0h
srLoopSb3:
	mov dbvar1,cl
	mov dbcolor,0fh
	call prtbyte
	call prtSpace
	inc cl
	cmp	cl,10h
	jnz srLoopSb3
	call prtCRLF  
	
	
	mov SPD_Addr,0
	mov count1,0   
	mov count2,0
	
	mov cl,count2	
	mov dbvar1,cl
	mov dbcolor,0fh
 	call prtbyte	
	call prtSpace	
srLoop:   
;	mov al,count2
;	shl al,4
;	or al,count1	
;	mov dbvar1,al
;	call prtbyte
;	call prtSpace	


	 mov dx,SMB_base	;refernce Inter ICH7 doc
	 add dx,0		;HST_STS regs
	 mov al,40h		;clear INUSE_STS
	 out dx,al

	 mov dx,SMB_base   
	 add dx,0		;HST_STS regs
	 in al,dx
	 mov SMB_STS,al

	 mov dx,SMB_base	;clear all status bits
	 mov al,1Eh		;host status register
	 out dx,al

	 mov dx,SMB_base	;set offset to read
	 add dx,3		;host command register
	 mov al,SPD_Addr
	 out dx,al

	 mov dx,SMB_base   ;Transimit Slave Address register
	 add dx,4
	 mov al,0a0h
	 inc al
	 out dx,al

	 mov dx,SMB_base	;set "Read Word" protocol and start bit
	 add dx,2		;Host Control register
	 mov al,48h  
	 out dx,al

 srReadSTS:
	 mov dx,SMB_base
	 in al,dx
	 mov SMB_STS,al
	 and al,1Eh
	 cmp al,0
	 je srReadSTS ;check repeatly until any of FAIL,BERR,DERR,INTR

	 mov al,SMB_STS   ;FAIL,BUS ERR,DEV ERR
	 and al,1Ch
	 cmp al,0
	 jne srExit
	
	 mov dx,SMB_base
	 add dx,05h
	 in al,dx  

	cmp al,0
	je srNColor
	mov dbcolor,04h
	jmp srSb1
srNColor:
	mov dbcolor,07h
srSb1:	
	 mov dbvar1, al
	 call prtbyte
	 call prtSpace
	;//
    cmp count1,0fh
    jnz srLoopSb1
    call prtCRLF   
    cmp count2,0fh
    jz srExit   
    inc count2
	mov cl,count2
	shl cl,4
	mov dbvar1,cl
	mov dbcolor,0fh
  	call prtbyte
	call prtSpace		
    mov count1,0
	inc SPD_Addr
    jmp srLoop   
srLoopSb1:
	inc SPD_Addr
    inc count1
    jmp srLoop   
srExit:
    popa
    ret
spdRead endp

getSMBbase proc
	pusha
	mov eax,08000FB20h ;Bus 0,Device 32,Function 3,20h
	mov dx,0cf8h
	out dx,eax
	mov dx,0cfch
	in eax,dx
	  
	and ax, not 11111b ; clear bit 0 to bit 4
	mov SMB_base,ax
	mov dwvar1,ax
	mov dx,offset message1
    mov ah,9
    int 21h  	
	call prtWord
	call prtCRLF
	
	popa
	ret
getSMBbase endp
cursorDis proc
	pusha
    mov     ah,2       
    mov     dl,column
    mov     dh,row
    mov     bh,0
    int     10h     
	popa
	ret
cursorDis endp	
	
IdxToBusData proc
    pusha
    mov     ah,2       
    mov     dx,018h
    mov     bh,0
    int     10h      
    
    mov al,row

    mov si,offset buffer
    mov ax,0
    mov al,row
    sub ax,2
    mov dbvar1,al
    call prtbyte        
    shl ax,1   
    add ax,si
    mov si,ax
    mov ax,[si]
    mov dwBusIdx,ax
    mov dwvar1,ax
    call prtTab
	mov dbcolor,80h
    call prtword
    popa
    ret
IdxToBusData endp    

ScanPciDev proc
    pusha
    mov si,offset buffer
    mov dbBusIdxCnt,0
    mov bx,0
loopSPD:
; int 1ab109
; category: expansion bus bioses

; int 1a - pci bios v2.0c+ - read configuration word
; ax = b109h
; bh = bus number
; bl = device/function number (bits 7-3 device, bits 2-0 function)
; di = register number (0000h-00ffh, must be multiple of 2) (see #00878)
; return: cf clear if successful
; cx = word read
; cf set on error
; ah = status (00h,87h) (see #00729)
; eax, ebx, ecx, and edx may be modified
; all other flags (except if) may be modified
; notes:    this function may require up to 1024 byte of stack; it will not enable
; interrupts if they were disabled before making the call
; the meanings of bl and bh on entry were exchanged between the initial
; drafts of the specification and final implementation
; bug:    the award bios 4.51pg (dated 05/24/96) incorrectly returns ffffh for
; register 00h if the pci function number is nonzero
; seealso: ax=b108h,ax=b10ah,ax=b189h,int 2f/ax=1684h/bx=304ch
; reference http://www.delorie.com/djgpp/doc/rbinter/id/86/23.html


	
    mov ax,0b109h
    mov di,0
    int 1ah
    cmp ah,0
    jnz nextSPD
 ; Values for PCI BIOS v2.0c+ status codes:
 ; 00h    successful
 ; 81h    unsupported function
 ; 83h    bad vendor ID
 ; 86h    device not found
 ; 87h    bad PCI register number
 
    cmp cx,0ffffh
    jz nextSPD
    cmp cx,0
    jz nextSPD
    ;0&FFFFh is an invalid value for Vendor ID.
	mov al,dbBusIdxCnt
	inc al
	mov dbvar1,al
	mov dbcolor,07h
    call prtbyte   
	mov dl,')'
    mov ah,2
    int 21h
	
    ;vender
    mov dwvar1,cx
	mov dbcolor,80h
    call prtword   
    call prtTab
	;device
    mov ax,0b109h
    mov di,2
    int 1ah   
    mov dwvar1,cx
	mov dbcolor,80h
    call prtword
   
;bx   
;15   8    |7    3    |2    0
;busnum    |devnum    |funnum   
    ;bus
    mov dbvar1, bh
    call prtbyte
    call prtTab
    ;dev
    mov al,bl
    mov cl,3
    shr al,cl
    mov dbvar1, al
    call prtbyte   
    call prtTab
    ;fun
    mov al,bl
    and ax,07h
    mov dbvar1, al
    call prtbyte   

    mov dwBusIdx,bx
    mov [si],bx
    add si,2   
    inc dbBusIdxCnt       
    call prtCRLF   

nextSPD:
    cmp bx,08ffh
    jz exitSPD
    inc bx
    jmp loopSPD
exitSPD:
    popa
    ret
ScanPciDev endp

prt_PciMem proc
    pusha
	mov dbcolor,0fh
	call prtSpace
	call prtSpace
	call prtSpace
	mov cl,0h
ppmLoopSb3:
	mov dbvar1,cl
    call prtbyte
	call prtSpace
	inc cl
	cmp cl,10h
	jnz ppmLoopSb3
	call prtCRLF  
	
	
    mov bx,dwBusIdx	
	;mov ebx,dwBusIdx ;Bus 0,Device 32,Function 3,20h
	shl ebx,8
	or ebx,080000000h
    mov count1,0   
    mov count2,0
	
	mov cl,count2	
	mov dbvar1,cl
	mov dbcolor,0fh
    call prtbyte
	call prtSpace	
ppmLoop:   
	mov eax,ebx
	mov dx,0CF8h	
	out dx,eax
	mov dx,0CFCh
	in eax,dx	

	mov cl,4
ppmLoopSb2:	
	cmp al,0
	je ppmNColor
	mov dbcolor,04h
	jmp ppmSb3
ppmNColor:
	mov dbcolor,07h
ppmSb3:	
	mov dbvar1,al
    call prtbyte
	call prtSpace
	shr eax,8
	dec cl
	jnz ppmLoopSb2
	
    cmp count1,03h
    jnz ppmLoopSb1
    call prtCRLF   
    cmp count2,0fh
    jz ppmExit   
    inc count2
	mov cl,count2
	shl cl,4
	mov dbvar1,cl
	mov dbcolor,0fh
    call prtbyte
	call prtSpace	
	
    mov count1,0
	add ebx,4
    jmp ppmLoop   
ppmLoopSb1:
    add ebx,4 
    inc count1
    jmp ppmLoop   
ppmExit:
    popa
    ret
prt_PciMem endp
getdword proc
	pusha

	mov ddScanStatus,01h
	mov ax,ddScanCursor
	mov row,al
	mov column,ah
	call cursorDis
	mov dbcolor,24h

	mov al,dbScanLen
	cmp al,8
	je gdDW00
	cmp al,4
	je gdW00
	cmp al,2
	je gdB00
	jmp gdDW00
gdB00:
	call prtbyte
	add ah,1
	mov column,ah
	call cursorDis
	sub ah,1
	mov column,ah
	jmp gdExit
gdW00:
	call prtword
	add ah,3
	mov column,ah
	call cursorDis
	sub ah,3
	mov column,ah
	jmp gdExit
gdDW00:
	call prtdword
	add ah,7
	mov column,ah
	call cursorDis
	sub ah,7
	mov column,ah
gdExit:
	popa
	ret
getdword endp

prtword proc
    pusha

    mov ax,dwvar1
    mov dbvar1,ah
    call prtbyte
    mov dbvar1,al
    call prtbyte   
    call prtTab   
    popa
    ret
prtword endp

prtdword proc
    pusha
	;mov dbcolor,10h
    mov eax,ddvar1
	shr eax,16
    mov dbvar1,ah
    call prtbyte
    mov dbvar1,al
    call prtbyte
	mov eax,ddvar1
    mov dbvar1,ah
    call prtbyte
    mov dbvar1,al
    call prtbyte   
    call prtTab   
    popa
    ret
prtdword endp

prtbyte proc
    pusha
    mov al, dbvar1
    mov cl, 4
    shr al, cl
    and al, 0fh
    mov dl,al
    call prt4bit

    mov al, dbvar1
    and al, 0fh
    mov dl,al
    call prt4bit   
    popa
    ret
prtbyte endp

prt4bit   proc
	pusha
        add dl,30h
        cmp dl,'9'
        jbe non_add
        add dl,7
non_add:
	mov al,dbcolor
	shr al,7
	cmp al,0
	je p4Color
        mov ah,2
        int 21h
	jmp p4Exit
p4Color:
	mov ah,09h
	mov al,dl
	mov bh,0
	mov bl,dbcolor
	and bl,7fh
	;or bl,00h
	mov cx,0001h
	int 10h
	mov cx,0001h
	call AdvanceCursor
	
p4Exit:
	popa
        ret
prt4bit   endp
AdvanceCursor PROC
	pusha
acloop:
	push cx	; save loop counter
	mov  ah,3      	; get cursor position
	mov  bh,0	; into DH, DL
	int  10h	; changes CX register!
	inc  dl        	; increment column
	mov  ah,2      	; set cursor position
	int  10h
	pop  cx	; restore loop counter
	loop acloop	; next column

	popa
	ret
AdvanceCursor ENDP
prtdHexToDec proc	
	pusha
	mov dbcolor,80h

	mov eax,ddvar1
	mov cx,0
loopPHD:
	mov edx,0
	mov ebx,10
	div ebx
	inc cx
	cmp eax,0
	jne loopPHD	
	
	add column,cl
	call cursorDis

	mov eax,ddvar1
loopPHD3:
	mov edx,0
	mov ebx,10
	div ebx
	call prt4bit
	dec column
	call cursorDis
	cmp eax,0
	jne loopPHD3

	add column,cl
	call cursorDis
	
	popa
	ret
prtdHexToDec endp
prtwordDec proc
	pusha
	;call prtword
	;call prtSpace
	mov dbcolor,80h
	mov dx,0
	mov ax,dwvar1
	mov cx,1000
	div cx
	mov dl,al
	call prt4bit
	
	mov dx,0
	mov ax,dwvar1
	mov cx,100
	div cx
	mov cl,10
	div cl	
	mov dl,ah
	call prt4bit	
	
	mov dx,0
	mov ax,dwvar1
	mov cx,10
	div cx
	mov cl,10
	div cl	
	mov dl,ah
	call prt4bit	
	
	mov dx,0
	mov ax,dwvar1
	mov cx,10
	div cx
	call prt4bit
	popa
	ret
prtwordDec endp

prtCRLF proc
    pusha
    mov dl,0dh
    mov ah,2
    int 21h
    mov dl,0ah
    int 21h   
    popa
    ret   
prtCRLF endp

prtTab proc
    pusha
    mov dl,9
    mov ah,2
    int 21h
    popa
    ret       
prtTab endp

prtSpace proc
    pusha
    mov dl,' '
    mov ah,2
    int 21h
    popa
    ret   	
prtSpace endp

funCLS proc
    pusha
    mov ah, 6
    mov al, 0
    mov bh, 7
    mov cx, 0
    mov dl, 79
    mov dh, 24
    int 10h
	
    mov ah, 2
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h

    mov dx,offset message0
    mov ah,9
    int 21h
	
    popa
    ret       
funCLS endp

prtWordPage proc
	pusha	
	mov cl,0h
	mov si,offset buffer
	mov ch,0h
pwpLoopSb3:
	call prtSpace
	call prtSpace
	call prtSpace
	mov dbvar1,cl
	mov dbcolor,0fh
	call prtbyte

	inc cl
	cmp cl,10h
	jnz pwpLoopSb3

	call prtCRLF  
	

	mov count1,0   
	mov count2,0
	
	mov cl,count2	
	mov dbvar1,cl
	mov dbcolor,0fh
	pusha
    	mov al, dbvar1
    	mov cl, 4
    	shr al, cl
    	and al, 0fh
    	mov dl,al
    	call prt4bit
	popa
	;call prtSpace	
pwpLoop:   
	;mov al,count2
	;shl al,4
	;or al,count1
	;mov [si],al
	
	mov ax,[si]
	mov dwvar1,ax
	inc si
	inc si
	cmp ax,0
	je pwpNColor
	mov dbcolor,04h
	jmp pwpSb1
pwpNColor:
	mov dbcolor,07h
pwpSb1:	
	 mov dbvar1, ah
	 call prtbyte
	 mov dbvar1, al
	 call prtbyte
	 call prtSpace
	cmp ch,strBlenth
	je pwpExit
	inc ch
    cmp count1,0fh
    jnz pwpLoopSb1
    ;call prtCRLF   
    cmp count2,0fh
    jz pwpExit   

    inc count2
	mov cl,count2
	shl cl,4
	mov dbvar1,cl
	mov dbcolor,0fh
	pusha
    	mov al, dbvar1
    	mov cl, 4
    	shr al, cl
    	and al, 0fh
    	mov dl,al
    	call prt4bit
	popa
	;call prtSpace		
    mov count1,0
	inc SPD_Addr
    jmp pwpLoop   
pwpLoopSb1:
	inc SPD_Addr
    inc count1
    jmp pwpLoop   
pwpExit:


    popa
    ret
prtWordPage endp

prtPage proc
	pusha	

	call prtSpace
	call prtSpace
	call prtSpace
	mov cl,0h
	mov si,offset strBuffer
	mov ch,0h
ppLoopSb3:
	mov dbvar1,cl
	mov dbcolor,0fh
	call prtbyte
	call prtSpace
	inc cl
	cmp cl,10h
	jnz ppLoopSb3
	call prtCRLF  
	

	mov count1,0   
	mov count2,0
	
	mov cl,count2	
	mov dbvar1,cl
	mov dbcolor,0fh
 	call prtbyte	
	call prtSpace	
ppLoop:   
	;mov al,count2
	;shl al,4
	;or al,count1
	;mov [si],al
	
	mov al,[si]
	mov dbvar1,al
	inc si
	cmp al,0
	je ppNColor
	mov dbcolor,04h
	jmp ppSb1
ppNColor:
	mov dbcolor,07h
ppSb1:	
	 mov dbvar1, al
	 call prtbyte
	 call prtSpace
	;//
	cmp ch,strBlenth
	je ppExit
	inc ch
    cmp count1,0fh
    jnz ppLoopSb1
    call prtCRLF   
    cmp count2,0fh
    jz ppExit   

    inc count2
	mov cl,count2
	shl cl,4
	mov dbvar1,cl
	mov dbcolor,0fh
  	call prtbyte
	call prtSpace		
    mov count1,0
	inc SPD_Addr
    jmp ppLoop   
ppLoopSb1:
	inc SPD_Addr
    inc count1
    jmp ppLoop   
ppExit:


    popa
    ret
prtPage endp
disableCursor proc
	pusha
	mov ax,0ah
	mov dx,03d4h
	out dx,ax
	mov dx,03d5h

	mov ax,020h
	out dx,ax
	popa
	ret
disableCursor endp
enableCursor proc
	pusha
	mov ax,0ah
	mov dx,03d4h
	out dx,ax
	mov dx,03d5h

	mov al,0dh
	and ax,0bfh
	out dx,ax

	mov ax,0bh
	mov dx,03d4h
	out dx,ax
	mov dx,03d5h

	mov al,0eh
	and ax,0fh
	out dx,ax
	popa
	ret
enableCursor endp
end main
