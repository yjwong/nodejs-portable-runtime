@ECHO off
REM Creates a portable development environment that uses Node.js and npm.
REM Copyright 2014 Wong Yong Jie. See LICENSE for details.

SETLOCAL EnableDelayedExpansion

    WHERE /Q powershell > NUL
    IF NOT !ERRORLEVEL! EQU 0 (
        ECHO Windows PowerShell is required to run the bootstrapping script.
        ECHO See http://technet.microsoft.com/en-us/library/hh847837.aspx for more information.
        EXIT
    ) ELSE (
        ECHO Bootstrapping the runtime...
        SET TMPFILE=%TEMP%\nodejs-portable-runtime-%RANDOM%.tmp
        powershell "powershell -ExecutionPolicy RemoteSigned -File .\bootstrap.ps1 | Tee-Object -FilePath !TMPFILE!"
        FOR /F "usebackq delims=" %%v IN (`TYPE !TMPFILE!`) DO SET "RUNTIME_DIR=%%v"
        SET PROJECT_DIR=%~dp0
        SET "NEW_PATH=!PROJECT_DIR!node_modules\.bin;!RUNTIME_DIR!;%PATH%"
        DEL !TMPFILE!
    )

ENDLOCAL & @SET PATH=%NEW_PATH%

SETLOCAL EnableDelayedExpansion

    WHERE /Q npm > NUL
    IF NOT !ERRORLEVEL! EQU 0 (
        ECHO Failed to bootstrap the Node.js runtime.
        ECHO node and npm may not be available.
    ) ELSE (
        WHERE /Q bower > NUL
        IF NOT !ERRORLEVEL! EQU 0 (
            ECHO Installing bower...
            call npm install -g bower
        )

        WHERE /Q grunt > NUL
        IF NOT !ERRORLEVEL! EQU 0 (
            ECHO Installing grunt-cli...
            call npm install -g grunt-cli
        )
    )

    ECHO Environment set up.
    powershell -NoLogo

ENDLOCAL
