	----------------------Driver-------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY seg7 IS
	PORT( bcd : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			leds : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END seg7;

ARCHITECTURE seg7_behavior OF seg7 IS				--handles input from BCD to 7 seg output
BEGIN
		leds <= "1000000" WHEN bcd = "0000" ELSE
				  "1111001" WHEN bcd = "0001" ELSE
				  "0100100" WHEN bcd = "0010" ELSE
				  "0110000" WHEN bcd = "0011" ELSE
				  "0011001" WHEN bcd = "0100" ELSE
				  "0010010" WHEN bcd = "0101" ELSE
				  "0000010" WHEN bcd = "0110" ELSE
				  "1111000" WHEN bcd = "0111" ELSE
				  "0000000" WHEN bcd = "1000" ELSE
				  "0010000" WHEN bcd = "1001" ELSE
				  "0001000" WHEN bcd = "1010" ELSE
				  "0000011" WHEN bcd = "1011" ELSE
				  "1000110" WHEN bcd = "1100" ELSE
				  "0100001" WHEN bcd = "1101" ELSE
				  "0000110" WHEN bcd = "1110" ELSE
				  "0001110" WHEN bcd = "1111" ELSE
				  "-------";
				
END seg7_behavior;

---------------------Driver--------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

entity binbcd8 is
	PORT(	Bin: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			Pout: OUT STD_LOGIC_VECTOR (9 DOWNTO 0));
END binbcd8;

ARCHITECTURE bin_bcdarch of binbcd8 IS				--takes an 8-bit binary input and gives a 
																--12-bit bcd value (3-digit decimal value)
BEGIN
	
	process (Bin)											--uses shift add 3 method
	variable Z : STD_LOGIC_VECTOR (17 DOWNTO 0);
	begin
		FOR i IN 0 to 17 LOOP
			Z(i) := '0';
		END LOOP;
		
		Z(10 DOWNTO 3) := Bin;
		
		FOR i IN 0 to 4 LOOP
			IF z(11 DOWNTO 8) > 4 THEN
				z(11 DOWNTO 8) := z(11 DOWNTO 8) + 3;
			END IF;
			IF z(15 DOWNTO 12) > 4 THEN
				z(15 DOWNTO 12) := z(15 DOWNTO 12) + 3;
			END IF;
			Z(17 DOWNTO 1) := Z(16 DOWNTO 0);
		END LOOP;
		Pout <= Z(17 DOWNTO 8);
	END PROCESS;
END bin_bcdarch;

---------------------Driver--------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;

ENTITY converter IS
		PORT( clock, clear: IN STD_LOGIC;
				modebit: IN STD_LOGIC_VECTOR(1 DOWNTO 0) ;  								-- this will define input mode -00 = binary, 01 = decimal, 11= hex
				Binput : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  								-- 8 bit binary input . 
				output: BUFFER STD_LOGIC_VECTOR (7 DOWNTO 0);							-- capture button ... 
				input: BUFFER STD_LOGIC_VECTOR( 7 DOWNTO 0);								--takes and modifies input from switches and key presses
				HexMSB , HexLSB:  BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0);				--to be output to 7-seg hexs
				Dec: BUFFER STD_LOGIC_VECTOR(9 DOWNTO 0);									--receives output from binbcd8 ENTITY
				DecMSB ,DecMID , DecLSB:  BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0);		--to be output to 7-seg hexs	

				incButtonLeft, incButtonMid, incButtonRight : IN STD_LOGIC;  							-- 3 increment buttons  
				Bleds : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);									-- the binary leds that are  going to display the output in binary 
				seg1,seg2,seg3,seg4,seg5,seg6: OUT STD_LOGIC_VECTOR(6 DOWNTO 0));		-- the 5 seven segments used as output display
																										-- seg 1 2 and 3 are decimal output displays .. seg4 and 5 are the hexoutput displays
			
	END converter ;
	
ARCHITECTURE behavior OF converter IS
	

COMPONENT seg7																	--add 7-seg component
			PORT (bcd : IN STD_LOGIC_VECTOR( 3 DOWNTO 0);
					leds : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END COMPONENT;

COMPONENT binbcd8																--add binbcd8 component
		PORT(	Bin: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
				Pout: OUT STD_LOGIC_VECTOR (9 DOWNTO 0));
END COMPONENT; 

BEGIN																				--map output values to 7seg displays
   s7A: seg7 PORT MAP (DecLSB, seg1 ); -- 
	s7B: seg7 PORT MAP (DecMID, seg2 );
	s7C: seg7 PORT MAP (DecMSB, seg3 );
	s7D: seg7 PORT MAP (HexLSB, seg4 ); -- 
	s7E: seg7 PORT MAP (HexMSB, seg5 );
	s7F: seg7 PORT MAP ("0000", seg6);
	decval: binbcd8 PORT MAP (input, Dec);								--map captured input values to binbcd8 to be displayed as decimal
	
	
Process 
begin
WAIT UNTIL Clock'EVENT AND Clock = '1' ;
	
	IF(clear = '0') THEN								--clears input capture if clear button is pressed
		input <= "00000000";
	END IF;
	
	IF (modebit = "00") THEN						--captures input from binary switches if modebit is 00
		input <= Binput;
	END IF;
	
	 
	IF (modebit = "01") THEN						--increments by decimal values if modebit = 01
		IF (incButtonRight = '0') THEN
			input <= input + 1;
			IF (input > 255) THEN
					input <= "00000000";
			END IF;
		END IF;
		IF (incButtonMid = '0') THEN
			input <= input + 10;
				IF (input > 255) THEN
					input <= "00000000";
				END IF;
		END IF;
		IF (incButtonLeft = '0') THEN
			input <= input + 100;
				IF (input > 255) THEN
					input <= "00000000";
				END IF;
		END IF;
		
	END IF;
	IF (modebit = "11") THEN					--increments byhex values if modebit = 11
		IF (incButtonRight = '0') THEN
			input <= input + 1;
			IF (input > 255) THEN
					input <= "00000000";
			END IF;
		END IF;
	IF (incButtonMid = '0') THEN
			input <= input + 16;
				IF (input > 255) THEN
					input <= "00000000";
				END IF;
		END IF;
	END IF;
	END process;
	
	process(input) IS
	begin
		output <= input;
	END Process;
	
	Bleds(7) <= output(7);	--handle binary LED output
	Bleds(6) <= output(6);
	Bleds(5) <= output(5);
	Bleds(4) <= output(4);
	Bleds(3) <= output(3);
	Bleds(2) <= output(2);
	Bleds(1) <= output(1);
	Bleds(0) <= output(0);
			
	HexMSB(3) <= output(7);	--handle hex output to 7-seg display
	HexMSB(2) <= output(6);
	HexMSB(1) <= output(5);
	HexMSB(0) <= output(4);
	HexLSB(3) <= output(3);
	HexLSB(2) <= output(2);
	HexLSB(1) <= output(1);
	HexLSB(0) <= output(0);
	
	DecMSB <= "0000" + Dec(9 DOWNTO 8); --handle decimal output to 7-seg display
	DecMID <= Dec(7 DOWNTO 4);
	DecLSB <= Dec(3 DOWNTO 0);
	
END behavior;
		