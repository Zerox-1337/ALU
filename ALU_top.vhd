library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALU_components_pack.all;

entity ALU_top is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          b_Enter    : in  std_logic;
          b_Sign     : in  std_logic;
          input      : in  std_logic_vector(7 downto 0);
          seven_seg  : out std_logic_vector(6 downto 0);
          anode      : out std_logic_vector(3 downto 0)
        );
end ALU_top;

architecture structural of ALU_top is

   -- SIGNAL DEFINITIONS
   signal Enter : std_logic; -- Where we store the debounced (stable) from the debouncer signal.
   signal Sign : std_logic; -- Where we store the debounce (stable) from the debouncer signal. This sign is not the same as sign2. Sign1: 0 = unsigned. 1 = signed.
   signal FN : std_logic_vector(3 downto 0); -- Where the FN output from keyboard ctrl goes to.
   signal RegCtrl : std_logic_vector(1 downto 0); -- Where the RegCtrl (10 updates the A, 01 updates B) output from the keyboard goes to.
   signal A : std_logic_vector (7 downto 0); -- Where the A (our first number in the register) output from the regUpdate goes. 
   signal B : std_logic_vector (7 downto 0); -- Where the B (our second number in the register), output from the regUpdate goes.    
   signal binary_in : std_logic_vector(7 downto 0); -- Where the result (the result from our mod 3, sub or add), output from the ALU goes.
   signal overflow : std_logic; -- Where the overflow (from our mod 3, sub or add), output from the ALU goes. 1 = overflow. 0 = no overflow.  
   signal Sign2 : std_logic; -- Where the sign (from our mod 3, sub or add), output from the ALU goes. 1= negative. 0 = positiv e
   signal BCD_out : std_logic_vector(9 downto 0); -- BCD output from the binary2BCD that goes to the 7segdriver as BCD_digit. Bit 0-3: represent 10^0. Bit 4-7: 10^1. Bit 8-9: 10^2. 
   
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
begin

   -- to provide a clean signal out of a bouncy one coming from the push button
   -- input(b_Enter) comes from the pushbutton; output(Enter) goes to the FSM 
   debouncer1: debouncer -- To get the debounced sign signal (a signal that is stable when you press down the button)
   port map ( clk          => clk,
              reset        => reset,
              button_in    => b_Enter, -- Inputs the enter button from the ALU_top to debounce it.
              button_out   => Enter -- Gets the bounced enter press from the debouncer that goes to the ALU_ctrl. 
            );
    debouncer2: debouncer -- To get the debounced sign signal (a signal that is stable when you press down the button)
    port map ( clk          => clk,
               reset        => reset,
               button_in    => b_Sign, -- Inputs the sign button unbounced.
               button_out   => Sign -- Outputs signal sign debounced. To be used.
             );
    
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

 
   -- ****************************
   -- DEVELOPE THE STRUCTURE OF ALU_TOP HERE
   -- ****************************

end structural;
