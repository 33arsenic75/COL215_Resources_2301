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





equations=[]
while True:
    try:
        l=list(REQ.readline().split())
        equations.append(Eq(globals()[l[0]],float(l[1])))
    except:
        break
    
    
'''    
for i in range(n-3):
    l=list(INP.readline().split())
    if(len(l)<3):
        break
    if(len(l)==3):
        eq=Eq((globals()[l[0]]+globals()[l[1]]),globals()[l[2]])
        equations.append(eq)
    else:
        m=globals()[l[1]]
        n=globals()[l[2]]
        eq=Eq(globals()[l[0]]+Piecewise((m,m>n),(n,True)),globals()[l[3]])
        equations.append(eq)
'''
for i in range(n-3):
    l = list(INP.readline().split())
    if len(l) < 3:
        break
    if(len(l)==3):
        output_vars=globals()[l[2]]
        gate_delay=globals()[l[0]]
        input_vars=[globals()[l[1]]]
        eq = Eq(output_vars, sum(input_vars) + gate_delay)
        equations.append(eq)
    else:
        output_vars=globals()[l[3]]
        gate_delay=globals()[l[0]]
        m=globals()[l[1]]
        n=globals()[l[2]]
        input_vars=Piecewise((m,m>n),(n,True))
        eq = Eq(output_vars,input_vars+ gate_delay)
        equations.append(eq)
        

    
    
    
print(equations)
print(variables)
variables=tuple(variables)
from sympy import nsolve
solutions = nsolve(equations, variables, [0.0] * len(variables), prec=1e-10)
'''
solutions = nsolve(equations, variables, [0] * len(variables))
solutions = solve(equations,variables,manual=True)
'''
print(solutions)


    
    
    
    
    
    
    
    
    