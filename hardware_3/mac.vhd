LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MAC IS
     PORT (
          flag : IN STD_LOGIC;
          kernel_input : IN INTEGER; --from kernel
          image_input : IN INTEGER; -- from image
          ans : OUT INTEGER
     );
END MAC;

ARCHITECTURE Behavioral OF MAC IS
BEGIN
     mac : PROCESS (flag)
     BEGIN
          ans <= kernel_input * image_input;
     END PROCESS;
END Behavioral;