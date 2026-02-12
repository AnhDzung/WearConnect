package servlet;

import Controller.ClothingController;
import DAO.ClothingImageDAO;
import DAO.OrderIssueDAO;
import Model.Clothing;
import Model.ClothingImage;
import Model.OrderIssue;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ImageServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Support path parameter for payment proof and other uploaded files
            String pathParam = request.getParameter("path");
            if (pathParam != null && !pathParam.isEmpty()) {
                byte[] fileData = tryLoadFromDisk(pathParam);
                if (fileData != null) {
                    writeImage(response, fileData, pathParam);
                    return;
                }
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found: " + pathParam);
                return;
            }
            
            // Support issueID parameter for OrderIssue images
            String issueIdParam = request.getParameter("issueID");
            if (issueIdParam != null) {
                int issueID = Integer.parseInt(issueIdParam);
                OrderIssue issue = OrderIssueDAO.getIssueByID(issueID);
                if (issue != null && issue.getImageData() != null) {
                    writeImage(response, issue.getImageData(), issue.getImagePath());
                    return;
                }
                byte[] fileData = tryLoadFromDisk(issue != null ? issue.getImagePath() : null);
                if (fileData != null) {
                    writeImage(response, fileData, issue.getImagePath());
                    return;
                }
            }
            
            // Support imageId, imageID (from ClothingImage) or clothing id fallback
            String imageIdParam = request.getParameter("imageId");
            if (imageIdParam == null) imageIdParam = request.getParameter("imageID");
            if (imageIdParam != null) {
                int imageID = Integer.parseInt(imageIdParam);
                ClothingImage img = ClothingImageDAO.getImageByID(imageID);
                if (img != null) {
                    if (img.getImageData() != null) {
                        writeImage(response, img.getImageData(), img.getImagePath());
                        return;
                    }
                    byte[] fileData = tryLoadFromDisk(img.getImagePath());
                    if (fileData != null) {
                        writeImage(response, fileData, img.getImagePath());
                        return;
                    }
                }
            }

            int clothingID = Integer.parseInt(request.getParameter("id"));
            Clothing clothing = ClothingController.getClothingDetails(clothingID);
            
            if (clothing != null) {
                if (clothing.getImageData() != null) {
                    writeImage(response, clothing.getImageData(), clothing.getImagePath());
                } else {
                    byte[] fileData = tryLoadFromDisk(clothing.getImagePath());
                    if (fileData != null) {
                        writeImage(response, fileData, clothing.getImagePath());
                    } else {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    }
                }
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            System.out.println("Image retrieval error: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void writeImage(HttpServletResponse response, byte[] imageData, String imagePath) throws IOException {
        String lower = imagePath != null ? imagePath.toLowerCase() : "";
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
            response.setContentType("image/jpeg");
        } else if (lower.endsWith(".png")) {
            response.setContentType("image/png");
        } else if (lower.endsWith(".gif")) {
            response.setContentType("image/gif");
        } else if (lower.endsWith(".webp")) {
            response.setContentType("image/webp");
        } else if (lower.endsWith(".pdf")) {
            response.setContentType("application/pdf");
        } else {
            response.setContentType("image/jpeg");
        }
        response.setContentLength(imageData.length);
        response.getOutputStream().write(imageData);
        response.getOutputStream().flush();
    }

    // Fallback: load image bytes from webapp root + relativePath when DB binary is missing
    private byte[] tryLoadFromDisk(String relativePath) {
        if (relativePath == null || relativePath.isEmpty()) return null;
        try {
            String webRoot = getServletContext().getRealPath("/");
            if (webRoot == null) return null;

            // Normalize relativePath: remove leading slash if present
            String rel = relativePath.startsWith("/") ? relativePath.substring(1) : relativePath;

            // If caller stored path with a leading 'uploads/' (e.g. 'uploads/payment-proof/...'),
            // combining with webRoot will correctly point to <webroot>/uploads/payment-proof/...
            java.nio.file.Path p = java.nio.file.Paths.get(webRoot, rel);
            // Debug logging to help find missing files in deployed environment
            System.out.println("[ImageServlet] trying to load from disk: webRoot=" + webRoot + " rel=" + rel + " path=" + p.toString());
            if (java.nio.file.Files.exists(p)) {
                return java.nio.file.Files.readAllBytes(p);
            } else {
                System.out.println("[ImageServlet] file not found at: " + p.toString());
            }
        } catch (Exception ignored) {
        }
        return null;
    }
}
