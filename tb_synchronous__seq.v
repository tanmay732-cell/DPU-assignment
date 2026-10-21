`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2026 19:30:29
// Design Name: 
// Module Name: tb_synchronous__seq
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

module tb_synchronous_seq;
    reg clk = 0, rst = 1, x = 0;
    wire z;
    tb_synchronous_seq dut (.clk(clk), .rst(rst), .x(x), .z(z));

    always #5 clk = ~clk;

    reg [18:0] X = 19'b0010100100010111010;
    reg [18:0] Y = 19'b0001101011101100100;
    integer i, errors = 0;

    initial begin
        $dumpfile("tb_synchronous_seq.vcd"); $dumpvars(0, tb_synchronous_seq);
        #12 rst = 0;                         
        for (i = 18; i >= 0; i = i - 1) begin
            x = X[i];                        
            #1;                              
            if (z !== Y[i]) begin
                errors = errors + 1;
                $display("MISMATCH bit %0d: x=%b z=%b expected=%b", 18-i, x, z, Y[i]);
            end else
                $display("bit %0d: x=%b z=%b ok", 18-i, x, z);
            @(posedge clk); #1;
        end
        if (errors == 0) $display("PASS: output matches Y");
        else             $display("FAIL: %0d mismatches", errors);
        $finish;
    end
endmodule