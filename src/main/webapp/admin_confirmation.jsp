<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest Account Created - Nzaze</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <main class="container py-5">
        <div class="card shadow-sm mx-auto" style="max-width: 520px;">
            <div class="card-body p-4">
                <h1 class="h4 mb-3">Guest account created</h1>
                <p class="text-muted">Share these credentials with <strong><%= request.getAttribute("guestName") %></strong>.</p>
                <dl class="row mb-4">
                    <dt class="col-sm-5">Username</dt>
                    <dd class="col-sm-7"><code><%= request.getAttribute("createdUsername") %></code></dd>
                    <dt class="col-sm-5">Temporary password</dt>
                    <dd class="col-sm-7"><code><%= request.getAttribute("createdPassword") %></code></dd>
                    <dt class="col-sm-5">Access code</dt>
                    <dd class="col-sm-7"><code><%= request.getAttribute("createdAccessCode") %></code></dd>
                </dl>
                <a class="btn btn-primary" href="new.jsp">Back to dashboard</a>
            </div>
        </div>
    </main>
</body>
</html>
