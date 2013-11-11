
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
port(		
	CLOCK_50			:IN		STD_LOGIC;
	SRAM_DQ			:INOUT	STD_LOGIC_VECTOR(15 DOWNTO  0);	-- SRAM Data bus 16 Bits
	SRAM_ADDR		:BUFFER	STD_LOGIC_VECTOR(19 DOWNTO  0);	-- SRAM Address bus 18 Bits
	SRAM_LB_N		:BUFFER	STD_LOGIC;								-- SRAM Low-byte Data Mask 
	SRAM_UB_N		:BUFFER	STD_LOGIC;								-- SRAM High-byte Data Mask 
	SRAM_CE_N		:BUFFER	STD_LOGIC;								-- SRAM Chip chipselect
	SRAM_OE_N		:BUFFER	STD_LOGIC;								-- SRAM Output chipselect
	SRAM_WE_N		:BUFFER	STD_LOGIC;								-- SRAM Write chipselect

	key: in std_logic_vector(3 downto 0);
	SW: in std_logic_vector(17 downto 0);
	LEDG: out std_logic_vector(3 downto 0);
	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7: OUT STD_LOGIC_VECTOR(0 TO 6)
	);
end processor;

architecture structure of processor is

COMPONENT altera_UP_sram
	PORT (
	-- Inputs
	CLK				:IN		STD_LOGIC;
	reset				:IN		STD_LOGIC;
	address			:IN		STD_LOGIC_VECTOR(19 DOWNTO  0);
	byteenable		:IN		STD_LOGIC_VECTOR( 1 DOWNTO  0);	
	read				:IN		STD_LOGIC;
	write				:IN		STD_LOGIC;
	writedata		:IN		STD_LOGIC_VECTOR(15 DOWNTO  0);	

	-- Bi-Directional
	SRAM_DQ			:INOUT	STD_LOGIC_VECTOR(15 DOWNTO  0);	-- SRAM Data bus 16 Bits

	-- Outputs
	readdata			:BUFFER	STD_LOGIC_VECTOR(15 DOWNTO  0);	
	readdatavalid	:BUFFER	STD_LOGIC;

	SRAM_ADDR		:BUFFER	STD_LOGIC_VECTOR(19 DOWNTO  0);	-- SRAM Address bus 18 Bits
	SRAM_LB_N		:BUFFER	STD_LOGIC;								-- SRAM Low-byte Data Mask 
	SRAM_UB_N		:BUFFER	STD_LOGIC;								-- SRAM High-byte Data Mask 
	SRAM_CE_N		:BUFFER	STD_LOGIC;								-- SRAM Chip chipselect
	SRAM_OE_N		:BUFFER	STD_LOGIC;								-- SRAM Output chipselect
	SRAM_WE_N		:BUFFER	STD_LOGIC);								-- SRAM Write chipselect

	END COMPONENT;

--define the component of the ALU
component ALU
	port( opcode: in std_logic_vector(2 downto 0);
			A:		  in std_logic_vector(7 downto 0);
			B:		  in std_logic_vector(7 downto 0);
			ALU_out:out std_logic_vector(7 downto 0));
end component;
--define the component of the bcd7seg
component bcd7seg
	PORT (S	: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
			H	: OUT	STD_LOGIC_VECTOR(0 TO 6));
end component;

--define the component of program_counter
component program_counter is
	port( increment_flag: in std_logic;
			new_count: out std_logic_vector(3 downto 0);
			old_count: in std_logic_vector(3 downto 0)
	);
end component;

--*******************************Signal Part*********************************************************--
   type count_state is (fetch, decode, execute, memory_write);
	type ADDR_array is array (1 downto 0) of STD_LOGIC_VECTOR(4 downto 0);
	type Data_array is array (2 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
	
	--Define the waht the state is now of present_state and next_state
	signal present_state, next_state : count_state;
	signal address_array: ADDR_array;
	signal datas_array: Data_array;
	
	signal instruction: std_logic_vector(17 downto 0);  --This is the instruction IR
	signal clk: std_logic;
	signal reset: std_logic;
	signal opfield: std_logic_vector(2 downto 0);
	signal address: std_logic_vector(19 downto 0);
	signal byteenable: std_logic_vector(1 downto 0):="01"; --make the all the 16-bits data available
	signal writedata,
			 readdata: std_logic_vector(15 downto 0);
	signal is_decode,
		  	 is_execute,			
			 is_memory_write,
			 is_write,
			 is_read :std_logic;
	signal readdatavalid: std_logic; 
	signal intermediate1Data,
			 intermediate2Data: STD_LOGIC_VECTOR(15 downto 0);
	signal intermediate1Hexdisplay,
			 intermediate2Hexdisplay,
			 intermediate3Hexdisplay,
			 intermediate4Hexdisplay: std_logic_vector(7 downto 0);
	signal display7, display6, display5, display4, display3, display2, display1, display0 : STD_LOGIC_VECTOR(0 TO 6);
	signal inter8bitData1,
			 inter8bitData2: std_logic_vector(7 downto 0);
	signal ALU_output: std_logic_vector(15 downto 0);
	signal counter: integer range 0 to 101 :=0;
	
	signal increment_flag: std_logic;
	signal old_count, new_count: std_logic_vector(3 downto 0):="0000";
	
--***************************************************************************************************--
--the main part of the processor architecture
begin
	reset<=key(1);	
	clk<=key(0);
	process(clk,reset)
	begin	
		if (reset='0') then 
			present_state<=fetch;
		elsif (rising_edge(clk)) then 
			present_state<=next_state;
		end if;
	end process;
	
	process(present_state, instruction, reset, SW)
	begin
		case present_state is
			when fetch=>
				--Let the LEDG3-LEDG0 display the the current state
				LEDG(3)<='1';
				LEDG(2)<='0';
				LEDG(1)<='0';
				LEDG(0)<='0';
				--take in the instructions
				instruction<=SW;
				is_write<= '0';
				is_read <= '0';
				increment_flag<='0';
				old_count <= new_count;
				next_state<=decode;
			when decode=>
				is_decode<='0';
				--Let the LEDG3-LEDG0 display the the current state
				LEDG(3)<='0';
				LEDG(2)<='1';
				LEDG(1)<='0';
				LEDG(0)<='0';
				opfield<= instruction(17 downto 15);
				address_array(1)<= instruction(9 downto 5);
				address_array(0)<= instruction(4 downto 0);
				intermediate1Hexdisplay<="000"&instruction(9 downto 5);
				intermediate2Hexdisplay<="000"&instruction(4 downto 0);
				intermediate3Hexdisplay<="00000"&instruction(17 downto 15);
				
				is_read <= '1';
				
--***The statement in the for loop did not execute sequentially************
--for i in 1 downto 0 loop
--datas_array(i)<=readdata;
--address<="000000000000000"&address_array(i);


--end loop;
--*************************************************************************
				if (counter=0) then 
					address<="000000000000000"&address_array(1);
					datas_array(1)<=readdata;
				end if;
					
				if (counter=100) then 
					address<="000000000000000"&address_array(0);
					datas_array(0)<=readdata;					
				end if;	
					
				next_state<=execute;
				
			when execute=>
				--Let the LEDG3-LEDG0 display the the current state
				LEDG(3)<='0';
				LEDG(2)<='0';
				LEDG(1)<='1';
				LEDG(0)<='0';
				
		    	is_read <='0';
				intermediate1Data<=datas_array(1);
				intermediate2Data<=datas_array(0);
					
				inter8bitData1<=intermediate1Data(7 downto 0);
				inter8bitData2<=intermediate2Data(7 downto 0);
					
				intermediate1Hexdisplay<=inter8bitData1;
				intermediate2Hexdisplay<=inter8bitData2;
				intermediate3Hexdisplay<=ALU_output(7 downto 0);

				next_state<=memory_write;

			when memory_write=>
				--Let the LEDG3-LEDG0 display the the current state
				LEDG(3)<='0';
				LEDG(2)<='0';
				LEDG(1)<='0';
				LEDG(0)<='1';
							
				is_write<='1';
				address<= "000000000000000"&instruction(14 downto 10);				
				writedata<="00000000"&ALU_output(7 downto 0);
				
				intermediate1Hexdisplay<="000"&instruction(14 downto 10);
				
				if (counter=100 and is_write='1') then 
					is_write<='0';
					is_read<='1';
					address<="000000000000000"&instruction(14 downto 10);
					datas_array(2)<=readdata;			
					intermediate3Hexdisplay<=datas_array(2)(7 downto 0);		
				end if;		
				
				increment_flag<='1';
				next_state<=fetch;
				
		end case;
	end process;
	
--In the execution state, we preform alu operation
   compute: ALU port map(opfield, inter8bitData1, inter8bitData2, ALU_output(7 downto 0));
--**********************************************************************
--We do the program counter port map
   programCount: program_counter port map(increment_flag, old_count, new_count);

--Implement the counter to delay the time
process(CLOCK_50)
begin 
  if(rising_edge(CLOCK_50)) then
    counter <= counter + 1;
  end if;
end process;
 
--Does port map of hex display
	--H0: bcd7seg port map();
	H7: bcd7seg port map(intermediate1Hexdisplay(7 downto 4), display7);
	H6: bcd7seg port map(intermediate1Hexdisplay(3 downto 0), display6);
	H5: bcd7seg port map(intermediate2Hexdisplay(7 downto 4), display5);
	H4: bcd7seg port map(intermediate2Hexdisplay(3 downto 0), display4);
	H3: bcd7seg port map(intermediate3Hexdisplay(7 downto 4), display3);
	H2: bcd7seg port map(intermediate3Hexdisplay(3 downto 0), display2);
	
	H0: bcd7seg port map(new_count, display0);
	
--Display the state of signal; 
	process(present_state)
		begin
			if (present_state = fetch) then
				HEX0 <= "1111110";
				HEX1 <= "1111110";
				HEX5 <= "1111110";
				HEX4 <= "1111110";
				HEX2 <= "1111110";
				HEX3 <= "1111110";
				HEX6 <= "1111110";
				HEX7 <= "1111110";
			elsif (present_state = decode) then 
				HEX7 <= display7;
				HEX6 <= display6;
				HEX5 <= display5;
				HEX4 <= display4;
				HEX3 <= display2;
				HEX2 <= "1111111";
				HEX1 <= "1111111";
				HEX0 <= display0;
			elsif (present_state = execute) then 
				HEX7 <= display7;
				HEX6 <= display6;
				HEX5 <= display5;
				HEX4 <= display4;
				HEX3 <= display3;
				HEX2 <= display2;
				HEX1 <= "1111111";
				HEX0 <= display0;
			else 
				HEX7 <= display7;
				HEX6 <= display6;
				HEX5 <= "1111111";
				HEX4 <= "1111111";
				HEX3 <= display3;
				HEX2 <= display2;
				HEX1 <= "1111111";
				HEX0 <= display0;
			end if;
	end process;

--************************************************************************************
--In the DECODE and MEMORY_write state, we do the port map
MEM: altera_UP_sram PORT MAP(
	clk=>CLOCK_50, 
	reset=>not key(1),
	address=>address,
	byteenable=>byteenable,
	read=>is_read,
	write=>is_write,
	writedata=>writedata,
	SRAM_DQ=>SRAM_DQ,
	readdata=>readdata,
	readdatavalid=>readdatavalid,
	
	SRAM_ADDR=>SRAM_ADDR,
	SRAM_LB_N=>SRAM_LB_N,
	SRAM_UB_N=>SRAM_UB_N,
	SRAM_CE_N=>SRAM_CE_N,
	SRAM_OE_N=>SRAM_OE_N,
	SRAM_WE_N=>SRAM_WE_N
);
--************************************************************************************
end structure;

--The entity of program counter
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
	port( increment_flag: in std_logic;
			new_count: out std_logic_vector(3 downto 0);
			old_count: in std_logic_vector(3 downto 0)
	);
end program_counter;

architecture behave of program_counter is 
begin 
	process(increment_flag)
	begin
		if increment_flag='1' then 
			new_count<=std_LOGIC_VECTOR(signed(old_count)+1);
		else 
			new_count<=old_count;		
		end if;
	end process;
end behave;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is 
	port( opcode: in std_logic_vector(2 downto 0);
			A:		  in std_logic_vector(7 downto 0);
			B:		  in std_logic_vector(7 downto 0);
			ALU_out:out std_logic_vector(7 downto 0));
end ALU;

architecture behavior of ALU is
begin		
process(opcode) 
begin	
		case opcode is
			when "000"=>ALU_out<=(A and B);
			when "001"=>ALU_out<=(A or B);
			when "010"=>ALU_out<=(A nand B);
			when "011"=>ALU_out<=(A nor B);
			when "100"=>ALU_out<=(A xor B);
			when "101"=>ALU_out<=std_logic_vector(signed(A)+signed(B));
			when "110"=>ALU_out<=std_logic_vector(signed(A)-signed(B));
			when "111"=>ALU_out<=std_logic_vector(shift_right(signed(A), to_integer(signed(B))));  
		end case;
	end process;
end behavior;


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

