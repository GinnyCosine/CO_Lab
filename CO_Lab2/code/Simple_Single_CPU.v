// 0716018
//Subject:     CO project 2 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Simple_Single_CPU(
        clk_i,
		rst_i
		);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signles
wire   [32-1:0]      pc_out_w;
wire   [32-1:0]      pc_in_w;
wire   [32-1:0]      seq_addr_w;
wire   [32-1:0]      ins_mem_w;
wire   [5-1:0]      rd_w;
wire     regDst_w;
wire     ALUsrc_w;
wire     branch_w;
wire     regWrite_w;
wire   [3-1:0]  ALU_op_w;
wire   [32-1:0]      RS_data_w;
wire   [32-1:0]      RT_data_w;
wire   [4-1:0]      ALU_ctrl_w;
wire   [32-1:0]      sign_ex_w;
wire   [32-1:0]      ALU_src_mux_w;
wire   [32-1:0]      ALU_result_w;
wire   [32-1:0]      sign_ex_shift_w;
wire   [32-1:0]      adder2_o_w;
wire        ALU_zero_w;
wire    bz_w;
//Greate componentes

assign bz_w = ALU_zero_w & branch_w;

ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(pc_in_w) ,   
	    .pc_out_o(pc_out_w) 
	    );
	
Adder Adder1(
        .src1_i(32'd4),     
	    .src2_i(pc_out_w),     
	    .sum_o(seq_addr_w)    
	    );
	
Instr_Memory IM(
        .pc_addr_i(pc_out_w),  
	    .instr_o(ins_mem_w)    
	    );

MUX_2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(ins_mem_w[20:16]),
        .data1_i(ins_mem_w[15:11]),
        .select_i(regDst_w),
        .data_o(rd_w)
        );	
		
Reg_File RF(
        .clk_i(clk_i),      
	    .rst_i(rst_i) ,     
        .RSaddr_i(ins_mem_w[25:21]) ,  
        .RTaddr_i(ins_mem_w[20:16]) ,  
        .RDaddr_i(rd_w) ,  
        .RDdata_i(ALU_result_w)  , 
        .RegWrite_i (regWrite_w),
        .RSdata_o(RS_data_w) ,  
        .RTdata_o(RT_data_w)   
        );
	
Decoder Decoder(
        .instr_op_i(ins_mem_w[31:26]), 
	    .RegWrite_o(regWrite_w), 
	    .ALU_op_o(ALU_op_w),   
	    .ALUSrc_o(ALUsrc_w),   
	    .RegDst_o(regDst_w),   
		.Branch_o(branch_w)   
	    );

ALU_Ctrl AC(
        .funct_i(ins_mem_w[5:0]),   
        .ALUOp_i(ALU_op_w),   
        .ALUCtrl_o(ALU_ctrl_w) 
        );
	
Sign_Extend SE(
        .data_i(ins_mem_w[15:0]),
        .data_o(sign_ex_w)
        );

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(RT_data_w),
        .data1_i(sign_ex_w),
        .select_i(ALUsrc_w),
        .data_o(ALU_src_mux_w)
        );	
		
ALU ALU(
        .src1_i(RS_data_w),
	    .src2_i(ALU_src_mux_w),
	    .ctrl_i(ALU_ctrl_w),
	    .result_o(ALU_result_w),
		.zero_o(ALU_zero_w)
	    );
		
Adder Adder2(
        .src1_i(seq_addr_w),     
	    .src2_i(sign_ex_shift_w),     
	    .sum_o(adder2_o_w)      
	    );
		
Shift_Left_Two_32 Shifter(
        .data_i(sign_ex_w),
        .data_o(sign_ex_shift_w)
        ); 		
		
MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(seq_addr_w),
        .data1_i(adder2_o_w),
        .select_i(bz_w),
        .data_o(pc_in_w)
        );	

endmodule
		  


