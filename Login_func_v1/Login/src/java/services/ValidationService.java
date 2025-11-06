package services;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.ProductIngredientDAO;
import dao.ProductSizeDAO;
import models.Category;
import models.Product;
import models.ProductIngredient;
import models.ProductSize;
import java.util.HashMap;
import java.util.Map;

public class ValidationService {
    
    private CategoryDAO categoryDAO = new CategoryDAO();
    private ProductDAO productDAO = new ProductDAO();
    private ProductIngredientDAO productIngredientDAO = new ProductIngredientDAO();
    private ProductSizeDAO sizeDAO = new ProductSizeDAO();
    
    // Validation messages
    public static final Map<String, String> VALIDATION_MESSAGES = new HashMap<>();
    
    static {
        // Category
        VALIDATION_MESSAGES.put("CATEGORY_NAME_DUPLICATE", "Category name already exists");
        VALIDATION_MESSAGES.put("CATEGORY_NOT_FOUND", "Category not found");
        
        // Product
        VALIDATION_MESSAGES.put("PRODUCT_NAME_DUPLICATE", "Product name already exists");
        VALIDATION_MESSAGES.put("PRODUCT_PRICE_INVALID", "Product price cannot be negative");
        VALIDATION_MESSAGES.put("PRODUCT_CATEGORY_INVALID", "Invalid category");
        VALIDATION_MESSAGES.put("PRODUCT_NOT_FOUND", "Product not found");
        
        // Product Size
        VALIDATION_MESSAGES.put("SIZE_DUPLICATE", "Size already exists for this product");
        VALIDATION_MESSAGES.put("SIZE_PRICE_INVALID", "Size price cannot be negative");
        VALIDATION_MESSAGES.put("SIZE_NOT_FOUND", "Size not found");
        
        // Ingredient
        VALIDATION_MESSAGES.put("INGREDIENT_DUPLICATE", "Ingredient already added to this product");
        VALIDATION_MESSAGES.put("INGREDIENT_QUANTITY_INVALID", "Ingredient quantity must be greater than 0");
        VALIDATION_MESSAGES.put("INGREDIENT_NOT_FOUND", "Ingredient not found");
        VALIDATION_MESSAGES.put("PRODUCT_INGREDIENT_INVALID", "Invalid ingredient information");
    }
    
    // ===== CATEGORY VALIDATION =====
    
    public ValidationResult validateAddCategory(String categoryName) {
        // Check duplicate name
        if (isCategoryNameExists(categoryName, null)) {
            return ValidationResult.error("CATEGORY_NAME_DUPLICATE");
        }
        
        // Check special characters (optional - có thể bỏ nếu không cần)
        if (containsSpecialCharacters(categoryName)) {
            return ValidationResult.error("CATEGORY_INVALID_CHARACTERS", "Category name contains invalid characters");
        }
        
        return ValidationResult.success();
    }
    
    public ValidationResult validateEditCategory(int categoryId, String categoryName) {
        // Check if category exists
        Category existing = categoryDAO.getCategoryById(categoryId);
        if (existing == null) {
            return ValidationResult.error("CATEGORY_NOT_FOUND");
        }
        
        // Check duplicate name (exclude current category)
        if (isCategoryNameExists(categoryName, categoryId)) {
            return ValidationResult.error("CATEGORY_NAME_DUPLICATE");
        }
        
        return ValidationResult.success();
    }
    
    // ===== PRODUCT VALIDATION =====
    
    public ValidationResult validateAddProduct(String productName, String categoryName, double price) {
        // Check duplicate name
        if (isProductNameExists(productName, null)) {
            return ValidationResult.error("PRODUCT_NAME_DUPLICATE");
        }
        
        // Check category exists
        if (!isCategoryExists(categoryName)) {
            return ValidationResult.error("PRODUCT_CATEGORY_INVALID");
        }
        
        // Check price
        if (price < 0) {
            return ValidationResult.error("PRODUCT_PRICE_INVALID");
        }
        
        return ValidationResult.success();
    }
    
    public ValidationResult validateEditProduct(int productId, String productName, String categoryName, double price) {
        // Check if product exists
        Product existing = productDAO.getProductById(productId);
        if (existing == null) {
            return ValidationResult.error("PRODUCT_NOT_FOUND");
        }
        
        // Check duplicate name (exclude current product)
        if (isProductNameExists(productName, productId)) {
            return ValidationResult.error("PRODUCT_NAME_DUPLICATE");
        }
        
        // Check category exists
        if (!isCategoryExists(categoryName)) {
            return ValidationResult.error("PRODUCT_CATEGORY_INVALID");
        }
        
        // Check price
        if (price < 0) {
            return ValidationResult.error("PRODUCT_PRICE_INVALID");
        }
        
        return ValidationResult.success();
    }
    
    // ===== PRODUCT SIZE VALIDATION =====
    
    public ValidationResult validateAddProductSize(int productId, String sizeName, double price) {
        // Check if product exists
        Product product = productDAO.getProductById(productId);
        if (product == null) {
            return ValidationResult.error("PRODUCT_NOT_FOUND");
        }
        
        // Check duplicate size for this product
        if (isSizeExistsForProduct(productId, sizeName, null)) {
            return ValidationResult.error("SIZE_DUPLICATE");
        }
        
        // Check price
        if (price < 0) {
            return ValidationResult.error("SIZE_PRICE_INVALID");
        }
        
        return ValidationResult.success();
    }
    
    public ValidationResult validateEditProductSize(int sizeId, int productId, String sizeName, double price) {
        // Check if size exists
        ProductSize existing = sizeDAO.getProductSizeById(sizeId);
        if (existing == null) {
            return ValidationResult.error("SIZE_NOT_FOUND");
        }
        
        // Check duplicate size for this product (exclude current size)
        if (isSizeExistsForProduct(productId, sizeName, sizeId)) {
            return ValidationResult.error("SIZE_DUPLICATE");
        }
        
        // Check price
        if (price < 0) {
            return ValidationResult.error("SIZE_PRICE_INVALID");
        }
        
        return ValidationResult.success();
    }
    
    // ===== PRODUCT INGREDIENT VALIDATION =====
    
    public ValidationResult validateIngredientForNewProductSize(int inventoryId, double quantityNeeded) {
        // Check if inventory exists
        if (!isInventoryExists(inventoryId)) {
            return ValidationResult.error("INGREDIENT_NOT_FOUND");
        }
        
        // Check quantity > 0
        if (quantityNeeded <= 0) {
            return ValidationResult.error("INGREDIENT_QUANTITY_INVALID");
        }
        
        return ValidationResult.success();
    }
    
    public ValidationResult validateAddProductIngredient(int productSizeId, int inventoryId, double quantityNeeded) {
        // Check if product size exists
        ProductSize productSize = sizeDAO.getProductSizeById(productSizeId);
        if (productSize == null) {
            return ValidationResult.error("SIZE_NOT_FOUND");
        }
        
        // Check if inventory exists (through ProductIngredientDAO)
        if (!isInventoryExists(inventoryId)) {
            return ValidationResult.error("INGREDIENT_NOT_FOUND");
        }
        
        // Check if ingredient already exists for this product size
        if (isIngredientExistsForProductSize(productSizeId, inventoryId)) {
            return ValidationResult.error("INGREDIENT_DUPLICATE");
        }
        
        // Check quantity > 0
        if (quantityNeeded <= 0) {
            return ValidationResult.error("INGREDIENT_QUANTITY_INVALID");
        }
        
        return ValidationResult.success();
    }
    
    public ValidationResult validateEditProductIngredient(int productSizeId, int inventoryId, double quantityNeeded, int excludeInventoryId) {
        // Check if product size exists
        ProductSize productSize = sizeDAO.getProductSizeById(productSizeId);
        if (productSize == null) {
            return ValidationResult.error("SIZE_NOT_FOUND");
        }
        
        // Check if inventory exists
        if (!isInventoryExists(inventoryId)) {
            return ValidationResult.error("INGREDIENT_NOT_FOUND");
        }
        
        // Check if ingredient already exists for this product size (exclude current one)
        if (inventoryId != excludeInventoryId && isIngredientExistsForProductSize(productSizeId, inventoryId)) {
            return ValidationResult.error("INGREDIENT_DUPLICATE");
        }
        
        // Check quantity > 0
        if (quantityNeeded <= 0) {
            return ValidationResult.error("INGREDIENT_QUANTITY_INVALID");
        }
        
        return ValidationResult.success();
    }
    
    // ===== HELPER METHODS =====
    
    private boolean isCategoryNameExists(String categoryName, Integer excludeId) {
        try {
            // Implement logic to check if category name exists
            // This would need to be added to CategoryDAO
            return categoryDAO.isCategoryNameExists(categoryName, excludeId);
        } catch (Exception e) {
            return false;
        }
    }
    
    private boolean isProductNameExists(String productName, Integer excludeId) {
        try {
            return productDAO.isProductNameExists(productName, excludeId);
        } catch (Exception e) {
            return false;
        }
    }
    
    private boolean isCategoryExists(String categoryName) {
        try {
            return categoryDAO.getCategoryByName(categoryName) != null;
        } catch (Exception e) {
            return false;
        }
    }
    
    private boolean isSizeExistsForProduct(int productId, String sizeName, Integer excludeId) {
        try {
            return sizeDAO.isSizeExistsForProduct(productId, sizeName, excludeId);
        } catch (Exception e) {
            return false;
        }
    }
    
    private boolean isInventoryExists(int inventoryId) {
        try {
            return productIngredientDAO.isInventoryExists(inventoryId);
        } catch (Exception e) {
            return false;
        }
    }
    
    private boolean isIngredientExistsForProductSize(int productSizeId, int inventoryId) {
        try {
            return productIngredientDAO.isIngredientExistsForProductSize(productSizeId, inventoryId);
        } catch (Exception e) {
            return false;
        }
    }
    
    private boolean containsSpecialCharacters(String text) {
        // Check for special characters like @, #, $, %, etc.
        return text.matches(".*[@#$%^&*()+=\\[\\]{}|\\\\:;\"'<>?,./].*");
    }
    
    // ===== VALIDATION RESULT CLASS =====
    
    public static class ValidationResult {
        private boolean valid;
        private String errorCode;
        private String errorMessage;
        
        private ValidationResult(boolean valid, String errorCode, String errorMessage) {
            this.valid = valid;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }
        
        public static ValidationResult success() {
            return new ValidationResult(true, null, null);
        }
        
        public static ValidationResult error(String errorCode) {
            String message = VALIDATION_MESSAGES.get(errorCode);
            return new ValidationResult(false, errorCode, message);
        }
        
        public static ValidationResult error(String errorCode, String customMessage) {
            return new ValidationResult(false, errorCode, customMessage);
        }
        
        public boolean isValid() {
            return valid;
        }
        
        public String getErrorCode() {
            return errorCode;
        }
        
        public String getErrorMessage() {
            return errorMessage;
        }
    }
}