@echo off
REM Created by: Samuel Valdez
REM Date: 12/13/2024
REM Usage: This script detects the current configuration for Unattended remote access, network discovery, and access prompts for AnyDesk from the configuration file

set anydeskPath=C:\ProgramData\AnyDesk\system.conf

if exist "%anydeskPath%" (
    REM Initialize the unattended access flag to 0 (disabled)
    set unattendedAccess=0

    REM Check for the presence of the unattended access password (pwd)
    findstr "ad.security.permission_profiles._unattended_access.pwd=" "%anydeskPath%" >nul
    if %errorlevel% equ 0 (
        set unattendedAccess=1
    )

    REM Check for the presence of the unattended access salt
    findstr "ad.security.permission_profiles._unattended_access.salt=" "%anydeskPath%" >nul
    if %errorlevel% equ 0 (
        set unattendedAccess=1
    )

    REM Output the status of Unattended Access
    if "%unattendedAccess%" equ "1" (
        echo Unattended access: Enabled
    ) else (
        echo Unattended access: Disabled
    )

    REM Interactive Access Detection
    findstr "ad.security.interactive_access=" "%anydeskPath%" >nul
    if %errorlevel% equ 0 (
        findstr /C:"ad.security.interactive_access=2" "%anydeskPath%" >nul
        if %errorlevel% equ 0 (
            echo Prompting: Disabled
        ) else (
            echo Prompting: Allowed
        )
    ) else (
        echo Interactive Access: Not Present
    )

    REM Network Discovery Detection
    findstr "ad.discovery.hidden=" "%anydeskPath%" >nul
    if %errorlevel% equ 0 (
        findstr /C:"ad.discovery.hidden=true" "%anydeskPath%" >nul
        if %errorlevel% equ 0 (
            echo Network Hidden: True
        ) else (
            echo Network Hidden: False
        )
    ) else (
        echo Network Hidden: Not Present
    )
) else (
    echo Configuration file not found.
)

pause
