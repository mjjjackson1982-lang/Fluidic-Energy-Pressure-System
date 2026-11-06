// ============================================================================
// FEPS 4-CHIP SILICON MATRIX: 7-INVERSION OUTGASSING & OCTAVE STEP CONTROLLER
// Target Clock: 476,054 Hz Resonance Carrier
// ============================================================================

module feps_silicon_matrix_controller (
    input  wire        clk_476khz,      // 476,054 Hz carrier clock signal[span_3](start_span)[span_3](end_span)
    input  wire        rst_n,           // Active low reset
    input  wire [15:0] pressure_in,     // Volumetric pressure gradient ADC input
    output reg  [3:0]  mod9_state,      // Active Mod-9 digital root state (1..9)[span_4](start_span)[span_4](end_span)
    output reg         mercy_vent_en,   // Outgassing valve trigger (Delta_vent = 0.000537)[span_5](start_span)[span_5](end_span)
    output reg  [15:0] v_rail_out       // Scaled output voltage rail
);

    // FEPS Threshold Constants
    localparam [15:0] P_SATURATION_7   = 16'h7000; // 7-inversion gate density threshold[span_6](start_span)[span_6](end_span)
    localparam [15:0] ALPHA_ELASTICITY = 16'h12A3; // 1.1650 fixed-point fluid elasticity factor[span_7](start_span)[span_7](end_span)

    always @(posedge clk_476khz or negedge rst_n) begin
        if (!rst_n) begin
            mod9_state    <= 4'd1;
            mercy_vent_en <= 1'b0;
            v_rail_out    <= 16'h1000;
        end else begin
            case (mod9_state)
                // Mod-9 doubling sequence: 1 -> 2 -> 4 -> 5 -> 7 -> 8 -> 1[span_8](start_span)[span_8](end_span)
                4'd1: mod9_state <= 4'd2;
                4'd2: mod9_state <= 4'd4;
                4'd4: mod9_state <= 4'd5;
                
                // --- 7-INVERSION GATE STATE ---
                4'd7: begin
                    if (pressure_in >= P_SATURATION_7) begin
                        // Trigger mercy vent to outgas pressure accumulation[span_9](start_span)[span_9](end_span)
                        mercy_vent_en <= 1'b1;
                        // Execute 8-Octave Jump (2^3 boundary step)[span_10](start_span)[span_10](end_span)
                        mod9_state    <= 4'd8;
                        v_rail_out    <= (v_rail_out * ALPHA_ELASTICITY) >> 12;[span_11](start_span)[span_11](end_span)
                    end else begin
                        mercy_vent_en <= 1'b0;
                    end
                end
                
                // --- 8-OCTAVE STEP-UP COMPLETED ---
                4'd8: begin
                    mercy_vent_en <= 1'b0; // Vent closes after cavity relaxation[span_12](start_span)[span_12](end_span)
                    mod9_state    <= 4'd1; // Returns to fundamental rail baseline[span_13](start_span)[span_13](end_span)
                end
                
                default: mod9_state <= 4'd1;
            endcase
        end
    end

endmodule
