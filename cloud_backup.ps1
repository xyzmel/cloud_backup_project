# Automated Backup to Azure Blob Storage

# Import Azure module (requires Az module installed)
Import-Module Az.Storage

# Configuration, change desired directories.
$SourceDirectories = @(
    "$env:USERPROFILE\Documents"
    "$env:USERPROFILE\Desktop"
)

$BlobStorageAccountName = "yourstorageaccount"
$BlobStorageContainerName = "backups"
$BlobStorageKey = "your_storage_account_key"
$BackupRetentionDays = 30
$EncryptionKey = (Get-Random -Minimum 100000 -Maximum 999999).ToString() # Replace with a fixed key in production
$EmailSettings = @{
    SmtpServer = "smtp.yourdomain.com"
    Port = 587
    From = "backup@yourdomain.com"
    To = "admin@yourdomain.com"
    SubjectSuccess = "Backup Completed Successfully"
    SubjectFailure = "Backup Failed"
    Credential = Get-Credential
}

# Create encryption function
Function Encrypt-File {
    param (
        [string]$InputFile,
        [string]$OutputFile,
        [string]$Key
    )
    $Aes = [System.Security.Cryptography.Aes]::Create()
    $Aes.Key = [System.Text.Encoding]::UTF8.GetBytes($Key.PadRight(32).Substring(0, 32))
    $Aes.IV = [byte[]](1..16) # Example IV, replace with a better initialization vector in production

    $Encryptor = $Aes.CreateEncryptor()
    [System.IO.File]::Open($InputFile, 'Open', 'Read') | ForEach-Object {
        $EncryptedStream = [System.Security.Cryptography.CryptoStream]::new($_, $Encryptor, "Write")
        $EncryptedStream.CopyTo($OutputFile)
        $EncryptedStream.Close()
    }
    $Aes.Dispose()
}

# Backup function
Function Perform-Backup {
    param (
        [string[]]$Directories,
        [string]$ContainerName,
        [string]$AccountName,
        [string]$AccountKey,
        [string]$Key
    )

    $Context = New-AzStorageContext -StorageAccountName $AccountName -StorageAccountKey $AccountKey

    foreach ($Directory in $Directories) {
        if (-Not (Test-Path $Directory)) {
            Write-Host "Directory not found: $Directory" -ForegroundColor Yellow
            continue
        }

        $Files = Get-ChildItem -Path $Directory -Recurse -File
        foreach ($File in $Files) {
            $TempFile = "$($File.FullName).enc"
            Encrypt-File -InputFile $File.FullName -OutputFile $TempFile -Key $Key

            $BlobName = "$($File.DirectoryName -replace "[:\\/]", "_")/$($File.Name).enc"
            Set-AzStorageBlobContent -File $TempFile -Container $ContainerName -Blob $BlobName -Context $Context

            Remove-Item $TempFile
            Write-Host "Uploaded and encrypted: $File.FullName"
        }
    }

    # Retention Policy
    $Blobs = Get-AzStorageBlob -Container $ContainerName -Context $Context
    $CutoffDate = (Get-Date).AddDays(-$BackupRetentionDays)
    foreach ($Blob in $Blobs) {
        if ($Blob.LastModified.DateTime -lt $CutoffDate) {
            Remove-AzStorageBlob -Blob $Blob.Name -Container $ContainerName -Context $Context
            Write-Host "Deleted old backup: $Blob.Name"
        }
    }
}

# Email notification function
Function Send-EmailNotification {
    param (
        [string]$Subject,
        [string]$Body
    )
    Send-MailMessage -SmtpServer $EmailSettings.SmtpServer `
                      -Port $EmailSettings.Port `
                      -From $EmailSettings.From `
                      -To $EmailSettings.To `
                      -Subject $Subject `
                      -Body $Body `
                      -Credential $EmailSettings.Credential
}

# Main script execution
Try {
    Perform-Backup -Directories $SourceDirectories -ContainerName $BlobStorageContainerName -AccountName $BlobStorageAccountName -AccountKey $BlobStorageKey -Key $EncryptionKey
    Send-EmailNotification -Subject $EmailSettings.SubjectSuccess -Body "Backup completed successfully."
} Catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Send-EmailNotification -Subject $EmailSettings.SubjectFailure -Body "Backup failed with error: $_"
}
