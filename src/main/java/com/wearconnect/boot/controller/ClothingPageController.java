package com.wearconnect.boot.controller;

import Controller.ClothingController;
import DAO.ClothingImageDAO;
import DAO.ColorDAO;
import DAO.CosplayDetailDAO;
import DAO.RatingDAO;
import Model.Clothing;
import Model.ClothingImage;
import Model.CosplayDetail;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

@Controller
@RequestMapping("/clothing")
public class ClothingPageController {

    // ===================== GET: Manager - My Clothing =====================

    @GetMapping(params = "action=myClothing")
    public String myClothing(HttpSession session, Model model) {
        if (!isManager(session)) return "redirect:/login";
        int managerId = getManagerId(session);
        model.addAttribute("myClothing", ClothingController.getMyClothing(managerId));
        return "manager/my-clothing";
    }

    // ===================== GET: Manager - Upload Form =====================

    @GetMapping(params = "action=upload")
    public String uploadForm(HttpSession session) {
        if (!isManager(session)) return "redirect:/login";
        return "manager/upload-clothing";
    }

    // ===================== GET: Manager - Edit Form =====================

    @GetMapping(params = {"action=edit", "id"})
    public String editForm(@RequestParam("id") int clothingId, HttpSession session, Model model) {
        if (!isManager(session)) return "redirect:/login";
        Clothing clothing = ClothingController.getClothingDetails(clothingId);
        if (clothing == null)
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found");
        model.addAttribute("clothing", clothing);
        return "manager/edit-clothing";
    }

    // ===================== GET: User - View Clothing Details =====================

    @GetMapping(params = {"action=view", "id"})
    public String viewClothing(@RequestParam("id") int clothingId, Model model) {
        Clothing clothing = ClothingController.getClothingDetails(clothingId);
        if (clothing == null)
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found");
        model.addAttribute("clothing", clothing);
        model.addAttribute("images", ClothingController.getClothingImages(clothingId));
        model.addAttribute("avgRating", RatingDAO.getAverageRatingForClothing(clothingId));
        model.addAttribute("ratings", RatingDAO.getRatingsByClothing(clothingId));
        if ("Cosplay".equals(clothing.getCategory())) {
            model.addAttribute("cosplayDetail", CosplayDetailDAO.getCosplayDetailByClothingID(clothingId));
        }
        return "user/clothing-details";
    }

    // ===================== GET: JSON Summary =====================

    @GetMapping(params = {"id", "!action"}, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> getClothingSummary(@RequestParam("id") int clothingId) {
        Clothing clothing = ClothingController.getClothingDetails(clothingId);
        if (clothing == null)
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found");
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("clothingID", clothing.getClothingID());
        response.put("clothingName", clothing.getClothingName());
        response.put("hourlyPrice", clothing.getHourlyPrice());
        response.put("dailyPrice", clothing.getDailyPrice());
        response.put("category", clothing.getCategory());
        response.put("style", clothing.getStyle());
        response.put("occasion", clothing.getOccasion());
        return response;
    }

    // ===================== POST: All POST actions =====================

    @PostMapping
    public void handlePost(HttpServletRequest request, HttpServletResponse response,
                           HttpSession session) throws IOException {
        if (!isManager(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String action = request.getParameter("action");
        if ("upload".equals(action)) {
            handleUpload(request, response, session);
        } else if ("update".equals(action)) {
            handleUpdate(request, response, session);
        } else if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing");
        }
    }

    // ===================== POST Helpers =====================

    private void handleUpload(HttpServletRequest request, HttpServletResponse response,
                              HttpSession session) throws IOException {
        int managerId = getManagerId(session);
        Clothing clothing = buildClothingFromRequest(request);
        clothing.setRenterID(managerId);

        String category = request.getParameter("category");
        if ("Cosplay".equals(category)) {
            clothing.setClothingStatus("PENDING_COSPLAY_REVIEW");
            clothing.setActive(false);
        } else {
            clothing.setClothingStatus("ACTIVE");
            clothing.setActive(true);
        }

        List<MultipartFile> images = resolveImages(request);
        if (images != null && !images.isEmpty() && !images.get(0).isEmpty()) {
            clothing.setImageData(images.get(0).getBytes());
            clothing.setImagePath(images.get(0).getOriginalFilename());
        }

        int newId = ClothingController.uploadClothing(clothing);
        if (newId > 0) {
            saveImages(images, newId);
            handleColors(request, newId, managerId);
            if ("Cosplay".equals(category)) saveCosplayDetail(request, newId, false);
        }
        response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing&uploaded=true");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response,
                              HttpSession session) throws IOException {
        int managerId = getManagerId(session);
        int clothingID;
        try {
            clothingID = Integer.parseInt(request.getParameter("clothingID"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing&error=invalid");
            return;
        }

        Clothing existing = ClothingController.getClothingDetails(clothingID);
        if (existing == null) {
            response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing&error=notfound");
            return;
        }

        Clothing clothing = buildClothingFromRequest(request);
        clothing.setClothingID(clothingID);
        clothing.setRenterID(managerId);

        List<MultipartFile> images = resolveImages(request);
        if (images != null && !images.isEmpty() && !images.get(0).isEmpty()) {
            clothing.setImageData(images.get(0).getBytes());
            clothing.setImagePath(images.get(0).getOriginalFilename());
        } else {
            clothing.setImageData(existing.getImageData());
            clothing.setImagePath(existing.getImagePath());
        }

        ClothingController.updateClothing(clothing);

        if (images != null) {
            for (int i = 1; i < images.size(); i++) {
                MultipartFile img = images.get(i);
                if (!img.isEmpty()) {
                    ClothingImage ci = new ClothingImage();
                    ci.setClothingID(clothingID);
                    ci.setImageData(img.getBytes());
                    ci.setImagePath(img.getOriginalFilename());
                    ci.setPrimary(false);
                    ClothingImageDAO.addClothingImage(ci);
                }
            }
        }

        ColorDAO.removeAllColorsFromClothing(clothingID);
        handleColors(request, clothingID, managerId);

        String category = request.getParameter("category");
        if ("Cosplay".equals(category)) {
            boolean hasDetail = CosplayDetailDAO.getCosplayDetailByClothingID(clothingID) != null;
            saveCosplayDetail(request, clothingID, hasDetail);
        }

        response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing&updated=true");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int clothingID = Integer.parseInt(request.getParameter("clothingID"));
            ClothingController.deleteClothing(clothingID);
        } catch (NumberFormatException e) {
            // ignore bad param
        }
        response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing");
    }

    // ===================== Utility Methods =====================

    private boolean isManager(HttpSession session) {
        if (session == null || session.getAttribute("account") == null) return false;
        String role = (String) session.getAttribute("userRole");
        return "Manager".equals(role != null ? role.trim() : "");
    }

    private int getManagerId(HttpSession session) {
        Object obj = session.getAttribute("accountID");
        return (obj instanceof Integer) ? (Integer) obj : Integer.parseInt(obj.toString());
    }

    private Clothing buildClothingFromRequest(HttpServletRequest request) {
        Clothing clothing = new Clothing();
        clothing.setClothingName(request.getParameter("clothingName"));
        clothing.setCategory(request.getParameter("category"));
        clothing.setStyle(request.getParameter("style"));
        clothing.setOccasion(request.getParameter("occasion"));
        clothing.setDescription(request.getParameter("description"));

        String[] sizes = request.getParameterValues("size");
        if (sizes != null && sizes.length > 0) clothing.setSize(String.join(", ", sizes));

        try { clothing.setHourlyPrice(new BigDecimal(request.getParameter("hourlyPrice"))); } catch (Exception ignored) {}
        try { clothing.setDailyPrice(new BigDecimal(request.getParameter("dailyPrice"))); } catch (Exception ignored) {}
        try { clothing.setItemValue(Double.parseDouble(request.getParameter("itemValue"))); } catch (Exception ignored) {}
        try { clothing.setQuantity(Integer.parseInt(request.getParameter("quantity"))); } catch (Exception e) { clothing.setQuantity(1); }

        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
        try { clothing.setAvailableFrom(LocalDateTime.parse(request.getParameter("availableFrom"), fmt)); } catch (Exception ignored) {}
        try { clothing.setAvailableTo(LocalDateTime.parse(request.getParameter("availableTo"), fmt)); } catch (Exception ignored) {}

        return clothing;
    }

    @SuppressWarnings("unchecked")
    private List<MultipartFile> resolveImages(HttpServletRequest request) {
        try {
            Object part = request.getAttribute(
                    org.springframework.web.multipart.support.StandardMultipartHttpServletRequest.class.getName());
            if (request instanceof org.springframework.web.multipart.MultipartHttpServletRequest) {
                return ((org.springframework.web.multipart.MultipartHttpServletRequest) request).getFiles("images");
            }
        } catch (Exception ignored) {}
        return null;
    }

    private void saveImages(List<MultipartFile> images, int clothingID) throws IOException {
        if (images == null) return;
        boolean first = true;
        for (MultipartFile img : images) {
            if (!img.isEmpty()) {
                ClothingImage ci = new ClothingImage();
                ci.setClothingID(clothingID);
                ci.setImageData(img.getBytes());
                ci.setImagePath(img.getOriginalFilename());
                ci.setPrimary(first);
                ClothingImageDAO.addClothingImage(ci);
                first = false;
            }
        }
    }

    private void handleColors(HttpServletRequest request, int clothingID, int managerId) {
        String hasOtherColor = request.getParameter("hasOtherColor");
        if ("on".equals(hasOtherColor) || "true".equals(hasOtherColor)) {
            String name = request.getParameter("customColorName");
            String hex = request.getParameter("customColorHex");
            if (name != null && !name.trim().isEmpty()) {
                int colorId = ColorDAO.upsertColor(name.trim(), hex, managerId);
                if (colorId > 0) ColorDAO.addColorToClothing(clothingID, colorId);
            }
        } else {
            String[] colorIds = request.getParameterValues("colors");
            if (colorIds != null) {
                for (String cid : colorIds) {
                    try { ColorDAO.addColorToClothing(clothingID, Integer.parseInt(cid)); } catch (Exception ignored) {}
                }
            }
        }
    }

    private void saveCosplayDetail(HttpServletRequest request, int clothingID, boolean update) {
        CosplayDetail detail = new CosplayDetail();
        detail.setClothingID(clothingID);
        detail.setCharacterName(request.getParameter("characterName"));
        detail.setSeries(request.getParameter("series"));
        detail.setCosplayType(request.getParameter("cosplayType"));
        detail.setAccuracyLevel(request.getParameter("accuracyLevel"));
        detail.setAccessoryList(request.getParameter("accessoryList"));
        if (update) {
            CosplayDetailDAO.updateCosplayDetail(detail);
        } else {
            CosplayDetailDAO.addCosplayDetail(detail);
        }
    }
}