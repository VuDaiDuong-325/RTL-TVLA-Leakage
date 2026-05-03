`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2026 08:19:15 AM
// Design Name: 
// Module Name: mac_core_single_cycle
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


(* use_dsp = "yes" *)
module mac_core_single_cycle (
    input                       clk,
    input                       rst_n,
    input                       valid_in,
    input                       clear_acc,
    input                       last_mac_in,
    input signed        [7:0]   w_in,
    input signed        [7:0]   x_in,
    output reg signed   [31:0]  psum_out,
    output reg                  valid_out
);

    always @(posedge clk) begin
        if (!rst_n) begin
            psum_out  <= 32'd0;
            valid_out <= 1'b0;
        end else begin
            // Mặc định hạ cờ valid_out
            valid_out <= 1'b0;
            
            if (valid_in) begin
                // Thực hiện Nhân và Cộng ngay trong 1 chu kỳ clock
                if (clear_acc) begin
                    psum_out <= w_in * x_in;
                end else begin
                    psum_out <= psum_out + (w_in * x_in);
                end
                
                // Nếu đây là dữ liệu cuối, bật cờ valid_out
                if (last_mac_in) begin
                    valid_out <= 1'b1;
                end
            end
        end
    end

endmodule
