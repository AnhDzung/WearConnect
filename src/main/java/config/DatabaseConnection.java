package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DatabaseConnection {
    // SQL Server Connection Parameters
    private static final String DEFAULT_SERVER = "localhost";
    private static final String DEFAULT_DATABASE = "WearConnect";
    private static final String DEFAULT_USERNAME = "sa";
    private static final String DEFAULT_PASSWORD = "sa";
    private static final String DEFAULT_PORT = "1433";
    
    private static Connection connection;

    public DatabaseConnection() {
    }

    public static Connection getConnection() {
        try {
            // Kiểm tra xem driver đã được load chưa
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            String connectionString = resolveConnectionString();
            Properties connectionProperties = new Properties();
            String username = getSetting("wearconnect.db.username", "WEARCONNECT_DB_USERNAME", DEFAULT_USERNAME);
            String password = getSetting("wearconnect.db.password", "WEARCONNECT_DB_PASSWORD", DEFAULT_PASSWORD);
            if (username != null && !username.isBlank()) {
                connectionProperties.setProperty("user", username);
            }
            if (password != null && !password.isBlank()) {
                connectionProperties.setProperty("password", password);
            }
            
            if (connection == null || connection.isClosed()) {
                connection = DriverManager.getConnection(connectionString, connectionProperties);
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

    private static String resolveConnectionString() {
        String directUrl = getSetting("wearconnect.db.url", "WEARCONNECT_DB_URL", null);
        if (directUrl != null && !directUrl.isBlank()) {
            return directUrl;
        }

        String server = getSetting("wearconnect.db.server", "WEARCONNECT_DB_SERVER", DEFAULT_SERVER);
        String port = getSetting("wearconnect.db.port", "WEARCONNECT_DB_PORT", DEFAULT_PORT);
        String database = getSetting("wearconnect.db.name", "WEARCONNECT_DB_NAME", DEFAULT_DATABASE);

        return "jdbc:sqlserver://" + server + ":" + port
                + ";databaseName=" + database
                + ";encrypt=true;trustServerCertificate=true;";
    }

    private static String getSetting(String systemPropertyKey, String envKey, String defaultValue) {
        String systemValue = System.getProperty(systemPropertyKey);
        if (systemValue != null && !systemValue.isBlank()) {
            return systemValue;
        }

        String envValue = System.getenv(envKey);
        if (envValue != null && !envValue.isBlank()) {
            return envValue;
        }

        return defaultValue;
    }
}
