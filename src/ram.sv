`include "types_pkg.vh"
`include "ram_if.vh"

module ram 
#(
    parameter int DEPTH     = 2**16,
    parameter int READ_LAT  = 10,
    parameter int WRITE_LAT = 5
)
(
    input logic CLK, n_rst,
    ram_if.ram ramif
);
    import types_pkg::*;

    localparam int IDX_W = $clog2(DEPTH);
    localparam int MAX_LAT = READ_LAT > WRITE_LAT ? READ_LAT : WRITE_LAT;
    localparam int CTR_W = $clog2(MAX_LAT + 1);

    ram_block_t mem [DEPTH];

    logic [CTR_W-1:0] count, target, next_count, next_target;
    logic busy, next_busy, current_wen, next_current_wen;
    logic next_data_ready;
    logic [IDX_W-1:0] current_idx, next_current_idx;
    ram_block_t current_wdata, next_current_wdata;

    always_ff @(posedge CLK, negedge n_rst) begin
        if (!n_rst) begin
            count <= '0;
            target <='0;
            busy <= 0;
            current_wen <= 0;
            current_idx <= '0;
            current_wdata <= '0;
            ramif.data_ready <= 0;
            ramif.rdata  <= '0;
        end 
        else begin
            count <= next_count;
            target <= next_target;
            busy <= next_busy;
            current_wen <= next_current_wen;
            current_idx <= next_current_idx;
            current_wdata <= next_current_wdata;
            ramif.data_ready <= next_data_ready;

            if (next_data_ready) begin
                if (current_wen) begin
                    mem[current_idx] <= current_wdata;
                end
                else begin
                    ramif.rdata <= mem[current_idx];
                end
            end
        end
    end

    always_comb begin
        next_busy = busy;
        next_target = target;
        next_count = count;
        next_current_wen = current_wen;
        next_current_idx = current_idx;
        next_current_wdata = current_wdata;
        next_data_ready = 0;

        if (!busy) begin
            if (ramif.ram_wen || ramif.ram_ren) begin
                next_busy = 1;
                next_count = '0;
                next_target = CTR_W'(ramif.ram_wen ? WRITE_LAT - 1 : READ_LAT - 1);
                next_current_wen = ramif.ram_wen;
                next_current_idx = ramif.ram_addr[RAM_BYTE_OFFSET_W + IDX_W - 1 : RAM_BYTE_OFFSET_W];
                next_current_wdata = ramif.wdata;
            end
        end
        else begin
            next_count = count + 1;

            if (count == target) begin
                next_busy = 0;
                next_data_ready = 1;
            end
        end
    end
endmodule
