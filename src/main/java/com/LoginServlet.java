package com.mycompany.nzaze;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.TimeZone;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/nzaze_db";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String usernameInput = request.getParameter("username");
        String passwordInput = request.getParameter("password");

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            // Fetch user authentication details and guest info from database
            String sql = "SELECT u.user_id, u.username, u.role, g.first_name, "
                       + "g.room_number, g.guest_code AS access_code, g.check_out_date "
                       + "FROM users u "
                       + "LEFT JOIN guests g ON u.user_id = g.user_id "
                       + "WHERE u.username = ? AND u.password_hash = ? "
                       + "AND (u.role <> 'GUEST' OR (g.status = 'ACTIVE' "
                       + "AND g.check_out_date > UTC_TIMESTAMP()))";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, usernameInput != null ? usernameInput.trim() : "");
            stmt.setString(2, passwordInput != null ? passwordInput.trim() : "");

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                int userId = rs.getInt("user_id");
                String role = rs.getString("role");
                String firstName = rs.getString("first_name");
                String roomNumber = rs.getString("room_number");
                String accessCode = rs.getString("access_code");
                Timestamp checkOutDate = rs.getTimestamp("check_out_date", utcCalendar());

                // Establish session attributes
                HttpSession session = request.getSession();
                session.setAttribute("user_id", userId);
                session.setAttribute("username", usernameInput);
                session.setAttribute("role", role);
                session.setAttribute("firstName", firstName != null ? firstName : "Admin");
                session.setAttribute("roomNumber", roomNumber);
                session.setAttribute("accessCode", accessCode);
                session.setAttribute("checkOutDate", checkOutDate);

                if ("GUEST".equalsIgnoreCase(role)) {
                    response.sendRedirect("guest_dashboard.jsp");
                } else {
                    session.setAttribute("user", usernameInput);
                    response.sendRedirect("new.jsp");
                }

            } else {
                response.sendRedirect("login.jsp?error=invalid");
            }

        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=db");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    private Calendar utcCalendar() {
        return Calendar.getInstance(TimeZone.getTimeZone("UTC"));
    }
}