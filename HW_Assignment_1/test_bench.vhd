----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/04/2023 11:05:22 PM
-- Design Name: 
-- Module Name: test_bench - tb
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

entity SegementDisplay_tb is
end SegementDisplay_tb;


architecture tb of SegementDisplay_tb is
component SegementDisplay
port (  a: in std_logic;
        b: in std_logic;
        c: in std_logic;
        d: in std_logic;
        A0:out std_logic;
        B0:out std_logic;  
        C0:out std_logic;      
        D0:out std_logic;
        E0:out std_logic;
        F0:out std_logic;
        G0:out std_logic);
        end component;
        signal a,b,c,d: std_logic;
        signal A0,B0,C0,D0,E0,F0,G0: std_logic;
begin
    UUT: SegementDisplay  port map(a=>a,b=>b,c=>c,d=>d,A0=>A0,B0=>B0,C0=>C0,D0=>D0,E0=>E0,F0=>F0,G0=>G0);
    a<='1';
    b<='0';
    c<='0';
    d<='0';
end tb;
