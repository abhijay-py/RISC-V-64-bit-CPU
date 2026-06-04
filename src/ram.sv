`include "types_pkg.vh"
`include "ram_if.vh"

module ram
#(
    parameter DEPTH     = 2**16,
    parameter READ_LAT  = 10,
    parameter WRITE_LAT = 5
)
(
    input logic clk, rst_n,
    ram_if.ram ramif
);
    import types_pkg::*;

    localparam IDX_W   = $clog2(DEPTH);
    localparam MAX_LAT = READ_LAT > WRITE_LAT ? READ_LAT : WRITE_LAT;
    localparam CTR_W   = $clog2(MAX_LAT + 1);
    localparam BAD_VAL = 64'hDEAD_BEEF_DEAD_BEEF;

    dword_t mem [DEPTH];

    logic [CTR_W-1:0] count, target, next_count, next_target;
    logic [IDX_W-1:0] current_idx, next_current_idx;

    logic   busy, next_busy, current_wen, next_current_wen;
    logic   next_data_ready;
    dword_t current_wdata, next_current_wdata;
    dword_t next_rdata;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            count            <= '0;
            target           <= '0;
            busy             <= 0;
            current_wen      <= 0;
            current_idx      <= '0;
            current_wdata    <= BAD_VAL;
            ramif.data_ready <= 0;
            ramif.rdata      <= BAD_VAL;
        end
        else begin
            count            <= next_count;
            target           <= next_target;
            busy             <= next_busy;
            current_wen      <= next_current_wen;
            current_idx      <= next_current_idx;
            current_wdata    <= next_current_wdata;
            ramif.data_ready <= next_data_ready;
            ramif.rdata      <= next_rdata;

            if (next_data_ready && current_wen) begin
                mem[current_idx] <= current_wdata;
            end
        end
    end

    always_comb begin
        next_busy          = busy;
        next_target        = target;
        next_count         = count;
        next_current_wen   = current_wen;
        next_current_idx   = current_idx;
        next_current_wdata = current_wdata;
        next_data_ready    = 0;
        next_rdata         = BAD_VAL;

        if (!busy) begin
            next_current_wdata = BAD_VAL;
            if (ramif.ram_wen || ramif.ram_ren) begin
                next_busy          = 1;
                next_count         = '0;
                next_target        = CTR_W'(ramif.ram_wen ? WRITE_LAT - 1 : READ_LAT - 1);
                next_current_wen   = ramif.ram_wen;
                next_current_idx   = ramif.ram_addr[RAM_OFFSET_W + IDX_W - 1 : RAM_OFFSET_W];
                next_current_wdata = ramif.wdata;
            end
        end
        else begin
            next_count = count + 1;

            if (count == target) begin
                next_busy       = 0;
                next_data_ready = 1;
                if (!current_wen) begin
                    next_rdata = mem[current_idx];
                end
            end
        end
    end
endmodule
