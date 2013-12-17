--Import logic primitives
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY activity4 IS
  PORT (Clk, J, K :IN STD_LOGIC;
        Q, Qbar   :OUT STD_LOGIC);
END activity4;

ARCHITECTURE behavior OF activity4 IS
   
	SIGNAL J1, K1, Qa, Qb: STD_LOGIC;
	ATTRIBUTE keep: boolean;
	ATTRIBUTE keep of J1, K1, Qa, Qb: signal is true;
	
BEGIN
   J1<=NOT(Qb AND J AND Clk);
	K1<=NOT(Clk AND K AND Qa);
	Qa<=NOT(J1 AND Qb);
	Qb<=NOT(Qa AND K1);
	
	Q<=Qa;  --Output of Q;
	Qbar<=Qb; --Output of Qbar;
	
END behavior;