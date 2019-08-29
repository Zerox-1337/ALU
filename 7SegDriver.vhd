library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_seg_driver is
   port ( clk           : in  std_logic;
          reset         : in  std_logic;
          BCD_digit     : in  std_logic_vector(9 downto 0);          
          sign          : in  std_logic;
          overflow      : in  std_logic;
          DIGIT_ANODE   : out std_logic_vector(3 downto 0);
          SEGMENT       : out std_logic_vector(6 downto 0)
        );
end seven_seg_driver;

architecture behavioral of seven_seg_driver is
signal ones, tens, hundreds, OFsign : std_logic_vector(6 downto 0);
type state_type is (rst, s0, s1, s2, s3);
signal state, next_state: state_type;
signal counter, next_counter: unsigned (19 downto 0);
signal bcd_out : std_logic_vector(9 downto 0);

component bcd_split is
    port( bcd_part: in std_logic_vector(3 downto 0);
          part_out: out std_logic_vector(6 downto 0)
          );
end component;     
begin

split1s: bcd_split
    port map(bcd_part => BCD_digit(3 downto 0),
             part_out => ones
             );
split10s: bcd_split
    port map(bcd_part => BCD_digit(7 downto 4),
             part_out => tens
             );
split100s: bcd_split
    port map(bcd_part(3) => '0', bcd_part(2) => '0', bcd_part(1) => BCD_digit(9), bcd_part(0) => BCD_digit(8),
             part_out => hundreds
             );
             

seq: process(clk, reset)
begin
    if(reset = '0') then
        state <= rst;
        counter <= (others => '0');
    elsif(clk'event and clk = '1') then
        state <= next_state;
        counter <= next_counter;
    end if;
end process;

write: process (counter, ones, tens, hundreds, overflow, sign) -- When total input or counter changes this process is run.
begin
    if(counter = "11111111111111111111" ) then -- If we get 20 1's we reset the counter to 0 zero again and start over.
        next_counter <= (others=> '0');        
    else
        next_counter <= counter + 1; -- Else we count
    end if;
        case(counter(19 downto 18)) is -- Will make it so that the switching delay on the display is so high that a human eye notices it. 
            when "00" =>
                DIGIT_ANODE <= "1110"; -- First display
                SEGMENT <= ones; -- Display First value
            when "01" => -- Second display 
                DIGIT_ANODE <= "1101";
                SEGMENT <= tens;
            when "10" => -- Third display
                DIGIT_ANODE <= "1011";
                SEGMENT <= hundreds;
            when "11" => -- Fourth display
                DIGIT_ANODE <= (others => '1');
                SEGMENT <= (others => '0'); 
                if (overflow = '1') then
                    DIGIT_ANODE <= "0111";
                    SEGMENT <= "0001110"; 
                elsif(sign = '1') then
                    DIGIT_ANODE <= "0111";
                    SEGMENT <= "0111111"; -- Minus sign
                end if;                 
            when others => null;       
    end case;
end process;
end behavioral;
