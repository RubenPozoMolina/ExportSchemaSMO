# Usage:  powershell ExportSchemaLikeSMSS.ps1 "Server" "Database" "C:\<ScriptPath>"

# Start Script
# Set-ExecutionPolicy RemoteSigned
# Set-ExecutionPolicy -ExecutionPolicy:Unrestricted -Scope:LocalMachine

function GenerateDBScript([string]$serverName, [string]$dbname, [string]$scriptpath)
{
    # Loading required libraries
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("System.Data") | Out-Null
    
    # Export datbase definition 
    $server = New-Object "Microsoft.SqlServer.Management.Smo.Server" $serverName
    $server.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.View], "IsSystemObject")
    $database = New-Object "Microsoft.SqlServer.Management.Smo.Database"
    $database = $server.Databases[$dbname]
    $options = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
    $options.FileName = $scriptpath +'\'+ $dbname + ".sql"
    $database.Script($options)

    # Options for DDL transfer
    $options.WithDependencies = $true
    $options.IncludeIfNotExists = $false
    $options.ScriptBatchTerminator = $true
    $options.ScriptSchema = $true
    $options.DriAll = $true
    $options.NoCollation = $true
    $options.Indexes = $true
    $options.AnsiPadding = $true
    $options.ClusteredIndexes = $true
    $options.Default = $true
    $options.AllowSystemObjects = $false
    $options.IncludeDatabaseContext = $true
    $options.ExtendedProperties = $true
    $options.AppendToFile = $true
    
    # Transfer
    $transfer = New-Object "Microsoft.SqlServer.Management.Smo.Transfer"
    $transfer.Database = $database
    $transfer.Options = $options
    $transfer.CreateTargetDatabase = $true
    $transfer.CopyAllObjects = $true
    $transfer.CopyAllStoredProcedures = $true
    $transfer.CopyAllPartitionFunctions = $true
    $transfer.ScriptTransfer()
} 

#=============
# Execute
#=============
GenerateDBScript $args[0] $args[1] $args[2]
# GenerateDBScript "localhost" "AdventureWorks2014" "c:\tmp"
