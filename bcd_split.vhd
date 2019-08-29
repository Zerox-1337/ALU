----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/30/2016 04:31:10 PM
-- Design Name: 
-- Module Name: bcd_split - Behavioral
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

entity bcd_split is
  Port (bcd_part : in std_logic_vector(3 downto 0);
        
        part_out : out std_logic_vector(6 downto 0) 
        );
end bcd_split;

architecture Behavioral of bcd_split is

begin
combinational : process(bcd_part)
begin
case (bcd_part) is
    
    when "0001" =>  -- 1       
        part_out <= "1111001";      -- .gfedcba first bit to the left is . last bit is a on. 
    when "0010" =>  -- 2   
        part_out <= "0100100"; 
    when "0011" =>  -- 3             
        part_out <= "0110000";
    when "0100" =>  -- 4        
        part_out <= "0011001";
    when "0101" =>  --5        
        part_out <= "0010010";
    when "0110" =>  -- 6       
        part_out <= "0000010";
    when "0111" =>  -- 7         
        part_out <= "1111000";
    when "1000" =>  -- 8       
        part_out <= "0000000";
    when "1001" =>  --9       
        part_out <= "0010000";
    when "0000" =>  --0       
        part_out <= "1000000";
    when "1011" =>  -- F0
        part_out <= "1001001";
    when others => -- display E
        part_out <= "0000110";   -- This is Error = E
    end case;     
    
end process;


end Behavioral;
