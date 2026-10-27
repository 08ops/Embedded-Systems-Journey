library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu4_tb is
end entity;

architecture sim of alu4_tb is

  signal a, b                  : std_logic_vector(3 downto 0);
  signal opcode                : std_logic_vector(2 downto 0);
  signal result                : std_logic_vector(3 downto 0);
  signal zero, carry, overflow : std_logic;

  -- Bundles one expected answer from the golden model.
  type alu_result_t is record
    res : integer range 0 to 15;
    z   : std_logic;
    c   : std_logic;
    v   : std_logic;
  end record;

  -- The golden model: computes the *expected* ALU answer using plain
  -- integer arithmetic and separate unsigned helpers, written independently
  -- from alu4.vhd's case statement. If both happen to agree on all 2048
  -- input combinations, that is strong evidence the design is correct.
  function golden_model(ai, bi, op : integer) return alu_result_t is
    variable r    : alu_result_t;
    variable ext  : integer;
    variable ua4, ub4, r4 : unsigned(3 downto 0);
    variable a_sign, b_sign, r_sign : std_logic;
  begin
    r.c := '0';
    r.v := '0';
    ua4 := to_unsigned(ai, 4);
    ub4 := to_unsigned(bi, 4);

    case op is
      when 0 =>  -- ADD
        ext   := ai + bi;
        r.res := ext mod 16;
        r.c   := '1' when ext > 15 else '0';
      when 1 =>  -- SUB
        ext   := ai - bi;
        r.res := ext mod 16;
        r.c   := '1' when ext < 0 else '0';
      when 2 =>  -- AND
        r4    := ua4 and ub4;
        r.res := to_integer(r4);
      when 3 =>  -- OR
        r4    := ua4 or ub4;
        r.res := to_integer(r4);
      when 4 =>  -- XOR
        r4    := ua4 xor ub4;
        r.res := to_integer(r4);
      when 5 =>  -- SHL (shift left by 1)
        r.c   := ua4(3);
        r4    := ua4(2 downto 0) & '0';
        r.res := to_integer(r4);
      when 6 =>  -- SHR (shift right by 1)
        r.c   := ua4(0);
        r4    := '0' & ua4(3 downto 1);
        r.res := to_integer(r4);
      when 7 =>  -- SLT (unsigned a < b)
        r.res := 1 when ai < bi else 0;
      when others =>
        r.res := 0;
    end case;

    -- Signed overflow only means something for ADD and SUB.
    if op = 0 or op = 1 then
      a_sign := '1' when ai >= 8 else '0';
      b_sign := '1' when bi >= 8 else '0';
      r_sign := '1' when r.res >= 8 else '0';
      if op = 0 then
        r.v := '1' when (a_sign = b_sign) and (r_sign /= a_sign) else '0';
      else
        r.v := '1' when (a_sign /= b_sign) and (r_sign /= a_sign) else '0';
      end if;
    end if;

    r.z := '1' when r.res = 0 else '0';
    return r;
  end function;

begin

  dut : entity work.alu4
    port map (
      a => a, b => b, opcode => opcode,
      result => result, zero => zero, carry => carry, overflow => overflow
    );

  stim : process
    variable exp    : alu_result_t;
    variable errors : integer := 0;
    variable tests  : integer := 0;
  begin
    for ai in 0 to 15 loop
      for bi in 0 to 15 loop
        for op in 0 to 7 loop
          a      <= std_logic_vector(to_unsigned(ai, 4));
          b      <= std_logic_vector(to_unsigned(bi, 4));
          opcode <= std_logic_vector(to_unsigned(op, 3));
          wait for 1 ns;  -- let the combinational logic settle

          exp   := golden_model(ai, bi, op);
          tests := tests + 1;

          if to_integer(unsigned(result)) /= exp.res
             or zero /= exp.z or carry /= exp.c or overflow /= exp.v then
            errors := errors + 1;
            report "MISMATCH a=" & integer'image(ai) &
                   " b=" & integer'image(bi) &
                   " op=" & integer'image(op) &
                   "  got: result=" & integer'image(to_integer(unsigned(result))) &
                   " z=" & std_logic'image(zero) &
                   " c=" & std_logic'image(carry) &
                   " v=" & std_logic'image(overflow) &
                   "  want: result=" & integer'image(exp.res) &
                   " z=" & std_logic'image(exp.z) &
                   " c=" & std_logic'image(exp.c) &
                   " v=" & std_logic'image(exp.v)
              severity error;
          end if;
        end loop;
      end loop;
    end loop;

    report integer'image(tests) & " tests run, " & integer'image(errors) & " failed.";
    if errors = 0 then
      report "PASS: ALU matches the golden model on all 2048 cases";
    else
      report "FAIL: " & integer'image(errors) & " mismatches - see above" severity failure;
    end if;
    wait;
  end process;

end architecture;
