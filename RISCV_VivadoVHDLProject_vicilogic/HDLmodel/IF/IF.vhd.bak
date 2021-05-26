-- Engineer: Fearghal Morgan
-- National University of Ireland Galway
-- 
-- Module Name: RISCV_IF
-- Description: Instruction Fetch stage
-- Includes 
--   1. PCCU Program Counter Control Unit
--   2. IM Instruction Memory array (read only)

-- Signal dictionary
--  clk               system clock strobe. low-to-high active edge
--  rst               asynchronous system reset, asserted high
--  ce         		  chip enable
--  PC(31:0)          instruction byte address  
--  instruction(31:0) instruction memory read data (combinational). 
--  brAdd   		  branch address 
--  selPCSrc          assert to select PC = branch address 
--	PCPlus4 		  PC byte address increment value  
--
-- structurally connects IM and PCCU components
-- Completed

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RISCV_IF is
  Port (clk        			: in  std_logic;
        rst      			: in  std_logic;
        ce         			: in  std_logic;
        brAdd   			: in  std_logic_vector(31 downto 0);
        selPCSrc        	: in  std_logic;
		PCPlus4 			: out std_logic_vector(31 downto 0);
		instruction         : out std_logic_vector(31 downto 0);
        PC                  : out std_logic_vector(31 downto 0)
		);
end RISCV_IF;

architecture struct of RISCV_IF is
signal intPC      : std_logic_vector(31 downto 0);
signal PCIncValue : std_logic_vector(31 downto 0);

component IM is
Port (PC :          in std_logic_vector(31 downto 0);
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

begin 

PCIncValue <= X"00000004";
PCCU_i: CB32CLEIncValue port map
       (clk        			 => clk,        		
        rst      			 => rst,      		
        ce         			 => ce,        		
        ldDat    			 => brAdd,    		
        ld              	 => selPCSrc,            
		incValue      		 => PCIncValue,      
        count      			 => intPC,      		
		CSPlusIncValue	     => PCPlus4
		);

IM_i: IM port map 
     (PC          => intPC,
      instruction => instruction
	  );
asgnPC_i: PC <= intPC;

end struct;