library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALU_components_pack.all;

entity binary2BCD is
   generic ( WIDTH : integer := 8   -- 8 bit binary to BCD
           );
   port ( binary_in : in  std_logic_vector(WIDTH-1 downto 0);  -- binary input width
          BCD_out   : out std_logic_vector(9 downto 0)        -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
        );
end binary2BCD;

architecture structural of binary2BCD is 

component add3 is
    port( input : in std_logic_vector(3 downto 0);
          output: out std_logic_vector(3 downto 0)
         );
end component;
signal  d2, d3, d4, d5, d6, d7: std_logic_vector(3 downto 0);
signal bcd_vector: std_logic_vector(9 downto 0);
begin 
    c1: add3 
        port map( input(3) => '0', input(2) => binary_in(7), input(1) => binary_in(6), input(0) => binary_in(5),
                  output(3) => d6(2), output(2) => d2(3), output(1) => d2(2), output(0) => d2(1)
                );
    c2: add3
        port map( input(3) => d2(3), input(2) => d2(2), input(1) => d2(1), input(0) => binary_in(4),
                  output(3) => d6(1), output(2) => d3(3), output(1) => d3(2), output(0) => d3(1)
                );
    c3: add3 
        port map( input(3) => d3(3), input(2) => d3(2), input(1) => d3(1), input(0) => binary_in(3),
                  output(3) => d6(0), output(2) => d4(3), output(1) => d4(2), output(0) => d4(1)           
                );
    c4: add3
        port map( input(3) => d4(3), input(2) => d4(2), input(1) => d4(1), input(0) => binary_in(2),
                  output(3) => d7(0), output(2) => d5(3), output(1) => d5(2), output(0) => d5(1)
                 );
     c5: add3
        port map( input(3) => d5(3), input(2) => d5(2), input(1) => d5(1), input(0) => binary_in(1),
                  output(3) => bcd_vector(4), output(2) => bcd_vector(3), output(1) => bcd_vector(2), output(0) => bcd_vector(1)
                  ); 
    c6: add3
        port map( input(3) => '0', input(2) => d6(2), input(1) => d6(1), input(0) => d6(0),
                  output(3) => bcd_vector(9), output(2) => d7(3), output(1) => d7(2), output(0) => d7(1)
                  );
    c7: add3
        port map( input(3) => d7(3), input(2) => d7(2), input(1) => d7(1), input(0) => d7(0),
                  output(3) => bcd_vector(8), output(2) => bcd_vector(7), output(1) => bcd_vector(6), output(0) => bcd_vector(5)
                  );   
    bcd_vector(0) <= binary_in(0);
    BCD_out <= bcd_vector;                             
end structural;

