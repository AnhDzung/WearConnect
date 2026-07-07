package config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class DatabaseConnection {
    // SQL Server Connection Parameters
    private static final String DEFAULT_SERVER = "localhost";
    private static final String DEFAULT_DATABASE = "WearConnect";
    private static final String DEFAULT_USERNAME = "sa";
    private static final String DEFAULT_PASSWORD = "sa";
    private static final String DEFAULT_PORT = "1433";

    private static volatile HikariDataSource dataSource;

    public DatabaseConnection() {
    }

    public static Connection getConnection() {
        try {
            return getDataSource().getConnection();
        } catch (SQLException e) {
            System.err.println("Lỗi kết nối SQL Server: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public static void closeConnection() {
        if (dataSource != null) {
            dataSource.close();
            dataSource = null;
            System.out.println("Đã đóng SQL Server connection pool!");
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

    private static HikariDataSource getDataSource() {
        if (dataSource == null) {
            synchronized (DatabaseConnection.class) {
                if (dataSource == null) {
                    String connectionString = resolveConnectionString();
                    String username = getSetting("wearconnect.db.username", "WEARCONNECT_DB_USERNAME", DEFAULT_USERNAME);
                    String password = getSetting("wearconnect.db.password", "WEARCONNECT_DB_PASSWORD", DEFAULT_PASSWORD);

                    Properties dsProps = new Properties();
                    if (username != null && !username.isBlank()) {
                        dsProps.setProperty("user", username);
                    }
                    if (password != null && !password.isBlank()) {
                        dsProps.setProperty("password", password);
                    }

                    HikariConfig config = new HikariConfig();
                    config.setJdbcUrl(connectionString);
                    config.setDriverClassName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                    config.setMaximumPoolSize(20);
                    config.setMinimumIdle(3);
                    config.setConnectionTimeout(30000);
                    config.setIdleTimeout(600000);
                    config.setMaxLifetime(1800000);
                    config.setPoolName("WearConnectHikariPool");
                    config.setDataSourceProperties(dsProps);

                    dataSource = new HikariDataSource(config);
                    System.out.println("Khởi tạo SQL Server connection pool thành công!");
                    initializeDatabaseSchema();
                }
            }
        }
        return dataSource;
    }

    private static void initializeDatabaseSchema() {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {
            if (conn != null) {
                stmt.execute("UPDATE Accounts SET UserRole = 'Seller' WHERE UserRole = 'Renter'");
                System.out.println("[DatabaseConnection] Migrated user role Renter to Seller successfully!");
            }
        } catch (SQLException e) {
            System.err.println("[DatabaseConnection] Error running UserRole migration: " + e.getMessage());
        }

        String sql = "IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='CartItems' AND xtype='U')\n" +
                     "BEGIN\n" +
                     "    CREATE TABLE CartItems (\n" +
                     "        CartItemID INT IDENTITY(1,1) PRIMARY KEY,\n" +
                     "        AccountID INT NOT NULL,\n" +
                     "        ClothingID INT NOT NULL,\n" +
                     "        RentalType NVARCHAR(50) NOT NULL,\n" +
                     "        StartDate DATETIME NOT NULL,\n" +
                     "        EndDate DATETIME NOT NULL,\n" +
                     "        SelectedSize NVARCHAR(50) NULL,\n" +
                     "        ColorID INT NULL,\n" +
                     "        FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID) ON DELETE CASCADE,\n" +
                     "        FOREIGN KEY (ClothingID) REFERENCES Clothing(ClothingID) ON DELETE CASCADE\n" +
                     "    )\n" +
                     "END";
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {
            if (conn != null) {
                stmt.execute(sql);
                System.out.println("[DatabaseConnection] Bảng CartItems đã được kiểm tra/khởi tạo thành công!");
            }
        } catch (SQLException e) {
            System.err.println("[DatabaseConnection] Lỗi khi tạo bảng CartItems: " + e.getMessage());
            e.printStackTrace();
        }
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
