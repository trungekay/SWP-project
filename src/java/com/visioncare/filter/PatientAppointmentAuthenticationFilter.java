package com.visioncare.filter;

import jakarta.servlet.annotation.WebFilter;

/** Apply the existing authentication checks to patient and appointment routes. */
@WebFilter(urlPatterns = {"/patient/*", "/appointment/*"})
public class PatientAppointmentAuthenticationFilter extends AuthenticationFilter {
}
