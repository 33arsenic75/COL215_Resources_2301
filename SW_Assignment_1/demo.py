def read_gate_delays(file_path):
    gate_delays = {}
    with open(file_path, 'r') as file:
        for line in file:
            gate, delay = line.strip().split('')
            gate_delays[gate] = int(delay)
    return gate_delays


def read_circuit(file_path):
    circuit = {}
    with open(file_path, 'r') as file:
        for line in file:
            output_gate, *input_gates = line.strip().split('')
            circuit[output_gate] = input_gates
    return circuit

def read_required_delays(file_path):
    required_delays = {}
    with open(file_path, 'r') as file:
        for line in file:
            gate, delay = line.strip().split('')
            required_delays[gate] = int(delay)
    return required_delays

def calculate_input_delays(circuit, gate_delays, required_delays):
    input_delays = {}
    
    for gate, inputs in circuit.items():
        delay = gate_delays[gate]
        required_delay = required_delays[gate]
        input_delays[gate] = required_delay - delay
        for input_gate in inputs:
            input_delays[input_gate] = max(input_delays.get(input_gate, 0), input_delays[gate] + gate_delays[gate])
    
    return input_delays

def write_input_delays(input_delays, output_path):
    with open(output_path, 'w') as file:
        for gate, delay in input_delays.items():
            file.write(f"{gate},{delay}\n")

def main():
    circuit_file = '/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/circuit.txt'
    gate_delays_file = '/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/gate_delays.txt'
    required_delays_file = '/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/required_delays.txt'
    input_delays_output_file = '/Users/abhinavshripad/Desktop/Courses/COL 215/SW_Assignment_1/input_delays.txt'
    
    circuit = read_circuit(circuit_file)
    gate_delays = read_gate_delays(gate_delays_file)
    required_delays = read_required_delays(required_delays_file)
    input_delays = calculate_input_delays(circuit, gate_delays, required_delays)
    write_input_delays(input_delays, input_delays_output_file)

main()
ga