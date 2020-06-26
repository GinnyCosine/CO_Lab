// 0716018

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:15:11 08/18/2013
// Design Name:
// Module Name:    alu
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module alu_bottom(
               src1,       //1 bit source 1 (input)
               src2,       //1 bit source 2 (input)
               less,       //1 bit less     (input)
               A_invert,   //1 bit A_invert (input)
               B_invert,   //1 bit B_invert (input)
               cin,        //1 bit carry in (input)
               operation,  //operation      (input)
               result,     //1 bit result   (output)
               cout,       //1 bit carry out(output)
               set,
               overflow
               );

input         src1;
input         src2;
input         less;
input         A_invert;
input         B_invert;
input         cin;
input [2-1:0] operation;

output        result;
output        cout;
output        overflow;
output        set;

wire	    [2:0] tmp;
wire	          src1_temp;
wire	          src2_temp;
reg           result;


assign src1_temp = (A_invert)?(~src1):(src1);
assign src2_temp = (B_invert)?(~src2):(src2);
assign tmp[0] = src1_temp & src2_temp;
assign tmp[1] = src1_temp | src2_temp;
assign tmp[2] = (src1_temp ^ src2_temp)^ cin;
assign cout = ((src1_temp ^ src2_temp) & cin)|(src1_temp & src2_temp);
assign overflow = (src1_temp == 1 & src2_temp == 1 & tmp[2] == 0) | (src1_temp == 0 & src2_temp == 0 & tmp[2] == 1);
assign set = tmp[2];

always@(*)
begin
	case (operation)
		2'b00: result = tmp[0];
		2'b01: result = tmp[1];
		2'b10: result = tmp[2];
		2'b11: result = less;
	endcase
end

endmodule