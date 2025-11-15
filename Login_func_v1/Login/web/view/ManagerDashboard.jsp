<%@page contentType="text/html" pageEncoding="UTF-8"%> <%@ page
import="models.User" %> <%@ page import="models.Employee" %> <% User currentUser
= (User) session.getAttribute("user"); Employee employee = (Employee)
session.getAttribute("employee"); // Check if user is logged in and is a Manager
if (currentUser == null || currentUser.getRole() != 2 || employee == null ||
!"Manager".equalsIgnoreCase(employee.getJobRole())) {
response.sendRedirect(request.getContextPath() + "/view/Login.jsp"); return; }
String userName = currentUser.getName(); %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Manager Dashboard - PizzaConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
      body {
        font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        background: linear-gradient(
          135deg,
          #fed7aa 0%,
          #ffffff 50%,
          #fee2e2 100%
        );
        min-height: 100vh;
      }
      .dashboard-card {
        transition: all 0.3s ease;
        cursor: pointer;
      }
      .dashboard-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
      }
      .icon-container {
        background: linear-gradient(135deg, #ff8c42 0%, #ff6b35 100%);
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
    </style>
  </head>
  <body>
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
          class="flex items-center px-3 py-3 rounded-lg bg-orange-500 text-white"
        >
          <div class="min-w-[2.5rem] flex justify-center">
            <i data-lucide="home" class="w-6 h-6"></i>
          </div>
          <span class="sidebar-text ml-3">Dashboard</span>
        </a>

        <a
          href="${pageContext.request.contextPath}/inventorymonitor"
          class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition"
        >
          <div class="min-w-[2.5rem] flex justify-center">
            <i data-lucide="package" class="w-6 h-6"></i>
          </div>
          <span class="sidebar-text ml-3">Inventory Monitor</span>
        </a>

        <a
          href="${pageContext.request.contextPath}/sales-reports"
          class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition"
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

    <!-- Main Content -->
    <div class="ml-20 min-h-screen flex items-center justify-center p-8">
      <div class="max-w-6xl w-full">
        <!-- Welcome Header -->
        <div class="text-center mb-12">
          <div
            class="inline-flex items-center justify-center w-20 h-20 bg-white rounded-full mb-4 shadow-lg"
          >
            <i data-lucide="user-circle" class="w-12 h-12 text-orange-500"></i>
          </div>
          <h1 class="text-4xl font-bold text-gray-800 mb-2">
            Welcome, <%= userName %>!
          </h1>
          <p class="text-gray-600">
            Welcome to Pizza Store Restaurant Management System
          </p>
        </div>

        <!-- Dashboard Cards Grid -->
        <div
          class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 max-w-6xl mx-auto"
        >
          <!-- Sales Reports Card -->
          <div
            class="dashboard-card bg-white rounded-2xl shadow-xl overflow-hidden"
            onclick="window.location.href='${pageContext.request.contextPath}/sales-reports'"
          >
            <div class="p-8">
              <div
                class="icon-container w-20 h-20 rounded-2xl flex items-center justify-center mb-6 shadow-lg"
              >
                <i data-lucide="file-text" class="w-10 h-10 text-white"></i>
              </div>
              <div class="mb-2">
                <span
                  class="text-sm font-semibold text-orange-500 uppercase tracking-wide"
                  >Reports</span
                >
              </div>
              <h3 class="text-2xl font-bold text-gray-800 mb-3">
                Sales Reports
              </h3>
              <p class="text-gray-600 leading-relaxed">
                View comprehensive sales reports, analyze revenue trends, and
                track business performance metrics.
              </p>
            </div>
            <div
              class="bg-gradient-to-r from-orange-50 to-orange-100 px-8 py-4 flex items-center justify-between"
            >
              <span class="text-sm font-medium text-orange-600"
                >View Reports</span
              >
              <i data-lucide="arrow-right" class="w-5 h-5 text-orange-600"></i>
            </div>
          </div>

          <!-- Edit Profile Card -->
          <div
            class="dashboard-card bg-white rounded-2xl shadow-xl overflow-hidden"
            onclick="window.location.href='${pageContext.request.contextPath}/profile'"
          >
            <div class="p-8">
              <div
                class="icon-container w-20 h-20 rounded-2xl flex items-center justify-center mb-6 shadow-lg"
              >
                <i data-lucide="user-circle" class="w-10 h-10 text-white"></i>
              </div>
              <div class="mb-2">
                <span
                  class="text-sm font-semibold text-orange-500 uppercase tracking-wide"
                  >Profile</span
                >
              </div>
              <h3 class="text-2xl font-bold text-gray-800 mb-3">
                Edit Profile
              </h3>
              <p class="text-gray-600 leading-relaxed">
                Update your personal information, change password, and manage
                your account settings.
              </p>
            </div>
            <div
              class="bg-gradient-to-r from-orange-50 to-orange-100 px-8 py-4 flex items-center justify-between"
            >
              <span class="text-sm font-medium text-orange-600"
                >Edit Profile</span
              >
              <i data-lucide="arrow-right" class="w-5 h-5 text-orange-600"></i>
            </div>
          </div>

          <!-- Inventory Monitor Card -->
          <div
            class="dashboard-card bg-white rounded-2xl shadow-xl overflow-hidden"
            onclick="window.location.href='${pageContext.request.contextPath}/inventory-monitor'"
          >
            <div class="p-8">
              <div
                class="icon-container w-20 h-20 rounded-2xl flex items-center justify-center mb-6 shadow-lg"
              >
                <i data-lucide="package" class="w-10 h-10 text-white"></i>
              </div>
              <div class="mb-2">
                <span
                  class="text-sm font-semibold text-orange-500 uppercase tracking-wide"
                  >Inventory</span
                >
              </div>
              <h3 class="text-2xl font-bold text-gray-800 mb-3">
                Inventory Monitor
              </h3>
              <p class="text-gray-600 leading-relaxed">
                Monitor inventory levels, track stock warnings, and manage
                critical items that need attention.
              </p>
            </div>
            <div
              class="bg-gradient-to-r from-orange-50 to-orange-100 px-8 py-4 flex items-center justify-between"
            >
              <span class="text-sm font-medium text-orange-600"
                >View Monitor</span
              >
              <i data-lucide="arrow-right" class="w-5 h-5 text-orange-600"></i>
            </div>
          </div>

          <!-- Customer Feedback Card -->
          <div
            class="dashboard-card bg-white rounded-2xl shadow-xl overflow-hidden"
            onclick="window.location.href='${pageContext.request.contextPath}/customer-feedback'"
          >
            <div class="p-8">
              <div
                class="icon-container w-20 h-20 rounded-2xl flex items-center justify-center mb-6 shadow-lg"
              >
                <i
                  data-lucide="message-circle"
                  class="w-10 h-10 text-white"
                ></i>
              </div>
              <div class="mb-2">
                <span
                  class="text-sm font-semibold text-orange-500 uppercase tracking-wide"
                  >Feedback</span
                >
              </div>
              <h3 class="text-2xl font-bold text-gray-800 mb-3">
                Customer Feedback
              </h3>
              <p class="text-gray-600 leading-relaxed">
                View and respond to customer feedback, monitor satisfaction
                ratings, and improve service quality.
              </p>
            </div>
            <div
              class="bg-gradient-to-r from-orange-50 to-orange-100 px-8 py-4 flex items-center justify-between"
            >
              <span class="text-sm font-medium text-orange-600"
                >View Feedback</span
              >
              <i data-lucide="arrow-right" class="w-5 h-5 text-orange-600"></i>
            </div>
          </div>
        </div>

        <!-- Quick Stats (Optional) -->
        <div class="mt-12 grid grid-cols-3 gap-6 max-w-6xl mx-auto">
          <div
            class="bg-white bg-opacity-20 backdrop-blur-lg rounded-xl p-6 text-center"
          >
            <div class="text-3xl font-bold text-white mb-1">4</div>
            <div class="text-white text-opacity-80 text-sm">
              Available Features
            </div>
          </div>
          <div
            class="bg-white bg-opacity-20 backdrop-blur-lg rounded-xl p-6 text-center"
          >
            <div class="text-3xl font-bold text-white mb-1">Manager</div>
            <div class="text-white text-opacity-80 text-sm">Your Role</div>
          </div>
          <div
            class="bg-white bg-opacity-20 backdrop-blur-lg rounded-xl p-6 text-center"
          >
            <div class="text-3xl font-bold text-white mb-1">Active</div>
            <div class="text-white text-opacity-80 text-sm">Account Status</div>
          </div>
        </div>
      </div>
    </div>

    <script>
      // Initialize Lucide icons
      lucide.createIcons();
    </script>
  </body>
</html>
