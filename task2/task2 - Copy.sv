module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

	// Defining local parameter values for the the individual states of for
	// task 2.
	localparam Waiting_For_Reset = 0;
	localparam Init_Wait_For_Rdy = 1;
	localparam Init_Deassert_en1 = 2;
	localparam get_s_i = 3;
	localparam import_to_ksa = 4;
	localparam request_s_j = 5;
	localparam get_s_j = 6;
	localparam write_s_i = 7;
	localparam write_s_j = 8;
	localparam request_s_i_1 = 9;
	localparam Done = 10;
	localparam Write_0_0 = 11;
	
	
	// Initiating the state variables for task2 to start in Waiting_For_Reset 
	// state.
	logic [3:0] state = Waiting_For_Reset;
	logic [8:0] index_counter = 0;
	
	// Variables for managing the enable for each instantiated module.
	logic en_init;
	logic en_ksa;
	logic wren_mem;
	
	// Variables for the rdy variables of init and ksa.
	logic rdy_init;
	logic rdy_ksa;
	
	// The data variables for interaction with the init module.
	logic rst_n_init; // Input
	logic [7:0] address_init; // Output
	logic [7:0] wrdata_init; // Output
	
	// The data variables for interaction with the ksa module.
	logic rst_n_ksa; // Input
	logic [7:0] rddata_ksa; // Input 
	logic [7:0] address_ksa; // Output
	logic [7:0] wrdata_ksa; // Output
	
	
	// The data variables for interaction with the memory module. 
	logic [7:0] address_mem; // Input
	logic [7:0] input_data_mem; // Input
	logic [7:0] read_value_mem; // Output
	
	// The encryption key determined by the switches on the board.
	// logic [23:0] key = 24'b000000000000000000000000;
	// logic [23:0] key = 24'h00033c;
	// logic [23:0] key = 24'h010101;
	logic [23:0] key;
	assign key[9:0] = SW[9:0];
	assign key[23:10] = 0;
	
	// Temporary registers for saving the values of s(i) and s(j).
	reg [7:0] s_i = 0;
	reg [7:0] s_j = 0;
	reg [7:0] j = 0;
			 
    s_mem s(.address(address_mem), .clock(CLOCK_50), .data(input_data_mem), 
		.wren(wren_mem), .q(read_value_mem));
	
	init init(.clk(CLOCK_50), .rst_n(rst_n_init), .en(en_init), .rdy(rdy_init), 
		.addr(address_init), .wrdata(wrdata_init), .wren());

	ksa ksa(.clk(CLOCK_50), .rst_n(rst_n_ksa), .en(en_ksa), .rdy(rdy_ksa), 
		.key(key), .addr(address_ksa), .rddata(rddata_ksa), .wrdata(wrdata_ksa),
		.wren());
		
    // Determines the state of the task1 state machine.
	always_ff @(posedge CLOCK_50)
		begin
			
			case(state)
			
				// In this state we are waiting for the reset button, KEY[3] to
				// be pressed. 
				Waiting_For_Reset:
					begin
						j <= 0;
						s_i <= 0;
						s_j <= 0;
						if (KEY[3] == 0)
							begin
								state <= Write_0_0;
							end
						else 
							begin
								state <= Waiting_For_Reset;
							end
					end
					
				Write_0_0:
					begin
						state <= Init_Wait_For_Rdy;
					end
			
				// Moves onto the next state if rdy is asserted.
				Init_Wait_For_Rdy: 
					begin
						if (rdy_init == 1)
							begin
								state <= Init_Deassert_en1;
							end	
						else
							begin
								state <= Init_Wait_For_Rdy;
							end
					end
					
				// A couple things. This state is mainly for de-asserting en
				// but it also decides when we are done. This is based on the 
				// data coming from INIT.
				Init_Deassert_en1: 
					begin
						if (wrdata_init == 255)
							begin
								state <= get_s_i;
								
							end
						else
							begin
								state <= Init_Wait_For_Rdy;
							end
					end
				
				get_s_i:
					begin
						state <= import_to_ksa;
						s_i <= read_value_mem;
					end
					
				import_to_ksa:
					begin
						if (rdy_ksa == 1)
							begin
								state <= request_s_j;
								
							end
					end
					
				request_s_j:
					begin
						state <= get_s_j;
						j <= address_ksa;
						
					end
					
				get_s_j:
					begin
						state <= write_s_i;
						s_j <= read_value_mem;
					end
					
				write_s_i:
					begin
						state <= write_s_j;						
					end
					
				write_s_j:
					begin
						state <= request_s_i_1;
					end
					
				request_s_i_1:
					begin
						
						if (index_counter == 256)
							begin
								state <= Done;
							end
						else
							begin
								state <= get_s_i;
							end
					end
				
				Done:
					begin
						state <= Waiting_For_Reset;
					end
			endcase

		end
	
	// The part of the state machine that deals with the index counter. 
	always_ff @(negedge CLOCK_50)
		begin
			// Reset the index counter when in the Waiting for reset state.
			if (state == Waiting_For_Reset)
				begin
					index_counter <= 0;
				end
			
			// Every time we press the ksa module is enabled, then increment 
			// the index counter.
			if (en_ksa == 1)
				begin
					index_counter <= index_counter + 1;
				end
				
		end
	
	// Determines the data path for task1.
	always_comb
		begin		
			case (state)
				
				// While waiting for reset, essentially do nothing.
				Waiting_For_Reset: 
					begin
						rst_n_init = 1;
						rst_n_ksa = 1;
						en_init = 0;
						en_ksa = 0;
						wren_mem = 0;
						rddata_ksa = 0;
						address_mem = 0;
						input_data_mem = 0;
					end
				
				Write_0_0:
					begin
						rst_n_init = 1;
						rst_n_ksa = 1;
						en_init = 0;
						en_ksa = 0;
						wren_mem = 1;
						rddata_ksa = 0;
						address_mem = 0;
						input_data_mem = 0;
					end
			
			
				// In this state we assert en when rdy is 1. 
				Init_Wait_For_Rdy:
					begin
						rst_n_init = 0;
						rst_n_ksa = 0;					
						en_ksa = 0;
						rddata_ksa = 0;
						address_mem = address_init;
						input_data_mem = wrdata_init;
						if (rdy_init == 1)
							begin
								en_init = 1;
								wren_mem = 1;
							end
						else
							begin
								en_init = 0;
								wren_mem = 0;
							end
					end
					
				// This state is to de-assert en. Also read requests the zero 
				// address of the memory in preparation for inputting into the 
				// next state.
				Init_Deassert_en1: 
					begin
						rst_n_init = 0;
						rst_n_ksa = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						en_init = 0;
						address_mem = index_counter[7:0];
						input_data_mem = 0;
						wren_mem = 0;
					end
				
				get_s_i: //3
					begin
						rst_n_init = 0;
						rst_n_ksa = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						en_init = 0;
						address_mem = 0;
						input_data_mem = 0;
						wren_mem = 0;
					end
					
				import_to_ksa: //4
					begin
						rst_n_init = 0;
						rst_n_ksa = 0;
						rddata_ksa = s_i;
						en_init = 0;
						address_mem = 0;
						input_data_mem = 0;
						wren_mem = 0;
						
						if (rdy_ksa == 1)
							en_ksa = 1;
						else
							en_ksa = 0;
					end
					
				request_s_j: //5
					begin
						rst_n_init = 0;
						rst_n_ksa = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						en_init = 0;
						address_mem = address_ksa;
						input_data_mem = 0;
						wren_mem = 0;
					end
					
				get_s_j: //6
					begin
						rst_n_init = 0;
						rst_n_ksa = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						en_init = 0;
						address_mem = 0;
						input_data_mem = 0;
						wren_mem = 0;
					end
					
				write_s_i: //7
					begin
						rst_n_init = 0;
						rst_n_ksa = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						en_init = 0;
						address_mem = j;
						input_data_mem = s_i;
						wren_mem = 1;
					end
					
				write_s_j: //8
					begin
						rst_n_init = 0;
						rst_n_ksa = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						en_init = 0;
						address_mem = index_counter[7:0] - 1;
						input_data_mem = s_j;
						wren_mem = 1;					
					end
					
				request_s_i_1: //9
					begin
						rst_n_init = 0;
						rst_n_ksa = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						en_init = 0;
						address_mem = index_counter[7:0];
						input_data_mem = 0;
						wren_mem = 0;					
					end
				
				Done:
					begin
						rst_n_init = 0;
						rst_n_ksa = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						en_init = 0;
						address_mem = 0;
						input_data_mem = 0;
						wren_mem = 0;
					end
				
			endcase
		end
			

endmodule: task2
