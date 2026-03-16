# Spring Boot Migration Scaffold

Repo này hiện đã có skeleton Spring Boot chạy song song với cấu trúc Servlet/JSP cũ.

## Những gì đã được thêm

- `pom.xml` để build bằng Maven + Spring Boot.
- `src/main/java/com/wearconnect/boot/WearConnectSpringBootApplication.java` làm entry point.
- `src/main/resources/application.properties` cho cấu hình server, JSP, datasource, multipart.
- `src/main/java/com/wearconnect/boot/config/LegacyServletRegistrationConfig.java` để đăng ký các servlet cũ quan trọng trong Spring Boot.
- `src/main/java/com/wearconnect/boot/controller/HomePageController.java` chuyển route `/` và `/home` sang Spring MVC.
- `src/main/java/com/wearconnect/boot/controller/ClothingPageController.java` chuyển flow xem chi tiết sản phẩm `/clothing?action=view&id=...` và JSON `/clothing?id=...` sang Spring MVC.
- `src/main/java/com/wearconnect/boot/config/LegacyDatabaseCompatibilityConfig.java` để bridge cấu hình datasource Spring Boot sang lớp JDBC cũ.

## Cách chạy

1. Cài Maven nếu máy chưa có.
2. Kiểm tra lại thông số DB trong `src/main/resources/application.properties`.
3. Chạy lệnh:

```bash
mvn spring-boot:run
```

4. Mở:

```text
http://localhost:8080/
```

## Trạng thái hiện tại

- `src/java` vẫn được compile nguyên trạng qua Maven.
- `web` vẫn được đóng gói làm web resources/JSP như cũ.
- Một số route đã chạy bằng Spring MVC.
- Nhiều route legacy vẫn chạy qua `ServletRegistrationBean` để tránh phải migrate toàn bộ một lần.

## Bước tiếp theo nên làm

1. Chuyển `LoginServlet` và `RegisterServlet` sang `@Controller`.
2. Chuyển logic session/auth sang `HandlerInterceptor` hoặc Spring Security.
3. Thay dần `DatabaseConnection` + static DAO bằng `DataSource` hoặc `JdbcTemplate`.
4. Gom package về một root package chung như `com.wearconnect`.
5. Sau khi ổn định mới cân nhắc JPA/Hibernate.