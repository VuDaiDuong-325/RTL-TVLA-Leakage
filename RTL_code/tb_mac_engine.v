`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2026 05:15:17 PM
// Design Name: 
// Module Name: tb_mac_tvla
// Project Name: TVLA_MAC_Engine
// Target Devices: 
// Tool Versions: 
// Description: Testbench thu thập dữ liệu cho phân tích TVLA (Post-Implementation)
//////////////////////////////////////////////////////////////////////////////////

module tb_mac_tvla();
    parameter NUM_TRACES = 2000; 
    
    reg clk;
    reg rst_n;
    reg start;
    reg [7:0] N;
    reg signed [7:0] w_in;
    reg signed [7:0] x_in;
    wire signed [31:0] psum_out;
    wire done;

    mac_engine u_mac (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .N(N),
        .w_in(w_in),
        .x_in(x_in),
        .psum_out(psum_out),
        .done(done)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    integer i, j;
    integer fd_labels;     
    reg is_random;        
    
    integer expected_psum; 
    integer error_count;   
    integer temp_w, temp_x;

    reg signed [7:0] W_SECRET [0:15]; 
    reg signed [7:0] X_FIXED [0:15];  

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            W_SECRET[i] = $random; 
            X_FIXED[i]  = $random; 
        end
    end

    initial begin
        fd_labels = $fopen("tvla_labels.txt", "w");
        $dumpfile("mac_activity.vcd"); 
        $dumpvars(0, tb_mac_tvla.u_mac); 

        rst_n = 0;
        start = 0;
        N = 16; 
        w_in = 0;
        x_in = 0;

        error_count = 0; 
        #200;
        rst_n = 1;
        #50;

        $display("--- BAT DAU CHAY MO PHONG TVLA CHO %0d TRACES ---", NUM_TRACES);

        for (i = 0; i < NUM_TRACES; i = i + 1) begin
            is_random = $urandom_range(0, 1);
            $fdisplay(fd_labels, "%d", is_random); 
            @(negedge clk);
            start = 1;
            expected_psum = 0;
            @(negedge clk);
            start = 0; 

            for (j = 0; j < N; j = j + 1) begin
                w_in = W_SECRET[j]; 
                if (is_random) begin
                    x_in = $random;
                end else begin
                    x_in = X_FIXED[j]; 
                end
                temp_w = $signed(w_in);
                temp_x = $signed(x_in);
                expected_psum = expected_psum + (temp_w * temp_x);
                
                @(negedge clk); 
            end
            wait(done == 1'b1);
            @(negedge clk); 
            
            if ($signed(psum_out) !== expected_psum) begin
                $display("[LOI] Trace %0d: Ky vong = %0d | Thuc te = %0d", i, expected_psum, $signed(psum_out));
                error_count = error_count + 1;
            end else if (i < 5) begin 
                $display("[OK] Trace %0d: Ket qua dung = %0d", i, expected_psum);
            end
            repeat(5) @(posedge clk); 

            if (i % 100 == 0 && i > 0) begin
                $display("... Da chay xong %0d/%0d traces ...", i, NUM_TRACES);
            end
        end

        $display("--- HOAN THANH MO PHONG ---");
        if (error_count == 0) begin
            $display(">> TUYET VOI! 100%% TRACES TINH TOAN CHINH XAC!");
        end else begin
            $display(">> PHAT HIEN %0d TRACES BI SAI SO!", error_count);
        end
        
        $fclose(fd_labels);
        $finish;
    end

endmodule