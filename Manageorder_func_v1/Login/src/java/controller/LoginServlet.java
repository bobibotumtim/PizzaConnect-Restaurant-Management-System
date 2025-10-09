package controller;

import dao.CustomerDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import models.*;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        
        if ("logout".equals(action)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            resp.sendRedirect("Login");
            return;
        }
        
        req.getRequestDispatcher("view/Login.jsp").forward(req, resp);
    }
    
    

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String user = request.getParameter("user");
        String pass = request.getParameter("pass");

        UserDAO dao = new UserDAO();
        User account = dao.checkLogin(user, pass);     // null neu sai

        if (account == null) {
            request.setAttribute("mess", "Ten dang nhap hoac mat khau khong dung!");
            request.getRequestDispatcher("view/Login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("user", account);   // LUU duy nhat 1 bien object

        // Chuyen trang tuy role
        if (account.getRole() == 1) {
            response.sendRedirect("dashboard");   // redirect to dashboard
        } else {
            CustomerDAO cdao = new CustomerDAO();
            Customer acc = cdao.getCustomerByUserID(account.getUserID());
            
            if (acc == null) {
                // If no Customer record exists, create a default one or redirect to profile creation
                acc = new Customer(0, account.getUsername(), 0, 
                                 account.getUserID(), account.getUsername(), 
                                 account.getEmail(), account.getPassword(), 
                                 account.getPhone(), account.getRole());
                // Optionally insert this customer into database
                cdao.insertCustomer(acc);
            }
            
            request.setAttribute("customer", acc);
            request.setAttribute("user", account);
            request.getRequestDispatcher("view/Detail.jsp").forward(request, response);
            //response.sendRedirect("home");
        }
    }
}
