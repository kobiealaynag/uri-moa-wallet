@echo off
setlocal
cd /d "%~dp0"
echo.
echo Uri Moa Wallet - GIWA Sepolia deployment
echo Project folder: %cd%
echo.

if not exist ".env" (
  echo Missing .env file.
  echo Copying .env.example to .env...
  copy ".env.example" ".env" >nul
  echo.
  echo Please open .env, fill DEPLOYER_PRIVATE_KEY, save it, then run this file again.
  notepad ".env"
  pause
  exit /b 1
)

echo Installing dependencies in this project folder...
call npm.cmd install
if errorlevel 1 (
  echo npm install failed.
  pause
  exit /b 1
)

echo.
echo Compiling contracts...
call npm.cmd run compile
if errorlevel 1 (
  echo Compile failed.
  pause
  exit /b 1
)

echo.
echo Deploying to GIWA Sepolia...
call npm.cmd run deploy:giwa
if errorlevel 1 (
  echo Deploy failed.
  pause
  exit /b 1
)

echo.
echo Done. Send deployments.giwa-sepolia.json addresses to Codex.
pause
