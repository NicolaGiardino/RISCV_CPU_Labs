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

signal IMArray : array64x32 :=
 (X"54c00113", X"00111193", X"fedcb237", X"003202b3", X"00800313", X"00532223", X"00435383", X"4063d433", 
  X"0bb42493", X"00049463", X"fc000ce3", X"008000ef", X"0000006f", X"00150513", X"00008067", X"00000000",  
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