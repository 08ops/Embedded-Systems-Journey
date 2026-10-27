library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 4-bit ALU
--
-- Opcode table:
--   000  ADD   result = a + b
--   001  SUB   result = a - b
--   010  AND   result = a and b
--   011  OR    result = a or b
--   100  XOR   result = a xor b
--   101  SHL   result = a shifted left by 1  (carry = bit shifted out)
--   110  SHR   result = a shifted right by 1 (carry = bit shifted out)
--   111  SLT   result = 1 if a < b (unsigned), else 0
--
-- zero     = '1' when result = "0000"
-- carry    = carry-out (ADD) / borrow (SUB) / shifted-out bit (SHL, SHR); '0' otherwise
-- overflow = signed overflow; only meaningful for ADD and SUB

entity alu4 is
  port (
    a        : in  std_logic_vector(3 downto 0);
    b        : in  std_logic_vector(3 downto 0);
    opcode   : in  std_logic_vector(2 downto 0); --so this was used to select the operrattion
    result   : out std_logic_vector(3 downto 0);
    zero     : out std_logic;
    carry    : out std_logic; --this helped in adddition
    overflow : out std_logic
  );
end entity;

architecture rtl of alu4 is
begin
  process(a, b, opcode)
    variable ua, ub : unsigned(3 downto 0);  -- a, b reinterpreted as unsigned numbers
    variable ext    : unsigned(4 downto 0);  -- one extra bit, to catch a carry/borrow out
    variable res    : std_logic_vector(3 downto 0);
    variable c, v   : std_logic;
  begin
    ua := unsigned(a);
    ub := unsigned(b);

    -- Defaults. Every branch below can override these. Keeping a default
    -- for every variable means nothing is ever left unassigned, which is
    -- what keeps this a clean combinational block with no latches.
    c   := '0';
    v   := '0';
    res := (others => '0');

    case opcode is
      when "000" =>  -- ADD
        -- TODO: add ua and ub with one extra bit of headroom, e.g.
        ext := ('0' & ua) + ('0' & ub);
        res := std_logic_vector(ext(3 downto 0));
        c  := ext(4);
        if (a(3) = b(3)) and (res(3) /= a(3)) then
          v := '1';
        end if;
        --   ext := ('0' & ua) + ('0' & ub);
        -- then take the bottom 4 bits as res, and ext's top bit as c.
        --
        -- TODO: overflow happens on ADD when a and b have the SAME sign
        -- bit (a(3), b(3)) but the result's sign bit (res(3)) differs
        -- from theirs.

      when "001" =>  -- SUB (a - b)
        -- TODO: same idea as ADD, but subtract instead:
        --   ext := ('0' & ua) - ('0' & ub);
        ext := ('0' & ua) - ('0' & ub);
        res := std_logic_vector(ext(3 downto 0));
        c := ext(4);
        if (a(3) /= b(3)) and (res(3) /= a(3)) then
          v := '1';
        end if;
        -- ext's top bit is now a borrow flag: it's '1' when ua < ub.
        --
        -- TODO: overflow happens on SUB when a and b have DIFFERENT sign
        -- bits, and the result's sign bit differs from a's.

      when "010" =>  -- AND
        -- TODO: res := a and b;
        res := a and b;



      when "011" =>  -- OR
        -- TODO
        res := a or b;

      when "100" =>  -- XOR
        -- TODO
        res := a xor b;

      when "101" =>  -- SHL (shift ua left by 1; the bit that falls off the
                      -- top becomes carry; a 0 comes in at the bottom)
        c := a(3);
        res := a(2 downto 0) & '0';
        -- TODO: c := ua(3);
        -- TODO: res := std_logic_vector(ua(2 downto 0) & '0');

      when "110" =>  -- SHR (shift ua right by 1; the bit that falls off the
      c  := a(0);
      res := '0' & a(3 downto 1);
                      -- bottom becomes carry; a 0 comes in at the top)
        c  := a(0);
        res := '0' & a(3 downto 1);
        -- TODO

      when "111" =>  -- SLT (unsigned a < b: result is 1 or 0)
        -- TODO: an if/else on ua < ub, setting res to "0001" or "0000"
        if ua < ub then
          res := "0001";
        else
          res := "0000";
        end if;

      when others =>
        res := (others => '0');
    end case;

    result   <= res;
    carry    <= c;
    overflow <= v;
    zero     <= '1' when res = "0000" else '0';
  end process;
end architecture;
