<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Timestamp, java.time.Instant" %>
<%
    // Session Guard: Redirect to login if user is not authenticated or not a GUEST
    String role = (String) session.getAttribute("role");
    if (session == null || role == null || !"GUEST".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    Timestamp checkOutDate = (Timestamp) session.getAttribute("checkOutDate");
    if (checkOutDate != null && !Instant.now().isBefore(checkOutDate.toInstant())) {
        session.invalidate();
        response.sendRedirect("login.jsp?error=expired");
        return;
    }

    String firstName = (String) session.getAttribute("firstName");
    String roomNumber = (String) session.getAttribute("roomNumber");
    String accessCode = (String) session.getAttribute("accessCode");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest Portal - Nzaze</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        body {
            background-color: #f4f6f9;
            color: #333;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        header {
            background-color: #1a252f;
            color: #ffffff;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        header h1 {
            font-size: 1.5rem;
            font-weight: 600;
        }
        .user-greeting {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .logout-btn {
            background-color: #e74c3c;
            color: white;
            text-decoration: none;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            font-size: 0.9rem;
            transition: background 0.3rem;
        }
        .logout-btn:hover {
            background-color: #c0392b;
        }
        .container {
            max-width: 900px;
            margin: 2rem auto;
            padding: 0 1rem;
            width: 100%;
        }
        .welcome-card {
            background: #ffffff;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        .welcome-card h2 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-bottom: 1.5rem;
        }
        .card {
            background: #ffffff;
            padding: 1.5rem;
            border-radius: 8px;
            border-left: 5px solid #3498db;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        .card-title {
            font-size: 0.85rem;
            text-transform: uppercase;
            color: #7f8c8d;
            letter-spacing: 1px;
            margin-bottom: 0.5rem;
        }
        .card-value {
            font-size: 2rem;
            font-weight: bold;
            color: #2c3e50;
        }
        .access-card {
            border-left-color: #2ecc71;
        }
        .access-code-value {
            font-family: 'Courier New', Courier, monospace;
            letter-spacing: 3px;
            color: #27ae60;
        }
        .action-card {
            background: #ffffff;
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            margin-bottom: 1.5rem;
        }
        .action-card h3 {
            margin-bottom: 1rem;
            color: #2c3e50;
        }
        .btn {
            display: inline-block;
            padding: 0.75rem 1.5rem;
            background-color: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-weight: 600;
            margin-right: 0.5rem;
        }
        .btn:hover {
            background-color: #2980b9;
        }
        .expansion-container {
            border: 2px dashed #bdc3c7;
            border-radius: 8px;
            padding: 2rem;
            text-align: center;
            color: #95a5a6;
        }
    </style>
</head>
<body>

    <header>
        <h1>Nzaze</h1>
        <div class="user-greeting">
            <span>Welcome, <strong><%= firstName %></strong>!</span>
            <a href="login.jsp" class="logout-btn">Logout</a>
        </div>
    </header>

    <div class="container">
        
        <div class="welcome-card">
            <h2>Guest Portal</h2>
            <p>Welcome to your stay. Here are your access details and property information.</p>
        </div>

        <div class="dashboard-grid">
            <div class="card">
                <div class="card-title">Room Number</div>
                <div class="card-value">#<%= (roomNumber != null) ? roomNumber : "N/A" %></div>
            </div>

            <div class="card access-card">
                <div class="card-title">Access Code</div>
                <div class="card-value access-code-value"><%= (accessCode != null) ? accessCode : "------" %></div>
            </div>
        </div>

        <div class="action-card">
            <h3>Property Support</h3>
            <a href="tel:+18005550199" class="btn">Call Property Management</a>
            <a href="mailto:support@nzaze.com" class="btn" style="background-color: #9b59b6;">Contact via Email</a>
        </div>

        <div class="expansion-container">
            <p><strong>Future Features Container</strong></p>
            <p style="font-size: 0.85rem; margin-top: 0.25rem;">Wi-Fi details, house rules, and digital check-out requests will appear here in future updates.</p>
        </div>

    </div>

</body>
</html>