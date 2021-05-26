library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv_if is
	Port( clk 			: in std_logic;
			rst 			: in std_logic;
			ce				: in std_logic;
			brAddr 		: in std_logic_vector(31 downto 0);
			selPCSrc 	: in std_logic;
			instruction : out std_logic_vector(31 downto 0);
			PC  			: out std_logic_vector(31 downto 0);
			PCPlus4 		: out std_logic_vector(31 downto 0)
		);
end riscv_if;


architecture structural of riscv_if is

component IM is
   Port (PC          : in  std_logic_vector(31 downto 0);
			ce : in std_logic;
         instruction : out std_logic_vector(31 downto 0)
        );
end component;

component CB32CLEIncValue is
  Port (clk        			: in  std_logic;
        rst      			: in  std_logic;
        ce         			: in  std_logic;
        ldDat    			: in std_logic_vector(31 downto 0);
        ld              	: in std_logic;
		incValue      		: in std_logic_vector(31 downto 0);
        count      			: out std_logic_vector(31 downto 0);
		CSPlusIncValue	    : out std_logic_vector(31 downto 0)
		);
end component;

signal incValue : std_logic_vector(31 downto 0) := X"00000004";
signal intPC    : std_logic_vector(31 downto 0);

begin

IM_i : IM port map (PC => intPC, ce => ce, instruction => instruction);

PSSU_i : CB32CLEIncValue port map (clk => clk, rst => rst, ce => ce, ld => selPCSrc, 
																ldDat => brAddr, incValue => incValue, count => intPC, CSPlusIncValue => PCPlus4);
																
PC_i : PC <= intPC;
																
end structural;