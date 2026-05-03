`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_mac_tvla
// Description: Testbench TVLA (Fix cứng Vector để so sánh kiến trúc, tỷ lệ 1000:1000)
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

    // Biến đếm để đảm bảo chính xác tỷ lệ 50/50 (1000 fixed, 1000 random)
    integer count_fixed;
    integer count_random;

    reg signed [7:0] W_SECRET [0:15]; 
    reg signed [7:0] X_FIXED [0:15];  

    // KHỞI TẠO CỐ ĐỊNH TẬP DỮ LIỆU ĐỂ SO SÁNH ĐỒNG NHẤT GIỮA CÁC KIẾN TRÚC
    initial begin
        // Tập W_SECRET (Khóa bí mật)
        W_SECRET[0]  = 8'd127;   // Max positive
        W_SECRET[1]  = -8'd128;  // Max negative (Corner case)
        W_SECRET[2]  = 8'd0;     // Zero
        W_SECRET[3]  = -8'd1;    // All 1s (8'hFF)
        W_SECRET[4]  = 8'hAA;    // Alternating 10101010 (-86)
        W_SECRET[5]  = 8'h55;    // Alternating 01010101 (85)
        W_SECRET[6]  = 8'd15;
        W_SECRET[7]  = -8'd25;
        W_SECRET[8]  = 8'd64;
        W_SECRET[9]  = -8'd100;
        W_SECRET[10] = 8'd42;
        W_SECRET[11] = -8'd73;
        W_SECRET[12] = 8'd115;
        W_SECRET[13] = -8'd12;
        W_SECRET[14] = 8'd50;
        W_SECRET[15] = -8'd60;

        // Tập X_FIXED (Dữ liệu cố định)
        X_FIXED[0]  = 8'd0;      // Zero
        X_FIXED[1]  = -8'd128;   // Max negative
        X_FIXED[2]  = 8'd127;    // Max positive
        X_FIXED[3]  = 8'h55;     // 01010101 (Max switching)
        X_FIXED[4]  = 8'hAA;     // 10101010 (Max switching)
        X_FIXED[5]  = 8'd1;      // Smallest positive
        X_FIXED[6]  = -8'd1;     // Smallest negative
        X_FIXED[7]  = 8'd10;     // Normal value
        X_FIXED[8]  = -8'd20;
        X_FIXED[9]  = 8'd30;
        X_FIXED[10] = -8'd40;
        X_FIXED[11] = 8'd50;
        X_FIXED[12] = -8'd60;
        X_FIXED[13] = 8'd70;
        X_FIXED[14] = -8'd80;
        X_FIXED[15] = 8'd90;
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
        count_fixed = 0;
        count_random = 0;

        #200;
        rst_n = 1;
        #50;

        $display("--- BAT DAU MO PHONG TVLA (%0d TRACES, TI LE 1:1) ---", NUM_TRACES);

        for (i = 0; i < NUM_TRACES; i = i + 1) begin
            
            // LOGIC ĐIỀU CHỈNH CHÍNH XÁC 1000 FIXED VÀ 1000 RANDOM
            if (count_fixed == (NUM_TRACES / 2)) begin
                is_random = 1; // Đã hết quota Fixed, ép sang Random
            end else if (count_random == (NUM_TRACES / 2)) begin
                is_random = 0; // Đã hết quota Random, ép sang Fixed
            end else begin
                is_random = $urandom_range(0, 1); // Trộn ngẫu nhiên
            end

            // Cập nhật biến đếm
            if (is_random) begin
                count_random = count_random + 1;
            end else begin
                count_fixed = count_fixed + 1;
            end

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

            if (i % 200 == 0 && i > 0) begin
                $display("... Da chay %0d traces (Fixed: %0d, Random: %0d) ...", i, count_fixed, count_random);
            end
        end

        $display("--- HOAN THANH MO PHONG ---");
        $display(">> TONG KET: %0d Fixed Traces | %0d Random Traces", count_fixed, count_random);
        if (error_count == 0) begin
            $display(">> TUYET VOI! 100%% TRACES TINH TOAN CHINH XAC!");
        end else begin
            $display(">> PHAT HIEN %0d TRACES BI SAI SO!", error_count);
        end
        
        $fclose(fd_labels);
        $finish;
    end
endmodule