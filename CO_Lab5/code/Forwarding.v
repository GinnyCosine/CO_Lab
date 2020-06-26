module Forwarding(
    RS_addr_EX_i,
    RT_addr_EX_i,
    RD_addr_MEM_i,
    RD_addr_WB_i,
    regWrite_MEM_i,
    regWrite_WB_i,
    Forward_A_o,
    Forward_B_o
	);

input   [5-1:0]     RS_addr_EX_i;
input   [5-1:0]     RT_addr_EX_i;
input   [5-1:0]     RD_addr_MEM_i;
input   [5-1:0]     RD_addr_WB_i;
input               regWrite_MEM_i;
input               regWrite_WB_i;

output  [2-1:0]     Forward_A_o;
output  [2-1:0]     Forward_B_o;

assign Forward_A_o = (regWrite_MEM_i == 1 && RD_addr_MEM_i != 0 && 
                        RD_addr_MEM_i == RS_addr_EX_i) ? 2'b01:
                        ((regWrite_WB_i == 1 && RD_addr_WB_i != 0 && 
                        RD_addr_WB_i == RS_addr_EX_i) ? 2'b10:2'b00);

assign Forward_B_o = (regWrite_MEM_i == 1 && RD_addr_MEM_i != 0 && 
                        RD_addr_MEM_i == RT_addr_EX_i) ? 2'b01:
                        ((regWrite_WB_i == 1 && RD_addr_WB_i != 0 && 
                        RD_addr_WB_i == RT_addr_EX_i) ? 2'b10:2'b00);

endmodule