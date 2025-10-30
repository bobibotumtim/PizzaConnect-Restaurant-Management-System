@echo off
echo Downloading Gson JAR for POS System...

REM Create lib directory if not exists
if not exist "web\WEB-INF\lib" mkdir "web\WEB-INF\lib"

REM Download Gson JAR
echo Downloading gson-2.10.1.jar...
powershell -Command "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar' -OutFile 'web\WEB-INF\lib\gson-2.10.1.jar'"

if exist "web\WEB-INF\lib\gson-2.10.1.jar" (
    echo ✅ Gson JAR downloaded successfully!
    echo File saved to: web\WEB-INF\lib\gson-2.10.1.jar
) else (
    echo ❌ Failed to download Gson JAR
    echo Please download manually from: https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar
    echo And save to: web\WEB-INF\lib\gson-2.10.1.jar
)

pause