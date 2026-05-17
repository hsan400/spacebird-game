LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY seven_seg IS
	PORT(input : IN std_logic_vector(5 DOWNTO 0);
		output : OUT std_logic_vector(6 DOWNTO 0) );
END seven_seg;

ARCHITECTURE behaviour OF seven_seg IS
	BEGIN
		WITH input SELECT
			output <= 
			"1000000" WHEN "000000",
			"1111001" WHEN "000001",
			"0100100" WHEN "000010",
			"0110000" WHEN "000011",
			"0011001" WHEN "000100",
			"0010010" WHEN "000101",
			"0000010" WHEN "000110",
			"1111000" WHEN "000111",
			"0000000" WHEN "001000",
			"0010000" WHEN "001001",
			"1111111" WHEN OTHERS; 
END behaviour;