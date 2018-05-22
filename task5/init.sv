module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

// your code here

	// These are the states of the state machine. 
	localparam Ready_To_Start = 0;
	localparam Write_To_Mem = 1;
	localparam Update_S = 2;
	localparam Done = 3;
	
	logic [3:0] state = Ready_To_Start;
	logic [7:0] S = 0;
		
	assign wrdata = S;
	assign addr = S;
	
	always_ff @(posedge clk, negedge rst_n)
		begin
			
			if (rst_n == 0)
				state = Ready_To_Start;
		
			case(state)	
			
				Ready_To_Start:
					begin
						if (en == 1)
							begin
								state <= Write_To_Mem;
								rdy <= 0;
								S <= 0;
							end
						else
							begin
								state <= Ready_To_Start;
								rdy <= 1;
								S <= 0;
							end
							
					end
					
				Write_To_Mem:
					begin
						state <= Update_S;
					end
					
				Update_S:
					begin
						if (S < 255)
							begin
								S <= S + 1;
								state = Write_To_Mem;
							end
						else 
							begin
								state <= Done;
							end
					end	

				Done:
					begin
						rdy <= 1;
						state <= Ready_To_Start;
					end
					
			endcase
						
		end
		
	always_comb
		begin
		
			case(state)
			Ready_To_Start:
				begin
					wren = 0;
				end
				
			Write_To_Mem:
				begin
					wren = 1;
				end
				
			Update_S:
				begin
					wren = 0;
				end
				
			Done:
				begin
					wren = 0;
				end
			endcase
		end
	
	
endmodule: init