--Import logic primitives
LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- A S-R latch
ENTITY activity3 IS
  PORT (Clk, R, S :IN STD_LOGIC;
        Q, Qbar   :OUT STD_LOGIC);
END activity3;

ARCHITECTURE behavior OF activity3 IS
   
	SIGNAL R1, S1, Qa, Qb: STD_LOGIC;   -- Intermediate signals
	ATTRIBUTE keep: boolean;            -- For waveform results
	ATTRIBUTE keep of R1, S1, Qa, Qb: signal is true;
	
BEGIN
   R1<=R AND Clk;
	S1<=S AND Clk;
	Qa<=NOT(R1 OR Qb);
	Qb<=NOT(Qa OR S1);
	
	Q<=Qa;
	Qbar<=Qb;
	
END behavior;