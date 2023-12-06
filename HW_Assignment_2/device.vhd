library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity device is
    port(clk : in std_logic;
         r: out std_logic_vector(3 downto 0);   --ensure that port is named as follows because the corresponding port in the .xdc file rquires it.
         g : out std_logic_vector(3 downto 0);
         b : out std_logic_vector(3 downto 0);
         hsync :  out std_logic :='0'; --could have been modelled as an internal signal if .xdc file did not require it.
         vsync :  out std_logic :='0');
end device;

architecture behavorial of device is
    --Signal declaration
    
    --generation of 25MHz file.
    signal counter : integer := 0;
    signal clk_divided : std_logic:='1';

    --concerning ROM
    signal rom_address : std_logic_vector(15 downto 0) := (others => '0');
    signal read_from_rom : std_logic_vector(7 downto 0) := (others => '0');

    signal i : integer := 0; --Number of pixel traversed

    signal ram_address : std_logic_vector(15 downto 0) := (others => '0');
    signal write_to_ram : std_logic_vector(7 downto 0) := (others => '0');
    signal read_from_ram : std_logic_vector(7 downto 0) := (others => '0');
    signal write_enable : std_logic := '1';

    signal check : integer := 0;

    signal ram_address_when_calc : std_logic_vector(15 downto 0) := (others => '0');
    signal ram_address_when_disp : std_logic_vector(15 downto 0) := (others => '0');

    signal pixel_1 : std_logic_vector(7 downto 0);
    signal pixel_2 : std_logic_vector(7 downto 0);
    signal pixel_3 : std_logic_vector(7 downto 0);

    signal pixel_1_value : integer := 0;
    signal pixel_2_value : integer := 0;
    signal pixel_3_value : integer := 0;

    signal init_result : integer := 0;
    signal final_result : integer := 0;

    constant HTOT : integer := 799;
    constant HD : integer := 639;
    constant HFP : integer := 16;
    constant HSP : integer := 96;
    constant HBP : integer := 48;

    signal hpos : integer := 0;
    signal vpos : integer := 0;

    constant VTOT : integer := 524;
    constant VD : integer := 479;
    constant VFP : integer := 10;
    constant VSP : integer := 2;
    constant VBP : integer := 33;

    signal videoOn : std_logic := '0';
    --Component declarartion
    --Component Declaration
    component dist_mem_gen_0
        port (
            a : in std_logic_vector(15 downto 0);
            spo : out std_logic_vector(7 downto 0);
            clk : in std_logic
        );
    end component;

    component dist_mem_gen_1
        port (
            a : in std_logic_vector(15 downto 0);
            d : in std_logic_vector(7 downto 0);
            we : in std_logic;
            clk : in std_logic;
            spo : out std_logic_vector(7 downto 0)
        );
    end component;

begin
    --Component instantiation
    my_rom : dist_mem_gen_0
        port map(
            a => rom_address,
            spo => read_from_rom,
            clk => clk
        );

    my_ram : dist_mem_gen_1
        port map(
            a => ram_address,
            d => write_to_ram,
            clk => clk,
            spo => read_from_ram,
            we => write_enable
        );

    gen_25_MHz_clk : process (clk) -- should I do it after write_enable = 0?
    begin
        if rising_edge(clk) then
            if counter = 1 then
                counter <= 0;
                clk_divided <= not clk_divided;
            else
                counter <= counter + 1;
                clk_divided <= clk_divided;
            end if;
        end if;
    end process;

    adjust_ram_address : process (clk)
    begin
        if rising_edge(clk) then
            if write_enable = '1' then
                ram_address <= ram_address_when_calc;
            else
                ram_address <= ram_address_when_disp;
            end if;
        end if;
    end process;

    write_data_to_ram : process (clk)
    begin
        if rising_edge(clk) then
            if i > 0 and write_enable = '1' then
                write_to_ram <= std_logic_vector(to_unsigned(final_result, 8));
            end if;
        end if;
    end process;

    compute_gradient : process (clk)
    begin
        if rising_edge(clk) then
            --initial gradient
            if i > 0 then
                --right edge case
                if (i  mod 256 = 0) then
                    init_result <= pixel_1_value - 2 * pixel_2_value;
                --left edge case
                elsif (i mod 256 = 1) then
                    init_result <= pixel_3_value - 2 * pixel_2_value;
                --normal case
                else
                    init_result <= pixel_1_value - 2 * pixel_2_value + pixel_3_value;
                end if;
            end if;
            --clamped gradient
            if init_result < 0 then
                final_result <= 0;
            elsif init_result > 255 then
                final_result <= 255;
            else
                final_result <= init_result;
            end if;
        end if;
    end process;

    --While reading from rom, calculating gradient and writing to ram
    memory_management : process (clk)
    begin
        if i <= 65536 then 
            if rising_edge(clk) then
                --Initial case
                if i = 0 then
                    rom_address <= std_logic_vector(to_unsigned(0, 16));
                    pixel_2 <= read_from_rom;
                    i <= i + 1;
                else
                    --logic behind using check:
                    --1 
                    
                    rom_address <= std_logic_vector(to_unsigned(i, 16));
                    pixel_3 <= read_from_rom;

                    if(check = 0 or check = 1 or check = 2 or check = 3) then
                        check <= check + 1;

                    elsif(check = 4) then

                        ram_address_when_calc <= std_logic_vector(to_unsigned(i - 1, 16));
                                
                                pixel_1 <= pixel_2;
                                pixel_2 <= pixel_3;
                                i <= i + 1;
                            
                            if i mod 256 = 1 then
                                --operation requires only pixel_2_value, pixel_3_value
                                pixel_2_value <= to_integer(unsigned(pixel_2));
                                pixel_3_value <= to_integer(unsigned(pixel_3));
                            
                            elsif i mod 256 = 0 then
                                --operation requires only pixel_1_value, pixel_2_value
                                pixel_1_value <= to_integer(unsigned(pixel_1));
                                pixel_2_value <= to_integer(unsigned(pixel_2));
                                
                            else
                                --operation requires all 3 pixel values.
                                pixel_2_value <= to_integer(unsigned(pixel_2));
                                pixel_3_value <= to_integer(unsigned(pixel_3));
                                pixel_1_value <= to_integer(unsigned(pixel_1));
                               
                            end if;

                    elsif(check = 5 or check = 6 or check = 7) then
                        check <= check + 1;
                    end if;
                end if;
            end if;
        else
            write_enable <= '0' ;
            --should  I increment ram_address here?
        end if;
    end process;
    
    ram_adjustment_for_display : process(clk_divided,write_enable)
    begin
        if(i>65536) then 
            if write_enable = '0' then 
                if(rising_edge(clk_divided)) then 
                    ram_address_when_disp <= std_logic_vector(to_unsigned((256*(vpos -10)+ hpos - 44),16));
                end if;
            end if;
        end if;
    end process;
    
    Horizontal_pixel_counter : process (clk_divided, write_enable)
    begin
        if (write_enable = '1') then
            hpos <= 0;
        elsif rising_edge(clk_divided) then
            if (hpos = HTOT) then
                hpos <= 0;
            else
                hpos <= hpos + 1;
            end if;
        end if;
    end process;

    Vertical_line_counter : process (clk_divided, write_enable, hpos)
    begin
        if (write_enable = '1') then
            vpos <= 0;
        elsif rising_edge(clk_divided) then
            if (hpos = HTOT) then
                if (vpos = VTOT) then
                    vpos <= 0;
                else
                    vpos <= vpos + 1;
                end if;
            end if;
        end if;
    end process;

    Synchronise_horizontally : process (clk_divided, write_enable, hpos)
    begin
        if (write_enable = '1') then
            hsync <= '0';
        elsif rising_edge(clk_divided) then
            if (hpos <= (HD + HFP) OR (hpos > HD + HFP + HSP)) then
                hsync <= '1';
            else
                hsync <= '0';
            end if;
        end if;
    end process;

    Synchronise_vertically : process (clk_divided, write_enable, vpos)
    begin
        if (write_enable = '1') then
            vsync <= '0';
        elsif rising_edge(clk_divided) then
            if (vpos <= (VD + VFP) OR (vpos > VD + VFP + VSP)) then
                vsync <= '1';
            else
                vsync <= '0';
            end if;
        end if;
    end process;

    enable_video : process (clk_divided, write_enable, hpos, vpos)
    begin
        if (write_enable = '1') then
            videoOn <= '0';
        elsif rising_edge(clk_divided) then
            if (hpos <= HD AND vpos <= VD) then
                videoOn <= '1';
            else
                videoOn <= '0';
            end if;
        end if;
    end process;

    paint_image : process (clk_divided, hpos, vpos, videoOn, write_enable)
    begin
        if (rising_edge(clk_divided)) then
            if (videoOn = '1') then
                if ((hpos >= 44 AND hpos < 300) AND (vpos >= 44 AND vpos < 300)) then
                    --To display the image in the specified area
                    r(3) <= read_from_ram(7);
                    r(2) <= read_from_ram(6);
                    r(1) <= read_from_ram(5);
                    r(0) <= read_from_ram(4);

                    g(3) <= read_from_ram(7);
                    g(2) <= read_from_ram(6);
                    g(1) <= read_from_ram(5);
                    g(0) <= read_from_ram(4);

                    b(3) <= read_from_ram(7);
                    b(2) <= read_from_ram(6);
                    b(1) <= read_from_ram(5);
                    b(0) <= read_from_ram(4);
                    --x <= x + 1;           
                else
                    --Rest of the screen should be black
                    r<= (others => '0');
                    g<= (others => '0');
                    b<= (others => '0');
                end if;
            end if;
        end if;
    end process;
    
    end architecture;