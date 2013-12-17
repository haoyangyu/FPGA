-- Import logic primitives
LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Define activity5 as the upper level, which extends two entities, one is J-K flip flop, the other is 7-segment decoder
ENTITY activity5 IS 
  PORT (KEY:IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        HEX0,HEX1: OUT STD_LOGIC_VECTOR(0 TO 6);                               
		  LEDR: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); 
END activity5;

ARCHITECTURE Structure of activity5 IS 
  COMPONENT JKFF
		PORT (	Clk, J, K :IN STD_LOGIC;
               Q         :OUT STD_LOGIC);           -- JKFF to be used
	END COMPONENT;		
	
	COMPONENT bcd7seg
		PORT (	S	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);  -- S is an intermediate signal (NOT A PHYSICAL INPUT)
			H	: OUT STD_LOGIC_VECTOR(0 TO 6));           -- Storage signal for result
	END COMPONENT;

	
SIGNAL q: STD_LOGIC_VECTOR (7 DOWNTO 0); 
SIGNAL highorder: STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL loworder: STD_LOGIC_VECTOR (3 DOWNTO 0);
-- Use q as the intermediate to trigger the upper level counter.
BEGIN
  a0: JKFF
		PORT MAP(KEY(0),J=>'1',K=>'1',Q=>q(0));
  a1: JKFF
		PORT MAP(KEY(0),J=>q(0),K=>q(0),Q=>q(1));
  a2: JKFF
	   PORT MAP(KEY(0),J=>(q(0) and q(1)),K=>(q(0) and q(1)),Q=>q(2));
  a3: JKFF
		PORT MAP(KEY(0),J=>(q(0) and q(1) and q(2)),K=>(q(0) and q(1) and q(2)),Q=>q(3));
  a4: JKFF
		PORT MAP(KEY(0),J=>(q(0) and q(1) and q(2) and q(3)),K=>(q(0) and q(1) and q(2) and q(3)),Q=>q(4));
  a5: JKFF
		PORT MAP(KEY(0),J=>(q(0) and q(1) and q(2) and q(3) and q(4)),K=>(q(0) and q(1) and q(2) and q(3) and q(4)),Q=>q(5));
  a6: JKFF
		PORT MAP(KEY(0),J=>(q(0) and q(1) and q(2) and q(3) and q(4) and q(5)),K=>(q(0) and q(1) and q(2) and q(3) and q(4) and q(5)),Q=>q(6));
  a7: JKFF
		PORT MAP(KEY(0),J=>(q(0) and q(1) and q(2) and q(3) and q(4) and q(5) and q(6)),K=>(q(0) and q(1) and q(2) and q(3) and q(4) and q(5) and q(6)),Q=>q(7));

-- Use LedR to show the outputs		
  LEDR<=q;
  
  highorder <= q(7 downto 4);
  loworder <= q(3 downto 0); 
-- Devide the hex into two parts and show them indiviually  
  H1: bcd7seg
		PORT MAP(highorder,HEX1);
  H0: bcd7seg
		PORT MAP(loworder,HEX0);
END Structure;	

-- Import logic primitives
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY JKFF IS
  PORT (Clk, J, K :IN  STD_LOGIC;
        Q   :OUT STD_LOGIC);
END JKFF;

ARCHITECTURE behavior OF JKFF IS
   
	SIGNAL J1, K1, Qa, Qb: STD_LOGIC;
	--ATTRIBUTE keep: boolean;
	--ATTRIBUTE keep of J1, K1, Qa, Qb: signal is true;
	
BEGIN
   J1<=NOT(Qb AND J AND Clk);
	K1<=NOT(Clk AND K AND Qa);
	Qa<=NOT(J1 AND Qb);
	Qb<=NOT(Qa AND K1);
	
	Q<=Qa;
	
	
END behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Define the bcd7seg entity as one decoder with inputs(S) and outputs(H) 
ENTITY bcd7seg IS
	PORT (	S	: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
		H	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END bcd7seg;

-- Define the function of bcd7seg as one decoder
-- Create a switch case based on the intermediate signal S
ARCHITECTURE sstructure OF bcd7seg IS
BEGIN
	PROCESS (S)
	BEGIN
		CASE S IS 		               
	     WHEN "0000"=>H<="0000001";  --Based on input S(0000) decode to display 0;
		  WHEN "0001"=>H<="1001111";  --Based on input S(0001) decode to display 1;
	     WHEN "0010"=>H<="0010010";  --Based on input S(0010) decode to display 2;
	     WHEN "0011"=>H<="0000110";  --Based on input S(0011) decode to display 3;
		  WHEN "0100"=>H<="1001100";  --Based on input S(0100) decode to display 4;
		  WHEN "0101"=>H<="0100100";  --Based on input S(0101) decode to display 5;
	     WHEN "0110"=>H<="0100000";  --Based on input S(0110) decode to display 6;
		  WHEN "0111"=>H<="0001111";  --Based on input S(0111) decode to display 7;
		  WHEN "1000"=>H<="0000000";  --Based on input S(1000) decode to display 8;
		  WHEN "1001"=>H<="0001100";  --Based on input S(1001) decode to display 9;
		  WHEN "1010"=>H<="0001000";  --Based on input S(1010) decode to display A;
		  WHEN "1011"=>H<="1100000";  --Based on input S(1011) decode to display b;
		  WHEN "1100"=>H<="1110010";  --Based on input S(1100) decode to display c;
		  WHEN "1101"=>H<="1000010";  --Based on input S(1101) decode to display d;
		  WHEN "1110"=>H<="0110000";  --Based on input S(1110) decode to display E;
		  WHEN "1111"=>H<="0111000";  --Based on input S(1111) decode to display F;
		END CASE;
	 END PROCESS;
END sstructure;