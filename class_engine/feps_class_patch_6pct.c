/*
 * ============================================================================
 * FEPS BOLTZMANN ENGINE PATCH: CLASS v3.2.0 INTEGRATION
 * Core Mechanics: 6% Relativistic Early Fluid Boost (SAMs) & Zero Shear
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

    // FEPS Parameter Anchors (Stored Angular Momentum effective fluid)
    double c_s_sq    = 1.0 / 3.0; // Fixed radiation sound speed (w = 1/3)
    double w_feps    = 1.0 / 3.0;
    double sigma_vis = 0.0;       // Zero anisotropic shear constraint

    // State Variables
    double delta_feps = y[ppw->index_pt_delta_feps];
    double theta_feps = y[ppw->index_pt_theta_feps];
    double phi        = y[ppw->index_pt_phi];
    double phi_dot    = y[ppw->index_pt_phi_dot];
    double psi        = y[ppw->index_pt_psi];
    double H          = ppw->pba_H;

    (void)phi; // Retained for metric-potential state indexing

    // 1. Continuity Equation
    dy[ppw->index_pt_delta_feps] = -(1.0 + w_feps) * (theta_feps + 3.0 * phi_dot)
                                   - 3.0 * H * (c_s_sq - w_feps) * delta_feps;

    // 2. Momentum Conservation Equation (Zero Acoustic Driver Term)
    // H * (1.0 - 3.0 * c_s_sq) * theta_feps evaluates to 0 identically
    dy[ppw->index_pt_theta_feps] = -H * (1.0 - 3.0 * c_s_sq) * theta_feps
                                   + (c_s_sq / (1.0 + w_feps)) * k * k * delta_feps
                                   + k * k * psi - k * k * sigma_vis;

    return _SUCCESS_;
}
