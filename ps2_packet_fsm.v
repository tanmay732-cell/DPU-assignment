`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2026 21:49:05
// Design Name: 
// Module Name: ps2_packet_fsm
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


module ps2_packet_fsm (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        in_valid,
    input  wire [7:0]  in_byte,
    output reg         done
);

    parameter S_SEARCH = 2'b00;
    parameter S_BYTE2  = 2'b01;
    parameter S_BYTE3  = 2'b10;

    reg [1:0] state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_SEARCH;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        done       = 1'b0;

        case (state)
            S_SEARCH: begin
                if (in_valid) begin
                    if (in_byte[3] == 1'b1) begin
                        next_state = S_BYTE2;
                    end else begin
                        next_state = S_SEARCH;
                    end
                end
            end

            S_BYTE2: begin
                if (in_valid) begin
                    next_state = S_BYTE3;
                end
            end

            S_BYTE3: begin
                if (in_valid) begin
                    done       = 1'b1;
                    if (in_byte[3] == 1'b1) begin
                        next_state = S_BYTE2;
                    end else begin
                        next_state = S_SEARCH;
                    end
                end
            end

            default: begin
                next_state = S_SEARCH;
            end
        endcase
    end

endmodule