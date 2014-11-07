@ECHO off
SETLOCAL EnableDelayedExpansion
REM Creates a portable development environment that uses Node.js and npm.
REM Copyright 2014 Wong Yong Jie. See LICENSE for details.

WHERE /Q powershell > NUL
IF NOT !ERRORLEVEL! EQU 0 (
    ECHO Windows PowerShell is required to run the bootstrapping script.
    ECHO See http://technet.microsoft.com/en-us/library/hh847837.aspx for more information.
) ELSE (
    ECHO Bootstrapping the runtime...
    FOR /F "usebackq delims=" %%v IN (`powershell -ExecutionPolicy RemoteSigned -File .\bootstrap.ps1`) DO SET "RUNTIME_DIR=%%v"
    SET PROJECT_DIR=%~dp0
    SET "PATH=!PROJECT_DIR!node_modules\.bin;!RUNTIME_DIR!;%PATH%"
    
    WHERE /Q npm > NUL
    IF NOT !ERRORLEVEL! EQU 0 (
        ECHO Failed to bootstrap the Node.js runtime.
        ECHO node and npm may not be available.
    ) ELSE (
        WHERE /Q bower > NUL
        IF NOT !ERRORLEVEL! EQU 0 (
            ECHO Installing bower...
            npm install -g bower
        )
        
        WHERE /Q grunt > NUL
        IF NOT !ERRORLEVEL! EQU 0 (
            ECHO Installing grunt-cli...
            npm install -g grunt-cli
        )
    )
    
    ECHO Environment set up.
)

ENDLOCAL & @SET PATH=%PATH% & @SET PHPRC=%PHPRC%

SETLOCAL EnableDelayedExpansion
  WHERE /Q powershell > NUL
  if NOT !ERRORLEVEL! EQU 0 0 (
      powershell
  )
ENDLOCAL
