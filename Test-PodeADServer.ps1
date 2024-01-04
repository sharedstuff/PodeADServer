$InvokeRestMethodParams = @{
    Uri         = 'http://localhost/Get/ADUser'
    Method      = 'GET'
    ContentType = 'application/json'
    Body        = @{
        Filter     = '*'
        Properties = @(
            'ObjectGUID'
            'SID'
            'Name'
        )
    } | ConvertTo-Json
}

$Response = Invoke-RestMethod @InvokeRestMethodParams
if ($Response.Error) { throw $Response.Error }
if ($Response.Count -eq 0) { throw 'No Result / Count=0' }
$Response.Data
