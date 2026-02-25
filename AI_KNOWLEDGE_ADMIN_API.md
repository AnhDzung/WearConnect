# AI Knowledge Admin API (Step 4)

Endpoint quản trị tri thức nội bộ cho RAG.

## Bước 6 - Validation + Audit log

Đã bổ sung lớp bảo vệ và truy vết:

- Validate server-side:
  - `title` bắt buộc, tối đa 300 ký tự
  - `category` tối đa 50 ký tự
  - `tags` tối đa 300 ký tự
  - `content` bắt buộc, tối đa 10000 ký tự
- Mỗi thao tác `create/update/delete` sẽ ghi audit vào bảng `AIKnowledgeAuditLogs`
- Audit lưu: action, operatorID, operatorRole, summary, before/after snapshot, thời gian, ip, user-agent

### SQL cần chạy thêm cho bước 6

- `ADD_AI_KNOWLEDGE_AUDIT_LOG.sql`

## Bước 9 - Tách JavaScript dashboard

- Logic JavaScript của trang admin dashboard đã được tách ra file riêng:
  - `web/assets/js/admin-dashboard.js`
- Trong JSP chỉ còn:
  - set biến `window.WEARCONNECT_CTX`
  - include file script ngoài

Mục tiêu: giảm rủi ro lỗi JSP parser, dễ maintain và mở rộng chức năng admin.

## Bước 10 - Tách CSS dashboard

- CSS inline của trang admin dashboard đã tách ra file:
  - `web/assets/css/admin-dashboard.css`
- JSP chỉ còn link stylesheet, giảm độ dài file và dễ chỉnh giao diện.

## Bước 11 - Harden API JSON

- Endpoint `POST /admin/ai-knowledge` đã xử lý payload JSON lỗi cú pháp.
- Nếu body JSON không hợp lệ sẽ trả:
  - HTTP `400`
  - `{ "success": false, "error": "INVALID_JSON_PAYLOAD" }`
- Các lỗi auth/session cũng được trả theo format JSON thống nhất.

## Giao diện quản trị trên web

- Truy cập tab mới trong admin dashboard: `GET /admin?action=aiKnowledge`
- Tab này dùng trực tiếp API `/admin/ai-knowledge` để tạo/sửa/ẩn tài liệu.

## Endpoint

- `GET /admin/ai-knowledge`
- `POST /admin/ai-knowledge`

Yêu cầu đăng nhập session và role `Admin` hoặc `Manager`.

## 1) List docs

### Request

`GET /admin/ai-knowledge?q=hoan%20tien&includeInactive=true&limit=50`

### Response

```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "docID": 10,
      "title": "Quy trình trả đồ và hoàn tiền",
      "category": "RETURN_REFUND",
      "content": "...",
      "tags": "trả hàng,hoàn tiền",
      "isActive": true,
      "updatedBy": 1,
      "updatedAt": "24/02/2026 16:10:20"
    }
  ]
}
```

## 1.1) List audit logs

### Request

`GET /admin/ai-knowledge?action=audit&docID=10&operatorID=1&auditAction=UPDATE&limit=100`

Các filter đều optional:

- `docID`
- `operatorID`
- `auditAction` (`CREATE`, `UPDATE`, `DEACTIVATE`)
- `limit` (mặc định 100)

## 2) Get one doc

### Request

`GET /admin/ai-knowledge?docID=10`

## 3) Create doc

### Request

`POST /admin/ai-knowledge`

```json
{
  "action": "create",
  "title": "Chính sách đổi size",
  "category": "SIZE_ADVICE",
  "content": "Nội dung chính sách...",
  "tags": "size,đổi size"
}
```

## 4) Update doc

### Request

`POST /admin/ai-knowledge`

```json
{
  "action": "update",
  "docID": 10,
  "title": "Quy trình trả đồ và hoàn tiền (cập nhật)",
  "category": "RETURN_REFUND",
  "content": "Nội dung cập nhật...",
  "tags": "trả hàng,hoàn tiền,refund",
  "isActive": true
}
```

## 5) Delete doc (soft delete)

### Request

`POST /admin/ai-knowledge`

```json
{
  "action": "delete",
  "docID": 10
}
```

Hành vi thực tế: đặt `IsActive = 0` (không xóa cứng).
