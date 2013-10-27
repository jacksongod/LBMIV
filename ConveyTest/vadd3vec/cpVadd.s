
	.file	"cpVadd.s"
	.ctext

	.globl	cpVadd
	.type	cpVadd. @function
	.signature	pdk=4

# cpVadd function:
#       -writes array pointers and size into AEG registers 
# 	-calls caep00 to execute vector add 
#	-reads partial sums from AEs
#	-reduction is done on the scalar processor 

cpVadd:
	mov %a8, $0, %aeg		# a8 contains address of a1
	mov %a9, $1, %aeg		# a9 contains address of a2
	mov %a10, $2, %aeg		# a10 contains address of a3
	mov %a11, $3, %aeg		# a11 contains length of vectors
	mov %a12, $5, %aeg		# a12 contains address  of a4
	caep00 $0
	mov.ae0 %aeg, $30, %a16		# read sums from each AE
	mov.ae1 %aeg, $31, %a17
	mov.ae2 %aeg, $32, %a18
	mov.ae3 %aeg, $33, %a19
	add.uq %a16, %a17, %a8		# sum results from each AE
	add.uq %a8, %a18, %a8
	add.uq %a8, %a19, %a8		# final sum returned in A8
	rtn 
	.cend
	
