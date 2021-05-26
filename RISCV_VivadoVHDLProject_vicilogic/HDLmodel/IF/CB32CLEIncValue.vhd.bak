-- Engineer: Fearghal Morgan 
-- National University of Ireland Galway
-- 
-- Module Name: CSPlusIncValue
-- Description: loadable 32-bit up counter, with chip enable, asynchronous reset,
--              and increment value incValue (incValue also included as output signal)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CB32CLEIncValue is
  Port (clk        			: in  std_logic;
        rst      			: in  std_logic;
        ce         			: in  std_logic;
        ldDat    			: in std_logic_vector(31 downto 0);
        ld              	: in std_logic;
		incValue      		: in std_logic_vector(31 downto 0);
        count      			: out std_logic_vector(31 downto 0);
		CSPlusIncValue	    : out std_logic_vector(31 downto 0)
		);
end CB32CLEIncValue;

architecture RTL of CB32CLEIncValue is
signal NS                : std_logic_vector(31 downto 0); -- next state
signal CS                : std_logic_vector(31 downto 0); -- current state
signal intCSPlusIncValue : std_logic_vector(31 downto 0);

begin 

NSDecode_i: process(ld, ldDat, intCSPlusIncValue) 
begin
    NS <= intCSPlusIncValue; -- default: select incremented count value   
	if ld = '1' then 
		NS <= ldDat;         -- load counter 
	end if ;
end process;

stateReg_i: process(clk, rst) 
begin
    if rst = '1' then
        CS <= (others => '0');
    elsif rising_edge(clk) then
        if ce = '1' then          
          CS <= NS;         
        end if;
    end if;
end process;  

asgnCount_i:             count             <= CS;                                                     
asgnintCSPlusIncValue_i: intCSPlusIncValue <= std_logic_vector( unsigned(CS) + unsigned(incValue) ); 
asgnCSPlusIncValue_i:    CSPlusIncValue    <= intCSPlusIncValue;

end RTL;