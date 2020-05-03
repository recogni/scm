// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Company:        Institute of Integrated Systems // ETH Zurich              //
//                                                                            //
// Engineer:      Igor Loi - igor.loi@unibo.it                                //
//                                                                            //
// Additional contributions by:                                               //
//                 Francesco Conti                                            //
//                 Davide Rossi                                               //
//                 Michael Gautschi                                           //
//                 Antonio Pullini                                            //
//                                                                            //
// Create Date:    12/03/2015                                                 //
// Design Name:    scm memory                                                 //
// Module Name:    register_file_1r_1w                                        //
// Project Name:   HWCE                                                       //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    scm memory multiport: FOR HWCE                             //
//                                                                            //
// Revision:                                                                  //
// Revision v0.1 - File Created                                               //
// Revision v0.2 - Improved Identation                                        //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module register_file_1r_1w
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32
)
(
    input  logic                                  clk,

    // Read port
    input  logic                                  ReadEnable,
    input  logic [ADDR_WIDTH-1:0]                 ReadAddr,
    output logic [DATA_WIDTH-1:0]                 ReadData,


    // Write port
    input  logic                                  WriteEnable,
    input  logic [ADDR_WIDTH-1:0]                 WriteAddr,
    input  logic [DATA_WIDTH-1:0]                 WriteData
);

    register_file_1w_multi_port_read #( 
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .N_READ(1), 
        .N_WRITE(1)
    ) regfile_1w_1r (
        .rst_n(1'b0),
        .test_en_i(1'b0),
        .*
    );

endmodule