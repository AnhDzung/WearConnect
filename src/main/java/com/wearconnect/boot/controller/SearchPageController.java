package com.wearconnect.boot.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import Controller.ClothingController;
import Model.Clothing;
import Service.ImageSearchService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller
@RequestMapping("/search")
public class SearchPageController {

    @GetMapping
    public void search(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchType = request.getParameter("type");
        String query = request.getParameter("query");
        List<Clothing> results;

        if ("category".equals(searchType)) {
            results = ClothingController.searchByCategory(query);
        } else if ("style".equals(searchType)) {
            results = ClothingController.searchByStyle(query);
        } else if ("occasion".equals(searchType)) {
            results = ClothingController.searchByOccasion(query);
        } else {
            results = ClothingController.getAllClothing();
        }

        request.setAttribute("searchResults", results);
        request.setAttribute("searchType", searchType);
        request.setAttribute("query", query);
        request.setAttribute("searchMessage", null);
        request.getRequestDispatcher("/WEB-INF/jsp/user/search-results.jsp").forward(request, response);
    }

    @PostMapping
    public void searchByImage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Clothing> results = new ArrayList<>();
        String searchMessage;
        String cameraImageData = request.getParameter("cameraImageData");
        MultipartFile imageFile = resolveImageFile(request);

        try {
            if (cameraImageData != null && !cameraImageData.isBlank()) {
                results = ImageSearchService.searchByImage(cameraImageData);
                searchMessage = results.isEmpty()
                    ? "AI không tìm thấy sản phẩm nào trên hệ thống khớp với ảnh bạn vừa chụp."
                    : "AI đã phân tích ảnh và tìm thấy các sản phẩm tương tự dưới đây.";
            } else if (imageFile != null && !imageFile.isEmpty()) {
                String base64Image = Base64.getEncoder().encodeToString(imageFile.getBytes());
                results = ImageSearchService.searchByImage(base64Image);
                searchMessage = results.isEmpty()
                    ? "AI không tìm thấy sản phẩm nào trên hệ thống khớp với ảnh bạn tải lên."
                    : "AI đã phân tích ảnh và tìm thấy các sản phẩm tương tự dưới đây.";
            } else {
                searchMessage = "Vui lòng mở camera hoặc tải ảnh lên để tìm kiếm.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            searchMessage = "Xin lỗi, đã xảy ra lỗi trong quá trình AI phân tích hình ảnh.";
        }

        request.setAttribute("searchResults", results);
        request.setAttribute("searchType", "image");
        request.setAttribute("query", imageFile != null ? imageFile.getOriginalFilename() : "camera");
        request.setAttribute("searchMessage", searchMessage);
        request.getRequestDispatcher("/WEB-INF/jsp/user/search-results.jsp").forward(request, response);
    }

    private MultipartFile resolveImageFile(HttpServletRequest request) {
        if (request instanceof MultipartHttpServletRequest) {
            return ((MultipartHttpServletRequest) request).getFile("image");
        }
        return null;
    }

    private byte[] resolveCameraBytes(String cameraImageData) {
        if (cameraImageData == null || cameraImageData.isBlank()) {
            return null;
        }

        try {
            String payload = cameraImageData;
            int markerIndex = cameraImageData.indexOf(",");
            if (markerIndex >= 0 && markerIndex < cameraImageData.length() - 1) {
                payload = cameraImageData.substring(markerIndex + 1);
            }
            return Base64.getDecoder().decode(payload);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }
}
