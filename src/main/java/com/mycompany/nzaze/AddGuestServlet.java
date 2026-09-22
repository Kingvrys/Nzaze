package com.mycompany.nzaze;

import com.nzaze.util.CredentialGenerator;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.Calendar;
import java.util.TimeZone;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/AddGuestServlet")
public class AddGuestServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/nzaze_db";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Get guest details from admin form
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String roomNumber = request.getParameter("roomNumber");
        String checkIn = request.getParameter("checkInDate");
        String checkOut = request.getParameter("checkOutDate");
        String comments = request.getParameter("comments");

        // 2. Generate username, password, and access code using Step 2 utility
        String username = CredentialGenerator.generateUsername(firstName, lastName);
        String tempPassword = CredentialGenerator.generateTemporaryPassword();
        String accessCode = CredentialGenerator.generateAccessCode();

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            conn.setAutoCommit(false); // Begin transaction

            // 3. Insert user login into 'users' table
            String userSql = "INSERT INTO users (username, password_hash, role) VALUES (?, ?, 'GUEST')";
            PreparedStatement userStmt = conn.prepareStatement(userSql, Statement.RETURN_GENERATED_KEYS);
            userStmt.setString(1, username);
            userStmt.setString(2, tempPassword);
            userStmt.executeUpdate();

            ResultSet rs = userStmt.getGeneratedKeys();
            int generatedUserId = -1;
            if (rs.next()) {
                generatedUserId = rs.getInt(1);
            }

            // 4. Insert stay details into 'guests' table linked to generated user_id
            String guestSql = "INSERT INTO guests (user_id, first_name, last_name, email, phone_number, room_number, guest_code, "
                            + "check_in_date, check_out_date, status, rating, host_comments) "
                            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', 0, ?)";
            PreparedStatement guestStmt = conn.prepareStatement(guestSql, Statement.RETURN_GENERATED_KEYS);
            guestStmt.setInt(1, generatedUserId);
            guestStmt.setString(2, firstName);
            guestStmt.setString(3, lastName);
            guestStmt.setString(4, email);
            guestStmt.setString(5, phone);
            guestStmt.setString(6, roomNumber);
            guestStmt.setString(7, accessCode);
            guestStmt.setString(8, checkIn);
            LocalDate checkoutDate = LocalDate.parse(checkOut.substring(0, 10));
            Timestamp checkoutExpiry = Timestamp.from(checkoutDate.atTime(12, 0).toInstant(ZoneOffset.UTC));
            guestStmt.setTimestamp(9, checkoutExpiry, Calendar.getInstance(TimeZone.getTimeZone("UTC")));
            guestStmt.setString(10, comments != null ? comments : "");
            guestStmt.executeUpdate();

            int generatedGuestId = -1;
            try (ResultSet guestKeys = guestStmt.getGeneratedKeys()) {
                if (guestKeys.next()) {
                    generatedGuestId = guestKeys.getInt(1);
                }
            }
            String staySql = "INSERT INTO guest_stays (guest_id, check_in_date, check_out_date) VALUES (?, ?, ?)";
            PreparedStatement stayStmt = conn.prepareStatement(staySql);
            stayStmt.setInt(1, generatedGuestId);
            stayStmt.setString(2, checkIn);
            stayStmt.setTimestamp(3, checkoutExpiry, Calendar.getInstance(TimeZone.getTimeZone("UTC")));
            stayStmt.executeUpdate();

            conn.commit(); // Commit both insertions together

            // 5. Pass generated credentials to confirmation view
            request.setAttribute("createdUsername", username);
            request.setAttribute("createdPassword", tempPassword);
            request.setAttribute("createdAccessCode", accessCode);
            request.setAttribute("guestName", firstName + " " + lastName);

            request.getRequestDispatcher("admin_confirmation.jsp").forward(request, response);

        } catch (ClassNotFoundException | SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.getWriter().println("Error creating guest account: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}