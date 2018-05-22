module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here

	logic en;
	logic rdy;
	logic [7:0] address;
	logic [7:0] data;
	logic value;
	logic [3:0] state = 0;
	
	
	// Defining local parameters for the states.

	
	
	/*
	input	[7:0]  address;
	input	  clock;
	input	[7:0]  data;
	input	  wren;
	output	[7:0]  q;
	*/
    s_mem s(.address(address), .clock(CLOCK_50), .data(data), .wren(en), .q(value));

	/*
	input logic clk, input logic rst_n,
	input logic en, output logic rdy,
	output logic [7:0] addr, output logic [7:0] wrdata, output logic wren
	*/
	init init(.clk(CLOCK_50), .rst_n(~KEY[3]), .en(en), .rdy(rdy), .addr(address), .wrdata(data), .wren());
	
	// Determines the state of the task1 state machine.
	always_ff @(posedge CLOCK_50)
		begin
			
			case(state)
				// Moves onto the next state if rdy is asserted.
				0: 
					begin
						if (rdy == 0)
							begin
								state = 0;
							end	
						else
							begin
								state = 1;
							end
					end
				// A couple things. This state is mainly for de-asserting en
				// but it also decides when we are done. This is based on the 
				// data coming from INIT.
				1: 
					begin
						if (data == 255)
							begin
								state = 2;
							end
						else
							begin
								state = 0;
							end
					end
					
				2:
					begin
						state = 2;
					end
					
			endcase

		end
		
	// Determines the data path for task1.
	always_comb
		begin		
			case (state)
				// In this state we assert en when rdy is 1. 
				0:
					begin
					
						if (rdy == 1)
							begin
								en = 1;
							end
						else
							begin
								en = 0;
							end
					end
				// This state is to de-assert en. 
				1: 
					begin
						en = 0;
					end
					
				2:
					begin
						en = 0;
					end
				
			endcase
		end
						
						
	
    // your code here

endmodule: task1
