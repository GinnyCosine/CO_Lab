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
wire     ALUsrc_w;
wire     branch_w;
wire   [2-1:0] regDst_w;
wire     regWrite_w;
wire   [2-1:0]  MemToReg_w;
wire     MemRead_w;
wire     MemWrite_w;
wire     Jump_w;
wire   [3-1:0]  ALU_op_w;
wire   [32-1:0]      RS_data_w;
wire   [32-1:0]      RT_data_w;
wire   [4-1:0]      ALU_ctrl_w;
wire   [32-1:0]      sign_ex_w;
wire   [32-1:0]      ALU_src_mux_w;
wire   [32-1:0]      ALU_result_w;
wire   [32-1:0]      MemData_w;
wire   [32-1:0]      RDwrite_w;
wire   [32-1:0]      sign_ex_shift_w;
wire   [32-1:0]      adder2_o_w;
wire        ALU_zero_w;
wire    bz_w;
wire    [2-1:0] pc_select_r;
wire     regWrite_select_r;
wire     rw_selected_w;
//wire    nop_w;
//Greate componentes

assign bz_w = ALU_zero_w & branch_w;
//assign nop_w = ins_mem_w[31:0] == 32'b0;
// jr
assign regWrite_select_r = (ins_mem_w[31:26] == 6'b000000 && ins_mem_w[20:0] == 8)?1'b1:1'b0;

assign pc_select_r = (regWrite_select_r == 1'b1) ? 3:
                     (bz_w == 1) ? 2:
                     (Jump_w == 1) ? 0:
                     1;


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

Data_Memory Data_Memory(
	.clk_i(clk_i),
	.addr_i(ALU_result_w),
	.data_i(RT_data_w),
	.MemRead_i(MemRead_w),
	.MemWrite_i(MemWrite_w),
	.data_o(MemData_w)
);

MUX_2to1 #(.size(1)) Mux_Reg_Write(
        .data0_i(regWrite_w),
        .data1_i(1'b0),
        .select_i(regWrite_select_r),
        .data_o(rw_selected_w)
        );

MUX_4to1 #(.size(5)) Mux_Reg_Dst(
        .data0_i(ins_mem_w[20:16]),
        .data1_i(ins_mem_w[15:11]),
        .data2_i(5'b11111),        // 不確定
        .data3_i(5'b11111),
        .select_i(regDst_w),
        .data_o(rd_w)
        );

MUX_4to1 #(.size(32)) Mux_Mem_to_Reg(
        .data0_i(ALU_result_w),
        .data1_i(MemData_w),
        .data2_i(seq_addr_w),
        .data3_i(0),
        .select_i(MemToReg_w),
        .data_o(RDwrite_w)
        );		
		
Reg_File Registers(
        .clk_i(clk_i),      
	.rst_i(rst_i) ,     
        .RSaddr_i(ins_mem_w[25:21]) ,  
        .RTaddr_i(ins_mem_w[20:16]) ,  
        .RDaddr_i(rd_w), 
        .RDdata_i(RDwrite_w),
        .RegWrite_i (rw_selected_w),
        .RSdata_o(RS_data_w) ,  
        .RTdata_o(RT_data_w)   
        );

Decoder Decoder(
        .instr_op_i(
                ins_mem_w[31:26]), 
	        .RegWrite_o(regWrite_w), 
	        .ALU_op_o(ALU_op_w),   
	        .ALUSrc_o(ALUsrc_w),   
	        .RegDst_o(regDst_w),   
	        .Branch_o(branch_w),
                .Jump_o(Jump_w),
                .MemRead_o(MemRead_w),
                .MemWrite_o(MemWrite_w),
                .MemtoReg_o(MemToReg_w)
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
		
Shift_Left_Two_32 Shifter_bottom(
        .data_i(sign_ex_w),
        .data_o(sign_ex_shift_w)
        ); 		

MUX_4to1 #(.size(32)) Mux_PC_Source(
        .data0_i({pc_out_w[31:28],ins_mem_w[25:0],2'b00}),   // 不知道jump在哪==
        .data1_i(seq_addr_w),   
        .data2_i(adder2_o_w),
        .data3_i(RS_data_w), 
        .select_i(pc_select_r),
        .data_o(pc_in_w)
        );	



endmodule