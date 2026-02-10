package servlet;

import Controller.ClothingController;
import DAO.ColorDAO;
import DAO.RatingDAO;
import Model.Clothing;
import Model.ClothingImage;
import Model.Color;
import Model.Rating;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;
import java.util.Collection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@MultipartConfig
public class ClothingServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("[ClothingServlet] doGet called - URI: " + request.getRequestURI() + " - Query: " + request.getQueryString());
        HttpSession session = request.getSession(false);
        String action = request.getParameter("action");
        System.out.println("[ClothingServlet] action=" + action + ", id=" + request.getParameter("id"));
        
        // API endpoint to get product details as JSON
        if (action == null && request.getParameter("id") != null) {
            try {
                int clothingID = Integer.parseInt(request.getParameter("id"));
                Clothing clothing = ClothingController.getClothingDetails(clothingID);
                
                if (clothing != null) {
                    // Build JSON string manually
                    String json = "{" +
                        "\"clothingID\":" + clothing.getClothingID() + "," +
                        "\"clothingName\":\"" + escapeJson(clothing.getClothingName()) + "\"," +
                        "\"hourlyPrice\":" + clothing.getHourlyPrice() + "," +
                        "\"dailyPrice\":" + clothing.getDailyPrice() + "," +
                        "\"category\":\"" + escapeJson(clothing.getCategory()) + "\"" +
                    "}";
                    
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().print(json);
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                }
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        }
        
        // Allow viewing product details without login
        if ("view".equals(action)) {
            System.out.println("[ClothingServlet] Handling view action");
            try {
                String idParam = request.getParameter("id");
                System.out.println("[ClothingServlet] idParam: " + idParam);
                if (idParam == null || idParam.isEmpty()) {
                    System.err.println("[ClothingServlet] ID parameter is missing or empty");
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing ID parameter");
                    return;
                }
                
                int clothingID = Integer.parseInt(idParam);
                System.out.println("[ClothingServlet] Getting details for clothingID: " + clothingID);
                Clothing clothing = ClothingController.getClothingDetails(clothingID);
                System.out.println("[ClothingServlet] Got clothing: " + (clothing != null ? "YES" : "NULL"));
                if (clothing == null) {
                    System.out.println("[ClothingServlet] Clothing is null, sending 404");
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
                    return;
                }
                request.setAttribute("clothing", clothing);
                request.setAttribute("images", ClothingController.getClothingImages(clothingID));
                request.setAttribute("avgRating", RatingDAO.getAverageRatingForClothing(clothingID));
                request.setAttribute("ratings", RatingDAO.getRatingsByClothing(clothingID));
                System.out.println("[ClothingServlet] Forwarding to clothing-details.jsp");
                request.getRequestDispatcher("/WEB-INF/jsp/user/clothing-details.jsp").forward(request, response);
                return;
            } catch (NumberFormatException nfe) {
                System.err.println("[ClothingServlet] NumberFormatException: " + nfe.getMessage());
                nfe.printStackTrace();
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID format");
                return;
            } catch (Exception e) {
                System.err.println("[ClothingServlet] Exception in view action: " + e.getMessage());
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error: " + e.getMessage());
                return;
            }
        }
        
        // Check session for other actions
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        int renterID = (int) session.getAttribute("accountID");
        
        if ("myClothing".equals(action)) {
            List<Clothing> myClothing = ClothingController.getMyClothing(renterID);
            request.setAttribute("myClothing", myClothing);
            request.getRequestDispatcher("/WEB-INF/jsp/manager/my-clothing.jsp").forward(request, response);
        } else if ("upload".equals(action)) {
            request.getRequestDispatcher("/WEB-INF/jsp/manager/upload-clothing.jsp").forward(request, response);
        } else if ("edit".equals(action)) {
            try {
                int clothingID = Integer.parseInt(request.getParameter("id"));
                Clothing clothing = ClothingController.getClothingDetails(clothingID);
                request.setAttribute("clothing", clothing);
                request.setAttribute("images", ClothingController.getClothingImages(clothingID));
                request.getRequestDispatcher("/WEB-INF/jsp/manager/edit-clothing.jsp").forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int renterID = (int) session.getAttribute("accountID");
        String action = request.getParameter("action");

        if ("upload".equals(action)) {
            String clothingName = request.getParameter("clothingName");
            String category = request.getParameter("category");
            String style = request.getParameter("style");
            String size = request.getParameter("size");
            String description = request.getParameter("description");
            String hourlyPriceStr = request.getParameter("hourlyPrice");
            String dailyPriceStr = request.getParameter("dailyPrice");
            String depositAmountStr = request.getParameter("depositAmount");
            String quantityStr = request.getParameter("quantity");
            String availableFromStr = request.getParameter("availableFrom");
            String availableToStr = request.getParameter("availableTo");

            try {
                double hourlyPrice = Double.parseDouble(hourlyPriceStr);
                double dailyPrice = dailyPriceStr != null && !dailyPriceStr.isEmpty()
                        ? Double.parseDouble(dailyPriceStr)
                        : hourlyPrice * 24;

                if (hourlyPrice < 10000 || hourlyPrice > 99999999.99 || dailyPrice < 10000 || dailyPrice > 99999999.99) {
                    response.sendRedirect(request.getContextPath() + "/clothing?action=upload&error=price");
                    return;
                }

                LocalDateTime availableFrom = LocalDateTime.parse(availableFromStr);
                LocalDateTime availableTo = LocalDateTime.parse(availableToStr);
                if (availableFrom.isAfter(availableTo)) {
                    response.sendRedirect(request.getContextPath() + "/clothing?action=upload&error=date");
                    return;
                }

                String imagePath = "images/default.jpg";
                byte[] imageData = null;
                List<ClothingImage> imagesToSave = new ArrayList<>();
                try {
                    Collection<Part> parts = request.getParts();
                    List<Part> imageParts = new ArrayList<>();
                    for (Part part : parts) {
                        if ("images".equals(part.getName()) && part.getSize() > 0) {
                            imageParts.add(part);
                        }
                    }

                    if (!imageParts.isEmpty()) {
                        for (int i = 0; i < imageParts.size(); i++) {
                            Part p = imageParts.get(i);
                            String fileName = p.getSubmittedFileName();
                            byte[] data = readBytes(p.getInputStream(), (int) p.getSize());
                            String storedName = System.currentTimeMillis() + "_" + fileName;

                            if (i == 0) {
                                imagePath = storedName;
                                imageData = data;
                            }

                            ClothingImage ci = new ClothingImage();
                            ci.setImagePath(storedName);
                            ci.setImageData(data);
                            ci.setPrimary(i == 0);
                            imagesToSave.add(ci);
                        }
                    }
                } catch (Exception e) {
                    System.out.println("File upload error: " + e.getMessage());
                    e.printStackTrace();
                    imagePath = "images/default.jpg";
                    imageData = null;
                }

                int quantity = 1;
                try {
                    quantity = Integer.parseInt(quantityStr);
                    if (quantity < 1) quantity = 1;
                    if (quantity > 1000) quantity = 1000;
                } catch (Exception e) {
                    quantity = 1;
                }

                double depositAmount = 0;
                try {
                    depositAmount = Double.parseDouble(depositAmountStr);
                    if (depositAmount < 0) depositAmount = 0;
                    if (depositAmount > 99999999.99) depositAmount = 99999999.99;
                } catch (Exception e) {
                    depositAmount = dailyPrice * 0.2;
                }

                Clothing clothing = new Clothing();
                clothing.setRenterID(renterID);
                clothing.setClothingName(clothingName);
                clothing.setCategory(category);
                clothing.setStyle(style);
                clothing.setSize(size);
                clothing.setDescription(description);
                clothing.setHourlyPrice(hourlyPrice);
                clothing.setDailyPrice(dailyPrice);
                clothing.setImagePath(imagePath);
                clothing.setImageData(imageData);
                clothing.setAvailableFrom(availableFrom);
                clothing.setAvailableTo(availableTo);
                clothing.setQuantity(quantity);
                clothing.setDepositAmount(depositAmount);

                int clothingID = ClothingController.uploadClothing(clothing);
                if (clothingID > 0) {
                    // Handle colors
                    String[] selectedColors = request.getParameterValues("colors");
                    if (selectedColors != null) {
                        for (String colorIDStr : selectedColors) {
                            try {
                                int colorID = Integer.parseInt(colorIDStr);
                                ColorDAO.addColorToClothing(clothingID, colorID);
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }

                    // Handle custom color
                    String hasOtherColor = request.getParameter("hasOtherColor");
                    if ("on".equals(hasOtherColor)) {
                        String customColorName = request.getParameter("customColorName");
                        String customColorHex = request.getParameter("customColorHex");
                        
                        if (customColorName != null && !customColorName.trim().isEmpty()) {
                            int customColorID = ColorDAO.upsertColor(customColorName, customColorHex, renterID);
                            if (customColorID > 0) {
                                ColorDAO.addColorToClothing(clothingID, customColorID);
                            }
                        }
                    }

                    if (!imagesToSave.isEmpty()) {
                        for (ClothingImage ci : imagesToSave) {
                            ci.setClothingID(clothingID);
                            ClothingController.addClothingImage(ci);
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing&success=true");
                } else {
                    response.sendRedirect(request.getContextPath() + "/clothing?action=upload&error=true");
                }
            } catch (Exception e) {
                System.out.println("EXCEPTION: " + e.getMessage());
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/clothing?action=upload&error=true");
            }
        } else if ("update".equals(action)) {
            try {
                int clothingID = Integer.parseInt(request.getParameter("clothingID"));
                Clothing clothing = ClothingController.getClothingDetails(clothingID);
                if (clothing == null) {
                    response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing&error=notfound");
                    return;
                }

                String clothingName = request.getParameter("clothingName");
                String category = request.getParameter("category");
                String style = request.getParameter("style");
                String size = request.getParameter("size");
                String description = request.getParameter("description");
                String hourlyPriceStr = request.getParameter("hourlyPrice");
                String dailyPriceStr = request.getParameter("dailyPrice");
                String depositAmountStr = request.getParameter("depositAmount");
                String quantityStr = request.getParameter("quantity");
                String availableFromStr = request.getParameter("availableFrom");
                String availableToStr = request.getParameter("availableTo");

                double hourlyPrice = Double.parseDouble(hourlyPriceStr);
                double dailyPrice = dailyPriceStr != null && !dailyPriceStr.isEmpty()
                        ? Double.parseDouble(dailyPriceStr)
                        : hourlyPrice * 24;

                if (hourlyPrice < 10000 || hourlyPrice > 99999999.99 || dailyPrice < 10000 || dailyPrice > 99999999.99) {
                    response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing&error=price");
                    return;
                }

                LocalDateTime availableFrom = LocalDateTime.parse(availableFromStr);
                LocalDateTime availableTo = LocalDateTime.parse(availableToStr);
                if (availableFrom.isAfter(availableTo)) {
                    response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing&error=date");
                    return;
                }

                int quantity = 1;
                try {
                    quantity = Integer.parseInt(quantityStr);
                    if (quantity < 1) quantity = 1;
                    if (quantity > 1000) quantity = 1000;
                } catch (Exception e) {
                    quantity = 1;
                }

                double depositAmount = 0;
                try {
                    depositAmount = Double.parseDouble(depositAmountStr);
                    if (depositAmount < 0) depositAmount = 0;
                    if (depositAmount > 99999999.99) depositAmount = 99999999.99;
                } catch (Exception e) {
                    depositAmount = dailyPrice * 0.2;
                }

                List<ClothingImage> imagesToSave = new ArrayList<>();
                String imagePath = clothing.getImagePath();
                byte[] imageData = clothing.getImageData();
                try {
                    Collection<Part> parts = request.getParts();
                    List<Part> imageParts = new ArrayList<>();
                    for (Part part : parts) {
                        if ("images".equals(part.getName()) && part.getSize() > 0) {
                            imageParts.add(part);
                        }
                    }

                    if (!imageParts.isEmpty()) {
                        for (int i = 0; i < imageParts.size(); i++) {
                            Part p = imageParts.get(i);
                            String fileName = p.getSubmittedFileName();
                            byte[] data = readBytes(p.getInputStream(), (int) p.getSize());
                            String storedName = System.currentTimeMillis() + "_" + fileName;

                            if (i == 0) {
                                imagePath = storedName;
                                imageData = data;
                            }

                            ClothingImage ci = new ClothingImage();
                            ci.setImagePath(storedName);
                            ci.setImageData(data);
                            ci.setPrimary(i == 0);
                            imagesToSave.add(ci);
                        }
                    }
                } catch (Exception e) {
                    System.out.println("File upload error: " + e.getMessage());
                    e.printStackTrace();
                }

                clothing.setClothingName(clothingName);
                clothing.setCategory(category);
                clothing.setStyle(style);
                clothing.setSize(size);
                clothing.setDescription(description);
                clothing.setHourlyPrice(hourlyPrice);
                clothing.setDailyPrice(dailyPrice);
                clothing.setAvailableFrom(availableFrom);
                clothing.setAvailableTo(availableTo);
                clothing.setQuantity(quantity);
                clothing.setDepositAmount(depositAmount);
                clothing.setImagePath(imagePath);
                clothing.setImageData(imageData);

                if (ClothingController.updateClothing(clothing)) {
                    // Handle colors - remove old colors and add new ones
                    String[] selectedColors = request.getParameterValues("colors");
                    ColorDAO.removeAllColorsFromClothing(clothingID);
                    
                    // Add selected colors
                    if (selectedColors != null) {
                        for (String colorIDStr : selectedColors) {
                            try {
                                int colorID = Integer.parseInt(colorIDStr);
                                ColorDAO.addColorToClothing(clothingID, colorID);
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }

                    // Handle custom color
                    String hasOtherColor = request.getParameter("hasOtherColor");
                    if ("on".equals(hasOtherColor)) {
                        String customColorName = request.getParameter("customColorName");
                        String customColorHex = request.getParameter("customColorHex");
                        
                        if (customColorName != null && !customColorName.trim().isEmpty()) {
                            int customColorID = ColorDAO.upsertColor(customColorName, customColorHex, renterID);
                            if (customColorID > 0) {
                                ColorDAO.addColorToClothing(clothingID, customColorID);
                            }
                        }
                    }

                    if (!imagesToSave.isEmpty()) {
                        ClothingController.clearPrimaryImages(clothingID);
                        for (ClothingImage ci : imagesToSave) {
                            ci.setClothingID(clothingID);
                            ClothingController.addClothingImage(ci);
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing&success=true");
                } else {
                    response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing&error=true");
                }
            } catch (Exception e) {
                System.out.println("UPDATE EXCEPTION: " + e.getMessage());
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing&error=true");
            }
        } else if ("delete".equals(action)) {
            int clothingID = Integer.parseInt(request.getParameter("clothingID"));
            if (ClothingController.deleteClothing(clothingID)) {
                response.sendRedirect(request.getContextPath() + "/clothing?action=myClothing&success=true");
            }
        }
    }

    // Helper method to escape JSON special characters
    private static String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }

    // Read bytes safely
    private static byte[] readBytes(InputStream is, int size) throws IOException {
        byte[] data = new byte[size];
        int offset = 0;
        while (offset < size) {
            int read = is.read(data, offset, size - offset);
            if (read == -1) break;
            offset += read;
        }
        is.close();
        return data;
    }
}
