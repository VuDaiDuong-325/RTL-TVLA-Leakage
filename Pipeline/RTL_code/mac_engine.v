`timescale 1ns / 1ps

module mac_engine (
    input                       clk,
    input                       rst_n,
    input                       start,
    input       [7:0]           N,         
    input signed [7:0]          w_in,
    input signed [7:0]          x_in,
    output signed [31:0]        psum_out,
    output                      done
);
    wire wire_valid_in;
    wire wire_clear_acc;
    wire wire_last_mac_in;
    wire wire_valid_out_core;

    mac_controller u_controller (
        .clk            (clk),
        .rst_n          (rst_n),
        .start          (start),
        .N              (N),
        .valid_out_core (wire_valid_out_core),
        .valid_in       (wire_valid_in),
        .clear_acc      (wire_clear_acc),
        .last_mac_in    (wire_last_mac_in),
        .done           (done)
    );

    mac_core u_core (
        .clk            (clk),
        .rst_n          (rst_n),
        .valid_in       (wire_valid_in),
        .clear_acc      (wire_clear_acc),
        .last_mac_in    (wire_last_mac_in),
        .w_in           (w_in),
        .x_in           (x_in),
        .psum_out       (psum_out),
        .valid_out      (wire_valid_out_core)
    );

endmodule