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
	Branch_o
	);
     
//I/O ports
// 幹 跟 ALUOp 有什麼不一樣
input  [6-1:0] instr_op_i;

output         RegWrite_o;
output [3-1:0] ALU_op_o;
output         ALUSrc_o;
output         RegDst_o;
output         Branch_o;
 
//Internal Signals
reg    [3-1:0] ALU_op_o;
reg            ALUSrc_o;
reg            RegWrite_o;
reg            RegDst_o;
reg            Branch_o;

//Parameter


//Main function
always@(*) begin
	case (instr_op_i)
		0:
		begin
			ALU_op_o = 3'b010;
			RegDst_o = 1;
			ALUSrc_o = 0;
			RegWrite_o = 1;
			Branch_o = 0;
		end
		4: // beq
		begin
			ALU_op_o = 3'b001;
			RegDst_o = 0;	// don't care
			ALUSrc_o = 0;
			RegWrite_o = 0;
			Branch_o = 1;
		end
		8:	// addi
		begin
			ALU_op_o = 3'b011;
			RegDst_o = 0;
			ALUSrc_o = 1;
			RegWrite_o = 1;
			Branch_o = 0;
		end
		10:	// slti
		begin
			ALU_op_o = 3'b111;
			RegDst_o = 0;
			ALUSrc_o = 1;
			RegWrite_o = 1;
			Branch_o = 0;
		end
	endcase
end


endmodule





                    
                    