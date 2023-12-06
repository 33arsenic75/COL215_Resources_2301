LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY filter IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
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

        hsync : OUT STD_LOGIC;
        vsync : OUT STD_LOGIC;
        r : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        g : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        b : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END filter;

ARCHITECTURE Behavioral OF filter IS

    --Component declaration
    COMPONENT dist_mem_gen_1
        PORT (
            a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            clk : IN STD_LOGIC);
    END COMPONENT;

    COMPONENT dist_mem_gen_2
        PORT (
            a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            d : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            clk : IN STD_LOGIC;
            we : IN STD_LOGIC;
            spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
    END COMPONENT;

    COMPONENT MAC
        PORT (
            flag : IN STD_LOGIC;
            kernel_input : IN INTEGER; --from kernel
            image_input : IN INTEGER; -- from image
            ans : OUT INTEGER
        );
    END COMPONENT;

    --Signal Declaration

    --rom related signals
    SIGNAL rom_address : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_from_rom : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    
    --signal rst : std_logic := '0';
    --ram related signals
    SIGNAL write_enable : STD_LOGIC := '1';
    SIGNAL write_to_ram : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_from_ram : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ram_address : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');

    --integer array type
    TYPE integer_vector IS ARRAY (8 DOWNTO 0) OF INTEGER;
    SIGNAL pixel_array : integer_vector;

    --Iterators
    SIGNAL i : INTEGER := 0;
    SIGNAL j : INTEGER := - 1;
    SIGNAL count : INTEGER := - 1;

    --Normalisation related signals
    SIGNAL minimum : INTEGER := 2147483647; --Initially set to INT_MAX i.e 2^31 - 1
    SIGNAL maximum : INTEGER := 0;
    SIGNAL val : INTEGER := 0;
    SIGNAL final_value : INTEGER := 0;

    --MAC related signals
    SIGNAL MAC_result : INTEGER;
    SIGNAL MAC_flag : STD_LOGIC := '0';
    SIGNAL kernel_to_mac : INTEGER;
    SIGNAL image_to_mac : INTEGER;

    --2nd pass over rom
    SIGNAL normalisation_flag : STD_LOGIC := '0';

    --    signal clk: std_logic := '0';
    --    signal filter_flag: std_logic := '1';

    -- --Display related signals
    SIGNAL clk_divided : STD_LOGIC := '0';
    SIGNAL hpos : INTEGER := 0;
    SIGNAL vpos : INTEGER := 0;
    SIGNAL video_on : STD_LOGIC := '0';
    CONSTANT HD : INTEGER := 639;
    CONSTANT HFP : INTEGER := 16;
    CONSTANT HSP : INTEGER := 96;
    CONSTANT HBP : INTEGER := 48;
    CONSTANT VD : INTEGER := 479;
    CONSTANT VFP : INTEGER := 10;
    CONSTANT VSP : INTEGER := 2;
    CONSTANT VBP : INTEGER := 33;
    SIGNAL display_pos : INTEGER := 0;
    SIGNAL display_flag : STD_LOGIC := '0';
    SIGNAL pseudo : STD_LOGIC := '1';

BEGIN

    --    clock_process : process

    --    begin

    --        clk<=not clk;

    --        wait for 5 ns;

    --    end process;

    rom : dist_mem_gen_1 PORT MAP(
        a => rom_address,

        clk => clk,

        spo => read_from_rom);

    ram : dist_mem_gen_2 PORT MAP(
        a => ram_address,

        d => write_to_ram,

        clk => clk,

        we => write_enable,

        spo => read_from_ram);

    my_mac : MAC PORT MAP(
        flag => MAC_flag,

        ans => MAC_result,

        kernel_input => kernel_to_mac,

        image_input => image_to_mac
    );

    assign_ram_address : PROCESS(count)
    BEGIN

        IF (count < 4096) THEN
            ram_address <= STD_LOGIC_VECTOR(to_unsigned(64 * i + j, 12));

        ELSE
            ram_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(display_pos, 12));

        END IF;

    END PROCESS;
    
        MMN : PROCESS (clk)
        VARIABLE oper : INTEGER := 0;
        VARIABLE output_pixel : STD_LOGIC_VECTOR (7 DOWNTO 0);
        VARIABLE counter1 : INTEGER := 0;
        VARIABLE counter2 : INTEGER := 0;
        VARIABLE wait_before_display : INTEGER := 0;

    BEGIN
        IF rising_edge (clk) THEN
            IF filter_flag = '1' AND pseudo = '1' THEN
                IF count < 4096 THEN
                    --to iterarate over the pixels
                    IF oper = 0 THEN
                        IF j = 63 THEN
                            i <= i + 1;
                            j <= 0;
                        ELSE
                            j <= j + 1;
                        END IF;
                        count <= count + 1;
                        oper := 1;
                        --to assign rom_address and read values from image_rom
                    ELSIF oper = 1 THEN
                        --first column
                        IF j = 0 THEN
                            -- to assign left values
                            IF counter1 = 0 THEN
                                pixel_array(0) <= 0;
                                pixel_array(3) <= 0;
                                pixel_array(6) <= 0;
                                counter1 := counter1 + 1;
                                --reading mid coilumn values
                                -- to read mid_mid
                            ELSIF counter1 = 1 THEN
                                rom_address <= STD_LOGIC_VECTOR(to_unsigned(64 * i + j, 12));
                                counter1 := counter1 + 1;
                            ELSIF counter1 = 2 THEN
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 3 THEN
                                counter1 := counter1 + 1;

                                -- to read up_mid
                            ELSIF counter1 = 4 THEN
                                pixel_array(4) <= to_integer(unsigned(read_from_rom));
                                IF i = 0 THEN
                                    pixel_array(1) <= 0;
                                ELSE
                                    rom_address <= STD_LOGIC_VECTOR(to_unsigned(64 * (i - 1) + j, 12));
                                END IF;
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 5 THEN
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 6 THEN
                                counter1 := counter1 + 1;

                                -- to read down_mid
                            ELSIF counter1 = 7 THEN
                                IF i /= 0 THEN
                                    pixel_array(1) <= to_integer(unsigned(read_from_rom));
                                END IF;
                                IF i = 63 THEN
                                    pixel_array(7) <= 0;
                                ELSE
                                    rom_address <= STD_LOGIC_VECTOR(to_unsigned(64 * (i + 1) + j, 12));
                                END IF;
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 8 THEN
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 9 THEN
                                counter1 := counter1 + 1;
                                --reading right column values
                                -- to read up_right
                            ELSIF counter1 = 10 THEN
                                IF i /= 63 THEN
                                    pixel_array(7) <= to_integer(unsigned(read_from_rom));
                                END IF;
                                IF i = 0 THEN
                                    pixel_array(2) <= 0;
                                ELSE
                                    rom_address <= STD_LOGIC_VECTOR(to_unsigned(64 * (i - 1) + j + 1, 12));
                                END IF;
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 11 THEN
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 12 THEN
                                counter1 := counter1 + 1;

                                --to read mid_right
                            ELSIF counter1 = 13 THEN
                                IF i /= 0 THEN
                                    pixel_array(2) <= to_integer(unsigned(read_from_rom));
                                END IF;

                                rom_address <= STD_LOGIC_VECTOR(to_unsigned(64 * i + j + 1, 12));

                                counter1 := counter1 + 1;

                            ELSIF counter1 = 14 THEN
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 15 THEN
                                counter1 := counter1 + 1;

                                --to read down _right
                            ELSIF counter1 = 16 THEN
                                pixel_array(5) <= to_integer(unsigned(read_from_rom));

                                IF i = 63 THEN
                                    pixel_array(8) <= 0;
                                ELSE
                                    rom_address <= STD_LOGIC_VECTOR(to_unsigned(64 * (i + 1) + j + 1, 12));

                                END IF;
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 17 THEN
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 18 THEN
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 19 THEN
                                IF i /= 63 THEN
                                    pixel_array(8) <= to_integer(unsigned(read_from_rom));
                                END IF;
                                oper := 2;
                                counter1 := 0;
                            END IF;

                            --reading columns others than first column
                        ELSE
                            --entries of first 2 columns can be obtained by transferring entries from 2nd and rd column of previous matrix
                            IF counter1 = 0 THEN
                                pixel_array(0) <= pixel_array(1);
                                pixel_array(1) <= pixel_array(2);
                                pixel_array(3) <= pixel_array(4);
                                pixel_array(4) <= pixel_array(5);
                                pixel_array(6) <= pixel_array(7);
                                pixel_array(7) <= pixel_array(8);
                                counter1 := counter1 + 1;
                                --to read up_right
                            ELSIF counter1 = 1 THEN
                                IF i = 0 OR j = 63 THEN
                                    pixel_array(2) <= 0;
                                ELSE
                                    rom_address <= STD_LOGIC_VECTOR(to_unsigned(64 * (i - 1) + j + 1, 12));

                                END IF;
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 2 THEN
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 3 THEN
                                counter1 := counter1 + 1;

                                --to read mid_right
                            ELSIF counter1 = 4 THEN
                                IF i /= 0 AND j /= 63 THEN
                                    pixel_array(2) <= to_integer(unsigned(read_from_rom));
                                END IF;

                                IF j = 63 THEN
                                    pixel_array(5) <= 0;
                                ELSE
                                    rom_address <= STD_LOGIC_VECTOR(to_unsigned(64 * i + j + 1, 12));
                                END IF;
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 5 THEN
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 6 THEN
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 7 THEN --down_right
                                IF j /= 63 THEN
                                    pixel_array(5) <= to_integer(unsigned(read_from_rom));
                                END IF;
                                IF i = 63 OR j = 63 THEN
                                    pixel_array(8) <= 0;
                                ELSE
                                    rom_address <= STD_LOGIC_VECTOR(to_unsigned(64 * (i + 1) + j + 1, 12));
                                END IF;
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 8 THEN
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 9 THEN
                                counter1 := counter1 + 1;

                            ELSIF counter1 = 10 THEN
                                IF j /= 63 AND i /= 63 THEN
                                    pixel_array(8) <= to_integer(unsigned(read_from_rom));
                                END IF;
                                counter1 := 0;
                                oper := 2;
                            END IF;
                        END IF;

                    ELSIF oper = 2 THEN --for computing gradient value
                        IF counter2 = 0 THEN
                            val <= 0;
                            kernel_to_mac <= k00;
                            image_to_mac <= pixel_array(0);
                            MAC_flag <= NOT(MAC_flag);
                            val <= val + MAC_result;
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 1 THEN
                            kernel_to_mac <= k01;
                            image_to_mac <= pixel_array(1);
                            MAC_flag <= NOT(MAC_flag);
                            val <= val + MAC_result;
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 2 THEN
                            kernel_to_mac <= k02;
                            image_to_mac <= pixel_array(2);
                            MAC_flag <= NOT(MAC_flag);
                            val <= val + MAC_result;
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 3 THEN
                            kernel_to_mac <= k10;
                            image_to_mac <= pixel_array(3);
                            MAC_flag <= NOT(MAC_flag);
                            val <= val + MAC_result;
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 4 THEN
                            kernel_to_mac <= k11;
                            image_to_mac <= pixel_array(4);
                            MAC_flag <= NOT(MAC_flag);
                            val <= val + MAC_result;
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 5 THEN
                            kernel_to_mac <= k12;
                            image_to_mac <= pixel_array(5);
                            MAC_flag <= NOT(MAC_flag);
                            val <= val + MAC_result;
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 6 THEN
                            kernel_to_mac <= k20;
                            image_to_mac <= pixel_array(6);
                            MAC_flag <= NOT(MAC_flag);
                            val <= val + MAC_result;
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 7 THEN
                            kernel_to_mac <= k21;
                            image_to_mac <= pixel_array(7);
                            MAC_flag <= NOT(MAC_flag);
                            val <= val + MAC_result;
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 8 THEN
                            kernel_to_mac <= k22;
                            image_to_mac <= pixel_array(8);
                            MAC_flag <= NOT(MAC_flag);
                            val <= val + MAC_result;
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 9 THEN
                            IF normalisation_flag = '0' THEN
                                IF val < minimum THEN
                                    minimum <= val;
                                END IF;
                                IF val > maximum THEN
                                    maximum <= val;
                                END IF;
                                counter2 := counter2 + 1;
                            ELSE
                                final_value <= val - minimum;
                                counter2 := counter2 + 1;
                            END IF;

                        ELSIF counter2 = 10 THEN
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 11 THEN
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 12 THEN
                            IF normalisation_flag = '1' THEN
                                final_value <= 255 * (final_value);
                            END IF;
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 13 THEN
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 14 THEN
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 15 THEN
                            IF normalisation_flag = '1' THEN
                                final_value <= (final_value)/(maximum - minimum);
                            END IF;
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 16 THEN
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 17 THEN
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 18 THEN
                            IF normalisation_flag = '1' THEN
                                write_to_ram <= STD_LOGIC_VECTOR(to_unsigned(final_value, 8));
                            END IF;
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 19 THEN
                            counter2 := counter2 + 1;

                        ELSIF counter2 = 20 THEN
                            val <= 0;
                            counter2 := 0;
                            oper := 0;
                        END IF;
                    END IF;
                END IF;
                IF count = 4096 AND normalisation_flag = '0' THEN
                    count <= - 1;
                    normalisation_flag <= '1';
                    i <= 0;
                    j <= - 1;
                ELSIF count = 4096 AND normalisation_flag = '1' THEN
                    IF wait_before_display = 0 THEN
                        wait_before_display := 1;
                    ELSIF wait_before_display = 1 THEN
                        wait_before_display := 2;
                    ELSE
                        write_enable <= '0';
                        display_flag <= '1';
                        pseudo <= '0';
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    gen_25_MHz_clk : PROCESS (clk) -- should I do it after write_enable = 0?
        VARIABLE num : INTEGER := 0;
    BEGIN
        IF rising_edge(clk) THEN
            IF num = 1 THEN
                num := 0;
                clk_divided <= NOT clk_divided;
            ELSE
                num := num + 1;
                clk_divided <= clk_divided;
            END IF;
        END IF;
    END PROCESS;

    horizontal_pixel_counter : PROCESS (clk_divided, rst)
    BEGIN
        IF (display_flag = '1') THEN
            IF (rst = '1') THEN
                hpos <= 0;
            ELSIF (clk_divided'event AND clk_divided = '1') THEN
                IF (hpos = HD + HFP + HSP + HBP) THEN
                    hpos <= 0;
                ELSE
                    hpos <= hpos + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    vertical_line_counter : PROCESS (clk_divided, rst, hpos)
    BEGIN
        IF (display_flag = '1') THEN
            IF (rst = '1') THEN
                vpos <= 0;
            ELSIF (clk_divided'event AND clk_divided = '1') THEN
                IF (hpos = HD + HFP + HSP + HBP) THEN
                    IF (vpos = VD + VFP + VSP + VBP) THEN
                        vpos <= 0;
                    ELSE
                        vpos <= vpos + 1;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    horizontal_synchronisation : PROCESS (clk_divided, rst, hpos)
    BEGIN
        IF (display_flag = '1') THEN
            IF (rst = '1') THEN
                hsync <= '0';
            ELSIF (clk_divided'event AND clk_divided = '1') THEN
                IF (hpos <= (HD + HFP) OR hpos > (HD + HFP + HSP)) THEN
                    hsync <= '1';
                ELSE
                    hsync <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    vertical_synchronisation : PROCESS (clk_divided, rst, vpos)
    BEGIN
        IF (display_flag = '1') THEN
            IF (rst = '1') THEN
                vsync <= '0';
            ELSIF (clk_divided'event AND clk_divided = '1') THEN
                IF (vpos <= (VD + VFP) OR vpos > (VD + VFP + VSP)) THEN
                    vsync <= '1';
                ELSE
                    vsync <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    videoOn : PROCESS (clk_divided, rst, hpos, vpos)
    BEGIN
        IF (display_flag = '1') THEN
            IF (rst = '1') THEN
                video_on <= '0';
            ELSIF (clk_divided'event AND clk_divided = '1') THEN
                IF (hpos <= HD AND vpos <= VD) THEN
                    video_on <= '1';
                ELSE
                    video_on <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    paint_image : PROCESS (clk_divided, rst, hpos, vpos, video_on)
    BEGIN
        IF (display_flag = '1') THEN
            IF (count= 4096) THEN
                IF (rst = '1') THEN
                    R <= "0000";
                    G <= "0000";
                    B <= "0000";

                ELSIF rising_edge(clk_divided) THEN
                    IF (video_on = '1') THEN

                        IF ((hpos >= 10 AND hpos <= 73) AND (vpos >= 10 AND vpos <= 73)) THEN
                            r(3) <= read_from_ram(7);
                            g(3) <= read_from_ram(7);
                            b(3) <= read_from_ram(7);
                            r(2) <= read_from_ram(6);
                            g(2) <= read_from_ram(6);
                            b(2) <= read_from_ram(6);
                            r(1) <= read_from_ram(5);
                            g(1) <= read_from_ram(5);
                            b(1) <= read_from_ram(5);
                            r(0) <= read_from_ram(4);
                            g(0) <= read_from_ram(4);
                            b(0) <= read_from_ram(4);
                            IF (hpos = 73 AND vpos = 73) THEN
                                display_pos <= 0;
                            ELSE
                                display_pos <= display_pos + 1;
                            END IF;
                        ELSE
                            R <= "0000";
                            G <= "0000";
                            B <= "0000";
                        END IF;
                    ELSE
                        R <= "0000";
                        G <= "0000";
                        B <= "0000";
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;