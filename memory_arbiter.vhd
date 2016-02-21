library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.memory_arbiter_lib.all;

-- Do not modify the port map of this structure
entity memory_arbiter is
port (clk 	: in STD_LOGIC;
      reset : in STD_LOGIC;
      
			--Memory port #1
			addr1	: in NATURAL;
			data1	:	inout STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
			re1		: in STD_LOGIC;
			we1		: in STD_LOGIC;
			busy1 : out STD_LOGIC;
			
			--Memory port #2
			addr2	: in NATURAL;
			data2	:	inout STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
			re2		: in STD_LOGIC;
			we2		: in STD_LOGIC;
			busy2 : out STD_LOGIC
  );
end memory_arbiter;

architecture behavioral of memory_arbiter is

	--Main memory signals
  --Use these internal signals to interact with the main memory
  SIGNAL mm_address       : NATURAL                                       := 0;
  SIGNAL mm_we            : STD_LOGIC                                     := '0';
  SIGNAL mm_wr_done       : STD_LOGIC                                     := '0';
  SIGNAL mm_re            : STD_LOGIC                                     := '0';
  SIGNAL mm_rd_ready      : STD_LOGIC                                     := '0';
  SIGNAL mm_data          : STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0)   := (others => 'Z');
  SIGNAL mm_initialize    : STD_LOGIC                                     := '0';

  Signal first_access  : std_logic :='1';
  Signal current_access   : std_logic := 'X';
  --Signal
  --Signal port2_done	  : std_logic :='1';

begin

	--Instantiation of the main memory component (DO NOT MODIFY)
	main_memory : ENTITY work.Main_Memory
      GENERIC MAP (
				Num_Bytes_in_Word	=> NUM_BYTES_IN_WORD,
				Num_Bits_in_Byte 	=> NUM_BITS_IN_BYTE,
        Read_Delay        => 3, 
        Write_Delay       => 3
      )
      PORT MAP (
        clk					=> clk,
        address     => mm_address,
        Word_Byte   => '1',
        we          => mm_we,
        wr_done     => mm_wr_done,
        re          => mm_re,
        rd_ready    => mm_rd_ready,
        data        => mm_data,
        initialize  => mm_initialize,
        dump        => '0'
      );

Busy : Process(clk, reset, re1, re2, we1, we2)
Begin
	if rising_edge(clk) and reset = '0' then
		if ((re1 = '1' or we1 = '1') and (mm_rd_ready = '0' and mm_wr_done = '0')) then
			busy1 <= '1';
		elsif(current_access = '1') then
			busy1 <= '0';
		end if;
		if ((re2 = '1' or we2 = '1') and (mm_rd_ready = '0' and mm_wr_done = '0')) then
			busy2 <= '1';
		elsif(current_access = '0') then
			busy2 <= '0';
		end if;
	end if;
end process;
			

Priority : Process(clk, reset, re1, re2, we1, we2)
Begin
	if reset = '1' then
		mm_re <= '0';
		mm_we <= '0';
	elsif rising_edge(clk) and reset = '0' then
--		if ((mm_wr_done = '1' or mm_rd_ready = '1') or first_access = '1') then
--			if(first_access = '1') then
--				first_access <= '0';
--			end if;
			if( re1 = '1') then
				mm_re <= '1';
				mm_we <= '0';
				mm_address <= addr1;
				mm_data <= data1;
				current_access <= '1';
			elsif( we1 = '1') then
				mm_re <= '0';
				mm_we <= '1';
				mm_address <= addr1;
				mm_data <= data1;
				current_access <= '1';
			elsif(re2 = '1') then
				mm_re <= '1';
				mm_we <= '0';
				mm_address <= addr2;
				mm_data <= data2;
				current_access <= '0';
			elsif(we2 = '1') then
				mm_re <= '0';
				mm_we <= '1';
				mm_address <= addr2;
				mm_data <= data2;
				current_access <= '0';
			else
				mm_re <= '0';
				mm_we <= '0';
				mm_address <= 0;
				mm_data <= (others => 'Z');
				current_access <= 'X';
			end if;
		--end if;
	end if;

end process;



end behavioral;