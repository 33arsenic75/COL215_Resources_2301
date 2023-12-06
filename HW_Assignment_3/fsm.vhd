LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY fsm IS
    PORT (
        --clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        r : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        g : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        b : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        hsync : OUT STD_LOGIC;
        vsync : OUT STD_LOGIC;
        inp : IN STD_LOGIC
    );
END fsm;

ARCHITECTURE Behavioral OF fsm IS

    COMPONENT kernel_reader
        PORT (
            clk : IN STD_LOGIC;
            kernel_reader_flag : IN STD_LOGIC;
            filter_flag : OUT STD_LOGIC;
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
    END COMPONENT;

    COMPONENT filter
        PORT (
            clk : IN STD_LOGIC;
            filter_flag : IN STD_LOGIC;

            k00 : IN INTEGER;
            k01 : IN INTEGER;
            k02 : IN INTEGER;
            k10 : IN INTEGER;
            k11 : IN INTEGER;
            k12 : IN INTEGER;
            k20 : IN INTEGER;
            k21 : IN INTEGER;
            k22 : IN INTEGER;

            r : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            g : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            b : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL k0 : INTEGER;
    SIGNAL k1 : INTEGER;
    SIGNAL k2 : INTEGER;
    SIGNAL k3 : INTEGER;
    SIGNAL k4 : INTEGER;
    SIGNAL k5 : INTEGER;
    SIGNAL k6 : INTEGER;
    SIGNAL k7 : INTEGER;
    SIGNAL k8 : INTEGER;
    --SIGNAL count : INTEGER;
    signal clk: std_logic := '0';
    SIGNAL done0 : STD_LOGIC := '1';
    SIGNAL done1 : STD_LOGIC := '0';

    SIGNAL kernel_switch : STD_LOGIC := '0';
    SIGNAL filter_switch : STD_LOGIC := '0';

    CONSTANT initial_state : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    CONSTANT kernel_state : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
    CONSTANT filter_state : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";

    SIGNAL state : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    --    signal hsync : std_logic;
    --    signal vsync :std_logic;
    --    signal red : std_logic_vector(3 downto 0);
    --    signal green : std_logic_vector(3 downto 0);
    --    signal blue : std_logic_vector(3 downto 0);

BEGIN

    my_kernel_reader : kernel_reader PORT MAP(
        clk => clk,
        kernel_reader_flag => kernel_switch,
        filter_flag => done1,
        k00 => k0,
        k01 => k1,
        k02 => k2,
        k10 => k3,
        k11 => k4,
        k12 => k5,
        k20 => k6,
        k21 => k7,
        k22 => k8);
        
    my_filter : filter PORT MAP(
        clk => clk,
        filter_flag => filter_switch,
        k00 => k0,
        k01 => k1,
        k02 => k2,
        k10 => k3,
        k11 => k4,
        k12 => k5,
        k20 => k6,
        k21 => k7,
        k22 => k8,
        r => r,
        g => g,
        b => b,
        hsync => hsync,
        vsync => vsync
    );

        clock_process : process

        begin

            clk<=not clk;

            wait for 10 ns;

        end process;

    FSM : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            CASE state IS
                WHEN initial_state =>
                    IF (done0 = '1') THEN
                        kernel_switch <= '1';
                        state <= kernel_state;
                    ELSE
                        state <= initial_state;
                    END IF;

                WHEN kernel_state =>
                    --NSL:

                    IF (done1 = '1') THEN
                        filter_switch <= '1';
                        state <= filter_state;
                    ELSE
                        state <= kernel_state;
                    END IF;
                    
                WHEN OTHERS =>
                    --do nothing
            END CASE;
        END IF;
    END PROCESS;
END Behavioral;