-- Company: National University of Ireland Galway
-- Engineer: Fearghal Morgan
-- 
-- Module Name: RB Register Bank  
-- 32 x 32-bit register array x0-x31
-- Description: Register Bank Module for the RISC-V Processor
-- Synchronous write
-- Combinational read 

-- Signal dictionary
--  clk               system clock strobe. low-to-high active edge
--  rst               asynchronous system reset, asserted high
--  ce         		  chip enable
--  rs1(4:0) 	      source address 1 
--  rs2(4:0) 	      source address 2 
--  RWr 	          assertion enables synchronous write of WBDat to RB(rd) 
--  WBDat             writeback data 
--  rd(4:0) 	      destination register address 
--  rs1D(31:0) 	      source address 1 data = RB(rs1), combinational read 
--  rs2D(31:0) 	      source address 1 data = RB(rs1), combinational read 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_vicilogic_Package.ALL;

entity RB is
  Port (clk      : in  std_logic;
        rst      : in  std_logic;
        ce       : in  std_logic;
        rs1 	 : in  std_logic_vector(4 downto 0);
        rs2 	 : in  std_logic_vector(4 downto 0);
		RWr      : in  std_logic;
        WBDat  	 : in  std_logic_vector(31 downto 0);
        rd  	 : in  std_logic_vector(4 downto 0);
        rs1D     : out std_logic_vector(31 downto 0);
        rs2D     : out std_logic_vector(31 downto 0)
		);
end RB;

architecture RTL of RB is 

signal RBArray : RISCV_regType;
signal XX_CS      : RISCV_regType;
signal XX_NS      : RISCV_regType;

begin

NSDecode_i: process(XX_CS, RWr, rd, WBDat) -- register write next state decode
begin
    XX_NS <= XX_CS;
    if RWr = '1' and rd /= "00000" then -- RB(0), ie., x0 always = 0
        XX_NS(to_integer(unsigned(rd))) <= WBDat;
    end if;
end process;

stateReg_i: process(clk, rst) -- State register
begin
    if rst = '1' then
        XX_CS <= (others => (others => '0'));
    elsif rising_edge(clk) then
        if ce = '1' then
            XX_CS <= XX_NS;
        end if;
    end if;
end process;

-- x0 is alway 0 (in process NSDecode)
asgn_rs1D_i: rs1D <= XX_CS(to_integer(unsigned(rs1)));
asgn_rs2D_i: rs2D <= XX_CS(to_integer(unsigned(rs2)));

asgnRB_i: RBArray <= XX_CS;

end RTL;