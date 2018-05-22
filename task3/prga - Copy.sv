module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

	localparam Waiting_for_en = 0;
	localparam Request_Message_Length = 1;
	localparam Get_Message_Length = 2;
	localparam Request_Encrpyted = 3;
	localparam Get_Encrypted = 4;
	localparam Update_i = 5;
	localparam Request_s_i = 6;
	localparam Get_s_i = 7;
	localparam Update_j = 8;
	localparam Request_s_j = 9;
	localparam Get_s_j = 10;
	localparam Write_s_i_to_j = 11;
	localparam Write_s_j_to_i = 12;
	localparam Request_Pad_k = 13;
	localparam Get_Pad_k = 14;
	localparam Write_Plaintext = 15;
	localparam Update_k = 16;
	
	logic [5:0] state = Waiting_for_en;
	
	logic [7:0] i = 0;
	logic [7:0] j = 0;
	logic [7:0] k = 0;
	logic [7:0] message_length = 0;
	logic [7:0] s_i = 0;
	logic [7:0] s_j = 0;
	logic [7:0] encrypted_byte = 0;
	logic [7:0] pad_k = 0;
	
	always_ff @(posedge clk)
		begin
	
			case(state)
			
				Waiting_for_en:
					begin
						i = 0;
						j = 0;
						k = 0;
						message_length = 0;
						s_i = 0;
						s_j = 0;
						encrypted_byte = 0;
						pad_k = 0;
						
						if (en == 1)
							begin
								rdy = 0;
								state = Request_Message_Length;
							end
						else 
							begin
								rdy = 1;
								state = Waiting_for_en;
							end
					end
					
					
				Request_Message_Length:
					begin
						state = Get_Message_Length;
					end
				
				Get_Message_Length:
					begin
						state = Request_Encrpyted;
						message_length = ct_rddata;
						k = 1;
					end
					
				Request_Encrpyted:
					begin
						state = Get_Encrypted;
					end
					
				Get_Encrypted:
					begin
						state = Update_i;
						encrypted_byte = ct_rddata;
					end
					
				Update_i:
					begin
						state = Request_s_i;
						i = (i + 1) % 256;
					end
					
				Request_s_i:
					begin
						state = Get_s_i;
					end
					
				Get_s_i:
					begin
						state = Update_j;
						s_i = s_rddata;
					end
					
				Update_j:
					begin
						state = Request_s_j;
						j = (j + s_i) % 256;
					end
					
				Request_s_j:
					begin
						state = Get_s_j;
					end
					
				Get_s_j:
					begin
						state = Write_s_i_to_j;
						s_j = s_rddata;
					end
					
				Write_s_i_to_j:
					begin
						state = Write_s_j_to_i;
					end
					
				Write_s_j_to_i:
					begin
						state = Request_Pad_k;
					end
					
				Request_Pad_k:
					begin
						state = Get_Pad_k;
					end
					
				Get_Pad_k:
					begin
						state = Write_Plaintext;
						pad_k = s_rddata;
					end
					
				Write_Plaintext:
					begin
						state = Update_k;
					end
				
				Update_k:
					begin
						if (k < (message_length - 1))
							begin
								state = Get_Encrypted;
								k = k + 1;
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
				
					Waiting_for_en:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
						
					Request_Message_Length:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
					
					Get_Message_Length:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
					Request_Encrpyted:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = k;
						end
						
					Get_Encrypted:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
					Update_i:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
					Request_s_i:
						begin
							s_addr = i;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
					Get_s_i:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
					Update_j:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
					Request_s_j:
						begin
							s_addr = j;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
					Get_s_j:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
					Write_s_i_to_j:
						begin
							s_addr = j;
							s_wrdata = s_i;
							s_wren = 1;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
					Write_s_j_to_i:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
					Request_Pad_k:
						begin
							s_addr = k;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
					Get_Pad_k:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
						
					Write_Plaintext:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = k - 1;
							pt_wrdata = pad_k ^ encrypted_byte;
							pt_wren = 1;
							
							ct_addr = 0;
						end
					
					Update_k:
						begin
							s_addr = 0;
							s_wrdata = 0;
							s_wren = 0;
							
							pt_addr = 0;
							pt_wrdata = 0;
							pt_wren = 0;
							
							ct_addr = 0;
						end
			
				endcase
			
			
			end
			
			
endmodule: prga
