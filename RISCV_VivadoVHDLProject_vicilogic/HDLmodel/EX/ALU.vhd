library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
	Port( A			: in  std_logic_vector(31 downto 0);
			B  		: in  std_logic_vector(31 downto 0);
			selALUOp : in  std_logic_vector(3 downto 0);
			branch 	: out std_logic;
			zero		: out std_logic;
			ALUOut	: out std_logic_vector(31 downto 0)
			);
end ALU;

architecture rtl of ALU is

signal out_s : std_logic_vector(31 downto 0);

begin

ALUOut_i: process(A, B, selALUOp)
begin
	if selALUOp <= "1010" then
		case selALUOp is
			when "0000" =>
				out_s <= std_logic_vector(signed(A) + signed(B));
			when "0001" =>
				out_s <= std_logic_vector(signed(A) - signed(B));
			when "0010" =>
				out_s <= A and B;
			when "0011" =>
				out_s <= A or B;
			when "0100" =>
				out_s <= A xor B;
			when "0101" =>
				out_s <= std_logic_vector(shift_left(signed(A), to_integer(unsigned(B(4 downto 0)))));
			when "0110" =>
				out_s <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(4 downto 0)))));
			when "0111" =>
				out_s <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(4 downto 0)))));
				out_s(31) <= A(31);
			when "1000" =>
				if (unsigned(A) < unsigned(B)) then
					out_s <= (31 downto 1 => '0') & '1';
				else 
					out_s <= (others => '0');
				end if;
			when "1001" =>
				if (signed(A) < signed(B)) then
					out_s <= (31 downto 1 => '0') & '1';
				else 
					out_s <= (others => '0');
				end if;
			when others =>
				out_s <= (others => '0');
		end case;
		if out_s = (31 downto 0 => '0') then
			zero <= '1';
		else
			zero <= '0';
		end if;
	else
		case selALUOp is
			when "1010" => 
				if unsigned(A) = unsigned(B) then
					branch <= '1';
				else 
					branch <= '0';
				end if;
			when "1011" =>
				if signed(A) /= signed(B) then
					branch <= '1';
				else 
					branch <= '0';
				end if;
			when "1100" =>
				if signed(A) < signed(B) then
					branch <= '1';
				else 
					branch <= '0';
				end if;
			when "1101" =>
				if signed(A) >= signed(B) then
					branch <= '1';
				else 
					branch <= '0';
				end if;
			when "1110" =>
				if unsigned(A) < unsigned(B) then
					branch <= '1';
				else 
					branch <= '0';
				end if;
			when "1111" =>
				if unsigned(A) >= unsigned(B) then
					branch <= '1';
				else 
					branch <= '0';
				end if;
			when others =>
				branch <= '0';
		end case;
	end if;
	
end process;

asgnALUOut_i : ALUOut <= out_s;

end rtl;