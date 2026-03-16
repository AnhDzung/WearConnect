package com.wearconnect.boot.controller;

import Controller.ClothingController;
import DAO.ClothingImageDAO;
import DAO.OrderIssueDAO;
import DAO.PaymentDAO;
import DAO.RentalOrderDAO;
import Model.Clothing;
import Model.ClothingImage;
import Model.OrderIssue;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.io.IOException;

@Controller
@RequestMapping("/image")
public class ImagePageController {

    @GetMapping
    public void handleGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String pathParam = request.getParameter("path");
            if (pathParam != null && !pathParam.isEmpty()) {
                byte[] fileData = tryLoadFromDisk(request, pathParam);
                if (fileData != null) {
                    writeImage(response, fileData, pathParam);
                    return;
                }
                byte[] dbData = loadProofImageFromDatabase(pathParam);
                if (dbData != null) {
                    writeImage(response, dbData, pathParam);
                    return;
                }
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found: " + pathParam);
                return;
            }

            String issueIdParam = request.getParameter("issueID");
            if (issueIdParam != null) {
                int issueID = Integer.parseInt(issueIdParam);
                OrderIssue issue = OrderIssueDAO.getIssueByID(issueID);
                if (issue != null && issue.getImageData() != null) {
                    writeImage(response, issue.getImageData(), issue.getImagePath());
                    return;
                }
                byte[] fileData = tryLoadFromDisk(request, issue != null ? issue.getImagePath() : null);
                if (fileData != null) {
                    writeImage(response, fileData, issue != null ? issue.getImagePath() : null);
                    return;
                }
            }

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
                    byte[] fileData = tryLoadFromDisk(request, img.getImagePath());
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
                    byte[] fileData = tryLoadFromDisk(request, clothing.getImagePath());
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

    private byte[] tryLoadFromDisk(HttpServletRequest request, String relativePath) {
        if (relativePath == null || relativePath.isEmpty()) return null;
        try {
            String webRoot = request.getServletContext().getRealPath("/");
            if (webRoot == null) return null;
            String rel = relativePath.startsWith("/") ? relativePath.substring(1) : relativePath;
            java.nio.file.Path p = java.nio.file.Paths.get(webRoot, rel);
            System.out.println("[ImageController] trying to load from disk: webRoot=" + webRoot + " rel=" + rel + " path=" + p);
            if (java.nio.file.Files.exists(p)) {
                return java.nio.file.Files.readAllBytes(p);
            }
            System.out.println("[ImageController] file not found at: " + p);
        } catch (Exception ignored) {
        }
        return null;
    }

    private byte[] loadProofImageFromDatabase(String logicalPath) {
        byte[] paymentProof = PaymentDAO.getPaymentProofDataByPath(logicalPath);
        if (paymentProof != null) {
            return paymentProof;
        }
        return RentalOrderDAO.getAnyProofImageDataByPath(logicalPath);
    }
}
