`timescale 1ps / 1ps

module task4_tb();

	reg clk;
	reg [3:0] KEY;
	reg [9:0] SW;
	
	wire [6:0] HEX0;
	wire [6:0] HEX1;
	wire [6:0] HEX2;
	wire [6:0] HEX3;
	wire [6:0] HEX4;
	wire [6:0] HEX5;
	wire [9:0] LEDR;

	task4 dut(.CLOCK_50(clk), .KEY(KEY), .SW(SW),
             .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2),
             .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
             .LEDR(LEDR));
			 
	initial forever begin
		clk = 0;
		#5;
		clk = 1;
		#5;
	end
	
	initial
		begin
			#10;
			KEY[3] = 1;
			#100;
			KEY[3] = 0;
			#100;
			KEY[3] = 1;
			
			#36000;
			
			KEY[3] = 1;
			#100;
			KEY[3] = 0;
			#100;
			KEY[3] = 1;
		end
	
	
endmodule

