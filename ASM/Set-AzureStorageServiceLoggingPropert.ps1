$Ctx = New-AzureStorageContext "<ストレージ アカウント名>" -StorageAccountKey "<アクセス キー>"
Set-AzureStorageServiceLoggingProperty -ServiceType Blob -LoggingOperations read,write,delete -RetentionDays 5 -Context $Ctx
Set-AzureStorageServiceLoggingProperty -ServiceType Table -LoggingOperations read,write,delete -RetentionDays 5 -Context $Ctx
Set-AzureStorageServiceLoggingProperty -ServiceType Queue -LoggingOperations read,write,delete -RetentionDays 5 -Context $Ctx