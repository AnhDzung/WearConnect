package DAO;

import Model.CosplayDetail;
import config.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO class for CosplayDetail table operations
 * Handles CRUD operations for cosplay-specific product metadata
 */
public class CosplayDetailDAO {

    /**
     * Add a new cosplay detail record
     * @param detail CosplayDetail object containing cosplay metadata
     * @return true if insertion successful, false otherwise
     */
    public static boolean addCosplayDetail(CosplayDetail detail) {
        String sql = "INSERT INTO CosplayDetail (ClothingID, CharacterName, Series, CosplayType, " +
                     "AccuracyLevel, AccessoryList) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, detail.getClothingID());
            ps.setString(2, detail.getCharacterName());
            ps.setString(3, detail.getSeries());
            ps.setString(4, detail.getCosplayType());
            ps.setString(5, detail.getAccuracyLevel());
            ps.setString(6, detail.getAccessoryList());
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get cosplay detail by clothing ID
     * @param clothingID The clothing ID
     * @return CosplayDetail object or null if not found
     */
    public static CosplayDetail getCosplayDetailByClothingID(int clothingID) {
        String sql = "SELECT * FROM CosplayDetail WHERE ClothingID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, clothingID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToCosplayDetail(rs);
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Get cosplay detail by detail ID
     * @param detailID The detail ID
     * @return CosplayDetail object or null if not found
     */
    public static CosplayDetail getCosplayDetailByID(int detailID) {
        String sql = "SELECT * FROM CosplayDetail WHERE DetailID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, detailID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToCosplayDetail(rs);
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Update cosplay detail information
     * @param detail CosplayDetail object with updated information
     * @return true if update successful, false otherwise
     */
    public static boolean updateCosplayDetail(CosplayDetail detail) {
        String sql = "UPDATE CosplayDetail SET CharacterName = ?, Series = ?, CosplayType = ?, " +
                     "AccuracyLevel = ?, AccessoryList = ?, UpdatedAt = GETDATE() " +
                     "WHERE ClothingID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, detail.getCharacterName());
            ps.setString(2, detail.getSeries());
            ps.setString(3, detail.getCosplayType());
            ps.setString(4, detail.getAccuracyLevel());
            ps.setString(5, detail.getAccessoryList());
            ps.setInt(6, detail.getClothingID());
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete cosplay detail by clothing ID
     * @param clothingID The clothing ID
     * @return true if deletion successful, false otherwise
     */
    public static boolean deleteCosplayDetail(int clothingID) {
        String sql = "DELETE FROM CosplayDetail WHERE ClothingID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, clothingID);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get all cosplay details
     * @return List of CosplayDetail objects
     */
    public static List<CosplayDetail> getAllCosplayDetails() {
        List<CosplayDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM CosplayDetail ORDER BY CreatedAt DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(mapRowToCosplayDetail(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return list;
    }

    /**
     * Search cosplay details by character name
     * @param characterName Character name to search for
     * @return List of matching CosplayDetail objects
     */
    public static List<CosplayDetail> searchByCharacterName(String characterName) {
        List<CosplayDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM CosplayDetail WHERE CharacterName LIKE ? ORDER BY CreatedAt DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, "%" + characterName + "%");
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                list.add(mapRowToCosplayDetail(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return list;
    }

    /**
     * Search cosplay details by series
     * @param series Series name to search for
     * @return List of matching CosplayDetail objects
     */
    public static List<CosplayDetail> searchBySeries(String series) {
        List<CosplayDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM CosplayDetail WHERE Series LIKE ? ORDER BY CreatedAt DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, "%" + series + "%");
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                list.add(mapRowToCosplayDetail(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return list;
    }

    /**
     * Search cosplay details by type (Anime/Game/Movie)
     * @param cosplayType Type to filter by
     * @return List of matching CosplayDetail objects
     */
    public static List<CosplayDetail> searchByType(String cosplayType) {
        List<CosplayDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM CosplayDetail WHERE CosplayType = ? ORDER BY CreatedAt DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, cosplayType);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                list.add(mapRowToCosplayDetail(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return list;
    }

    /**
     * Helper method to map ResultSet row to CosplayDetail object
     * @param rs ResultSet positioned at a row
     * @return CosplayDetail object
     * @throws SQLException if database access error
     */
    private static CosplayDetail mapRowToCosplayDetail(ResultSet rs) throws SQLException {
        CosplayDetail detail = new CosplayDetail();
        detail.setDetailID(rs.getInt("DetailID"));
        detail.setClothingID(rs.getInt("ClothingID"));
        detail.setCharacterName(rs.getString("CharacterName"));
        detail.setSeries(rs.getString("Series"));
        detail.setCosplayType(rs.getString("CosplayType"));
        detail.setAccuracyLevel(rs.getString("AccuracyLevel"));
        detail.setAccessoryList(rs.getString("AccessoryList"));
        
        Timestamp createdAt = rs.getTimestamp("CreatedAt");
        if (createdAt != null) detail.setCreatedAt(createdAt);
        
        Timestamp updatedAt = rs.getTimestamp("UpdatedAt");
        if (updatedAt != null) detail.setUpdatedAt(updatedAt);
        
        return detail;
    }
}
