library ieee;
use ieee.std_logic_1164.all;

entity adc_dac_spi is
port(clock		:	in std_logic;
		reset		:	in std_logic;
		
		adc_spi_init	:	in	std_logic;
		
		adc_nCS	:	out std_logic;
		sclk		:	out std_logic;
		adc_sync		:	out std_logic;
		adc_pdwn		:	out std_logic;
		sdio		:	out std_logic;
		adc_sdio_dir	:	out std_logic;	
		
		dac_nCS		:	out std_logic;
		dac_spi_done	:	out std_logic;
		adc_spi_done	:	out std_logic
		);
end entity adc_dac_spi;

architecture behavior of adc_dac_spi is

component ad9653 is
port(clock		:	in std_logic;
		reset		:	in std_logic;
		
		spi_init	:	in	std_logic;
		
		nCS		:	out std_logic;
		sclk		:	out std_logic;
		sync		:	out std_logic;
		pdwn		:	out std_logic;
		sdio		:	out std_logic;
		sdio_dir	:	out std_logic;
		spi_done	:	out std_logic
		);
end component;
component ad9781 is
port(clock		:	in std_logic;
		reset		:	in std_logic;
		
		spi_init	:	in	std_logic;		
		nCS		:	out std_logic;
		sclk		:	out std_logic;		
		sdio		:	out std_logic;		
		spi_done	:	out std_logic
		);
end component;

signal	adc_sclk			:	std_logic;
signal	dac_sclk			:	std_logic;
signal	adc_sdio			:	std_logic;
signal	dac_sdio			:	std_logic;
signal	adc_spi_done_int	:	std_logic;
begin

ad9653_inst: ad9653
port map(clock		=>	clock,
			reset		=>	reset,
		
			spi_init	=>	adc_spi_init,
			nCS		=>	adc_nCS,
			sclk		=>	adc_sclk,
			sync		=>	adc_sync,
			pdwn		=>	adc_pdwn,
			sdio		=>	adc_sdio,
			sdio_dir	=>	adc_sdio_dir,
			spi_done	=>	adc_spi_done_int
			);
ad9781_inst: ad9781
port map(clock		=>	clock,
			reset		=>	reset,
		
			spi_init	=>	'0',		
			nCS		=>	dac_nCS,
			sclk		=>	dac_sclk,		
			sdio		=>	dac_sdio,
			spi_done	=>	dac_spi_done
			);

sclk	<=	dac_sclk when adc_spi_done_int = '1' else adc_sclk;
sdio	<=	dac_sdio when adc_spi_done_int = '1' else adc_sdio;
adc_spi_done	<=	adc_spi_done_int;			


end architecture behavior;		
		
		