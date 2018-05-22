module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, 
		   output logic [7:0] wrdata, output logic wren);

	// These are the states of the state machine. 
	localparam Ready = 0;
	localparam Not_Ready = 1;
	localparam Reset = 2;
		  
	logic [3:0] state = Ready;
	
	logic [7:0] index_counter = 0;
	logic [14:0] j = 0;
	
	assign addr = j;
		   
	// This always block deals with the statemachine of the ksa module and also
	// the output of rdy.
    always_ff @(posedge clk)
		begin
			case(state)
				
				Ready: 
					begin
						// en == 1 means we have output the S value, now back to 
						// the not ready state to update S value. 
						if (en == 1)
							begin
								rdy <= 0;
								state <= Not_Ready;
							end
						// en == 0 means we state in the Ready state. 
						else
							begin
								if (rst_n == 1)
									begin
										state <= Reset;
										rdy <= 0;
									end
								else
									begin
										state <= Ready;
										rdy <= 1;
									end
							end
						
						
					end
					
				Not_Ready:
					begin
						if (index_counter == 255)
							begin
								state <= Reset;
								rdy <= 0;
							end
						else 
							begin
								if (rst_n == 1)
									begin
										state <= Reset;
										rdy <= 0;
									end
								else
									begin
										state <= Ready;
										rdy <= 1;
									end
							end
					end
					
				Reset:
					begin
						rdy <= 0;
						state <= Ready;
					end
				
					
			endcase
			
		end
	
	always_ff @(posedge clk)
		begin
			if (en == 1)
				begin
					// Calculating the new j.
					if (index_counter % 3 == 2)
						begin
							j = (j + rddata + key[7:0]) % 256;	
							// j = j + rddata + key[7:0];
						end
					else if (index_counter % 3 == 1)
						begin
							j = (j + rddata + key[15:8]) % 256;
						end
					else
						begin
							j = (j + rddata + key[23:16]) % 256;
						end

					// The index counter should increment.
					if (index_counter == 255)
						begin
							index_counter <= 0;
						end
					else
						begin
							index_counter <= index_counter + 1;
						end
				end
			
			if (rst_n == 1)
				begin
					j = 0;
					index_counter <= 0;
				end
		end

endmodule: ksa
