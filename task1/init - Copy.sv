module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

// your code here

	// These are the states of the state machine. 
	localparam Not_Ready = 1;
	localparam Ready = 2;
	localparam Reset = 3;
	
	logic [3:0] state = Ready;
	logic [7:0] S = 0;
		
	// For the purposes of this module, the address and the write data are going
	// to be the same. 
	assign wrdata = S;
	assign addr = S;
	
	always_ff @(posedge clk)
		begin
			case(state)	
			
				// Takes one clock cycle to update the S value to itself plus 1.
				// If the S value reaches 255 then it takes an extra clock cycle
				// to go back to 0.
				Not_Ready:
					begin
						
						if (S == 255)
							begin
								state <= Not_Ready;
								rdy <= 0;
								S <= 0;
							end
						else 
							begin
								if (rst_n == 1)
									begin
										state <= Not_Ready;
										rdy <= 0;
										S <= 0;
									end
								else
									begin
										state <= Ready;
										rdy <= 1;
										S <= S + 1;
									end
							end
							
					end
					
				// In the 'Ready' state the we are ready to output the S value.
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
										state <= Not_Ready;
										rdy <= 0;
										S <= 0;
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
						S <= 0;
					end			
					
			endcase
						
		end
	
	
endmodule: init