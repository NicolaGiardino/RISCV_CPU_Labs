
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_vicilogic_Package.ALL;

entity RB is
	Port( clk 	: in std_logic;
			rst 	: in std_logic;
			rs1	: in std_logic_vector(4 downto 0);
			rs2	: in std_logic_vector(4 downto 0);
			RWr 	: in std_logic;
			WBDat	: in std_logic_vector(31 downto 0);
			rd		: in std_logic_vector(4 downto 0);
			rs1D	: out std_logic_vector(31 downto 0);
			rs2D	: out std_logic_vector(31 downto 0)
		);
end RB;

architecture rtl of RB is

signal Reg	: RISCV_regType := (others => (others => '0'));
signal NS	: RISCV_regType := (others => (others => '0'));
signal CS	: RISCV_regType := (others => (others => '0'));

begin

NSDecode_i : process(NS, RWr, rd, WBDat)
begin
    NS <= CS;
	if RWr = '1' then
	   if rd /= "0000" then
		  NS(to_integer(unsigned(rd))) <= WBDat;
	   end if;
	end if;
end process;

stateReg_i: process(clk, rst)
begin
if RWr = '1' then
	if rst = '1' then
		CS <= (others => ( others => '0'));
	elsif clk'event and clk = '1' then
		CS <= NS;
	end if;
end if;
end process;

asgnRB_i : Reg <= CS;

asgnRs1_i: rs1D <= Reg(to_integer(unsigned(rs1)));

asgnRs2_i: rs2D <= Reg(to_integer(unsigned(rs2)));

end RTL;