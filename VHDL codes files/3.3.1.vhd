LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY activity6 IS
  PORT (A,B :IN STD_LOGIC;
        S,C   :OUT STD_LOGIC);
END activity6;
--Define behavior of half adder
ARCHITECTURE behavior OF activity6 IS
	
BEGIN
   S<=A XOR B;
	C<=A AND B;
	
END behavior;