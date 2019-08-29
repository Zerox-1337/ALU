library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regUpdate is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          RegCtrl    : in  std_logic_vector (1 downto 0);   -- Register update control from ALU controller. 11 = clear. 10 = update A, 01 = update B. 00 = nothing. 
          input      : in  std_logic_vector (7 downto 0);   -- Switch inputs
          A          : out std_logic_vector (7 downto 0);   -- Input A
          B          : out std_logic_vector (7 downto 0)   -- Input B
        );
end regUpdate;

architecture behavioral of regUpdate is
type state_type is (rst, st1, st2);
signal state, next_state : state_type;
signal A_reg, B_reg, A_next, B_next : std_logic_vector(7 downto 0);

begin

seq: process(clk, reset)
begin
    if (reset = '0') then
        A_reg <= (others => '0');
        B_reg <= (others => '0');
    elsif (clk'event and clk = '1') then
        A_reg <= A_next;
        B_reg <= B_next;
    end if;
end process;
    
    
comb: process(input,RegCtrl, A_reg, B_reg)
begin
   A_next <= A_reg;
   B_next <= B_reg;
   if (RegCtrl = "10") then
     A_next <= input;
    end if;
    
    if (RegCtrl ="01") then
         B_next <= input;
    end if;
     
end process;

    A <= A_reg;
    B <= B_reg;
end behavioral;
