from sympy import symbols, Eq, solve, re,Piecewise
import sys
import fileinput
INP=open("/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/circuit.txt",'r')
x=open("/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/circuit.txt",'r')
n=len(list(x.readline()))
REQ=open("/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/required_delays.txt",'r')
OUT=open("/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/input_delays.txt",'w')
DEL=open("/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/gate_delays.txt",'r')
x=len(list(DEL.readline()))
DEL=open("/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/gate_delays.txt",'r')
for i in range(x):
    l=list(DEL.readline().split())
    if(len(l)!=2):
        break
    print(l)
    globals()[l[0]]=float(l[1])




variables=[]
inp=list(INP.readline().split())
inp=inp[1:]
for i in range(len(inp)):
    globals()[inp[i]]=symbols(inp[i],real=True)
    variables.append(globals()[inp[i]])




out=list(INP.readline().split())
out=out[1:]
for i in range(len(out)):
    globals()[out[i]]=symbols(out[i],real=True)
    variables.append(globals()[out[i]])
 
 
 
 
    
iv=list(INP.readline().split())
iv=iv[1:]
for i in range(len(out)):
    globals()[iv[i]]=symbols(iv[i],real=True)
    variables.append(globals()[iv[i]])





Equations=[]
while True:
    try:
        l=list(REQ.readline().split())
        Equations.append(Eq(0,-globals()[l[0]]+int(l[1])))
    except:
        break
    
    
    
for i in range(n-3):
    l=list(INP.readline().split())   
    print(l)
    if(len(l)<3):
        break
    if(len(l)==3):
        Equations.append(Eq(globals()[l[2]],globals()[l[0]]+globals()[l[1]]))
        print(0)
    else:
        Equations.append(Eq(globals()[l[3]],globals()[l[0]]+Piecewise((globals()[l[1]],globals()[l[1]]>globals()[l[2]]),(globals()[l[2]],True))))                   
        print(1)

    
    
    
print(Equations)
print(variables)
variables=tuple(variables)
print(solve(Eq,variables))
    
    
    
    
    
    
    
    
    