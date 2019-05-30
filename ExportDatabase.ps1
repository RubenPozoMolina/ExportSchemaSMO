# Usage:  powershell ExportDatabase.ps1 "Server" "Database" "C:\<ScriptPath>" "UserName" "Password" 

# Start Script
# Set-ExecutionPolicy RemoteSigned
# Set-ExecutionPolicy -ExecutionPolicy:Unrestricted -Scope:LocalMachine

function GenerateDBScript([string]$serverName, [string]$dbname, [string]$scriptpath, [string]$user, [string]$password)
{
    # Loading required libraries
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("System.Data") | Out-Null
    
    # Export datbase definition
    $connection = New-object "Microsoft.SqlServer.Management.Common.ServerConnection"
    $connection.ServerInstance = $servername
    $connection.LoginSecure = $false
    $connection.Login = $user
    $connection.Password = $password 
    $server = New-Object "Microsoft.SqlServer.Management.Smo.Server" $connection
    $server.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.View], "IsSystemObject")
    $database = New-Object "Microsoft.SqlServer.Management.Smo.Database"
    $database = $server.Databases[$dbname]
    $scripter = New-Object "Microsoft.SqlServer.Management.Smo.DependencyWalker"
    $options = New-Object "Microsoft.SqlServer.Management.Smo.ScriptingOptions"
    $options.FileName = $scriptpath +'\'+ $dbname + ".sql"
    
   # Options for DDL transfer
    $options.WithDependencies = $true
    $options.IncludeIfNotExists = $false
    $options.ScriptBatchTerminator = $true
    $options.ScriptSchema = $true
    $options.ScriptData = $true
    $options.DriAll = $true
    $options.NoCollation = $true
    $options.Indexes = $true
    $options.ClusteredIndexes = $true
    $options.Default = $true
    $options.AllowSystemObjects = $false
    $options.IncludeDatabaseContext = $true
    $options.ExtendedProperties = $true
    $options.AppendToFile = $true
    
    # Transfer
    $transfer = New-Object "Microsoft.SqlServer.Management.Smo.Transfer"
    $transfer.Database = $database
    $transfer.CopyAllObjects = $true;
    $transfer.CopyAllUsers = $true;
    $transfer.CopySchema = $true;
    $transfer.CopyData = $true;
    $transfer.CreateTargetDatabase = $true
    $transfer.CopyAllStoredProcedures = $true
    $transfer.CopyAllPartitionFunctions = $true
    $transfer.Options = $options
    $transfer.EnumScriptTransfer()

} 

#=============
# Execute
#=============
GenerateDBScript $args[0] $args[1] $args[2] $args[3] $args[4]
# GenerateDBScript "localhost" "AdventureWorks2014" "c:\tmp" "sa" "sa"
