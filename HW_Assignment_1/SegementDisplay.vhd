----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/04/2023 10:46:18 PM
-- Design Name: 
-- Module Name: SegementDiplay - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SegementDisplay is
    port(a,b,c,d : in std_logic;A0,B0,C0,D0,E0,F0,G0,x,y,z,w: out std_logic);
end SegementDisplay;

architecture Behavioral of SegementDisplay is
begin    
--    A0<=;
--    B0<=
--    C0<=not((not a and b) or(a and not b) or(not c and d) or(not a and not c) or(not a and d));
--    D0<=not((b and not c and d)  or (not a and not b and not d) or (not b and c and d) or (b and c and not d) or(a and not c));
--    E0<=not((not b and not d) or (c and not d) or(a and c ) or (a and b));
--    F0<=not((not c and not d) or (not a and b and not c) or (b and not d) or (a and not b) or (a and c));
--    G0<=not((not b and c) or (a and not b) or (not a and b and not c) or (c and not d) or ( a and d));
A0 <= (not a and not b and not c and d) or (not a and b and not c and not d) or (a and b and not c and d) or (a and not b and c and d);
B0 <= (not a and b and not c and d) or (a and b and not c and not d) or (b and c and not d) or (a and c and d);
C0 <= (not a and not b and c and not d) or (a and  b and not c and not d) or (a and b and c);
D0 <= (not a and not b and not c and d) or (not a and b and not c and not d) or (b and c and d) or (a and not b and c and not d) ;
E0 <= (not a and d) or (not a and b and not c) or (not b and not c and d);
F0 <= (not a and not b and c) or (not a and not b and d) or (not a and c and d) or (a and b and not c and d);
G0 <= (not a and not b and not c) or (not a and b and c and d) or (a and b and not c and not d);
x<='1';
y<='1';
z<='1';
w<='0';
end Behavioral;
