package controller;

import dao.TableDAO;
import dao.OrderDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import models.Table;
import models.Order;
import models.Employee;

@WebServlet(name = "AssignTableServlet", urlPatterns = {"/assign-table"})
public class AssignTableServlet extends HttpServlet {

    private TableDAO tableDAO = new TableDAO();
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra session
        HttpSession session = request.getSession(false);
        Employee waiter = (Employee) session.getAttribute("employee");
        
        System.out.println("=== AssignTableServlet Debug ===");
        System.out.println("Session: " + (session != null ? "exists" : "null"));
        System.out.println("Waiter: " + (waiter != null ? waiter.getName() : "null"));
        
        if (waiter == null) {
            System.out.println("❌ No waiter in session, redirecting to login");
            response.sendRedirect("view/Login.jsp");
            return;
        }

        // Lấy tất cả bàn với status
        List<Table> allTables = tableDAO.getActiveTablesWithStatus();
        System.out.println("✅ Tables loaded: " + (allTables != null ? allTables.size() : "null"));
        
        if (allTables != null) {
            for (Table t : allTables) {
                System.out.println("  - Table: " + t.getTableNumber() + " | Status: " + t.getStatus() + " | Capacity: " + t.getCapacity());
            }
        }
        
        request.setAttribute("tables", allTables);
        System.out.println("✅ Forwarding to AssignTable.jsp");
        request.getRequestDispatcher("view/AssignTable.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("getTableOrders".equals(action)) {
            // AJAX request để lấy thông tin order của bàn
            int tableId = Integer.parseInt(request.getParameter("tableId"));
            
            // Lấy các order của bàn này (status != 4 - chưa hoàn thành)
            List<Order> orders = orderDAO.getOrdersByTableId(tableId);
            
            // Trả về JSON
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            StringBuilder json = new StringBuilder();
            json.append("{\"orders\": [");
            
            for (int i = 0; i < orders.size(); i++) {
                Order order = orders.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"orderId\": ").append(order.getOrderID()).append(",");
                json.append("\"customerName\": \"").append(escapeJson(order.getCustomerNameFromDB())).append("\",");
                json.append("\"totalPrice\": ").append(order.getTotalPrice()).append(",");
                json.append("\"status\": ").append(order.getStatus()).append(",");
                json.append("\"statusText\": \"").append(getStatusText(order.getStatus())).append("\",");
                json.append("\"paymentStatus\": \"").append(escapeJson(order.getPaymentStatus())).append("\",");
                json.append("\"note\": \"").append(escapeJson(order.getNote() != null ? order.getNote() : "")).append("\"");
                json.append("}");
            }
            
            json.append("]}");
            response.getWriter().write(json.toString());
        }
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r");
    }
    
    private String getStatusText(int status) {
        switch (status) {
            case 0: return "Pending";
            case 1: return "In Progress";
            case 2: return "Ready";
            case 3: return "Served";
            case 4: return "Completed";
            default: return "Unknown";
        }
    }
}
