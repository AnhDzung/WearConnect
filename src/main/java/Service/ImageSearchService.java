package Service;

import java.util.Base64;
import java.util.Collections;
import java.util.List;

import DAO.ClothingDAO;
import Model.Clothing;

public class ImageSearchService {

    public static List<Clothing> searchByImage(String base64Image) {
        // 1. Tách bỏ phần header của chuỗi Base64 (data:image/jpeg;base64,...)
        String base64Data = base64Image;
        if (base64Image.contains(",")) {
            base64Data = base64Image.split(",")[1];
        }

        // 2. Giải mã chuỗi Base64 thành mảng byte để gửi cho AI
        byte[] imageBytes = Base64.getDecoder().decode(base64Data);

        // 3. Yêu cầu Gemini phân tích hình ảnh và trả về từ khóa
        String promptText = "Bạn là một chuyên gia thời trang. Hãy phân tích trang phục chính trong bức ảnh này. " +
                "Trích xuất các từ khóa đặc trưng nhất để tìm kiếm sản phẩm tương tự, bao gồm: " +
                "loại trang phục (ví dụ: áo sơ mi, váy, áo dài, blazer...), phong cách (thanh lịch, vintage, cá tính...), và màu sắc. " +
                "LƯU Ý QUAN TRỌNG: CHỈ trả về một chuỗi các từ khóa cách nhau bằng khoảng trắng (ví dụ: áo sơ mi trắng thanh lịch). " +
                "Tuyệt đối không giải thích hay viết thêm bất kỳ câu nào khác.";
        String userPrompt = "Hãy phân tích hình ảnh này và cho tôi từ khóa.";
        
        // Gọi Gemini thông qua class LLMClientService có sẵn của dự án
        String aiKeywords = LLMClientService.generateReplyWithImage(promptText, userPrompt, imageBytes, "image/jpeg");
        
        // Log ra để bạn dễ debug xem AI đã đọc được gì từ ảnh
        System.out.println("AI Image Analysis Keywords: " + aiKeywords);

        if (aiKeywords == null || aiKeywords.isBlank()) {
            return Collections.emptyList();
        }

        // 4. Dùng từ khóa AI trả về để tìm kiếm quần áo trong DB 
        // (Tái sử dụng hàm tìm kiếm AI có sẵn trong ClothingDAO của bạn)
        return ClothingDAO.searchProductsForAI(aiKeywords, null, null, null, 10, null);
    }
}