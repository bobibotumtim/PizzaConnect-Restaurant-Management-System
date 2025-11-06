package controller;

import dao.CategoryDAO;
import models.Category;
import services.ValidationService;
import services.ValidationService.ValidationResult;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/managecategory")
public class ManageCategoryServlet extends HttpServlet {
    private CategoryDAO categoryDAO = new CategoryDAO();
    private ValidationService validationService = new ValidationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String search = request.getParameter("searchName");

        if (action == null) action = "";

        switch (action) {
            case "edit":
                int id = Integer.parseInt(request.getParameter("id"));
                Category category = categoryDAO.getCategoryById(id);
                request.setAttribute("editCategory", category);
                break;
            case "delete":
                int deleteId = Integer.parseInt(request.getParameter("id"));
                categoryDAO.deleteCategory(deleteId);
                response.sendRedirect("managecategory?message=deleted");
                return;
        }

        List<Category> list;
        if (search != null && !search.trim().isEmpty()) {
            list = categoryDAO.getAllCategories().stream()
                    .filter(c -> c.getCategoryName().toLowerCase().contains(search.toLowerCase()))
                    .toList();
        } else {
            list = categoryDAO.getAllCategories();
        }

        request.setAttribute("categories", list);
        request.getRequestDispatcher("/view/ManageCategory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("categoryId");
        String name = request.getParameter("categoryName");
        String desc = request.getParameter("description");

        HttpSession session = request.getSession();
        ValidationResult validationResult;

        if (idStr == null || idStr.isEmpty()) {
            // Add new category
            validationResult = validationService.validateAddCategory(name);
            
            if (validationResult.isValid()) {
                Category c = new Category(name, desc);
                boolean success = categoryDAO.addCategory(c);
                
                if (success) {
                    session.setAttribute("message", "Category added successfully!");
                    session.setAttribute("messageType", "success");
                } else {
                    session.setAttribute("message", "Error adding category.");
                    session.setAttribute("messageType", "error");
                }
            } else {
                session.setAttribute("message", validationResult.getErrorMessage());
                session.setAttribute("messageType", "error");
            }
        } else {
            // Update existing category
            int id = Integer.parseInt(idStr);
            validationResult = validationService.validateEditCategory(id, name);
            
            if (validationResult.isValid()) {
                Category c = new Category(id, name, desc);
                boolean success = categoryDAO.updateCategory(c);
                
                if (success) {
                    session.setAttribute("message", "Category updated successfully!");
                    session.setAttribute("messageType", "success");
                } else {
                    session.setAttribute("message", "Error updating category.");
                    session.setAttribute("messageType", "error");
                }
            } else {
                session.setAttribute("message", validationResult.getErrorMessage());
                session.setAttribute("messageType", "error");
            }
        }
        
        response.sendRedirect("managecategory");
    }
}
