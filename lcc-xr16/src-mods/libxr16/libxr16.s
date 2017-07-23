global __reset
align 16
__reset:
addi sp,sp,-8
sw r15,6(sp)
call __resetmem
call _main
L2:
br L2
L1:
lw r15,6(sp)
addi sp,sp,8
ret

global __resetmem
align 16
__resetmem:
addi sp,sp,-12
sw r11,6(sp)
sw r12,8(sp)
sw r15,10(sp)
lea r12,__end
call __tos
mov r11,r2
br L10
L7:
sw r0,(r12)
L8:
lea r12,2(r12)
L10:
mov r9,r12
mov r8,r11
cmp r9,r8
bltu L7
L6:
lw r11,6(sp)
lw r12,8(sp)
lw r15,10(sp)
addi sp,sp,12
ret

global __interrupt
align 16
__interrupt:
mov r2,r0
L11:
ret

global __tos
align 16
__tos:
sw r3,0(sp)
lea r2,0+0(sp)
L12:
ret

global __end
align 2
__end:
bss 2
