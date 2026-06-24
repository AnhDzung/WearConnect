package com.wearconnect.boot.config;

import config.DatabaseConnection;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import java.sql.Connection;
import java.sql.Statement;

@Component
public class DatabaseMigrationConfig implements CommandLineRunner {
    @Override
    public void run(String... args) throws Exception {
        System.out.println("[DatabaseMigrationConfig] Checking database tables and running migrations if needed...");
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // 1. Create table Voucher if not exists
            String createVoucherTable = 
                "IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Voucher') " +
                "BEGIN " +
                "    CREATE TABLE Voucher ( " +
                "        VoucherID INT IDENTITY(1,1) PRIMARY KEY, " +
                "        VoucherCode VARCHAR(50) UNIQUE NOT NULL, " +
                "        DiscountType VARCHAR(20) NOT NULL, " +
                "        DiscountValue DOUBLE PRECISION NOT NULL, " +
                "        MinOrderValue DOUBLE PRECISION NOT NULL DEFAULT 0, " +
                "        MaxDiscountAmount DOUBLE PRECISION NULL, " +
                "        StartDate DATETIME NULL, " +
                "        EndDate DATETIME NULL, " +
                "        IsActive BIT NOT NULL DEFAULT 1, " +
                "        CreatedAt DATETIME DEFAULT GETDATE() " +
                "    ); " +
                "END;";
            stmt.execute(createVoucherTable);

            // 2. Add VoucherCode column to RentalOrder if not exists
            String addVoucherCodeColumn = 
                "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('RentalOrder') AND name = 'VoucherCode') " +
                "BEGIN " +
                "    ALTER TABLE RentalOrder ADD VoucherCode VARCHAR(50) NULL; " +
                "END;";
            stmt.execute(addVoucherCodeColumn);

            // 3. Add DiscountAmount column to RentalOrder if not exists
            String addDiscountAmountColumn = 
                "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('RentalOrder') AND name = 'DiscountAmount') " +
                "BEGIN " +
                "    ALTER TABLE RentalOrder ADD DiscountAmount DOUBLE PRECISION NOT NULL DEFAULT 0; " +
                "END;";
            stmt.execute(addDiscountAmountColumn);
            
            System.out.println("[DatabaseMigrationConfig] Database migrations checked and executed successfully!");
        } catch (Exception e) {
            System.err.println("[DatabaseMigrationConfig] Database migration failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
