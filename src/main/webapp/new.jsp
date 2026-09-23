<%
    if (session.getAttribute("user") == null
            || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Nzaze - Guest Tracking Dashboard</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">

        <nav class="navbar navbar-dark bg-dark mb-4">
    <div class="container">
        <a class="navbar-brand fw-bold d-flex align-items-center" href="#">
            <img src="images/logo.png" alt="Logo" width="30" height="30" class="d-inline-block align-text-top me-2">
            NG Nzaze Guest Tracking
        </a>
    </div>
</nav>3

        <div class="container">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="h4 text-secondary">Guest Management Dashboard</h2>
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addGuestModal">
                    + Add New Guest
                </button>
            </div>

            <div class="card shadow-sm mb-4">
                <div class="card-header bg-warning text-dark fw-bold d-flex justify-content-between align-items-center">
                    <span>Guest Stay Leaderboard</span>
                    <small id="leaderboardStatus" class="fw-normal">Loading...</small>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr><th>Rank</th><th>Guest</th><th>Number of stays</th></tr>
                            </thead>
                            <tbody id="leaderboardBody">
                                <tr><td colspan="3" class="text-center py-3 text-muted">Loading leaderboard...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm mb-4">
                <div class="card-header bg-dark text-white fw-bold">
                    Guest Search
                </div>
                <div class="card-body">
                    <form id="checkInForm" class="row g-3 align-items-center" autocomplete="off">
                        <div class="col-md-8 col-sm-12 position-relative">
                            <input type="text" id="guestSearch" class="form-control" placeholder="Search by name, email, phone, room, or access code" required>
                            <div id="searchSuggestions" class="list-group position-absolute w-100 shadow-sm" style="z-index: 10;"></div>
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <button type="submit" class="btn btn-success w-100">Search & Verify</button>
                        </div>
                    </form>
                    
                    <div id="resultContainer" class="mt-3"></div>
                </div>
            </div>
            <div class="card shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th>Guest ID</th>
                                    <th>Access Code</th>
                                    <th>First Name</th>
                                    <th>Last Name</th>
                                    <th>Phone</th>
                                    <th>Check-In</th>
                                    <th>Check-Out</th>
                                    <th>Status</th>
                                    <th>Rating</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    String url = "jdbc:mysql://localhost:3306/nzaze_db";
                                    String user = "root";
                                    String password = "";
                                    String sql = "SELECT guest_id, guest_code, first_name, last_name, phone_number, check_in_date, check_out_date, status, rating FROM guests ORDER BY guest_id DESC";

                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        try (Connection conn = DriverManager.getConnection(url, user, password);
                                             Statement stmt = conn.createStatement();
                                             ResultSet rs = stmt.executeQuery(sql)) {

                                            boolean hasData = false;
                                            while (rs.next()) {
                                                hasData = true;
                                                String status = rs.getString("status");
                                                // Dynamic badge styling based on status
                                                String badgeClass = "bg-secondary";
                                                if ("Active".equalsIgnoreCase(status)) badgeClass = "bg-success";
                                                else if ("Pending".equalsIgnoreCase(status)) badgeClass = "bg-warning text-dark";
                                %>
                                                <tr>
                                                    <td><a href="GuestHistoryServlet?guestId=<%= rs.getInt("guest_id") %>">#<%= rs.getInt("guest_id") %></a></td>
                                                    <td><code class="fw-bold text-danger"><%= rs.getString("guest_code") %></code></td>
                                                    <td class="fw-bold"><%= rs.getString("first_name") %></td>
                                                    <td><%= rs.getString("last_name") %></td>
                                                    <td><%= rs.getString("phone_number") %></td>
                                                    <td><%= rs.getString("check_in_date") %></td>
                                                    <td><%= rs.getString("check_out_date") %></td>
                                                    <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                                                    <td>
                                                        <% 
                                                            int stars = rs.getInt("rating");
                                                            for(int i=0; i<stars; i++) { out.print("⭐"); }
                                                            if(stars == 0) { out.print("<small class='text-muted'>Unrated</small>"); }
                                                        %>
                                                    </td>
                                                    <td><a class="btn btn-sm btn-outline-primary" href="EditGuestServlet?guestId=<%= rs.getInt("guest_id") %>">Edit</a></td>
                                                </tr>
                                <%
                                            }
                                            if (!hasData) {
                                                out.println("<tr><td colspan='10' class='text-center py-4 text-muted'>No guests found. Click '+ Add New Guest' to get started!</td></tr>");
                                            }
                                        }
                                    } catch (Exception e) {
                                        out.println("<tr><td colspan='10' class='text-center py-4 text-danger'>Error loading database entries: " + e.getMessage() + "</td></tr>");
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="addGuestModal" tabindex="-1" aria-labelledby="addGuestModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="addGuestModalLabel">Register New Guest</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="AddGuestServlet" method="POST">
                        <div class="modal-body">
                            <div class="row g-3">
                                <div class="col-6">
                                    <label class="form-label">First Name</label>
                                    <input type="text" name="firstName" class="form-control" required>
                                </div>
                                <div class="col-6">
                                    <label class="form-label">Last Name</label>
                                    <input type="text" name="lastName" class="form-control" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Email</label>
                                    <input type="email" name="email" class="form-control">
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Phone Number</label>
                                    <input type="text" name="phone" class="form-control" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Room Number</label>
                                    <input type="text" name="roomNumber" class="form-control" required>
                                </div>
                                <div class="col-6">
                                    <label class="form-label">Check-In Date</label>
                                    <input type="datetime-local" name="checkInDate" class="form-control" required>
                                </div>
                                <div class="col-6">
                                    <label class="form-label">Check-Out Date and Time (expires at 12:00 UTC)</label>
                                    <input type="datetime-local" name="checkOutDate" class="form-control" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Host Comments</label>
                                    <textarea name="comments" class="form-control" rows="3"></textarea>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary">Generate Code & Save</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

        <script>
        const searchForm = document.getElementById("checkInForm");
        const searchInput = document.getElementById("guestSearch");
        const suggestions = document.getElementById("searchSuggestions");
        const resultDiv = document.getElementById("resultContainer");
        let searchTimer;

        function loadLeaderboard() {
            fetch("LeaderboardServlet")
                .then(response => response.json())
                .then(data => {
                    const body = document.getElementById("leaderboardBody");
                    const status = document.getElementById("leaderboardStatus");
                    if (!data.success || !data.entries || data.entries.length === 0) {
                        body.innerHTML = '<tr><td colspan="3" class="text-center py-3 text-muted">No guest stays recorded yet.</td></tr>';
                        status.textContent = "No stays yet";
                        return;
                    }
                    body.innerHTML = data.entries.map(entry =>
                        `<tr><td class="fw-bold">\${entry.rank}</td><td>\${escapeHtml(entry.name)}</td><td class="fw-bold">\${entry.stays}</td></tr>`
                    ).join("");
                    status.textContent = "Updated just now";
                })
                .catch(() => {
                    document.getElementById("leaderboardBody").innerHTML = '<tr><td colspan="3" class="text-center py-3 text-danger">Could not load leaderboard.</td></tr>';
                    document.getElementById("leaderboardStatus").textContent = "Unavailable";
                });
        }

        loadLeaderboard();

        searchInput.addEventListener("input", function() {
            clearTimeout(searchTimer);
            const term = searchInput.value.trim();
            if (term.length < 2) {
                suggestions.innerHTML = "";
                return;
            }
            searchTimer = setTimeout(() => searchGuests(term, true), 250);
        });

        searchForm.addEventListener("submit", function(event) {
            event.preventDefault();
            searchGuests(searchInput.value.trim(), false);
        });

        function searchGuests(term, showSuggestions) {
            fetch("CheckInServlet?q=" + encodeURIComponent(term))
                .then(response => response.json())
                .then(data => {
                    if (showSuggestions) {
                        suggestions.innerHTML = (data.results || []).map(guest =>
                            `<button type="button" class="list-group-item list-group-item-action" data-value="\${escapeHtml(guest.firstName + " " + guest.lastName)}">\${escapeHtml(guest.firstName + " " + guest.lastName)} <small class="text-muted">\${escapeHtml(guest.roomNumber || guest.guestCode)}</small></button>`
                        ).join("");
                        suggestions.querySelectorAll("button").forEach(button => button.addEventListener("click", () => {
                            searchInput.value = button.dataset.value;
                            suggestions.innerHTML = "";
                            searchGuests(searchInput.value, false);
                        }));
                    } else {
                        suggestions.innerHTML = "";
                        renderResults(data);
                    }
                })
                .catch(() => resultDiv.innerHTML = '<div class="alert alert-danger mt-2">Could not search the guest database.</div>');
        }

        function renderResults(data) {
            if (!data.results || data.results.length === 0) {
                resultDiv.innerHTML = `<div class="alert alert-warning mt-2">\${escapeHtml(data.message || "No matching guest found.")}</div>`;
                return;
            }
            resultDiv.innerHTML = data.results.map(guest => `
                <div class="card border-success mt-2"><div class="card-body">
                    <h5>\${escapeHtml(guest.firstName + " " + guest.lastName)} <span class="badge bg-success">\${escapeHtml(guest.status)}</span></h5>
                    <p class="mb-1">Room: <strong>\${escapeHtml(guest.roomNumber || "Not assigned")}</strong> | Phone: \${escapeHtml(guest.phoneNumber)}</p>
                    <p class="mb-2">Email: \${escapeHtml(guest.email || "Not provided")} | Access code: <code>\${escapeHtml(guest.guestCode)}</code></p>
                    <a href="GuestHistoryServlet?guestId=\${guest.guestId}" class="btn btn-outline-secondary btn-sm">View history</a>
                    <a href="EditGuestServlet?guestId=\${guest.guestId}" class="btn btn-outline-primary btn-sm">Edit guest</a>
                    <button type="button" class="btn btn-outline-success btn-sm" onclick="recordCheckIn(\${guest.guestId})">Record check-in</button>
                </div></div>`).join("");
        }

        function escapeHtml(value) {
            return String(value || "").replace(/[&<>'"]/g, character => ({"&":"&amp;","<":"&lt;",">":"&gt;","'":"&#39;","\"":"&quot;"}[character]));
        }

        function recordCheckIn(guestId) {
            fetch("CheckInServlet", {
                method: "POST",
                headers: {"Content-Type": "application/x-www-form-urlencoded"},
                body: "guestId=" + encodeURIComponent(guestId)
            })
                .then(response => response.json())
                .then(data => {
                    resultDiv.innerHTML = `<div class="alert \${data.success ? "alert-success" : "alert-danger"} mt-2">\${escapeHtml(data.message)}</div>`;
                    if (data.success) {
                        loadLeaderboard();
                    }
                })
                .catch(() => resultDiv.innerHTML = '<div class="alert alert-danger mt-2">Could not record the check-in.</div>');
        }
        </script>
    </body>
</html>