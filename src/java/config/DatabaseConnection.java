package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    // SQL Server Connection Parameters
    private static final String SERVER = "localhost"; // Thay đổi thành server của bạn
    private static final String DATABASE = "WearConnect";
    private static final String USERNAME = "sa"; // Thay đổi thành username SQL Server của bạn
    private static final String PASSWORD = "sa"; // Thay đổi thành password SQL Server của bạn
    private static final String PORT = "1433";
    
    private static Connection connection;

    public DatabaseConnection() {
    }

    public static Connection getConnection() {
        try {
            // Kiểm tra xem driver đã được load chưa
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            
            // Tạo connection string
            String connectionString = "jdbc:sqlserver://" + SERVER + ":" + PORT + 
                                     ";databaseName=" + DATABASE + 
                                     ";user=" + USERNAME + 
                                     ";password=" + PASSWORD +
                                     ";encrypt=true;trustServerCertificate=true;";
            
            if (connection == null || connection.isClosed()) {
                connection = DriverManager.getConnection(connectionString);
                System.out.println("Kết nối SQL Server thành công!");
            }
        } catch (ClassNotFoundException e) {
            System.err.println("Lỗi: Driver SQL Server không tìm thấy!");
            System.err.println("Vui lòng thêm file mssql-jdbc-*.jar vào Libraries");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Lỗi kết nối SQL Server: " + e.getMessage());
            e.printStackTrace();
        }
        return connection;
    }

    public static void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                System.out.println("Đã đóng kết nối SQL Server!");
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi đóng kết nối: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        // Test connection
        Connection conn = getConnection();
        if (conn != null) {
            System.out.println("Kết nối thành công!");
            closeConnection();
        } else {
            System.out.println("Kết nối thất bại!");
        }
    }
}
