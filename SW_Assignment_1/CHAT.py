class Gate:
    def __init__(self, gate_type, inputs, output, delay):
        self.gate_type = gate_type
        self.inputs = inputs
        self.delay = delay
        self.output=output
        self.output_delay = 0
        self.input_delays = [0] * len(inputs)

def read_gate_delays(filename):
    gate_delays = {}
    with open(filename, 'r') as file:
        for line in file:
            gate_type, delay = line.strip().split()
            gate_delays[gate_type] = float(delay)  # Use float for gate delays
    return gate_delays

def read_circuit(filename):
    circuit = []
    primary_inputs = []
    primary_outputs = []
    internal_signals = []

    with open(filename, 'r') as file:
        for line in file:
            tokens = line.strip().split()
            gate_type = tokens[0]

            if gate_type == 'PRIMARY_INPUTS':
                primary_inputs = tokens[1:]
            elif gate_type == 'PRIMARY_OUTPUTS':
                primary_outputs = tokens[1:]
            elif gate_type == 'INTERNAL_SIGNALS':
                internal_signals = tokens[1:]
            else:
                gate_name = tokens[0]
                inputs = tokens[1:-1]
                outputs=tokens[-1]
                circuit.append(Gate(gate_type, inputs,outputs, gate_delays[gate_type]))
    return circuit, primary_inputs, primary_outputs, internal_signals


def read_required_delays(filename):
    required_delays = {}
    with open(filename, 'r') as file:
        for line in file:
            gate, delay = line.strip().split()
            required_delays[gate] = float(delay)
    return required_delays

def topological_sort(circuit):
    in_degree = {gate_name: 0 for gate_name in circuit}
    for i in range(len(circuit)):
        for input_gate in circuit[i].inputs:
            in_degree[circuit[i]] += 1
    queue = []
    for gate_name, degree in in_degree.items():
        if degree == 1:
            queue.append(gate_name)
    if(len(queue)==0):
        queue=circuit
    sorted_gates = []
    while queue:
        gate = queue.pop(0)
        sorted_gates.append(gate)
        out=gate.ouputs;
        for out in gate.outputs:
            in_degree[input_gate] -= 1
            if in_degree[input_gate] == 0:
                queue.append(input_gate)
    
    print(sorted_gates)
    return sorted_gates

if __name__ == '__main__':
    gate_delays = read_gate_delays('/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/gate_delays.txt')
    
    circuit, primary_inputs, primary_outputs, internal_signals = read_circuit('/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/circuit.txt')
    
    required_output_delays = read_required_delays('/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/required_delays.txt')
    
    all_gate_names = primary_inputs + primary_outputs + internal_signals
    
    sorted_gates = topological_sort(circuit)  # Topological sorting using DAG concept
    
    # Ensure all gates are included in the in_degree dictionary
    in_degree = {gate_name: 0 for gate_name in all_gate_names}
    
    for gate_name in sorted_gates:
        gate = circuit[gate_name]
        input_delays = [circuit[input_gate].output_delay for input_gate in gate.inputs]
        gate.output_delay = gate.delay + max(input_delays)

    for gate_name, gate in circuit.items():
        for i, input_gate in enumerate(gate.inputs):
            gate.input_delays[i] = required_output_delays[gate_name] - (gate.delay + circuit[input_gate].output_delay)

    with open('/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/input_delays.txt', 'w') as file:
        for gate_name, gate in circuit.items():
            input_delays_str = ','.join(str(delay) for delay in gate.input_delays)
            file.write(f"{gate_name} {input_delays_str}\n")