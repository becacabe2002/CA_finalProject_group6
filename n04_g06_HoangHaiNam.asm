# Bai tap cua nhom co tham khao tu nguon: https://github.com/BlazingRockStorm/MISP-assembly-of-HEDSPI

# Mars bot
.eqv HEADING 0xffff8010 
.eqv MOVING 0xffff8050
.eqv LEAVETRACK 0xffff8020
.eqv WHEREX 0xffff8030
.eqv WHEREY 0xffff8040
# Key matrix
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012

.data
# (rotate,time,0=untrack | 1=track;)
# numpad 0 -> postscript-DCE
postcript1: .asciiz "90,2000,0;180,3000,0;180,5790,1;80,500,1;70,500,1;60,500,1;50,500,1;40,500,1;30,500,1;20,500,1;10,500,1;0,500,1;350,500,1;340,500,1;330,500,1;320,500,1;310,500,1;300,500,1;290,500,1;280,500,1;90,8000,0;270,500,1;260,500,1;250,500,1;240,500,1;230,500,1;220,500,1;210,500,1;200,500,1;190,500,1;180,500,1;170,500,1;160,500,1;150,500,1;140,500,1;130,500,1;120,500,1;110,500,1;100,500,1;90,500,1;90,5500,0;270,3000,1;0,5800,1;90,3000,1;180,2900,0;270,3000,1;90,3000,0;180,2000,0;90,2000,0;"
# numpad 4 -> postscript-H.NAM 
postcript2: .asciiz "180,9000,0;90,2000,0;0,6000,1;180,3000,0;90,3000,1;0,3000,0;180,6000,1;90,1500,0;90,500,1;0,500,1;270,500,1;180,500,1;90,2000,0;0,6000,1;150,6830,1;0,6000,1;90,2500,0;90,2500,0;200,6400,1;90,4300,0;340,6400,1;200,3500,0;90,2450,1;90,3500,0;180,3000,0;0,6000,1;140,4000,1;40,4000,1;180,6000,1;0,1000,0;90,2000,0;"
# numpad 8 -> postscript-M.TÚ
postcript3: .asciiz "180,9000,0;90,2000,0;0,6000,1;140,4000,1;40,4000,1;180,6000,1;90,1500,0;90,500,1;0,500,1;270,500,1;180,500,1;90,3000,0;0,6000,1;270,2000,0,90,4000,1;90,2000,0;180,4500,1;170,300,1;160,300,1;150,300,1;140,300,1;130,300,1;120,300,1;110,300,1;100,300,1;90,300,1;80,300,1;70,300,1;60,300,1;50,300,1;40,300,1;30,300,1;20,300,1;10,300,1;0,4500,1;270,1900,0;0,700,0;40,2000,1,90,2000,0,180,7500,0"
notification: .asciiz "\n Ban co muon quay lai chuong trinh? "
.text
#Xu ly tren keymatrix
MAIN:
	li $t3, IN_ADRESS_HEXA_KEYBOARD
	li $t4, OUT_ADRESS_HEXA_KEYBOARD
polling: 
	CHECK_NUMPAD_0:
	li $t5, 0x01 # hang 1 trong key matrix
	sb $t5, 0($t3) # phai chi Ä‘inh lai hang du kien
	lb $a0, 0($t4) # doc gia tri cua nut duoc chon
	bne $a0, 0x11, CHECK_NUMPAD_4 # neu khong phai nut 0 thi kiem tra hang tiep theo
	la $a1, postcript1 # gan gia chi cua postcript1 vao $a1
	j RUN
	CHECK_NUMPAD_4:
	li $t5, 0x02 # hang 2 trong key matrix
	sb $t5, 0($t3)# phai chi dinh lai hang du kien
	lb $a0, 0($t4)# doc gia tri cua nut duoc chon
	bne $a0, 0x12, CHECK_NUMPAD_8# neu khong phai nut 4 thi kiem tra hang tiep theo
	la $a1, postcript2# gan dia chi cua postcript2 vao $a1
	j RUN
	CHECK_NUMPAD_8:
	li $t5, 0X04 # hang 3 trong key matrix
	sb $t5, 0($t3) # phai chi dinh lai hang du kien
	lb $a0, 0($t4)# doc gia tri cua nut duoc chon
	bne $a0, 0x14, BACK# neu khong phai nut 8 thi kiem tra hang tiep theo
	la $a1, postcript3# gan dia chi cua postcript3 vao $a1
	j RUN
BACK:	j polling # quay lai doc tiep cho den khi 0 hoac 4 hoac 8 duoc chon

# Xu ly Marsbot
RUN:
	jal GO
READ_POSTCRIPT: 
	addi $t0, $zero, 0 # Luu gia tri rotate
	addi $t1, $zero, 0 # Luu gia tri time
	
 	READ_ROTATE:# Ä?oc goc quay
 	add $t7, $a1, $t6 # dich bit ($a1 luu dia chi cua postscript)
	lb $t5, 0($t7)  # doc ki tu postscript
	beq $t5, 0, END # Ket thuc postscript
 	beq $t5, 44, READ_TIME # Gap dau ',' thi chuyen sang doc thoi gian
 	mul $t0, $t0, 10 # Nhan 10 lan gia tri luc truoc
 	addi $t5, $t5, -48 # Chuyen so theo ma ascii ve dang thap phan (Trong bang ascii thi so 0 co thu tu 48)
 	add $t0, $t0, $t5  # Cong cac chu so
 	addi $t6, $t6, 1 # Tang 1 bit dich chuyen
 	j READ_ROTATE # Doc tiep ki tu tiep theo
 	
 	READ_TIME: # do thoi gian chuyen dong
 	add $a0, $t0, $zero # gan goc quay vao a0
	jal ROTATE # quay Marsbot
 	addi $t6, $t6, 1 # Tang 1 bit dich chuyen
 	add $t7, $a1, $t6 # dich bit
	lb $t5, 0($t7) # doc ki tu postscript
	beq $t5, 44, READ_TRACK# Gap dau ',' thi chuyen sang doc thoi gian
	mul $t1, $t1, 10 # Nhan 10 lan gia tri luc truoc
 	addi $t5, $t5, -48 # Chuyen so theo ma ascii ve dang thap phan
 	add $t1, $t1, $t5 # Cong cac chu so
 	j READ_TIME  # Doc tiep ki tu tiep theo
 	
 	READ_TRACK:# doc trang thai
 	addi $v0,$zero,32 # Giu nguyen trang thai sleep cua Marsbot bang syscall 32
 	add $a0, $zero, $t1 # gan thoi gian chuyen dong vao a0
 	addi $t6, $t6, 1 # Tang 1 bit dich chuyen
 	add $t7, $a1, $t6 # dich bit
	lb $t5, 0($t7) # doc ki tu postscript
 	addi $t5, $t5, -48  # Chuyen so theo ma ascii ve dang thap phan
 	beq $t5, $zero, CHECK_UNTRACK # 1 -> track | 0 -> untrack
 	jal UNTRACK # dung cat net truoc
	jal TRACK # cat net tiep theo
	j NEXT # chuyen sang buoc di chuyen tiep theo
	
CHECK_UNTRACK:
	jal UNTRACK
NEXT:
	syscall
 	addi $t6, $t6, 2 # Bo qua dau ';'
 	j READ_POSTCRIPT

GO: 
 	li $at, MOVING # thay doi cong MOVING
 	addi $k0, $zero,1 # thanh muc logic 1
 	sb $k0, 0($at) # de bat dau chay
 	jr $ra

STOP: 
	li $at, MOVING # thay doi cong MOVING
 	sb $zero, 0($at) # thanh muc logic 0
 	jr $ra # de dung chay

TRACK: 
	li $at, LEAVETRACK # thay doi cong LEAVETRACK
 	addi $k0, $zero,1 # thanh muc logic 1
	sb $k0, 0($at) # de bat dau cat
 	jr $ra

UNTRACK:
	li $at, LEAVETRACK # thay doi cong LEAVETRACK thanh muc logic 0
 	sb $zero, 0($at) # de dung cat
 	jr $ra

ROTATE: 
	li $at, HEADING # thay doi cong HEADING
 	sw $a0, 0($at) # de quay goc robot
 	jr $ra
END:
	jal STOP
	
ASK_LOOP: # hoi nguoi dung co muon lap lai chuong trinh khong
	li $v0, 50
	la $a0, notification
	syscall
	beq $a0,0,MAIN	# neu co, branch toi main	
	b EXIT
EXIT: 

