library ieee;
use ieee.std_logic_1164.all;
entity ex1 is 
    port (A,B : in STD_LOGIC;
            Y : out STD_LOGIC);
end ex1;

architecture ex1_arch of ex1 is 
begin
    Y <= not(A and B) or (A) or (A and not(B));
end ex1_arch;
