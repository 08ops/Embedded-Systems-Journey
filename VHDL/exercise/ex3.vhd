library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LogicCircuit is
   Port ( A_1, A_2, B_1, B_2, D_1 : in  STD_LOGIC;
          E_out : out STD_LOGIC );
end LogicCircuit;

architecture IfModel of LogicCircuit is
begin
   process (A_1, A_2, B_1, B_2, D_1)
   begin
      if ((A_1 and A_2) = '1') or ((B_1 and B_2) = '1') or ((B_2 and (not D_1)) = '1') then
         E_out <= '1';
      else
         E_out <= '0';
      end if;
   end process;
end IfModel;
