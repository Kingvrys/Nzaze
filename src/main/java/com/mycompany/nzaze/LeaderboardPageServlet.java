package com.mycompany.nzaze;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LeaderboardPageServlet")
public class LeaderboardPageServlet extends HttpServlet {

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

        String sql = "SELECT g.first_name, g.last_name, COUNT(s.stay_id) AS stay_count "
                + "FROM guest_stays s JOIN guests g ON g.guest_id = s.guest_id "
                + "GROUP BY g.guest_id, g.first_name, g.last_name "
                + "ORDER BY stay_count DESC, g.last_name, g.first_name";
        List<LeaderboardEntry> entries = new ArrayList<>();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement statement = connection.prepareStatement(sql);
                 ResultSet results = statement.executeQuery()) {
                int rank = 0;
                while (results.next()) {
                    entries.add(new LeaderboardEntry(++rank,
                            results.getString("first_name") + " " + results.getString("last_name"),
                            results.getInt("stay_count")));
                }
            }
            request.setAttribute("leaderboardEntries", entries);
            request.getRequestDispatcher("leaderboard.jsp").forward(request, response);
        } catch (ClassNotFoundException | SQLException exception) {
            response.sendRedirect("new.jsp?error=leaderboard-load");
        }
    }

    public static class LeaderboardEntry {
        private final int rank;
        private final String name;
        private final int stays;

        public LeaderboardEntry(int rank, String name, int stays) {
            this.rank = rank;
            this.name = name;
            this.stays = stays;
        }

        public int getRank() { return rank; }
        public String getName() { return name; }
        public int getStays() { return stays; }
    }
}