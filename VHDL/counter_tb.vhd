library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Testbench: no ports. It drives the counter and checks its output.
entity counter_tb is
end entity;

architecture sim of counter_tb is
  signal clk  : std_logic := '0';
  signal rst  : std_logic := '1';
  signal en   : std_logic := '0';
  signal q    : std_logic_vector(3 downto 0);
  signal done : boolean := false;
begin

  -- Device under test
  dut : entity work.counter
    port map (clk => clk, rst => rst, en => en, q => q);

  -- 100 MHz clock (10 ns period); stops when the test is done
  clk_gen : process
  begin
    while not done loop
      clk <= '0'; wait for 5 ns;
      clk <= '1'; wait for 5 ns;
    end loop;
    wait;
  end process;

  -- Stimulus and checks
  stim : process
  begin
    -- Hold reset for a couple of clocks
    rst <= '1'; en <= '0';
    wait for 20 ns;
    rst <= '0';
    wait until rising_edge(clk);

    -- Enabled: it should count 1, 2, ... 15, wrap to 0, then 1, 2, ...
    en <= '1';
    for i in 1 to 20 loop
      wait until rising_edge(clk);
      wait for 1 ns;  -- let the output settle before checking
      assert unsigned(q) = to_unsigned(i mod 16, 4)
        report "Count mismatch at step " & integer'image(i)
        severity failure;
    end loop;

    -- Disabled: it should hold its value (20 mod 16 = 4)
    en <= '0';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait for 1 ns;
    assert unsigned(q) = 4
      report "Count changed while disabled"
      severity failure;

    -- Reset: it should go back to 0
    rst <= '1';
    wait until rising_edge(clk);
    wait for 1 ns;
    assert unsigned(q) = 0
      report "Reset did not clear the counter"
      severity failure;

    report "PASS: all counter tests passed";
    done <= true;
    wait;
  end process;

end architecture;
