// 0716018
`timescale 1ns/1ps

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

module alu(
           clk,           // system clock              (input)
           rst_n,         // negative reset            (input)
           src1,          // 32 bits source 1          (input)
           src2,          // 32 bits source 2          (input)
           ALU_control,   // 4 bits ALU control input  (input)
			  //bonus_control, // 3 bits bonus control input(input) 
           result,        // 32 bits result            (output)
           zero,          // 1 bit when the output is 0, zero must be set (output)
           cout,          // 1 bit carry out           (output)
           overflow       // 1 bit overflow            (output)
           );

input           clk;
input           rst_n;
input  [32-1:0] src1;
input  [32-1:0] src2;
input   [4-1:0] ALU_control;
//3 A_invert
//2 B_invert
//1:0 operation

//input   [3-1:0] bonus_control; 

output [32-1:0] result;
output          zero;
output          cout;
output          overflow;
reg          overflow;
reg             result;
reg             cout;
reg             zero;
wire    [32-1:0] result_r;
wire    [32-1:0] cout_r;
wire             overflow_r;
wire				set;

alu_top a0(.src1(src1[0]), 
           .src2(src2[0]), 
           .less(set), 
           .cin(ALU_control[2]), 
           .operation(ALU_control[1:0]), 
           .A_invert(ALU_control[3]), 
           .B_invert(ALU_control[2]), 
           .result(result_r[0]), 
           .cout(cout_r[0]));

generate
    genvar i;
    for (i = 1; i < 31; i=i+1)
    begin
        alu_top middle(.src1(src1[i]), 
                       .src2(src2[i]), 
                       .less(1'b0), 
                       .cin(cout_r[i - 1]), 
                       .operation(ALU_control[1:0]), 
                       .A_invert(ALU_control[3]), 
                       .B_invert(ALU_control[2]), 
                       .result(result_r[i]), 
                       .cout(cout_r[i]));

    end
endgenerate

alu_bottom a31(.src1(src1[31]), 
               .src2(src2[31]), 
               .less(1'b0), 
               .cin(cout_r[30]), 
               .operation(ALU_control[1:0]), 
               .A_invert(ALU_control[3]), 
               .B_invert(ALU_control[2]), 
               .result(result_r[31]), 
               .cout(cout_r[31]),
               .set(set),
               .overflow(overflow_r));

always@( posedge clk or negedge rst_n ) 
begin
	if(!rst_n) begin
		result <= 32'b0;
	end
	else begin
        overflow <= overflow_r;
		result <= result_r;
        zero <= (result_r == 32'b0)?(1):(0);
        if ((ALU_control == 4'b0010)||(ALU_control == 4'b0110))
            cout <= cout_r[31];
        else
            cout <= 0;
	end
end



endmodule
