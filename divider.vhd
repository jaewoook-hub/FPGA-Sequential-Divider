library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.divider_const.all;

--Additional standard or custom libraries go here
entity divider is 
	port(
		--Inputs
			clk 		: in std_logic;
			start		: in std_logic;
			dividend	: in std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
			divisor	: in std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
				
		--Outputs
			quotient	: out std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
			remainder: out std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
			overflow	: out std_logic
		);
end entity divider;

-- structural architecture for divider
architecture structural_combinational of divider is

-- Signals and components go here

	-- set the length of DATA_WIDTH to equal to DIVISOR_WIDTH
	constant DATA_WIDTH : natural := DIVISOR_WIDTH;
	
	-- components
	component comparator is
		generic(
					-- set the width for DATA_WIDTH
					DATA_WIDTH : natural := 4
		);
		
		port(
			-- inputs
			DINL 			: in std_logic_vector (DATA_WIDTH downto 0);
			DINR 			: in std_logic_vector (DATA_WIDTH - 1 downto 0);
			-- outputs
			DOUT 			: out std_logic_vector (DATA_WIDTH - 1 downto 0);
			isGreaterEq : out std_logic
		);
	end component comparator;
	
	
	-- types
	type short_array is array (0 to DIVIDEND_WIDTH) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type long_array is array (0 to (DIVIDEND_WIDTH - 1)) of std_logic_vector(DATA_WIDTH downto 0);
	
	-- initalize arrays to be used for storing comparators from dout_array to din_array and back to computing comparators
	
	-- signals
	signal dout_array : short_array;
	signal din_array 	: long_array;


-- structural design
begin

	dout_array(DIVIDEND_WIDTH) <= (others => '0');
	
	-- GENERATE Function that begins from counting downwards to 0
	compare_block : for i in (DIVIDEND_WIDTH - 1) downto 0 GENERATE
	-- concatenate dividend(i) to the end of dout_array(i + 1) and store into din_array
		din_array(i) <= dout_array(i + 1) & dividend(i);
			
	compare : comparator
		-- map DATA_WIDTH
		generic map (
						DATA_WIDTH => DATA_WIDTH
		)	
		-- map inputs/outports from component comparator to other signals/inputs/outputs of the entity divider
		port map (
					DINL			=> din_array(i),
					DINR			=> divisor,
					DOUT			=> dout_array(i),
					isGreaterEq	=> quotient(i)
		);
	end GENERATE;
	
	-- checking case for when start button is pressed as well as overflow
	START_PROCESS : process(start) is
	begin
		-- when start button is pressed continue
		if (rising_edge(start)) then
			
			-- if so, convert divisor to unsigned integer and if it's 0, then set overflow to 1
			if (to_integer(unsigned(divisor))) = 0 then
				overflow <= '1';
				remainder <= std_logic_vector(to_unsigned(0, DIVISOR_WIDTH));
			
			-- otherwise, set overflow to 0 and then remainder equal to the first instance of the dout_array
			else
				overflow <= '0';
				remainder <= dout_array(0);
			
			end if;
		end if;
	end process START_PROCESS;
			
end architecture structural_combinational;

-------------------------------------------------------------------

-- architecture for behavioral divider
architecture behavioral_sequential of divider is

	-- Components
	component comparator is 
		generic( 
			DATA_WIDTH	: natural := DIVISOR_WIDTH 
			); 
		port(
			--Inputs
			DINL			: in std_logic_vector (DATA_WIDTH downto 0);
			DINR			: in std_logic_vector (DATA_WIDTH - 1 downto 0);
			
			--Outputs
			DOUT			: out std_logic_vector (DATA_WIDTH - 1 downto 0);
			isGreaterEq	: out std_logic
		);
	end component comparator;
	
	--Signals
		signal DINL_sig		: std_logic_vector (DIVISOR_WIDTH downto 0);
		signal DINR_sig		: std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
		
		signal DOUT_sig		: std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
		signal isGreaterEq_sig: std_logic;
		
		signal temp_int 		: integer;
		
	--Constants
		constant zeros_dividend : std_logic_vector(DIVIDEND_WIDTH - 1 downto 0) := (others => '0');
		constant zeros_divisor 	: std_logic_vector(DIVISOR_WIDTH - 1 downto 0) := (others => '0');

begin

	comp_process : comparator 
		port map (
					--Inputs
					DINL 			=> DINL_sig,
					DINR 			=> DINR_sig,
					
					--Outputs
					DOUT 			=> DOUT_sig,
					isGreaterEq => isGreaterEq_sig
				);
					
	-- begin process statement
	start_process : process(clk) is
	
		--Variables
		-- comparator variables --
		variable tempDINL			: std_logic_vector (DIVISOR_WIDTH downto 0) 		:= (others => '0');
		
		--divider variables--
		variable temp_result		: std_logic_vector(DIVISOR_WIDTH - 1 downto 0)	:= (others => '0');
		variable temp_input		: std_logic_vector(DIVISOR_WIDTH downto 0)		:= (others => '0');
		variable temp_quotient	: std_logic_vector(DIVIDEND_WIDTH - 1 downto 0) := (others => '0');

		variable temp_remainder	: std_logic_vector(DIVISOR_WIDTH - 1 downto 0);
		variable temp_dividend	: std_logic_vector(DIVIDEND_WIDTH - 1 downto 0);
		variable temp_index 		: integer := temp_int;

	begin
	
		-- set signals and variable
		DINL_sig			<= tempDINL;
		DINR_sig		 	<= divisor;
		quotient 		<= temp_quotient;
		temp_dividend 	:= dividend;
		remainder 		<= temp_remainder;
		temp_int 		<= temp_index;

		-- if rising edge on clock, proceed computation
		if rising_edge(clk) then
		
			-- assign index to a temp variable
			temp_index := temp_int;
			
			-- if start is high, then reset everything to 0
			if (start = '1') then
				temp_input := (others => '0');
				temp_result	:= zeros_divisor;
				temp_quotient := zeros_dividend;
				temp_index := DIVIDEND_WIDTH;
			end if;
			
			-- while temp index is greater than or equal to 0, continue below
			if (temp_index >= 0) then
				
				-- if temp is not dividend_width, then continue to perform computation
				if (temp_index /= DIVIDEND_WIDTH) then
					-- set DOUT value into temp_result and store that value by shifting left of temp_input
					temp_result := DOUT_sig;
					temp_input(temp_input'Left downto 1) := temp_result;
					temp_quotient(temp_index) := isGreaterEq_sig;
				end if;
				
				-- if temp is not 0, then have right side of temp_input become temp_dividend
				if (temp_index /= 0) then
					temp_input(temp_input'Right) := temp_dividend(temp_index - 1);
					tempDINL := temp_input;
				end if;
				
				-- if temp is 0, set remainder to get temp_result
				if (temp_index = 0) then
					temp_remainder := temp_result;
				end if;
				
				-- decrement temp index
				temp_index := temp_index - 1;

				-- if divisor is 0, set overflow to high and quotient becomes 0
				if ( divisor = zeros_divisor ) then
					overflow 		<= '1'; 
					temp_quotient 	:= zeros_dividend;
				else 
					overflow 		<= '0';
				end if;
				
			end if;
		end if;
	end process start_process;
end architecture behavioral_sequential;