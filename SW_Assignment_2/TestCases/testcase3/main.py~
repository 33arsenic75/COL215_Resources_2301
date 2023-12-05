from collections import deque
import copy
import sys

def read_circuit_fileA(file_path, gate_delays):
    inputs = []
    outputs = []
    internal_signals = []
    Signal={}
    Succesor={}
    Predecesor={}
    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            if not line or line.startswith('//'):
                continue
            parts = line.split()
            if parts[0] == 'PRIMARY_INPUTS':
                # Split the remaining parts and extend the inputs list
                inputs+=parts[1:]
                for i in parts[1:]:
                    Signal[i]=0
            elif parts[0] == 'PRIMARY_OUTPUTS':
                #outputs = parts[1:]
                outputs+=parts[1:]
                for i in parts[1:]:
                    Signal[i]=-1;
            elif parts[0] == 'INTERNAL_SIGNALS':
                #internal_signals = parts[1:]
                internal_signals+=parts[1:]
                for i in parts[1:]:
                    Signal[i]=-1;
            else:
                gate_type = parts[0]
                input = parts[1:-1]
                output = parts[-1]
                if(gate_type=='DFF'):
                    inputs.append(output)
                    if output in internal_signals:
                        internal_signals.remove(output)
                    if output in outputs:
                        outputs.remove(output)
                    Signal[output]=0
                    continue
                else:
                    Signal[output]=gate_delays[gate_type]
                for i in input:
                    if i in Succesor:
                        Succesor[i].append(output)
                    else:
                        Succesor[i]=[output]
                    if output in Predecesor:
                        Predecesor[output].append(i)
                    else:
                        Predecesor[output]=[i]
                        
        return inputs,outputs,Signal,internal_signals,Predecesor,Succesor

def read_gate_delaysA(file_path):
    gate_delays = {}

    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            if not line or line.startswith('//'):
                continue
            parts = line.split()
            gate_type = parts[1]
            delay = float(parts[2])
            if(gate_type in gate_delays):
                gate_delays[gate_type]=min(delay,gate_delays[gate_type])
            else:
                gate_delays[gate_type]=delay

    return gate_delays

def read_circuit_fileB(file_path):
    inputs = []
    outputs = []
    internal_signals = []
    Signal={}
    Succesor={}
    Predecesor={}
    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            if not line or line.startswith('//'):
                continue
            parts = line.split()
            if parts[0] == 'PRIMARY_INPUTS':
                # Split the remaining parts and extend the inputs list
                inputs+=parts[1:]
                for i in parts[1:]:
                    Signal[i]="INP"
            elif parts[0] == 'PRIMARY_OUTPUTS':
                #outputs = parts[1:]
                outputs+=parts[1:]
            elif parts[0] == 'INTERNAL_SIGNALS':
                #internal_signals = parts[1:]
                #for i in parts[1:]:
               internal_signals+=parts[1:]
            else:
                gate_type = parts[0]
                input = parts[1:-1]
                output = parts[-1]
                if gate_type == 'DFF':
                    inputs.append(output)
                    Signal[output] = "INP"
                    if output in internal_signals:
                        internal_signals.remove(output)
                    if output in outputs:
                        outputs.remove(output)
                    for i in input:
                        if i in internal_signals:
                            internal_signals.remove(i)
                        if i in inputs:
                            inputs.remove(i)
                    outputs.append(input)
                    continue
                else:
                    Signal[output]=gate_type
                for i in input:
                    if i in Succesor:
                        Succesor[i].append(output)
                    else:
                        Succesor[i]=[output]
                    if output in Predecesor:
                        Predecesor[output].append(i)
                    else:
                        Predecesor[output]=[i]
        
        return inputs,outputs,Signal,internal_signals,Predecesor,Succesor

def read_gate_delaysB(file_path,gate_delay_constraint):
    gate_delays={}
    with open(file_path,'r') as file:
        for line in file:
            line = line.strip()
            if not line or line.startswith('//'):
                continue
            parts=line.split()
            gate_type=parts[1]
            delay=float(parts[2])
            area=float(parts[3])
            if(delay>gate_delay_constraint):
                continue
            if(gate_type in gate_delays):
                gate_delays[gate_type].append([float(delay),float(area)])
            else:
                gate_delays[gate_type]=[[float(delay),float(area)]]
                
    for gate_type, implementations in gate_delays.items():
        # Sort the implementations list based on the delay (implementations[0])
        sorted_implementations = sorted(implementations, key=lambda x: x[0])
        # Update the implementations list with the sorted list
        gate_delays[gate_type] = sorted_implementations
    gate_delays["INP"]=[[0,0]]
    return gate_delays

def bfs(i,inputs,outputs,Signal,internal_signals,Predecesor,Succesor,sorted_signals):
    if i in outputs:
        return
    for j in Succesor[i]:
        if j in sorted_signals:
            sorted_signals.remove(j)
            sorted_signals.append(j)
        else:
            sorted_signals.append(j)
        bfs(j,inputs,outputs,Signal,internal_signals,Predecesor,Succesor,sorted_signals)

def topological_sort(inputs,outputs,Signal,internal_signals,Predecesor,Succesor):
    sorted_signals=[]
    for i in inputs:
        sorted_signals.append(i)
    for i in inputs:
        bfs(i,inputs,outputs,Signal,internal_signals,Predecesor,Succesor,sorted_signals)
    
    return sorted_signals
    
def maximum_delay(inputs,outputs,Signal,internal_signals,Predecesor,Succesor,sorted_signals):
    ans=Signal
    for i in sorted_signals:
        if i in inputs:
            ans[i]=0
        else:
            for j in Predecesor[i]:
                ans[i]=max(ans[i],ans[j]+Signal[i])
    delay=0
    for i in sorted_signals:
        delay=max(delay,ans[i])
    return delay       
        
def cal_delay(inputs, outputs, internal_signals, Succesor, gate_delays_constraint, sorted_signals,case_delay):
    delay={}
    for i in inputs:
        delay[i]=0
    for i in internal_signals:
        delay[i]=0
    for i in outputs:
        delay[i]=0
    for i in sorted_signals:
        if i in outputs:
            continue
        for j in Succesor[i]:
            delay[j]=max(delay[j],delay[i]+case_delay[j][0][0])
    a=0
    for i in delay:
        a=max(a,delay[i])
    area=0
    for i in internal_signals+outputs:
        area=area+case_delay[i][0][1]
    return a,area

def recursive(inputs, outputs, Signal, internal_signals, Succesor, gate_delays, gate_delays_constraint, sorted_signals,case):
    store=[]
    index=case[1]
    #print(index)
    inserted=False
    temp=[]
    #print("part by part increase begins")
    for i in internal_signals + outputs:
        temp_index = copy.deepcopy(index)
        if index[i][1]==len(gate_delays[Signal[i]])-1:
            continue
#        temp_index = copy.deepcopy(index)
        temp_index[i][1]=temp_index[i][1]+1
        temp_index[i][0]=gate_delays[Signal[i]][temp_index[i][1]]
        a,area=cal_delay(inputs,outputs,internal_signals,Succesor,gate_delays_constraint,sorted_signals,temp_index)
        #print(a,temp_index,area)
        if(a<=gate_delays_constraint):
            #print('putting in notfinal')
            #print(a,temp_index,area)
            temp.append([a,temp_index,area])
            inserted=True
            #print(Inbuilt_delay,a,area)
    if not inserted:
        return cal_delay(inputs,outputs,internal_signals,Succesor,gate_delays_constraint,sorted_signals,index)[1]

    else:
        min_area=float('inf')
        for i in temp:
            if(min_area>i[2]):
                case=i
        
    return recursive(inputs, outputs, Signal, internal_signals, Succesor, gate_delays, gate_delays_constraint, sorted_signals,case)
                            
def min_area(inputs, outputs, Signal, internal_signals, Succesor, gate_delays, gate_delays_constraint, sorted_signals):
    index={}
    processed={}
    for i in internal_signals:
        index[i]=0
    for i in outputs:
        index[i]=0
    Inbuilt_delay={}
    for i in internal_signals:
        Inbuilt_delay[i]=[gate_delays[Signal[i]][index[i]],0]
        
    for i in outputs:
        Inbuilt_delay[i]=[gate_delays[Signal[i]][index[i]],0]

    a,area=cal_delay(inputs,outputs,internal_signals,Succesor,gate_delays_constraint,sorted_signals,Inbuilt_delay)
    
    if(a>gate_delays_constraint):
        print('no solution exists')
        return
        
    case=[a,Inbuilt_delay,area]
    ans=recursive(inputs, outputs, Signal, internal_signals, Succesor, gate_delays, gate_delays_constraint, sorted_signals,case)
    return ans
   
def mainA():
    circuit_file_path = sys.argv[2]
    gate_delays_file_path = sys.argv[3]
    output_file=sys.argv[4]
    gate_delays = read_gate_delaysA(gate_delays_file_path)
    inputs,outputs,Signal,internal_signals,Predecesor,Succesor=read_circuit_fileA(circuit_file_path, gate_delays)
    #print(inputs)
    #print(outputs)
    #print(internal_signals)
    #print(Predecesor)
    #print(Succesor)
    sorted_signals=topological_sort(inputs,outputs,Signal,internal_signals,Predecesor,Succesor)
    ans=maximum_delay(inputs,outputs,Signal,internal_signals,Predecesor,Succesor,sorted_signals)
    output_file=open(output_file,'w')
    output_file.write(ans.__str__())
    output_file.write('\n')

def mainB():
    circuit_file_path = sys.argv[2]
    gate_delays_file_path = sys.argv[3] 
    gate_delays_constraint=sys.argv[4]
    with open(gate_delays_constraint,'r') as file:
        for line in file:
            gate_delays_constraint=float(line)
    #print(gate_delays_constraint)
    gate_delays = read_gate_delaysB(gate_delays_file_path,gate_delays_constraint)
    inputs,outputs,Signal,internal_signals,Predecesor,Succesor=read_circuit_fileB(circuit_file_path)
    sorted_signals=topological_sort(inputs,outputs,Signal,internal_signals,Predecesor,Succesor)
    #print(sorted_signals)
    ans=min_area(inputs, outputs, Signal, internal_signals, Succesor, gate_delays, gate_delays_constraint, sorted_signals)
    output_file=sys.argv[5]
    output_file=open(output_file,'w')
    output_file.write(ans.__str__())
    output_file.write('\n')
    
    
if __name__ == '__main__':
    type=sys.argv[1]
    if type=='A':
        mainA()
    else:    
        mainB()