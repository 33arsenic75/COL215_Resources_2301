import sys
class Gate:
    def __init__(self,input1,input2,output,delay):
        self.input1=input1
        self.input2=input2
        self.output=output
        self.delay=delay
        
def gate_delays(filename):
    filename=open(filename,'r')
    while True:
        l=filename.readline()
        if(l[0]=="/" or l[0]=="\n"):
            continue
        else:
            break
    l=list(l.split())
    for i in range(5):
        globals()[l[0]]=float(l[1])
        l=list(filename.readline().split())
        
def topologicalsort(gates,inp,out,iv):
    variables={v:0 for v in inp+out+iv}
    for i in inp:
        variables[i]=1
    markdown={g:0 for g in gates}
    queue=[]
    while len(gates)!=0:
        for i in gates:
            if(markdown[i]==1):
                continue
            x=i.input1
            y=i.input2
            z=i.output
            if(variables[x]==1 and variables[y]==1):
                variables[z]=1
                queue.append(i)
                markdown[i]=1
                gates.remove(i)
    return queue

def calculate_output_delays(sorted_gates):
    for i in sorted_gates:
        j=max(globals()[i.input1],globals()[i.input2])
        globals()[i.output]=max(globals()[i.output],float(i.delay)+j)
    
def write_output_delays(out,filename):
    filename=open(filename,'w')
    for i in out:
        x=f'{globals()[i]:.9g}'
        s=i+' '+x.__str__()
        filename.write(s)
        filename.write('\n')

def read_circuitB(filename):
    filename=open(filename,'r')
    l=filename.readline()
    while(l[0]=="/" or l[0]=='\n'):
        l=filename.readline()
        continue
    inp=list(l.split())
    inp=inp[1:]
    for i in inp:
        globals()[i]=float('inf')
    out=list(filename.readline().split())
    out=out[1:]
    for i in out:
        globals()[i]=0;
    iv=list(filename.readline().split())
    iv=iv[1:]
    for i in iv:
        globals()[i]=float('inf')
    gates=[]
    while True:
        try:
            l=list(filename.readline().split())
            if(len(l)==3):
                x=Gate(l[1],l[1],l[2],globals()[l[0]])
                gates.append(x)
            else:
                x=Gate(l[1],l[2],l[3],globals()[l[0]])
                gates.append(x)
        except:
            break
    
    return  inp,out,iv,gates

def read_circuitA(filename):
    filename=open(filename,'r')
    l=filename.readline()
    while(l[0]=='/' or l[0]=='\n'):
        l=filename.readline()
        continue
    inp=list(l.split())
    inp=inp[1:]
    for i in inp:
        globals()[i]=0
    out=list(filename.readline().split())
    out=out[1:]
    for i in out:
        globals()[i]=0;
    iv=list(filename.readline().split())
    iv=iv[1:]
    for i in iv:
        globals()[i]=0;
    gates=[]
    while True:
        try:
            l=list(filename.readline().split())
            if(len(l)==3):
                x=Gate(l[1],l[1],l[2],globals()[l[0]])
                gates.append(x)
            else:
                x=Gate(l[1],l[2],l[3],globals()[l[0]])
                gates.append(x)
        except:
            break
    
    return  inp,out,iv,gates

def calculate_input_delays(sort_gate):
    for i in sort_gate:
        x=globals()[i.output]-float(i.delay)
        globals()[i.input1]=min(x,globals()[i.input1])
        globals()[i.input2]=min(x,globals()[i.input2])

def write_required(filename,inp):
    filename=open(filename,'w')
    for i in inp:
        x=f'{globals()[i]:.9g}'
        s=i+' '+x.__str__()
        filename.write(s)
        filename.write('\n')

def required_output_delay(filename,out):
    filename=open(filename,'r') 
    for i in range(len(out)):      
        l=list(filename.readline().split())
        globals()[l[0]]=float(l[1])
        
def PartA():
    gate_delays(gate_delay)
    inp,out,iv,gates = read_circuitA(circuit)
    sort_gate=topologicalsort(gates,inp,out,iv)
    calculate_output_delays(sort_gate)
    write_output_delays(out,'output_delays.txt')
    
def PartB():
    gate_delays(gate_delay)
    inp,out,iv,gates = read_circuitB(circuit)
    required_output_delay(required_delay,out)
    sort_gate=topologicalsort(gates,inp,out,iv)
    sort_gate.reverse()
    calculate_input_delays(sort_gate)
    write_required('input_delays.txt',inp)

s=sys.argv[1]
circuit=sys.argv[2]
gate_delay=sys.argv[3]
required_delay=sys.argv[4]
if(s=="A"):
    PartA()
elif(s=="B"):
    PartB()
    
