<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ taglib
uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> <%@ taglib
uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
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
        <div class="text-orange-500 text-3xl min-w-[3rem] flex justify-center">
          <i data-lucide="pizza" class="w-10 h-10"></i>
        </div>
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

      <!-- Logout -->
      <div class="px-3">
        <a
          href="${pageContext.request.contextPath}/logout"
          class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-red-600 hover:text-white transition"
        >
          <div class="min-w-[2.5rem] flex justify-center">
            <i data-lucide="log-out" class="w-6 h-6"></i>
          </div>
          <span class="sidebar-text ml-3">Logout</span>
        </a>
      </div>
    </div>

    <!-- Mobile Navigation Toggle -->
    <div class="md:hidden fixed top-4 left-4 z-50">
      <button
        id="mobile-menu-toggle"
        class="p-2 bg-orange-500 text-white rounded-lg shadow-lg hover:bg-orange-600 transition-colors"
      >
        <i data-lucide="menu" class="w-6 h-6"></i>
      </button>
    </div>

    <!-- Main Content -->
    <div class="flex-1 gradient-bg p-6 overflow-y-auto">
      <div class="max-w-7xl mx-auto">
        <!-- Breadcrumb -->
        <nav class="flex mb-4" aria-label="Breadcrumb">
          <ol class="inline-flex items-center space-x-1 md:space-x-3">
            <li class="inline-flex items-center">
              <a
                href="${pageContext.request.contextPath}/dashboard"
                class="inline-flex items-center text-sm font-medium text-gray-700 hover:text-orange-600"
              >
                <i data-lucide="home" class="w-4 h-4 mr-2"></i>
                Dashboard
              </a>
            </li>
            <li>
              <div class="flex items-center">
                <i
                  data-lucide="chevron-right"
                  class="w-4 h-4 text-gray-400"
                ></i>
                <span class="ml-1 text-sm font-medium text-orange-600 md:ml-2"
                  >Báo Cáo Bán Hàng</span
                >
              </div>
            </li>
          </ol>
        </nav>

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
                <span
                  class="text-sm font-medium bg-white bg-opacity-20 px-3 py-1 rounded-full"
                >
                  <fmt:formatNumber
                    value="${reportData.growthRate}"
                    pattern="+#.#;-#.#"
                  />%
                </span>
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
                <span
                  class="text-sm font-medium bg-white bg-opacity-20 px-3 py-1 rounded-full"
                  >+8.3%</span
                >
              </div>
              <h3 class="text-2xl font-bold mb-1">${reportData.totalOrders}</h3>
              <p class="text-green-100 text-sm">Tổng Đơn Hàng</p>
            </div>

            <div
              class="card-gradient-purple rounded-xl shadow-lg p-6 text-white"
            >
              <div class="flex items-center justify-between mb-2">
                <i data-lucide="users" class="w-8 h-8 opacity-80"></i>
                <span
                  class="text-sm font-medium bg-white bg-opacity-20 px-3 py-1 rounded-full"
                  >+15.2%</span
                >
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
                <span
                  class="text-sm font-medium bg-white bg-opacity-20 px-3 py-1 rounded-full"
                  >+5.7%</span
                >
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

            <!-- Daily Revenue Comparison -->
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
                Doanh Thu Theo Thời Gian
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
                            class="text-right py-3 px-4 font-semibold text-blue-600"
                          >
                            Kỳ Trước
                          </th>
                          <th
                            class="text-right py-3 px-4 font-semibold text-orange-600"
                          >
                            Kỳ Này
                          </th>
                          <th
                            class="text-center py-3 px-4 font-semibold text-gray-700"
                          >
                            So Sánh
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

                            <!-- Previous Period Revenue -->
                            <td class="py-3 px-4 text-right text-sm">
                              <c:choose>
                                <c:when
                                  test="${not empty reportData.previousPeriodDailyRevenue && status.index < reportData.previousPeriodDailyRevenue.size()}"
                                >
                                  <span class="text-blue-600 font-semibold">
                                    <fmt:formatNumber
                                      value="${reportData.previousPeriodDailyRevenue[status.index].revenue}"
                                      type="number"
                                      groupingUsed="true"
                                    />₫
                                  </span>
                                  <br />
                                  <span class="text-xs text-gray-500"
                                    >${reportData.previousPeriodDailyRevenue[status.index].orders}
                                    đơn</span
                                  >
                                </c:when>
                                <c:otherwise>
                                  <span class="text-gray-400">-</span>
                                </c:otherwise>
                              </c:choose>
                            </td>

                            <!-- Current Period Revenue -->
                            <td class="py-3 px-4 text-right text-sm">
                              <span class="text-orange-600 font-semibold">
                                <fmt:formatNumber
                                  value="${daily.revenue}"
                                  type="number"
                                  groupingUsed="true"
                                />₫
                              </span>
                              <br />
                              <span class="text-xs text-gray-500"
                                >${daily.orders} đơn</span
                              >
                            </td>

                            <!-- Comparison -->
                            <td class="py-3 px-4 text-center text-sm">
                              <c:choose>
                                <c:when
                                  test="${not empty reportData.previousPeriodDailyRevenue && status.index < reportData.previousPeriodDailyRevenue.size()}"
                                >
                                  <c:set
                                    var="prevRev"
                                    value="${reportData.previousPeriodDailyRevenue[status.index].revenue}"
                                  />
                                  <c:set
                                    var="currRev"
                                    value="${daily.revenue}"
                                  />
                                  <c:choose>
                                    <c:when test="${prevRev > 0}">
                                      <c:set
                                        var="change"
                                        value="${((currRev - prevRev) / prevRev) * 100}"
                                      />
                                      <c:choose>
                                        <c:when test="${change > 0}">
                                          <span
                                            class="inline-flex items-center px-2 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700"
                                          >
                                            ↑
                                            <fmt:formatNumber
                                              value="${change}"
                                              maxFractionDigits="1"
                                            />%
                                          </span>
                                        </c:when>
                                        <c:when test="${change < 0}">
                                          <span
                                            class="inline-flex items-center px-2 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-700"
                                          >
                                            ↓
                                            <fmt:formatNumber
                                              value="${-change}"
                                              maxFractionDigits="1"
                                            />%
                                          </span>
                                        </c:when>
                                        <c:otherwise>
                                          <span
                                            class="inline-flex items-center px-2 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-700"
                                          >
                                            = 0%
                                          </span>
                                        </c:otherwise>
                                      </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                      <span class="text-gray-400">-</span>
                                    </c:otherwise>
                                  </c:choose>
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
              onclick="quickReport('today')"
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
              onclick="quickReport('week')"
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
              onclick="quickReport('month')"
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
              onclick="quickReport('compare')"
              class="flex flex-col items-center gap-2 p-4 border-2 border-gray-200 rounded-lg hover:border-orange-500 hover:bg-orange-50 transition-all group"
            >
              <i
                data-lucide="pie-chart"
                class="w-6 h-6 text-gray-600 group-hover:text-orange-500"
              ></i>
              <span
                class="text-sm font-medium text-gray-700 group-hover:text-orange-600 text-center"
              >
                So sánh kỳ trước
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

      function quickReport(type) {
        const today = new Date();
        let dateFrom, dateTo;

        switch (type) {
          case "today":
            // Today only
            dateFrom = dateTo = today.toISOString().split("T")[0];
            break;
          case "week":
            // Last 7 days
            const weekAgo = new Date(today.getTime() - 6 * 24 * 60 * 60 * 1000);
            dateFrom = weekAgo.toISOString().split("T")[0];
            dateTo = today.toISOString().split("T")[0];
            break;
          case "month":
            // Last 30 days
            const monthAgo = new Date(
              today.getTime() - 29 * 24 * 60 * 60 * 1000
            );
            dateFrom = monthAgo.toISOString().split("T")[0];
            dateTo = today.toISOString().split("T")[0];
            break;
          case "compare":
            // Last 14 days (for comparison)
            const twoWeeksAgo = new Date(
              today.getTime() - 13 * 24 * 60 * 60 * 1000
            );
            dateFrom = twoWeeksAgo.toISOString().split("T")[0];
            dateTo = today.toISOString().split("T")[0];
            break;
        }

        // Update form and submit
        document.querySelector('input[name="dateFrom"]').value = dateFrom;
        document.querySelector('input[name="dateTo"]').value = dateTo;
        document.querySelector("form").submit();
      }

      // Calculate progress bar widths
      document.addEventListener("DOMContentLoaded", function () {
        const progressBars = document.querySelectorAll("[data-revenue]");
        progressBars.forEach(function (bar) {
          const revenue = parseFloat(bar.getAttribute("data-revenue")) || 0;
          const total = parseFloat(bar.getAttribute("data-total")) || 0;
          const percentage = total > 0 ? (revenue / total) * 100 : 0;
          bar.style.width = percentage + "%";
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
