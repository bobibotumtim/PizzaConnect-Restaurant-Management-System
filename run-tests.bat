@echo off
echo ========================================
echo    PizzaConnect JUnit Test Runner
echo ========================================
echo.

echo [1/4] Cleaning previous test results...
call mvn clean
echo.

echo [2/4] Compiling project...
call mvn compile
if %errorlevel% neq 0 (
    echo ERROR: Compilation failed!
    pause
    exit /b 1
)
echo.

echo [3/4] Running JUnit tests...
call mvn test
if %errorlevel% neq 0 (
    echo WARNING: Some tests failed!
) else (
    echo SUCCESS: All tests passed!
)
echo.

echo [4/4] Generating test report...
call mvn surefire-report:report
echo.

echo ========================================
echo    Test Results Summary
echo ========================================
echo.
echo Test reports generated in:
echo - target/surefire-reports/
echo - target/site/surefire-report.html
echo.
echo Open target/site/surefire-report.html in browser to view detailed results
echo.

pause

