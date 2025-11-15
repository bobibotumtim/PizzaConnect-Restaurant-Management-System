# Top Navigation Bar Update - Manager Pages

## Overview

Đã thêm top navigation bar với user info và logout button cho tất cả trang Manager, đồng thời xóa logout button khỏi sidebar.

## Changes Made

### Before

- Logout button nằm ở cuối sidebar
- Không có user info hiển thị
- Sidebar chiếm không gian cho logout

### After

- Top navbar với user name, role và logout button
- Sidebar không còn logout button
- Giao diện giống Chef Monitor

## Top Navbar Structure

```html
<div
  class="fixed top-0 left-20 right-0 bg-white shadow-md border-b px-6 py-3 flex items-center justify-between z-40"
>
  <div class="text-2xl font-bold text-orange-600">🍕 [Page Title]</div>
  <div class="flex items-center gap-3">
    <div class="text-right">
      <div class="font-semibold text-gray-800">[User Name]</div>
      <div class="text-xs text-gray-500">Manager</div>
    </div>
    <a
      href="logout"
      class="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 ..."
    >
      <i data-lucide="log-out" class="w-4 h-4"></i>
      Logout
    </a>
  </div>
</div>
```

## Files Updated

### 1. Manager Dashboard

- **File**: `ManagerDashboard.jsp`
- **Changes**:
  - ❌ Removed logout from sidebar
  - ✅ Added top navbar with "Manager Dashboard" title
  - ✅ Shows user name and "Manager" role
  - ✅ Red logout button with icon
  - ✅ Added `mt-16` to main content for navbar spacing

### 2. Inventory Monitor

- **File**: `InventoryMonitor.jsp`
- **Changes**:
  - ❌ Removed logout from sidebar
  - ✅ Added top navbar with "Inventory Monitor" title
  - ✅ Shows user name and "Manager" role
  - ✅ Red logout button with icon
  - ✅ Added `mt-16` to main content

### 3. Sales Reports

- **File**: `GenerateSalesReports.jsp`
- **Changes**:
  - ❌ Removed logout from sidebar
  - ❌ Removed mobile menu toggle
  - ✅ Added userName variable from session
  - ✅ Added top navbar with "Sales Reports" title
  - ✅ Shows user name and "Manager" role
  - ✅ Red logout button with icon
  - ✅ Added `mt-16` to main content

### 4. Customer Feedback

- **File**: `CustomerFeedbackSimple.jsp`
- **Changes**:
  - ❌ Removed logout from sidebar
  - ✅ Added userName variable
  - ✅ Added top navbar with "Customer Feedback" title
  - ✅ Shows user name and "Manager" role
  - ✅ Red logout button with icon
  - ✅ Added `mt-16` to main content

### 5. User Profile

- **File**: `UserProfile.jsp`
- **Status**: ✅ Already has top navbar
- **No changes needed**

## Visual Layout

```
┌─────────────────────────────────────────────────────────┐
│ Sidebar │ 🍕 Page Title    User Name │ 🚪 Logout │  ← Top Navbar
│         │                   Manager  │           │
├─────────┼─────────────────────────────────────────────┤
│         │                                             │
│  🍕     │                                             │
│         │          Main Content                       │
│  Home   │                                             │
│  📦     │                                             │
│  📊     │                                             │
│  👤     │                                             │
│  💬     │                                             │
│         │                                             │
└─────────┴─────────────────────────────────────────────┘
```

## Navbar Components

### Left Side

- **Logo + Title**: 🍕 [Page Name]
- **Style**: Bold, orange color
- **Font**: 2xl (24px)

### Right Side

1. **User Info Box**:

   - User name (bold, gray-800)
   - Role "Manager" (small, gray-500)
   - Right-aligned text

2. **Logout Button**:
   - Red background (bg-red-500)
   - White text
   - Rounded corners
   - Logout icon (Lucide)
   - Hover effect (darker red)
   - Shadow on hover

## CSS Classes Used

### Navbar Container

```css
fixed top-0 left-20 right-0
bg-white shadow-md border-b
px-6 py-3
flex items-center justify-between
z-40
```

### User Info

```css
text-right
font-semibold text-gray-800  /* Name */
text-xs text-gray-500        /* Role */
```

### Logout Button

```css
bg-red-500 text-white
px-4 py-2 rounded-lg
hover:bg-red-600
shadow-sm hover:shadow-md
transition-all duration-200
flex items-center gap-2
```

### Main Content Adjustment

```css
mt-16  /* Top margin for navbar */
```

## Benefits

### 1. Consistency

- All Manager pages have same navbar style
- Matches Chef Monitor design
- Unified user experience

### 2. Better UX

- User info always visible
- Easy access to logout
- Clear page identification

### 3. Space Efficiency

- Sidebar more compact
- No logout taking space
- More room for navigation items

### 4. Professional Look

- Modern top navbar design
- Clean separation of concerns
- Better visual hierarchy

## User Info Display

| Page              | Title                | User Name | Role    |
| ----------------- | -------------------- | --------- | ------- |
| Manager Dashboard | 🍕 Manager Dashboard | [Dynamic] | Manager |
| Inventory Monitor | 🍕 Inventory Monitor | [Dynamic] | Manager |
| Sales Reports     | 🍕 Sales Reports     | [Dynamic] | Manager |
| Customer Feedback | 🍕 Customer Feedback | [Dynamic] | Manager |
| User Profile      | 🍕 PizzaConnect      | [Dynamic] | Manager |

## Sidebar Changes

### Before

```
🍕 PizzaConnect
├─ Home
├─ Inventory
├─ Sales Reports
├─ Edit Profile
├─ Customer Feedback
└─ 🚪 Logout  ← Removed
```

### After

```
🍕 PizzaConnect
├─ Home
├─ Inventory
├─ Sales Reports
├─ Edit Profile
└─ Customer Feedback
```

## Z-Index Layers

- Sidebar: `z-50` (highest)
- Top Navbar: `z-40` (below sidebar)
- Main Content: default (lowest)

This ensures sidebar can expand over navbar when hovered.

## Responsive Behavior

- Navbar is `fixed` at top
- Adjusts to sidebar width (left-20 = 5rem)
- Expands full width to right edge
- User info and logout always visible

## Testing Checklist

- [x] Manager Dashboard - Navbar displays correctly
- [x] Inventory Monitor - Navbar displays correctly
- [x] Sales Reports - Navbar displays correctly
- [x] Customer Feedback - Navbar displays correctly
- [x] User Profile - Already had navbar
- [x] Logout button works on all pages
- [x] User name displays correctly
- [x] Role shows "Manager"
- [x] Sidebar no longer has logout
- [x] Main content has proper spacing (mt-16)

## Notes

- All pages use same navbar structure
- User name pulled from session
- Role hardcoded as "Manager" (could be dynamic)
- Logout icon from Lucide library
- Red color for logout (danger action)
- Navbar fixed position for always visible

## Future Enhancements

- Dynamic role display (Admin/Manager/etc.)
- Notification bell icon
- User avatar/profile picture
- Dropdown menu for user actions
- Dark mode toggle
