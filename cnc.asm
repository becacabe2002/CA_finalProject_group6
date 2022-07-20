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
.text
#Xử lý trên keymatrix
	li $t3, IN_ADRESS_HEXA_KEYBOARD
	li $t4, OUT_ADRESS_HEXA_KEYBOARD
polling: 
	CHECK_NUMPAD_0:
	li $t5, 0x01 # hàng 1 trong key matrix
	sb $t5, 0($t3) # phải chỉ định lại hàng dự kiến
	lb $a0, 0($t4) # đọc giá trị của nút được chọn
	bne $a0, 0x11, CHECK_NUMPAD_4 # nếu không phải nút 0 thì kiểm tra hàng tiếp theo
	la $a1, postcript1 # gán địa chỉ của postcript1 vào $a1
	j RUN
	CHECK_NUMPAD_4:
	li $t5, 0x02 # hàng 2 trong key matrix
	sb $t5, 0($t3)# phải chỉ định lại hàng dự kiến
	lb $a0, 0($t4)# đọc giá trị của nút được chọn
	bne $a0, 0x12, CHECK_NUMPAD_8# nếu không phải nút 4 thì kiểm tra hàng tiếp theo
	la $a1, postcript2# gán địa chỉ của postcript2 vào $a1
	j RUN
	CHECK_NUMPAD_8:
	li $t5, 0X04 # hàng 3 trong key matrix
	sb $t5, 0($t3) # phải chỉ định lại hàng dự kiến
	lb $a0, 0($t4)# đọc giá trị của nút được chọn
	bne $a0, 0x14, BACK# nếu không phải nút 8 thì quay trở lại hàng đầu tiên
	la $a1, postcript3# gán địa chỉ của postcript3 vào $a1
	j RUN
BACK:	j polling # quay lại đọc tiếp cho đến khi 0 hoặc 4 hoặc 8 được chọn

# Xử lý Marsbot
RUN:
	jal GO
READ_POSTCRIPT: 
	addi $t0, $zero, 0 # Lưu giá trị rotate
	addi $t1, $zero, 0 # Lưu giá trị time
	
 	READ_ROTATE:# Đọc góc quay
 	add $t7, $a1, $t6 # dịch bit ($a1 lưu địa chỉ của postscript)
	lb $t5, 0($t7)  # Đọc kí tự postscript
	beq $t5, 0, END # Kết thúc postscript
 	beq $t5, 44, READ_TIME # Gặp dấu ',' thì chuyển sang đọc thời gian
 	mul $t0, $t0, 10 # Nhân 10 lần giá trị lúc trước
 	addi $t5, $t5, -48 # Chuyển số theo mã ascii về dạng thập phân (Trong bảng ascii thì số 0 có thứ tự 48)
 	add $t0, $t0, $t5  # Cộng các chữ số
 	addi $t6, $t6, 1 # Tăng 1 bit dịch chuyển
 	j READ_ROTATE # Đọc tiếp kí tự tiếp theo
 	
 	READ_TIME: # đọc thời gian chuyển động
 	add $a0, $t0, $zero # gán góc quay vào a0
	jal ROTATE # quay Marsbot
 	addi $t6, $t6, 1 # Tăng 1 bit dịch chuyển
 	add $t7, $a1, $t6 # dịch bit
	lb $t5, 0($t7) # Đọc kí tự postscript
	beq $t5, 44, READ_TRACK# Gặp dấu ',' thì chuyển sang đọc trạng thái
	mul $t1, $t1, 10 # Nhân 10 lần giá trị lúc trước
 	addi $t5, $t5, -48 # Chuyển số theo mã ascii về dạng thập phân
 	add $t1, $t1, $t5 # Cộng các chữ số
 	j READ_TIME  # Đọc tiếp kí tự tiếp theo
 	
 	READ_TRACK:# Đọc trạng thái
 	addi $v0,$zero,32 # Giữ nguyên trạng thái sleep của Marsbot bằng syscall 32
 	add $a0, $zero, $t1 # gán thời gian chuyển động vào a0
 	addi $t6, $t6, 1 # Tăng 1 bit dịch chuyển
 	add $t7, $a1, $t6 # dịch bit
	lb $t5, 0($t7) # Đọc kí tự postscript
 	addi $t5, $t5, -48  # Chuyển số theo mã ascii về dạng thập phân
 	beq $t5, $zero, CHECK_UNTRACK # 1 -> track | 0 -> untrack
 	jal UNTRACK # dừng cắt nét trước
	jal TRACK # cắt nét tiếp theo
	j NEXT # chuyển sang bước di chuyển tiếp theo
	
CHECK_UNTRACK:
	jal UNTRACK
NEXT:
	syscall
 	addi $t6, $t6, 2 # Bỏ qua dấu ';'
 	j READ_POSTCRIPT

GO: 
 	li $at, MOVING # thay đổi cổng MOVING
 	addi $k0, $zero,1 # thành mức logic 1
 	sb $k0, 0($at) # để bắt đầu chạy
 	jr $ra

STOP: 
	li $at, MOVING # thay đổi cổng MOVING
 	sb $zero, 0($at) # thành mức logic 0
 	jr $ra # đề dừng chạy

TRACK: 
	li $at, LEAVETRACK # thay đổi cổng LEAVETRACK
 	addi $k0, $zero,1 # thành mức logic 1
	sb $k0, 0($at) # để bắt đầu cắt
 	jr $ra

UNTRACK:
	li $at, LEAVETRACK # thay đổi cổng LEAVETRACK thành mức logic 0
 	sb $zero, 0($at) # đề dừng cắt
 	jr $ra

ROTATE: 
	li $at, HEADING # thay đổi cổng HEADING
 	sw $a0, 0($at) # để quay góc robot
 	jr $ra
END:
	jal STOP
	li $v0, 10
	syscall

