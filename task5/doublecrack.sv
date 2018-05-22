module doublecrack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

	localparam Init = 0;
	localparam Waiting_for_en = 1;
	localparam Request_Message_Length = 2;
	localparam Get_Message_Length = 3;
	localparam Write_Message_Length = 4;
	localparam Request_Message_Word = 5;
	localparam Write_Message_Word = 6;
	localparam Wait_for_rdy_1 = 7;
	localparam Wait_for_rdy_2 = 8;
	localparam Deassert = 9;
	localparam Wait_for_done = 10;
	localparam Wait_for_done_2 = 11;
	localparam Done = 12;
			 
	// Statemachine Variables
	logic [7:0] state = Init;
	// rdy
	logic [7:0] message_length;
	logic [7:0] message_index;
	// logic [7:0] message_word; // Only if we decide to do it less efficiently.
	logic rst_1 = 1;
	
	// Datapath Variables
	logic [7:0] copy_addr; // Input
	logic [7:0] copy_wrdata; // Input
	logic copy_wren; // Input
	logic [7:0] copy_q; // Output 
	
	// en
	
	logic en_1; // Input
	logic en_2; // Input
	logic rdy_1;  // Output
	logic rdy_2; // Output
	logic [23:0] key_1; // Output
	logic [23:0] key_2; // Output
	logic key_valid_1; // Output
	logic key_valid_2; // Output
	logic [7:0] ct_addr_1; // Input
	logic [7:0] ct_addr_2; // Input
	logic [7:0] ct_rddata_1; // Input
	logic [7:0] ct_rddata_2; // Input
	
	copy_mem s3(.address(copy_addr), .clock(clk), .data(copy_wrdata), 
		.wren(copy_wren), .q(copy_q));
		
	/*
	(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata)
	*/
	
	crack1 crk1(.clk(clk), .rst_n(rst_1), .en(en_1), .rdy(rdy_1), .key(key_1),
		.key_valid(key_valid_1), .ct_addr(ct_addr_1), .ct_rddata(ct_rddata_1));
	
	crack2 crk2(.clk(clk), .rst_n(rst_1), .en(en_2), .rdy(rdy_2), .key(key_2),
		.key_valid(key_valid_2), .ct_addr(ct_addr_2), .ct_rddata(ct_rddata_2));
	
	always_ff @(posedge clk, negedge rst_n)
		begin
		
			if (rst_n == 0)
				state = Init;
		
		case(state)
			
			Init:
				begin
					state = Waiting_for_en;
					key = 0;
					key_valid = 0;
					rdy = 0;
					message_length = 0;
					message_index = 0;
			
				end
			Waiting_for_en:
				begin
					message_index = 0;
					
					if (en == 1)
						begin
							state = Request_Message_Length;
							rdy = 0;
							rst_1 = 1;
						end
					else 
						begin
							state = Waiting_for_en;
							rdy = 1;
							rst_1 = 0;
						end
				end
			Request_Message_Length:
				begin
					state = Get_Message_Length;
				end
			Get_Message_Length:
				begin
					state = Write_Message_Length;
					message_length = ct_rddata;
				end
			Write_Message_Length:
				begin
					state = Request_Message_Word;
					message_index = 1;
				end
			Request_Message_Word:
				begin
					state = Write_Message_Word;
				end
			Write_Message_Word:
				begin
					if (message_index < message_length)
						begin
							state = Request_Message_Word;
							message_index = message_index + 1;
						end
					else
						begin
							state = Wait_for_rdy_1;
						end
				end
			Wait_for_rdy_1:
				begin
					if (rdy_1 == 1)
						begin
							state = Wait_for_rdy_2;
						end
					else
						begin
							state = Wait_for_rdy_1;
						end
				end
			Wait_for_rdy_2: // 8
				begin
					if (rdy_2 == 1)
						begin
							state = Deassert;
						end
					else
						begin
							state = Wait_for_rdy_2;
						end
				end
			Deassert: // 9
				begin
					state = Wait_for_done;
				end
			Wait_for_done: // 10
				begin
					if (rdy_1 == 1)
						begin
							if (key_valid_1 == 1)
								begin
									state = Done;
									key = key_1;
									key_valid = 1;
								end
							else
								begin
									state = Wait_for_done_2;
								end
						end
					else
						begin
							if (rdy_2 == 1)
								begin
									if (key_valid_2 == 1)
										begin
											state = Done;
											key = key_2;
											key_valid = 1;
										end
									else
										begin
											state = Done;
											key = 0;
											key_valid = 0;
										end
								end
							else
								begin
									state = Wait_for_done;
								end
						end
				end
			Wait_for_done_2: // 11
				begin
					if (rdy_2 == 1)
						begin
							if (key_valid_2 == 1)
								begin
									state = Done;
									key = key_2;
									key_valid = 1;
								end
							else
								begin
									state = Done;
									key = 0;
									key_valid = 0;
								end
						end
					else
						begin
							state = Wait_for_done_2;
						end
				end
			Done:
				begin
					rdy = 1;
					state = Waiting_for_en;	
					rst_1 = 0;
				end
		
		endcase
		
		end
	
	always_comb
		begin
		
		case(state)
		
			Init:
				begin
					en_1 = 0;
					en_2 = 0;
					ct_addr = 0;
					copy_addr = 0;
					copy_wrdata = 0;
					copy_wren = 0;
					ct_rddata_1 = 0;
					ct_rddata_2 = 0; 
				end
			Waiting_for_en:
				begin
					en_1 = 0;
					en_2 = 0;
					ct_addr = 0;
					copy_addr = 0;
					copy_wrdata = 0;
					copy_wren = 0; 
					ct_rddata_1 = 0;
					ct_rddata_2 = 0; 
				end
			Request_Message_Length:
				begin
					en_1 = 0;
					en_2 = 0;
					ct_addr = message_index;
					copy_addr = 0;
					copy_wrdata = 0;
					copy_wren = 0;
					ct_rddata_1 = 0;
					ct_rddata_2 = 0; 
				end
			Get_Message_Length:
				begin
					en_1 = 0;
					en_2 = 0;
					ct_addr = 0;
					copy_addr = 0;
					copy_wrdata = 0;
					copy_wren = 0;
					ct_rddata_1 = 0;
					ct_rddata_2 = 0; 
				end
			Write_Message_Length:
				begin
					en_1 = 0;
					en_2 = 0;
					ct_addr = 0;
					copy_addr = message_index;
					copy_wrdata = message_length;
					copy_wren = 1;
					ct_rddata_1 = 0;
					ct_rddata_2 = 0; 
				end
			Request_Message_Word:
				begin
					en_1 = 0;
					en_2 = 0;
					ct_addr = message_index;
					copy_addr = 0;
					copy_wrdata = 0;
					copy_wren = 0; 
					ct_rddata_1 = 0;
					ct_rddata_2 = 0; 
				end
			Write_Message_Word:
				begin
					en_1 = 0;
					en_2 = 0;
					ct_addr = 0;
					copy_addr = message_index;
					copy_wrdata = ct_rddata;
					copy_wren = 1;
					ct_rddata_1 = 0;
					ct_rddata_2 = 0; 
				end
			Wait_for_rdy_1:
				begin
					en_2 = 0;
					ct_addr = 0;
					copy_addr = 0;
					copy_wrdata = 0;
					copy_wren = 0;
					ct_rddata_1 = 0;
					ct_rddata_2 = 0; 
					
					if (rdy_1 == 1)
								en_1 = 1;
							else
								en_1 = 0;
				end
			Wait_for_rdy_2:
				begin
					en_1 = 0;
					ct_addr = 0;
					copy_addr = 0;
					copy_wrdata = 0;
					copy_wren = 0;
					ct_rddata_1 = 0;
					ct_rddata_2 = 0;
					
					if (rdy_2 == 1)
								en_2 = 1;
							else
								en_2 = 0;
				end
			Deassert:
				begin
					en_1 = 0;
					en_2 = 0;
					ct_addr = ct_addr_1;
					copy_addr = ct_addr_2;
					copy_wrdata = 0;
					copy_wren = 0;
					ct_rddata_1 = ct_rddata;
					ct_rddata_2 = copy_q;
				end
			Wait_for_done:
				begin
					en_1 = 0;
					en_2 = 0;
					ct_addr = ct_addr_1;
					copy_addr = ct_addr_2;
					copy_wrdata = 0;
					copy_wren = 0;
					ct_rddata_1 = ct_rddata;
					ct_rddata_2 = copy_q;
				end
			Wait_for_done_2:
				begin
					en_1 = 0;
					en_2 = 0;
					ct_addr = ct_addr_1;
					copy_addr = ct_addr_2;
					copy_wrdata = 0;
					copy_wren = 0;
					ct_rddata_1 = ct_rddata;
					ct_rddata_2 = copy_q;
				end
			Done:
				begin
					en_1 = 0;
					en_2 = 0;
					ct_addr = 0;
					copy_addr = 0;
					copy_wrdata = 0;
					copy_wren = 0;
					ct_rddata_1 = 0;
					ct_rddata_2 = 0; 
				end

		
		endcase
		
		
		end

endmodule: doublecrack
