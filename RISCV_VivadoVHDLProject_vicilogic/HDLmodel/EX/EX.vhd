library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_vicilogic_Package.ALL;

entity EX is
	Port( jalr 			: in std_logic;
			auipc 		: in std_logic;
			selALUBSrc 	: in std_logic;
			selALUOp		: in std_logic_vector(3 downto 0);
			selDToM		: in std_logic_vector(1 downto 0);
			rs1D 			: in std_logic_vector(31 downto 0);
			rs2D			: in std_logic_vector(31 downto 0);
			extImm		: in std_logic_vector(31 downto 0);
			PC				: in std_logic_vector(31 downto 0);
			ALUOut		: out std_logic_vector(31 downto 0);
			DToM			: out std_logic_vector(31 downto 0);
			brAddr		: out std_logic_vector(31 downto 0);
			branch 		: out std_logic
			);
end EX;
	
architecture combinational of EX is

component ALU is
	Port( A			: in  std_logic_vector(31 downto 0);
			B  		: in  std_logic_vector(31 downto 0);
			selALUOp : in  std_logic_vector(3 downto 0);
			branch 	: out std_logic;
			zero		: out std_logic;
			ALUOut	: out std_logic_vector(31 downto 0)
			);
end component;

signal A : std_logic_vector(31 downto 0);
signal B : std_logic_vector(31 downto 0);
signal zero : std_logic;

begin

ALU_i : ALU port map(A => A, B => B, selALUOp => selALUOp, branch => branch, zero => zero, AlUOut => ALUOut);

selA_i: process(PC, rs1D, auipc)
begin
	A <= rs1D;
	if auipc = '1' then
		A <= PC;
	end if;
end process;

selB_i: process(extImm, rs2D, selALUBSrc)
begin
	B <= extImm;
	if selALUBSrc = '1' then
		B <= rs2D;
	end if;
end process;

genBrAddr_i: process(PC, rs1D, jalr)
begin
	if jalr = '1' then
		brAddr <= std_logic_vector(unsigned(extImm) + unsigned(rs1D));
	else
		brAddr <= std_logic_vector(unsigned(extImm) + unsigned(PC));
	end if;
end process;

selStSlice_i: process(selDToM, rs2D)
begin
	case selDToM is
		when "00" =>
			DToM <= rs2D;
		when "01" =>
			DToM <= X"0000" & rs2D(15 downto 0);
		when "10" =>
			DToM <= X"000000" & rs2D(7 downto 0);
		when others =>
			DToM <= (others => '0');
	end case;
end process;

end combinational;