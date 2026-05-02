`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2026 04:56:48 PM
// Design Name: 
// Module Name: mac_controller
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

module mac_controller (
    input                       clk,
    input                       rst_n,
    input                       start,
    input       [7:0]           N,              
    input                       valid_out_core, 
    output reg                  valid_in,
    output reg                  clear_acc,
    output reg                  last_mac_in,
    output reg                  done
);

    // Định nghĩa các trạng thái FSM
    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam WAIT    = 2'b10;

    reg [1:0] state, next_state;
    reg [7:0] count;

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else        state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE:    if (start) next_state = COMPUTE;
            COMPUTE: if (count == N - 1) next_state = WAIT;
            WAIT:    if (valid_out_core) next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count       <= 8'd0;
            valid_in    <= 1'b0;
            clear_acc   <= 1'b0;
            last_mac_in <= 1'b0;
            done        <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    count <= 8'd0;
                    done  <= 1'b0;
                    if (start) begin
                        valid_in    <= 1'b1;
                        clear_acc   <= 1'b1; 
                        last_mac_in <= (N == 8'd1); 
                    end else begin
                        valid_in    <= 1'b0;
                        clear_acc   <= 1'b0;
                        last_mac_in <= 1'b0;
                    end
                end

                COMPUTE: begin
                    clear_acc <= 1'b0;
                    if (count == N - 1) begin
                        valid_in    <= 1'b0;
                        last_mac_in <= 1'b0;
                    end else begin
                        count <= count + 1'b1;
                        valid_in <= 1'b1;
                        if (count == N - 2) last_mac_in <= 1'b1;
                    end
                end

                WAIT: begin
                    valid_in    <= 1'b0;
                    last_mac_in <= 1'b0;
                    if (valid_out_core) begin
                        done <= 1'b1;
                    end
                end
            endcase
        end
    end
endmodule
