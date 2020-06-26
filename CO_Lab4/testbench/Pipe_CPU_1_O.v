//0716018
`timescale 1ns / 1ps
//Subject:     CO project 4 - Pipe CPU 1
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Pipe_CPU_1(
    clk_i,
    rst_i
    );
    
/****************************************
I/O ports
****************************************/
input clk_i;
input rst_i;

/****************************************
Internal signal
****************************************/
/**** IF stage ****/
wire    [32-1:0]    pc_out_w;
wire    [32-1:0]    pc_in_w;
wire    [32-1:0]    seq_addr_w;
wire    [32-1:0]    ins_mem_w;

/****** IF ID *****/
//wire    [64-1:0]    IF_ID_out_w;
wire    [32-1:0]    seq_addr_IF_w;
wire    [32-1:0]    ins_mem_IF_w;   
/**** ID stage ****/
wire    [32-1:0]    RS_data_w;
wire    [32-1:0]    RT_data_w;
wire    [32-1:0]    sign_ex_w;
wire    [5-1:0]     rd_w;
wire                ALUsrc_w;
wire                branch_w;
wire                regDst_w;
wire                regWrite_w;
wire                MemToReg_w;
wire                MemRead_w;
wire                MemWrite_w;
wire    [3-1:0]     ALU_op_w;
wire    [2-1:0]     WB_Ctrl_w;
wire    [3-1:0]     M_Ctrl_w;
wire    [5-1:0]     EX_Ctrl_w;

/****** ID EX *****/
//wire    [148-1:0]   ID_EX_out_w;
wire    [2-1:0]     WB_Ctrl_ID_w;
wire    [3-1:0]     M_Ctrl_ID_w;
wire    [5-1:0]     EX_Ctrl_ID_w;
wire    [32-1:0]    seq_addr_ID_w;
wire    [32-1:0]    RS_data_ID_w;
wire    [32-1:0]    RT_data_ID_w;
wire    [32-1:0]    sign_ex_ID_w;
wire    [5-1:0]     Mux2_0_ID_w;
wire    [5-1:0]     Mux2_1_ID_w;
/**** EX stage ****/
wire    [4-1:0]     ALU_ctrl_w;
wire    [32-1:0]    ALU_result_w;
wire                ALU_zero_w;
wire    [32-1:0]    sign_ex_shift_w;
wire    [32-1:0]    Mux1_w;
wire    [5-1:0]     Mux2_w;
wire    [32-1:0]    branch_addr_w;

/****** EX MEM *****/
wire    [2-1:0]     WB_Ctrl_EX_w;
wire    [3-1:0]     M_Ctrl_EX_w;
wire    [32-1:0]    branch_addr_EX_w;
wire                ALU_zero_EX_w;
wire    [32-1:0]    ALU_result_EX_w;
wire    [32-1:0]    RT_data_EX_w;
wire    [5-1:0]     RD_addr_EX_w;

/**** MEM stage ****/
wire                bz_w;
wire    [32-1:0]    MemData_w;

/****** MEM WB *****/
wire    [2-1:0]     WB_Ctrl_MEM_w;
wire    [32-1:0]    MemData_MEM_w;
wire    [32-1:0]    ALU_result_MEM_w;
wire    [5-1:0]     RD_addr_MEM_w;

/**** WB stage ****/
wire    [32-1:0]    RDwrite_w;


/****************************************
signal assignment
****************************************/
assign WB_Ctrl_w = ({regWrite_w, MemToReg_w});
assign M_Ctrl_w = ({branch_w, MemRead_w, MemWrite_w});
assign EX_Ctrl_w = ({regDst_w, ALU_op_w, ALUsrc_w});
assign bz_w = M_Ctrl_EX_w[2] & ALU_zero_EX_w;

/****************************************
Instantiate modules
****************************************/

//Instantiate the components in IF stage
MUX_2to1 #(.size(32)) Mux0(
    .data0_i(seq_addr_w),
    .data1_i(branch_addr_EX_w),
    .select_i(bz_w),
    .data_o(pc_in_w)
);

ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(pc_in_w) ,   
	    .pc_out_o(pc_out_w) 
	    );


Instruction_Memory IM(
        .addr_i(pc_out_w),  
	    .instr_o(ins_mem_w)    
	    );
			
Adder Add_pc(
        .src1_i(32'd4),     
	    .src2_i(pc_out_w),     
	    .sum_o(seq_addr_w)
);

		
Pipe_Reg #(.size(64)) IF_ID(       //N is the total length of input/output
    .clk_i(clk_i),
	.rst_i (rst_i),
    .data_i({seq_addr_w, ins_mem_w}),
    .data_o({seq_addr_IF_w, ins_mem_IF_w})
);


//Instantiate the components in ID stage
Reg_File RF(
    .clk_i(clk_i),      
	.rst_i(rst_i) ,     
    .RSaddr_i(ins_mem_IF_w[25:21]) ,  
    .RTaddr_i(ins_mem_IF_w[20:16]) ,  
    .RDaddr_i(RD_addr_MEM_w), 
    .RDdata_i(RDwrite_w),
    .RegWrite_i (WB_Ctrl_MEM_w[1]),
    .RSdata_o(RS_data_w),
    .RTdata_o(RT_data_w) 
);

Decoder Control(
    .instr_op_i(ins_mem_IF_w[31:26]), 
    .RegWrite_o(regWrite_w), 
    .ALU_op_o(ALU_op_w),   
    .ALUSrc_o(ALUsrc_w),   
    .RegDst_o(regDst_w),   
    .Branch_o(branch_w),
    .MemRead_o(MemRead_w),
    .MemWrite_o(MemWrite_w),
    .MemtoReg_o(MemToReg_w)
);

Sign_Extend Sign_Extend(
    .data_i(ins_mem_IF_w[15:0]),
    .data_o(sign_ex_w)
);	

Pipe_Reg #(.size(148)) ID_EX(
    .clk_i(clk_i),      
	.rst_i (rst_i),  
    .data_i({WB_Ctrl_w, M_Ctrl_w, EX_Ctrl_w, seq_addr_IF_w,RS_data_w,RT_data_w,sign_ex_w,ins_mem_IF_w[20:16],ins_mem_IF_w[15:11]}),
    .data_o({WB_Ctrl_ID_w, M_Ctrl_ID_w, EX_Ctrl_ID_w, seq_addr_ID_w,RS_data_ID_w,RT_data_ID_w,sign_ex_ID_w,Mux2_0_ID_w,Mux2_1_ID_w})
);


//Instantiate the components in EX stage	   
Shift_Left_Two_32 Shifter(
    .data_i(sign_ex_ID_w),
    .data_o(sign_ex_shift_w)
);

ALU ALU(
        .src1_i(RS_data_ID_w),
	    .src2_i(Mux1_w),
	    .ctrl_i(ALU_ctrl_w),
	    .result_o(ALU_result_w),
		.zero_o(ALU_zero_w)
);
		
ALU_Ctrl ALU_Control(
        .funct_i(sign_ex_ID_w[5:0]),   
        .ALUOp_i(EX_Ctrl_ID_w[3:1]), 
        .ALUCtrl_o(ALU_ctrl_w)
);

MUX_2to1 #(.size(32)) Mux1(
    .data0_i(RT_data_ID_w),
    .data1_i(sign_ex_ID_w),
    .select_i(EX_Ctrl_ID_w[0]),
    .data_o(Mux1_w)
);
		
MUX_2to1 #(.size(5)) Mux2(
    .data0_i(Mux2_0_ID_w),
    .data1_i(Mux2_1_ID_w),
    .select_i(EX_Ctrl_ID_w[4]),
    .data_o(Mux2_w)
);

Adder Add_pc_branch(
    .src1_i(seq_addr_ID_w),
	.src2_i(sign_ex_shift_w),
	.sum_o(branch_addr_w)
);

Pipe_Reg #(.size(107)) EX_MEM(
    .clk_i(clk_i),      
	.rst_i (rst_i),  
    .data_i({WB_Ctrl_ID_w,M_Ctrl_ID_w,branch_addr_w,ALU_zero_w,ALU_result_w,RT_data_ID_w,Mux2_w}),
    .data_o({WB_Ctrl_EX_w,M_Ctrl_EX_w,branch_addr_EX_w,ALU_zero_EX_w,ALU_result_EX_w,RT_data_EX_w,RD_addr_EX_w})
);


//Instantiate the components in MEM stage
Data_Memory DM(
    .clk_i(clk_i),
	.addr_i(ALU_result_EX_w),
	.data_i(RT_data_EX_w),
	.MemRead_i(M_Ctrl_EX_w[1]),
	.MemWrite_i(M_Ctrl_EX_w[0]),
	.data_o(MemData_w)
);

Pipe_Reg #(.size(71)) MEM_WB(
    .clk_i(clk_i),      
	.rst_i (rst_i),  
    .data_i({WB_Ctrl_EX_w,MemData_w,ALU_result_EX_w,RD_addr_EX_w}),
    .data_o({WB_Ctrl_MEM_w,MemData_MEM_w,ALU_result_MEM_w,RD_addr_MEM_w})
);


//Instantiate the components in WB stage
MUX_2to1 #(.size(32)) Mux3(
    .data0_i(ALU_result_MEM_w),
    .data1_i(MemData_MEM_w),
    .select_i(WB_Ctrl_MEM_w[0]),
    .data_o(RDwrite_w)
);

endmodule

