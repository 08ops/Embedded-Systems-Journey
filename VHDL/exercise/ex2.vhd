--Provide a VHDL model of an 8-input AND gate using concurrent,
--conditional and selected signal assignment.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity And8 is
   Port ( A : in  STD_LOGIC_VECTOR(7 downto 0);
          F : out STD_LOGIC );
end And8;

architecture Concurrent of And8 is
begin
   F <= A(0) and A(1) and A(2) and A(3) and A(4) and A(5) and A(6) and A(7);
end Concurrent;
