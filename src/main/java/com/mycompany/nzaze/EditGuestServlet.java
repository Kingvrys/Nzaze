package com.mycompany.nzaze;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.Calendar;
import java.util.TimeZone;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/EditGuestServlet")
public class EditGuestServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/nzaze_db";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request.getSession(false))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String guestId = request.getParameter("guestId");
        String sql = "SELECT guest_id, first_name, last_name, email, phone_number, room_number, "
                + "guest_code, check_in_date, check_out_date, status, rating, host_comments "
                + "FROM guests WHERE guest_id = ?";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setInt(1, Integer.parseInt(guestId));
                try (ResultSet resultSet = statement.executeQuery()) {
                    if (!resultSet.next()) {
                        response.sendRedirect("new.jsp?error=guest-not-found");
                        return;
                    }
                    request.setAttribute("guestId", resultSet.getInt("guest_id"));
                    request.setAttribute("firstName", resultSet.getString("first_name"));
                    request.setAttribute("lastName", resultSet.getString("last_name"));
                    request.setAttribute("email", resultSet.getString("email"));
                    request.setAttribute("phone", resultSet.getString("phone_number"));
                    request.setAttribute("roomNumber", resultSet.getString("room_number"));
                    request.setAttribute("guestCode", resultSet.getString("guest_code"));
                    request.setAttribute("checkInDate", resultSet.getTimestamp("check_in_date"));
                    request.setAttribute("checkOutDate", resultSet.getTimestamp("check_out_date", utcCalendar()));
                    request.setAttribute("status", resultSet.getString("status"));
                    request.setAttribute("rating", resultSet.getInt("rating"));
                    request.setAttribute("comments", resultSet.getString("host_comments"));
                    request.getRequestDispatcher("edit_guest.jsp").forward(request, response);
                }
            }
        } catch (ClassNotFoundException | SQLException | NumberFormatException exception) {
            response.sendRedirect("new.jsp?error=guest-load");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request.getSession(false))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sql = "UPDATE guests SET first_name = ?, last_name = ?, email = ?, phone_number = ?, "
                + "room_number = ?, check_in_date = ?, check_out_date = ?, status = ?, rating = ?, "
                + "host_comments = ? WHERE guest_id = ?";
        try {
            int guestId = Integer.parseInt(request.getParameter("guestId"));
            LocalDate checkoutDate = LocalDate.parse(request.getParameter("checkOutDate").substring(0, 10));
            Timestamp checkoutExpiry = Timestamp.from(checkoutDate.atTime(12, 0).toInstant(ZoneOffset.UTC));
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setString(1, request.getParameter("firstName"));
                statement.setString(2, request.getParameter("lastName"));
                statement.setString(3, request.getParameter("email"));
                statement.setString(4, request.getParameter("phone"));
                statement.setString(5, request.getParameter("roomNumber"));
                statement.setString(6, request.getParameter("checkInDate"));
                statement.setTimestamp(7, checkoutExpiry, utcCalendar());
                statement.setString(8, request.getParameter("status"));
                statement.setInt(9, Integer.parseInt(request.getParameter("rating")));
                statement.setString(10, request.getParameter("comments"));
                statement.setInt(11, guestId);
                statement.executeUpdate();
            }
            response.sendRedirect("new.jsp?updated=1");
        } catch (ClassNotFoundException | SQLException | NumberFormatException exception) {
            response.sendRedirect("new.jsp?error=guest-update");
        }
    }

    private boolean isAdmin(HttpSession session) {
        return session != null && "ADMIN".equalsIgnoreCase((String) session.getAttribute("role"));
    }

    private Calendar utcCalendar() {
        return Calendar.getInstance(TimeZone.getTimeZone("UTC"));
    }
}
