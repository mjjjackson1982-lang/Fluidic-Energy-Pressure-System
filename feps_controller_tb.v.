`timescale 1ns / 1ps

module feps_controller_tb;

    reg         clk_476khz;
    reg         rst_n;
    reg  [15:0] pressure_in;
    wire [3:0]  mod9_state;
    wire        mercy_vent_en;
    wire [15:0] v_rail_out;

    // Instantiate FEPS Silicon Matrix Controller
    feps_silicon_matrix_controller uut (
        .clk_476khz    (clk_476khz),
        .rst_n         (rst_n),
        .pressure_in   (pressure_in),
        .mod9_state    (mod9_state),
        .mercy_vent_en (mercy_vent_en),
        .v_rail_out    (v_rail_out)
    );

    // 476,054 Hz clock (~2100.6 ns period -> 1050 ns half-period)
    initial clk_476khz = 0;
    always #1050 clk_476khz = ~clk_476khz;

    initial begin
        $display("Time(ns) | State | Pressure | MercyVent | V_Rail");
        $monitor("%8t |   %d   |  0x%h  |     %b     | 0x%h",
                 $time, mod9_state, pressure_in, mercy_vent_en, v_rail_out);

        // Initialize and release reset
        rst_n = 0;
        pressure_in = 16'h4000; // Below 0.875 threshold
        #3000;
        rst_n = 1;

        // Wait one full cycle below threshold (holds at state 7)
        #12000;

        // Apply >= 0.875 saturation pressure (0xE500 > 0xE000) to trigger outgassing
        pressure_in = 16'hE500;
        #8000;

        $finish;
    end

endmodule
