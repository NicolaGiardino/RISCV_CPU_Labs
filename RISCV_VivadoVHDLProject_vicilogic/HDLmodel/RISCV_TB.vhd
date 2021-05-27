-- RISCV_TB

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.RISCV_vicilogic_Package.all;

ENTITY RISCV_TB IS END RISCV_TB;

ARCHITECTURE behavior OF RISCV_TB IS 

component RISCV is
   Port (clk  : in std_logic;       
         rst  : in std_logic;
			ce   : in std_logic;
		 useDebugInstruction : in std_logic;
		 debugInstruction : in std_logic_vector(31 downto 0)
        );
end component; 

SIGNAL clk : std_logic := '0';
SIGNAL rst : std_logic := '1';
signal ce  : std_logic;

signal useDebugInstruction : std_logic;
signal debugInstruction : std_logic_vector(31 downto 0);

signal testNo      : integer;
constant clkPeriod : time := 20 ns;	-- 50MHz clk
signal endOfSim    : boolean := false;

begin 

-- Instantiate the Unit Under Test (UUT)
uut: RISCV port map
   (clk => clk,
    rst => rst,
	 ce => ce,
	useDebugInstruction => useDebugInstruction,
	debugInstruction => debugInstruction
   );
 
clkStim:	process (clk)
begin
 if (endOfSim = false) then 
   clk <= not clk after clkPeriod/2;
 end if; 
end process;

STIM_i: PROCESS  
begin 
 rst <= '0';
 useDebugInstruction <= '0';
 debugInstruction    <= X"fff54513"; -- xori x10, x10, -1, invert x10

 testNo <= 0;
 rst <= '1';
 wait for 1.7*clkPeriod; -- simulate to just after clk rising edge
 rst <= '0';
 ce <= '1'; 
 testNo <= 1;
 useDebugInstruction <= '0';
 wait for clkPeriod; 
 -- o/p msg to simulation  transcript
 report "RISC-V simulation start"; 

 wait for 10*clkPeriod; 	 

 report "simulation done";   
 endOfSim <= true;
 wait; -- will wait forever
 END PROCESS;

end behavior;
