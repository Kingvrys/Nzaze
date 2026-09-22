<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Timestamp, java.time.LocalDateTime, java.time.ZoneOffset" %>
<%
    if (session.getAttribute("role") == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    Timestamp checkInDate = (Timestamp) request.getAttribute("checkInDate");
    Timestamp checkOutDate = (Timestamp) request.getAttribute("checkOutDate");
    String checkInValue = checkInDate.toLocalDateTime().toString().substring(0, 16);
    String checkOutValue = checkOutDate.toInstant().atZone(ZoneOffset.UTC).toLocalDateTime().toString().substring(0, 16);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Guest - Nzaze</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <main class="container py-5">
        <div class="card shadow-sm mx-auto" style="max-width: 680px;">
            <div class="card-body p-4">
                <h1 class="h4 mb-4">Edit Guest</h1>
                <p class="text-muted">Access code: <code><%= request.getAttribute("guestCode") %></code></p>
                <form action="EditGuestServlet" method="POST">
                    <input type="hidden" name="guestId" value="<%= request.getAttribute("guestId") %>">
                    <div class="row g-3">
                        <div class="col-md-6"><label class="form-label">First Name</label><input name="firstName" class="form-control" required value="<%= request.getAttribute("firstName") %>"></div>
                        <div class="col-md-6"><label class="form-label">Last Name</label><input name="lastName" class="form-control" required value="<%= request.getAttribute("lastName") %>"></div>
                        <div class="col-md-6"><label class="form-label">Email</label><input type="email" name="email" class="form-control" value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>"></div>
                        <div class="col-md-6"><label class="form-label">Phone</label><input name="phone" class="form-control" required value="<%= request.getAttribute("phone") %>"></div>
                        <div class="col-md-6"><label class="form-label">Room Number</label><input name="roomNumber" class="form-control" value="<%= request.getAttribute("roomNumber") != null ? request.getAttribute("roomNumber") : "" %>"></div>
                        <div class="col-md-6"><label class="form-label">Status</label><select name="status" class="form-select"><option <%= "ACTIVE".equalsIgnoreCase((String) request.getAttribute("status")) ? "selected" : "" %>>ACTIVE</option><option <%= "INACTIVE".equalsIgnoreCase((String) request.getAttribute("status")) ? "selected" : "" %>>INACTIVE</option></select></div>
                        <div class="col-md-6"><label class="form-label">Check-In</label><input type="datetime-local" name="checkInDate" class="form-control" required value="<%= checkInValue %>"></div>
                        <div class="col-md-6"><label class="form-label">Check-Out (expires 12:00 UTC)</label><input type="datetime-local" name="checkOutDate" class="form-control" required value="<%= checkOutValue %>"></div>
                        <div class="col-md-3"><label class="form-label">Rating</label><input type="number" min="0" max="5" name="rating" class="form-control" required value="<%= request.getAttribute("rating") %>"></div>
                        <div class="col-12"><label class="form-label">Host Comments</label><textarea name="comments" class="form-control" rows="3"><%= request.getAttribute("comments") != null ? request.getAttribute("comments") : "" %></textarea></div>
                    </div>
                    <div class="d-flex gap-2 mt-4"><a href="new.jsp" class="btn btn-secondary">Cancel</a><button type="submit" class="btn btn-primary">Save Changes</button></div>
                </form>
            </div>
        </div>
    </main>
</body>
</html>
