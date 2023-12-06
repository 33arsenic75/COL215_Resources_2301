LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY kernel_reader IS
    PORT (
        clk : IN STD_LOGIC;

        --To switch on the current component 
        kernel_reader_flag : IN STD_LOGIC;

        --To switch on filter component
        filter_flag : OUT STD_LOGIC;

        --Entries of kernel_rom
        k00 : OUT INTEGER;
        k01 : OUT INTEGER;
        k02 : OUT INTEGER;
        k10 : OUT INTEGER;
        k11 : OUT INTEGER;
        k12 : OUT INTEGER;
        k20 : OUT INTEGER;
        k21 : OUT INTEGER;
        k22 : OUT INTEGER
    );
END kernel_reader;

ARCHITECTURE Behavioral OF kernel_reader IS

    --Component declaration
    COMPONENT dist_mem_gen_0
        PORT (
            a : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

            spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

            clk : IN STD_LOGIC);
    END COMPONENT;

    --Signal Declaration
    --    signal clk : std_logic := '0';
    SIGNAL kernel_rom_address : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL kernel_output : STD_LOGIC_VECTOR(7 DOWNTO 0);

    --Signal to initiate process read_kernel_rom when ANDed with kernel_read_flag
    SIGNAL pseudo : STD_LOGIC := '1';

BEGIN

    --Component Initialisation
    kernel_rom : dist_mem_gen_0 PORT MAP(
        a => kernel_rom_address,

        clk => clk,

        spo => kernel_output);

    --Clock Generation Process
    --    clock_process : process

    --    begin
    --        wait for 5 ns;
    --        clk<=not clk;

    --    end process;

    --Kernel Reading Process
    read_kernel_rom : PROCESS (clk)
        --To keep track of clock cycles
        --Pause of one clock cycles after each assignment of kernel_rom_address
        --Process completed in 19 clock cycles
        VARIABLE counter : INTEGER := 0;
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (kernel_reader_flag = '1') AND pseudo = '1' THEN
                IF (counter = 0) THEN
                    kernel_rom_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 4));
                    counter := counter + 1;

                ELSIF (counter = 1) THEN
                    counter := counter + 1;

                ELSIF (counter = 2) THEN
                    k00 <= to_integer(signed(kernel_output));
                    kernel_rom_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(1, 4));
                    counter := counter + 1;

                ELSIF (counter = 3) THEN
                    counter := counter + 1;

                ELSIF (counter = 4) THEN
                    k01 <= to_integer(signed(kernel_output));
                    kernel_rom_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(2, 4));
                    counter := counter + 1;

                ELSIF (counter = 5) THEN
                    counter := counter + 1;

                ELSIF (counter = 6) THEN
                    k02 <= to_integer(signed(kernel_output));
                    kernel_rom_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(3, 4));
                    counter := counter + 1;

                ELSIF (counter = 7) THEN
                    counter := counter + 1;

                ELSIF (counter = 8) THEN
                    k10 <= to_integer(signed(kernel_output));
                    kernel_rom_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(4, 4));
                    counter := counter + 1;

                ELSIF (counter = 9) THEN
                    counter := counter + 1;

                ELSIF (counter = 10) THEN
                    k11 <= to_integer(signed(kernel_output));
                    kernel_rom_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(5, 4));
                    counter := counter + 1;

                ELSIF (counter = 11) THEN
                    counter := counter + 1;

                ELSIF (counter = 12) THEN
                    k12 <= to_integer(signed(kernel_output));
                    kernel_rom_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(6, 4));
                    counter := counter + 1;

                ELSIF (counter = 13) THEN
                    counter := counter + 1;

                ELSIF (counter = 14) THEN
                    k20 <= to_integer(signed(kernel_output));
                    kernel_rom_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(7, 4));
                    counter := counter + 1;

                ELSIF (counter = 15) THEN
                    counter := counter + 1;

                ELSIF (counter = 16) THEN
                    k21 <= to_integer(signed(kernel_output));
                    kernel_rom_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(8, 4));
                    counter := counter + 1;

                ELSIF (counter = 17) THEN
                    counter := counter + 1;

                ELSIF counter <= 18 THEN
                    k22 <= to_integer(signed(kernel_output));
                    counter := 0;
                    pseudo <= '0';
                    filter_flag <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;