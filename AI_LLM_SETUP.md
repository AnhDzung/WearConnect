# AI Chat - Step 2 (LLM Integration)

Tài liệu này hướng dẫn bật gọi LLM thật cho endpoint `/chat` đã có trong dự án.

## 1) Kiến trúc đã tích hợp

`ChatServlet` -> `AIChatController` -> `AIChatService` -> `LLMClientService`

- Nếu gọi LLM thành công: trả lời từ model (`responseSource = LLM`)
- Nếu lỗi timeout/thiếu API key/provider: tự fallback rule-based (`responseSource = RULE`)
- Nếu intent nhạy cảm hoặc confidence thấp: handoff sang nhân viên theo logic hiện có

## 2) Biến cấu hình

Đọc từ **System Property** hoặc **Environment Variable**:

- `AI_PROVIDER`: `openai` hoặc `gemini` (mặc định `openai`)
- `AI_API_KEY`: API key của provider (bắt buộc để bật LLM)
- `AI_MODEL`: model name
  - OpenAI mặc định: `gpt-4o-mini`
  - Gemini mặc định: `gemini-1.5-flash`
- `AI_ENDPOINT`: custom endpoint (optional)
- `AI_TIMEOUT_SECONDS`: timeout request (mặc định `15`)
- `AI_TEMPERATURE`: độ sáng tạo (mặc định `0.3`)
- `AI_MAX_TOKENS`: giới hạn output tokens (mặc định `450`)

## 3) Ví dụ cấu hình nhanh (Windows cmd)

### OpenAI

```cmd
set AI_PROVIDER=openai
set AI_API_KEY=sk-xxxxx
set AI_MODEL=gpt-4o-mini
```

### Gemini

```cmd
set AI_PROVIDER=gemini
set AI_API_KEY=AIzaSyxxxxx
set AI_MODEL=gemini-1.5-flash
```

## 4) Test API

### Gửi message

`POST /chat`

```json
{
  "message": "Mình muốn tư vấn size, cao 1m72 nặng 65kg",
  "conversationID": null
}
```

### Lấy lịch sử

`GET /chat?conversationID=1&limit=20`

Trong response, kiểm tra:
- `data.assistantMessage`
- `data.intent`
- `data.confidence`
- `data.redirectToAdvisor`
- `data.redirectReason`

Và trong bảng `AIMessages`, cột `ResponseSource` sẽ là `LLM` hoặc `RULE`.

## 5) Ghi chú bảo mật

- Không hardcode API key trong source code.
- Ưu tiên truyền key qua biến môi trường tại server deploy.
- Nếu cần production cứng hơn: thêm lớp mask dữ liệu cá nhân trước khi gửi model.

## 6) Step 3 - RAG knowledge context

Hệ thống đã tích hợp truy vấn tri thức nội bộ từ bảng `AIKnowledgeDocs` trước khi gọi model:

- `AIKnowledgeDAO.searchTopDocs(...)`: lấy top tài liệu active theo keyword score
- `AIKnowledgeService.buildKnowledgeContext(...)`: cắt gọn nội dung và tạo context
- `AIChatService`: gắn context vào system prompt để model ưu tiên chính sách nội bộ

Để test nhanh, chạy script mẫu:

- `AI_RAG_KNOWLEDGE_SAMPLE.sql`

Sau đó gọi lại `POST /chat` với các câu hỏi về cọc, trả hàng, size hoặc trạng thái đơn để kiểm tra chất lượng trả lời theo tri thức nội bộ.

## 7) Nâng RAG retrieval (chatbot quality)

Đã nâng logic retrieval để chatbot lấy context chính xác hơn:

- Không chỉ `LIKE` đơn giản theo cả câu.
- Chấm điểm theo nhiều trường (`title`, `tags`, `category`, `content`) với trọng số khác nhau.
- Tách token câu hỏi và bỏ stop-words để tăng độ liên quan.
- Boost theo `intent` của hội thoại (`PAYMENT_SUPPORT`, `RETURN_REFUND`, `SIZE_ADVICE`, `ORDER_SUPPORT`).
- Ưu tiên nhẹ cho tài liệu cập nhật gần đây (`UpdatedAt`).

Kết quả mong đợi: giảm lấy nhầm tài liệu, tăng độ đúng chính sách trong trả lời chatbot.

## 8) Feedback loop cho retrieval

Đã thêm vòng lặp tối ưu dựa trên phản hồi thật của user:

- Mỗi lần chatbot trả lời, hệ thống log các doc đã retrieve vào `AIRetrievalLogs`.
- API chat trả thêm:
  - `assistantMessageID`
  - `responseSource`
  - `redirectToAdvisor` (backend quyết định có cần mở trang tư vấn riêng)
  - `redirectReason`
- Client có thể gửi phản hồi chất lượng trả lời:

### Gửi feedback

`POST /chat`

```json
{
  "action": "feedback",
  "assistantMessageID": 123,
  "rating": 4,
  "isHelpful": true,
  "note": "Trả lời đúng chính sách cọc"
}
```

### SQL cần chạy

- `ADD_AI_RETRIEVAL_FEEDBACK_LOOP.sql`
