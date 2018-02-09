#region Define variables
$date            = Get-Date -Format dd.MMM
$retentionPeriod = 6

$DBName          = "<DBNAME>"
$remoteStorage   = "<REMOTE_STORAGE_PATH>"
$fileName        = "<FILE_NAME>"
# NOTE: generate certificate using "Create-Certificate.sql"
$encryptorName   = "<ENCRYPTOR_NAME>"

$localBackupFolder = "<LOCAL_BACKUP_FOLDER>"
$localBackupFile   = $localBackupFolder+$fileName+$date+".bak"

# mail settings
$from       = "<FROM_EMAIL>" 
$to         = "TO_EMAIL"
$message    = "MESSAGE_TEXT"
$mailServer = "<SMTP_SERVER>"
#endregion

# Create encrypted backup
$encryptionOption = New-SqlBackupEncryptionOption -Algorithm Aes256 -EncryptorType ServerCertificate -EncryptorName $encryptorName
Backup-SqlDatabase -ServerInstance localhost -Database $DBName -BackupFile $localPath -EncryptionOption $encryptionOption

# Copy backup file to remote storage
New-PSDrive -Name BCK -PSProvider FileSystem -Root $remoteStorage
Copy-Item $localPath -Destination BCK:\

# Remove Old DB backup
$selection = ls BCK: | where {$_.Name -clike $fileName}

foreach($file in $selection)
{
    if($file.CreationTime -lt (Get-Date).AddDays(-$retentionPeriod))
    {
        Remove-Item -Path $file.PSPath
    }
}

Remove-Item $localPath
Remove-PSDrive BCK

Send-MailMessage -SmtpServer $mailServer -From $from `
                 -To $to -Subject $message