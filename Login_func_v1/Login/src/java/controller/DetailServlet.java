package controller;

import dao.CustomerDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import models.Customer;
import models.User;

@WebServlet(name = "DetailServlet", urlPatterns = {"/detail"})
public class DetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            // Nếu chưa đăng nhập -> quay lại login
            request.setAttribute("mess", "Please log in to view details.");
            request.getRequestDispatcher("view/Login.jsp").forward(request, response);
            return;
        }

        // Lấy user đang đăng nhập
        User u = (User) session.getAttribute("user");
        int userID = u.getUserID();

        // Gọi DAO để lấy thông tin khách hàng theo userID
        CustomerDAO cdao = new CustomerDAO();
        Customer c = cdao.getCustomerByUserID(userID);

        if (c == null) {
            request.setAttribute("error", "Customer information not found.");
        } else {
            request.setAttribute("customer", c);
            request.setAttribute("user", u);
        }

        // Chuyển tiếp sang detail.jsp để hiển thị
        request.getRequestDispatcher("view/Detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
