`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2026 21:33:35
// Design Name: 
// Module Name: packet_fifo_
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module packet_fifo_#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   packet_valid,
    input  wire [DATA_WIDTH-1:0]  packet_in,
    output reg                    packet_drop,
    input  wire                   packet_ready,
    output reg  [DATA_WIDTH-1:0]  packet_out,
    output reg                    packet_valid_out,
    output wire                   full,
    output wire                   empty,
    output wire [ADDR_WIDTH:0]    fifo_count
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;
    reg [ADDR_WIDTH:0]   count;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);
    assign fifo_count = count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr           <= 0;
            rd_ptr           <= 0;
            count            <= 0;
            packet_drop      <= 1'b0;
            packet_out       <= {DATA_WIDTH{1'b0}};
            packet_valid_out <= 1'b0;
        end else begin
            packet_drop <= 1'b0;
            
            case ({packet_valid && !full, packet_valid && full, packet_ready && !empty})
                // Case 1: Write only (!full & write, no read)
                3'b100: begin
                    mem[wr_ptr] <= packet_in;
                    wr_ptr      <= wr_ptr + 1;
                    count       <= count + 1;
                end

                // Case 2: Read only (read, no write)
                3'b001: begin
                    packet_out       <= mem[rd_ptr];
                    rd_ptr           <= rd_ptr + 1;
                    count            <= count - 1;
                    packet_valid_out <= 1'b1;
                end

                // Case 3: Simultaneous Write and Read
                3'b101: begin
                    mem[wr_ptr]      <= packet_in;
                    wr_ptr           <= wr_ptr + 1;
                    packet_out       <= mem[rd_ptr];
                    rd_ptr           <= rd_ptr + 1;
                    packet_valid_out <= 1'b1;
                end

                // Case 4: Write attempted when FULL
                3'b010: begin
                    packet_drop <= 1'b1;
                end

                // Case 5: Write attempted when FULL, AND a simultaneous Read occurs
                3'b011: begin
                    mem[wr_ptr]      <= packet_in;
                    wr_ptr           <= wr_ptr + 1;
                    packet_out       <= mem[rd_ptr];
                    rd_ptr           <= rd_ptr + 1;
                    packet_valid_out <= 1'b1;
                end

                default: begin
                    if (!empty && !packet_ready) begin
                        packet_valid_out <= 1'b0;
                    end else if (empty) begin
                        packet_valid_out <= 1'b0;
                    end
                end
            endcase

            if (empty && !packet_ready) begin
                packet_valid_out <= 1'b0;
            end
        end
    end

endmodule