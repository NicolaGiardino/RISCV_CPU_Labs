----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.05.2021 23:10:07
-- Design Name: 
-- Module Name: CB16CLED - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CB16CLED is
    Port ( clk : in std_logic;
           rst : in std_logic;
           load  : in std_logic;
           ce   : in std_logic;
           up : in std_logic;
           loadData : in std_logic_vector(15 downto 0);
           count : out std_logic_vector(15 downto 0)
		);
end CB16CLED;

architecture rtl of CB16CLED is
signal NS, CS       : std_logic_vector(15 downto 0) := (others => '0');

begin

NSDecode_count_i: process(ce, up, load, CS, loadData)
begin
    NS <= CS;
    if load = '1' then
        NS <= loadData;
    elsif ce = '1' then
        if up = '1' then
            NS <= std_logic_vector(unsigned(CS) + 1);
        else
            NS <= std_logic_vector(unsigned(CS) - 1);
        end if;
    end if;
end process;

stateReg_count_i : process(clk, rst, NS)
begin
    if rst = '1' then 
        CS <= (others => '0');
    elsif rising_edge(clk) then
        CS <= NS;
    end if;
end process;

asgnCount_i : count <= CS;

end rtl;
