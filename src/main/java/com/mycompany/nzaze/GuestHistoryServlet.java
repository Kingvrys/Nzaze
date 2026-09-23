package com.mycompany.nzaze;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/GuestHistoryServlet")
public class GuestHistoryServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/nzaze_db";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String guestId = request.getParameter("guestId");
        String guestSql = "SELECT g.guest_id, g.first_name, g.last_name, g.email, g.phone_number, "
            + "g.room_number, g.guest_code, u.username, u.password_hash "
            + "FROM guests g LEFT JOIN users u ON u.user_id = g.user_id WHERE g.guest_id = ?";
        String historySql = "SELECT stay_id, check_in_date, check_out_date FROM guest_stays "
                + "WHERE guest_id = ? ORDER BY check_in_date DESC";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement guestStatement = connection.prepareStatement(guestSql);
                 PreparedStatement historyStatement = connection.prepareStatement(historySql)) {
                int id = Integer.parseInt(guestId);
                guestStatement.setInt(1, id);
                try (ResultSet guest = guestStatement.executeQuery()) {
                    if (!guest.next()) {
                        response.sendRedirect("new.jsp?error=guest-not-found");
                        return;
                    }
                    request.setAttribute("guestId", guest.getInt("guest_id"));
                    request.setAttribute("firstName", guest.getString("first_name"));
                    request.setAttribute("lastName", guest.getString("last_name"));
                    request.setAttribute("email", guest.getString("email"));
                    request.setAttribute("phone", guest.getString("phone_number"));
                    request.setAttribute("roomNumber", guest.getString("room_number"));
                    request.setAttribute("guestCode", guest.getString("guest_code"));
                    request.setAttribute("guestUsername", guest.getString("username"));
                    request.setAttribute("guestPassword", guest.getString("password_hash"));
                }

                historyStatement.setInt(1, id);
                List<Stay> history = new ArrayList<>();
                try (ResultSet stays = historyStatement.executeQuery()) {
                    while (stays.next()) {
                        history.add(new Stay(stays.getInt("stay_id"),
                                stays.getTimestamp("check_in_date", utcCalendar()),
                                stays.getTimestamp("check_out_date", utcCalendar())));
                    }
                }
                request.setAttribute("history", history);
                request.getRequestDispatcher("guest_history.jsp").forward(request, response);
            }
        } catch (ClassNotFoundException | SQLException | NumberFormatException exception) {
            response.sendRedirect("new.jsp?error=history-load");
        }
    }

    public static class Stay {
        private final int id;
        private final Timestamp checkIn;
        private final Timestamp checkOut;

        public Stay(int id, Timestamp checkIn, Timestamp checkOut) {
            this.id = id;
            this.checkIn = checkIn;
            this.checkOut = checkOut;
        }

        public int getId() { return id; }
        public Timestamp getCheckIn() { return checkIn; }
        public Timestamp getCheckOut() { return checkOut; }
    }

    private Calendar utcCalendar() {
        return Calendar.getInstance(TimeZone.getTimeZone("UTC"));
    }
}
