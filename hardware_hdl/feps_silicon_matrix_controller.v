// ============================================================================
// FEPS 4-CHIP SILICON MATRIX: 7-INVERSION OUTGASSING & OCTAVE STEP CONTROLLER
// Target Clock: 476,054 Hz Resonance Carrier
// ============================================================================

module feps_silicon_matrix_controller (
    input  wire        clk_476khz,      // 476,054 Hz carrier clock signal
    input  wire        rst_n,           // Active low reset
    input  wire [15:0] pressure_in,     // Volumetric pressure gradient ADC input
    output reg  [3:0]  mod9_state,      // Active Mod-9 digital root state (1..8)
    output reg         mercy_vent_en,   // Outgassing valve trigger (Delta_vent = 0.000537)
    output reg  [15:0] v_rail_out       // Scaled output voltage rail
);

    // FEPS Threshold Constants
    // 0.875 (7/8) saturation threshold of 16-bit full-scale ADC (0.875 * 65536 = 57344 = 16'hE000)
    localparam [15:0] P_SATURATION_7   = 16'hE000; // 7-inversion gate density threshold (0.875 saturation)
    localparam [15:0] ALPHA_ELASTICITY = 16'h12A3; // 1.1650 fixed-point fluid elasticity factor (Q4.12)

    // Wide intermediate product to prevent 16-bit overflow before Q4.12 shift
    wire [31:0] v_rail_scaled = v_rail_out * ALPHA_ELASTICITY;

    always @(posedge clk_476khz or negedge rst_n) begin
        if (!rst_n) begin
            mod9_state    <= 4'd1;
            mercy_vent_en <= 1'b0;
            v_rail_out    <= 16'h1000;
        end else begin
            case (mod9_state)
                // Mod-9 doubling sequence: 1 -> 2 -> 4 -> 5 -> 7 -> 8 -> 1
                4'd1: mod9_state <= 4'd2;
                4'd2: mod9_state <= 4'd4;
                4'd4: mod9_state <= 4'd5;
                4'd5: mod9_state <= 4'd7;
                
                // --- 7-INVERSION GATE STATE ---
                4'd7: begin
                    if (pressure_in >= P_SATURATION_7) begin
                        // Trigger mercy vent to outgas pressure accumulation
                        mercy_vent_en <= 1'b1;
                        // Execute 8-Octave Jump (2^3 boundary step)
                        mod9_state    <= 4'd8;
                        v_rail_out    <= v_rail_scaled[27:12];
                    end else begin
                        mercy_vent_en <= 1'b0;
                    end
                end
                
                // --- 8-OCTAVE STEP-UP COMPLETED ---
                4'd8: begin
                    mercy_vent_en <= 1'b0; // Vent closes after cavity relaxation
                    mod9_state    <= 4'd1; // Returns to fundamental rail baseline
                end
                
                default: mod9_state <= 4'd1;
            endcase
        end
    end

endmodule

                
         
