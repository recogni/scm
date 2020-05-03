// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module register_file_1w_multi_port_read
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32,

    parameter N_READ        = 2,
    parameter N_WRITE       = 1
)
(
    input  logic                                   clk,
    input  logic                                   rst_n,
    input  logic                                   test_en_i,

    // Read port
    input  logic [N_READ-1:0]                      ReadEnable,
    input  logic [N_READ-1:0][ADDR_WIDTH-1:0]      ReadAddr,
    output logic [N_READ-1:0][DATA_WIDTH-1:0]      ReadData,

    // Write port
    input  logic                                   WriteEnable,
    input  logic [ADDR_WIDTH-1:0]                  WriteAddr,
    input  logic [DATA_WIDTH-1:0]                  WriteData
);

    localparam    NUM_WORDS = 2**ADDR_WIDTH;

    // Read address register, located at the input of the address decoder
    logic [N_READ-1:0][ADDR_WIDTH-1:0]             ReadAddr_reg;
    logic [ADDR_WIDTH-1:0]                         WriteAddr_reg;
    logic [DATA_WIDTH-1:0]                         WriteData_reg;
    logic                                          WriteEnable_reg;

    logic [DATA_WIDTH-1:0]                         MemContent[0:NUM_WORDS-1];
    logic [NUM_WORDS-1:0]                          WriteClk;
    logic                                          clk_int;

    genvar       x;
    genvar       z;

    cluster_clock_gating CG_WE_GLOBAL
    (
        .clk_o     ( clk_int        ),
        .en_i      ( WriteEnable    ),
        .test_en_i ( test_en_i      ),
        .clk_i     ( clk            )
    );

    // Read ports
    generate
    for(x=0;x<N_READ;x=x+1) begin
        always_ff @(posedge clk) begin
            if (ReadEnable[x]) begin
                ReadAddr_reg[x] <= ReadAddr[x];
            end
        end

        always_comb begin
            if ((ReadAddr_reg[x] == WriteAddr_reg) && WriteEnable_reg) begin
                ReadData[x] = WriteData_reg;
            end else begin
                ReadData[x] = MemContent[ReadAddr_reg[x]];
            end
        end
    end
    endgenerate

    // Write port
    always_ff @(posedge clk) begin
        WriteEnable_reg <= rst_n ? WriteEnable : 1'b0;
        if (WriteEnable) begin
            WriteData_reg <= WriteData;
            WriteAddr_reg <= WriteAddr;
        end
    end

    logic [NUM_WORDS-1:0] write_decode;

    generate
    for(x=0;x<NUM_WORDS;x=x+1) begin
        assign write_decode[x] = (WriteAddr_reg == x[ADDR_WIDTH-1:0]) && WriteEnable_reg;

        cluster_clock_gating WriteClock 
            (
                .clk_o     ( WriteClk[x]     ),
                .en_i      ( write_decode[x] ),
                .test_en_i ( test_en_i       ),
                .clk_i     ( clk_int         )
            );

        always_ff @(posedge WriteClk[x]) begin
            MemContent[x] <= WriteData_reg;
        end
    end
    endgenerate

endmodule