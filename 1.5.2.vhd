-- Import logic primitives
LIBRARY ieee;
USE ieee.std_logic_1164.all;
 
-- Define ENTITY part2(I define the name as activity2), declarify the inputs(SW) and outputs(HEXS)
ENTITY activity2 IS
PORT ( SW: IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- USE SWITCH 3 to 0 as an input
	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7: OUT STD_LOGIC_VECTOR(0 TO 6)); -- HEX DISPLAY OUTPUTS
END activity2;
 
-- Define characteristics of the activity2, use component bcd7seg to form the top-down hirachy.
-- And map port S=>SW adn H=>HEX by PORT MAP
ARCHITECTURE Structure OF activity2 IS
	COMPONENT bcd7seg
		PORT (	S	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);  -- S is an intermediate signal (NOT A PHYSICAL INPUT)
			H	: OUT STD_LOGIC_VECTOR(0 TO 6));           -- Storage signal for result
	END COMPONENT;
	
BEGIN
   -- drive the displays through 7-seg decoders
	H7: bcd7seg
	      PORT MAP(SW,HEX7);-- map port S=>SW adn H=>HEX7 by PORT MAP
	H6: bcd7seg
	      PORT MAP(SW,HEX6);-- map port S=>SW adn H=>HEX6 by PORT MAP
	H5: bcd7seg
			PORT MAP(SW,HEX5);-- map port S=>SW adn H=>HEX5 by PORT MAP
	H4: bcd7seg
	   	PORT MAP(SW,HEX4);-- map port S=>SW adn H=>HEX4 by PORT MAP
	H3: bcd7seg
	      PORT MAP(SW,HEX3);-- map port S=>SW adn H=>HEX3 by PORT MAP
	H2: bcd7seg
			PORT MAP(SW,HEX2);-- map port S=>SW adn H=>HEX2 by PORT MAP
	H1: bcd7seg 
    		PORT MAP(SW,HEX1);-- map port S=>SW adn H=>HEX1 by PORT MAP
	H0: bcd7seg
			PORT MAP(SW,HEX0);-- map port S=>SW adn H=>HEX0 by PORT MAP
END Structure;
 
 
-- Import logic primitives, once use an entity it may import library!
LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Define the bcd7seg entity as one decoder with inputs(S) and outputs(H) 
ENTITY bcd7seg IS
	PORT (	S	: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
		H	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END bcd7seg;

-- Define the function of bcd7seg as one decoder
-- Create a switch case based on the intermediate signal S
ARCHITECTURE Structure OF bcd7seg IS
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
END Structure;