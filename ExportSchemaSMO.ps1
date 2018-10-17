# Usage:  powershell ExportSchemaSMO.ps1 "Server" "Database" "C:\<ScriptPath>"

# Start Script
# Set-ExecutionPolicy RemoteSigned

# Set-ExecutionPolicy -ExecutionPolicy:Unrestricted -Scope:LocalMachine
function GenerateDBScript([string]$serverName, [string]$dbname, [string]$scriptpath)
{
  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName("System.Data") | Out-Null
  $server = New-Object "Microsoft.SqlServer.Management.Smo.Server" $serverName
  $server.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.View], "IsSystemObject")
  $database = New-Object "Microsoft.SqlServer.Management.Smo.Database"
  $database = $server.Databases[$dbname]
  $scripter = New-Object "Microsoft.SqlServer.Management.Smo.Scripter"
  $dependencyType = New-Object "Microsoft.SqlServer.Management.Smo.DependencyType"
  $scripter.Server = $server
  $options = New-Object "Microsoft.SqlServer.Management.Smo.ScriptingOptions"
  $options.AllowSystemObjects = $false
  $options.IncludeDatabaseContext = $true
  $options.IncludeIfNotExists = $false
  $options.ClusteredIndexes = $true
  $options.Default = $true
  $options.DriAll = $true
  $options.Indexes = $true
  $options.NonClusteredIndexes = $true
  $options.IncludeHeaders = $false
  $options.ToFileOnly = $true
  $options.AppendToFile = $false
  $options.ScriptDrops = $false
  $options.FileName = $scriptpath +'\'+ $dbname + ".sql"
  $options.ScriptSchema = $true
  $options.WithDependencies = $true

  # Set options for SMO.Scripter
  $scripter.Options = $options

  # Create collection
  $collection = New-Object Microsoft.SqlServer.Management.Smo.UrnCollection
 
  # Add tables
  $item = New-Object Microsoft.SqlServer.Management.Smo.Table

  foreach ($item in $database.Tables){
    $collection.Add($item.Urn)
    Write-Host $item.Name
  }

  # Add views
  $item = New-Object Microsoft.SqlServer.Management.Smo.View
  foreach ($item in $database.Views){
   $collection.Add($item.Urn)
   Write-Host $item.Name
  }
 
  # Dump to file
  $scripter.Script($collection)
} 

#=============
# Execute
#=============
# GenerateDBScript $args[0] $args[1] $args[2]
GenerateDBScript "localhost" "AdventureWorks2014" "c:\tmp"
