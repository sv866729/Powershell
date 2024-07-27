# Powershell Scripts Repository

Thanks for checking out my PowerShell repository! This repository contains a collection
of PowerShell scripts that I have created over my career and thought would be beneficial
to the community.

## Table of Contents
- [Introduction](#introduction)
- [Getting Started](#getting-started)
- [Scripts Overview](#scripts-overview)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)


## Introduction

This repository provides a variety of PowerShell scripts for different use cases. Whether you need to conduct a security audit, automate repetitive tasks, or manage Office , you'll find useful scripts here. Each script is designed to be modular and easy to adapt to your needs.

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

## Scripts Overview (IN PROGRESS)

### AD Related

#### AD Related: `Get-AliasAllUsers.ps1`

- **Description**: Used to get all Ad users and the proxyaddress
- **Usage**: Basic usage example.
    ```powershell
    Get-AliasAllUsers -ou "OU=Users,DC=example,DC=com"
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

#### AD Related: `Remove-AliasAllUsers.ps1`

- **Description**: This funtion will get all the users and remove a alias based on the on specified domain.
- **Usage**: Basic usage example.
    ```powershell
    Remove-AliasAllUsers -domain "domain.com" -ou "OU=Users,DC=example,DC=com"
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

#### AD Related: `Set-NewAliasAllUsers.ps1`

- **Description**: This funtion will get all the users and set a new alias based on the on specified.
- **Usage**: Basic usage example.
    ```powershell
    Set-NewAliasAllUsers -domain "domain.com" -ou "OU=Users,DC=example,DC=com"
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

### Building Blocks

#### Building Blocks `download-install.ps1`

- **Description**: Used to download a file from a specified URL and initiate its installation.
- **Usage**: Basic usage example.
    ```powershell
    download-install -url "https://example.com/file.exe"
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

#### Building Blocks: `error-handling.ps1`

- **Description**: Executes a command and handles errors gracefully, providing customizable messages for success and failure.
- **Usage**: Basic usage example.
    ```powershell
    error-handling -command "YourCommandHere"
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

#### Building Blocks: `Generate-Passphrase.ps1`

- **Description**: Generates a passphrase using a specified word list and number of words, appending a random number at the end.
- **Usage**: Basic usage example.
    ```powershell
    Generate-Passphrase -wordlist @("word1", "word2", "word3") -wordcount 4
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

#### Building Blocks: `Gernerate-username.ps1`

- **Description**: Generates usernames based on first and last names from a CSV file, optionally adding a random number to each username.
- **Usage**: Basic usage example.
    ```powershell
    Generate-usernames -csvpath "C:\path\to\your\file.csv"
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

#### Building Blocks: `get-hexcode.ps1`

- **Description**: Converts a decimal value to its hexadecimal representation, ensuring it is formatted to an 8-character code with leading zeros.
- **Usage**: Basic usage example.
    ```powershell
    get-hexcode -decimalvalue 123
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

#### Building Blocks: `install-moduleIfNeeded.ps1`

- **Description**: Checks if a PowerShell module is installed and installs it if not already present.
- **Usage**: Basic usage example.
    ```powershell
    Install-ModuleIfNeeded -ModuleName "ModuleName"
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion


### Microsoft 365 Related

#### Microsoft 365 Related: `BlockingAllSignIns365MSOL.ps1`

- **Description**: Connects to Microsoft Online Services and blocks credentials for all users.

#### Microsoft 365 Related: `EnableSecDefaultsGRAPH.ps1`

- **Description**: This script installs the Microsoft.Graph.Identity.SignIns module, connects to Microsoft Graph with specific scopes, and ensures that Security Defaults are enabled. If Security Defaults is not enabled, it will be enabled by the script. It handles authentication, checks the current status of Security Defaults, and reports any errors encountered during the process. Finally, it disconnects from Microsoft Graph.


#### Microsoft 365 Related: `EnforcingLegacyMfaGRAPH.ps1`

- **Description**: Connects to Microsoft Graph, retrieves all users, and enforces Multi-Factor Authentication (MFA) for each user by sending a PATCH request to the Microsoft Graph API.

#### Microsoft 365 Related: `Remove-InboxRulesByNameEXCH.ps1`

- **Description**: Connects to Exchange Online, retrieves all user mailboxes, and removes any inbox rules that contain a specified string in their name. The script installs the required module if not already installed, connects to Exchange Online, processes each mailbox, and disconnects from Exchange Online.

- **Usage**: Basic usage example.
    ```powershell
    Remove-InboxRulesByName -RuleNameSubstring "(Migrated)"
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

#### Microsoft 365 Related: `Reset-M365UserPasswordsMSOL.ps1`

- **Description**: Connects to Microsoft Online Services, retrieves a list of all users, and resets the passwords for all users except the specified admin account. Generates random passwords and exports the list of users with their new passwords to a CSV file at the specified location.

- **Usage**: Basic usage example.
    ```powershell
    Reset-UserPasswords -AdminAccount "admin@example.com" -FilePath "C:\Path\To\Save\passwordlist.csv"
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

#### Microsoft 365 Related: `Reset-MFAForAllUsersMSOL.ps1`

- **Description**: Connects to Microsoft Online Services and resets the Multi-Factor Authentication (MFA) options for all users in Microsoft 365. This script retrieves all users and resets their MFA settings using `Reset-MsolStrongAuthenticationMethodByUpn`.

- **Usage**: Basic usage example.
    ```powershell
    Reset-MFAForAllUsers
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

#### Microsoft 365 Related: `Revoke-SessionsForAllUsersGRAPH.ps1`

- **Description**: Connects to Microsoft Graph and revokes the sign-in sessions for all users. This script retrieves all users and revokes their sign-in sessions using the `Revoke-MgUserSignInSession` command.

- **Usage**: Basic usage example.
    ```powershell
    Revoke-SessionsForAllUsers
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

### Windows Security Related

#### Windows Security Related: `Disable-WeakCiphers.ps1`

- **Description**: Disables a list of weak cipher suites on a Windows machine. This script iterates over a predefined list of cipher suites and disables each one. It handles errors and provides feedback on the success or failure of disabling each cipher suite.

- **Usage**: Basic usage example.
    ```powershell
    Disable-WeakCiphers
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

#### Windows Security Related: `Get-EventMetadata.ps1`

- **Description**: Retrieves detailed metadata for a specific event from the Windows Event Log. The function filters events by the specified event ID and log name, converts them to XML format, and extracts relevant information. It returns the event data as a `PSCustomObject` for easy manipulation and export.

- **Usage**: Basic usage example.
    ```powershell
    Get-EventMetadata -EventId 4672 -LogName "Security"
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion

#### Windows Security Related: `Get-PortProcess.ps1`

- **Description**: Retrieves detailed information about the process that is listening on a specified TCP port. This function provides data about the process, its parent process, executable file properties, and digital signature details.

.
- **Usage**: Basic usage example.
    ```powershell
    Get-PortProcess -Port 80
    ```
- **Dependencies**: Run the script to load the funtion into a session
- **Notes**: This script does not execute by default and is only a funtion


## Usage
Open PowerShell and navigate to the script's location. Execute the script with the required parameters using the details listed in the Script Overview section and the header of the script.

## Contributing

Help Wanted! Feel free to help me out. Use the following steps below to do so:

1. **Fork the Repository**: Click on the "Fork" button on GitHub to create your own copy.
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
6. **Create a Pull Request**: Go to the repository on GitHub and create a pull request with a clear description of your changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

For any questions or support, please reach out to:

- **Author**: [Samuel Valdez](https://www.linkedin.com/in/samuel-v-656034279/)
- **GitHub**: [Sv866729](https://github.com/sv866729/)

