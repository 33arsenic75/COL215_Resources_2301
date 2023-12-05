class Gate:
    def __init__(self, gate_type, inputs, output, delay):
        self.gate_type = gate_type
        self.inputs = inputs
        self.delay = delay
        self.output=output
        self.output_delay = 0
        self.input_delays = [0] * len(inputs)
        
def topological_sort(circuit):
    in_degree = {gate_name: 0 for gate_name in circuit}
    
    for gate_name, gate in circuit.items():
        for input_gate in gate.inputs:
            in_degree[input_gate] += 1

    queue = []
    for gate_name, degree in in_degree.items():
        if degree == 0:
            queue.append(gate_name)

    sorted_gates = []
    while queue:
        gate_name = queue.pop(0)
        sorted_gates.append(gate_name)
        gate = circuit[gate_name]
        for input_gate in gate.inputs:
            in_degree[input_gate] -= 1
            if in_degree[input_gate] == 0:
                queue.append(input_gate)

    if len(sorted_gates) != len(circuit):
        print("The circuit contains cycles and cannot be topologically sorted.")
        return []

    return sorted_gates

# Function to perform topological sorting and calculate output delays
def calculate_output_delays(circuit, gate_delays):
    sorted_gates = topological_sort(circuit)
    
    for gate_name in sorted_gates:
        gate = circuit[gate_name]
        input_delays = [circuit[input_gate].output_delay for input_gate in gate.inputs]
        gate.output_delay = gate_delays[gate.gate_type] + max(input_delays)

# Read gate delays from file
def read_gate_delays(filename):
    gate_delays = {}
    with open(filename, 'r') as file:
        for line in file:
            gate_type, delay = line.strip().split()
            gate_delays[gate_type] = float(delay)
    return gate_delays

# Read circuit description from file
def read_circuit(filename):
    circuit =[]
    with open(filename, 'r') as file:
        for line in file:
            tokens = line.strip().split()
            gate_type = tokens[0]
            inputs = tokens[1:-1]
            output=tokens[-1]
            circuit.append(Gate(gate_type, inputs,output,gate_delays[gate_type]))
    return circuit

# Write output delays to file
def write_output_delays(circuit, filename):
    with open(filename, 'w') as file:
        for gate_name, gate in circuit.items():
            file.write(f"{gate_name} {gate.output_delay}\n")

# Main program
if __name__ == '__main__':
    gate_delays = read_gate_delays('/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/gate_delays.txt')
    circuit = read_circuit('/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/circuit.txt')
    
    calculate_output_delays(circuit, gate_delays)
    
    write_output_delays(circuit, '/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/output_delays.txt')
