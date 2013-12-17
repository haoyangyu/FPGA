library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vendingMachine_newVersion is
	port( 
	   --KEY3 increments QUARTERS by A dollar
		--KEY2 increments QUARTERS by A quarter
		--KEY1 acts as a coin return or rest
		--KEY0 acts as a CLOCK
         key : in std_logic_vector(0 to 3);
		--Data signal LEDR light: If the items have been dispensed	
			LEDR : out std_logic_vector(0 to 17);
		--Data signal LEDG: IDLE(LEDG0),PRODUCT_SELECT(LEDG1), DISPENSE(LEDG2)
		--DISPENSE_READY(LEDG8)
			LEDG : out std_logic_vector(0 to 8);
		--Select the products by switches
		--SW0-SW3:bubble_gum
		--SW4-SW7:chocolate
		--SW8-SW11:chips
		--SW12-SW15:soda_can
		--SW16:reset
			SW : in std_LOGIC_VECTOR(0 to 15);
		--HEX5,HEX4 show the money constumers need to pay
		--HEX1,HEX0 show the money constumers have already paid
			HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7: OUT STD_LOGIC_VECTOR(0 TO 6));
end vendingMachine_newVersion;

architecture structure of vendingMachine_newVersion is

component hexDisplay is	--include hexDisplay as a component of counter
PORT ( S : IN STD_LOGIC_VECTOR(0 to 3); -- define input of 7seg
H : OUT STD_LOGIC_VECTOR(0 TO 6)); -- define output of 7seg
END COMPONENT;


type count_state is (idle, product_select, dispense);

type intArray is array (0 to 5) of integer;

	SIGNAL present_state, next_state : count_state;
	signal soda_can, chips, chocolate, bubble_gum: std_LOGIC_VECTOR (0 to 3);
	signal quartersDisplay: std_logic_vector (0 to 7):= "00000000";
	signal costDisplay : std_logic_vector (0 to 7):= "00000000";
	signal reset: std_logic;
	signal clk: std_logic;
	signal dispense_ready: std_logic;
	signal quarters, cost : integer range 0 to 40 := 0;
	signal display1, display0, display4, display5 : STD_LOGIC_VECTOR(0 TO 6);
	
	signal intermediatNum : intArray := (0,0,0,0,0,0);

begin
	reset <= key(1);
	clk <= key(0);
	soda_can(0 to 3) <= SW(12 to 15);
	chips(0 to 3) <= SW(8 to 11);
	chocolate(0 to 3) <= SW(4 to 7);
	bubble_gum(0 to 3) <= SW(0 to 3);
		
	process(clk, reset)
	begin
		if reset = '0' then
			present_state <= idle;
		elsif (rising_edge(clk)) then
			present_state <= next_state;
		end if;
	end process;
	
	process(key, reset)
	begin
--Initially the intermediatNum!!
		if reset = '0' or present_state = idle then
			intermediatNum(4) <= 0;
			intermediatNum(5) <= 0;
			quarters <= intermediatNum(4)+ intermediatNum(5);
			quartersDisplay <= std_logic_vector(to_unsigned(quarters,8));
		else
		
			if rising_edge(key(2)) then
				intermediatNum(4) <=  (intermediatNum(4) + 1); 
			end if;
			
			if rising_edge(key(3)) then
				intermediatNum(5) <= (intermediatNum(5) + 4);
			end if;
			
			quarters <= intermediatNum(4)+ intermediatNum(5);
			quartersDisplay <= std_logic_vector(to_unsigned(quarters,8));
		end if;
	end process;
	
	process(soda_can,chips,chocolate,bubble_gum)
	begin
	--For all the situation of soda_can	
					case soda_can is		               
						when "0000"=>intermediatNum(3)<=0;
						when "0001"=>intermediatNum(3)<=1; 
						when "0010"=>intermediatNum(3)<=1; 
						when "0011"=>intermediatNum(3)<=2; 
	
						when "0100"=>intermediatNum(3)<=1; 
						when "0101"=>intermediatNum(3)<=2; 
						when "0110"=>intermediatNum(3)<=2; 
						when "0111"=>intermediatNum(3)<=3; 

						when "1000"=>intermediatNum(3)<=1; 
						when "1001"=>intermediatNum(3)<=2; 
						when "1010"=>intermediatNum(3)<=2; 
						when "1011"=>intermediatNum(3)<=3; 

						when "1100"=>intermediatNum(3)<=2; 
						when "1101"=>intermediatNum(3)<=3; 
						when "1110"=>intermediatNum(3)<=3; 
						when "1111"=>intermediatNum(3)<=4; 
					end case;
--For all the situation of chips 					
					case chips is		               
						when "0000"=>intermediatNum(2)<=0;
						when "0001"=>intermediatNum(2)<=1; 
						when "0010"=>intermediatNum(2)<=1; 
						when "0011"=>intermediatNum(2)<=2; 
	
						when "0100"=>intermediatNum(2)<=1; 
						when "0101"=>intermediatNum(2)<=2; 
						when "0110"=>intermediatNum(2)<=2; 
						when "0111"=>intermediatNum(2)<=3; 

						when "1000"=>intermediatNum(2)<=1; 
						when "1001"=>intermediatNum(2)<=2; 
						when "1010"=>intermediatNum(2)<=2; 
						when "1011"=>intermediatNum(2)<=3; 

						when "1100"=>intermediatNum(2)<=2; 
						when "1101"=>intermediatNum(2)<=3; 
						when "1110"=>intermediatNum(2)<=3; 
						when "1111"=>intermediatNum(2)<=4; 
					end case;
--For all the situation of chocolate 										
					case chocolate is		               
						when "0000"=>intermediatNum(1)<=0;
						when "0001"=>intermediatNum(1)<=1; 
						when "0010"=>intermediatNum(1)<=1; 
						when "0011"=>intermediatNum(1)<=2; 
	
						when "0100"=>intermediatNum(1)<=1; 
						when "0101"=>intermediatNum(1)<=2; 
						when "0110"=>intermediatNum(1)<=2; 
						when "0111"=>intermediatNum(1)<=3; 

						when "1000"=>intermediatNum(1)<=1; 
						when "1001"=>intermediatNum(1)<=2; 
						when "1010"=>intermediatNum(1)<=2; 
						when "1011"=>intermediatNum(1)<=3; 

						when "1100"=>intermediatNum(1)<=2; 
						when "1101"=>intermediatNum(1)<=3; 
						when "1110"=>intermediatNum(1)<=3; 
						when "1111"=>intermediatNum(1)<=4; 
					end case;
--For all the situation of bubble_gum 										
					case bubble_gum is		               
						when "0000"=>intermediatNum(0)<=0;
						when "0001"=>intermediatNum(0)<=1; 
						when "0010"=>intermediatNum(0)<=1; 
						when "0011"=>intermediatNum(0)<=2; 
	
						when "0100"=>intermediatNum(0)<=1; 
						when "0101"=>intermediatNum(0)<=2; 
						when "0110"=>intermediatNum(0)<=2; 
						when "0111"=>intermediatNum(0)<=3; 

						when "1000"=>intermediatNum(0)<=1; 
						when "1001"=>intermediatNum(0)<=2; 
						when "1010"=>intermediatNum(0)<=2; 
						when "1011"=>intermediatNum(0)<=3; 

						when "1100"=>intermediatNum(0)<=2; 
						when "1101"=>intermediatNum(0)<=3; 
						when "1110"=>intermediatNum(0)<=3; 
						when "1111"=>intermediatNum(0)<=4; 
					end case;
end process;
-----------------------------Wrong methond-------------------------------------------
--Display a dash across all HEX displays
--HEX0 <="1111110";
--HEX1 <="1111110";
--HEX2 <="1111110";
--HEX3 <="1111110";
--HEX4 <="1111110";
--HEX5 <="1111110";
--HEX6 <="1111110";
--HEX7 <="1111110";
--Try to detect the one change of SW(i)
				
--process
--begin 
--i<=0;
--loop
--wait until SW(i)='1';
--i<=i+1;
--end loop;
--end process;
--------------------------------------------------------------------------------------	
	process(present_state, SW, key)
	begin
		case present_state is
			when idle =>
				cost <= 4*intermediatNum(3) + 3*intermediatNum(2) + 2*intermediatNum(1) + intermediatNum(0);
			
				if (SW = "0000000000000000") then
					next_state <= idle;
					LEDG(0) <= '1';
					LEDR(0 to 17)<= "000000000000000000";
					LEDG(1 to 8) <= "00000000";
									
				else
					next_state <= product_select;
					LEDG(0) <= '1';
					LEDR(0 to 17)<= "000000000000000000";
					LEDG(1 to 8) <= "00000000";					
				end if;
-------------------I do not know why for loop statement did not work--------------------
		--when product_select =>				
		--		for i in 0 to 3 loop
		--			if bubble_gum(i)='1' then 
		--				intermediatNum(3)<=intermediatNum(3)+1;
		--			end if;
		--		end loop;
		--	Count the number of chocolate sold out
		--		for j in 0 to 3 loop
		--			if chocolate(j)='1' then 
		--				intermediatNum(2)<=intermediatNum(2)+1;
		--			end if;
		--		end loop;
		--Count the number of chips sold out
		--		for p in 0 to 3 loop
		--			if chips(p)='1' then 
		--				intermediatNum(1)<=intermediatNum(1)+1;
		--			end if;
		--		end loop;
		--Count the number of soda_can sold out
		--		for q in 0 to 3 loop
		--			if soda_can(q)='1' then 
		--				intermediatNum(0)<=intermediatNum(0)+1;
		--			end if;
		--		end loop;
----------------So I try if statement-----------------------------------------------------------						
			when product_select =>	

					
					--cost <= 4*intermediatNum(3) + 3*intermediatNum(2) + 2*intermediatNum(1) + intermediatNum(0);
					costDisplay <= std_logic_vector(to_unsigned(cost,8));
					
--The condition for the vendingMachine is ready for dispense
					if costDisplay = quartersDisplay then
						dispense_ready <= '1';
					else
						dispense_ready <= '0';
					end if;
					
--The codes must conclude when DISPENSE_READY=0, because if it does not have the state will
--switch to IDLE state regardless of whether costDisplay=quartersDisplay or not.						
				if (dispense_ready = '0') then
					next_state <= product_select;
					LEDG(0) <= '0';
					LEDG(1) <= '1';
					LEDG(2) <= '0';
					LEDG(8) <= '0';
				else
					next_state <= dispense;
					LEDG(0) <= '0';
					LEDG(1) <= '1';
					LEDG(2) <= '0';
					LEDG(8) <= '1';
				end if;
			when dispense =>			
					LEDR (0 to 17) <= "111111111111111111";
					LEDG(0) <= '0';
					LEDG(1) <= '0';
					LEDG(2) <= '1';
					next_state <= idle;		
			end case;
	end process;

--display signals and connect to physical output

H1: hexDisplay port map (quartersDisplay(0 to 3), display1);
H0: hexDisplay port map (quartersDisplay(4 to 7), display0);
H4: hexDisplay port map (costDisplay(0 to 3), display5);
H5: hexDisplay port map (costDisplay(4 to 7), display4);

--Display the state of signal; 
	process(present_state)
		begin
			if (present_state = idle) then
				HEX0 <= "1111110";
				HEX1 <= "1111110";
				HEX5 <= "1111110";
				HEX4 <= "1111110";
				HEX2 <= "1111110";
				HEX3 <= "1111110";
				HEX6 <= "1111110";
				HEX7 <= "1111110";
			else
				HEX0 <= display0;
				HEX1 <= display1;
				HEX5 <= display5;
				HEX4 <= display4;
				HEX2 <= "1111111";
				HEX3 <= "1111111";
				HEX6 <= "1111111";
				HEX7 <= "1111111";
			end if;
	end process;

end structure;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Define the hexDisplay entity as one decoder with inputs(S) and outputs(H) 
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hexDisplay IS
	PORT (	S	: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
		H	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END hexDisplay;

-- Define the function of bcd7seg as one decoder
-- Create a switch case based on the intermediate signal S
ARCHITECTURE sstructure OF hexDisplay IS
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
