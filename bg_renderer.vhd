library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bg_renderer is 
    port (
        pixel_row, pixel_column : in STD_LOGIC_VECTOR(9 DOWNTO 0);
        scroll_en, reset : in std_logic;
        red, green, blue : out std_logic;
    )
end bg_renderer;

architecture behaviour of bg_renderer is 
    signal scroll_x : std_logic_vector(9 downto 0) := (others => '0');

begin
    process(scroll_en, reset)
    begin
        if (reset = '1') then 
            scroll_x <= (others => '0');
        elsif rising_edge(scroll_en) then 
            scroll_x <= scroll_x + 1;
        end if;
    end process;

    process(pixel_row, pixel_column, scroll_x)
        variable x, y, sx : integer;
    begin
        x := conv_integer(pixel_column);
        y := conv_integer(pixel_row);
        sx := conv_integer(scroll_x);

        red <= '0';
        green <= '0';
        blue <= '1';

        if (((x + sx) mod 63 = 0) and ((y + sx) mod 47 = 0)) then
            red   <= '1';
            green <= '1';
            blue  <= '1';  
        end if;

        if (((x + sx/2) mod 97 = 0) and (y mod 83 = 0)) then
            red   <= '1';
            green <= '1';
            blue  <= '0';  
        end if;

    end process;

end architecture behaviour;