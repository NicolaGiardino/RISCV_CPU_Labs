library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity WB is
	Port( selDFrM	: in std_logic_vector(2 downto 0);
			selWBD	: in std_logic_vector(1 downto 0);
			DFrM		: in std_logic_vector(31 downto 0);
			ALUOut 	: in std_logic_vector(31 downto 0);
			PCPlus4	: in std_logic_vector(31 downto 0);
			WBDat		: out std_logic_vector(31 downto 0)
			);
end WB;

architecture combinational of Wb is

signal MToWB	: std_logic_vector(31 downto 0);

begin

selLdSlice_i : process(selDFrM, DFrM)
begin
	case selDFrM is
		when "000" =>
			MToWB <= DFrM;
		when "001" =>
			MToWB <= X"ffff" & DFrM(15 downto 0);
		when "010" =>
			MToWB <= X"ffffff" & DFrM(7 downto 0);
		when "011" =>
			MToWB <= X"0000" & DFrM(15 downto 0);
		when "100" =>
			MToWB <= X"000000" & DFrM(7 downto 0);
		when others =>
			MToWB <= (others => '0');
	end case;
end process;

selWB_i: process(selWBD, MToWB, ALUOut, PCPlus4)
begin
	WBDat <= ALUOut;
	if selWBD = "01" then
		WBDat <= MToWB;
	elsif selWBD = "10" then
		WBDat <= PCPlus4;
	end if;
end process;

end combinational;