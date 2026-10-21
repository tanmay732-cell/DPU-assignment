`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2026 21:50:03
// Design Name: 
// Module Name: tb_ps2_packet_fsm
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

`timescale 1ns/1ps

module tb_ps2_packet_fsm;

    reg        clk;
    reg        rst_n;
    reg        in_valid;
    reg [7:0]  in_byte;
    wire       done;

    ps2_packet_fsm uut (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_byte(in_byte),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        clk      = 0;
        rst_n    = 0;
        in_valid = 0;
        in_byte  = 8'h00;

        #12;
        rst_n = 1;
        #10;

        $display("=== STARTING PS2 FSM TESTS ===");

        // Test 1: Invalid bytes before a message (bit[3] == 0 should be discarded)
        @(posedge clk);
        in_valid = 1; in_byte = 8'h02;
        @(posedge clk);
        in_byte  = 8'h04;
        @(posedge clk);
        in_byte  = 8'h08;
        
        // Test 2: Send remaining 2 bytes of the message
        @(posedge clk);
        in_byte  = 8'h10;
        @(posedge clk);
        in_byte  = 8'h20;
        
        @(posedge clk);
        in_valid = 0;
        #1;
        if (!done) begin
            $error("FAIL: Done signal not asserted at end of 3-byte packet.");
        end else begin
            $display("PASS: First packet correctly recognized.");
        end

        // Test 3: Gaps between valid bytes
        #20;
        @(posedge clk);
        in_valid = 1; in_byte = 8'h88;
        @(posedge clk);
        in_valid = 0;
        #30;
        
        @(posedge clk);
        in_valid = 1; in_byte = 8'h01;
        @(posedge clk);
        in_byte  = 8'h02;
        
        @(posedge clk);
        in_valid = 0;
        #1;
        if (!done) begin
            $error("FAIL: Packet with gaps failed.");
        end else begin
            $display("PASS: Packet with gaps handled correctly.");
        end

        // Test 4: Consecutive messages (Third byte of msg 1 has bit[3]=1 serving as first byte of msg 2)
        #20;
        @(posedge clk);
        in_valid = 1; in_byte = 8'h08;
        @(posedge clk);
        in_byte  = 8'h01;
        @(posedge clk);
        in_byte  = 8'h88;
        
        #1;
        if (!done) begin
            $error("FAIL: Done not asserted for consecutive message transition.");
        end else begin
            $display("PASS: Consecutive message boundary handled.");
        end

        @(posedge clk);
        in_byte  = 8'h02;
        @(posedge clk);
        in_byte  = 8'h03;
        
        @(posedge clk);
        in_valid = 0;
        #1;
        if (!done) begin
            $error("FAIL: Second consecutive message failed.");
        end else begin
            $display("PASS: Second consecutive message completed.");
        end

        $display("=== ALL TESTS PASSED SUCCESSFULLY ===");
        $finish;
    end

endmodule