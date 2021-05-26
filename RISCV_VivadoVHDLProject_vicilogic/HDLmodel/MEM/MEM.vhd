-- Description: memory
-- Engineer: Fearghal Morgan, Joseph Clancy, Arthur Beretta
-- National University of Ireland, Galway (NUI Galway)
--
-- 64 x 32-bit memory array 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_vicilogic_Package.all;

entity MEM is
   Port (clk  : in std_logic;       
         rst  : in std_logic;
         MWr  : in std_logic;                      -- Memory write control (1 : write)
         MRd  : in std_logic;                      -- Memory read control  (0 : read)
         add  : in std_logic_vector(31 downto 0);  -- Address 
         DToM : in std_logic_vector(31 downto 0);  -- Data in 
         DFrM : out std_logic_vector(31 downto 0)  -- Data in 
        );
end MEM;

architecture RTL of MEM is
signal memArray     : array64x32;
signal memAddrSlice : std_logic_vector(5 downto 0);

begin

memAddrSlice <= add(7 downto 2);

-- write to memory array (accessing 32-bit data words)
synch_i : process(clk, rst)
begin
	if rst = '1' then
        memArray <= (others => X"00000000");
	elsif rising_edge(clk) then	
        if MWr = '1' then
           memArray(to_integer(unsigned(memAddrSlice))) <= DToM;
		end if;
    end if;
end process;

-- combinational read from memory  
DFrM_i : process(memAddrSlice, MRd, memArray)
begin
  DFrM <= (others => '0'); -- default
  if MRd = '1' then
       DFrM <= memArray(to_integer(unsigned(memAddrSlice)));
  end if;
end process;

end RTL;