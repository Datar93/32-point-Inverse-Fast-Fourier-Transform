//
//  This module uses 32 bit values to represent the twiddle factor
//  The first two bits represents integer and the 30 bits represents decimal precision
//  32'b01000000000000000000000000000000
//       1            0
//
module TwidTHRTWO(cosANG,cVAL,sinANG,sVAL);

input [3:0] cosANG, sinANG;
output [35:0] cVAL,sVAL;
reg [35:0]  cVAL_1, sVAL_1;
assign cVAL = cVAL_1/*[31:0]*/;
assign sVAL = sVAL_1/*[31:0]*/;
always @(*) begin
    case(cosANG) // 2 bit intiger 30 bit fraction
0: cVAL_1  = 36'h100000000;
1: cVAL_1  = 36'h0FB14BE7F;
2: cVAL_1  = 36'h0EC835E79;
3: cVAL_1  = 36'h0D4DB3148;
4: cVAL_1  = 36'h0B504F334;
5: cVAL_1  = 36'h08E39D9CD;
6: cVAL_1  = 36'h061F78A9A;
7: cVAL_1  = 36'h031F17078;
8: cVAL_1  = 36'h000000000;
9: cVAL_1  = 36'hFCE0E8F87;
10:cVAL_1  = 36'hF9E087565;
11:cVAL_1  = 36'hF71C62632;
12:cVAL_1  = 36'hF4AFB0CCC;
13:cVAL_1  = 36'hF2B24CEB7;
14:cVAL_1  = 36'hF137CA186;
15:cVAL_1  = 36'hF04EB4180;
    endcase
    
    
    
    case(sinANG)
0: sVAL_1  = 36'h000000000;
1: sVAL_1  = 36'h031F17078;
2: sVAL_1  = 36'h061F78A9A;
3: sVAL_1  = 36'h08E39D9CD; 
4: sVAL_1  = 36'h0B504F334;
5: sVAL_1  = 36'h0D4DB3148; 
6: sVAL_1  = 36'h0EC835E79;   
7: sVAL_1  = 36'h0FB14BE7F;
8: sVAL_1  = 36'h100000000;
9: sVAL_1  = 36'h0FB14BE7F;
10:sVAL_1  = 36'h0EC835E79;
11:sVAL_1  = 36'h0D4DB3148;
12:sVAL_1  = 36'h0B504F334;
13:sVAL_1  = 36'h08E39D9CD;
14:sVAL_1  = 36'h061F78A9A;
15:sVAL_1  = 36'h031F17078; 
    endcase
end
endmodule
