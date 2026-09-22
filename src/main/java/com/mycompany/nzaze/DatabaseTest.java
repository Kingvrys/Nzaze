import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseTest {
    // Connection configuration details
    private static final String URL = "jdbc:mysql://localhost:3306/nzaze_db";
    private static final String USER = "root"; 
    private static final String PASSWORD = ""; // XAMPP default MySQL password is empty

    public static void main(String[] args) {
        System.out.println("====== Attempting Database Connection ======");
        
        try {
            // Force load the driver class to ensure the Maven dependency works
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Try to establish the connection
            try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD)) {
                if (connection != null) {
                    System.out.println("🎉 SUCCESS: Connected to nzaze_db flawlessly!");
                }
            }
        } catch (ClassNotFoundException e) {
            System.out.println("❌ ERROR: MySQL JDBC Driver missing! Check your pom.xml.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("❌ ERROR: Connection failed! Ensure XAMPP MySQL is running.");
            e.printStackTrace();
        }
    }
}