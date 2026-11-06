/*
 * ============================================================================
 * FEPS BOLTZMANN ENGINE PATCH: CLASS v3.2.0 INTEGRATION
 * Core Mechanics: 6% Relativistic Early Fluid Boost & Zero Shear Modulation
 * ============================================================================
 */

#include "perturbations.h"

int perturbations_feps_derivative(
    struct precision * ppr,
    struct background * pba,
    struct thermo * pth,
    struct perturbations * ppt,
    enum linear_or_logarithmic mode,
    double k,
    double tau,
    double * y,
    double * dy,
    int index_pt,
    struct perturbations_workspace * ppw
) {

    // FEPS Parameter Anchors
    double c_s_sq = 1.0 / 3.0; // Fixed radiation sound speed (w = 1/3)[span_2](start_span)[span_2](end_span)
    double w_feps = 1.0 / 3.0;
    double sigma_vis = 0.0;     // Zero anisotropic shear constraint[span_3](start_span)[span_3](end_span)

    // State Variables
    double delta_feps = y[ppw->index_pt_delta_feps];
    double theta_feps = y[ppw->index_pt_theta_feps];
    double phi        = y[ppw->index_pt_phi];
    double phi_dot    = y[ppw->index_pt_phi_dot];
    double psi        = y[ppw->index_pt_psi];
    double H          = ppw->pba_H;

    // 1. Continuity Equation
    dy[ppw->index_pt_delta_feps] = -(1.0 + w_feps) * (theta_feps + 3.0 * phi_dot) 
                                   - 3.0 * H * (c_s_sq - w_feps) * delta_feps;[span_4](start_span)[span_4](end_span)

    // 2. Momentum Conservation Equation (Zero Acoustic Driver Term)
    // H * (1.0 - 3.0 * c_s_sq) * theta_feps evaluates to 0 identically[span_5](start_span)[span_5](end_span)
    dy[ppw->index_pt_theta_feps] = -H * (1.0 - 3.0 * c_s_sq) * theta_feps 
                                   + (c_s_sq / (1.0 + w_feps)) * k * k * delta_feps 
                                   + k * k * psi - k * k * sigma_vis;[span_6](start_span)[span_6](end_span)

    return _SUCCESS_;
}
