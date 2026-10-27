
    -- Instantiate the circuit_model entity
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity circuit_model is
    port (
        CLK : in  std_logic;
        LDA : in  std_logic;
        LDB : in  std_logic;
        RD  : in  std_logic;
        S0  : in  std_logic;
        S1  : in  std_logic;
        X   : in  std_logic_vector(7 downto 0);
        Y   : in  std_logic_vector(7 downto 0);
        RA  : out std_logic_vector(7 downto 0);
        RB  : out std_logic_vector(7 downto 0)
    );
end entity circuit_model;

architecture Behavioral of circuit_model is
    -- Internal signals for register outputs
    signal reg_a_q : std_logic_vector(7 downto 0) := (others => '0');
    signal reg_b_q : std_logic_vector(7 downto 0) := (others => '0');

    -- Multiplexer outputs
    signal mux_b_out : std_logic_vector(7 downto 0);
    signal mux_a_out : std_logic_vector(7 downto 0);

    -- Load signals
    signal ld_b : std_logic;
    signal ld_a : std_logic;

begin
    -- 2:1 Multiplexer for REGB
    mux_b_out <= X when (S1 = '1') else Y;

    -- 2:1 Multiplexer for REGA
    mux_a_out <= reg_b_q when (S0 = '1') else Y;

    -- Enable gating logic
    ld_b <= LDB and (not RD);
    ld_a <= LDA and RD;

    -- Falling-edge triggered registers
    process(CLK)
    begin
        if falling_edge(CLK) then
            if ld_b = '1' then
                reg_b_q <= mux_b_out;
            end if;

            if ld_a = '1' then
                reg_a_q <= mux_a_out;
            end if;
        end if;
    end process;

    -- Connect internal register values to outputs
    RA <= reg_a_q;
    RB <= reg_b_q;

end architecture Behavioral;