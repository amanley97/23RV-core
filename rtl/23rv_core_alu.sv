//
// 23RV ALU
//

`timescale 1 ns / 1 ps

module 23rv_core_alu #(
    parameter ADDRESS_BITWIDTH = 5,
    parameter DATA_WIDTH = DATA_WIDTH
  ) (
        input  wire clk,
        input  wire reset,
       
        // register source 1 
        input  wire  [DATA_WIDTH-1:0] alu_rs1_val,
        // register source 2 
        input  wire  [DATA_WIDTH-1:0] alu_rs2_val,
        // register destination
        output logic [DATA_WIDTH-1:0] alu_rd_val,
    );

    // asuming we have this infromation coming from the instruction bus or the control unit
    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [ADDRESS_BITWIDTH-1:0]  rs1;
    logic [ADDRESS_BITWIDTH-1:0]  rs2;
    logic [ADDRESS_BITWIDTH-1:0]  rd;
    logic [11:0] imm12;
    logic [4:0]  shamt;


    logic [DATA_WIDTH-1:0] _add;  // add
    logic [DATA_WIDTH-1:0] _sub;  // sub
    logic [DATA_WIDTH-1:0] _slt;  // set less than
    logic [DATA_WIDTH-1:0] _sltu; // set less than unsigned
    logic [DATA_WIDTH-1:0] _xor;  // xor
    logic [DATA_WIDTH-1:0] _or;   // or
    logic [DATA_WIDTH-1:0] _and;  // and
    logic [DATA_WIDTH-1:0] _sll;  // shift left logical
    logic [DATA_WIDTH-1:0] _srl;  // shift right logical
    logic [DATA_WIDTH-1:0] _sra;  // shift right arithmetic

    logic [DATA_WIDTH-1:0] _addi;  // add immediate
    logic [DATA_WIDTH-1:0] _slti;  // set less than immediate
    logic [DATA_WIDTH-1:0] _sltiu; // set less than immediate unsigned
    logic [DATA_WIDTH-1:0] _xori;  // xor immediate
    logic [DATA_WIDTH-1:0] _ori;   // or immediate
    logic [DATA_WIDTH-1:0] _andi;  // and immediate
    logic [DATA_WIDTH-1:0] _slli;  // shift left logical immediate
    logic [DATA_WIDTH-1:0] _srli;  // shift right logical immediate
    logic [DATA_WIDTH-1:0] _srai;  // shift right arithmetic immediate

    
    always @ (posedge clk or negedge reset) begin
        if (!reset) begin
            alu_rd_val <= {DATA_WIDTH{1'b0}};
        end else begin
        
        // see docs/insts.png 
        // I_ARITH 7'b0010011 = in decimal 19
        // R_ARITH 7'b0110011 = in decimal 51
        // ADDI    3'b000
        // SLTI    3'b010
        // SLTIU   3'b011
        // XORI    3'b100
        // ORI     3'b110
        // ANDI    3'b111
        // SLLI    3'b001
        // SRLI    3'b101
        // SRAI    3'b101
        // ADD     3'b000
        // SUB     3'b000
        // SLL     3'b001
        // SLT     3'b010
        // SLTU    3'b011
        // XOR     3'b100
        // SRL     3'b101
        // SRA     3'b101
        // OR      3'b110
        // AND     3'b111


           alu_rd_val <=    (opcode==7'b0010011 && funct3==3'b000) ? _addi :
                            (opcode==7'b0010011 && funct3==3'b010) ? _slti :
                            (opcode==7'b0010011 && funct3==3'b011) ? _sltiu :
                            (opcode==7'b0010011 && funct3==3'b100) ? _xori :
                            (opcode==7'b0010011 && funct3==3'b110) ? _ori  :
                            (opcode==7'b0010011 && funct3==3'b111) ? _andi :
                            (opcode==7'b0010011 && funct3==3'b001) ? _slli :
                            (opcode==7'b0010011 && funct3==3'b101 && funct7[5]==1'b0) ? _srli :
                            (opcode==7'b0010011 && funct3==3'b101 && funct7[5]==1'b1) ? _srai :
                            (opcode==7'b0110011 && funct3==3'b000 && funct7[5]==1'b0) ? _add  :
                            (opcode==7'b0110011 && funct3==3'b000 && funct7[5]==1'b1) ? _sub  :
                            (opcode==7'b0110011 && funct3==3'b010) ? _slt  :
                            (opcode==7'b0110011 && funct3==3'b011) ? _sltu :
                            (opcode==7'b0110011 && funct3==3'b100) ? _xor  :
                            (opcode==7'b0110011 && funct3==3'b110) ? _or   :
                            (opcode==7'b0110011 && funct3==3'b111) ? _and  :
                            (opcode==7'b0110011 && funct3==3'b001) ? _sll  :
                            (opcode==7'b0110011 && funct3==3'b101 && funct7[5]==1'b0) ? _srl  :
                            (opcode==7'b0110011 && funct3==3'b101 && funct7[5]==1'b1) ? _sra  :
                                                        {DATA_WIDTH{1'b0}};
        end
    end


    // I-type instructions
    assign _addi = $signed({{(DATA_WIDTH-12){imm12[11]}}, imm12}) + $signed(alu_rs1_val);

    assign _slti = ($signed(alu_rs1_val) < $signed({{(DATA_WIDTH-12){imm12[11]}}, imm12})) ? {{DATA_WIDTH-1{1'b0}}, 1'b1} :
                                                                                       {DATA_WIDTH{1'b0}};

    assign _sltiu = (alu_rs1_val < {{(DATA_WIDTH-12){imm12[11]}}, imm12}) ? {{DATA_WIDTH-1{1'b0}}, 1'b1} :
                                                                      {DATA_WIDTH{1'b0}};

    assign _xori = {{(DATA_WIDTH-12){imm12[11]}}, imm12} ^ alu_rs1_val;

    assign _ori = {{(DATA_WIDTH-12){imm12[11]}}, imm12} | alu_rs1_val;

    assign _andi = {{(DATA_WIDTH-12){imm12[11]}}, imm12} & alu_rs1_val;

    assign _slli = (shamt == 5'd01) ? {alu_rs1_val[DATA_WIDTH-1-01:0],  1'b0} :
                   (shamt == 5'd02) ? {alu_rs1_val[DATA_WIDTH-1-02:0],  2'b0} :
                   (shamt == 5'd03) ? {alu_rs1_val[DATA_WIDTH-1-03:0],  3'b0} :
                   (shamt == 5'd04) ? {alu_rs1_val[DATA_WIDTH-1-04:0],  4'b0} :
                   (shamt == 5'd05) ? {alu_rs1_val[DATA_WIDTH-1-05:0],  5'b0} :
                   (shamt == 5'd06) ? {alu_rs1_val[DATA_WIDTH-1-06:0],  6'b0} :
                   (shamt == 5'd07) ? {alu_rs1_val[DATA_WIDTH-1-07:0],  7'b0} :
                   (shamt == 5'd08) ? {alu_rs1_val[DATA_WIDTH-1-08:0],  8'b0} :
                   (shamt == 5'd09) ? {alu_rs1_val[DATA_WIDTH-1-09:0],  9'b0} :
                   (shamt == 5'd10) ? {alu_rs1_val[DATA_WIDTH-1-10:0], 10'b0} :
                   (shamt == 5'd11) ? {alu_rs1_val[DATA_WIDTH-1-11:0], 11'b0} :
                   (shamt == 5'd12) ? {alu_rs1_val[DATA_WIDTH-1-12:0], 12'b0} :
                   (shamt == 5'd13) ? {alu_rs1_val[DATA_WIDTH-1-13:0], 13'b0} :
                   (shamt == 5'd14) ? {alu_rs1_val[DATA_WIDTH-1-14:0], 14'b0} :
                   (shamt == 5'd15) ? {alu_rs1_val[DATA_WIDTH-1-15:0], 15'b0} :
                   (shamt == 5'd16) ? {alu_rs1_val[DATA_WIDTH-1-16:0], 16'b0} :
                   (shamt == 5'd17) ? {alu_rs1_val[DATA_WIDTH-1-17:0], 17'b0} :
                   (shamt == 5'd18) ? {alu_rs1_val[DATA_WIDTH-1-18:0], 18'b0} :
                   (shamt == 5'd19) ? {alu_rs1_val[DATA_WIDTH-1-19:0], 19'b0} :
                   (shamt == 5'd20) ? {alu_rs1_val[DATA_WIDTH-1-20:0], 20'b0} :
                   (shamt == 5'd21) ? {alu_rs1_val[DATA_WIDTH-1-21:0], 21'b0} :
                   (shamt == 5'd22) ? {alu_rs1_val[DATA_WIDTH-1-22:0], 22'b0} :
                   (shamt == 5'd23) ? {alu_rs1_val[DATA_WIDTH-1-23:0], 23'b0} :
                   (shamt == 5'd24) ? {alu_rs1_val[DATA_WIDTH-1-24:0], 24'b0} :
                   (shamt == 5'd25) ? {alu_rs1_val[DATA_WIDTH-1-25:0], 25'b0} :
                   (shamt == 5'd26) ? {alu_rs1_val[DATA_WIDTH-1-26:0], 26'b0} :
                   (shamt == 5'd27) ? {alu_rs1_val[DATA_WIDTH-1-27:0], 27'b0} :
                   (shamt == 5'd28) ? {alu_rs1_val[DATA_WIDTH-1-28:0], 28'b0} :
                   (shamt == 5'd29) ? {alu_rs1_val[DATA_WIDTH-1-29:0], 29'b0} :
                   (shamt == 5'd30) ? {alu_rs1_val[DATA_WIDTH-1-30:0], 30'b0} :
                   (shamt == 5'd31) ? {alu_rs1_val[DATA_WIDTH-1-31:0], 31'b0} :
                                      {alu_rs1_val[DATA_WIDTH-1:0]} ;

    assign _srli = (shamt == 5'd01) ? {01'b0, alu_rs1_val[DATA_WIDTH-1:01]} :
                   (shamt == 5'd02) ? {02'b0, alu_rs1_val[DATA_WIDTH-1:02]} :
                   (shamt == 5'd03) ? {03'b0, alu_rs1_val[DATA_WIDTH-1:03]} :
                   (shamt == 5'd04) ? {04'b0, alu_rs1_val[DATA_WIDTH-1:04]} :
                   (shamt == 5'd05) ? {05'b0, alu_rs1_val[DATA_WIDTH-1:05]} :
                   (shamt == 5'd06) ? {06'b0, alu_rs1_val[DATA_WIDTH-1:06]} :
                   (shamt == 5'd07) ? {07'b0, alu_rs1_val[DATA_WIDTH-1:07]} :
                   (shamt == 5'd08) ? {08'b0, alu_rs1_val[DATA_WIDTH-1:08]} :
                   (shamt == 5'd09) ? {09'b0, alu_rs1_val[DATA_WIDTH-1:09]} :
                   (shamt == 5'd10) ? {10'b0, alu_rs1_val[DATA_WIDTH-1:10]} :
                   (shamt == 5'd11) ? {11'b0, alu_rs1_val[DATA_WIDTH-1:11]} :
                   (shamt == 5'd12) ? {12'b0, alu_rs1_val[DATA_WIDTH-1:12]} :
                   (shamt == 5'd13) ? {13'b0, alu_rs1_val[DATA_WIDTH-1:13]} :
                   (shamt == 5'd14) ? {14'b0, alu_rs1_val[DATA_WIDTH-1:14]} :
                   (shamt == 5'd15) ? {15'b0, alu_rs1_val[DATA_WIDTH-1:15]} :
                   (shamt == 5'd16) ? {16'b0, alu_rs1_val[DATA_WIDTH-1:16]} :
                   (shamt == 5'd17) ? {17'b0, alu_rs1_val[DATA_WIDTH-1:17]} :
                   (shamt == 5'd18) ? {18'b0, alu_rs1_val[DATA_WIDTH-1:18]} :
                   (shamt == 5'd19) ? {19'b0, alu_rs1_val[DATA_WIDTH-1:19]} :
                   (shamt == 5'd20) ? {20'b0, alu_rs1_val[DATA_WIDTH-1:20]} :
                   (shamt == 5'd21) ? {21'b0, alu_rs1_val[DATA_WIDTH-1:21]} :
                   (shamt == 5'd22) ? {22'b0, alu_rs1_val[DATA_WIDTH-1:22]} :
                   (shamt == 5'd23) ? {23'b0, alu_rs1_val[DATA_WIDTH-1:23]} :
                   (shamt == 5'd24) ? {24'b0, alu_rs1_val[DATA_WIDTH-1:24]} :
                   (shamt == 5'd25) ? {25'b0, alu_rs1_val[DATA_WIDTH-1:25]} :
                   (shamt == 5'd26) ? {26'b0, alu_rs1_val[DATA_WIDTH-1:26]} :
                   (shamt == 5'd27) ? {27'b0, alu_rs1_val[DATA_WIDTH-1:27]} :
                   (shamt == 5'd28) ? {28'b0, alu_rs1_val[DATA_WIDTH-1:28]} :
                   (shamt == 5'd29) ? {29'b0, alu_rs1_val[DATA_WIDTH-1:29]} :
                   (shamt == 5'd30) ? {30'b0, alu_rs1_val[DATA_WIDTH-1:30]} :
                   (shamt == 5'd31) ? {31'b0, alu_rs1_val[DATA_WIDTH-1:31]} :
                                      {alu_rs1_val[DATA_WIDTH-1:0]} ;

    assign _srai = (shamt == 5'd01) ? {{01{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:01]} :
                   (shamt == 5'd02) ? {{02{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:02]} :
                   (shamt == 5'd03) ? {{03{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:03]} :
                   (shamt == 5'd04) ? {{04{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:04]} :
                   (shamt == 5'd05) ? {{05{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:05]} :
                   (shamt == 5'd06) ? {{06{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:06]} :
                   (shamt == 5'd07) ? {{07{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:07]} :
                   (shamt == 5'd08) ? {{08{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:08]} :
                   (shamt == 5'd09) ? {{09{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:09]} :
                   (shamt == 5'd10) ? {{10{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:10]} :
                   (shamt == 5'd11) ? {{11{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:11]} :
                   (shamt == 5'd12) ? {{12{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:12]} :
                   (shamt == 5'd13) ? {{13{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:13]} :
                   (shamt == 5'd14) ? {{14{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:14]} :
                   (shamt == 5'd15) ? {{15{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:15]} :
                   (shamt == 5'd16) ? {{16{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:16]} :
                   (shamt == 5'd17) ? {{17{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:17]} :
                   (shamt == 5'd18) ? {{18{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:18]} :
                   (shamt == 5'd19) ? {{19{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:19]} :
                   (shamt == 5'd20) ? {{20{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:20]} :
                   (shamt == 5'd21) ? {{21{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:21]} :
                   (shamt == 5'd22) ? {{22{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:22]} :
                   (shamt == 5'd23) ? {{23{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:23]} :
                   (shamt == 5'd24) ? {{24{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:24]} :
                   (shamt == 5'd25) ? {{25{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:25]} :
                   (shamt == 5'd26) ? {{26{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:26]} :
                   (shamt == 5'd27) ? {{27{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:27]} :
                   (shamt == 5'd28) ? {{28{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:28]} :
                   (shamt == 5'd29) ? {{29{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:29]} :
                   (shamt == 5'd30) ? {{30{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:30]} :
                   (shamt == 5'd31) ? {{31{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:31]} :
                                      {alu_rs1_val[DATA_WIDTH-1:0]} ;

    // R-type instructions
    assign _add = $signed(alu_rs1_val) + $signed(alu_rs2_val);

    assign _sub = $signed(alu_rs1_val) - $signed(alu_rs2_val);

    assign _slt = ($signed(alu_rs1_val) < $signed(alu_rs2_val)) ? {{DATA_WIDTH-1{1'b0}}, 1'b1} :
                                                                  {DATA_WIDTH{1'b0}};

    assign _sltu = (alu_rs1_val < alu_rs2_val) ? {{DATA_WIDTH-1{1'b0}}, 1'b1} :
                                                  {DATA_WIDTH{1'b0}};

    assign _xor = alu_rs1_val ^ alu_rs2_val;

    assign _or = alu_rs1_val | alu_rs2_val;

    assign _and = alu_rs1_val & alu_rs2_val;

    assign _sll = (alu_rs2_val[4:0] == 5'd01) ? {alu_rs1_val[DATA_WIDTH-1-01:0], 01'b0} :
                  (alu_rs2_val[4:0] == 5'd02) ? {alu_rs1_val[DATA_WIDTH-1-02:0], 02'b0} :
                  (alu_rs2_val[4:0] == 5'd03) ? {alu_rs1_val[DATA_WIDTH-1-03:0], 03'b0} :
                  (alu_rs2_val[4:0] == 5'd04) ? {alu_rs1_val[DATA_WIDTH-1-04:0], 04'b0} :
                  (alu_rs2_val[4:0] == 5'd05) ? {alu_rs1_val[DATA_WIDTH-1-05:0], 05'b0} :
                  (alu_rs2_val[4:0] == 5'd06) ? {alu_rs1_val[DATA_WIDTH-1-06:0], 06'b0} :
                  (alu_rs2_val[4:0] == 5'd07) ? {alu_rs1_val[DATA_WIDTH-1-07:0], 07'b0} :
                  (alu_rs2_val[4:0] == 5'd08) ? {alu_rs1_val[DATA_WIDTH-1-08:0], 08'b0} :
                  (alu_rs2_val[4:0] == 5'd09) ? {alu_rs1_val[DATA_WIDTH-1-09:0], 09'b0} :
                  (alu_rs2_val[4:0] == 5'd10) ? {alu_rs1_val[DATA_WIDTH-1-10:0], 10'b0} :
                  (alu_rs2_val[4:0] == 5'd11) ? {alu_rs1_val[DATA_WIDTH-1-11:0], 11'b0} :
                  (alu_rs2_val[4:0] == 5'd12) ? {alu_rs1_val[DATA_WIDTH-1-12:0], 12'b0} :
                  (alu_rs2_val[4:0] == 5'd13) ? {alu_rs1_val[DATA_WIDTH-1-13:0], 13'b0} :
                  (alu_rs2_val[4:0] == 5'd14) ? {alu_rs1_val[DATA_WIDTH-1-14:0], 14'b0} :
                  (alu_rs2_val[4:0] == 5'd15) ? {alu_rs1_val[DATA_WIDTH-1-15:0], 15'b0} :
                  (alu_rs2_val[4:0] == 5'd16) ? {alu_rs1_val[DATA_WIDTH-1-16:0], 16'b0} :
                  (alu_rs2_val[4:0] == 5'd17) ? {alu_rs1_val[DATA_WIDTH-1-17:0], 17'b0} :
                  (alu_rs2_val[4:0] == 5'd18) ? {alu_rs1_val[DATA_WIDTH-1-18:0], 18'b0} :
                  (alu_rs2_val[4:0] == 5'd19) ? {alu_rs1_val[DATA_WIDTH-1-19:0], 19'b0} :
                  (alu_rs2_val[4:0] == 5'd20) ? {alu_rs1_val[DATA_WIDTH-1-20:0], 20'b0} :
                  (alu_rs2_val[4:0] == 5'd21) ? {alu_rs1_val[DATA_WIDTH-1-21:0], 21'b0} :
                  (alu_rs2_val[4:0] == 5'd22) ? {alu_rs1_val[DATA_WIDTH-1-22:0], 22'b0} :
                  (alu_rs2_val[4:0] == 5'd23) ? {alu_rs1_val[DATA_WIDTH-1-23:0], 23'b0} :
                  (alu_rs2_val[4:0] == 5'd24) ? {alu_rs1_val[DATA_WIDTH-1-24:0], 24'b0} :
                  (alu_rs2_val[4:0] == 5'd25) ? {alu_rs1_val[DATA_WIDTH-1-25:0], 25'b0} :
                  (alu_rs2_val[4:0] == 5'd26) ? {alu_rs1_val[DATA_WIDTH-1-26:0], 26'b0} :
                  (alu_rs2_val[4:0] == 5'd27) ? {alu_rs1_val[DATA_WIDTH-1-27:0], 27'b0} :
                  (alu_rs2_val[4:0] == 5'd28) ? {alu_rs1_val[DATA_WIDTH-1-28:0], 28'b0} :
                  (alu_rs2_val[4:0] == 5'd29) ? {alu_rs1_val[DATA_WIDTH-1-29:0], 29'b0} :
                  (alu_rs2_val[4:0] == 5'd30) ? {alu_rs1_val[DATA_WIDTH-1-30:0], 30'b0} :
                  (alu_rs2_val[4:0] == 5'd31) ? {alu_rs1_val[DATA_WIDTH-1-31:0], 31'b0} :
                                                {alu_rs1_val[DATA_WIDTH-1:0]} ;

    assign _srl = (alu_rs2_val[4:0] == 5'd01) ? {01'b0, alu_rs1_val[DATA_WIDTH-1:01]} :
                  (alu_rs2_val[4:0] == 5'd02) ? {02'b0, alu_rs1_val[DATA_WIDTH-1:02]} :
                  (alu_rs2_val[4:0] == 5'd03) ? {03'b0, alu_rs1_val[DATA_WIDTH-1:03]} :
                  (alu_rs2_val[4:0] == 5'd04) ? {04'b0, alu_rs1_val[DATA_WIDTH-1:04]} :
                  (alu_rs2_val[4:0] == 5'd05) ? {05'b0, alu_rs1_val[DATA_WIDTH-1:05]} :
                  (alu_rs2_val[4:0] == 5'd06) ? {06'b0, alu_rs1_val[DATA_WIDTH-1:06]} :
                  (alu_rs2_val[4:0] == 5'd07) ? {07'b0, alu_rs1_val[DATA_WIDTH-1:07]} :
                  (alu_rs2_val[4:0] == 5'd08) ? {08'b0, alu_rs1_val[DATA_WIDTH-1:08]} :
                  (alu_rs2_val[4:0] == 5'd09) ? {09'b0, alu_rs1_val[DATA_WIDTH-1:09]} :
                  (alu_rs2_val[4:0] == 5'd10) ? {10'b0, alu_rs1_val[DATA_WIDTH-1:10]} :
                  (alu_rs2_val[4:0] == 5'd11) ? {11'b0, alu_rs1_val[DATA_WIDTH-1:11]} :
                  (alu_rs2_val[4:0] == 5'd12) ? {12'b0, alu_rs1_val[DATA_WIDTH-1:12]} :
                  (alu_rs2_val[4:0] == 5'd13) ? {13'b0, alu_rs1_val[DATA_WIDTH-1:13]} :
                  (alu_rs2_val[4:0] == 5'd14) ? {14'b0, alu_rs1_val[DATA_WIDTH-1:14]} :
                  (alu_rs2_val[4:0] == 5'd15) ? {15'b0, alu_rs1_val[DATA_WIDTH-1:15]} :
                  (alu_rs2_val[4:0] == 5'd16) ? {16'b0, alu_rs1_val[DATA_WIDTH-1:16]} :
                  (alu_rs2_val[4:0] == 5'd17) ? {17'b0, alu_rs1_val[DATA_WIDTH-1:17]} :
                  (alu_rs2_val[4:0] == 5'd18) ? {18'b0, alu_rs1_val[DATA_WIDTH-1:18]} :
                  (alu_rs2_val[4:0] == 5'd19) ? {19'b0, alu_rs1_val[DATA_WIDTH-1:19]} :
                  (alu_rs2_val[4:0] == 5'd20) ? {20'b0, alu_rs1_val[DATA_WIDTH-1:20]} :
                  (alu_rs2_val[4:0] == 5'd21) ? {21'b0, alu_rs1_val[DATA_WIDTH-1:21]} :
                  (alu_rs2_val[4:0] == 5'd22) ? {22'b0, alu_rs1_val[DATA_WIDTH-1:22]} :
                  (alu_rs2_val[4:0] == 5'd23) ? {23'b0, alu_rs1_val[DATA_WIDTH-1:23]} :
                  (alu_rs2_val[4:0] == 5'd24) ? {24'b0, alu_rs1_val[DATA_WIDTH-1:24]} :
                  (alu_rs2_val[4:0] == 5'd25) ? {25'b0, alu_rs1_val[DATA_WIDTH-1:25]} :
                  (alu_rs2_val[4:0] == 5'd26) ? {26'b0, alu_rs1_val[DATA_WIDTH-1:26]} :
                  (alu_rs2_val[4:0] == 5'd27) ? {27'b0, alu_rs1_val[DATA_WIDTH-1:27]} :
                  (alu_rs2_val[4:0] == 5'd28) ? {28'b0, alu_rs1_val[DATA_WIDTH-1:28]} :
                  (alu_rs2_val[4:0] == 5'd29) ? {29'b0, alu_rs1_val[DATA_WIDTH-1:29]} :
                  (alu_rs2_val[4:0] == 5'd30) ? {30'b0, alu_rs1_val[DATA_WIDTH-1:30]} :
                  (alu_rs2_val[4:0] == 5'd31) ? {31'b0, alu_rs1_val[DATA_WIDTH-1:31]} :
                                                {alu_rs1_val[DATA_WIDTH-1:0]} ;

    assign _sra = (alu_rs2_val[4:0] == 5'd01) ? {{01{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:01]} :
                  (alu_rs2_val[4:0] == 5'd02) ? {{02{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:02]} :
                  (alu_rs2_val[4:0] == 5'd03) ? {{03{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:03]} :
                  (alu_rs2_val[4:0] == 5'd04) ? {{04{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:04]} :
                  (alu_rs2_val[4:0] == 5'd05) ? {{05{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:05]} :
                  (alu_rs2_val[4:0] == 5'd06) ? {{06{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:06]} :
                  (alu_rs2_val[4:0] == 5'd07) ? {{07{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:07]} :
                  (alu_rs2_val[4:0] == 5'd08) ? {{08{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:08]} :
                  (alu_rs2_val[4:0] == 5'd09) ? {{09{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:09]} :
                  (alu_rs2_val[4:0] == 5'd10) ? {{10{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:10]} :
                  (alu_rs2_val[4:0] == 5'd11) ? {{11{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:11]} :
                  (alu_rs2_val[4:0] == 5'd12) ? {{12{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:12]} :
                  (alu_rs2_val[4:0] == 5'd13) ? {{13{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:13]} :
                  (alu_rs2_val[4:0] == 5'd14) ? {{14{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:14]} :
                  (alu_rs2_val[4:0] == 5'd15) ? {{15{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:15]} :
                  (alu_rs2_val[4:0] == 5'd16) ? {{16{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:16]} :
                  (alu_rs2_val[4:0] == 5'd17) ? {{17{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:17]} :
                  (alu_rs2_val[4:0] == 5'd18) ? {{18{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:18]} :
                  (alu_rs2_val[4:0] == 5'd19) ? {{19{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:19]} :
                  (alu_rs2_val[4:0] == 5'd20) ? {{20{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:20]} :
                  (alu_rs2_val[4:0] == 5'd21) ? {{21{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:21]} :
                  (alu_rs2_val[4:0] == 5'd22) ? {{22{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:22]} :
                  (alu_rs2_val[4:0] == 5'd23) ? {{23{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:23]} :
                  (alu_rs2_val[4:0] == 5'd24) ? {{24{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:24]} :
                  (alu_rs2_val[4:0] == 5'd25) ? {{25{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:25]} :
                  (alu_rs2_val[4:0] == 5'd26) ? {{26{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:26]} :
                  (alu_rs2_val[4:0] == 5'd27) ? {{27{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:27]} :
                  (alu_rs2_val[4:0] == 5'd28) ? {{28{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:28]} :
                  (alu_rs2_val[4:0] == 5'd29) ? {{29{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:29]} :
                  (alu_rs2_val[4:0] == 5'd30) ? {{30{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:30]} :
                  (alu_rs2_val[4:0] == 5'd31) ? {{31{alu_rs1_val[DATA_WIDTH-1]}}, alu_rs1_val[DATA_WIDTH-1:31]} :
                                                {alu_rs1_val[DATA_WIDTH-1:0]} ;


endmodule
