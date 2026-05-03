`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2026 12:42:42 PM
// Design Name: 
// Module Name: mac_engine
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

module mac_engine (
    input clk,
    input rst_n,
    input start,
    input [7:0] N,
    input signed [7:0] w_in,
    input signed [7:0] x_in,
    output signed [31:0] psum_out,
    output done
);

    // ==========================================
    // 1. KHỐI ĐIỀU KHIỂN (CONTROLLER / COUNTER)
    // ==========================================
    reg [7:0] count;
    reg running;

    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 8'd0;
            running <= 1'b0;
        end else begin
            if (start) begin
                // Bắt đầu chu trình tính toán
                running <= 1'b1;
                count <= 8'd0;
            end else if (running) begin
                if (count == N - 1) begin
                    // Nếu đã đếm đến phần tử cuối cùng thì dừng
                    running <= 1'b0;
                end else begin
                    // Ngược lại thì tăng biến đếm
                    count <= count + 1'b1;
                end
            end
        end
    end

    // Tự động sinh các tín hiệu điều khiển cho Datapath
    wire ctrl_valid_in  = running;
    wire ctrl_clear_acc = (count == 8'd0); // Chỉ xóa ở phần tử đầu tiên (count = 0)
    wire ctrl_last_mac  = (count == N - 1); // Bật cờ ở phần tử cuối cùng

    // ==========================================
    // 2. KHỐI XỬ LÝ (DATAPATH - GỌI MODULE CỦA BẠN VÀO)
    // ==========================================
    mac_core_single_cycle u_mac_core (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(ctrl_valid_in),
        .clear_acc(ctrl_clear_acc),
        .last_mac_in(ctrl_last_mac),
        .w_in(w_in),
        .x_in(x_in),
        .psum_out(psum_out),
        .valid_out(done) // valid_out của core chính là tín hiệu done của engine
    );

endmodule
