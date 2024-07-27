# PowerShell Scripts Repository

Thanks for checking out my PowerShell repository! This repository contains a collection of PowerShell scripts that I have created over my career and thought would be beneficial to the community.

## Table of Contents
- [Introduction](#introduction)
- [Getting Started](#getting-started)
- [Scripts Overview](#scripts-overview)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Introduction

This repository provides a variety of PowerShell scripts for different use cases. Whether you need to conduct a security audit, automate repetitive tasks, or manage Office, you'll find useful scripts here. Each script is designed to be modular and easy to adapt to your needs.

## Getting Started

To get started with the scripts in this repository:

1. **Clone the Repository**: 
    ```bash
    git clone https://github.com/sv866729/Powershell-Stuff
    ```
2. **Navigate to the Directory**:
    ```bash
    cd Powershell-Stuff
    ```

3. **Open PowerShell**: Ensure you are using PowerShell with appropriate execution policies. You might need to adjust the policy to allow script execution:
    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

## Scripts Overview

### AD Related

#### `Get-AliasAllUsers.ps1`

- **Description**: Gets all AD users and their proxy addresses.
- **Usage**: 
    ```powershell
    Get-AliasAllUsers -ou "OU=Users,DC=example,DC=com"
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

#### `Remove-AliasAllUsers.ps1`

- **Description**: Removes an alias from all users in the specified domain.
- **Usage**: 
    ```powershell
    Remove-AliasAllUsers -domain "domain.com" -ou "OU=Users,DC=example,DC=com"
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

#### `Set-NewAliasAllUsers.ps1`

- **Description**: Sets a new alias for all users based on the specified criteria.
- **Usage**: 
    ```powershell
    Set-NewAliasAllUsers -domain "domain.com" -ou "OU=Users,DC=example,DC=com"
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

### Building Blocks

#### `download-install.ps1`

- **Description**: Downloads a file from a specified URL and initiates its installation.
- **Usage**: 
    ```powershell
    download-install -url "https://example.com/file.exe"
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

#### `error-handling.ps1`

- **Description**: Executes a command and handles errors gracefully, providing customizable messages for success and failure.
- **Usage**: 
    ```powershell
    error-handling -command "YourCommandHere"
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

#### `Generate-Passphrase.ps1`

- **Description**: Generates a passphrase using a specified word list and number of words, appending a random number at the end.
- **Usage**: 
    ```powershell
    Generate-Passphrase -wordlist @("word1", "word2", "word3") -wordcount 4
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

#### `Generate-Username.ps1`

- **Description**: Generates usernames based on first and last names from a CSV file, optionally adding a random number to each username.
- **Usage**: 
    ```powershell
    Generate-Usernames -csvpath "C:\path\to\your\file.csv"
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

#### `Get-HexCode.ps1`

- **Description**: Converts a decimal value to its hexadecimal representation, formatted to an 8-character code with leading zeros.
- **Usage**: 
    ```powershell
    Get-HexCode -decimalvalue 123
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

#### `Install-ModuleIfNeeded.ps1`

- **Description**: Checks if a PowerShell module is installed and installs it if not already present.
- **Usage**: 
    ```powershell
    Install-ModuleIfNeeded -ModuleName "ModuleName"
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

### Microsoft 365 Related

#### `BlockingAllSignIns365MSOL.ps1`

- **Description**: Connects to Microsoft Online Services and blocks credentials for all users.

#### `EnableSecDefaultsGRAPH.ps1`

- **Description**: Installs the Microsoft.Graph.Identity.SignIns module, connects to Microsoft Graph, ensures Security Defaults are enabled, and handles authentication and status checks.

#### `EnforcingLegacyMfaGRAPH.ps1`

- **Description**: Connects to Microsoft Graph, retrieves all users, and enforces Multi-Factor Authentication (MFA) for each user via the Microsoft Graph API.

#### `Remove-InboxRulesByNameEXCH.ps1`

- **Description**: Connects to Exchange Online, retrieves all user mailboxes, and removes any inbox rules containing a specified string.
- **Usage**: 
    ```powershell
    Remove-InboxRulesByName -RuleNameSubstring "(Migrated)"
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

#### `Reset-M365UserPasswordsMSOL.ps1`

- **Description**: Connects to Microsoft Online Services, retrieves all users, resets passwords (excluding specified admin account), and exports the list of new passwords to a CSV file.
- **Usage**: 
    ```powershell
    Reset-UserPasswords -AdminAccount "admin@example.com" -FilePath "C:\Path\To\Save\passwordlist.csv"
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

#### `Reset-MFAForAllUsersMSOL.ps1`

- **Description**: Connects to Microsoft Online Services and resets Multi-Factor Authentication (MFA) options for all users.
- **Usage**: 
    ```powershell
    Reset-MFAForAllUsers
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

#### `Revoke-SessionsForAllUsersGRAPH.ps1`

- **Description**: Connects to Microsoft Graph and revokes sign-in sessions for all users.
- **Usage**: 
    ```powershell
    Revoke-SessionsForAllUsers
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

### Windows Security Related

#### `Disable-WeakCiphers.ps1`

- **Description**: Disables a list of weak cipher suites on a Windows machine, handling errors and providing feedback.
- **Usage**: 
    ```powershell
    Disable-WeakCiphers
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

#### `Get-EventMetadata.ps1`

- **Description**: Retrieves detailed metadata for a specific event from the Windows Event Log and returns it as a `PSCustomObject`.
- **Usage**: 
    ```powershell
    Get-EventMetadata -EventId 4672 -LogName "Security"
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

#### `Get-PortProcess.ps1`

- **Description**: Retrieves detailed information about the process listening on a specified TCP port, including process, parent process, executable file properties, and digital signature details.
- **Usage**: 
    ```powershell
    Get-PortProcess -Port 80
    ```
- **Dependencies**: Run the script to load the function into a session.
- **Notes**: This script does not execute by default and is only a function.

## Usage

Open PowerShell and navigate to the script's location. Execute the script with the required parameters using the details listed in the [Scripts Overview](#scripts-overview) section and the header of the script.

## Contributing

Help Wanted! Feel free to contribute by following these steps:

1. **Fork the Repository**: Click the [Fork](https://github.com/sv866729/Powershell-Stuff/fork) button on GitHub to create your own copy.
2. **Create a Branch**: 
    ```bash
    git checkout -b feature/your-feature
    ```
3. **Make Changes**: Edit or add scripts as needed.
4. **Commit Changes**:
    ```bash
    git add .
    git commit -m "Add a descriptive message about your changes"
    ```
5. **Push to the Branch**:
    ```bash
    git push origin feature/your-feature
    ```
6. **Create a Pull Request**: Go to the repository on GitHub and [create a pull request](https://github.com/sv866729/Powershell-Stuff/compare) with a clear description of your changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For any questions or support, please reach out to:

- **Author**: [Samuel Valdez](https://www.linkedin.com/in/samuel-v-656034279/)
- **GitHub**: [Sv866729](https://github.com/sv866729/)
