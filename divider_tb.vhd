library IEEE;

-- additional libraries
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;
use WORK.divider_const.all;

entity divider_tb is
end entity;

architecture divider_testbench of divider_tb is

	-- Components
	component divider is
		port(
			-- Inputs
				clk 			: in std_logic;
				start			: in std_logic;
				dividend		: in std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
				divisor		: in std_logic_vector (DIVISOR_WIDTH - 1 downto 0);

			-- Outputs
				quotient		: out std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
				remainder	: out std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
				overflow		: out std_logic
			);
	end component divider;

	for all : divider use entity WORK.divider (behavioral_sequential);
	
	--Signals
	signal clk_signal : std_logic := '1';
	signal start_signal 		: std_logic;
	signal dividend_signal 	: std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
	signal divisor_signal 	: std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
	signal quotient_signal 	: std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
	signal remainder_signal : std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
	signal overflow_signal 	: std_logic;
	
begin

	dut : divider 
		port map(
					clk 			=> clk_signal,
					start 		=> start_signal,
					dividend 	=> dividend_signal,
					divisor 		=> divisor_signal,
					quotient 	=> quotient_signal,
					remainder 	=> remainder_signal,
					overflow 	=> overflow_signal
				);
				
	-- set wait signal of 5 ns for clock
	clk_signal <= not clk_signal after 5 ns;
	
	stimulus_proc : process is
	
		file in_file				: text open read_mode is "divider16.in";
		file out_file				: text open write_mode is "divider16.out";
		
		-- Variables
		variable my_line			: line;
		variable out_line			: line;
		variable temp1				: integer;
		variable temp2				: integer;
		variable quotient_temp	: integer;
		variable remainder_temp : integer;
		variable overflow_temp	: std_logic;

		begin
		
			-- when txt file is not empty
			while not endfile(in_file) loop
			
				-- read lines of txt file
				readline(in_file, my_line);
				read(my_line, temp1);
				readline(in_file, my_line);
				read(my_line, temp2);
				
				-- wait until clock signal hits 0
				wait on clk_signal until clk_signal = '0';
				
				-- convert signals to std_logic_vector from integers and assign start as high
				dividend_signal 	<= std_logic_vector(to_unsigned(temp1, DIVIDEND_WIDTH));
				divisor_signal 	<= std_logic_vector(to_unsigned(temp2, DIVISOR_WIDTH));
				start_signal 		<= '1';
				
				
				wait for 2000 ns;
				
				-- set start to be 0 again
				start_signal <= '0';
				
				wait for 1000 ns;
				
				-- take in values and assign as integers
				quotient_temp := to_integer(unsigned(quotient_signal));
				remainder_temp:= to_integer(unsigned(remainder_signal));
				overflow_temp := overflow_signal;
				start_signal  <= '0';
				
				-- write inputs
				write(out_line, temp1);
				write(out_line, string'(" / "));
				write(out_line, temp2);
				write(out_line, string'(" = "));
				
				-- if overflow is high, write overflow as 0
				-- otherwise write quotient
				if (overflow_temp = '1') then
					write(out_line, string'("0"));
				else 
					write(out_line, quotient_temp);
				end if;
				
				-- write out remainder
				write(out_line, string'(" -- "));
				write(out_line, remainder_temp);
				writeline(out_file, out_line);
				
			end loop;
			
			-- exit file
			file_close(out_file);
			
			wait;
	
	end process;

end architecture divider_testbench;
