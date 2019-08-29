library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_ctrl is
   port ( clk     : in  std_logic;
          reset   : in  std_logic;
          enter   : in  std_logic;
          sign    : in  std_logic;
          FN      : out std_logic_vector (3 downto 0);   -- ALU functions
          RegCtrl : out std_logic_vector (1 downto 0) --Register update control bits
        );
end ALU_ctrl;

architecture behavioral of ALU_ctrl is
type state_type1 is (A, A_hold, B, B_hold, AaddB, AaddB_hold, AsubB, AsubB_hold, Amod3, Amod3_hold);
type state_type2 is (sign1, sign2, sign1_hold, sign2_hold);
signal sigstate, sigstate_next : state_type2;
signal state, next_state : state_type1;
signal sign_reg : std_logic;
begin
seq: process(clk, reset)
    begin
        if (reset = '0') then
            state <= A;
            sigstate <= sign1;
        elsif(clk'event and clk = '1') then
            state <= next_state;
            sigstate <= sigstate_next; -- Next sign state.
        end if;
    
    end process;
comb1: process(sign, sigstate) -- State machine for sign. If you press the button once you got signed and if you press it twice you got unsigned.
begin
    case(sigstate) is
        when sign1 =>
            if(sign = '1') then
                sign_reg <= '1';
                sigstate_next <= sign1_hold;
            else
                sign_reg <= '0';
                sigstate_next <= sign1; 
            end if;
        when sign1_hold => -- Hold button when unsigned.
            sign_reg <= '1';
            if(sign = '1') then
                sigstate_next <= sign1_hold;
            else
                sigstate_next <=sign2;
            end if;        
        when sign2 =>
            if(sign = '1') then
                sign_reg <= '0';
                sigstate_next <= sign2_hold;
            else
                sign_reg <= '1';
                sigstate_next <= sign2;
            end if;
        when sign2_hold => -- Hold button when signed
            sign_reg <= '0';
            if(sign = '1') then
                sigstate_next <= sign2_hold;
            else
                sigstate_next <= sign1;
            end if;
    end case;
end process;   
comb2: process(state, enter, sign_reg)
    begin
    RegCtrl <= "00";

    case (state) is 
        when A =>
            FN <= "0000"; -- We will display the values even if we don't press enter, but only save them when we press enter.
            RegCtrl <= "10";
            if (enter = '1') then               
                next_state <= A_hold;
            else
                next_state <= A;
            end if;
        
        when A_hold =>
            FN <= "0000"; -- We will display the values even if we don't press enter, but only save them when we press enter.
            if (enter = '1') then
                next_state <= A_hold;
             else
                next_state <= B;
             end if;
        when B =>
            FN <= "0001"; -- We will display the values even if we don't press enter, but only save them when we press enter.
            RegCtrl <= "01"; -- After FN is sent to the ALU you tell regctrl to save the input value. 
            if(enter = '1') then
                
                next_state <= B_hold;
            else
                next_state <= B;
            end if;
        
        when B_hold =>
            FN <= "0001"; -- We will display the values even if we don't press enter, but only save them when we press enter.
            if (enter = '1') then
                next_state <= B_hold;
            else
                next_state <= AaddB;
            end if;
        when AaddB => -- A + B
            if (sign_reg = '1') then
                FN <= "1010";
                if (enter = '1') then
                    next_state <= AaddB_hold;
                else
                    next_state <= AaddB;
                end if;
            else
                FN <= "0010";
                if (enter = '1') then
                    next_state <= AaddB_hold;
                else
                    next_state <= AaddB;
                end if;
            end if;
        when AaddB_hold =>
            if (sign_reg = '1') then
                FN <= "1010";
                if (enter = '1') then
                    next_state <= AaddB_hold;
                else
                    next_state <= AsubB;
                end if;
            else
                FN <= "0010";
                if (enter = '1') then
                    next_state <= AaddB_hold;
                else
                    next_state <= AsubB;
                end if;
        end if;            
        when AsubB => -- A - B
            --if (sign_reg = '1') then
                FN <= (sign_reg & "011");
                --FN <= "1011";
                if (enter = '1') then
                    next_state <= AsubB_hold;
                else
                    next_state <= AsubB;
                end if;
           -- else
             --   FN <= "0011";
--                if (enter = '1') then
--                    next_state <= AsubB_hold;
--                else
--                    next_state <= AsubB;
--                end if;
           -- end if;        
        when AsubB_hold =>
--            if (sign_reg = '1') then
--                FN <= "1011";
                FN <= (sign_reg & "011");
                if (enter = '1') then
                    next_state <= AsubB_hold;
                else
                    next_state <= Amod3;
                end if;
--            else
--                FN <= "0011";
--                if (enter = '1') then
--                    next_state <= AsubB_hold;
--                else
--                    next_state <= Amod3;
--                end if;
--            end if;        
        
        when Amod3 => -- A mod 3.
            if(sign_reg = '1') then
                FN <= "1100";
                if (enter = '1') then
                    next_state <= Amod3_hold;
                else
                    next_state <= Amod3;
                end if;    
            else
                FN <= "0100";
                if(enter = '1') then
                    next_state <= Amod3_hold;
                else
                    next_state <= Amod3;
                end if;
            end if;
        when Amod3_hold => 
            if(sign_reg = '1') then
                FN <= "1100";
                if (enter = '1') then
                    next_state <= Amod3_hold;
                else
                    next_state <= AaddB;
                end if;    
            else
                FN <= "0100";
                if(enter = '1') then
                    next_state <= Amod3_hold;
                else
                    next_state <= AaddB;
                end if;
            end if;            

    end case;
    
    end process;

end behavioral;
