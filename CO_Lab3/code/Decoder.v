// 0716018
//Subject:     CO project 2 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      Luke
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Decoder(
    instr_op_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
	Branch_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o
	);
     
//I/O ports
input  [6-1:0]  instr_op_i;

output          RegWrite_o;
output [3-1:0]  ALU_op_o;
output          ALUSrc_o;
output [2-1:0]  RegDst_o;
output          Branch_o;
output			Jump_o;
output			MemRead_o;
output			MemWrite_o;
output [2-1:0]	MemtoReg_o;

//Internal Signals
reg    [3-1:0]  ALU_op_o;
reg    			ALUSrc_o;
reg             RegWrite_o;
reg    [2-1:0]  RegDst_o;
reg             Branch_o;
reg				Jump_o;
reg				MemRead_o;
reg				MemWrite_o;
reg  [2-1:0]	MemtoReg_o;
//Parameter


//Main function
always@(*) begin
	case (instr_op_i)
		0:	// R type
		begin
			ALU_op_o = 3'b010;
			RegDst_o = 1;
			ALUSrc_o = 0;
			RegWrite_o = 1;
			Branch_o = 0;
			MemtoReg_o = 0;
			MemRead_o = 0;
			MemWrite_o = 0;
			Jump_o = 0;
		end
		4: // beq
		begin
			ALU_op_o = 3'b001;
			RegDst_o = 0;	// don't care
			ALUSrc_o = 0;
			RegWrite_o = 0;
			Branch_o = 1;
			MemtoReg_o = 0;	// don't care
			MemRead_o = 0;
			MemWrite_o = 0;
			Jump_o = 0;
		end
		8:	// addi
		begin
			ALU_op_o = 3'b011;
			RegDst_o = 0;
			ALUSrc_o = 1;
			RegWrite_o = 1;
			Branch_o = 0;
			MemtoReg_o = 0;
			MemRead_o = 0;
			MemWrite_o = 0;
			Jump_o = 0;
		end
		10:	// slti
		begin
			ALU_op_o = 3'b111;
			RegDst_o = 0;
			ALUSrc_o = 1;
			RegWrite_o = 1;
			Branch_o = 0;
			MemtoReg_o = 0;
			MemRead_o = 0;
			MemWrite_o = 0;
			Jump_o = 0;
		end
		35:	// lw
		begin
			ALU_op_o = 3'b000;
			RegDst_o = 0;
			ALUSrc_o = 1;
			MemtoReg_o = 1;
			RegWrite_o = 1;
			MemRead_o = 1;
			MemWrite_o = 0;
			Branch_o = 0;
			Jump_o = 0;
		end
		43: // sw
		begin
			ALU_op_o = 3'b000;
			RegDst_o = 0;
			ALUSrc_o = 1;
			MemtoReg_o = 0; // don't care
			RegWrite_o = 0;
			MemRead_o = 0;
			MemWrite_o = 1;
			Branch_o = 0;
			Jump_o = 0;
		end
		2:	// jump
		begin
			ALU_op_o = 3'b000;
			RegDst_o = 0;
			ALUSrc_o = 1;
			RegWrite_o = 0;	// 重要
			Branch_o = 0;
			MemtoReg_o = 0;
			MemRead_o = 0;
			MemWrite_o = 0;
			Jump_o = 1;
		end
		3:	// jal
		begin
			ALU_op_o = 3'b000;
			RegDst_o = 2;
			ALUSrc_o = 1;
			RegWrite_o = 1; // 重要
			Branch_o = 0;
			MemtoReg_o = 2;
			MemRead_o = 0;
			MemWrite_o = 0;
			Jump_o = 1;
		end
		default:
		begin
			ALU_op_o = 3'b000;
			RegDst_o = 0;
			ALUSrc_o = 0;
			RegWrite_o = 0; // 重要
			Branch_o = 0;
			MemtoReg_o = 0;
			MemRead_o = 0;
			MemWrite_o = 0;
			Jump_o = 0;
		end
	endcase
end


endmodule