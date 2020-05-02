library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.divider_const.all;

entity comparator is
		generic( 
			DATA_WIDTH	: natural := DIVISOR_WIDTH 
			); 
		port(
			--Inputs
			DINL	: in std_logic_vector (DATA_WIDTH downto 0);
			DINR	: in std_logic_vector (DATA_WIDTH - 1 downto 0);
			
			--Outputs
			DOUT	: out std_logic_vector (DATA_WIDTH - 1 downto 0);
			isGreaterEq: out std_logic
			
			);
end entity comparator;

-- Architecture of comparator
architecture behavioral of comparator is
	-- Signals
	signal DINL_int 	 : integer;
	signal DINR_int	 : integer;
	signal DOUT_int 	 : integer;
	signal DINL_append : std_logic_vector (DATA_WIDTH downto 0);

begin
		-- convert to integers
		DINL_int <= (to_integer(unsigned(DINL)));
		DINR_int <= (to_integer(unsigned(DINR)));
 
		-- perform computation of subtraction
		DOUT_int <= DINL_int - DINR_int when DINL_int >= DINR_int
			else DINL_int;
		
		-- set DOUT to be std_logic_vector
		DOUT <= std_logic_vector(to_unsigned(DOUT_int, DATA_WIDTH));

		isGreaterEq <= '1' when DINL_int >= DINR_int 
			else '0';
	
end architecture behavioral;