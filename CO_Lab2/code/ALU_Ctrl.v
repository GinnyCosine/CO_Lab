// 0716018
//Subject:     CO project 2 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o
          );
          
//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;    
     
//Internal Signals
reg        [4-1:0] ALUCtrl_o;

always@(*)
begin
    case(ALUOp_i) 
        3'b010: // R format
        begin
            case (funct_i)
                32: ALUCtrl_o = 2;
                34: ALUCtrl_o = 6;
                36: ALUCtrl_o = 0;
                37: ALUCtrl_o = 1;
                42: ALUCtrl_o = 7;
            endcase
        end
        3'b011: // addi
            ALUCtrl_o = 2;
        3'b111: // slti
            ALUCtrl_o = 7;
        3'b001: // beq
            ALUCtrl_o = 6;
    endcase
end


endmodule     





                    
                    