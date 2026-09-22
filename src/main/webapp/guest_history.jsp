<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.mycompany.nzaze.GuestHistoryServlet.Stay" %>
<%
    if (session.getAttribute("role") == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Stay> history = (List<Stay>) request.getAttribute("history");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest History - Nzaze</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <main class="container py-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <p class="text-muted mb-1">Admin only</p>
                <h1 class="h3 mb-1"><%= request.getAttribute("firstName") %> <%= request.getAttribute("lastName") %></h1>
                <p class="mb-0">Guest ID: <strong>#<%= request.getAttribute("guestId") %></strong> | Access code: <code><%= request.getAttribute("guestCode") %></code></p>
            </div>
            <a href="new.jsp" class="btn btn-secondary">Back to dashboard</a>
        </div>
        <div class="row g-3 mb-4">
            <div class="col-md-3"><div class="card shadow-sm"><div class="card-body"><small class="text-muted">Total stays</small><div class="display-6"><%= history.size() %></div></div></div></div>
            <div class="col-md-3"><div class="card shadow-sm"><div class="card-body"><small class="text-muted">Room</small><div class="h4"><%= request.getAttribute("roomNumber") != null ? request.getAttribute("roomNumber") : "Not assigned" %></div></div></div></div>
            <div class="col-md-6"><div class="card shadow-sm"><div class="card-body"><small class="text-muted">Contact</small><div><%= request.getAttribute("email") != null ? request.getAttribute("email") : "No email" %> | <%= request.getAttribute("phone") %></div></div></div></div>
        </div>
        <div class="card shadow-sm">
            <div class="card-header fw-bold">Stay history</div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead><tr><th>Stay</th><th>Check-in</th><th>Check-out</th></tr></thead>
                        <tbody>
                        <% if (history.isEmpty()) { %>
                            <tr><td colspan="3" class="text-center text-muted py-4">No check-in history recorded yet.</td></tr>
                        <% } else { for (Stay stay : history) { %>
                            <tr><td>#<%= stay.getId() %></td><td><%= stay.getCheckIn() %> UTC</td><td><%= stay.getCheckOut() %> UTC</td></tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
