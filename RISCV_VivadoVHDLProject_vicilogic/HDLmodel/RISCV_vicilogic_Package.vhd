-- Description : RISCV_vicilogic_Package 
-- Engineer: Fearghal Morgan
-- viciLogic 

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package RISCV_vicilogic_Package is

type array64x32    is array (0 to 63) of std_logic_vector(31 downto 0);
type RISCV_regType is array (31 downto 0) of std_logic_vector(31 downto 0);

end RISCV_vicilogic_Package;

package body RISCV_vicilogic_Package is
 
end RISCV_vicilogic_Package;