module Hazard_Detection(
    PC_src_i,
    MemRead_EX_i,
    RS_IFID_addr_i,
    RT_IFID_addr_i,
    RT_IDEX_addr_i,
    PC_write_o,
    IF_wait_o,
    IF_flush_o,
    ID_flush_o,
    EX_flush_o
	);

input   PC_src_i;   // 判斷是不是 branch
input   MemRead_EX_i;
input   [5-1:0]  RS_IFID_addr_i;
input   [5-1:0]  RT_IFID_addr_i;
input   [5-1:0]  RT_IDEX_addr_i;

output  PC_write_o;
output  IF_wait_o;
output  IF_flush_o;
output  ID_flush_o;
output  EX_flush_o;

reg  PC_write_o;
reg  IF_wait_o;
reg  IF_flush_o;
reg  ID_flush_o;
reg  EX_flush_o;

always @(*) begin
    case(PC_src_i)
        1:
        begin
            PC_write_o <= 1;
            IF_wait_o <= 0;
            IF_flush_o <= 1;
            ID_flush_o <= 1;
            EX_flush_o <= 1;
        end
        0:
        begin
            if (MemRead_EX_i == 1 && (RT_IDEX_addr_i == RT_IFID_addr_i || RT_IDEX_addr_i == RS_IFID_addr_i)) begin
                PC_write_o <= 0;
                IF_wait_o <= 1;
                IF_flush_o <= 0;
                ID_flush_o <= 1;
                EX_flush_o <= 0;
            end
            else begin
                PC_write_o <= 1;
                IF_wait_o <= 0;
                IF_flush_o <= 0;
                ID_flush_o <= 0;
                EX_flush_o <= 0;
            end
        end
    endcase
end

endmodule