# 🍕 Customer Menu Feature

## 📋 Overview

This feature allows customers to view the restaurant menu with all products, sizes, and prices from the database when they log in.

## 🎯 Features

### 1. Customer Home Page (`/home`)
- **Hero Carousel**: Rotating banner with promotional content
- **Featured Products**: Display of 6 featured products with sizes and prices
- **Category Preview**: Quick access to browse products by category
- **Responsive Design**: Mobile-friendly layout

### 2. Customer Menu Page (`/customer-menu`)
- **Full Product Catalog**: All available products from the database
- **Category Filter**: Filter products by Pizza, Drink, Topping, etc.
- **Product Details**: 
  - Product name and description
  - Product image
  - Available sizes (S, M, L, F)
  - Price for each size
  - Availability status
- **Price Display**: Formatted in Vietnamese Dong (₫)
- **Responsive Grid**: Adapts to different screen sizes

## 🔐 Access

**Customer Login:**
- Phone: `0909000004` (Le Van C)
- Password: `123`

After login, customers are automatically redirected to the home page with the menu.

## 🗂️ Files Created/Modified

### New Files:
1. `Login/src/java/controller/CustomerMenuServlet.java` - Handles menu display logic
2. `Login/web/view/CustomerMenu.jsp` - Full menu page with filters

### Modified Files:
1. `Login/src/java/controller/HomeServlet.java` - Updated to load products with sizes
2. `Login/web/view/Home.jsp` - Enhanced to display products with prices
3. `Login/src/java/controller/LoginServlet.java` - Redirect customers to home servlet
4. `Login/web/WEB-INF/web.xml` - Added CustomerMenuServlet mapping

## 📊 Database Integration

The menu displays data from:
- **Product** table: Product information
- **ProductSize** table: Available sizes and prices
- **Category** table: Product categories

### Sample Data (from ScriptForHieuV5.sql):

**Products:**
- Hawaiian Pizza (S: 120,000₫, M: 160,000₫, L: 200,000₫)
- Iced Milk Coffee (Fixed: 25,000₫)
- Peach Orange Tea (Fixed: 30,000₫)
- Extra Cheese Topping (Fixed: 15,000₫)
- Sausage Topping (Fixed: 20,000₫)

## 🎨 UI Features

### Design Elements:
- **Tailwind CSS**: Modern, responsive styling
- **Lucide Icons**: Clean, professional icons
- **Gradient Backgrounds**: Eye-catching product cards
- **Hover Effects**: Interactive card animations
- **Color-coded Sizes**: 
  - Small (S): Blue
  - Medium (M): Green
  - Large (L): Purple
  - Fixed (F): Gray

### Navigation:
- Sidebar navigation (inherited from existing layout)
- Top navigation bar
- Category filter buttons
- "View Full Menu" links

## 🔄 User Flow

```
1. Customer logs in with phone/password
   ↓
2. System validates credentials
   ↓
3. Redirect to /home (HomeServlet)
   ↓
4. Load products with sizes from database
   ↓
5. Display Home.jsp with featured products
   ↓
6. Customer clicks "View Full Menu" or category
   ↓
7. Navigate to /customer-menu (CustomerMenuServlet)
   ↓
8. Display CustomerMenu.jsp with all products
   ↓
9. Customer can filter by category
   ↓
10. Click "Order" button (ready for future cart feature)
```

## 🚀 URLs

- **Home Page**: `http://localhost:8080/Login/home`
- **Full Menu**: `http://localhost:8080/Login/customer-menu`
- **Filter by Category**: `http://localhost:8080/Login/customer-menu?category=Pizza`

## 📱 Responsive Breakpoints

- **Mobile**: 1 column grid
- **Tablet (md)**: 2 columns grid
- **Desktop (lg)**: 3 columns grid

## 🔮 Future Enhancements

1. **Shopping Cart**: Add products to cart
2. **Product Details Modal**: View detailed product information
3. **Search Functionality**: Search products by name
4. **Favorites**: Save favorite products
5. **Reviews & Ratings**: Customer reviews
6. **Order History**: View past orders
7. **Loyalty Points**: Display and use loyalty points
8. **Real-time Availability**: Check ingredient stock

## 🐛 Testing

### Test Cases:
1. ✅ Login as customer → Should redirect to home
2. ✅ Home page displays featured products with prices
3. ✅ Click "View Full Menu" → Navigate to customer-menu
4. ✅ Filter by category → Display filtered products
5. ✅ All prices display in Vietnamese Dong format
6. ✅ Product images display correctly
7. ✅ Responsive design works on mobile/tablet/desktop

### Test Data:
Use the sample data from `ScriptForHieuV5.sql`:
- 5 products (1 Pizza, 2 Drinks, 2 Toppings)
- Multiple sizes per product
- Different price ranges

## 📝 Notes

- The menu only displays products where `IsAvailable = 1`
- Categories with `IsDeleted = 1` are excluded
- Product sizes with `IsDeleted = 1` are excluded
- Prices are formatted using Vietnamese locale
- All text is in English (can be localized later)

---

**Created**: 2025-01-09  
**Version**: 1.0  
**Author**: Pizza Store Development Team
