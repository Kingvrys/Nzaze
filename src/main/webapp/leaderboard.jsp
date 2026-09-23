<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.mycompany.nzaze.LeaderboardPageServlet.LeaderboardEntry" %>
<%
    if (session.getAttribute("user") == null
            || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<LeaderboardEntry> entries = (List<LeaderboardEntry>) request.getAttribute("leaderboardEntries");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leaderboard - Nzaze</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <nav class="navbar navbar-dark bg-dark mb-4">
        <div class="container">
            <a class="navbar-brand fw-bold" href="new.jsp">Nzaze Guest Tracking</a>
            <a class="btn btn-outline-light btn-sm" href="new.jsp">Back to guest tracker</a>
        </div>
    </nav>

    <main class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-1">Guest Stay Leaderboard</h1>
                <p class="text-muted mb-0">Guests ranked by their total number of recorded stays.</p>
            </div>
            <span class="badge text-bg-warning">Admin only</span>
        </div>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-dark">
                            <tr><th>Rank</th><th>Guest</th><th>Number of stays</th></tr>
                        </thead>
                        <tbody>
                            <% if (entries == null || entries.isEmpty()) { %>
                                <tr><td colspan="3" class="text-center text-muted py-4">No guest stays recorded yet.</td></tr>
                            <% } else { %>
                                <% for (LeaderboardEntry entry : entries) { %>
                                    <tr>
                                        <td class="fw-bold">#<%= entry.getRank() %></td>
                                        <td><%= entry.getName() %></td>
                                        <td class="fw-bold"><%= entry.getStays() %></td>
                                    </tr>
                                <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</body>
</html>