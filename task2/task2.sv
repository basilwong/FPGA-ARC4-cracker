module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

	// Defining local parameter values for the the individual states of for
	// task 2.
	localparam Waiting_For_Reset = 0;
	localparam Init_Wait_For_Rdy = 1;
	localparam Deassert_en_init = 2;
	localparam Initializing = 3;
	localparam Done_Initializing = 4;
	localparam Ksa_Wait_For_Ready = 5;
	localparam Deassert_en_ksa = 6;
	localparam Ksaing = 7;
	localparam Done = 8;
	
	
	// Initiating the state variables for task2 to start in Waiting_For_Reset 
	// state.
	logic [3:0] state = Waiting_For_Reset;
	
	// Variables for managing the enable for each instantiated module.
	logic en_init;
	logic en_ksa;
	logic wren_mem;
	
	// Variables for the rdy variables of init and ksa.
	logic rdy_init;
	logic rdy_ksa;
	
	// The data variables for interaction with the init module.
	logic [7:0] address_init; // Output
	logic [7:0] wrdata_init; // Output
	logic wren_init; // Output
	
	// The data variables for interaction with the ksa module.
	logic [7:0] rddata_ksa; // Input 
	logic [7:0] address_ksa; // Output
	logic [7:0] wrdata_ksa; // Output
	logic wren_ksa; // Output
	
	
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
			 
    s_mem s(.address(address_mem), .clock(CLOCK_50), .data(input_data_mem), 
		.wren(wren_mem), .q(read_value_mem));
	
	init init(.clk(CLOCK_50), .rst_n(1), .en(en_init), .rdy(rdy_init), 
		.addr(address_init), .wrdata(wrdata_init), .wren(wren_init));

	ksa ksa(.clk(CLOCK_50), .rst_n(1), .en(en_ksa), .rdy(rdy_ksa), 
		.key(key), .addr(address_ksa), .rddata(rddata_ksa), .wrdata(wrdata_ksa),
		.wren(wren_ksa));
		
    // Determines the state of the task1 state machine.
	always_ff @(posedge CLOCK_50)
		begin
			
			case(state)
			
				Waiting_For_Reset:
					begin
						if (KEY[3] == 0)
							begin
								state = Init_Wait_For_Rdy ;
							end
						else
							begin
								state = Waiting_For_Reset;
							end
					end
				
				Init_Wait_For_Rdy: 
					begin
						if (rdy_init == 0)
							begin
								state = Init_Wait_For_Rdy;
							end	
						else
							begin
								state = Deassert_en_init;
							end
					end
				
				Deassert_en_init:
					begin
						state = Initializing;
					end
				
				Initializing: 
					begin
						if (rdy_init == 1)
							begin
								state = Done_Initializing;
							end
						else
							begin
								state = Initializing;
							end
					end
					
				Done_Initializing:
					begin
						state = Ksa_Wait_For_Ready;
					end
				
				Ksa_Wait_For_Ready: 
					begin
						if (rdy_ksa == 0)
							begin
								state = Ksa_Wait_For_Ready;
							end	
						else
							begin
								state = Deassert_en_ksa;
							end
					end
				
				Deassert_en_ksa:
					begin
						state = Ksaing;
					end
				
				Ksaing: 
					begin
						if (rdy_ksa == 1)
							begin
								state = Done;
							end
						else
							begin
								state = Ksaing;
							end
					end
					
				Done:
					begin
						state = Waiting_For_Reset;
					end
			endcase

		end
	
	always_comb
		begin		
			case (state)
				
				Waiting_For_Reset: 
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = 0;
						address_mem = 0;
						input_data_mem = 0;
					end
					
				Init_Wait_For_Rdy:
					begin
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = 0;
						address_mem = 0;
						input_data_mem = 0;
						
						if (rdy_init == 1)
							en_init = 1;
						else
							en_init = 0;
					end
					
				Deassert_en_init:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = wren_init;
						address_mem = address_init;
						input_data_mem = wrdata_init;
					end
					
				Initializing:	
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = wren_init;
						address_mem = address_init;
						input_data_mem = wrdata_init;
					end
					
				Done_Initializing:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = 0;
						address_mem = 0;
						input_data_mem = 0;
					end
					
				Ksa_Wait_For_Ready:
					begin
						en_init = 0;
						rddata_ksa = 0;
						wren_mem = 0;
						address_mem = 0;
						input_data_mem = 0;
						
						if (rdy_ksa == 1)
							en_ksa = 1;
						else
							en_ksa = 0;
					end
				
				Deassert_en_ksa:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = read_value_mem;
						wren_mem = wren_ksa;
						address_mem = address_ksa;
						input_data_mem = wrdata_ksa;
					end
					
				Ksaing:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = read_value_mem;
						wren_mem = wren_ksa;
						address_mem = address_ksa;
						input_data_mem = wrdata_ksa;
					end
					
				Done:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = 0;
						address_mem = 0;
						input_data_mem = 0;
					end
				
			endcase
		end
			

endmodule: task2
