LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY counter IS
    PORT(
        clk : IN std_logic;
        press : IN std_logic;
        Q : OUT std_logic_vector(5 downto 0);
		  En : in std_logic;
		  Next_en : out std_logic
    );
END counter;

ARCHITECTURE behaviour OF counter IS
    SIGNAL count : unsigned(5 downto 0) := "000000";
    SIGNAL press_prev : std_logic := '0';
BEGIN

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (press = '1' AND press_prev = '0' and En = '1') THEN
                IF count = "001001" THEN
                    count <= "000000";
                ELSE
                    count <= count + 1;
					 END IF;
            END IF;
            press_prev <= press;
        END IF;
    END PROCESS;

    Q <= std_logic_vector(count);
	 Next_en <= '1' when (press = '1' AND press_prev = '0' and En = '1' and count = "001001") else '0';

END behaviour;