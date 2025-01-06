# Cloud Backup Script

## Overview
This PowerShell script provides a reliable way to back up files and directories to cloud storage (Azure Blob Storage). It includes features like AES encryption, a 30-day retention policy for backups, and email notifications to inform the user about the success or failure of backup operations. 

## Features
- **Cloud Backup**: Automatically uploads files to an Azure Blob Storage container.
- **Encryption**: Files are encrypted using AES before being uploaded to ensure security.
- **Retention Policy**: Automatically deletes backups older than 30 days to save space.
- **Email Notifications**: Sends email alerts for successful backups and error handling.

## Prerequisites
1. **Azure Setup**:
   - An Azure Storage Account with a Blob Storage container.
   - Access credentials: Storage Account Name and Access Key.
  
2. **PowerShell Modules**:
   - Az PowerShell Module (`Install-Module -Name Az -AllowClobber`)
   - Send-MailMessage for email notifications.
     
3. **SMTP Settings** for email notifications.
   
5. **AES Encryption Key**:
   - A pre-generated AES encryption key for encrypting files. You can generate one using PowerShell or other tools.

## Script Usage

### Configuration
1. **Set Parameters**:
   Open the script and modify the following variables to match your environment:

   ```powershell
   $BackupSource = "C:\Path\To\Backup"  # Directory to back up
   $StorageAccountName = "yourstorageaccount"  # Azure Storage Account name
   $StorageAccountKey = "youraccesskey"  # Azure Storage Account key
   $ContainerName = "backup-container"  # Azure Blob Storage container name
   $SMTPServer = "smtp.example.com"  # SMTP server for email notifications
   $EmailFrom = "you@example.com"  # Sender email address
   $EmailTo = "recipient@example.com"  # Recipient email address
   $AESKeyPath = "C:\Path\To\AESKey.key"  # Path to the AES encryption key

2. **Encryption Key** :Ensure the AES key file exists and is securely stored.

## Encryption Key
Ensure the AES key file exists and is securely stored.

## Azure Connection
Authenticate using the Az module to interact with Azure:

```powershell
Connect-AzAccount
```

## Running the Script
1. Open PowerShell with administrative privileges.
2. Run the script:

```powershell
.\CloudBackup.ps1
```

## Scheduling Backups
To automate backups, schedule the script using Windows Task Scheduler:

1. Create a new task.
2. Set the trigger to your desired schedule (e.g., daily at 2 AM).
3. Add the script path in the "Action" tab.

## Detailed Workflow

### Encryption:
- Files are encrypted locally using the AES key before upload.
- Encrypted files are stored temporarily before being uploaded.

### Upload to Azure:
- Encrypted files are uploaded to the specified Blob Storage container.

### Retention Policy:
- The script lists all backups in the container and removes files older than 30 days.

### Email Notifications:
- **Success**: Sends an email with the list of backed-up files.
- **Failure**: Sends an error report detailing the issue.

## Error Handling
The script includes robust error handling to:
- Retry failed uploads.
- Log errors to a file (`BackupError.log` in the script directory).
- Notify the user of critical failures via email.

## Security Considerations
- Ensure the AES encryption key is stored securely and not hard-coded in the script.
- Use environment variables or secure secrets management for sensitive information like the Azure Storage Key and SMTP credentials.
- Limit access to the backup directory and script file to authorized users.

## Example Output

### Email Notification (Success):

```vbnet
Subject: Backup Successful - Cloud Backup Script
Body:
Backup completed successfully on 01/06/2025.
Files backed up:
  - document1.pdf
  - photo1.jpg

Retention policy applied: 3 files deleted from cloud storage.
```

### Email Notification (Failure):

```vbnet
Subject: Backup Failed - Cloud Backup Script
Body:
Backup failed on 01/06/2025.
Error details:
  - Connection to Azure failed.
  - File encryption error.

Check BackupError.log for more details.
```

Create a new task.
Set the trigger to your desired schedule (e.g., daily at 2 AM).
Add the script path in the "Action" tab.
Detailed Workflow
