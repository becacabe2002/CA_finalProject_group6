# Bai tap cua nhom co tham khao tu nguon: https://github.com/BlazingRockStorm/MISP-assembly-of-HEDSPI
# Chuc nang kiem tra string da duoc cai tien, chi xet chuoi cuoi cung nhan duoc (BACKSPACE co hieu luc)

.eqv SEVENSEG_LEFT    0xFFFF0011 # Dia chi cua den led 7 doan trai	
.eqv SEVENSEG_RIGHT   0xFFFF0010 # Dia chi cua den led 7 doan phai 
.eqv IN_ADRESS_HEXA_KEYBOARD       0xFFFF0012  
.eqv OUT_ADRESS_HEXA_KEYBOARD      0xFFFF0014	
.eqv KEY_CODE   0xFFFF0004         # ASCII code from keyboard, 1 byte 
.eqv KEY_READY  0xFFFF0000        	# =1 if has a new keycode ?                                  
				        # Auto clear after lw  
.eqv DISPLAY_CODE   0xFFFF000C   	# ASCII code to show, 1 byte 
.eqv DISPLAY_READY  0xFFFF0008   	# =1 if the display has already to do  
	                                # Auto clear after sw  
.eqv MASK_CAUSE_KEYBOARD   0x0000034     # Keyboard Cause    
  
.data 
byte_hex_led     : .byte 63,6,91,79,102,109,125,7,127,111 # gia tri cua byte tai 0xFFFF0010 de hien thi t? 0->9
storestring : .space 1000			#khoang trong de luu cac ky tu nhap tu ban phim.
stringsource : .asciiz "bo mon ky thuat may tinh" 
Message: .asciiz "\n So ky tu trong 1s :  "
resultMess: .asciiz  "\n So ky tu nhap dung la: "  
notification: .asciiz "\n ban co muon quay lai chuong trinh? "
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
# MAIN Procsciiz ciiz edure 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
.text
	li   $k0,  KEY_CODE              
	li   $k1,  KEY_READY                    
	li   $s0, DISPLAY_CODE              
	li   $s1, DISPLAY_READY  	
MAIN:         
	li $s4,0 			#dung de dem toan bo so ky tu nhap vao
  	li $s3,0			#dung de dem so vong lap 
 	li $t4,10				
  	li $t5,200			#luu gia tri so vong lap. 
	li $t6,0			#bien dem so ky tu nhap duoc trong 1s
	li $t9,0
LOOP:          
WAIT_FOR_KEY:  
 	lw   $t1, 0($k1)                  # $t1 = [$k1] = KEY_READY              
	beq  $t1, $zero,POLLING               # if $t1 == 0 then Polling             
MAKE_INTER:

	addi $t6,$t6,1    		#tang bien dem ky tu nhap duoc trong 1s len 1
	teqi $t1, 1                     # if $t1 = 1 then raise an Interrupt    
#---------------------------------------------------------         
# Loop an print sequence numbers         
#---------------------------------------------------------
POLLING:          
	#neu da lap dk 200 vong( 1s) se nhay den xu ly so ky tu nhap trong 1s.
	addi    $s3, $s3, 1     # dem so ky tu nhap vao tu ban phim.
	div $s3,$t5		#lay so vong lap chia cho 200 de xac dinh da duoc 1s hay chua
	mfhi $t7		#luu phan du cua phep chia tren
	bne $t7,0,SLEEP		#neu chua duoc 1s (s3/s5 = 1)nhay den label sleep
				#neu da duoc 1s thi nhay den nhan SETCOUNT de thuc hien in ra man hinh
SETCOUNT: # in ra man hinh so chu danh duoc trong 1s
	li $s3,0		#tai lap gia tri cua $s3 ve 0 de dem lai so vong lap cho cac lan tiep theo
	li $v0,4		#bat dau chuoi lenh in ra console so ky tu nhap duoc trong 1s
	la $a0,Message
	syscall	
	li    $v0,1            	#in ra so ky tu trong 1s
	add   $a0,$t6,$zero    	# Nhan bien t6 dem so ky nhap duoc trong 1s		
	syscall
DISPLAY_DIGITAL: # Hien so chu nhap vao/1s tren 2 thanh led 7 thanh, ngoai ra con dc dung de hien so tu go dung khi set ket qua vao thanh ghi t6
	div $t6,$t4		#lay so ky tu nhap duoc trong 1s chia cho 10
	mflo $t7		#luu gia tri phan nguyen, gia tri nay se duoc luu o den LED ben trai
	la $s2,byte_hex_led	#con tro toi array chua cac so hien thi tren led
	add $s2,$s2,$t7		# xac dinh vi tri con tro =  cong them gia tri t7 vao con tro ban dau
	lb $a0,0($s2)           #lay noi dung cho vao $a0           
	jal   SHOW_7SEG_LEFT    # ngay den label den LED trai
#------------------------------------------------------------------------
	mfhi $t7		#luu gia tri phan du cua phep chia, gia tri nay se duoc in ra trong den LED ben phai
	la $s2,byte_hex_led			
	add $s2,$s2,$t7
	lb $a0,0($s2)           # set value for segments           
	jal  SHOW_7SEG_RIGHT    # show    
#------------------------------------------------------------------------                                            
	li    $t6,0		#reset lai bien dem t6 trc kho quay l?i loop
	beq $t9,1,ASK_LOOP 	# bien t9 dung de kiem tra
				# neu display_digital dc dung cho viec hien thi correct input, t9 = 1
				# neu display_digítal dc dung cho viec hien thi so tu nhap vao 1s, t9 = 0 (default)
SLEEP:  
	addi    $v0,$zero,32                   
	li      $a0,5           # sleep 5 ms         
	syscall         
	nop           	        # nop la can thiet sau trc khi branch sau syscall          
	b       LOOP          	# Loop 

END_MAIN: 
	li $v0,10
	syscall
	
SHOW_7SEG_LEFT:  
	li   $t0,  SEVENSEG_LEFT 	# gan dia chi cong nhu da khai bao                 
	sb   $a0,  0($t0)        	# gan gia tri moi vao cong                    
	jr   $ra 
	
SHOW_7SEG_RIGHT: 
	li   $t0,  SEVENSEG_RIGHT 	                 
	sb   $a0,  0($t0)         	                
	jr   $ra 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PHAN PHUC VU NGAT (soft interupt)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
.ktext    0x80000180         		#chuong trinh con chay sau khi interupt duoc goi.         
	mfc0  $t1, $13                  # cho biet nguyen nhan lam tham chieu dia chi bo nho khong hop
	li    $t2, MASK_CAUSE_KEYBOARD              
	and   $at, $t1,$t2              
	beq   $at,$t2, COUNTER_KETYBOARD              
	j    END_PROCESS  

COUNTER_KETYBOARD: 
READ_KEY:  
	    lw   $t0, 0($k0)            		# $t0 = [$k0] = KEY_CODE 	    
	
WAIT_FOR_DIS: 
	     lw   $t2, 0($s1)            	# $t2 = [$s1] = DISPLAY_READY            
	     beq  $t2, $zero, WAIT_FOR_DIS	# if $t2 == 0 then Polling  
	     
	     beq $t0, 8, DELETE_CHAR  # neu ky hieu nhan vao la phim BACKSPACE, nh?y t?i DELETE_CHAR                           
SHOW_KEY:
	     sb $t0, 0($s0)              	# hien thi ky tu vua nhap tu ban phim tren man hinh MMIO
	     # luu ky tu input vao mang storestring
             la  $t7,storestring		# lay $t7 con tro cua chuoi luu chuoi nhap vao
             add $t7,$t7,$s4			# di chuyen con tro toi vi tri moi
             sb $t0,0($t7)			# luu lai tu vua nhap
             addi $s4,$s4,1			# tang so luong tu nhap vao
             beq $t0,10,END                     # Can chu y toi ki hieu xuong dong '\n' - ASCII: 10
             					# Neu xuat hien '\n' --> xong input process --> Chuyen toi END
	     j END_PROCESS
	     
DELETE_CHAR: # viec xoa ki tu nhap vao tuong duong
	     # voi viec lam giam tong so ky tu nhap vao s4 di 1
	addi $s4, $s4, -1
	sb $t0, 0($s0)
	

END_PROCESS:                         
NEXT_PC:   mfc0    $at, $14	        # $at <= Coproc0.$14 = Coproc0.epc              
	    addi    $at, $at, 4	        # $at = $at + 4 (next instruction)              
            mtc0    $at, $14	       	# Coproc0.$14 = Coproc0.epc <= $at  
RETURN:   eret                       	# tro ve len ke tiep cua chuong trinh chinh

# ---- HET PHAN PHUC VU NGAT
END:
	li $v0,11         
	li $a0,'\n'         		#in xuong dong
	syscall 
	li $t1,0 			#reset bien dem t1 de dem so ky tu da duoc xet
	li $t3,0                        # khai bao bien t3 de dem so ky tu nhap dung
	li $t8,24			#luu $t8 la do dai xau da luu tru trong ma nguon.
	slt $t7,$s4,$t8			#so sanh xem do dai xau nhap tu ban phim (luu tai thanh s4) va do dai cua xau co dinh trong ma nguon (luu tai t8)
					#xau nao nho hon thi duyet theo do dai cua xau do (s4 < t8 -> t7 = 1; else t7 = 0)
					
	bne $t7,1, CHECK_STRING	
	add $t8,$0,$s4			#trong TH xau input >= xau luu san, t8 chua do dai cua sau input
	addi $t8,$t8,-1			#tru 1 vi ky tu cuoi cung la dau enter thi khong can xet.

CHECK_STRING:			
	la $t2,storestring
	add $t2,$t2,$t1
	li $v0,11			#in ra cac ky tu da nhap tu ban phim da qua check.
	lb $t5,0($t2)			#lay ky tu thu $t1 trong storestring luu vao $t5 de so sanh voi ky tu thu $t1 o stringsource
	move $a0,$t5			# set noi dung thanh ghi a0 = noi dung thanh ghi t5
	syscall 
	la $t4,stringsource
	add $t4,$t4,$t1
	lb $t6,0($t4)			#lay ky tu thu $t1 trong stringsource luu vao $t6
	bne $t6,$t5,CONTINUE		# so sanh hai ky tu luu trong t5 va t6, neu 2 ky tu ko giong nhau thi tiep tuc vong lap check
	addi $t3,$t3,1			# neu giong, tang so ki tu nhap dung t3 len them 1

CONTINUE: 
	addi $t1,$t1,1			#sau khi so sanh 1 ky tu, tang bien dem len 
	beq $t1,$t8,PRINT		#neu da duyet het so ky tu can xet (so luong ki tu cua chuoi nho hon), tien hanh in ket qua ra man hinh
	j CHECK_STRING			#con khong thi tiep tuc xet tiep cac ky tu 

PRINT:	
	li $v0,4
	la $a0,resultMess
	syscall
	li $v0,1
	add $a0,$0,$t3			# in so tu nhap dung
	syscall	
	li $t9,1			#! thay doi de su dung lai qua trinh display_led o tren
	li $t6,0			# gan lai gia tri bien dem t6
	li $t4,10			# gan lai gia tri so chia = 10 cho t4
	add $t6,$0,$t3
	b DISPLAY_DIGITAL 

ASK_LOOP: # hoi nguoi dung co muon lap lai chuong trinh khong
	li $v0, 50
	la $a0, notification
	syscall
	beq $a0,0,MAIN	# neu co, branch toi main	
	b EXIT
EXIT: 


