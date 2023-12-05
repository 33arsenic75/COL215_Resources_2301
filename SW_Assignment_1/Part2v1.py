class Gate:
    def __init__(self,input1,input2,output,delay):
        self.input1=input1
        self.input2=input2
        self.output=output
        self.delay=delay
        
def gate_delays(filename):
    filename=open(filename,'r')
    for i in range(5):
        l=list(filename.readline().split())
        globals()[l[0]]=float(l[1]) 
        
def read_circuit(filename):
    filename=open(filename,'r')
    inp=list(filename.readline().split())
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

def required_output_delay(filename,out):
    filename=open(filename,'r') 
    for i in range(len(out)):      
        l=list(filename.readline().split())
        globals()[l[0]]=float(l[1])

    
    
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

def calculate_input_delays(sort_gate):
    for i in sort_gate:
        x=globals()[i.output]-i.delay
        globals()[i.input1]=min(x,globals()[i.input1])
        globals()[i.input2]=min(x,globals()[i.input2])

            

def write_required(filename,inp):
    filename=open(filename,'w')
    for i in inp:
        s=i+' '+str(globals()[i])
        filename.write(s)
        filename.write('\n')



gate_delays('/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/gate_delays.txt')
inp,out,iv,gates = read_circuit('/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/circuit.txt')
required_output_delay('/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/required_delays.txt',out)
sort_gate=topologicalsort(gates,inp,out,iv)
sort_gate.reverse()
calculate_input_delays(sort_gate)
write_required('/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/input_delays.txt',inp)
