library ieee;
use ieee.std_logic_1164.all;

entity tb_ALU is
end tb_ALU;

architecture structural of tb_ALU is

signal Enter : std_logic := '0'; -- Where we store the debounced (stable) from the debouncer signal.
signal Sign : std_logic := '0'; -- Where we store the debounce (stable) from the debouncer signal. This sign is not the same as sign2. Sign1: 0 = unsigned. 1 = signed.
signal FN : std_logic_vector(3 downto 0); -- Where the FN output from keyboard ctrl goes to.
signal RegCtrl : std_logic_vector(1 downto 0); -- Where the RegCtrl (10 updates the A, 01 updates B) output from the keyboard goes to.
signal A : std_logic_vector (7 downto 0); -- Where the A (our first number in the register) output from the regUpdate goes. 
signal B : std_logic_vector (7 downto 0); -- Where the B (our second number in the register), output from the regUpdate goes.    
signal binary_in : std_logic_vector(7 downto 0); -- Where the result (the result from our mod 3, sub or add), output from the ALU goes.
signal overflow : std_logic; -- Where the overflow (from our mod 3, sub or add), output from the ALU goes. 1 = overflow. 0 = no overflow.  
signal Sign2 : std_logic; -- Where the sign (from our mod 3, sub or add), output from the ALU goes. 1= negative. 0 = positive
signal BCD_out : std_logic_vector(9 downto 0); -- BCD output from the binary2BCD that goes to the 7segdriver as BCD_digit. Bit 0-3: represent 10^0. Bit 4-7: 10^1. Bit 8-9: 10^2. 


signal b_Enter : std_logic := '0';
signal b_Sign : std_logic := '0';
signal clk : std_logic := '0';
signal reset : std_logic := '1';
signal input : std_logic_vector(7 downto 0)  := "00000000";
signal seven_seg  : std_logic_vector(6 downto 0) := "0000000";
signal anode : std_logic_vector(3 downto 0)  := "0000";


-- Defines the components. 

component debouncer is 
port (
        clk : in std_logic;
        reset : in std_logic;
        button_in : in std_logic;
        button_out : out std_logic
      );
end component;

component ALU_ctrl is 
port (
        clk : in std_logic;
        reset : in std_logic;
        enter : in std_logic;
        sign : in std_logic; -- If the number is unsigned or signed. The ALU uses a variable sign that is for: if '1' then negative, if '0' positive
        FN : out std_logic_vector(3 downto 0);
        RegCtrl : out std_logic_vector(1 downto 0)
      );
end component;   
    

 component regUpdate is
 port ( 
           clk        : in  std_logic;
           reset      : in  std_logic;
           RegCtrl    : in  std_logic_vector (1 downto 0);   -- Register update control from ALU controller. 11 = clear. 10 = update A, 01 = update B. 00 = nothing. 
           input      : in  std_logic_vector (7 downto 0);   -- Switch inputs
           A          : out std_logic_vector (7 downto 0);   -- Input A
           B          : out std_logic_vector (7 downto 0)   -- Input B
         );
 end component;
 
 component ALU is
    port ( A          : in  std_logic_vector (7 downto 0);   -- Input A
           B          : in  std_logic_vector (7 downto 0);   -- Input B
           FN         : in  std_logic_vector (3 downto 0);   -- ALU functions provided by the ALU_Controller (see the lab manual)
           result     : out std_logic_vector (7 downto 0);   -- A result from the ALU calc (result goes to binary2BCD as binary_in)
           overflow   : out std_logic;                       -- '1' if overflow ocurres, '0' otherwise 
           sign       : out std_logic                        -- If the number is negative then '1' if it's posivity then '0'. Don't confuse with the ALU ctrl value with the same name that says if a its unsigned or signed.
         );
 end component;
 
 component binary2BCD is
    generic ( WIDTH : integer := 8   -- 8 bit binary to BCD
            );
    port ( binary_in : in  std_logic_vector(WIDTH-1 downto 0);  -- binary input width
           BCD_out   : out std_logic_vector(9 downto 0)        -- BCD output. Bit 0-3: represent 10^0. Bit 4-7: 10^1. Bit 8-9: 10^2. 
         );
 end component;
 
 component seven_seg_driver is
    port ( clk           : in  std_logic;
           reset         : in  std_logic;
           BCD_digit     : in  std_logic_vector(9 downto 0);          
           sign          : in  std_logic;
           overflow      : in  std_logic;
           DIGIT_ANODE   : out std_logic_vector(3 downto 0);
           SEGMENT       : out std_logic_vector(6 downto 0)
         );
 end component;
 
 component bcd is
     port ( bcd_in : in std_logic_vector(3 downto 0);
            bcd_out: out std_logic_vector(3 downto 0)              
          );
 end component;
 constant period   : time := 1000 ns;
begin




Enter <= not(Enter) after period*5;
Sign <= not(Sign) after period*11;
reset <= '0', '1' after period*5;
clk <= not(clk) after 500 ns;
   input <= "00000101",                -- A = 5
        "00001001" after 10 * period,   -- A = 9
        "00010001" after 20 * period,   -- A = 17
        "10010001" after 30 * period,   -- A = 145
        "00000010" after 40 * period,   -- A = 148. 2
        "11010101" after 50 * period,   -- A = 213
        "00100011" after 60 * period,   -- A = 35
        "11110010" after 70 * period,   -- A = 242
        "00110001" after 80 * period,   -- A = 49
        "01010101" after 90 * period;   -- A = 85  

--   component ALU
--   port ( A          : in  std_logic_vector(7 downto 0);
--          B          : in  std_logic_vector(7 downto 0);
--          FN         : in  std_logic_vector(3 downto 0);
--          result     : out std_logic_vector(7 downto 0);
--          overflow   : out std_logic;
--          sign       : out std_logic
--        );
--   end component;

--   signal A          : std_logic_vector(7 downto 0);
--   signal B          : std_logic_vector(7 downto 0);
--   signal FN         : std_logic_vector(3 downto 0);
--   signal result     : std_logic_vector(7 downto 0);
--   signal overflow   : std_logic;
--   signal sign       : std_logic;
   
--   constant period   : time := 25 ns;
   
--   -- binary2BCD
--   signal bits_in : std_logic_vector(7 downto 0);
--   signal bits_out : std_logic_vector(9 downto 0);
 
--   component binary2BCD is
--      generic ( WIDTH : integer := 8   -- 8 bit binary to BCD
--              );
--      port ( binary_in : in  std_logic_vector(WIDTH-1 downto 0);  -- binary input width
--             BCD_out   : out std_logic_vector(9 downto 0)        -- BCD output. Bit 0-3: represent 10^0. Bit 4-7: 10^1. Bit 8-9: 10^2. 
--           );
--   end component;
   

--begin  -- structural
   
--   DUT: ALU
--   port map ( A         => A,
--              B         => B,
--              FN        => FN,
--              result    => result,
--              sign      => sign,
--              overflow  => overflow
--            );
   
--   -- *************************
--   -- User test data pattern
--   -- *************************
   
--   A <= "00000101",                    -- A = 5
--        "00001001" after 1 * period,   -- A = 9
--        "00010001" after 2 * period,   -- A = 17
--        "10010001" after 3 * period,   -- A = 145
--        "00000010" after 4 * period,   -- A = 148. 2
--        "11010101" after 5 * period,   -- A = 213
--        "00100011" after 6 * period,   -- A = 35
--        "11110010" after 7 * period,   -- A = 242
--        "00110001" after 8 * period,   -- A = 49
--        "01010101" after 9 * period;   -- A = 85
  
--   B <= "00000011",                    -- B = 3
--        "00000011" after 1 * period,   -- B = 3
--        "10010001" after 2 * period,   -- B = 145
--        "01111100" after 3 * period,   -- B = 124
--        "11111001" after 4 * period,   -- B = 249
--        "01101001" after 5 * period,   -- B = 105
--        "01100011" after 6 * period,   -- B = 35
--        "01101000" after 7 * period,   -- B = 104
--        "00101101" after 8 * period,   -- B = 45
--        "10100100" after 9 * period;   -- B = 36. Changed
     
--   FN <= "0000",                              -- Pass A
--         "0001" after 1 * period,             -- Pass B
--         "0000" after 2 * period,             -- Pass A
--         "0001" after 3 * period,             -- Pass B
--         "0010" after 4 * period,             -- Pass unsigned A + B
--         "0011" after 5 * period,             -- Pass unsigned A - B  
--         "0011" after 6 * period,             -- Pass unsigned A - B
--         "0010" after 7 * period,             -- Pass unsigned A + B
--         "0011" after 8 * period,             -- Pass unsigned A - B
--         "0100" after 9 * period,             -- Pass unsigned max(A, B)
--         "1010" after 10 * period,            -- Pass signed A + B
--         "1011" after 11 * period,            -- Pass signed A - B
--         "1100" after 12 * period,            -- Pass signed max(A, B)
--         "1111" after 13 * period;            -- Invalid input command

--   bits_in <= "00000000",                     -- 0
--         "00000001" after 1 * period,         -- 1
--         "00000010" after 2 * period,         -- 2
--         "00101011" after 3 * period,         -- 43
--         "01011111" after 4 * period,         -- 95
--         "10111010" after 5 * period,         -- 186
--         "11110111" after 6 * period,         -- 247
--         "11111111" after 7 * period;         -- 255
        
----     bits_in <= bits_vector;   
----        for I in 1 to 255 loop
----            bits_in <= std_logic_vector(unsigned(bits_vector) + 1);
----            wait for period;
----        end loop;
        
--   DUT2: binary2BCD
--   port map ( binary_in         => bits_in,
--              BCD_out           => bits_out
--            );








   -- to provide a clean signal out of a bouncy one coming from the push button
   -- input(b_Enter) comes from the pushbutton; output(Enter) goes to the FSM 

--   debouncer1: debouncer -- To get the debounced sign signal (a signal that is stable when you press down the button)
--   port map ( clk          => clk,
--              reset        => reset,
--              button_in    => b_Enter, -- Inputs the enter button from the ALU_top to debounce it.
--              button_out   => Enter -- Gets the bounced enter press from the debouncer that goes to the ALU_ctrl. 
--            );
--    debouncer2: debouncer -- To get the debounced sign signal (a signal that is stable when you press down the button)
--    port map ( clk          => clk,
--               reset        => reset,
--               button_in    => b_Sign, -- Inputs the sign button unbounced.
--               button_out   => Sign -- Outputs signal sign debounced. To be used.
--             );
    
   ALU_ctrl1: ALU_ctrl
   port map ( clk          => clk,
              reset        => reset,
              enter        => Enter, -- Inputs the debounced enter signal from debouncer 1
              sign         => Sign,
              FN           => FN, -- Gets the FN output from the ALU controller
              RegCtrl      => RegCtrl -- Gets the RegCtrl output from the the ALU controller, that will go to the RegCtrl
            );
   RegUpdate1: regUpdate
   port map ( clk          =>  clk,
              reset        =>  reset,
              RegCtrl      =>  RegCtrl, -- Inputs the RegCtrl value output from ALU_ctrl
              input        =>  input, -- Takes in the input from the top of the controller. 
              A            =>  A, -- Gets the A output from the RegUpdate that goes to the ALU
              B            =>  B -- Gets the B output from the RegUpdate that goes to the ALU                                 
     );
   ALU1: ALU  
   port map ( A            =>  A, -- Takes the A output from regUpdate into ALU
              B            =>  B, -- Takes the B output from from regUpdate into ALU
              FN           =>  FN, -- Takes the FN output from ALU_ctrl into ALU
              result       => binary_in,  -- Gets the result/binary_in output from from the ALU, that goes to the binary2BCD 
              overflow     =>  overflow,  -- Gets the overflow that says 1= overflow, 0 = no overflow, output from from the ALU, that goes to the 7SegDriver  that will display it 
              sign         =>  sign2  -- Gets the sign that says 1= negative, 0 = positive, output from from the ALU, that goes to the 7SegDriver  that will display it                               
       ); 
       
     
    binary2BCD1: binary2BCD
    port map ( binary_in => binary_in, -- Takes the binary_in output from ALU into binary2BCD
           BCD_out   => BCD_out -- Gets the BCD_out (binary bits seperated so that for example number 123 is divided into 3 numbers: 1 (bit 9-8),2 (bit 7-4) and 3 (bit 0-3)) output from binary2BCD that goes to the 7segdriver       
         );
  sevenseg1: seven_seg_driver
  port map ( clk           =>  clk,
             reset         =>  reset,
             BCD_digit     =>  BCD_out, -- Takes the BCD_out output from the binary2BCD. 
             sign          =>  sign2, -- Takes the sign output from the ALU. (1 = display negative, 0 = display positive)
             overflow      =>  overflow, -- Takes the overflow output from the ALU (1 = overflow, 0 = no overflow)
             DIGIT_ANODE   =>  anode,   -- DIGIT_ANODE outputs to anode that is an output in ALU_top
             SEGMENT       =>  seven_seg -- SEGMENT outputs to seven_seg that is an output in ALU_top              
             );       





end structural;
