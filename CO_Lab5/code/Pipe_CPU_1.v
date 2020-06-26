//0716018
`timescale 1ns / 1ps
//Subject:     CO project 5 - Pipe CPU 1
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

wire    PC_write_w;
wire    IF_wait_w;
wire    IF_flush_w;
wire    ID_flush_w;
wire    EX_flush_w;

/****** IF ID *****/
//wire    [64-1:0]    IF_ID_out_w;
wire    [32-1:0]    seq_addr_ID_w;
wire    [32-1:0]    ins_mem_ID_w;   
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
wire    [2-1:0]     WB_Ctrl_EX_w;
wire    [3-1:0]     M_Ctrl_EX_w;
wire    [5-1:0]     EX_Ctrl_EX_w;
wire    [32-1:0]    seq_addr_EX_w;
wire    [32-1:0]    RS_data_EX_w;
wire    [32-1:0]    RT_data_EX_w;
wire    [32-1:0]    sign_ex_EX_w;
wire    [5-1:0]     RS_addr_EX_w;
wire    [5-1:0]     RT_addr_EX_w;
wire    [5-1:0]     Mux2_1_EX_w;
/**** EX stage ****/
wire    [2-1:0]     Forward_A_w;
wire    [2-1:0]     Forward_B_w;
wire    [32-1:0]    Mux_Forward_B_w;
wire    [4-1:0]     ALU_ctrl_w;
wire    [32-1:0]    ALU_input_1_w;
wire    [32-1:0]    ALU_input_2_w;
wire    [32-1:0]    ALU_result_w;
wire                ALU_zero_w;
wire    [32-1:0]    sign_ex_shift_w;
wire    [5-1:0]     Mux2_w;
wire    [32-1:0]    branch_addr_w;

/****** EX MEM *****/
wire    [2-1:0]     WB_Ctrl_MEM_w;
wire    [3-1:0]     M_Ctrl_MEM_w;
wire    [32-1:0]    branch_addr_MEM_w;
wire                ALU_zero_MEM_w;
wire    [32-1:0]    ALU_result_MEM_w;
wire    [32-1:0]    RT_data_MEM_w;
wire    [5-1:0]     RD_addr_MEM_w;

/**** MEM stage ****/
wire                bz_w;
wire    [32-1:0]    MemData_w;

/****** MEM WB *****/
wire    [2-1:0]     WB_Ctrl_WB_w;
wire    [32-1:0]    ALU_result_WB_w;
wire    [32-1:0]    MemData_WB_w;
wire    [5-1:0]     RD_addr_WB_w;
/**** WB stage ****/
wire    [32-1:0]    RDwrite_w;

wire    [2-1:0]     BranchType_w;
wire    [2-1:0]     BranchType_EX_w;
wire    [2-1:0]     BranchType_MEM_w;
wire                Branch_result_w;

/****************************************
signal assignment
****************************************/
assign WB_Ctrl_w = ({regWrite_w, MemToReg_w});
assign M_Ctrl_w = ({branch_w, MemRead_w, MemWrite_w});
assign EX_Ctrl_w = ({regDst_w, ALU_op_w, ALUsrc_w});
assign bz_w = M_Ctrl_MEM_w[2] & Branch_result_w;

/****************************************
Instantiate modules
****************************************/

MUX_4to1 #(.size(1)) Mux_branch(
    .data0_i(ALU_zero_MEM_w),
    .data1_i(~ALU_zero_MEM_w),
    .data2_i(~ALU_result_MEM_w[31]),
    .data3_i(~(ALU_zero_MEM_w | ALU_result_MEM_w[31])),
    .select_i(BranchType_MEM_w),
    .data_o(Branch_result_w)
);

Hazard_Detection Hazard_Detection(
    .PC_src_i(bz_w),
    .MemRead_EX_i(M_Ctrl_EX_w[1]),
    .RS_IFID_addr_i(ins_mem_ID_w[25:21]),  
    .RT_IFID_addr_i(ins_mem_ID_w[20:16]),
    .RT_IDEX_addr_i(RT_addr_EX_w),
    .PC_write_o(PC_write_w),
    .IF_wait_o(IF_wait_w),
    .IF_flush_o(IF_flush_w),
    .ID_flush_o(ID_flush_w),
    .EX_flush_o(EX_flush_w)
	);

//Instantiate the components in IF stage
MUX_2to1 #(.size(32)) Mux0(
    .data0_i(seq_addr_w),
    .data1_i(branch_addr_MEM_w),
    .select_i(bz_w),
    .data_o(pc_in_w)
);

ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i),   
        .pc_write_i(PC_write_w),  
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
    .flush_i(IF_flush_w),
    .wait_i(IF_wait_w),
    .data_i({seq_addr_w, ins_mem_w}),
    .data_o({seq_addr_ID_w, ins_mem_ID_w})
);


//Instantiate the components in ID stage
Reg_File RF(
    .clk_i(clk_i),      
	.rst_i(rst_i) ,     
    .RSaddr_i(ins_mem_ID_w[25:21]) ,  
    .RTaddr_i(ins_mem_ID_w[20:16]) ,  
    .RDaddr_i(RD_addr_WB_w), 
    .RDdata_i(RDwrite_w),
    .RegWrite_i (WB_Ctrl_WB_w[1]),
    .RSdata_o(RS_data_w),
    .RTdata_o(RT_data_w) 
);

Decoder Control(
    .instr_op_i(ins_mem_ID_w[31:26]), 
    .RegWrite_o(regWrite_w), 
    .ALU_op_o(ALU_op_w),   
    .ALUSrc_o(ALUsrc_w),   
    .RegDst_o(regDst_w),   
    .Branch_o(branch_w),
    .MemRead_o(MemRead_w),
    .MemWrite_o(MemWrite_w),
    .MemtoReg_o(MemToReg_w),
	.BranchType_o(BranchType_w)
);

Sign_Extend Sign_Extend(
    .data_i(ins_mem_ID_w[15:0]),
    .data_o(sign_ex_w)
);	

Pipe_Reg #(.size(155)) ID_EX(
    .clk_i(clk_i),      
	.rst_i (rst_i),  
    .flush_i(ID_flush_w),
    .wait_i(1'b0),
    .data_i({WB_Ctrl_w, M_Ctrl_w, EX_Ctrl_w, seq_addr_ID_w,RS_data_w,RT_data_w,sign_ex_w,ins_mem_ID_w[25:21],ins_mem_ID_w[20:16],ins_mem_ID_w[15:11],BranchType_w}),
    .data_o({WB_Ctrl_EX_w, M_Ctrl_EX_w, EX_Ctrl_EX_w, seq_addr_EX_w,RS_data_EX_w,RT_data_EX_w,sign_ex_EX_w,RS_addr_EX_w,RT_addr_EX_w,Mux2_1_EX_w,BranchType_EX_w})
);


//Instantiate the components in EX stage	   
Shift_Left_Two_32 Shifter(
    .data_i(sign_ex_EX_w),
    .data_o(sign_ex_shift_w)
);

Forwarding Forwarding(
    .RS_addr_EX_i(RS_addr_EX_w),
    .RT_addr_EX_i(RT_addr_EX_w),
    .RD_addr_MEM_i(RD_addr_MEM_w),
    .RD_addr_WB_i(RD_addr_WB_w),
    .regWrite_MEM_i(WB_Ctrl_MEM_w[1]),
    .regWrite_WB_i(WB_Ctrl_WB_w[1]),
    .Forward_A_o(Forward_A_w),
    .Forward_B_o(Forward_B_w)
	);

MUX_4to1 #(.size(32)) Mux_ALU_input_1(
        .data0_i(RS_data_EX_w),
        .data1_i(ALU_result_MEM_w),
        .data2_i(RDwrite_w),
        .data3_i(32'd0),
        .select_i(Forward_A_w),
        .data_o(ALU_input_1_w)
);

ALU ALU(
        .src1_i(ALU_input_1_w),
	    .src2_i(ALU_input_2_w),
	    .ctrl_i(ALU_ctrl_w),
	    .result_o(ALU_result_w),
		.zero_o(ALU_zero_w)
);
		
ALU_Ctrl ALU_Control(
        .funct_i(sign_ex_EX_w[5:0]),   
        .ALUOp_i(EX_Ctrl_EX_w[3:1]), 
        .ALUCtrl_o(ALU_ctrl_w)
);

MUX_4to1 #(.size(32)) Mux_Forward_B(
        .data0_i(RT_data_EX_w),
        .data1_i(ALU_result_MEM_w),
        .data2_i(RDwrite_w),
        .data3_i(32'd0),
        .select_i(Forward_B_w),
        .data_o(Mux_Forward_B_w)
);

MUX_2to1 #(.size(32)) Mux1(
    .data0_i(Mux_Forward_B_w),
    .data1_i(sign_ex_EX_w),
    .select_i(EX_Ctrl_EX_w[0]),
    .data_o(ALU_input_2_w)
);
		
MUX_2to1 #(.size(5)) Mux2(
    .data0_i(RT_addr_EX_w),
    .data1_i(Mux2_1_EX_w),
    .select_i(EX_Ctrl_EX_w[4]),
    .data_o(Mux2_w)
);

Adder Add_pc_branch(
    .src1_i(seq_addr_EX_w),
	.src2_i(sign_ex_shift_w),
	.sum_o(branch_addr_w)
);

Pipe_Reg #(.size(109)) EX_MEM(
    .clk_i(clk_i),      
	.rst_i (rst_i),  
    .flush_i(EX_flush_w),
    .wait_i(1'b0),
    .data_i({WB_Ctrl_EX_w,M_Ctrl_EX_w,branch_addr_w,ALU_zero_w,ALU_result_w,RT_data_EX_w,Mux2_w,BranchType_EX_w}),
    .data_o({WB_Ctrl_MEM_w,M_Ctrl_MEM_w,branch_addr_MEM_w,ALU_zero_MEM_w,ALU_result_MEM_w,RT_data_MEM_w,RD_addr_MEM_w,BranchType_MEM_w})
);


//Instantiate the components in MEM stage
Data_Memory DM(
    .clk_i(clk_i),
	.addr_i(ALU_result_MEM_w),
	.data_i(RT_data_MEM_w),
	.MemRead_i(M_Ctrl_MEM_w[1]),
	.MemWrite_i(M_Ctrl_MEM_w[0]),
	.data_o(MemData_w)
);

Pipe_Reg #(.size(71)) MEM_WB(
    .clk_i(clk_i),      
	.rst_i (rst_i),  
    .data_i({WB_Ctrl_MEM_w,MemData_w,ALU_result_MEM_w,RD_addr_MEM_w}),
    .data_o({WB_Ctrl_WB_w,MemData_WB_w,ALU_result_WB_w,RD_addr_WB_w})
);


//Instantiate the components in WB stage
MUX_2to1 #(.size(32)) Mux3(
    .data0_i(ALU_result_WB_w),
    .data1_i(MemData_WB_w),
    .select_i(WB_Ctrl_WB_w[0]),
    .data_o(RDwrite_w)
);

endmodule

