-- Description: Instruction Memory IM 
-- Engineer: Fearghal Morgan, Joseph Clancy, Arthur Beretta
-- National University of Ireland, Galway (NUI Galway)
--
-- 64 x 32-bit memory array 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_vicilogic_Package.all;

entity IM is
   Port (PC          : in  std_logic_vector(31 downto 0);
			ce				: in std_logic;
         instruction : out std_logic_vector(31 downto 0)
        );
end IM;

architecture comb of IM is
signal IMAddrSlice : std_logic_vector(5 downto 0);

--Refer to 
-- addi_instructions.s program https://www.vicilogic.com/static/ext/RISCV/programExamples/addi_Instructions/addi_instructions.s
-- vicilogic RISC-V course lesson https://www.vicilogic.com/vicilearn/run_step/?s_id=1445  
-- Course References section https://www.vicilogic.com/vicilearn/run_step/?s_id=707, reference 9 (1.a.ii) 
-- Simulation supports up to 64 instructions 

--signal IMArray : array64x32 := Storre/Load from perip
-- (X"000107b7", X"0fffe537", X"00c55513", X"00a7a223", X"00400513", X"00a7a023", X"00300513", X"00a7a023", 
--  X"0087a583", X"0087a583", X"0087a583", X"00100513", X"00a7a023", X"00150513", X"00008067", X"00000000",  
--  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",  
--  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",  
--  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",  
--  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",  
--  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",  
--  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000"); 

-- Function example
signal IMArray : array64x32 :=
 (X"10000113", X"ff010113", X"00c000ef", X"01010113", X"0000006f", X"00112023", X"00410113", X"00158593", 
  X"010000ef", X"ffc10113", X"00012083", X"00008067", X"00258593", X"00008067", X"00000000", X"00000000",  
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",  
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",  
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",  
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",  
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",  
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");



begin

IMAddrSlice <= PC(7 downto 2);
instruction <= IMArray(to_integer(unsigned(IMAddrSlice))); -- combinational read from memory  

end comb;