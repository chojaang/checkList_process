package com.checklist.servlet;

import com.checklist.repository.FileJsonRepository;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet(urlPatterns = {"/archive"})
public class ArchiveServlet extends HttpServlet {
    private final FileJsonRepository repository = new FileJsonRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int currentYear = LocalDate.now().getYear();
        int year = currentYear;
        String yearParam = req.getParameter("year");
        if (yearParam != null && !yearParam.isBlank()) {
            try {
                year = Integer.parseInt(yearParam);
            } catch (NumberFormatException ignored) {
                year = currentYear;
            }
        }

        req.setAttribute("selectedYear", year);
        req.setAttribute("results", repository.findResultsByYear(getServletContext(), year));
        req.getRequestDispatcher("/archive.jsp").forward(req, resp);
    }
}
