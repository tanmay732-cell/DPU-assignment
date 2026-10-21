`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2026 21:34:41
// Design Name: 
// Module Name: tb_packet_fifo
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

module tb_packet_fifo;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 3;
    parameter DEPTH      = 1 << ADDR_WIDTH;

    reg                   clk;
    reg                   rst_n;
    reg                   packet_valid;
    reg [DATA_WIDTH-1:0]  packet_in;
    wire                  packet_drop;
    reg                   packet_ready;
    wire [DATA_WIDTH-1:0] packet_out;
    wire                  packet_valid_out;
    wire                  full;
    wire                  empty;
    wire [ADDR_WIDTH:0]   fifo_count;

    integer i;

    packet_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .packet_valid(packet_valid),
        .packet_in(packet_in),
        .packet_drop(packet_drop),
        .packet_ready(packet_ready),
        .packet_out(packet_out),
        .packet_valid_out(packet_valid_out),
        .full(full),
        .empty(empty),
        .fifo_count(fifo_count)
    );

    always #5 clk = ~clk;

    reg [DATA_WIDTH-1:0] model_queue [0:DEPTH-1];
    integer q_head = 0;
    integer q_tail = 0;
    integer q_size = 0;
    reg [DATA_WIDTH-1:0] expected_val;

    initial begin
        clk          = 0;
        rst_n        = 0;
        packet_valid = 0;
        packet_in    = 0;
        packet_ready = 0;

        #12;
        rst_n = 1;
        #10;

        if (!empty || full || (fifo_count != 0)) begin
            $error("FAIL: Initial empty condition incorrect.");
        end else begin
            $display("PASS: Initial empty condition verified.");
        end

        @(posedge clk);
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(posedge clk);
            packet_valid = 1;
            packet_in    = i + 8'hA0;
            model_queue[q_tail] = packet_in;
            q_tail = (q_tail + 1) % DEPTH;
            q_size = q_size + 1;
        end

        @(posedge clk);
        packet_valid = 0;
        #1;

        if (!full || empty || (fifo_count != DEPTH)) begin
            $error("FAIL: Full condition check failed.");
        end else begin
            $display("PASS: FIFO Full condition verified.");
        end

        @(posedge clk);
        packet_valid = 1;
        packet_in    = 8'hFF;
        @(posedge clk);
        packet_valid = 0;
        #1;

        if (!packet_drop) begin
            $error("FAIL: packet_drop not asserted on full write!");
        end else begin
            $display("PASS: Packet drop on full FIFO verified.");
        end

        for (i = 0; i < DEPTH; i = i + 1) begin
            @(posedge clk);
            packet_ready = 1;
            @(posedge clk);
            #1;
            if (packet_out !== model_queue[q_head]) begin
                $error("FAIL: Data mismatch! Expected: %h, Got: %h", model_queue[q_head], packet_out);
            end else begin
                $display("PASS: Correct packet popped: %h", packet_out);
            end
            q_head = (q_head + 1) % DEPTH;
            q_size = q_size - 1;
        end

        @(posedge clk);
        packet_ready = 0;
        #1;

        if (!empty) begin
            $error("FAIL: FIFO should be empty after clearing all elements.");
        end else begin
            $display("PASS: FIFO Empty condition verified post-drain.");
        end

        @(posedge clk);
        packet_valid = 1;
        packet_in    = 8'h11;
        model_queue[q_tail] = 8'h11; q_tail = (q_tail + 1) % DEPTH; q_size = q_size + 1;
        @(posedge clk);
        packet_in    = 8'h22;
        model_queue[q_tail] = 8'h22; q_tail = (q_tail + 1) % DEPTH; q_size = q_size + 1;
        
        @(posedge clk);
        packet_valid = 1;
        packet_ready = 1;
        packet_in    = 8'h33;
        
        begin
            expected_val = model_queue[q_head];
            q_head = (q_head + 1) % DEPTH;
            model_queue[q_tail] = 8'h33;
            q_tail = (q_tail + 1) % DEPTH;
        end

        @(posedge clk);
        packet_valid = 0;
        packet_ready = 0;
        #1;

        $display("=== ALL TESTS COMPLETED SUCCESSFULLY ===");
        $finish;
    end

endmodule