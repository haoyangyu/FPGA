LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY activity8_newversion IS 
  PORT(  SW:IN STD_LOGIC_VECTOR(12 DOWNTO 0); --switches
         HEX3,HEX7,HEX5: OUT STD_LOGIC_VECTOR(0 TO 6);--HEX DISPLAY, LEDR, LEDG
			LEDG: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			LEDR: OUT STD_LOGIC_VECTOR(1 DOWNTO 1)
			   ); 
END activity8_newversion;

ARCHITECTURE structure OF activity8_newversion IS
--INTRODUCE THE COMPONENT ADDER 
  COMPONENT ADDER
    PORT (A,B ,CIN :IN STD_LOGIC;
          S,COUT   :OUT STD_LOGIC);
  END COMPONENT;
--INTRODUCE THE MUX4TO1
  COMPONENT MUX4TO1 
    PORT  (sele : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	        i0,i1,i2,i3: IN STD_LOGIC;
			  F : OUT STD_LOGIC);
  END COMPONENT;
--INTRODUCE THE DECODER OF HEX
  COMPONENT bcd7seg
		PORT (	S	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);  -- S is an intermediate signal (NOT A PHYSICAL INPUT)
			H	: OUT STD_LOGIC_VECTOR(0 TO 6));           -- Storage signal for result
	END COMPONENT;
	
SIGNAL AA,BB: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL C: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL SUM: STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
--DO PORT MAP TO MUX4TO1
  choose0: MUX4TO1 PORT MAP(sele(1)=>SW(11),sele(0)=>SW(10),i0=>SW(4),i1=>NOT(SW(4)),i2=>'0',i3=>'X',F=>BB(0));
  
  choose1: MUX4TO1 PORT MAP(sele(1)=>SW(9),sele(0)=>SW(8),i0=>SW(0),i1=>NOT(SW(0)),i2=>'0',i3=>'X',F=>AA(0));
  
  choose2: MUX4TO1 PORT MAP(sele(1)=>SW(11),sele(0)=>SW(10),i0=>SW(5),i1=>NOT(SW(5)),i2=>'0',i3=>'X',F=>BB(1));
  
  choose3: MUX4TO1 PORT MAP(sele(1)=>SW(9),sele(0)=>SW(8),i0=>SW(1),i1=>NOT(SW(1)),i2=>'0',i3=>'X',F=>AA(1));
  
  choose4: MUX4TO1 PORT MAP(sele(1)=>SW(11),sele(0)=>SW(10),i0=>SW(6),i1=>NOT(SW(6)),i2=>'0',i3=>'X',F=>BB(2)); 
  
  choose5: MUX4TO1 PORT MAP(sele(1)=>SW(9),sele(0)=>SW(8),i0=>SW(2),i1=>NOT(SW(2)),i2=>'0',i3=>'X',F=>AA(2));
  
  choose6: MUX4TO1 PORT MAP(sele(1)=>SW(11),sele(0)=>SW(10),i0=>SW(7),i1=>NOT(SW(7)),i2=>'0',i3=>'X',F=>BB(3));
  
  choose7: MUX4TO1 PORT MAP(sele(1)=>SW(9),sele(0)=>SW(8),i0=>SW(3),i1=>NOT(SW(3)),i2=>'0',i3=>'X',F=>AA(3));
  
--DO PORT MAP TO ADDED			
  sum0: ADDER PORT MAP(AA(0),BB(0),SW(12),SUM(0),C(0));
  sum1: ADDER PORT MAP(AA(1),BB(1),C(0),SUM(1),C(1));
  sum2: ADDER PORT MAP(AA(2),BB(2),C(1),SUM(2),C(2));	 
  sum3: ADDER PORT MAP(AA(3),BB(3),C(2),SUM(3),C(3));
  
--DO PORT MAP TO DECODER OF HEX 
  h7: bcd7seg PORT MAP(AA,HEX7);
  h5: bcd7seg PORT MAP(BB,HEX5);
  h3: bcd7seg PORT MAP(SUM,HEX3);
  
--To achieve the sequential statements by process
--If C(2)!=C(3) means the result over-flows display C4 on LEDG0 
PROCESS(C,SUM) 
BEGIN
  IF (C(2)/=C(3)) THEN 
    LEDG(0)<='1'; 
	 ELSIF (C(2)=C(3)) THEN 
	 LEDG(0)<='0';
  END IF;
	
  IF (SUM="0000") THEN
	 LEDR(1)<='1';
	 ELSE LEDR(1)<='0';
  END IF;
END PROCESS;

END structure;
	

--Define the function of the entity of the mux4to1 multiplexer 
LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY MUX4TO1 IS
  PORT  (sele : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	        i0,i1,i2,i3: IN STD_LOGIC;
			  F : OUT STD_LOGIC);
  END MUX4TO1;

ARCHITECTURE structure_mux4to1 OF MUX4TO1 IS
BEGIN
  PROCESS(sele)
    BEGIN
	   CASE sele IS
		  WHEN "00" =>F<= i0;
		  WHEN "01" =>F<= i1;
		  WHEN "10" =>F<= i2; 
		  WHEN "11" =>F<= i3;
		END CASE;
	END PROCESS;
END structure_mux4to1;

--DEFINE A 1-BIT FULL ADDER 
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ADDER IS
  PORT (A,B ,CIN :IN STD_LOGIC;
        S,COUT   :OUT STD_LOGIC);
END ADDER;

ARCHITECTURE behavior OF ADDER IS	
BEGIN
   S<=(A XOR B) XOR CIN;
   COUT<=((A XOR B) AND CIN) OR (A AND B);	
	
END behavior;



-- Define the bcd7seg entity as one decoder with inputs(S) and outputs(H) 
LIBRARY ieee;
USE ieee.std_logic_1164.all;
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

