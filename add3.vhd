----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/30/2016 02:16:43 PM
-- Design Name: 
-- Module Name: add3 - Behavioral
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

entity add3 is
  Port ( input: in std_logic_vector(3 downto 0);
         output: out std_logic_vector(3 downto 0)
        );
end add3;

architecture Behavioral of add3 is
begin
process(input)
begin
    case (input) is
        when "0000" => 
            output <= "0000";   
        when "0001" =>
            output <= "0001";
        when "0010" =>
            output <= "0010";
        when "0011" =>
            output <= "0011";
        when "0100" =>
            output <= "0100";
        when "0101" => 
            output <= "1000";
        when "0110" =>
            output <= "1001";
        when "0111" =>
            output <= "1010";
        when "1000" =>
            output <= "1011";
        when "1001" =>
            output <= "1100";
        when "1010" =>
            output <= "1101";
        when "1011" =>
            output <= "1110";
--        when "1100" => --12
--            output <= "1111"; --15
        when others =>
            output <= "1111"; --15
    end case;
end process;    
end Behavioral;
