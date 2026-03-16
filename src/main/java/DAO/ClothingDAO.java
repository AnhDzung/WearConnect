package DAO;

import config.DatabaseConnection;
import Model.Clothing;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class ClothingDAO {

    public static List<Clothing> getHomeProducts(String type,
                                                 String query,
                                                 List<String> categories,
                                                 String dateFrom,
                                                 String dateTo,
                                                 String sort,
                                                 int page,
                                                 int pageSize) {
        List<Clothing> list = new ArrayList<>();
        String safeSort = sort != null ? sort : "newest";
        int safePage = Math.max(page, 1);
        int safePageSize = Math.max(pageSize, 1);
        int offset = (safePage - 1) * safePageSize;

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.*, COALESCE(r.AvgRating, 0) AS AvgRating ")
           .append("FROM Clothing c ")
           .append("LEFT JOIN ( ")
           .append("  SELECT ro.ClothingID, AVG(CAST(rt.Rating AS FLOAT)) AS AvgRating ")
           .append("  FROM Rating rt ")
           .append("  JOIN RentalOrder ro ON rt.RentalOrderID = ro.RentalOrderID ")
           .append("  GROUP BY ro.ClothingID ")
           .append(") r ON r.ClothingID = c.ClothingID ")
           .append("WHERE 1=1 ");

        appendHomeFilters(sql, type, query, categories, dateFrom, dateTo);

        if ("popular".equals(safeSort)) {
            sql.append(" ORDER BY COALESCE(r.AvgRating, 0) DESC, c.ClothingID DESC ");
        } else if ("price_asc".equals(safeSort)) {
            sql.append(" ORDER BY ISNULL(c.DailyPrice, 0) ASC, c.ClothingID DESC ");
        } else if ("price_desc".equals(safeSort)) {
            sql.append(" ORDER BY ISNULL(c.DailyPrice, 0) DESC, c.ClothingID DESC ");
        } else {
            sql.append(" ORDER BY c.ClothingID DESC ");
        }
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY ");

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = bindHomeFilters(ps, 1, type, query, categories, dateFrom, dateTo);
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, safePageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public static int countHomeProducts(String type,
                                        String query,
                                        List<String> categories,
                                        String dateFrom,
                                        String dateTo) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) AS TotalItems FROM Clothing c WHERE 1=1 ");
        appendHomeFilters(sql, type, query, categories, dateFrom, dateTo);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindHomeFilters(ps, 1, type, query, categories, dateFrom, dateTo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("TotalItems");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public static int addClothing(Clothing clothing) {
        String sql = "INSERT INTO Clothing (RenterID, ClothingName, Category, Style, Occasion, Size, Description, HourlyPrice, DailyPrice, ImagePath, ImageData, AvailableFrom, AvailableTo, Quantity, ItemValue, ClothingStatus) " +
                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, clothing.getRenterID());
            ps.setString(2, clothing.getClothingName());
            ps.setString(3, clothing.getCategory());
            ps.setString(4, clothing.getStyle());
            ps.setString(5, clothing.getOccasion());
            ps.setString(6, clothing.getSize());
            ps.setString(7, clothing.getDescription());
            ps.setBigDecimal(8, clothing.getHourlyPriceBigDecimal());
            ps.setBigDecimal(9, clothing.getDailyPriceBigDecimal());
            ps.setString(10, clothing.getImagePath());
            ps.setBytes(11, clothing.getImageData());
            ps.setTimestamp(12, Timestamp.valueOf(clothing.getAvailableFrom()));
            ps.setTimestamp(13, Timestamp.valueOf(clothing.getAvailableTo()));
            ps.setInt(14, clothing.getQuantity() > 0 ? clothing.getQuantity() : 1);
            ps.setBigDecimal(15, clothing.getItemValueBigDecimal());
            ps.setString(16, clothing.getClothingStatus() != null ? clothing.getClothingStatus() : "ACTIVE");
            
            int row = ps.executeUpdate();
            if (row > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public static List<Clothing> getAllActiveClothing() {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE IsActive = 1 AND ClothingStatus != 'PENDING_COSPLAY_REVIEW'";
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRowToClothing(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<Clothing> getAllClothingAdmin() {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing ORDER BY CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRowToClothing(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static Clothing getClothingByID(int clothingID) {
        String sql = "SELECT * FROM Clothing WHERE ClothingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clothingID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRowToClothing(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static List<Clothing> searchByCategory(String category) {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE Category = ? AND IsActive = 1 AND ClothingStatus != 'PENDING_COSPLAY_REVIEW'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<Clothing> searchByStyle(String style) {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE Style LIKE ? AND IsActive = 1 AND ClothingStatus != 'PENDING_COSPLAY_REVIEW'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + style + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<Clothing> searchByOccasion(String occasion) {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE Occasion LIKE ? AND IsActive = 1 AND ClothingStatus != 'PENDING_COSPLAY_REVIEW'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + occasion + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<Clothing> searchByName(String name) {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE ClothingName LIKE ? AND IsActive = 1 AND ClothingStatus != 'PENDING_COSPLAY_REVIEW'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + name + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<Clothing> searchProductsForAI(String keyword, int limit) {
        return searchProductsForAI(keyword, limit, null);
    }

    public static List<Clothing> searchProductsForAI(String keyword, int limit, BigDecimal maxDailyPrice) {
        return searchProductsForAI(keyword, null, null, null, limit, maxDailyPrice);
    }

    public static List<Clothing> searchProductsForAI(String keyword,
                                                     String occasion,
                                                     String style,
                                                     String category,
                                                     int limit,
                                                     BigDecimal maxDailyPrice) {
        List<Clothing> list = new ArrayList<>();
        if ((keyword == null || keyword.trim().isEmpty())
                && (occasion == null || occasion.trim().isEmpty())
                && (style == null || style.trim().isEmpty())
                && (category == null || category.trim().isEmpty())) {
            return list;
        }

        int safeLimit = limit <= 0 ? 6 : Math.min(limit, 12);
        String likeKeyword = keyword == null || keyword.trim().isEmpty() ? null : "%" + keyword.trim() + "%";
        String likeOccasion = occasion == null || occasion.trim().isEmpty() ? null : "%" + occasion.trim() + "%";
        String likeStyle = style == null || style.trim().isEmpty() ? null : "%" + style.trim() + "%";
        String likeCategory = category == null || category.trim().isEmpty() ? null : "%" + category.trim() + "%";

        String sql = "SELECT TOP " + safeLimit + " * FROM Clothing "
                + "WHERE IsActive = 1 AND ClothingStatus != 'PENDING_COSPLAY_REVIEW' "
                + "AND (? IS NULL OR DailyPrice IS NULL OR DailyPrice <= ?) "
            + "AND (? IS NULL OR Occasion COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI) "
            + "AND (? IS NULL OR Style COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI) "
            + "AND (? IS NULL OR Category COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI) "
            + "AND (? IS NULL OR ClothingName COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI "
            + "OR Category COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI "
            + "OR Style COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI "
            + "OR Occasion COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI "
            + "OR Description COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI) "
                + "ORDER BY "
                + "CASE "
            + "WHEN (? IS NOT NULL AND Occasion COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI) THEN 0 "
            + "WHEN (? IS NOT NULL AND Category COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI) THEN 1 "
            + "WHEN (? IS NOT NULL AND Style COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI) THEN 2 "
            + "WHEN (? IS NOT NULL AND ClothingName COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI) THEN 3 "
                + "ELSE 4 END, CreatedAt DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (maxDailyPrice == null) {
                ps.setNull(1, java.sql.Types.DECIMAL);
                ps.setNull(2, java.sql.Types.DECIMAL);
            } else {
                ps.setBigDecimal(1, maxDailyPrice);
                ps.setBigDecimal(2, maxDailyPrice);
            }

            ps.setString(3, likeOccasion);
            ps.setString(4, likeOccasion);
            ps.setString(5, likeStyle);
            ps.setString(6, likeStyle);
            ps.setString(7, likeCategory);
            ps.setString(8, likeCategory);

            ps.setString(9, likeKeyword);
            ps.setString(10, likeKeyword);
            ps.setString(11, likeKeyword);
            ps.setString(12, likeKeyword);
            ps.setString(13, likeKeyword);
            ps.setString(14, likeKeyword);

            ps.setString(15, likeOccasion);
            ps.setString(16, likeOccasion);
            ps.setString(17, likeCategory);
            ps.setString(18, likeCategory);
            ps.setString(19, likeStyle);
            ps.setString(20, likeStyle);
            ps.setString(21, likeKeyword);
            ps.setString(22, likeKeyword);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public static List<Clothing> getLatestActiveProductsForAI(int limit, BigDecimal maxDailyPrice) {
        List<Clothing> list = new ArrayList<>();
        int safeLimit = limit <= 0 ? 6 : Math.min(limit, 12);

        String sql = "SELECT TOP " + safeLimit + " * FROM Clothing "
                + "WHERE IsActive = 1 AND ClothingStatus != 'PENDING_COSPLAY_REVIEW' "
                + "AND (? IS NULL OR DailyPrice IS NULL OR DailyPrice <= ?) "
                + "ORDER BY CreatedAt DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (maxDailyPrice == null) {
                ps.setNull(1, java.sql.Types.DECIMAL);
                ps.setNull(2, java.sql.Types.DECIMAL);
            } else {
                ps.setBigDecimal(1, maxDailyPrice);
                ps.setBigDecimal(2, maxDailyPrice);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public static List<Clothing> getClothingByRenter(int renterID) {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE RenterID = ? AND IsActive = 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, renterID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static boolean updateClothing(Clothing clothing) {
        String sql = "UPDATE Clothing SET ClothingName = ?, Category = ?, Style = ?, Occasion = ?, Size = ?, Description = ?, HourlyPrice = ?, DailyPrice = ?, ImagePath = ?, ImageData = ?, AvailableFrom = ?, AvailableTo = ?, Quantity = ?, ItemValue = ? WHERE ClothingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, clothing.getClothingName());
            ps.setString(2, clothing.getCategory());
            ps.setString(3, clothing.getStyle());
            ps.setString(4, clothing.getOccasion());
            ps.setString(5, clothing.getSize());
            ps.setString(6, clothing.getDescription());
            ps.setBigDecimal(7, clothing.getHourlyPriceBigDecimal());
            ps.setBigDecimal(8, clothing.getDailyPriceBigDecimal());
            ps.setString(9, clothing.getImagePath());
            ps.setBytes(10, clothing.getImageData());
            ps.setTimestamp(11, Timestamp.valueOf(clothing.getAvailableFrom()));
            ps.setTimestamp(12, Timestamp.valueOf(clothing.getAvailableTo()));
            ps.setInt(13, clothing.getQuantity());
            ps.setBigDecimal(14, clothing.getItemValueBigDecimal());
            ps.setInt(15, clothing.getClothingID());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean deleteClothing(int clothingID) {
        String sql = "UPDATE Clothing SET IsActive = 0 WHERE ClothingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clothingID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private static Clothing mapRowToClothing(ResultSet rs) throws SQLException {
        Clothing clothing = new Clothing();
        clothing.setClothingID(rs.getInt("ClothingID"));
        clothing.setRenterID(rs.getInt("RenterID"));
        clothing.setClothingName(rs.getString("ClothingName"));
        clothing.setCategory(rs.getString("Category"));
        clothing.setStyle(rs.getString("Style"));
        clothing.setOccasion(rs.getString("Occasion"));
        clothing.setSize(rs.getString("Size"));
        clothing.setDescription(rs.getString("Description"));
        clothing.setHourlyPrice(rs.getBigDecimal("HourlyPrice"));
        BigDecimal dailyPrice = rs.getBigDecimal("DailyPrice");
        if (dailyPrice == null) {
            // Nếu DailyPrice NULL, set mặc định = HourlyPrice * 24
            BigDecimal hourlyPrice = rs.getBigDecimal("HourlyPrice");
            dailyPrice = hourlyPrice != null ? hourlyPrice.multiply(new java.math.BigDecimal(24)) : new java.math.BigDecimal(0);
        }
        clothing.setDailyPrice(dailyPrice);
        clothing.setImagePath(rs.getString("ImagePath"));
        clothing.setImageData(rs.getBytes("ImageData"));
        clothing.setAvailableFrom(rs.getTimestamp("AvailableFrom").toLocalDateTime());
        clothing.setAvailableTo(rs.getTimestamp("AvailableTo").toLocalDateTime());
        clothing.setActive(rs.getBoolean("IsActive"));
        
        // Set quantity with default value of 1 if not present
        int quantity = rs.getInt("Quantity");
        clothing.setQuantity(quantity > 0 ? quantity : 1);
        
        // Set deposit amount
        BigDecimal itemValue = rs.getBigDecimal("ItemValue");
        if (itemValue != null) {
            clothing.setItemValue(itemValue);
        }
        
        // Set clothing status
        String clothingStatus = rs.getString("ClothingStatus");
        clothing.setClothingStatus(clothingStatus != null ? clothingStatus : "ACTIVE");

        // Optional aggregated column used by home listing optimization
        try {
            clothing.setAverageRating(rs.getDouble("AvgRating"));
        } catch (SQLException ignore) {}
        
        clothing.setCreatedAt(rs.getTimestamp("CreatedAt").toLocalDateTime());
        return clothing;
    }

    private static void appendHomeFilters(StringBuilder sql,
                                          String type,
                                          String query,
                                          List<String> categories,
                                          String dateFrom,
                                          String dateTo) {
        sql.append(" AND c.IsActive = 1 ")
           .append(" AND (c.Category IS NULL OR LTRIM(RTRIM(c.Category)) <> 'Cosplay') ")
           .append(" AND (c.ClothingStatus IS NULL OR UPPER(LTRIM(RTRIM(c.ClothingStatus))) = 'ACTIVE') ");

        if (query != null && !query.isBlank()) {
            if ("category".equals(type)) {
                sql.append(" AND c.Category = ? ");
            } else if ("style".equals(type)) {
                sql.append(" AND c.Style LIKE ? ");
            } else if ("occasion".equals(type)) {
                sql.append(" AND c.Occasion LIKE ? ");
            } else {
                sql.append(" AND c.ClothingName LIKE ? ");
            }
        }

        if (categories != null && !categories.isEmpty()) {
            sql.append(" AND c.Category IN (");
            for (int i = 0; i < categories.size(); i++) {
                if (i > 0) sql.append(", ");
                sql.append("?");
            }
            sql.append(") ");
        }

        if (dateFrom != null && !dateFrom.isBlank()) {
            sql.append(" AND (c.AvailableTo IS NULL OR CAST(c.AvailableTo AS DATE) >= CAST(? AS DATE)) ");
        }
        if (dateTo != null && !dateTo.isBlank()) {
            sql.append(" AND (c.AvailableFrom IS NULL OR CAST(c.AvailableFrom AS DATE) <= CAST(? AS DATE)) ");
        }
    }

    private static int bindHomeFilters(PreparedStatement ps,
                                       int startIndex,
                                       String type,
                                       String query,
                                       List<String> categories,
                                       String dateFrom,
                                       String dateTo) throws SQLException {
        int paramIndex = startIndex;

        if (query != null && !query.isBlank()) {
            if ("category".equals(type)) {
                ps.setString(paramIndex++, query);
            } else {
                ps.setString(paramIndex++, "%" + query + "%");
            }
        }

        if (categories != null && !categories.isEmpty()) {
            for (String category : categories) {
                ps.setString(paramIndex++, category);
            }
        }

        if (dateFrom != null && !dateFrom.isBlank()) {
            ps.setString(paramIndex++, dateFrom);
        }
        if (dateTo != null && !dateTo.isBlank()) {
            ps.setString(paramIndex++, dateTo);
        }

        return paramIndex;
    }
    
    /**
     * Get all cosplay products by status
     */
    public static List<Clothing> getCosplayByStatus(String status) {
        List<Clothing> list = new ArrayList<>();
        String sql = "SELECT * FROM Clothing WHERE Category = 'Cosplay' AND ClothingStatus = ? ORDER BY CreatedAt DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToClothing(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * Update clothing status
     */
    public static boolean updateClothingStatus(int clothingID, String status) {
        String sql = "UPDATE Clothing SET ClothingStatus = ? WHERE ClothingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, clothingID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Set clothing active status
     */
    public static boolean setClothingActive(int clothingID, boolean isActive) {
        String sql = "UPDATE Clothing SET IsActive = ? WHERE ClothingID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, isActive ? 1 : 0);
            ps.setInt(2, clothingID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
