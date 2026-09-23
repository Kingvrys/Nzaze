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
import javax.servlet.http.HttpSession;

@WebServlet("/LeaderboardServlet")
public class LeaderboardServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/nzaze_db";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType("application/json");
            response.getWriter().print("{\"success\":false,\"message\":\"Administrator access required.\"}");
            return;
        }

        String sql = "SELECT g.first_name, g.last_name, COUNT(s.stay_id) AS stay_count "
                + "FROM guest_stays s JOIN guests g ON g.guest_id = s.guest_id "
                + "GROUP BY g.guest_id, g.first_name, g.last_name "
                + "ORDER BY stay_count DESC, g.last_name, g.first_name";
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement statement = connection.prepareStatement(sql);
                 ResultSet results = statement.executeQuery()) {
                StringBuilder json = new StringBuilder("{\"success\":true,\"entries\":[");
                boolean hasEntries = false;
                int rank = 0;
                while (results.next()) {
                    if (hasEntries) {
                        json.append(',');
                    }
                    hasEntries = true;
                    rank++;
                    json.append("{\"rank\":").append(rank)
                            .append(",\"name\":\"")
                            .append(jsonValue(results.getString("first_name") + " " + results.getString("last_name")))
                            .append("\",\"stays\":").append(results.getInt("stay_count"))
                            .append('}');
                }
                json.append("]}");
                response.getWriter().print(json);
            }
        } catch (ClassNotFoundException | SQLException exception) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"success\":false,\"message\":\"Could not load the leaderboard.\"}");
        }
    }

    private String jsonValue(String value) {
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}