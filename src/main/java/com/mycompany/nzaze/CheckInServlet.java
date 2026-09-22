package com.mycompany.nzaze;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/CheckInServlet")
public class CheckInServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/nzaze_db";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (!isAdmin(request.getSession(false))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().print("{\"success\":false,\"message\":\"Administrator access required.\"}");
            return;
        }

        String sql = "INSERT INTO guest_stays (guest_id, check_in_date, check_out_date) "
                + "SELECT guest_id, UTC_TIMESTAMP(), check_out_date FROM guests "
                + "WHERE guest_id = ? AND status = 'ACTIVE' AND check_out_date > UTC_TIMESTAMP()";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setInt(1, Integer.parseInt(request.getParameter("guestId")));
                int updated = statement.executeUpdate();
                response.getWriter().print(updated == 1
                        ? "{\"success\":true,\"message\":\"Check-in recorded.\"}"
                        : "{\"success\":false,\"message\":\"Guest is inactive or expired.\"}");
            }
        } catch (ClassNotFoundException | SQLException | NumberFormatException exception) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"success\":false,\"message\":\"Could not record check-in.\"}");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String searchTerm = request.getParameter("q");
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            response.getWriter().print("{\"success\":false,\"message\":\"Enter a guest name, email, phone, room, or access code.\"}");
            return;
        }

        String searchPattern = "%" + searchTerm.trim() + "%";
        String sql = "SELECT guest_id, first_name, last_name, email, phone_number, room_number, guest_code, status "
            + "FROM guests WHERE status = 'ACTIVE' AND check_out_date > UTC_TIMESTAMP() "
            + "AND (first_name LIKE ? OR last_name LIKE ? OR email LIKE ? OR phone_number LIKE ? "
            + "OR room_number LIKE ? OR guest_code LIKE ?) "
            + "ORDER BY first_name, last_name LIMIT 10";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement statement = connection.prepareStatement(sql)) {
                for (int index = 1; index <= 6; index++) {
                    statement.setString(index, searchPattern);
                }
                try (ResultSet resultSet = statement.executeQuery()) {
                    StringBuilder json = new StringBuilder("{\"success\":true,\"results\":[");
                    boolean hasResults = false;
                    while (resultSet.next()) {
                        if (hasResults) {
                            json.append(',');
                        }
                        hasResults = true;
                        json.append("{\"guestId\":").append(resultSet.getInt("guest_id"))
                            .append(",\"firstName\":\"").append(jsonValue(resultSet.getString("first_name")))
                            .append("\",\"lastName\":\"").append(jsonValue(resultSet.getString("last_name")))
                            .append("\",\"email\":\"").append(jsonValue(resultSet.getString("email")))
                            .append("\",\"phoneNumber\":\"").append(jsonValue(resultSet.getString("phone_number")))
                            .append("\",\"roomNumber\":\"").append(jsonValue(resultSet.getString("room_number")))
                            .append("\",\"guestCode\":\"").append(jsonValue(resultSet.getString("guest_code")))
                            .append("\",\"status\":\"").append(jsonValue(resultSet.getString("status"))).append("\"}");
                    }
                    json.append(']');
                    if (!hasResults) {
                        json.append(",\"message\":\"No active guest matched that search.\"");
                    }
                    json.append('}');
                    response.getWriter().print(json);
                }
            }
        } catch (ClassNotFoundException | SQLException exception) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"success\":false,\"message\":\"Database lookup failed.\"}");
        }
    }

    private String jsonValue(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }

    private boolean isAdmin(javax.servlet.http.HttpSession session) {
        return session != null && "ADMIN".equalsIgnoreCase((String) session.getAttribute("role"));
    }
}
