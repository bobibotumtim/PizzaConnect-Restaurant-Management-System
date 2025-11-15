<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ page
import="models.User" %> <%@ taglib uri="http://java.sun.com/jsp/jstl/core"
prefix="c" %> <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<% User currentUser = (User) session.getAttribute("user"); String userName =
(currentUser != null) ? currentUser.getName() : "User"; %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Báo Cáo Bán Hàng - PizzaConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
      .gradient-bg {
        background: linear-gradient(
          135deg,
          #fed7aa 0%,
          #ffffff 50%,
          #fee2e2 100%
        );
      }
      .card-gradient-blue {
        background: linear-gradient(135deg, #3b82f6, #1d4ed8);
      }
      .card-gradient-green {
        background: linear-gradient(135deg, #10b981, #059669);
      }
      .card-gradient-purple {
        background: linear-gradient(135deg, #8b5cf6, #7c3aed);
      }
      .card-gradient-orange {
        background: linear-gradient(135deg, #f97316, #ea580c);
      }

      /* Expandable Sidebar Styles */
      .sidebar {
        width: 5rem;
        transition: width 0.3s ease;
      }
      .sidebar:hover {
        width: 16rem;
      }
      .sidebar-text {
        opacity: 0;
        white-space: nowrap;
        transition: opacity 0.3s ease;
      }
      .sidebar:hover .sidebar-text {
        opacity: 1;
      }

      /* Mobile responsive styles */
      @media (max-width: 768px) {
        .sidebar {
          width: 60px;
        }
        .main-content {
          padding: 16px;
        }
        .chart-container {
          height: 250px;
        }
        .form-grid {
          grid-template-columns: 1fr;
        }
        .action-buttons {
          flex-direction: column;
          gap: 8px;
        }
        .action-buttons button {
          width: 100%;
        }
      }

      @media (max-width: 640px) {
        .sidebar {
          display: none;
        }
        .main-content {
          margin-left: 0;
        }
        h1 {
          font-size: 24px;
        }
        .chart-container {
          height: 200px;
        }
      }
    </style>
  </head>
  <body class="flex h-screen bg-gray-50">
    <!-- Expandable Sidebar -->
    <div
      class="sidebar fixed left-0 top-0 h-full bg-gray-900 flex flex-col py-6 z-50 overflow-hidden"
    >
      <!-- Logo -->
      <div class="flex items-center px-4 mb-8">
        <div class="text-3xl min-w-[3rem] flex justify-center">🍕</div>
        <span class="sidebar-text ml-3 text-white text-xl font-bold"
          >PizzaConnect</span
        >
      </div>

      <!-- Navigation -->
      <nav class="flex-1 flex flex-col space-y-2 px-3">
        <a
          href="${pageContext.request.contextPath}/manager-dashboard"
          class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition"
        >
          <div class="min-w-[2.5rem] flex justify-center">
            <i data-lucide="home" class="w-6 h-6"></i>
          </div>
          <span class="sidebar-text ml-3">Dashboard</span>
        </a>

        <a
          href="${pageContext.request.contextPath}/sales-reports"
          class="flex items-center px-3 py-3 rounded-lg bg-orange-500 text-white"
        >
          <div class="min-w-[2.5rem] flex justify-center">
            <i data-lucide="file-text" class="w-6 h-6"></i>
          </div>
          <span class="sidebar-text ml-3">Sales Reports</span>
        </a>

        <a
          href="${pageContext.request.contextPath}/profile"
          class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition"
        >
          <div class="min-w-[2.5rem] flex justify-center">
            <i data-lucide="user-circle" class="w-6 h-6"></i>
          </div>
          <span class="sidebar-text ml-3">Edit Profile</span>
        </a>

        <a
          href="${pageContext.request.contextPath}/customer-feedback"
          class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition"
        >
          <div class="min-w-[2.5rem] flex justify-center">
            <i data-lucide="message-circle" class="w-6 h-6"></i>
          </div>
          <span class="sidebar-text ml-3">Customer Feedback</span>
        </a>
      </nav>
    </div>

    <!-- Top Navigation Bar -->
    <div
      class="fixed top-0 left-20 right-0 bg-white shadow-md border-b px-6 py-3 flex items-center justify-between z-40"
    >
      <div class="text-2xl font-bold text-orange-600">🍕 PizzaConnect</div>
      <div class="flex items-center gap-3">
        <div class="text-right">
          <div class="font-semibold text-gray-800"><%= userName %></div>
          <div class="text-xs text-gray-500">Manager</div>
        </div>
        <a
          href="${pageContext.request.contextPath}/logout"
          class="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 shadow-sm hover:shadow-md transition-all duration-200 flex items-center gap-2"
        >
          <i data-lucide="log-out" class="w-4 h-4"></i>
          Logout
        </a>
      </div>
    </div>

    <!-- Main Content -->
    <div class="flex-1 gradient-bg p-6 overflow-y-auto mt-16">
      <div class="max-w-7xl mx-auto">
        <!-- Header -->
        <div class="mb-8">
          <div class="flex items-center gap-3 mb-2">
            <div
              class="p-3 bg-gradient-to-br from-orange-500 to-red-500 rounded-lg shadow-lg"
            >
              <i data-lucide="file-text" class="w-8 h-8 text-white"></i>
            </div>
            <div>
              <h1 class="text-3xl font-bold text-gray-800">Báo Cáo Bán Hàng</h1>
              <p class="text-gray-600">
                Tạo và phân tích báo cáo doanh thu Pizza Store
              </p>
            </div>
          </div>
        </div>

        <!-- Error/Success Messages -->
        <c:if test="${not empty error}">
          <div
            class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6"
          >
            <strong>Lỗi:</strong> ${error}
          </div>
        </c:if>
        <c:if test="${not empty message}">
          <div
            class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-6"
          >
            <strong>Thành công:</strong> ${message}
          </div>
        </c:if>

        <!-- Report Configuration -->
        <div
          class="bg-white rounded-xl shadow-lg p-6 mb-6 border border-orange-100"
        >
          <h2
            class="text-xl font-semibold text-gray-800 mb-4 flex items-center gap-2"
          >
            <i data-lucide="calendar" class="w-5 h-5 text-orange-500"></i>
            Cấu Hình Báo Cáo
          </h2>

          <form
            id="reportForm"
            method="post"
            action="sales-reports"
            class="space-y-4"
          >
            <input type="hidden" name="action" value="generate" />
            <input
              type="hidden"
              id="exportFormat"
              name="format"
              value="excel"
            />

            <div class="form-grid grid grid-cols-1 md:grid-cols-2 gap-4">
              <!-- Date From -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2"
                  >Từ Ngày</label
                >
                <input
                  type="date"
                  name="dateFrom"
                  value="${dateFrom}"
                  required
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                />
              </div>

              <!-- Date To -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2"
                  >Đến Ngày</label
                >
                <input
                  type="date"
                  name="dateTo"
                  value="${dateTo}"
                  required
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                />
              </div>
            </div>

            <!-- Export Format & Actions -->
            <div class="mt-6 flex flex-wrap items-center gap-4">
              <div class="flex items-center gap-2">
                <span class="text-sm font-medium text-gray-700"
                  >Định dạng:</span
                >
                <div class="flex gap-2">
                  <button
                    type="button"
                    onclick="setFormat('pdf')"
                    id="pdf-btn"
                    class="px-4 py-2 rounded-lg font-medium transition-all bg-gray-100 text-gray-700 hover:bg-gray-200"
                  >
                    PDF
                  </button>
                  <button
                    type="button"
                    onclick="setFormat('excel')"
                    id="excel-btn"
                    class="px-4 py-2 rounded-lg font-medium transition-all bg-orange-500 text-white shadow-md"
                  >
                    EXCEL
                  </button>
                </div>
              </div>

              <div class="action-buttons flex gap-3 ml-auto">
                <button
                  type="submit"
                  class="flex items-center gap-2 px-6 py-2 bg-gradient-to-r from-orange-500 to-red-500 text-white rounded-lg font-medium hover:from-orange-600 hover:to-red-600 transition-all shadow-md hover:shadow-lg"
                >
                  <i data-lucide="file-text" class="w-4 h-4"></i>
                  Tạo Báo Cáo
                </button>
                <button
                  type="button"
                  onclick="exportData()"
                  class="flex items-center gap-2 px-6 py-2 bg-green-500 text-white rounded-lg font-medium hover:bg-green-600 transition-all shadow-md hover:shadow-lg"
                >
                  <i data-lucide="download" class="w-4 h-4"></i>
                  Xuất Dữ Liệu
                </button>
              </div>
            </div>
          </form>
        </div>

        <!-- Real Data Display -->
        <c:if test="${not empty reportData}">
          <!-- Summary Statistics -->
          <div
            class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6"
          >
            <div class="card-gradient-blue rounded-xl shadow-lg p-6 text-white">
              <div class="flex items-center justify-between mb-2">
                <i data-lucide="dollar-sign" class="w-8 h-8 opacity-80"></i>
              </div>
              <h3 class="text-2xl font-bold mb-1">
                <fmt:formatNumber
                  value="${reportData.totalRevenue}"
                  type="number"
                  groupingUsed="true"
                />
                ₫
              </h3>
              <p class="text-blue-100 text-sm">Tổng Doanh Thu</p>
            </div>

            <div
              class="card-gradient-green rounded-xl shadow-lg p-6 text-white"
            >
              <div class="flex items-center justify-between mb-2">
                <i data-lucide="shopping-cart" class="w-8 h-8 opacity-80"></i>
              </div>
              <h3 class="text-2xl font-bold mb-1">${reportData.totalOrders}</h3>
              <p class="text-green-100 text-sm">Tổng Đơn Hàng</p>
            </div>

            <div
              class="card-gradient-purple rounded-xl shadow-lg p-6 text-white"
            >
              <div class="flex items-center justify-between mb-2">
                <i data-lucide="users" class="w-8 h-8 opacity-80"></i>
              </div>
              <h3 class="text-2xl font-bold mb-1">
                ${reportData.totalCustomers}
              </h3>
              <p class="text-purple-100 text-sm">Khách Hàng</p>
            </div>

            <div
              class="card-gradient-orange rounded-xl shadow-lg p-6 text-white"
            >
              <div class="flex items-center justify-between mb-2">
                <i data-lucide="trending-up" class="w-8 h-8 opacity-80"></i>
              </div>
              <h3 class="text-2xl font-bold mb-1">
                <fmt:formatNumber
                  value="${reportData.avgOrderValue}"
                  type="number"
                  groupingUsed="true"
                />
                ₫
              </h3>
              <p class="text-orange-100 text-sm">Giá Trị Trung Bình</p>
            </div>
          </div>

          <!-- Data Tables -->
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- Top Products -->
            <div
              class="bg-white rounded-xl shadow-lg p-6 border border-orange-100"
            >
              <h2
                class="text-xl font-semibold text-gray-800 mb-4 flex items-center gap-2"
              >
                <i data-lucide="pie-chart" class="w-5 h-5 text-orange-500"></i>
                Top 5 Sản Phẩm Bán Chạy
              </h2>

              <div class="space-y-3">
                <c:choose>
                  <c:when test="${not empty reportData.topProducts}">
                    <c:forEach
                      var="product"
                      items="${reportData.topProducts}"
                      varStatus="status"
                    >
                      <div
                        class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-orange-50 transition-colors"
                      >
                        <div
                          class="flex-shrink-0 w-8 h-8 bg-gradient-to-br from-orange-500 to-red-500 rounded-full flex items-center justify-center text-white font-bold"
                        >
                          ${status.index + 1}
                        </div>
                        <div class="flex-1 min-w-0">
                          <p class="font-medium text-gray-800 truncate">
                            ${product.productName}
                          </p>
                          <p class="text-sm text-gray-500">
                            ${product.quantity} pizza đã bán
                          </p>
                        </div>
                        <div class="text-right">
                          <p class="font-semibold text-orange-600">
                            <fmt:formatNumber
                              value="${product.revenue}"
                              type="number"
                              groupingUsed="true"
                            />
                            ₫
                          </p>
                        </div>
                      </div>
                    </c:forEach>
                  </c:when>
                  <c:otherwise>
                    <div class="text-center py-8 text-gray-500">
                      <i
                        data-lucide="inbox"
                        class="w-12 h-12 mx-auto mb-4 text-gray-300"
                      ></i>
                      <p>
                        Không có dữ liệu sản phẩm trong khoảng thời gian này
                      </p>
                    </div>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>

            <!-- Daily Revenue Table -->
            <div
              class="bg-white rounded-xl shadow-lg p-6 border border-orange-100"
            >
              <h2
                class="text-xl font-semibold text-gray-800 mb-4 flex items-center gap-2"
              >
                <i
                  data-lucide="trending-up"
                  class="w-5 h-5 text-orange-500"
                ></i>
                Doanh Thu Theo Ngày
              </h2>

              <c:choose>
                <c:when test="${not empty reportData.dailyRevenue}">
                  <!-- Table Header -->
                  <div class="overflow-x-auto">
                    <table class="w-full">
                      <thead>
                        <tr class="border-b-2 border-gray-200">
                          <th
                            class="text-left py-3 px-4 font-semibold text-gray-700"
                          >
                            Ngày
                          </th>
                          <th
                            class="text-right py-3 px-4 font-semibold text-orange-600"
                          >
                            Doanh Thu
                          </th>
                          <th
                            class="text-center py-3 px-4 font-semibold text-blue-600"
                          >
                            Số Đơn
                          </th>
                          <th
                            class="text-right py-3 px-4 font-semibold text-green-600"
                          >
                            Trung Bình/Đơn
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                        <c:forEach
                          var="daily"
                          items="${reportData.dailyRevenue}"
                          varStatus="status"
                        >
                          <tr class="border-b border-gray-100 hover:bg-gray-50">
                            <td
                              class="py-3 px-4 text-sm font-medium text-gray-700"
                            >
                              ${daily.date}
                            </td>

                            <!-- Revenue -->
                            <td class="py-3 px-4 text-right text-sm">
                              <span class="text-orange-600 font-semibold">
                                <fmt:formatNumber
                                  value="${daily.revenue}"
                                  type="number"
                                  groupingUsed="true"
                                />₫
                              </span>
                            </td>

                            <!-- Orders -->
                            <td class="py-3 px-4 text-center text-sm">
                              <span
                                class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-700"
                              >
                                ${daily.orders} đơn
                              </span>
                            </td>

                            <!-- Average per order -->
                            <td class="py-3 px-4 text-right text-sm">
                              <c:choose>
                                <c:when test="${daily.orders > 0}">
                                  <span class="text-green-600 font-semibold">
                                    <fmt:formatNumber
                                      value="${daily.revenue / daily.orders}"
                                      type="number"
                                      groupingUsed="true"
                                      maxFractionDigits="0"
                                    />₫
                                  </span>
                                </c:when>
                                <c:otherwise>
                                  <span class="text-gray-400">-</span>
                                </c:otherwise>
                              </c:choose>
                            </td>
                          </tr>
                        </c:forEach>
                      </tbody>
                    </table>
                  </div>
                </c:when>
                <c:otherwise>
                  <div class="text-center py-8 text-gray-500">
                    <i
                      data-lucide="calendar"
                      class="w-12 h-12 mx-auto mb-4 text-gray-300"
                    ></i>
                    <p>Không có dữ liệu doanh thu trong khoảng thời gian này</p>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </c:if>

        <!-- Message when no data -->
        <c:if test="${empty reportData}">
          <div
            class="bg-blue-50 border border-blue-200 rounded-lg p-6 text-center"
          >
            <i
              data-lucide="info"
              class="w-12 h-12 text-blue-500 mx-auto mb-4"
            ></i>
            <h3 class="text-lg font-semibold text-blue-800 mb-2">
              Chưa có dữ liệu báo cáo
            </h3>
            <p class="text-blue-600 mb-4">
              Vui lòng chọn khoảng thời gian và nhấn "Tạo Báo Cáo" để xem dữ
              liệu.
            </p>
          </div>
        </c:if>

        <!-- Quick Reports -->
        <div
          class="mt-6 bg-white rounded-xl shadow-lg p-6 border border-orange-100"
        >
          <h2 class="text-xl font-semibold text-gray-800 mb-4">
            Báo Cáo Nhanh
          </h2>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
            <button
              onclick="setQuickReport('today')"
              class="flex flex-col items-center gap-2 p-4 border-2 border-gray-200 rounded-lg hover:border-orange-500 hover:bg-orange-50 transition-all group"
            >
              <i
                data-lucide="calendar"
                class="w-6 h-6 text-gray-600 group-hover:text-orange-500"
              ></i>
              <span
                class="text-sm font-medium text-gray-700 group-hover:text-orange-600 text-center"
              >
                Báo cáo hôm nay
              </span>
            </button>
            <button
              onclick="setQuickReport('week')"
              class="flex flex-col items-center gap-2 p-4 border-2 border-gray-200 rounded-lg hover:border-orange-500 hover:bg-orange-50 transition-all group"
            >
              <i
                data-lucide="trending-up"
                class="w-6 h-6 text-gray-600 group-hover:text-orange-500"
              ></i>
              <span
                class="text-sm font-medium text-gray-700 group-hover:text-orange-600 text-center"
              >
                Báo cáo tuần này
              </span>
            </button>
            <button
              onclick="setQuickReport('month')"
              class="flex flex-col items-center gap-2 p-4 border-2 border-gray-200 rounded-lg hover:border-orange-500 hover:bg-orange-50 transition-all group"
            >
              <i
                data-lucide="file-text"
                class="w-6 h-6 text-gray-600 group-hover:text-orange-500"
              ></i>
              <span
                class="text-sm font-medium text-gray-700 group-hover:text-orange-600 text-center"
              >
                Báo cáo tháng này
              </span>
            </button>
            <button
              onclick="setQuickReport('quarter')"
              class="flex flex-col items-center gap-2 p-4 border-2 border-gray-200 rounded-lg hover:border-orange-500 hover:bg-orange-50 transition-all group"
            >
              <i
                data-lucide="pie-chart"
                class="w-6 h-6 text-gray-600 group-hover:text-orange-500"
              ></i>
              <span
                class="text-sm font-medium text-gray-700 group-hover:text-orange-600 text-center"
              >
                Báo cáo quý này
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <script>
      // Initialize Lucide icons
      lucide.createIcons();

      // Mobile navigation
      const mobileMenuToggle = document.getElementById("mobile-menu-toggle");
      if (mobileMenuToggle) {
        mobileMenuToggle.addEventListener("click", function () {
          alert("Mobile menu - feature coming soon!");
        });
      }

      function showNotification(message, type) {
        // Remove existing notifications
        const existingNotifications =
          document.querySelectorAll(".notification");
        existingNotifications.forEach((n) => n.remove());

        // Create notification
        const notification = document.createElement("div");
        const bgClass =
          type === "success"
            ? "bg-green-500 text-white"
            : "bg-red-500 text-white";
        const iconName = type === "success" ? "check-circle" : "alert-circle";

        notification.className =
          "notification fixed top-4 right-4 z-50 px-6 py-4 rounded-lg shadow-lg transition-all duration-300 " +
          bgClass;
        notification.innerHTML =
          '<div class="flex items-center gap-2">' +
          '<i data-lucide="' +
          iconName +
          '" class="w-5 h-5"></i>' +
          "<span>" +
          message +
          "</span>" +
          '<button onclick="this.parentElement.parentElement.remove()" class="ml-2 hover:opacity-70">' +
          '<i data-lucide="x" class="w-4 h-4"></i>' +
          "</button>" +
          "</div>";

        document.body.appendChild(notification);
        lucide.createIcons();

        // Auto remove after 5 seconds
        setTimeout(function () {
          if (notification.parentElement) {
            notification.remove();
          }
        }, 5000);
      }

      // Helper function to format date as YYYY-MM-DD
      function formatDate(date) {
        try {
          if (!date) {
            console.error('formatDate: date is null or undefined');
            return null;
          }
          
          // Ensure it's a Date object
          let dateObj = date instanceof Date ? date : new Date(date);
          
          // Check if date is valid
          if (isNaN(dateObj.getTime())) {
            console.error('formatDate: Invalid date object:', date);
            return null;
          }
          
          // Use toISOString and extract date part (YYYY-MM-DD)
          // Adjust for timezone offset
          const year = dateObj.getFullYear();
          const month = dateObj.getMonth() + 1;
          const day = dateObj.getDate();
          
          // Format as YYYY-MM-DD
          const formatted = year + '-' + 
                           String(month).padStart(2, '0') + '-' + 
                           String(day).padStart(2, '0');
          
          console.log('formatDate:', date, '->', formatted);
          return formatted;
        } catch (error) {
          console.error('formatDate error:', error, 'for date:', date);
          return null;
        }
      }

      // Set quick report dates based on actual calendar periods
      function setQuickReport(type) {
        try {
          console.log('setQuickReport called with type:', type);
          
          if (!type) {
            console.error('setQuickReport: type parameter is missing');
            alert('Lỗi: Không xác định được loại báo cáo');
            return;
          }
          
          const today = new Date();
          console.log('Today date object:', today);
          console.log('Today is valid:', !isNaN(today.getTime()));
          
          let dateFrom, dateTo;

          switch (type) {
            case "today":
              // Today only
              dateFrom = formatDate(today);
              dateTo = formatDate(today);
              console.log('Today report:', dateFrom, 'to', dateTo);
              if (!dateFrom || !dateTo) {
                throw new Error('Không thể tính toán ngày hôm nay');
              }
              break;

            case "week":
              // This week: Monday to Sunday
              const dayOfWeek = today.getDay(); // 0 = Sunday, 1 = Monday, etc.
              const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // If Sunday, go back 6 days
              const monday = new Date(today);
              monday.setDate(today.getDate() - daysToMonday);
              monday.setHours(0, 0, 0, 0);

              const sunday = new Date(monday);
              sunday.setDate(monday.getDate() + 6);
              sunday.setHours(23, 59, 59, 999);

              dateFrom = formatDate(monday);
              dateTo = formatDate(sunday);
              console.log('Week report:', dateFrom, 'to', dateTo);
              if (!dateFrom || !dateTo) {
                throw new Error('Không thể tính toán ngày tuần này');
              }
              break;

            case "month":
              // This month: First day to last day
              const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
              firstDay.setHours(0, 0, 0, 0);
              const lastDay = new Date(
                today.getFullYear(),
                today.getMonth() + 1,
                0
              );
              lastDay.setHours(23, 59, 59, 999);

              dateFrom = formatDate(firstDay);
              dateTo = formatDate(lastDay);
              console.log('Month report:', dateFrom, 'to', dateTo);
              if (!dateFrom || !dateTo) {
                throw new Error('Không thể tính toán ngày tháng này');
              }
              break;

            case "quarter":
              // This quarter: Q1 (Jan-Mar), Q2 (Apr-Jun), Q3 (Jul-Sep), Q4 (Oct-Dec)
              const currentMonth = today.getMonth(); // 0-11
              const quarterStartMonth = Math.floor(currentMonth / 3) * 3;

              const quarterStart = new Date(
                today.getFullYear(),
                quarterStartMonth,
                1
              );
              quarterStart.setHours(0, 0, 0, 0);
              const quarterEnd = new Date(
                today.getFullYear(),
                quarterStartMonth + 3,
                0
              );
              quarterEnd.setHours(23, 59, 59, 999);

              dateFrom = formatDate(quarterStart);
              dateTo = formatDate(quarterEnd);
              console.log('Quarter report:', dateFrom, 'to', dateTo);
              if (!dateFrom || !dateTo) {
                throw new Error('Không thể tính toán ngày quý này');
              }
              break;
              
            default:
              console.error('setQuickReport: Unknown type:', type);
              alert('Lỗi: Loại báo cáo không hợp lệ');
              return;
          }

          // Update form fields immediately
          const dateFromInput = document.querySelector('input[name="dateFrom"]');
          const dateToInput = document.querySelector('input[name="dateTo"]');
          const form = document.getElementById("reportForm");
          
          console.log('Looking for elements:', {
            dateFromInput: !!dateFromInput,
            dateToInput: !!dateToInput,
            form: !!form
          });
          
          if (!dateFromInput || !dateToInput) {
            console.error('Could not find date input fields');
            alert('Lỗi: Không tìm thấy các trường ngày tháng');
            return;
          }
          
          if (!form) {
            console.error('Could not find form');
            alert('Lỗi: Không tìm thấy form');
            return;
          }
          
          // Validate dates before proceeding
          if (!dateFrom || !dateTo || dateFrom === 'undefined' || dateTo === 'undefined' || dateFrom === 'null' || dateTo === 'null') {
            console.error('Invalid dates calculated:', { dateFrom, dateTo });
            alert('Lỗi: Không thể tính toán ngày tháng. Vui lòng thử lại.');
            return;
          }
          
          console.log('Calculated dates - dateFrom:', dateFrom, 'dateTo:', dateTo);
          
          // Update the date input fields (for visual feedback)
          dateFromInput.value = dateFrom;
          dateToInput.value = dateTo;
          console.log('Updated form fields - dateFrom:', dateFrom, 'dateTo:', dateTo);
          
          // Instead of submitting form, redirect directly with GET request
          // Build a clean URL from scratch to avoid any existing invalid parameters
          const basePath = window.location.pathname;
          const redirectUrl = basePath + '?action=generate&dateFrom=' + encodeURIComponent(dateFrom) + '&dateTo=' + encodeURIComponent(dateTo);
          
          console.log('Redirecting to:', redirectUrl);
          console.log('Date values being sent:', {
            dateFrom: dateFrom,
            dateTo: dateTo,
            dateFromType: typeof dateFrom,
            dateToType: typeof dateTo
          });
          
          // Double check before redirect
          if (!dateFrom || !dateTo || dateFrom === '--' || dateTo === '--' || dateFrom === 'null' || dateTo === 'null') {
            console.error('ABORTING: Invalid dates detected before redirect:', { dateFrom, dateTo });
            alert('Lỗi: Không thể tính toán ngày tháng. Vui lòng thử lại.');
            return;
          }
          
          window.location.href = redirectUrl;
          
        } catch (error) {
          console.error('Error in setQuickReport:', error);
          alert('Lỗi khi tạo báo cáo: ' + error.message);
        }
      }
      
      // Make sure function is available globally
      window.setQuickReport = setQuickReport;
      window.formatDate = formatDate;

      // Calculate progress bar widths
      document.addEventListener("DOMContentLoaded", function () {
        const progressBars = document.querySelectorAll("[data-revenue]");
        progressBars.forEach(function (bar) {
          const revenue = parseFloat(bar.getAttribute("data-revenue")) || 0;
          const total = parseFloat(bar.getAttribute("data-total")) || 0;
          const percentage = total > 0 ? (revenue / total) * 100 : 0;
          bar.style.width = percentage + "%";
        });
        
        // Verify setQuickReport function is available
        if (typeof setQuickReport === 'function') {
          console.log('setQuickReport function is available');
        } else {
          console.error('setQuickReport function is NOT available!');
        }
        
        // Test if form and inputs exist
        const form = document.getElementById("reportForm");
        const dateFromInput = document.querySelector('input[name="dateFrom"]');
        const dateToInput = document.querySelector('input[name="dateTo"]');
        console.log('DOM elements check:', {
          form: !!form,
          dateFromInput: !!dateFromInput,
          dateToInput: !!dateToInput
        });
      });

      // Export functionality
      function setFormat(format) {
        document.getElementById("exportFormat").value = format;

        // Update button styles
        document.querySelectorAll('[id$="-btn"]').forEach((btn) => {
          btn.className =
            "px-4 py-2 rounded-lg font-medium transition-all bg-gray-100 text-gray-700 hover:bg-gray-200";
        });

        document.getElementById(format + "-btn").className =
          "px-4 py-2 rounded-lg font-medium transition-all bg-orange-500 text-white shadow-md";
      }

      function exportData() {
        const form = document.getElementById("reportForm");
        const dateFrom = form.dateFrom.value;
        const dateTo = form.dateTo.value;
        const exportFormat = document.getElementById("exportFormat").value;

        if (!dateFrom || !dateTo) {
          alert("Vui lòng chọn khoảng thời gian!");
          return;
        }

        if (new Date(dateFrom) > new Date(dateTo)) {
          alert("Ngày bắt đầu không thể lớn hơn ngày kết thúc!");
          return;
        }

        const params = new URLSearchParams({
          action: "export",
          dateFrom: dateFrom,
          dateTo: dateTo,
          format: exportFormat || "excel",
        });

        window.open(
          "${pageContext.request.contextPath}/sales-reports?" +
            params.toString(),
          "_blank"
        );
      }

      function generateReport() {
        const form = document.getElementById("reportForm");
        form.action = "${pageContext.request.contextPath}/sales-reports";
        form.method = "GET";

        const dateFrom = form.dateFrom.value;
        const dateTo = form.dateTo.value;

        if (!dateFrom || !dateTo) {
          alert("Vui lòng chọn khoảng thời gian!");
          return;
        }

        if (new Date(dateFrom) > new Date(dateTo)) {
          alert("Ngày bắt đầu không thể lớn hơn ngày kết thúc!");
          return;
        }

        form.submit();
      }

      function toggleExportDropdown() {
        const dropdown = document.getElementById("exportDropdown");
        dropdown.classList.toggle("hidden");
      }

      document.addEventListener("click", function (event) {
        const dropdown = document.getElementById("exportDropdown");
        const exportBtn = document.querySelector(".export-btn");

        if (
          exportBtn &&
          !exportBtn.contains(event.target) &&
          !dropdown.contains(event.target)
        ) {
          dropdown.classList.add("hidden");
        }
      });
    </script>
  </body>
</html>
