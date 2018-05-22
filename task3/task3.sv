module task3(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);


	// States for the top level module.
	localparam Waiting_to_start = 0;
	localparam Waiting_for_rdy = 1;
	localparam Deassert_en = 2;
	localparam Decrypting = 3;
	localparam Got_Done_Signal = 4;		 
			 
	// The encryption key determined by the switches on the board.
	// logic [23:0] key = 24'b000000000000000000000000;
	// logic [23:0] key = 'h1E4600;
	logic [23:0] key;
	assign key[9:0] = SW[9:0];
	assign key[23:10] = 0;
	
	logic [7:0] ct_addr;
	logic [7:0] ct_rddata;
	
	logic [7:0] pt_addr;
	logic [7:0] pt_rddata;
	logic [7:0] pt_wrdata;
	logic pt_wren;
	
	logic en = 0;
	logic rdy;
	
	logic [2:0] top_state = Waiting_to_start;
			 
    ct_mem ct(.address(ct_addr), .clock(CLOCK_50), .q(ct_rddata));
    pt_mem pt(.address(pt_addr), .clock(CLOCK_50), .data(pt_wrdata), 
		.wren(pt_wren), .q(pt_rddata));
    
	
	/*	
	input logic clk, input logic rst_n,
	input logic en, output logic rdy,
	input logic [23:0] key,
	output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
	output logic [7:0] pt_addr, input logic [7:0] pt_rddata, 
	output logic [7:0] pt_wrdata, output logic pt_wren
	*/
	
	arc4 a4(.clk(CLOCK_50), .rst_n(1), .en(en), .rdy(rdy), .key(key), 
		.ct_addr(ct_addr), .ct_rddata(ct_rddata), .pt_addr(pt_addr), 
		.pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren));
		
	always_ff @(posedge CLOCK_50)
		begin
			
			case(top_state)
			
				Waiting_to_start:
					begin
						if (KEY[3] == 0)
							top_state <= Waiting_for_rdy;
						else
							top_state <= Waiting_to_start;
					end
					
				Waiting_for_rdy:
					begin
						if (rdy == 1)
							top_state <= Deassert_en;
						else
							top_state <= Waiting_for_rdy;
					end
					
				Deassert_en:
					begin
						top_state <= Decrypting;
					end
					
				Decrypting:
					begin
						if (rdy == 1)
							top_state <= Got_Done_Signal;
						else
							top_state <= Decrypting;
					end
					
				Got_Done_Signal:
					begin
						top_state <= Waiting_to_start;
					end
					
			endcase
		end
		
		always_comb
			begin
			
				case(top_state)
				
					Waiting_to_start:
						begin
							en = 0;
						end
						
					Waiting_for_rdy:
						begin
							if (rdy == 1)
								en = 1;
							else
								en = 0;
						end
						
					Deassert_en:
						begin
							en = 0;
						end
						
					Decrypting:
						begin
							en = 0;
						end
						
					Got_Done_Signal:
						begin
							en = 0;
						end
				endcase
			
			end


	

endmodule: task3
