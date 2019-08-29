library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
   port ( A          : in  std_logic_vector (7 downto 0);   -- Input A
          B          : in  std_logic_vector (7 downto 0);   -- Input B
          FN         : in  std_logic_vector (3 downto 0);   -- ALU functions provided by the ALU_Controller (see the lab manual)
          result 	 : out std_logic_vector (7 downto 0);   -- ALU output (unsigned binary)
	      overflow   : out std_logic;                       -- '1' if overflow ocurres, '0' otherwise 
	      sign       : out std_logic                        -- '1' if the result is a negative value, '0' otherwise
        );
end ALU;

architecture behavioral of ALU is

signal signed_AsubB : signed(7 downto 0);
signal signed_AaddB : signed(7 downto 0);
signal AsubB        : unsigned(7 downto 0);
signal AaddB        : unsigned(7 downto 0);
-- SIGNAL DEFINITIONS HERE IF NEEDED
signal d1, d2, d3, d4, d5, mod_out : std_logic_vector(1 downto 0);

component mod3 is
    port( input : in std_logic_vector(2 downto 0);
          output : out std_logic_vector(1 downto 0)
    );
end component;
begin
mod3_1: mod3 
    port map(input(2) => A(7), input(1) => A(6), input (0) => A(5),
             output(1) => d1(1), output(0) => d1(0)
             );
mod3_2: mod3 
    port map(input(2) => d1(1), input(1) => d1(0), input(0) => A(4),
             output(1) => d2(1), output(0) => d2(0)
             );
mod3_3: mod3 
    port map(input(2) => d2(1), input(1) => d2(0), input(0) => A(3),
             output(1) => d3(1), output(0) => d3(0)
             );
mod3_4: mod3 
    port map(input(2) => d3(1), input(1) => d3(0), input(0) => A(2),
             output(1) => d4(1), output(0) => d4(0)
             );
mod3_5: mod3 
    port map(input(2) => d4(1), input(1) => d4(0), input(0) => A(1),
             output(1) => d5(1), output(0) => d5(0) 
             );
mod3_6: mod3 
    port map(input(2) => d5(1), input(1) => d5(0), input(0) => A(0),
             output(1) => mod_out(1), output(0) => mod_out(0)
             );

   
    signed_AsubB <= (signed (A) - signed (B));
    signed_AaddB <= (signed (A) + signed (B));
    AsubB        <= (unsigned(A) - unsigned(B));
    AaddB        <= (unsigned (A) + unsigned(B));
    
   process ( FN, A, B, signed_AsubB, signed_AaddB, AsubB, AaddB, mod_out) 
   begin
    overflow <= '0';
    result <= "00000000";
    sign <= '0'; -- For plus.
    case FN is 
    when "0000" => -- Input A
        result <= A; -- The result A will be displayed. 
    
    when "0001" => -- Input B
        result <= B; -- The result B will be displayed.
   
    when "0010" =>  -- Add unsigned      
        if (AaddB < unsigned(A) or AaddB < unsigned(B)) then -- If the result is less than one of the numbers we added together than it's overflow. 
            overflow <= '1';
        else
            result <= std_logic_vector(AaddB);            
        end if;    
          
     when "0011" =>  -- sub unsigned          
        if (unsigned(A) < unsigned(B)) then -- If the result is less than one of the numbers we added together than it's overflow. 
            overflow <= '1';
        else
            result <= std_logic_vector(AsubB);           
        end if; 
        
     when "0100" => -- Unsigned mod 3
          result <= "000000" & mod_out;    
    
    when "1010" => -- signed add.
        if (A(7) = '0' and B(7) = '0' and (signed_AaddB) <= 0) then -- Both postive but negative result, overflow.
            overflow <= '1';
        elsif (A(7) = '1' and B(7) = '1' and (signed_AaddB) >= 0 ) then -- Both negative but positive result, overflow.
            overflow <= '1';
        else
             if (signed_AaddB< 0) then
                sign <= '1';
                result <= std_logic_vector(not(signed_AaddB) + 1);                
             else
                result <= std_logic_vector(signed_AaddB);
             end if;
             
    end if;
    
    when "1011" => -- signed minus
      
        if (A(7) /= B(7) and ((signed_AaddB > 0 and signed(B) > 0) or  (signed_AaddB < 0 and signed(B) < 0))) then -- both got different signs and the result is the same sign as B (what you substract) 
            overflow <= '1';
        else
            if (signed_AsubB < 0) then
                sign <= '1';               
                result <= std_logic_vector(not(signed_AsubB) +1);             
            else
                result <= std_logic_vector(signed_AsubB);
            end if;
           
           
    end if;
   
   when "1100" => -- Signed A mod.
        if(A = "10000000") then
            result <= "00000001";
        elsif(A(7) = '1') then
            if(mod_out = "00") then
                result <= "00000010";
            elsif(mod_out = "10") then
                result <= "00000000";
            else
                result <= "00000001";
            end if;
        else
            result <= "000000" & mod_out; 
        end if;
   when others => null;
end case;
end process;

end behavioral;
