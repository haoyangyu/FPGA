--Import logic primitives
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--Define an entity which illustrates inputs and outputs
--Simple module that connects the SW(1),SW(2) swithches to the LEDR(1) light
ENTITY activity1 IS
PORT(SW:IN STD_LOGIC_VECTOR (2 DOWNTO 1);
     LEDR: OUT STD_LOGIC_VECTOR(1 DOWNTO 1));
END activity1;

--Define characteristics of the entity activity1
--According to the logic gates to realize the architecture of activity1
--The truth table is:
--X(SW1)   Y(SW2)   F(LEDR(1))
--  0  	 	  0  			1
--  0 		  1		   0
--  1         0         1
--  1			  1         1
ARCHITECTURE behavior OF activity1 IS
BEGIN
     LEDR(1)<=SW(1)OR(NOT(SW(2)));
END behavior;

