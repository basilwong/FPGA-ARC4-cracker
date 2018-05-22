module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, 
		   output logic [7:0] wrdata, output logic wren);

	// These are the states of the state machine. 
	localparam Waiting_For_en = 0;
	localparam request_s_i = 1;
	localparam get_s_i = 2;
	localparam update_j = 3;
	localparam request_s_j = 4;
	localparam get_s_j = 5;
	localparam write_s_i = 6;
	localparam write_s_j = 7;
	localparam update_i = 8;
	localparam Done = 9;
		  
	logic [4:0] state = Waiting_For_en;	
	
	logic [7:0] i = 0;
	logic [7:0] j = 0;
	
	logic [7:0] s_i = 0;
	logic [7:0] s_j = 0;
	
    always_ff @(posedge clk, negedge rst_n)
		begin
			if (rst_n == 0)
				state = Waiting_For_en;
		
			case(state)
				
				Waiting_For_en:
					begin
						i = 0;
						j = 0;
						s_i = 0;
						s_j = 0;
						if (en == 1)
							begin
								state = request_s_i;
								rdy = 0;
							end
						else
							begin
								state = Waiting_For_en;
								rdy = 1;
							end
					end
				
				request_s_i:
					begin
						state = get_s_i;
					end
				
				get_s_i:
					begin
						state = update_j;
						s_i = rddata;
					end
					
				update_j:
					begin
						state = request_s_j;
						if (i % 3 == 2)
							begin
								j = (j + s_i + key[7:0]) % 256;	
							end
						else if (i % 3 == 1)
							begin
								j = (j + s_i + key[15:8]) % 256;
							end
						else
							begin
								j = (j + s_i + key[23:16]) % 256;
							end
					end
					
				request_s_j:
					begin
						state = get_s_j;						
					end
					
				get_s_j:
					begin
						state = write_s_i;
						s_j = rddata;
					end
					
				write_s_i:
					begin
						state <= write_s_j;						
					end
					
				write_s_j:
					begin
						state <= update_i;
					end
					
				update_i:
					begin
						
						if (i < 255)
							begin
								i = i + 1;
								state = request_s_i;
							end
						else
							begin
								state <= Done;
							end
					end
				
				Done:
					begin
						rdy = 1;
						state <= Waiting_For_en;
					end
			endcase
			
		end
	
	always_comb
		begin
			case(state)
			Waiting_For_en:
				begin
					addr = 0;
					wrdata = 0;
					wren = 0;
				end
				
			request_s_i:
				begin
					addr = i;
					wrdata = 0;
					wren = 0;
				end
				
			get_s_i:
				begin
					addr = 0;
					wrdata = 0;
					wren = 0;
				end
				
			update_j:
				begin
					addr = 0;
					wrdata = 0;
					wren = 0;
				end
			
			request_s_j:
				begin
					addr = j;
					wrdata = 0;
					wren = 0;
				end
				
			get_s_j:
				begin
					addr = 0;
					wrdata = 0;
					wren = 0;
				end
				
			write_s_i:
				begin
					addr = j;
					wrdata = s_i;
					wren = 1;
				end
				
			write_s_j:
				begin
					addr = i;
					wrdata = s_j;
					wren = 1;
				end
				
			update_i:
				begin
					addr = 0;
					wrdata = 0;
					wren = 0;
				end
				
			Done:
				begin
					addr = 0;
					wrdata = 0;
					wren = 0;
				end
			endcase

		end

endmodule: ksa
