module crack2(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

			 
	localparam Waiting_for_en = 0;
	localparam Wait_for_arc4_rdy = 1;
	localparam Deassert_en = 2;
	localparam Run_Arc4 = 3;
	localparam Request_message_legnth = 4;
	localparam Get_message_length = 5;
	localparam Request_word = 6;
	localparam Get_word = 7;
	localparam Check_Word = 8;
	localparam Update_index = 9;
	localparam Update_key = 10;
	localparam Done_Valid_key_1 = 11;
	localparam Done_Valid_key_2 = 12;
	localparam Done_Non_Valid_key_1 = 13;
	localparam Done_Non_Valid_key_2 = 14;
	localparam Init = 15;
	
	logic [5:0] state = Init;
	
	logic [7:0] index = 0;
	logic [7:0] word = 0;
	logic [7:0]	message_length = 0;
			 
	logic [7:0] pt_addr_mem;
	logic [7:0] pt_rddata_mem;
	logic [7:0] pt_wrdata_mem;
	logic pt_wren_mem;
	
	logic [7:0] ct_addr_arc4;
	logic [7:0] ct_rddata_arc4;
	logic [7:0] pt_addr_arc4;
	logic [7:0] pt_rddata_arc4;
	logic [7:0] pt_wrdata_arc4;
	logic pt_wren_arc4;
	
	logic en_arc4;
	logic rdy_arc4;
	
	pt_mem_2 s3(.address(pt_addr_mem), .clock(clk), .data(pt_wrdata_mem), 
	.wren(pt_wren_mem), .q(pt_rddata_mem));
	
	arc4_2 a4_2(.clk(clk), .rst_n(rst_n), .en(en_arc4), .rdy(rdy_arc4), .key(key), 
		.ct_addr(ct_addr_arc4), .ct_rddata(ct_rddata_arc4), .pt_addr(pt_addr_arc4), 
		.pt_rddata(pt_rddata_arc4), .pt_wrdata(pt_wrdata_arc4), .pt_wren(pt_wren_arc4));

    
	
	always_ff @(posedge clk)
		begin
	
			case(state)
					Init:
						begin
							state = Waiting_for_en;
							key_valid = 0;
							rdy = 1;
						end
			
					Waiting_for_en:
						begin
							index = 0;
							word = 0;
							key = 1;
							message_length = 0;
							
							if (en == 1)
								begin
									state = Wait_for_arc4_rdy;
									rdy = 0;
								end
							else 
								begin
									state = Waiting_for_en;
									rdy = 1;
								end
						end
						
					Wait_for_arc4_rdy:
						begin
							key_valid = 0;
							if (rdy_arc4 == 1)	
								begin
									state = Deassert_en;
								end
							else
								begin
									state = Wait_for_arc4_rdy;
								end
						end
						
					Deassert_en:
						begin
							state = Run_Arc4;
						end
						
					Run_Arc4:
						begin
							if (rdy_arc4 == 1)	
								begin
									state = Request_message_legnth;
								end
							else
								begin
									state = Run_Arc4;
								end
						end
						
					Request_message_legnth:
						begin
							state = Get_message_length;
						end
						
					Get_message_length:
						begin
							state = Request_word;
							message_length = ct_rddata;
						end
						
					Request_word:
						begin
							state = Get_word;
						end
						
					Get_word:
						begin
							state = Check_Word;
							word = pt_rddata_mem;
						end
						
					Check_Word: //8
						begin
							if ((word >= 'h20) && (word <= 'h7E))
								begin
									if (index == (message_length - 1))
										begin
											state = Done_Valid_key_1;
										end
									else
										begin
											state = Request_word;
											index = index + 1;
										end
								end
							else
								begin
									if (rst_n == 0)
										begin
											state = Init;
										end
									else
										begin
										
											state = Update_key;
											index = 0;
										end
								end	
						end
						
					// Update_index: //9
						// begin
							
						// end
						
					Update_key: //10
						begin
							if (key < 'b111111111111111111111110)
								begin
									state = Wait_for_arc4_rdy;
									key = key + 2;
								end
							else
								begin
									state = Done_Non_Valid_key_1;
								end
						end
						
					Done_Valid_key_1:
						begin
							state = Done_Valid_key_2;
							key_valid = 1;
							rdy = 1;
						end
						
					Done_Valid_key_2:
						begin
							if (en == 1)
								begin
									state = Wait_for_arc4_rdy;
									rdy = 0;
									key = 1;
								end
							else 
								begin
									state = Waiting_for_en;
									rdy = 1;
								end
						end
						
					Done_Non_Valid_key_1:
						begin
							state = Done_Non_Valid_key_2;
							key_valid = 0;
							rdy = 1;
						end
						
					Done_Non_Valid_key_2:
						begin
							if (en == 1)
								begin
									state = Wait_for_arc4_rdy;
									key = 1;
									rdy = 0;
								end
							else 
								begin
									state = Waiting_for_en;
									rdy = 1;
								end
						end
						
			endcase
		end
	
	always_comb
		begin
			case(state)
			
					Init:
						begin
							en_arc4 = 0;
							ct_addr  = 0;
							pt_addr_mem = 0;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
						end
			
					Waiting_for_en:
						begin
							en_arc4 = 0;
							ct_addr  = 0;
							pt_addr_mem = 0;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
						end
						
					Wait_for_arc4_rdy:
						begin
							ct_addr  = 0;
							pt_addr_mem = 0;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
							
							if (rdy_arc4 == 1)
								en_arc4 = 1;
							else
								en_arc4 = 0;
						end
						
					Deassert_en:
						begin
							en_arc4 = 0;
							ct_addr  = ct_addr_arc4;
							pt_addr_mem = pt_addr_arc4;
							pt_wrdata_mem = pt_wrdata_arc4;
							pt_wren_mem = pt_wren_arc4;
							pt_rddata_arc4 = pt_rddata_mem;
							ct_rddata_arc4 = ct_rddata;
						end
						
					Run_Arc4:
						begin
							en_arc4 = 0;
							ct_addr  = ct_addr_arc4;
							pt_addr_mem = pt_addr_arc4;
							pt_wrdata_mem = pt_wrdata_arc4;
							pt_wren_mem = pt_wren_arc4;
							pt_rddata_arc4 = pt_rddata_mem;
							ct_rddata_arc4 = ct_rddata;
						end
						
					Request_message_legnth:
						begin
							en_arc4 = 0;
							ct_addr  = 0;
							pt_addr_mem = 0;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
						end
						
					Get_message_length:
						begin
							en_arc4 = 0;
							ct_addr  = 0;
							pt_addr_mem = 0;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
						end
						
					Request_word:
						begin
							en_arc4 = 0;
							ct_addr  = 0;
							pt_addr_mem = index;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
						end
						
					Get_word:
						begin
							en_arc4 = 0;
							ct_addr  = 0;
							pt_addr_mem = 0;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
						end
						
					Check_Word:
						begin
							en_arc4 = 0;
							ct_addr  = 0;
							pt_addr_mem = 0;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
						end
						
					// Update_index:
						// begin
							// en_arc4 = 0;
							// ct_addr  = 0;
							// pt_addr_mem = 0;
							// pt_wrdata_mem = 0;
							// pt_wren_mem = 0;
							// pt_rddata_arc4 = 0;
							// ct_rddata_arc4 = 0;
						// end
						
					Update_key:
						begin
							en_arc4 = 0;
							ct_addr  = 0;
							pt_addr_mem = 0;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
						end
						
					Done_Valid_key_1:
						begin
							en_arc4 = 0;
							ct_addr  = 0;
							pt_addr_mem = 0;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
						end
					
					Done_Valid_key_2:
						begin
							en_arc4 = 0;
							ct_addr  = 0;
							pt_addr_mem = 0;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
						end
					
					Done_Non_Valid_key_1:
						begin
							en_arc4 = 0;
							ct_addr  = 0;
							pt_addr_mem = 0;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
						end
						
					Done_Non_Valid_key_2:
						begin
							en_arc4 = 0;
							ct_addr  = 0;
							pt_addr_mem = 0;
							pt_wrdata_mem = 0;
							pt_wren_mem = 0;
							pt_rddata_arc4 = 0;
							ct_rddata_arc4 = 0;
						end
						
						
			endcase
		end



endmodule: crack2
