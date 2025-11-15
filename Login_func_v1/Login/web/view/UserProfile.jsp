<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>User Profile</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body {
            background: linear-gradient(135deg, #fed7aa 0%, #ffffff 50%, #fee2e2 100%);
            min-height: 100vh;
        }
        .tab-content { display: none; }
        .tab-content.active { display: block; }
        .error-message { color: #dc2626; font-size: 0.875rem; margin-top: 0.25rem; }
        .input-error { border-color: #dc2626; }
        .success-message { color: #16a34a; font-size: 0.875rem; margin-top: 0.25rem; }
    </style>
</head>
<body class="min-h-screen flex overflow-hidden">
    <!-- Sidebar -->
    <jsp:include page="Sidebar.jsp" />
    
    <div class="flex flex-col flex-1 overflow-auto" style="margin-left: 80px;">
        <!-- Top Navigation Bar -->
        <div class="bg-white shadow-md border-b px-6 py-3 flex items-center justify-between">
            <div class="flex items-center gap-4">
                <div class="text-2xl font-bold text-orange-600">🍕 PizzaConnect</div>
            </div>
            <div class="flex items-center gap-3">
                <div class="text-right">
                    <div class="font-semibold text-gray-800">${user.name}</div>
                    <div class="text-xs text-gray-500">
                        <c:choose>
                            <c:when test="${user.role == 1}">Admin</c:when>
                            <c:when test="${user.role == 2}">
                                <c:choose>
                                    <c:when test="${not empty employee and employee.jobRole == 'Manager'}">Manager</c:when>
                                    <c:otherwise>Waiter</c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise>Customer</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <a href="logout" class="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 shadow-sm hover:shadow-md transition-all duration-200">
                    🚪 Logout
                </a>
            </div>
        </div>

        <div class="flex">
        <!-- Tabbar -->
        <div class="w-64 bg-white shadow-lg min-h-screen p-6">
            <div class="text-center mb-8">
                <div class="w-20 h-20 bg-orange-500 rounded-full flex items-center justify-center mx-auto mb-4">
                    <i data-lucide="user" class="w-10 h-10 text-white"></i>
                </div>
                
                <!-- Display loyalty points for customers -->
                <c:if test="${user.role == 3}">
                    <div class="flex items-center justify-center mt-2 text-amber-600">
                        <i data-lucide="coin" class="w-4 h-4 mr-1"></i>
                        <span class="font-semibold">${loyaltyPoints} points</span>
                        <c:if test="${not empty loyaltyValue}">
                            <span class="text-sm text-gray-600 ml-2">(≈ <fmt:formatNumber value="${loyaltyValue}" type="currency" currencyCode="VND" />)</span>
                        </c:if>
                    </div>
                </c:if>
            </div>

            <nav class="space-y-2">
                <button onclick="showTab('personal')" class="w-full text-left px-4 py-3 rounded-lg ${empty activeTab or activeTab == 'personal' ? 'bg-orange-500 text-white' : 'text-gray-700 hover:bg-gray-100'}">
                    Personal Information
                </button>
                <button onclick="showTab('password')" class="w-full text-left px-4 py-3 rounded-lg ${activeTab == 'password' ? 'bg-orange-500 text-white' : 'text-gray-700 hover:bg-gray-100'}">
                    Change Password
                </button>
            </nav>
        </div>

        <!-- Main Content -->
        <div class="flex-1 p-8">
            <!-- Personal Information Tab -->
            <div id="personal" class="tab-content ${empty activeTab or activeTab == 'personal' ? 'active' : ''}">
                <div class="bg-white rounded-lg shadow-md p-6">
                    <h2 class="text-xl font-bold mb-6">Personal Information</h2>
                    
                    <!-- Success Message -->
                    <c:if test="${not empty successMessage}">
                        <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg">
                            ${successMessage}
                        </div>
                    </c:if>
                    
                    <!-- Error Message -->
                    <c:if test="${not empty errorMessage}">
                        <div class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
                            ${errorMessage}
                        </div>
                    </c:if>

                    <form action="profile" method="post" id="personalForm" class="space-y-4">
                        <input type="hidden" name="action" value="updateProfile">
                        
                        <div class="grid grid-cols-2 gap-4">
                            <!-- Name Field -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Full Name *</label>
                                <input type="text" name="name" value="${user.name}" 
                                       class="w-full p-2 border border-gray-300 rounded-lg ${not empty fieldErrors.name ? 'input-error' : ''}" 
                                       placeholder="Enter your full name (e.g., Nguyen Van A)"
                                       required maxlength="100">
                                <div id="nameError" class="error-message">
                                    <c:if test="${not empty fieldErrors.name}">${fieldErrors.name}</c:if>
                                </div>
                            </div>
                            
                            <!-- Email Field -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Email Address *</label>
                                <input type="email" name="email" value="${user.email}" 
                                       class="w-full p-2 border border-gray-300 rounded-lg ${not empty fieldErrors.email ? 'input-error' : ''}" 
                                       placeholder="example@gmail.com"
                                       required maxlength="100">
                                <div id="emailError" class="error-message">
                                    <c:if test="${not empty fieldErrors.email}">${fieldErrors.email}</c:if>
                                </div>
                            </div>
                            
                            <!-- Phone Field -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Phone Number *</label>
                                <input type="text" name="phone" value="${user.phone}" 
                                       class="w-full p-2 border border-gray-300 rounded-lg ${not empty fieldErrors.phone ? 'input-error' : ''}" 
                                       placeholder="0912345678 (10 digits)"
                                       required pattern="^0[1-9]\d{8}$" maxlength="10">
                                <div id="phoneError" class="error-message">
                                    <c:if test="${not empty fieldErrors.phone}">${fieldErrors.phone}</c:if>
                                </div>
                            </div>
                            
                            <!-- Gender Field -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Gender *</label>
                                <select name="gender" class="w-full p-2 border border-gray-300 rounded-lg ${not empty fieldErrors.gender ? 'input-error' : ''}" required>
                                    <option value="">Select your gender</option>
                                    <option value="Male" ${user.gender == 'Male' ? 'selected' : ''}>Male</option>
                                    <option value="Female" ${user.gender == 'Female' ? 'selected' : ''}>Female</option>
                                    <option value="Other" ${user.gender == 'Other' ? 'selected' : ''}>Other</option>
                                </select>
                                <div id="genderError" class="error-message">
                                    <c:if test="${not empty fieldErrors.gender}">${fieldErrors.gender}</c:if>
                                </div>
                            </div>
                            
                            <!-- Date of Birth Field -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Date of Birth</label>
                                <input type="date" name="dateOfBirth" 
                                       value="<fmt:formatDate value='${user.dateOfBirth}' pattern='yyyy-MM-dd' />" 
                                       class="w-full p-2 border border-gray-300 rounded-lg ${not empty fieldErrors.dateOfBirth ? 'input-error' : ''}"
                                       max="<%= java.time.LocalDate.now().minusYears(13) %>">
                                <div id="dobError" class="error-message">
                                    <c:if test="${not empty fieldErrors.dateOfBirth}">${fieldErrors.dateOfBirth}</c:if>
                                </div>
                                <div class="text-sm text-gray-500 mt-1">Must be at least 13 years old</div>
                            </div>
                        </div>
                        
                        <div class="flex justify-end">
                            <button type="submit" class="bg-orange-500 text-white px-6 py-2 rounded-lg hover:bg-orange-600 transition duration-200">
                                Save
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Password Tab -->
            <div id="password" class="tab-content ${activeTab == 'password' ? 'active' : ''}">
                <div class="bg-white rounded-lg shadow-md p-6">
                    <h2 class="text-xl font-bold mb-6">Change Password</h2>
                    
                    <!-- Password Success Message -->
                    <c:if test="${not empty passwordSuccess}">
                        <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg">
                            ${passwordSuccess}
                        </div>
                    </c:if>
                    
                    <!-- Password Error Message -->
                    <c:if test="${not empty passwordError}">
                        <div class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
                            ${passwordError}
                        </div>
                    </c:if>

                    <form action="profile" method="post" id="passwordForm" class="space-y-4">
                        <input type="hidden" name="action" value="changePassword">
                        
                        <!-- Current Password -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Current Password *</label>
                            <input type="password" name="oldPassword" 
                                   class="w-full p-2 border border-gray-300 rounded-lg ${not empty fieldErrors.oldPassword ? 'input-error' : ''}" 
                                   placeholder="Enter your current password"
                                   required minlength="8" maxlength="50">
                            <div id="oldPasswordError" class="error-message">
                                <c:if test="${not empty fieldErrors.oldPassword}">${fieldErrors.oldPassword}</c:if>
                            </div>
                        </div>
                        
                        <!-- New Password -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">New Password *</label>
                            <input type="password" name="newPassword" 
                                   class="w-full p-2 border border-gray-300 rounded-lg ${not empty fieldErrors.newPassword ? 'input-error' : ''}" 
                                   placeholder="At least 8 characters with letters and numbers"
                                   required minlength="8" maxlength="50"
                                   pattern="^(?=.*[A-Za-z])(?=.*\d).{8,}$">
                            <div id="newPasswordError" class="error-message">
                                <c:if test="${not empty fieldErrors.newPassword}">${fieldErrors.newPassword}</c:if>
                            </div>
                            <div class="text-sm text-gray-500 mt-1">Must contain at least one letter and one number</div>
                        </div>
                        
                        <!-- Confirm New Password -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Confirm New Password *</label>
                            <input type="password" name="confirmPassword" 
                                   class="w-full p-2 border border-gray-300 rounded-lg ${not empty fieldErrors.confirmPassword ? 'input-error' : ''}" 
                                   placeholder="Re-enter your new password"
                                   required minlength="8" maxlength="50">
                            <div id="confirmPasswordError" class="error-message">
                                <c:if test="${not empty fieldErrors.confirmPassword}">${fieldErrors.confirmPassword}</c:if>
                            </div>
                        </div>
                        
                        <div class="flex justify-end">
                            <button type="submit" class="bg-orange-500 text-white px-6 py-2 rounded-lg hover:bg-orange-600 transition duration-200">
                                Save
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();

        // Initialize with correct tab based on server-side attribute
        document.addEventListener('DOMContentLoaded', function() {
            const activeTab = '${not empty activeTab ? activeTab : "personal"}';
            showTab(activeTab, false);
            
            // Clear form data on page load to prevent resubmission
            if (window.history.replaceState) {
                window.history.replaceState(null, null, window.location.href);
            }
        });

        function showTab(tabName, updateEvent = true) {
            // Hide all tab contents
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Show selected tab content
            const selectedTab = document.getElementById(tabName);
            if (selectedTab) {
                selectedTab.classList.add('active');
            }
            
            // Update tab button styles
            document.querySelectorAll('nav button').forEach(btn => {
                btn.classList.remove('bg-orange-500', 'text-white');
                btn.classList.add('text-gray-700', 'hover:bg-gray-100');
            });
            
            // Highlight active tab button
            const activeBtn = document.querySelector(`nav button[onclick="showTab('${tabName}')"]`);
            if (activeBtn) {
                activeBtn.classList.add('bg-orange-500', 'text-white');
                activeBtn.classList.remove('text-gray-700', 'hover:bg-gray-100');
            }
            
            // Store active tab in session storage only if triggered by user click
            if (updateEvent) {
                sessionStorage.setItem('activeTab', tabName);
            }
        }

        // Form validation for personal information
        document.getElementById('personalForm')?.addEventListener('submit', function(e) {
            clearErrors();
            let isValid = validatePersonalForm();

            if (!isValid) {
                e.preventDefault();
            }
        });

        // Form validation for password change
        document.getElementById('passwordForm')?.addEventListener('submit', function(e) {
            clearErrors();
            let isValid = validatePasswordForm();

            if (!isValid) {
                e.preventDefault();
            }
        });

        function validatePersonalForm() {
            let isValid = true;

            // Name validation
            const name = document.querySelector('input[name="name"]');
            if (!name.value.trim()) {
                showError('nameError', 'Full name is required');
                name.classList.add('input-error');
                isValid = false;
            } else if (name.value.trim().length < 2) {
                showError('nameError', 'Name must be at least 2 characters long');
                name.classList.add('input-error');
                isValid = false;
            }

            // Email validation
            const email = document.querySelector('input[name="email"]');
            const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            if (!email.value.trim()) {
                showError('emailError', 'Email address is required');
                email.classList.add('input-error');
                isValid = false;
            } else if (!emailRegex.test(email.value)) {
                showError('emailError', 'Please enter a valid email address (e.g., example@gmail.com)');
                email.classList.add('input-error');
                isValid = false;
            }

            // Phone validation
            const phone = document.querySelector('input[name="phone"]');
            const phoneRegex = /^0[1-9]\d{8}$/;
            if (!phone.value.trim()) {
                showError('phoneError', 'Phone number is required');
                phone.classList.add('input-error');
                isValid = false;
            } else if (!phoneRegex.test(phone.value)) {
                showError('phoneError', 'Please enter a valid 10-digit phone number starting with 0 (e.g., 0912345678)');
                phone.classList.add('input-error');
                isValid = false;
            }

            // Gender validation
            const gender = document.querySelector('select[name="gender"]');
            if (!gender.value) {
                showError('genderError', 'Please select your gender');
                gender.classList.add('input-error');
                isValid = false;
            }

            // Date of Birth validation
            const dob = document.querySelector('input[name="dateOfBirth"]');
            if (dob.value) {
                const birthDate = new Date(dob.value);
                const today = new Date();
                const minAgeDate = new Date();
                minAgeDate.setFullYear(today.getFullYear() - 13);
                
                if (birthDate > minAgeDate) {
                    showError('dobError', 'You must be at least 13 years old');
                    dob.classList.add('input-error');
                    isValid = false;
                }
            }

            return isValid;
        }

        function validatePasswordForm() {
            let isValid = true;

            const oldPassword = document.querySelector('input[name="oldPassword"]');
            const newPassword = document.querySelector('input[name="newPassword"]');
            const confirmPassword = document.querySelector('input[name="confirmPassword"]');

            // Current password validation
            if (!oldPassword.value.trim()) {
                showError('oldPasswordError', 'Please enter your current password');
                oldPassword.classList.add('input-error');
                isValid = false;
            } else if (oldPassword.value.length < 8) {
                showError('oldPasswordError', 'Current password must be at least 8 characters');
                oldPassword.classList.add('input-error');
                isValid = false;
            }

            // New password validation
            const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d).{8,}$/;
            if (!newPassword.value.trim()) {
                showError('newPasswordError', 'Please enter a new password');
                newPassword.classList.add('input-error');
                isValid = false;
            } else if (newPassword.value.length < 8) {
                showError('newPasswordError', 'New password must be at least 8 characters long');
                newPassword.classList.add('input-error');
                isValid = false;
            } else if (!passwordRegex.test(newPassword.value)) {
                showError('newPasswordError', 'Password must contain at least one letter and one number');
                newPassword.classList.add('input-error');
                isValid = false;
            }

            // Confirm password validation
            if (!confirmPassword.value.trim()) {
                showError('confirmPasswordError', 'Please confirm your new password');
                confirmPassword.classList.add('input-error');
                isValid = false;
            } else if (newPassword.value !== confirmPassword.value) {
                showError('confirmPasswordError', 'New passwords do not match. Please enter the same password in both fields');
                confirmPassword.classList.add('input-error');
                isValid = false;
            }

            return isValid;
        }

        function showError(elementId, message) {
            const element = document.getElementById(elementId);
            if (element) {
                element.textContent = message;
            }
        }

        function clearErrors() {
            document.querySelectorAll('.error-message').forEach(el => {
                el.textContent = '';
            });
            document.querySelectorAll('.input-error').forEach(el => {
                el.classList.remove('input-error');
            });
        }

        // Real-time validation and clear errors on input
        document.querySelectorAll('input, select').forEach(input => {
            input.addEventListener('input', function() {
                this.classList.remove('input-error');
                const errorElement = document.getElementById(this.name + 'Error');
                if (errorElement) {
                    errorElement.textContent = '';
                }
            });
        });
    </script>
        </div> <!-- Close flex wrapper -->
    </div> <!-- Close flex-1 wrapper -->
</body>
</html>