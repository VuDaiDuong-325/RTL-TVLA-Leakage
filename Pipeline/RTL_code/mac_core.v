`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2026 02:18:05 PM
// Design Name: 
// Module Name: mac_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: MAC Core Optimized for DSP48E2 Inference
//////////////////////////////////////////////////////////////////////////////////

(* use_dsp = "yes" *)
module mac_core(
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
    reg signed [7:0]  a_reg, b_reg;
    reg signed [15:0] m_reg;
    reg signed [31:0] p_reg;

    reg v_reg1, v_reg2, v_reg3;
    reg l_reg1, l_reg2, l_reg3;
    reg c_reg1, c_reg2, c_reg3;

    always @(posedge clk) begin
        if (!rst_n) begin
            psum_out  <= 32'd0;
            valid_out <= 1'b0;
            v_reg1 <= 0; v_reg2 <= 0; v_reg3 <= 0;
            l_reg1 <= 0; l_reg2 <= 0; l_reg3 <= 0;
            c_reg1 <= 0; c_reg2 <= 0; c_reg3 <= 0;
        end else begin
            v_reg1 <= valid_in;
            l_reg1 <= last_mac_in;
            c_reg1 <= clear_acc;
            
            if (valid_in) begin
                a_reg <= w_in;
                b_reg <= x_in;
            end
            v_reg2 <= v_reg1;
            l_reg2 <= l_reg1;
            c_reg2 <= c_reg1;
            
            if (v_reg1) begin
                m_reg <= a_reg * b_reg;
            end
            v_reg3 <= v_reg2;
            l_reg3 <= l_reg2;
            
            if (v_reg2) begin
                if (c_reg2) 
                    p_reg <= m_reg; 
                else 
                    p_reg <= p_reg + m_reg; 
            end
            valid_out <= 1'b0;
            if (v_reg3 && l_reg3) begin
                psum_out <= p_reg;
                valid_out <= 1'b1;
            end
        end
    end
endmodule