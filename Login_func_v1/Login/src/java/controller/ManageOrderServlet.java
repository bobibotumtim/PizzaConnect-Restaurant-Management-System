package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import models.Order;

@WebServlet("/manage-orders")
public class ManageOrderServlet extends HttpServlet {

    @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    String userName = request.getParameter("userName");
    String address = request.getParameter("address");
    String totalMoneyStr = request.getParameter("totalMoney");
    String statusStr = request.getParameter("status");

    try {
        double totalMoney = Double.parseDouble(totalMoneyStr);
        int status = Integer.parseInt(statusStr);

        Order newOrder = new Order(); // đảm bảo có constructor rỗng
        newOrder.setUserName(userName);
        newOrder.setAddress(address);
        newOrder.setTotalMoney(totalMoney);
        newOrder.setStatus(status);

        OrderDAO dao = new OrderDAO();
        dao.addOrder(newOrder);  // thêm vào DB

        // LẤY LẠI DANH SÁCH ORDER MỚI
        List<Order> orderList = dao.getAllOrders();
        request.setAttribute("orderList", orderList);
        request.setAttribute("success", "Thêm đơn hàng thành công");

        request.getRequestDispatcher("ManageOrders.jsp").forward(request, response);

    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Lỗi khi thêm đơn hàng: " + e.getMessage());
        request.getRequestDispatcher("ManageOrders.jsp").forward(request, response);
    }
}


    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    OrderDAO dao = new OrderDAO();
    List<Order> orderList = dao.getAllOrders();  // <-- lấy từ DB mới nhất

    request.setAttribute("orderList", orderList);  // ⬅️ dùng request, không dùng session!
    request.getRequestDispatcher("ManageOrders.jsp").forward(request, response);
}

}
