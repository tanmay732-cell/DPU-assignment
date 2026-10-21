`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2026 19:24:58
// Design Name: 
// Module Name: synchronous_seq
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


module seq_det (
    input  wire clk,
    input  wire rst,     
    input  wire x,
    output wire z
);
    reg [2:0] hist;       
    reg [1:0] count;        

    wire [3:0] win   = {hist, x};         
    wire       match = (win == 4'd2)  || (win == 4'd4)  || (win == 4'd5) ||
                       (win == 4'd8)  || (win == 4'd14);

    assign z = (count == 2'd3) && match;

    always @(posedge clk) begin
        if (rst) begin
            hist <= 3'b000;
            count  <= 2'd0;
        end else begin
            hist <= {hist[1:0], x};        
            if (count != 2'd3)
                count <= count + 1'b1;       
        end
    end
endmodule