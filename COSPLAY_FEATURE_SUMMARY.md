# Cosplay Feature Implementation Summary

## Overview
Comprehensive cosplay product management system with extended metadata, admin approval workflow, and dedicated landing page.

## Database Changes

### 1. CosplayDetail Table
**Location:** `ADD_COSPLAY_DETAIL_TABLE.sql`, `sql_database_schema.sql`

**Structure:**
```sql
CREATE TABLE CosplayDetail (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    ClothingID INT NOT NULL,
    CharacterName NVARCHAR(200) NOT NULL,
    Series NVARCHAR(200) NOT NULL,
    CosplayType NVARCHAR(50) NOT NULL, -- 'Anime', 'Game', 'Movie'
    AccuracyLevel NVARCHAR(50) NOT NULL, -- 'Cao', 'Trung bình', 'Cơ bản'
    AccessoryList NVARCHAR(MAX) NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ClothingID) REFERENCES Clothing(ClothingID) ON DELETE CASCADE
);
```

### 2. ClothingStatus Column
**Added to:** Clothing table

**Values:**
- `ACTIVE` - Normal products available for rent
- `PENDING_COSPLAY_REVIEW` - Cosplay awaiting admin approval
- `APPROVED_COSPLAY` - Admin-approved cosplay
- `INACTIVE` - Disabled products

## Backend Implementation

### 1. Model Layer
**Files Created:**
- `Model/CosplayDetail.java` - POJO for cosplay metadata

**Files Modified:**
- `Model/Clothing.java` - Added `clothingStatus` field with getter/setter

### 2. DAO Layer
**Files Created:**
- `DAO/CosplayDetailDAO.java` - Full CRUD operations:
  - `addCosplayDetail()` - Insert new cosplay detail
  - `getCosplayDetailByClothingID()` - Fetch by clothing ID
  - `updateCosplayDetail()` - Update existing detail
  - `deleteCosplayDetail()` - Remove detail
  - `searchByCharacterName()` - Search by character
  - `searchBySeries()` - Search by series/anime/game
  - `searchByType()` - Filter by Anime/Game/Movie

**Files Modified:**
- `DAO/ClothingDAO.java`:
  - `addClothing()` - Added ClothingStatus parameter (16 parameters total)
  - `mapRowToClothing()` - Extract ClothingStatus from ResultSet

### 3. Servlet Layer
**Files Created:**
- `servlet/CosplayServlet.java` - Dedicated cosplay landing page handler:
  - Filters to show only APPROVED_COSPLAY or ACTIVE status
  - Search by character name, series, or type
  - Sorting by rating, price (asc/desc)
  - Attaches CosplayDetail to each product

**Files Modified:**
- `servlet/ClothingServlet.java`:
  - Import `CosplayDetailDAO` and `CosplayDetail`
  - **Upload action:** 
    - Set status to `PENDING_COSPLAY_REVIEW` for Cosplay category
    - Capture cosplay-specific parameters (characterName, series, type, accuracy, accessories)
    - Save CosplayDetail record
    - Skip color selection for Cosplay products
  - **Update action:**
    - Update or create CosplayDetail if category is Cosplay
    - Skip color handling for Cosplay products

## Frontend Implementation

### 1. Upload Form
**File Modified:** `web/WEB-INF/jsp/manager/upload-clothing.jsp`

**Changes:**
- Added `onchange="toggleCosplayFields()"` to category dropdown
- Inserted cosplay-specific fields section (hidden by default):
  - Character Name (text input)
  - Series (text input)
  - Type (dropdown: Anime/Game/Movie)
  - Accuracy Level (dropdown: Cao/Trung bình/Cơ bản)
  - Accessory List (textarea)
- Added warning box about admin review requirement
- Color selection hidden when Cosplay category selected
- JavaScript validation:
  - `toggleCosplayFields()` - Show/hide cosplay fields, toggle required attributes
  - `validateCosplayFields()` - Ensure all cosplay fields filled
  - Updated `validateColors()` - Skip color validation for Cosplay

### 2. Edit Form
**File Modified:** `web/WEB-INF/jsp/manager/edit-clothing.jsp`

**Changes:**
- JSP scriptlet imports `CosplayDetail` and `CosplayDetailDAO`
- Fetches existing `CosplayDetail` by clothingID
- Pre-populates cosplay fields with existing data
- Same conditional UI logic as upload form
- Same JavaScript validation structure

### 3. Cosplay Landing Page
**File Created:** `web/WEB-INF/jsp/user/cosplay.jsp`

**Features:**
- Hero section with gradient background and cosplay-themed messaging
- Search panel with filters:
  - Search by: Character, Series, Type (Anime/Game/Movie)
  - Dynamic input (text or dropdown based on search type)
- Sort bar: Rating, Price Low-High, Price High-Low
- Custom cosplay product cards:
  - Full outfit image (4:5 aspect ratio)
  - Character name (bold, large)
  - Series name (muted)
  - Type badge (Anime/Game/Movie)
  - Hourly price (prominent)
  - Deposit amount with "(hoàn lại)" note
  - Rating with rental count
- Empty state message when no results
- Responsive grid layout

### 4. Header Navigation
**File Modified:** `web/WEB-INF/jsp/components/header.jsp`

**Changes:**
- Added "Cosplay & Fes" navigation link for User role
- Link: `${pageContext.request.contextPath}/cosplay`
- Positioned between "Cửa Hàng" and "Đơn Thuê Của Tôi"

### 5. Web Configuration
**File Modified:** `web/WEB-INF/web.xml`

**Changes:**
- Added CosplayServlet mapping:
  ```xml
  <servlet>
      <servlet-name>CosplayServlet</servlet-name>
      <servlet-class>servlet.CosplayServlet</servlet-class>
  </servlet>
  <servlet-mapping>
      <servlet-name>CosplayServlet</servlet-name>
      <url-pattern>/cosplay</url-pattern>
  </servlet-mapping>
  ```

## Workflow

### Manager Upload Cosplay Product:
1. Manager selects "Cosplay" from Category dropdown
2. Form reveals cosplay-specific fields (Character Name, Series, Type, Accuracy, Accessories)
3. Color selection section is hidden (not required for cosplay)
4. On submit, `ClothingServlet` sets status to `PENDING_COSPLAY_REVIEW`
5. `CosplayDetail` record created with extended metadata
6. Product not visible on public pages until admin approval

### User Browse Cosplay:
1. Click "Cosplay & Fes" in header
2. `CosplayServlet` loads only APPROVED_COSPLAY or ACTIVE status items
3. Search/filter by character name, series, or type
4. View custom product cards showing character/series/pricing
5. Click card to view full details

### Admin Review (Not Yet Implemented):
- Admin notification when cosplay uploaded
- Review checklist:
  - ✓ Có đúng là cosplay không?
  - ✓ Có đủ phụ kiện không?
  - ✓ Có ảnh thật không?
- Approve → status becomes `APPROVED_COSPLAY`
- Reject → status remains `PENDING_COSPLAY_REVIEW` (or set to INACTIVE)

## Migration Steps

To deploy this feature:

1. **Run Database Migrations:**
   ```sql
   -- Execute in order:
   ADD_COSPLAY_DETAIL_TABLE.sql
   ```

2. **Restart Application Server:**
   - Rebuild project to compile new classes
   - Deploy updated WAR file
   - Clear browser cache

3. **Verify:**
   - Manager can see cosplay fields when uploading
   - User sees "Cosplay & Fes" button in header
   - `/cosplay` route loads landing page
   - Cosplay products correctly filtered by status

## Files Created (10)
1. `ADD_COSPLAY_DETAIL_TABLE.sql` - Migration script
2. `src/java/Model/CosplayDetail.java` - Domain model
3. `src/java/DAO/CosplayDetailDAO.java` - Data access layer
4. `src/java/servlet/CosplayServlet.java` - Request handler
5. `web/WEB-INF/jsp/user/cosplay.jsp` - Landing page

## Files Modified (9)
1. `sql_database_schema.sql` - Added CosplayDetail table + ClothingStatus column
2. `src/java/Model/Clothing.java` - Add clothingStatus field
3. `src/java/DAO/ClothingDAO.java` - Handle ClothingStatus in add/map
4. `src/java/servlet/ClothingServlet.java` - Handle cosplay upload/update
5. `web/WEB-INF/jsp/manager/upload-clothing.jsp` - Cosplay fields + validation
6. `web/WEB-INF/jsp/manager/edit-clothing.jsp` - Cosplay fields + pre-population
7. `web/WEB-INF/jsp/components/header.jsp` - Add "Cosplay & Fes" link
8. `web/WEB-INF/web.xml` - Register CosplayServlet

## Key Features Implemented ✅

✅ Extended cosplay metadata (character, series, type, accuracy, accessories)  
✅ Separate CosplayDetail table with foreign key relationship  
✅ ClothingStatus field for approval workflow  
✅ Conditional form fields (show/hide based on category)  
✅ Skip color selection for cosplay products  
✅ Dedicated `/cosplay` landing page with custom design  
✅ Search by character name, series, type  
✅ Custom cosplay product cards with specialized layout  
✅ Header navigation button "Cosplay & Fes"  
✅ Filter to show only approved cosplay (APPROVED_COSPLAY or ACTIVE status)  

## Pending Implementation ⏳

⏳ Admin notification system for pending cosplay reviews  
⏳ Admin review interface with approval checklist  
⏳ Status transition from PENDING_COSPLAY_REVIEW → APPROVED_COSPLAY  
⏳ Manager notification when cosplay approved/rejected  

## Technical Notes

**Status Logic:**
- Normal products: Status = `ACTIVE` (default)
- New cosplay uploads: Status = `PENDING_COSPLAY_REVIEW`
- After admin approval: Status = `APPROVED_COSPLAY`
- Public pages (home, search) show: `IsActive = 1` (all statuses)
- Cosplay landing page shows: `Category = 'Cosplay'` AND (`Status = 'APPROVED_COSPLAY'` OR `Status = 'ACTIVE'`)

**Color Handling:**
- Cosplay products do NOT require color selection
- Color grid and custom color sections hidden when Cosplay selected
- Validation skips color checks for Cosplay category
- `ClothingServlet` skips color processing if `category.equals("Cosplay")`

**Search Strategy:**
- CosplayServlet filters at servlet level (not raw SQL WHERE clause)
- Allows future status-based filtering without schema changes
- `searchByCharacterName()`, `searchBySeries()`, `searchByType()` in DAO return all matches
- Servlet filters by status before rendering

**Responsive Design:**
- Product grid uses `repeat(auto-fill, minmax(280px, 1fr))`
- Mobile breakpoint at 768px switches to single-column search form
- Hero text shrinks from 48px to 32px on mobile
