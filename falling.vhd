LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY falling IS
    PORT( pb1, pb2, lmsb, clk, vert_sync, dp_text : IN STD_LOGIC;
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        red, green, blue : OUT STD_LOGIC
    );
END falling;

ARCHITECTURE behaviour OF falling IS

    COMPONENT char_rom IS
    PORT(
        character_address : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        font_row, font_col : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        clock : IN STD_LOGIC;
        rom_mux_output : OUT STD_LOGIC
    );
    END COMPONENT;

    SIGNAL ball_on : STD_LOGIC;
    SIGNAL size : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL ball_y_pos : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240, 10);
    SIGNAL ball_x_pos : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL ball_y_motion : STD_LOGIC_VECTOR(9 DOWNTO 0);

    SIGNAL char_addr : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL font_r : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL font_c : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL rom_pixel : STD_LOGIC;
    SIGNAL in_title : STD_LOGIC;
    SIGNAL title_rel_col : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL title_rel_row : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL title_char_x : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL text_on : STD_LOGIC;

    SIGNAL lives : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";

    SIGNAL char_addr2 : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL font_r2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL font_c2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL rom_pixel2 : STD_LOGIC;
    SIGNAL in_lives : STD_LOGIC;
    SIGNAL lives_rel_col : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL lives_rel_row : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL lives_char_x : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL lives_digit : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL lives_on : STD_LOGIC;

BEGIN
		
    -- Title
    ROM : char_rom PORT MAP(
        character_address => char_addr,
        font_row => font_r,
        font_col => font_c,
        clock  => clk,
        rom_mux_output => rom_pixel
    );

    -- Lives
    ROM2 : char_rom PORT MAP(
        character_address => char_addr2,
        font_row => font_r2,
        font_col => font_c2,
        clock => clk,
        rom_mux_output => rom_pixel2
    );

    -- Bird
    size <= CONV_STD_LOGIC_VECTOR(8, 10);
    ball_x_pos <= CONV_STD_LOGIC_VECTOR(590, 11);

    ball_on <= '1' WHEN (('0' & ball_x_pos <= '0' & pixel_column + size) AND
        ('0' & pixel_column <= '0' & ball_x_pos + size) AND
        ('0' & ball_y_pos  <= pixel_row + size) AND
        ('0' & pixel_row   <= ball_y_pos + size)) ELSE '0';

    
	 Move_Ball: PROCESS(vert_sync)
    BEGIN
        IF rising_edge(vert_sync) THEN
			if (ball_y_pos > CONV_STD_LOGIC_VECTOR(479, 10) - size) THEN
				ball_y_motion <= (OTHERS => '0');
				ball_y_pos <= CONV_STD_LOGIC_VECTOR(479, 10) - size;
			elsif (ball_y_pos <= size) THEN
				ball_y_motion <= ball_y_motion + CONV_STD_LOGIC_VECTOR(1, 10);
				ball_y_pos <= ball_y_pos + ball_y_motion;
			elsif (lmsb = '1') THEN
				ball_y_motion <= -CONV_STD_LOGIC_VECTOR(4, 10);
				ball_y_pos <= ball_y_pos + ball_y_motion;
			ELSE
				ball_y_motion <= ball_y_motion + CONV_STD_LOGIC_VECTOR(1, 10);
				ball_y_pos <= ball_y_pos + ball_y_motion;
         END IF;
        END IF;
    END PROCESS Move_Ball;

    -- Title
    in_title <= '1' WHEN (
        pixel_row >= 10  AND pixel_row < 26 AND
        pixel_column >= 240 AND pixel_column < 400)
        ELSE '0';

    title_rel_col <= pixel_column - 240;
    title_rel_row <= pixel_row - 10;
    title_char_x  <= title_rel_col(7 DOWNTO 4);

    PROCESS(title_char_x)
    BEGIN
        CASE title_char_x IS
            WHEN "0000" => char_addr <= CONV_STD_LOGIC_VECTOR(19, 6); -- S
            WHEN "0001" => char_addr <= CONV_STD_LOGIC_VECTOR(16, 6); -- P
            WHEN "0010" => char_addr <= CONV_STD_LOGIC_VECTOR(1, 6);  -- A
            WHEN "0011" => char_addr <= CONV_STD_LOGIC_VECTOR(3, 6);  -- C
            WHEN "0100" => char_addr <= CONV_STD_LOGIC_VECTOR(5, 6);  -- E
            WHEN "0101" => char_addr <= CONV_STD_LOGIC_VECTOR(32, 6); -- space
            WHEN "0110" => char_addr <= CONV_STD_LOGIC_VECTOR(2, 6);  -- B
            WHEN "0111" => char_addr <= CONV_STD_LOGIC_VECTOR(9, 6);  -- I
            WHEN "1000" => char_addr <= CONV_STD_LOGIC_VECTOR(18, 6); -- R
            WHEN "1001" => char_addr <= CONV_STD_LOGIC_VECTOR(4, 6);  -- D
            WHEN OTHERS => char_addr <= CONV_STD_LOGIC_VECTOR(32, 6);
        END CASE;
    END PROCESS;

    font_r  <= title_rel_row(3 DOWNTO 1);
    font_c  <= title_rel_col(3 DOWNTO 1);
    text_on <= rom_pixel WHEN (in_title = '1' and dp_text = '1') ELSE '0';

    -- Lives
    in_lives <= '1' WHEN (
        pixel_row >= 30  AND pixel_row < 38 AND
        pixel_column >= 284 AND pixel_column < 356)
        ELSE '0';

    lives_rel_col <= pixel_column - 284;
    lives_rel_row <= pixel_row - 30;
    lives_char_x <= lives_rel_col(6 DOWNTO 3); 


    PROCESS(lives)
    BEGIN
        CASE lives IS
            WHEN "11" => lives_digit <= CONV_STD_LOGIC_VECTOR(51, 6); -- '3'
            WHEN "10" => lives_digit <= CONV_STD_LOGIC_VECTOR(50, 6); -- '2'
            WHEN "01" => lives_digit <= CONV_STD_LOGIC_VECTOR(49, 6); -- '1'
            WHEN OTHERS => lives_digit <= CONV_STD_LOGIC_VECTOR(48, 6); -- '0'
        END CASE;
    END PROCESS;

    PROCESS(lives_char_x, lives_digit)
    BEGIN
        CASE lives_char_x IS
            WHEN "0000" => char_addr2 <= CONV_STD_LOGIC_VECTOR(12, 6); -- L
            WHEN "0001" => char_addr2 <= CONV_STD_LOGIC_VECTOR(9,  6); -- I
            WHEN "0010" => char_addr2 <= CONV_STD_LOGIC_VECTOR(22, 6); -- V
            WHEN "0011" => char_addr2 <= CONV_STD_LOGIC_VECTOR(5,  6); -- E
            WHEN "0100" => char_addr2 <= CONV_STD_LOGIC_VECTOR(19, 6); -- S
            WHEN "0110" => char_addr2 <= CONV_STD_LOGIC_VECTOR(46, 6); -- : 
            WHEN "0111" => char_addr2 <= CONV_STD_LOGIC_VECTOR(32, 6); -- space
            WHEN "1000" => char_addr2 <= lives_digit;                  
            WHEN OTHERS => char_addr2 <= CONV_STD_LOGIC_VECTOR(32, 6);
        END CASE;
    END PROCESS;

    font_r2 <= lives_rel_row(2 DOWNTO 0);
    font_c2 <= lives_rel_col(2 DOWNTO 0);
    lives_on <= rom_pixel2 WHEN (in_lives = '1' and dp_text = '1') ELSE '0';


    Red <= pb1 OR text_on OR lives_on;
    Green <= (NOT pb2) AND (NOT ball_on) AND (NOT text_on) AND (NOT lives_on);
    Blue <= (NOT ball_on) AND (NOT text_on) AND (NOT lives_on);

END behaviour;