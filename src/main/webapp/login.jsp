<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Nzaze Guest Tracking</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light d-flex align-items-center justify-content-center" style="height: 100vh;">
    
    <div class="card shadow p-4" style="width: 360px;">
        <div class="text-center mb-3">
            <img src="images/logo.png" alt="Logo" width="60" height="60">
        </div>
        
        <h3 class="text-center mb-4">Portal Login</h3>
        
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger py-2" role="alert">
                Invalid credentials or guest access has expired.
            </div>
        <% } %>

        <form action="LoginServlet" method="POST">
            <div class="mb-3">
                <label class="form-label">Username</label>
                <input type="text" name="username" class="form-control" placeholder="Enter username" required>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Password</label>
                <input type="password" name="password" class="form-control" placeholder="Enter password" required>
            </div>
            
            <button type="submit" class="btn btn-primary w-100">Login</button>
        </form>
    </div>

</body>
</html>