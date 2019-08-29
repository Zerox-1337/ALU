----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/06/2016 01:38:16 PM
-- Design Name: 
-- Module Name: bcd_invert - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bcd_invert is
  Port (  bcd_in: in std_logic_vector(9 downto 0);
          sign : in std_logic;
          bcd_out: out std_logic_vector(9 downto 0)
        );
end bcd_invert;

architecture Behavioral of bcd_invert is
begin
process(bcd_in, sign)
begin
    if (sign = '1') then -- If a negative unsigned number then invert and take +1.
        if(bcd_in(9) = '1') then    
            --bcd_out <= std_logic_vector(signed(not(bcd_in)) + 1 );
                   bcd_out <= bcd_in; 
        else
            bcd_out <= bcd_in; 
        end if; 
    else
        bcd_out <= bcd_in;
    end if;
end process;

end Behavioral;
