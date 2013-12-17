-- User-Encoded State Machine
LIBRARY ieee; -- Import logic primitives
USE ieee.std_logic_1164.all;

ENTITY activity9 IS

	PORT(	clk		:	IN STD_LOGIC;
			reset		:	IN STD_LOGIC;
			S			:	IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Input bits
			Z			:	OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Output bits
			pres_out	:	OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- Present state encoding
			next_out :	OUT STD_LOGIC_VECTOR(2 DOWNTO 0)); -- Next state encoding
			
END activity9;

ARCHITECTURE behaviour OF activity9 IS
	-- Build an enumerated type for the state machine
	TYPE count_state IS (A, B, C, D, E);
	
	-- Registers to hold the current state and the next state
	SIGNAL present_state, next_state	:	count_state;
	-- SIGNAL state_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	-- Attribute to declare a specific encoding for the states
	ATTRIBUTE syn_encoding : string;
	ATTRIBUTE syn_encoding OF count_state : TYPE IS "000 001 011 010 110";
	
BEGIN
	-- Move to the next state
	PROCESS(clk, reset)
	BEGIN
		IF (reset = '1') THEN 
			present_state <= A;
		ELSIF (rising_edge(clk)) THEN
			present_state <= next_state;
		END IF;		
	END PROCESS;
	
	-- Determine what the next state will be, and set the output bits
	PROCESS(present_state, S)
	BEGIN
		CASE present_state IS		
			WHEN A =>
				IF (S = "00") THEN
					next_state <= A;
					Z <= "00";
				ELSIF (S = "10") THEN
					next_state <= A;
					Z <= "00";
				ELSE
					next_state <= D;
					Z <= "01";
				END IF;
				
			WHEN B =>
				IF (S = "00") THEN
					next_state <= C;
					Z <= "10";
				ELSIF (S = "01") THEN
					next_state <= E;
					Z <= "00";
				ELSIF (S = "10") THEN
					next_state <= D;
					Z <= "11";
				ELSE
					next_state <= A;
					Z <= "01";
				END IF;
				
			WHEN C =>
				IF (S = "00") THEN
					next_state <= E;
					Z <= "01";
				ELSIF (S = "01") THEN
					next_state <= E;
					Z <= "01";
				ELSE
					next_state <= B;
					Z <= "10";
				END IF;
				
			WHEN D =>
				IF (S = "00") THEN
					next_state <= A;
					Z <= "01";
				ELSIF (S = "01") THEN
					next_state <= E;
					Z <= "10";
				ELSE
					next_state <= A;
					Z <= "00";
				END IF;
				
			WHEN E =>
				IF (S = "00") THEN
					next_state <= E;
					Z <= "01";
				ELSIF (S = "10") THEN
					next_state <= B;
					Z <= "11";
				ELSIF (S="11") THEN
					next_state <= D;
					Z <= "00";
				ELSE
					next_state <= A;
					Z <= "00";
				END IF;	
		END CASE;
	END PROCESS;
	
	-- Show what the present state is on waveforms
	pres_out <= "000" WHEN present_state = A ELSE 
					"001" WHEN present_state = B ELSE
	 				"011" WHEN present_state = C ELSE
	 				"010" WHEN present_state = D ELSE
					"110" WHEN present_state = E;
					
	-- Show what the next state is on waveforms
	next_out <= "000" WHEN next_state = A ELSE
					"001" WHEN next_state = B ELSE
	 				"011" WHEN next_state = C ELSE
	 				"010" WHEN next_state = D ELSE
					"110" WHEN next_state = E;
	
END behaviour;

