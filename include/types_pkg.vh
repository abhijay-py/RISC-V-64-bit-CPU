`ifndef TYPES_PKG_VH
`define TYPES_PKG_VH

package types_pkg;

    //data sizes
    parameter BYTE_W    = 8;
    parameter HWORD_W   = BYTE_W * 2;
    parameter WORD_W    = BYTE_W * 4;
    parameter DWORD_W   = BYTE_W * 8;
    parameter ADDR_W = BYTE_W * 6; //More efficient addressing (used in x86)

    //Instr. Parameter sizes
    parameter OPCODE_W  = 7;
    parameter FUNCT7_W  = 7;
    parameter FUNCT3_W  = 3;
    parameter REG_W     = 5;

    //Cache sizes
    parameter CACHE_ADDR_W = ADDR_W

    parameter L1D_IDX_W = 6;
    parameter L1D_BLK_OFFSET_W = 2;
    parameter L1D_BYTE_OFFSET_W = 3;
    parameter L1D_TAG_W = CACHE_ADDR_W - L1D_IDX_W - L1D_BLK_OFFSET_W - L1D_BYTE_OFFSET_W;

    parameter L1I_IDX_W = 7;
    parameter L1I_BLK_OFFSET_W = 3;
    parameter L1I_BYTE_OFFSET_W = 2;
    parameter L1I_TAG_W = CACHE_ADDR_W - L1I_IDX_W - L1I_BLK_OFFSET_W - L1I_BYTE_OFFSET_W;

    parameter L2_IDX_W = 15;
    parameter L2_BLK_OFFSET_W = 2;
    parameter L2_BYTE_OFFSET_W = 3;
    parameter L2_TAG_W = CACHE_ADDR_W - L2_IDX_W - L2_BLK_OFFSET_W - L2_BYTE_OFFSET_W;


    //Size Types
    typedef logic [BYTE_W-1:0] byte_t;
    typedef logic [HWORD_W-1:0] hword_t;
    typedef logic [WORD_W-1:0] word_t;
    typedef logic [DWORD_W-1:0] dword_t;
    typedef logic [REG_W-1:0] reg_t;


    //Opcode Types
    typedef enum logic [OPCODE_W-1:0] {
        LOAD    = 7'b0000011,
        FENCE   = 7'b0001111,
        I_TYPE  = 7'b0010011,
        AUIPC   = 7'b0010111,
        S_TYPE   = 7'b0010011,
        R_TYPE  = 7'b0110011,
        LUI     = 7'b0110111,
        SB_TYPE = 7'b1100011,
        JALR    = 7'b1100111,
        JAL     = 7'b1101111,
        ENV_CSR = 7'b1110011,
        HALT    = 7'b1111111,
        IW_TYPE = 7'b0011011,
        RW_TYPE = 7'b0111011
    } opcode_t;


    //FUNCT3
    typedef enum logic [FUNCT3_W-1:0] {
        LB      = 3'b000,
        LH      = 3'b001,
        LW      = 3'b010,
        LD      = 3'b011,
        LBU     = 3'b100,
        LHU     = 3'b101,
        LWU     = 3'b110
    } funct3_load_t;

    typedef enum logic [FUNCT3_W-1:0] {
        FENCE   = 3'b000,
        FENCE_I = 3'b001
    } funct3_fence_t;

    typedef enum logic [FUNCT3_W-1:0] {
        ADDI    = 3'b000,
        SLLI    = 3'b001,
        SLTI    = 3'b010,
        SLTIU   = 3'b011,
        XORI    = 3'b100,
        SRAI_SRLI = 3'b101,
        ORI     = 3'b110,
        ANDI    = 3'b111
    } funct3_i_t;

    typedef enum logic [FUNCT3_W-1:0] {
        SB      = 3'b000,
        SH      = 3'b001,
        SW      = 3'b010,
        SD      = 3'b011,
    } funct3_s_t;

    typedef enum logic [FUNCT3_W-1:0] {
        ADD_SUB = 3'b000,
        SLL     = 3'b001,
        SLT     = 3'b010,
        SLTU    = 3'b011,
        XOR     = 3'b100,
        SRA_SRL = 3'b101,
        OR      = 3'b110,
        AND     = 3'b111
    } funct3_r_t;

    typedef enum logic [FUNCT3_W-1:0] {
        BEQ     = 3'b000,
        BNE     = 3'b001,
        BLT     = 3'b100,
        BGE     = 3'b101,
        BLTU    = 3'b110,
        BGEU    = 3'b111
    } funct3_sb_t;


    //FUNCT7
    typedef enum logic [FUNCT7_W-1:0] {
        ADD     = 7'b0000000,
        SUB     = 7'b0100000 
    } funct7_r_t;

    typedef enum logic [FUNCT7_W-1:0] {
        SRL     = 7'b0000000,
        SRA     = 7'b0100000
    } funct7_sr_t; //ITYPE OR RTYPE


    //ECALL/EBREAK
    typedef enum logic [11:0] {
        ECALL   = 12'b000000000000,
        EBREAK  = 12'b000000000001
    }  imm12_env_t;


    //INSTR
    typedef struct packed {
        funct7_r_t      funct7;
        reg_t           rs2;
        reg_t           rs1;
        funct3_r_t      funct3;
        reg_t           rd;
        opcode_t        opcode;
    } instr_r_t;

    typedef struct packed{
        logic [11:0]    imm;
        reg_t           rs1;
        funct3_i_t      funct3;
        reg_t           rd;
        opcode_t        opcode;
    } instr_i_t;

    typedef struct packed {
        logic [11:0]    imm;
        reg_t           rs1;
        funct3_load_t   funct3;
        reg_t           rd;
        opcode_t        opcode;
    } instr_load_t;

    typedef struct packed {
        logic [6:0]     upper_imm;
        reg_t           rs2;
        reg_t           rs1;
        funct3_s_t      funct3;
        logic [4:0]     lower_imm;
        opcode_t        opcode;
    } instr_s_t; //Includes SB type

    typedef struct packed {
        logic [19:0]    imm;
        reg_t           rd;
        opcode_t        opcode;
    } instr_u_t; //Includes UJ type


    //CACHE FRAMES
    typedef struct packed {
        logic valid;
        logic [L1I_TAG_W-1:0] tag;
        word_t [7:0] data;
    } l1icache_frame;

    typedef struct packed {
        logic valid;
        logic dirty;
        logic exclusive;
        logic [L1D_TAG_W-1:0] tag;
        dword_t [3:0] data;
    } l1dcache_frame;

    typedef struct packed {
        logic valid;
        logic dirty;
        logic [L2_TAG_W-1:0] tag;
        dword_t [3:0] data;
    } l2cache_frame;
