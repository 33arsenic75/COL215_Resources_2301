import sys


def main():
    argument = sys.argv[1]
    circuit_file = sys.argv[2]
    gate_delays_file = sys.argv[3]
    required_delays_file = sys.argv[4]

    # reads the input,internal signal and output
    store_def = {}
    with open(circuit_file, "r") as circuit:
        for line in circuit:
            if (
                not (line.startswith("//"))
                and not (line.startswith("\n"))
                and (
                    (line.startswith("PRIMARY_INPUTS"))
                    or (line.startswith("INTERNAL_SIGNALS"))
                    or (line.startswith("PRIMARY_OUTPUTS"))
                )
            ):
                i = line.split(" ")

                for j in range(len(i)):
                    i[j] = i[j].replace("\n", "")

                store_def[i[0]] = []
                for m in range(1, len(i)):
                    if i[m] != "":
                        store_def[i[0]] += [i[m]]

    # store all the signals with there initial timestamps as 0
    input_output = {}
    with open(circuit_file, "r") as circuit:
        for line in circuit:
            if (
                not (line.startswith("//"))
                and not (line.startswith("\n"))
                and (
                    (line.startswith("PRIMARY_INPUTS"))
                    or (line.startswith("INTERNAL_SIGNALS"))
                    or (line.startswith("PRIMARY_OUTPUTS"))
                )
            ):
                inputs = line.split(" ")

                for i in range(1, len(inputs)):
                    inputs[i] = inputs[i].replace("\n", "")
                    input_output[inputs[i]] = 0

    # store the gate delays after reading the file
    gate_delay = {}
    with open(gate_delays_file, "r") as gates:
        for line in gates:
            if not (line.startswith("//")) and not (line.startswith("\n")):
                inputs = line.split(" ")
                for i in range(len(inputs)):
                    inputs[i] = inputs[i].replace("\n", "")
                gate_delay[inputs[0]] = float(inputs[1])

    def sorting_circuit():
        with open(circuit_file, "r") as circuit:
            unsorted_circuit = []
            sorted_circuit = []
            for line in circuit:
                if (
                    not (line.startswith("//"))
                    and not (
                        (line.startswith("PRIMARY_INPUTS"))
                        or (line.startswith("INTERNAL_SIGNALS"))
                        or (line.startswith("PRIMARY_OUTPUTS"))
                    )
                    and not (line.startswith("\n"))
                ):
                    inputs = line.split(" ")
                    for i in range(len(inputs)):
                        inputs[i] = inputs[i].replace("\n", "")
                    if len(set(inputs)) != 1:
                        unsorted_circuit.append(inputs)
            existing_signals = set(store_def["PRIMARY_INPUTS"])
            g = len(unsorted_circuit)
            while True:
                for j in range(g):
                    flag = 0
                    k = len(unsorted_circuit[j]) - 1
                    for q in range(1, k):
                        if unsorted_circuit[j][q] not in existing_signals:
                            flag = 1
                            break

                    if flag == 0:
                        sorted_circuit.append(unsorted_circuit[j])
                        existing_signals.add(unsorted_circuit[j][-1])
                        unsorted_circuit.remove(unsorted_circuit[j])
                        g = g - 1
                        j = 0
                        break
                if g == 0:
                    break
                elif flag == 1 and j == g - 1:
                    sys.exit("Circuit does not exist")
        return sorted_circuit

    def output_delays():
        l = sorting_circuit()
        for i in range(len(l)):
            if l[i][0] == "INV":
                # input_output[l[i][-1]] += gate_delay[l[i][0]] + input_output[l[i][1]]
                input_output[l[i][-1]] = max(
                    gate_delay[l[i][0]] + input_output[l[i][1]], input_output[l[i][-1]]
                )

            else:
                c = 0
                for b in range(1, len(l[i]) - 1):
                    c = max(c, input_output[l[i][b]])
                # input_output[l[i][-1]] += c + gate_delay[l[i][0]]
                input_output[l[i][-1]] = max(
                    c + gate_delay[l[i][0]], input_output[l[i][-1]]
                )

        file_path = "output_delays.txt"
        with open(file_path, "w") as file:
            for k in range(len(store_def["PRIMARY_OUTPUTS"])):
                v1 = float(input_output[store_def["PRIMARY_OUTPUTS"][k]])
                v2 = int(input_output[store_def["PRIMARY_OUTPUTS"][k]])
                if (v1 - v2) == 0.0:
                    a = store_def["PRIMARY_OUTPUTS"][k] + " " + str(v2)
                    file.write(a)
                    file.write("\n")

                else:
                    a = (
                        store_def["PRIMARY_OUTPUTS"][k]
                        + " "
                        + str(float(input_output[store_def["PRIMARY_OUTPUTS"][k]]))
                    )
                    file.write(a)
                    file.write("\n")

    def input_delays():
        with open(required_delays_file, "r") as required_delays:
            # required_delays = open(r"required_delays.txt", "r")
            for line in required_delays:
                if not (line.startswith("//")) and not (line.startswith("\n")):
                    inp = line.split(" ")
                    for i in range(len(inp)):
                        inp[i] = inp[i].replace("\n", "")
                    input_output[inp[0]] = float(inp[1])

        lst = sorting_circuit()
        lst.reverse()
        for i in range(len(lst)):
            if lst[i][0] == "INV":
                if input_output[lst[i][1]] != 0:
                    input_output[lst[i][1]] = min(
                        input_output[lst[i][1]],
                        input_output[lst[i][-1]] - gate_delay[lst[i][0]],
                    )
                else:
                    input_output[lst[i][1]] = (
                        input_output[lst[i][-1]] - gate_delay[lst[i][0]]
                    )
            else:
                for b in range(1, len(lst[i]) - 1):
                    if input_output[lst[i][b]] != 0:
                        input_output[lst[i][b]] = min(
                            input_output[lst[i][b]],
                            (input_output[lst[i][-1]] - gate_delay[lst[i][0]]),
                        )
                    else:
                        input_output[lst[i][b]] = (
                            input_output[lst[i][-1]] - gate_delay[lst[i][0]]
                        )

        file_path = "input_delays.txt"
        with open(file_path, "w") as file:
            for k in range(len(store_def["PRIMARY_INPUTS"])):
                v1 = float(input_output[store_def["PRIMARY_INPUTS"][k]])
                v2 = int(input_output[store_def["PRIMARY_INPUTS"][k]])
                if (v1 - v2) == 0.0:
                    if v1 >= 0 and v2 >= 0:
                        a = (
                            store_def["PRIMARY_INPUTS"][k]
                            + " "
                            + str(int(input_output[store_def["PRIMARY_INPUTS"][k]]))
                        )
                        file.write(a)
                        file.write("\n")
                    else:
                        file.write("No Solution Exists")
                        file.write("\n")
                        sys.exit("No solution exists")
                else:
                    if v1 >= 0 and v2 >= 0:
                        a = (
                            store_def["PRIMARY_INPUTS"][k]
                            + " "
                            + str(float(input_output[store_def["PRIMARY_INPUTS"][k]]))
                        )
                        file.write(a)
                        file.write("\n")
                    else:
                        file.write("No Solution Exists")
                        file.write("\n")
                        sys.exit("No solution exists")

    if argument == "A":
        output_delays()
    elif argument == "B":
        input_delays()


if __name__ == "__main__":
    main()
