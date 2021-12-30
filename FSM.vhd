----------------------------------------------------------------------------------
-- Company: Ain Shams University
-- Engineer: Abdelrahman Oun
-- 
-- Create Date:    12/28/2021 
-- Design Name: 	 ATM control unit
-- Module Name:    FSM - behavioral_modle 
-- Project Name: 		ATM_FSM
-- Target Devices: 
-- Tool versions: 
-- Description: this document includes the implementation of ATM's control unit
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM is
	generic (
					-- register file data width
					WIDTH : positive := 16
				);
				
	port (	
				------------------------------------------------
				------------------input signals-----------------
				------------------------------------------------
				
				-- clock of the system
				i_clock 				: in std_logic;
				
				-- asynchronous active low reset signal
				i_reset 				: in std_logic;
				
				-- enable signal to enable the control unit and disable it
				i_enable				: in std_logic;
				
				-- register file interface
				-- input flag indicates that the data is valid on rd_data bus
				i_rd_valid 			: in std_logic;
				
				-- read data buss holds the data from the register file
				i_rd_data 			: in std_logic_vector(WIDTH-1 downto 0);
				
				-- card scanner interface
				-- input flag indicates that the ID is ready to be captured on the card_ID bus
				i_valid_ID 			: in std_logic;
				
				-- input bus holds card ID which inserted in the ATM
				i_card_ID 			: in std_logic_vector(WIDTH-1 downto 0);
				
				-- card sensor and motor interface
				-- input flag indicates that the card has inserted in the ATM
				i_card_valid 		: in std_logic;
				
				-- timer interface
				-- input flag indicates the timer is overflowed
				i_time_out 			: in std_logic;
				
				-- cash counter interface
				-- input flag indicates that the counter has finished its operation
				i_feeder_done 		: in std_logic;
				
				-- input bus holds the value of the cash in the feeder inserted form the user
				i_receive_value 	: in std_logic_vector (WIDTH-1 downto 0);
				
				--keyboard interface
				-- input flag indicates that the data is valid on keyboard_data buss is ready to be fetched
				i_keyboard_valid 	: in std_logic;
				
				-- input bus holds the value entered from the user
				i_keyboard_data 	: in std_logic_vector (WIDTH-1 downto 0);
				
				-- control keys interface
				-- input control signal indicates that the user is ok with the choice
				i_yes 				: in std_logic;
				
				-- input control signal indicates that the user is not ok with the choice
				i_no 					: in std_logic;
				
				-- input control signal indicates that the user wants to deposit a money
				i_deposit 			: in std_logic;
				
				
				-- input control signal indicates that the user wants to withdraw a money
				i_withdraw 			: in std_logic;
				
				-- input control signal indicates that the uset wants to change his card password
				i_change_pass 		: in std_logic;
				
				-- counter interface
				-- input flag indicates that the counter overflow
				i_overflow 			: in std_logic;
				
				------------------------------------------------
				-----------------output signals-----------------
				------------------------------------------------
				
				-- register file interface
				-- output control signal to enabel the register file to do an operation
				o_reg_file_en		: out std_logic;
				
				-- read or write enable signal
				o_RW 					: out std_logic;
				
				-- address bus holds the location wants ot read in or write from
				o_address 			: out std_logic_vector (1 downto 0);
				
				-- write data bus holds the data which control unit wants to write on the register file
				o_wr_data 			: out std_logic_vector (WIDTH-1 downto 0);
				
				-- printer interface
				-- output control signal is used to enable the printer to print the receipt
				o_printer_en 		: out std_logic;
				
				-- card scannter interface
				-- output control signal is used to enable the scanner to scan the card
				o_scan_en 			: out std_logic;
				
				-- card sensor and motor interface
				-- output control signal is used to enable the motor to get the card out 
				o_motor_en 			: out std_logic;
				
				-- timer interface
				-- timer enable signal
				o_timer_en 			: out std_logic;
				
				-- timer reset signal
				o_timer_reset 		: out std_logic;
				
				-- cash counter interface
				-- output control signal is used to enable the feeder to send the cash
				o_send_en			: out std_logic;
				
				-- output control signal is used to enable the cash counter to count the cash entered by the user
				o_receive_en 		: out std_logic;
				
				-- output bus holds the value that the user wants to withdraw
				o_send_value 		: out std_logic_vector (WIDTH-1 downto 0);
				
				-- keyboard interface
				-- output control signal is used to enable the keyboard
				o_keyboard_en 		: out std_logic;
				
				-- counter interface
				-- output control signal is used to reset the counter
				o_counter_reset 	: out std_logic;
				
				-- output control signal is used to increse the counter by one
				o_count 				: out std_logic;
				
				-- LCD interface
				-- output bus holds the value of the current state to inform the user which operation is on going
				o_current_state 	: out std_logic_vector (4 downto 0)				
			);	
			
end FSM;
	

architecture behavioral_modle of FSM is

	SUBTYPE STATE_TYPE IS STD_LOGIC_VECTOR (4 DOWNTO 0);
	
	-- the states is coded using gray code
	CONSTANT idle							: STATE_TYPE:="00000"; -- 1
	CONSTANT card_inserted				: STATE_TYPE:="00001"; -- 2
	CONSTANT reg_file_write_id			: STATE_TYPE:="00011"; -- 3
	CONSTANT reg_file_read_pass		: STATE_TYPE:="00010"; -- 4
	CONSTANT enter_pass					: STATE_TYPE:="00110"; -- 5
	CONSTANT compare_pass				: STATE_TYPE:="00111"; -- 6
	CONSTANT wrong_pass					: STATE_TYPE:="00101"; -- 7
	CONSTANT restore_card				: STATE_TYPE:="00100"; -- 8
	CONSTANT main_menu					: STATE_TYPE:="01100"; -- 9
	CONSTANT enter_cash_value			: STATE_TYPE:="01101"; -- 10
	CONSTANT reg_file_read_account	: STATE_TYPE:="01111"; -- 11
	CONSTANT compare_value				: STATE_TYPE:="01110"; -- 12
	CONSTANT send_cash					: STATE_TYPE:="01010"; -- 13
	CONSTANT op_not_valid				: STATE_TYPE:="01011"; -- 14
	CONSTANT another_service			: STATE_TYPE:="01001"; -- 15
	CONSTANT receive_cash				: STATE_TYPE:="01000"; -- 16
	CONSTANT cash_ok						: STATE_TYPE:="11000"; -- 17
	CONSTANT reg_file_write_deposit	: STATE_TYPE:="11001"; -- 18
	CONSTANT reg_file_write_withdraw	: STATE_TYPE:="11011"; -- 19
	CONSTANT enter_new_pass				: STATE_TYPE:="11010"; -- 20
	CONSTANT reg_file_write_pass		: STATE_TYPE:="11110"; -- 21
	CONSTANT print_reciept				: STATE_TYPE:="11111"; -- 22
	CONSTANT printing						: STATE_TYPE:="11101"; -- 23
	
	SIGNAL current_state,next_state : STATE_TYPE;
	
	
	-- internal signal is used to indicates that the comparator result is matched or acceptable
	signal accept : std_logic;
	
	-- internal signal is used to indicates that the copatator result is not matched and not acceptable
	signal not_accept : std_logic;
	
begin
	
	
	-- assign the current state to o_current_state to inform the LCD driver which state the controller in
	o_current_state <= current_state;
	
	----------------------------------------------------------------------
	---------------------------sequential process-------------------------
	----------------------------------------------------------------------
	
	current_state_process : process (i_clock , i_reset)
	begin
		if i_reset = '0' then
			current_state <= idle;
			
		elsif rising_edge (i_clock) then
			if i_enable = '1' then
				current_state <= next_state;
			end if;
			
		end if;
	
	end process current_state_process;
	
	----------------------------------------------------------------------
	--------------------------combinational process-----------------------
	---------------this process handles the flow of the states -----------
	----------------------------------------------------------------------
	
	next_state_process : process (
				current_state,
				accept,
				not_accept,
				i_rd_valid,
				i_valid_ID,
				i_card_valid,
				i_time_out,
				i_feeder_done,
				i_keyboard_valid,
				i_yes,
				i_no,
				i_deposit,
				i_withdraw,
				i_change_pass,
				i_overflow)
	begin
		case current_state is
			
			------------------------- state 1 --------------------------
			when idle =>
				if i_card_valid = '1' then
					next_state <= card_inserted;
				else
					next_state <= idle;
				end if;
			
			------------------------- state 2 --------------------------
			when card_inserted =>
				if i_valid_ID = '1' then
					next_state <= reg_file_write_id;
				else
					next_state <= card_inserted;
				end if;
				
			------------------------- state 3 --------------------------
			when reg_file_write_id => next_state <= reg_file_read_pass;
			
			------------------------- state 4 --------------------------
			when reg_file_read_pass =>
				if i_rd_valid = '1' then
					next_state <= enter_pass;
				else
					next_state <= reg_file_read_pass;
				end if;
				
			------------------------- state 5 --------------------------
			when enter_pass =>
				if i_keyboard_valid = '1' then
					next_state <= compare_pass;
				elsif i_time_out = '1' then
					next_state <= restore_card;
				else
					next_state <= enter_pass;
				end if;

			------------------------- state 6 --------------------------
			when compare_pass =>
				if accept = '1' then
					next_state <= main_menu;
				elsif not_accept = '1' then
					next_state <= wrong_pass;
				else
					next_state <= compare_pass;
				end if;
				
			------------------------- state 7 --------------------------
			when wrong_pass =>
				if i_overflow = '1' then
					next_state <= restore_card;
				else
					next_state <= compare_pass;
				end if;
			
			------------------------- state 8 --------------------------
			when restore_card => next_state <= idle;
			
			------------------------- state 9 --------------------------
			when main_menu =>
				if i_withdraw = '1' then
					next_state <= enter_cash_value;
				elsif i_deposit = '1' then
					next_state <= receive_cash;
				elsif i_change_pass = '1' then
					next_state <= enter_new_pass;
				elsif i_overflow = '1' then
					next_state <= restore_card;
				else
					next_state <= main_menu;
				end if;
				
			------------------------- state 10 --------------------------
			when enter_cash_value =>
				if i_keyboard_valid = '1' then
					next_state <= reg_file_read_account;
				elsif i_time_out = '1' then
					next_state <= restore_card;
				else
					next_state <= enter_cash_value;
				end if;
			
			------------------------- state 11 --------------------------
			when reg_file_read_account =>
				if i_rd_valid = '1' then
					next_state <= compare_value;
				else
					next_state <= reg_file_read_account; 
				end if;
			
			------------------------- state 12 --------------------------
			when compare_value =>
				if accept = '1' then
					next_state <= reg_file_write_withdraw;
				elsif not_accept = '1' then
					next_state <= op_not_valid;
				else
					next_state <= compare_value;
				end if;
			
			------------------------- state 13 --------------------------
			when send_cash =>
				if i_feeder_done = '1' then
					next_state <= another_service;
				else
					next_state <= send_cash;
				end if;
			
			------------------------- state 14 --------------------------
			when op_not_valid => next_state <= another_service;
			
			------------------------- state 15 --------------------------
			when another_service =>
				if i_yes = '1' then
					next_state <= main_menu;
				elsif i_no = '1' then
					next_state <= print_reciept;
				elsif i_time_out = '1' then
					next_state <= restore_card;
				else
					next_state <= another_service;
				end if;
			
			------------------------- state 16 --------------------------
			when receive_cash =>
				if i_feeder_done = '1' then
					next_state <= cash_ok;
				else
					next_state <= receive_cash;
				end if;
			
			------------------------- state 17 --------------------------
			when cash_ok =>
				if i_yes = '1' then
					next_state <= reg_file_write_deposit;
				elsif i_no = '1' then
					next_state <= send_cash;
				elsif i_time_out = '1' then
					next_state <= restore_card;
				else
					next_state <= another_service;
				end if;
			
			------------------------- state 18 --------------------------
			when reg_file_write_deposit => next_state <= another_service;
			
			------------------------- state 19 --------------------------
			when reg_file_write_withdraw => next_state <= another_service;
			
			------------------------- state 20 --------------------------
			when enter_new_pass =>
				if i_keyboard_valid = '1' then
					next_state <= reg_file_write_pass;
				elsif i_time_out = '1' then
					next_state <= restore_card;
				else
					next_state <= enter_new_pass;
				end if;
				
			------------------------- state 21 --------------------------
			when reg_file_write_pass => next_state <= another_service;
			
			------------------------- state 22 --------------------------
			when print_reciept =>
				if i_yes = '1' then
					next_state <= printing;
				elsif i_no = '1' then
					next_state <= restore_card;
				elsif i_time_out = '1' then
					next_state <= restore_card;
				else
					next_state <= print_reciept;
				end if;
			
			------------------------- state 23 --------------------------
			when printing => next_state <= restore_card;
			
			
			when others => next_state <= idle;
		end case;
	end process next_state_process;
	
	
	----------------------------------------------------------------------
	--------------------------combinational process-----------------------
	-------------this process handles the operation of each state---------
	----------------------------------------------------------------------
	
	current_state_operations : process (
				current_state,
				i_rd_data,
				i_keyboard_data)
	begin
		case current_state is
			
			------------------------- state 1 --------------------------
			when idle =>
				-- assign all control and data signals to zero
				o_reg_file_en <= '1';
				o_RW <= '1';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 2 --------------------------
			when card_inserted =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '1';									-- activate ID scanner
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';
				accept <= '0';
				not_accept <= '0';
				
			------------------------- state 3 --------------------------
			when reg_file_write_id => 
				o_reg_file_en <= '1';								-- enable the register file
				o_RW <= '0';											-- write operation
				o_address <= "00";									-- card ID address
				o_wr_data <= i_card_ID;								-- assign the card ID from the scanner to the register file
				o_printer_en <= '0';
				o_scan_en <= '0';									-- deactivate ID scanner
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 4 --------------------------
			when reg_file_read_pass =>
				o_reg_file_en <= '1';								-- enable the register file
				o_RW <= '1';											-- read operation
				o_address <= "01";									-- password address
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';
				accept <= '0';
				not_accept <= '0';
				
			------------------------- state 5 --------------------------
			when enter_pass =>
				o_reg_file_en <= '0';								-- disable the register file
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '1';									-- enable the timer
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '1';								-- enable the keyboard to receive the password entered from the user
				o_counter_reset <= '0';
				o_count <= '0';
				accept <= '0';
				not_accept <= '0';

			------------------------- state 6 --------------------------
			when compare_pass =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';
				if (i_rd_data = i_keyboard_data) then			-- if the entered password matched to the saved one
					accept <= '1';									-- activate the internal signal accept
					not_accept <= '0';
				else
					accept <= '0';
					not_accept <= '1';								-- activate the internal signal not_accept
				end if;

				
			------------------------- state 7 --------------------------
			when wrong_pass => 
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '1';									-- enable the timer 
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '1';								-- enable the keyboard to receive the password again entered from the user
				o_counter_reset <= '0';
				o_count <= '1';										-- increase the counter by one by enabling the count pin then disable it
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 8 --------------------------
			when restore_card =>	
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '1';									-- enable the motor to restore the card
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '1';							-- reset the counter
				o_count <= '0';		
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 9 --------------------------
			when main_menu =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '1';									-- enable the timer
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '1';							-- reset the counter
				o_count <= '0';		
				accept <= '0';
				not_accept <= '0';
				
			------------------------- state 10 --------------------------
			when enter_cash_value =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '1';									-- enable the timer
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '1';								-- enable the keyboard to receive the cash value entered from the user
				o_counter_reset <= '0';
				o_count <= '0';		
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 11 --------------------------
			when reg_file_read_account =>
				o_reg_file_en <= '1';								-- enable the register file
				o_RW <= '1';											-- read operation
				o_address <= "10";									-- account address
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';		
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 12 --------------------------
			when compare_value =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';		
				if (i_rd_data >= i_keyboard_data) then			-- if the entered cash is valid in the account
					accept <= '1';									-- activate the internal signal accept
					not_accept <= '0';
				else
					accept <= '0';
					not_accept <= '1';								-- activate the internal signal not_accept
				end if;
			
			------------------------- state 13 --------------------------
			when send_cash =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '1';									-- enable the feeder to send the cash
				o_receive_en <= '0';
				o_send_value <= i_keyboard_data;					-- assign the cash entered from the user to the feeder
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';		
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 14 --------------------------
			when op_not_valid =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <=(others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';		
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 15 --------------------------
			when another_service =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '1';									-- enable the timer
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <=(others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';		
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 16 --------------------------
			when receive_cash =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '1';								-- enable the feeder to receive the cash from the user
				o_send_value <=(others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';		
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 17 --------------------------
			when cash_ok =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '1';									-- enable the timer
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <=(others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';		
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 18 --------------------------
			when reg_file_write_deposit => 
				o_reg_file_en <= '1';								-- enable the register file
				o_RW <= '0';											-- write operation
				o_address <= "11";									-- whitdraw or deposit value address
				o_wr_data <= i_receive_value;						-- assign the cash entered from the feeder to the register file
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 19 --------------------------
			when reg_file_write_withdraw =>
				o_reg_file_en <= '1';								-- enable the register file
				o_RW <= '0';											-- write operation
				o_address <= "11";									-- whitdraw or deposit value address
				o_wr_data <= i_keyboard_data;						-- assign the cash entered from the user to the register file
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';
				accept <= '0';
				not_accept <= '0';

			------------------------- state 20 --------------------------
			when enter_new_pass =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '1';									-- enable the timer
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '1';								-- enable the keyboard to receive the password entered from the user
				o_counter_reset <= '0';
				o_count <= '0';
				accept <= '0';
				not_accept <= '0';
				
			------------------------- state 21 --------------------------
			when reg_file_write_pass => 
				o_reg_file_en <= '1';								-- enable the register file
				o_RW <= '0';											-- write operation
				o_address <= "01";									-- password address
				o_wr_data <= i_keyboard_data;						-- assign the password entered from the user to the register file
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 22 --------------------------
			when print_reciept =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '1';									-- enable the timer
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <=(others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';		
				accept <= '0';
				not_accept <= '0';
			
			------------------------- state 23 --------------------------
			when printing =>
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '1';								-- enable the printer to print the reciept
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <=(others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';		
				accept <= '0';
				not_accept <= '0';
			
			------------------------- other case options ----------------
			when others => 
				-- assign all control and data signals to zero
				o_reg_file_en <= '0';
				o_RW <= '0';
				o_address <= "00";
				o_wr_data <= (others => '0');
				o_printer_en <= '0';
				o_scan_en <= '0';
				o_motor_en <= '0';
				o_timer_en <= '0';
				o_send_en <= '0';
				o_receive_en <= '0';
				o_send_value <= (others => '0');
				o_keyboard_en <= '0';
				o_counter_reset <= '0';
				o_count <= '0';
				accept <= '0';
				not_accept <= '0';
				
		end case;
	end process current_state_operations;
	
	
	

	----------------------------------------------------------------------
	-------comparator process to handle the o_timer_reset signal --------- 	
	----------------------------------------------------------------------
	states_comparator : process (current_state, next_state)
   begin
		if current_state = next_state then
			o_timer_reset <= '0';
		else 
			o_timer_reset <= '1';
		end if;
	end process states_comparator;

end behavioral_modle;
























