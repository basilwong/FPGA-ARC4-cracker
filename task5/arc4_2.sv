module arc4_2(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

	localparam Waiting_For_Reset = 0;
	localparam Init_Wait_For_Rdy = 1;
	localparam Deassert_en_init = 2;
	localparam Initializing = 3;
	localparam Done_Initializing = 4;
	localparam Ksa_Wait_For_Ready = 5;
	localparam Deassert_en_ksa = 6;
	localparam Ksaing = 7;
	localparam Prga_Wait_For_Rdy = 8;
	localparam Deassert_en_prga = 9;
	localparam Prgaing = 10;
	localparam Done = 11;
	
	logic [7:0] state = Waiting_For_Reset;
	
	// Variables for managing the enable for each instantiated module.
	logic en_init;
	logic en_ksa;
	logic en_prga;
	logic wren_mem;
	
	// Variables for the rdy variables of init and ksa.
	logic rdy_init;
	logic rdy_ksa;
	logic rdy_prga;
	
	// The data variables for interaction with the init module.
	logic [7:0] address_init; // Output
	logic [7:0] wrdata_init; // Output
	logic wren_init; // Output
	
	// The data variables for interaction with the ksa module.
	logic [7:0] rddata_ksa; // Input 
	logic [7:0] address_ksa; // Output
	logic [7:0] wrdata_ksa; // Output
	logic wren_ksa; // Output
	
	// The data variables for interaction with the prga module.
	logic [7:0] s_rddata_prga; // Input
	logic [7:0] s_address_prga; // Output
	logic [7:0] s_wrdata_prga; // Output
	logic s_wren_prga; // Output
	
	// The data variables for interaction with the memory module. 
	logic [7:0] address_mem; // Input
	logic [7:0] input_data_mem; // Input
	logic [7:0] read_value_mem; // Output
			 
    s_mem_2 s2(.address(address_mem), .clock(clk), .data(input_data_mem), 
		.wren(wren_mem), .q(read_value_mem));
	
	init init(.clk(clk), .rst_n(rst_n), .en(en_init), .rdy(rdy_init), 
		.addr(address_init), .wrdata(wrdata_init), .wren(wren_init));

	ksa ksa(.clk(clk), .rst_n(rst_n), .en(en_ksa), .rdy(rdy_ksa), 
		.key(key), .addr(address_ksa), .rddata(rddata_ksa), .wrdata(wrdata_ksa),
		.wren(wren_ksa));
		
	prga prga(.clk(clk), .rst_n(rst_n), .en(en_prga), .rdy(rdy_prga), .key(key),
            .s_addr(s_address_prga), .s_rddata(s_rddata_prga), 
			.s_wrdata(s_wrdata_prga), .s_wren(s_wren_prga), .ct_addr(ct_addr),
			.ct_rddata(ct_rddata), .pt_addr(pt_addr), .pt_rddata(pt_rddata), 
			.pt_wrdata(pt_wrdata), .pt_wren(pt_wren));

		
    // Determines the state of the task1 state machine.
	always_ff @(posedge clk, negedge rst_n)
		begin
			if (rst_n == 0)
				state = Waiting_For_Reset;
			
			case(state)
			
				Waiting_For_Reset:
					begin
						if (en == 1)
							begin
								state = Init_Wait_For_Rdy;
								rdy = 0;
							end
						else
							begin
								state = Waiting_For_Reset;
								rdy = 1;
							end
					end
				
				Init_Wait_For_Rdy: 
					begin
						if (rdy_init == 0)
							begin
								state = Init_Wait_For_Rdy;
							end	
						else
							begin
								state = Deassert_en_init;
							end
					end
				
				Deassert_en_init:
					begin
						state = Initializing;
					end
				
				Initializing: 
					begin
						if (rdy_init == 1)
							begin
								state = Done_Initializing;
							end
						else
							begin
								state = Initializing;
							end
					end
					
				Done_Initializing:
					begin
						state = Ksa_Wait_For_Ready;
					end
				
				Ksa_Wait_For_Ready: 
					begin
						if (rdy_ksa == 0)
							begin
								state = Ksa_Wait_For_Ready;
							end	
						else
							begin
								state = Deassert_en_ksa;
							end
					end
				
				Deassert_en_ksa:
					begin
						state = Ksaing;
					end
				
				Ksaing: 
					begin
						if (rdy_ksa == 1)
							begin
								state = Prga_Wait_For_Rdy;
							end
						else
							begin
								state = Ksaing;
							end
					end
					
				Prga_Wait_For_Rdy:
					begin
						if (rdy_prga == 0)
							begin
								state = Prga_Wait_For_Rdy;
							end	
						else
							begin
								state = Deassert_en_prga;
							end
					end
					
				Deassert_en_prga:
					begin
						state = Prgaing;
					end
					
				Prgaing:
					begin
						if (rdy_prga == 1)
							begin
								state = Done;
							end
						else
							begin
								state = Prgaing;
							end
					end
					
				Done:
					begin
						state = Waiting_For_Reset;
						rdy = 1;
					end
			endcase

		end
	
	always_comb
		begin		
			case (state)
				
				Waiting_For_Reset: 
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = 0;
						address_mem = 0;
						input_data_mem = 0;
						en_prga = 0;
						s_rddata_prga = 0;
					end
					
				Init_Wait_For_Rdy:
					begin
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = 0;
						address_mem = 0;
						input_data_mem = 0;
						en_prga = 0;
						s_rddata_prga = 0;
						
						if (rdy_init == 1)
							en_init = 1;
						else
							en_init = 0;
					end
					
				Deassert_en_init:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = wren_init;
						address_mem = address_init;
						input_data_mem = wrdata_init;
						en_prga = 0;
						s_rddata_prga = 0;
					end
					
				Initializing:	
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = wren_init;
						address_mem = address_init;
						input_data_mem = wrdata_init;
						en_prga = 0;
						s_rddata_prga = 0;
					end
					
				Done_Initializing:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = 0;
						address_mem = 0;
						input_data_mem = 0;
						en_prga = 0;
						s_rddata_prga = 0;
					end
					
				Ksa_Wait_For_Ready:
					begin
						en_init = 0;
						rddata_ksa = 0;
						wren_mem = 0;
						address_mem = 0;
						input_data_mem = 0;
						en_prga = 0;
						s_rddata_prga = 0;
						
						if (rdy_ksa == 1)
							en_ksa = 1;
						else
							en_ksa = 0;
					end
				
				Deassert_en_ksa:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = read_value_mem;
						wren_mem = wren_ksa;
						address_mem = address_ksa;
						input_data_mem = wrdata_ksa;
						en_prga = 0;
						s_rddata_prga = 0;
					end
					
				Ksaing:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = read_value_mem;
						wren_mem = wren_ksa;
						address_mem = address_ksa;
						input_data_mem = wrdata_ksa;
						en_prga = 0;
						s_rddata_prga = 0;
					end
					
				Prga_Wait_For_Rdy:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = 0;
						address_mem = 0;
						input_data_mem = 0;
						s_rddata_prga = 0;
						
						if (rdy_prga == 1)
							en_prga = 1;
						else
							en_prga = 0;
					end
					
				Deassert_en_prga:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = s_wren_prga;
						address_mem = s_address_prga;
						input_data_mem = s_wrdata_prga;
						en_prga = 0;
						s_rddata_prga = read_value_mem;
					end
					
				Prgaing:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = s_wren_prga;
						address_mem = s_address_prga;
						input_data_mem = s_wrdata_prga;
						en_prga = 0;
						s_rddata_prga = read_value_mem;
					end
					
				Done:
					begin
						en_init = 0;
						en_ksa = 0;
						rddata_ksa = 0;
						wren_mem = 0;
						address_mem = 0;
						input_data_mem = 0;
						en_prga = 0;
						s_rddata_prga = 0;
					end
				
			endcase
		end
	
endmodule: arc4_2
