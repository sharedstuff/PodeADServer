#Requires -Modules @{ ModuleName='Pode'; GUID='e3ea217c-fc3d-406b-95d5-4304ab06c6af'; ModuleVersion='2.9.0' }
#Requires -Modules @{ ModuleName='ActiveDirectory'; GUID='43c15630-959c-49e4-a977-758c5cc93408'; ModuleVersion='1.0.1.0' }
#Requires -RunAsAdministrator
#Requires -Version 7.4

# Test: Start-PodeServer
# https://pode.readthedocs.io/en/latest/Tutorials/Routes/Examples/RestApiSessions

$ActiveDirectoryCommands = Get-Command -Module ActiveDirectory

$PodeServerParams = @{
    Thread = 4
}
Start-PodeServer @PodeServerParams {

    # Endpoint / Listener
    $PodeEndpointParams = @{
        Address  = '*'
        Port     = 80
        Protocol = 'HTTP'
    }
    Add-PodeEndpoint @PodeEndpointParams

    # Routes
    $PodeRoutes = @(

        @{

            Path        = '/'
            Method      = @('GET')
            ScriptBlock = {
                Get-PodeRoute | Where-Object Path -like '/*' | Select-Object Path, Method | Sort-Object Path, Method | ConvertTo-Json -Depth 1 | Write-PodeTextResponse -ContentType 'application/json'
            }

        }

        @{

            Path        = '/:Verb/:Noun'
            Method      = @('GET', 'POST')
            ScriptBlock = {

                # Shorthands
                $ActiveDirectoryCommands = $using:ActiveDirectoryCommands
                $Verb = $WebEvent.Parameters['Verb']
                $Noun = $WebEvent.Parameters['Noun']

                $Payload = $WebEvent.Data | ConvertTo-Json -Depth 99 -WarningAction SilentlyContinue | ConvertFrom-Json -AsHashtable

                $CommandName = $ActiveDirectoryCommands.Name | Where-Object { $_.ToLower() -eq ($Verb.ToLower(), $Noun.ToLower() -join '-') }

                # Generate Response
                $Response = [ordered]@{
                    context = 'PodeADServer'
                    type    = 'Response'
                }

                if ($CommandName -in $ActiveDirectoryCommands.Name) {

                    try {
                        $Result = & $CommandName @Payload | Select-Object *
                    }
                    catch {
                        $Response.Error = [string]$_
                    }

                    if ($Result) {
                        $Response.Count = $Result.Count
                        $Response.Data = $Result
                    }

                }
                else {
                    $Response.Error = 'Endpoint at URL {0}/{1} / Command with Name {0}-{1} (Verb-Noun) was not found' -f $Verb, $Noun
                }

                $Response | ConvertTo-Json -Depth 99 -WarningAction SilentlyContinue | Write-PodeTextResponse -ContentType 'application/json'

            }

        }

    )

    $PodeRoutes | ForEach-Object { Add-PodeRoute @_ }

}
