----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/06/2016 03:34:52 PM
-- Design Name: 
-- Module Name: mod3 - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mod3 is
  Port ( input : in std_logic_vector(2 downto 0);
          output : out std_logic_vector(1 downto 0)
        );
end mod3;

architecture Behavioral of mod3 is

begin
process(input)
begin
case (input) is
    when "000" =>
        output <= "00";
    when "001" =>
        output <= "01";
    when "010" =>
        output <= "10";
    when "011" =>
        output <= "00";
    when "100" =>
        output <= "01";
    when "101" =>
        output <= "10";
    when "110" => -- only for first component
        output <= "00";
    when "111" => -- only for first component
        output <= "01";
    when others =>
        null;
end case;
end process;
end Behavioral;
