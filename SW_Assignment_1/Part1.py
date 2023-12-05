from sympy import symbols, Eq, solve
import sys
import fileinput
INP=open("/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/circuit.txt",'r')
OUT=open("/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/output_delays.txt",'w')
inp=list(INP.readline().split())
inp=inp[1:]
for i in range(len(inp)):
    globals()[inp[i]]=0

out=list(INP.readline().split())
out=out[1:]
for i in range(len(out)):
    globals()[out[i]]=0
iv=list(INP.readline().split())
iv=iv[1:]
for i in range(len(iv)):
    globals()[iv[i]]=0

x=open("/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/gate_delays.txt")
while True:
    try:
        l=list(x.readline().split())
        globals()[l[0]]=float(l[1])
    except:
        break

while True:
    try:
        line=list(INP.readline().split())
        if(line[0]=='INV'):
            globals()[line[-1]]=INV+globals()[line[1]]
        elif(line[0]=='OR2'):
            globals()[line[-1]]=OR2+max(globals()[line[1]],globals()[line[2]])
        elif(line[0]=='NOR2'):
            globals()[line[-1]]=NOR2+max(globals()[line[1]],globals()[line[2]])
        elif(line[0]=='AND2'):
            globals()[line[-1]]=AND2+max(globals()[line[1]],globals()[line[2]])
        elif(line[0]=='NAND2'):
            globals()[line[-1]]=NAND2+max(globals()[line[1]],globals()[line[2]])
        else:
            break
    except:
        break
    

for i in range(len(out)):
    s=out[i]+' '+str(globals()[out[i]])
    OUT.write(s)
    OUT.write('\n')


    