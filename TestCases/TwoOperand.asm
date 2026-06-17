# all numbers in hex format
# we always start by reset signal
# this is a commented line
# you should ignore empty lines

.ORG 0  #this is the reset address
200

.ORG 200
LDM R1, 0006       #add 6 in R1
LDM R2, 0020       #add 20 in R2
LDM R3, FFFC
LDM R4, F322
IADD R5,R3,2  #R5 = FFFE,
ADD  R4,R1,R4    #R4= F328 , 
SUB  R6,R5,R4    #R6= 0CD6 , // R6 = R5 - R4
AND  R6,R7,R6    #R6= 00000000 ,
SWAP R6,R1    #R1=00000000, R6=6,
NOP
MOV  R1, R3    #R3=0000000, 
ADD  R2,R5,R2    #R2= 0001001E,
OUT R1 
OUT R2 
OUT R3
OUT R4
OUT R5
OUT R6
OUT R7

