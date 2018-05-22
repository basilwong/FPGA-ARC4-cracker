module task4(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);


	// States for the top level module.
	localparam Waiting_to_start = 0;
	localparam Waiting_for_rdy = 1;
	localparam Deassert_en = 2;
	localparam Cracking = 3;
	localparam Got_Done_Signal = 4;		

	logic [2:0] top_state = Waiting_to_start;
	
	logic [7:0] ct_addr;
	logic [7:0] ct_rddata;
	
	logic en = 0;
	logic rdy;
	
	logic [23:0] key = 0;
	logic [23:0] key_output;
	logic key_valid;
	
	logic [4:0] hex_0;
	logic [4:0] hex_1;
	logic [4:0] hex_2;
	logic [4:0] hex_3;
	logic [4:0] hex_4;
	logic [4:0] hex_5;
			 
    ct_mem ct(.address(ct_addr), .clock(CLOCK_50), .q(ct_rddata));    
	
	crack crk(.clk(CLOCK_50), .rst_n(1), .en(en), .rdy(rdy),
            .key(key_output), .key_valid(key_valid), .ct_addr(ct_addr), 
			.ct_rddata(ct_rddata));
			
	segger7 HEX_0(.seg7(HEX0), .card(hex_0));
	segger7 HEX_1(.seg7(HEX1), .card(hex_1));
	segger7 HEX_2(.seg7(HEX2), .card(hex_2));

	segger7 HEX_3(.seg7(HEX3), .card(hex_3));
	segger7 HEX_4(.seg7(HEX4), .card(hex_4));
	segger7 HEX_5(.seg7(HEX5), .card(hex_5));		
	
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
					
				Waiting_for_rdy: //1
					begin
						key = 0;
						if (rdy == 1)
							top_state <= Deassert_en;
						else
							top_state <= Waiting_for_rdy;
					end
					
				Deassert_en: //2
					begin
						top_state <= Cracking;
					end
					
				Cracking: //3
					begin
						if (rdy == 1)
							begin
								top_state <= Got_Done_Signal;
								key <= key_output;
							end
						else
							top_state <= Cracking;
					end
					
				Got_Done_Signal: //4
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
							if (key_valid == 1)
								begin
									hex_0  = key[3:0];
									hex_1  = key[7:4];
									hex_2  = key[11:8];
									hex_3  = key[15:12];
									hex_4  = key[19:16];
									hex_5  = key[23:20];
								end
							else
								begin
									hex_0  = 16;
									hex_1  = 16;
									hex_2  = 16;
									hex_3  = 16;
									hex_4  = 16;
									hex_5  = 16;
								end
						end
						
					Waiting_for_rdy:
						begin
							if (rdy == 1)
								en = 1;
							else
								en = 0;
								
							hex_0  = 17;
							hex_1  = 17;
							hex_2  = 17;
							hex_3  = 17;
							hex_4  = 17;
							hex_5  = 17;
						end
						
					Deassert_en:
						begin
							en = 0;
							hex_0  = 17;
							hex_1  = 17;
							hex_2  = 17;
							hex_3  = 17;
							hex_4  = 17;
							hex_5  = 17;
						end
						
					Cracking:
						begin
							en = 0;
							hex_0  = 17;
							hex_1  = 17;
							hex_2  = 17;
							hex_3  = 17;
							hex_4  = 17;
							hex_5  = 17;
						end
						
					Got_Done_Signal:
						begin
							en = 0;
							if (key_valid == 1)
								begin
									hex_0  = key[3:0];
									hex_1  = key[7:4];
									hex_2  = key[11:8];
									hex_3  = key[15:12];
									hex_4  = key[19:16];
									hex_5  = key[23:20];
								end
							else
								begin
									hex_0  = 16;
									hex_1  = 16;
									hex_2  = 16;
									hex_3  = 16;
									hex_4  = 16;
									hex_5  = 16;
								end
						end
				endcase
			
			end

endmodule: task4
