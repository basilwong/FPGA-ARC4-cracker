module segger7(input [4:0] card, output reg [6:0] seg7);

   always_comb begin
	case(card)
		0: seg7 = 7'b1000000;
		1: seg7 = 7'b1111001;
		2: seg7 = 7'b0100100;
		3: seg7 = 7'b0110000;
		4: seg7 = 7'b0011001;
		5: seg7 = 7'b0010010;
		6: seg7 = 7'b0000010;
		7: seg7 = 7'b1111000;
		8: seg7 = 7'b0000000;
		9: seg7 = 7'b0010000;
		10: seg7 = 7'b0001000; // A
		11: seg7 = 7'b0000011; // b
		12: seg7 = 7'b1000110; // C
		13: seg7 = 7'b0100001; // d
		14: seg7 = 7'b0000110; // E
		15: seg7 = 7'b0001110; // F
		16: seg7 = 7'b0111111; // - 
		17: seg7 = 7'b1111111;
		default: seg7 = 7'b1111111;
	endcase
end

endmodule
