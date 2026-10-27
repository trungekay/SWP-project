package com.visioncare.controller;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 
 */
@WebServlet(name = "AdminClinicConfigServlet", urlPatterns = {"/admin/clinic-config"})
public class AdminClinicConfigServlet extends HttpServlet {
    private final com.visioncare.dao.RoomDAO roomDAO = new com.visioncare.dao.RoomDAO();
    private final com.visioncare.dao.TimeSlotDAO timeSlotDAO = new com.visioncare.dao.TimeSlotDAO();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("rooms", roomDAO.getAll());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("rooms", java.util.Collections.emptyList());
        }

        try {
            request.setAttribute("timeSlots", timeSlotDAO.getConfiguredSlots());
            request.setAttribute("minWorkHours", timeSlotDAO.getMinWeeklyWorkingHours());
            request.setAttribute("maxWeeklyHours", timeSlotDAO.getMaxWeeklyAvailableHours());
            request.setAttribute("pendingHoldMinutes", timeSlotDAO.getPendingHoldMinutes());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("timeSlots", java.util.Collections.emptyList());
        }

        try {
            com.visioncare.dao.DoctorDAO doctorDAO = new com.visioncare.dao.DoctorDAO();
            request.setAttribute("doctors", doctorDAO.getAll());
            request.setAttribute("specialists", doctorDAO.getSpecialists());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("doctors", java.util.Collections.emptyList());
            request.setAttribute("specialists", java.util.Collections.emptyList());
        }

        try {
            com.visioncare.dao.ClinicGalleryDAO galleryDAO = new com.visioncare.dao.ClinicGalleryDAO();
            request.setAttribute("galleryItems", galleryDAO.getAll());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("galleryItems", java.util.Collections.emptyList());
        }

        try {
            com.visioncare.dao.ClinicBannerDAO bannerDAO = new com.visioncare.dao.ClinicBannerDAO();
            request.setAttribute("clinicBanners", bannerDAO.getAll());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("clinicBanners", java.util.Collections.emptyList());
        }

        try {
            com.visioncare.dao.CatalogDAO catalogDAO = new com.visioncare.dao.CatalogDAO();
            request.setAttribute("catalogServices", catalogDAO.listServices());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("catalogServices", java.util.Collections.emptyList());
        }

        request.getRequestDispatcher("/views/admin/clinic-config.jsp").forward(request, response);
    }
}
