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
         inport : in std_logic_vector(15 downto 0);
         DFrM : out std_logic_vector(31 downto 0);  -- Data in 
         outport : out std_logic_vector(15 downto 0)
        );
end MEM;

architecture combinational of MEM is
 
component CB16CLED is
    Port(  clk : in std_logic;
           rst : in std_logic;
           load  : in std_logic;
           ce   : in std_logic;
           up : in std_logic;
           loadData : in std_logic_vector(15 downto 0);
           count : out std_logic_vector(15 downto 0)
     );
end component;

signal memArray     : array64x32 := (others => (others => '0'));
signal memAddrSlice : std_logic_vector(5 downto 0) := "000000";
signal ce0, ce1, load, up, ce     : std_logic := '0';
signal dataStack    : std_logic_vector(31 downto 0) := (others => '0');
signal cInPOutP     : std_logic_vector(31 downto 0) := (others => '0');
signal control0, control1, count, rInport, outport_s, loadData : std_logic_vector(15 downto 0) := (others => '0');


begin

CB16CLED_i : CB16CLED port map( clk => clk, rst => rst, load => load, ce => ce, up => up, loadData => loadData, count => count);

memAddrSlice <= add(7 downto 2);

add31To16DEC_i: process(add)
begin
    ce0 <= '0';
    ce1 <= '0';
    if add(16) = '0' then
        ce0 <= '1';
        ce1 <= '0';
    elsif add(16) = '1' then
        ce0 <= '0';
        ce1 <= '1';
    end if;
end process;

-- write to memory array (accessing 32-bit data words)
synch_i : process(clk, rst)
begin
	if rising_edge(clk) then	
        if MWr = '1' and ce0 = '1' then
           memArray(to_integer(unsigned(memAddrSlice))) <= DToM;
		end if;
    end if;
end process;

outport_i : process(clk, add, DToM)
begin
    if rising_edge(clk) then
        if add(4 downto 0) = "10000" and ce1 = '1' and MWr = '1' then
            outport_s <= DToM(15 downto 0);
        end if;
    end if;
end process;

rInport_i : process(clk, inport)
begin
    if rising_edge(clk) then
        rInport <= inport;
    end if;
end process;
            
control1_i : process(add, clk, DToM)
begin
    if rising_edge(clk) then
        if add(4 downto 0) = "00100" and MWr = '1' and ce1 = '1' then
            control1 <= DToM(15 downto 0);
            loadData  <= DToM(15 downto 0);
        end if;
    end if;
end process;

control0_i : process(add, clk, DToM)
begin
    if rising_edge(clk) then
        if add(4 downto 0) = "00000" and MWr = '1' and ce1 = '1' then
            control0 <= DToM(15 downto 0);
            load     <= DToM(2);
            up       <= DToM(1);
            ce       <= DToM(0);
        end if;
    end if;
end process;

cInPOutP_mux_i : process(control0, control1, count, rInport, outport_s, add)
begin
    if MRd = '1' then
        case add(4 downto 0) is
            when "00000"  => 
                cInPOutP <= X"0000" & control0;
            when "00100"  => 
                cInPOutP <= X"0000" & control1;
            when "01000"  =>   
                cInPOutP <= X"0000" & count;
            when "01100"  => 
                cInPOutP <= X"0000" & rInport;
            when "10000" => 
                cInPOutP <= X"0000" & outport_s;
                outport  <= outport_s;
            when others =>
                cInPOutP <= cInPOutP;
        end case;
    end if;
end process;

-- combinational read from memory  
DFrM_i : process(ce0, ce1, memAddrSlice, cInPOutP, MRd, memArray)
begin
  DFrM <= (others => '0'); -- default
  if MRd = '1' then
        if ce0 = '1' then
            DFrM <= memArray(to_integer(unsigned(memAddrSlice)));
        elsif ce1 = '1' then
            DFrM <= cInPOutP;
        end if;
  end if;
end process;

end combinational;