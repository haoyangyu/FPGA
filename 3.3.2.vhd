LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY activity7 IS 
  PORT(A: IN STD_LOGIC_VECTOR(3 DOWNTO 0):="0110";
       B: IN STD_LOGIC_VECTOR(3 DOWNTO 0):="0101";
		 SUM: OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
  END activity7;
  
--4-bit Ripple carry adder block diagram 
ARCHITECTURE behavior OF activity7 IS 
  COMPONENT ADDER
     PORT (A,B ,CIN :IN STD_LOGIC;
        S,COUT   :OUT STD_LOGIC);
  END COMPONENT;
  
 SIGNAL C: STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN 
--Do THE PORT MAP OF ADDER TO FORM THE RIPPLE CARRY ADDER
  sum0: ADDER
        PORT MAP(A(0),B(0),'0',SUM(0),C(0));
  sum1: ADDER
        PORT MAP(A(1),B(1),C(0),SUM(1),C(1));
  sum2: ADDER
        PORT MAP(A(2),B(2),C(1),SUM(2),C(2));	 
  sum3: ADDER
        PORT MAP(A(3),B(3),C(2),SUM(3),C(3));

END behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

--DEFINE THE 1-BIT FULL ADDER
ENTITY ADDER IS
  PORT (A,B ,CIN :IN STD_LOGIC;
        S,COUT   :OUT STD_LOGIC);
END ADDER;

ARCHITECTURE behavior OF ADDER IS
   
	
BEGIN
   S<=(A XOR B) XOR CIN;
   COUT<=((A XOR B) AND CIN) OR (A AND B);	
	
END behavior;

