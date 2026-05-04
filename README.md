# 👗 WearConnect

> **C2C Fashion Rental Platform** — Rent outfits, not just clothes.

WearConnect is a full-cycle C2C fashion rental platform where users can list their clothing items for rent and book outfits from other users. The platform manages the entire rental lifecycle — from discovery and booking to payment verification, shipping, returns, refunds, and AI-powered support.


---

## ✨ Key Features

### 👤 Role-Based Access
Three user roles with distinct permissions: **Admin**, **Manager**, and **User**

### 👚 Product Management
- Create rental listings with image uploads, color/size variations
- Availability tracking and status management
- Cosplay rental module with extended metadata and admin moderation

### 📦 Rental Order Lifecycle
Full workflow covering:
`Booking Request → Payment Verification → Manager Shipping → User Confirmation → Rental Tracking → Return → Refund Settlement`

### 💰 Smart Deposit System
Dynamic deposit calculation based on:
- User trust rating
- Rental duration (hourly/daily)
- Item value

### 💳 Payment & Refund Processing
- Bank transfer proof submission with admin approval/rejection
- Automated order status updates
- Late fee, damage compensation, and refund calculation based on return condition

### 🤖 AI-Powered Chat Assistant
- Intent detection for customer queries
- RAG-based knowledge retrieval from internal knowledge base
- LLM fallback strategy (OpenAI / Gemini configurable)
- Feedback logging for continuous improvement

### 🎭 Cosplay Module
- Specialized discovery page with filtering and sorting
- Admin moderation workflow for cosplay listings

### 🚨 Issue & Dispute Handling
- Report system for problematic orders
- Investigation and resolution flow with status notifications

---

## 🏗️ System Architecture

```
Controller Layer  →  Service Layer  →  DAO Layer  →  SQL Server
```

- **MVC Architecture** with clear Controller–Service–DAO separation
- **Role-based access control** with BCrypt password hashing
- **Google OAuth2** login integration
- **Event-driven notification system** syncing renters, managers, and admins
- **Centralized financial logic** for deposit, refund, and compensation rules
- **Extensible AI integration** supporting pluggable LLM providers (OpenAI/Gemini)

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Backend | Java, Spring Boot, JSP, JDBC |
| Database | SQL Server |
| Frontend | JSP, HTML/CSS, JavaScript |
| Auth | BCrypt, Google OAuth2 |
| AI Integration | OpenAI API / Gemini API, RAG-based retrieval |
| Tools | Git, GitHub, Visual Studio Code, Maven |
| Libraries | Gson, BCrypt, LLM API clients |

---

## 🚀 Getting Started

### Prerequisites
- Java 17 or newer
- SQL Server
- NetBeans IDE (recommended) or any Maven-compatible IDE

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/AnhDzung/WearConnect.git
   ```

2. **Set up the database**
   - Create a new SQL Server database
   - Run `sql_database_schema.sql` to initialize all tables
   - Run the migration `.sql` files in root if needed for additional features

3. **Configure application properties**
   - Edit `src/main/resources/application.properties`
   - Set your database connection string, credentials, and AI API keys
   - See `OAUTH2_PROPERTIES_CONFIG.txt` for Google OAuth2 setup

4. **Run the project**
   - Open the project folder containing `pom.xml` in NetBeans
   - Click **Run Project** — this executes `spring-boot:run` via embedded Tomcat
   - App starts at `http://localhost:8080`

   > If port 8080 is busy, change `server.port` in `application.properties`

### AI Chat Setup
Refer to `AI_LLM_SETUP.md` for configuring OpenAI or Gemini API keys and loading the RAG knowledge base.

---

## 📁 Project Structure

```
WearConnect/
├── src/
│   ├── main/
│   │   ├── java/          # Controllers, Services, DAOs, Models
│   │   ├── resources/     # application.properties
│   │   └── webapp/        # JSP views
├── web/                   # Static web resources
├── lib/                   # External libraries
├── sql_database_schema.sql
├── pom.xml
└── README.md
```

---

## 📊 Business Processes

**Rental Flow:**
Product Discovery → Booking Request → Deposit & Fee Calculation → Payment Submission → Admin Verification → Manager Shipping → User Confirmation → Rental Tracking

**Return & Refund Flow:**
Return Request → Return Method Selection → Manager Confirmation → Condition-Based Refund Calculation → Admin Settlement → Completion

**AI Support Flow:**
User Query → Intent Detection → Knowledge Retrieval + LLM Response → Feedback Logging

---

## 👨‍💻 Developer

**Nguyễn Đắc Anh Dũng**
Full-Stack Developer — FPT University (2021–2026)

- 📧 dadnguyen14062003@gmail.com
- 🔗 [GitHub Profile](https://github.com/AnhDzung)

---

## 📄 License

This project is built for academic purposes at FPT University.