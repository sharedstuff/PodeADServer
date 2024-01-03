$InvokeRestMethodParams = @{
    Uri = 'http://localhost/Get/ADUser'
    Method = 'GET'
    ContentType = 'application/json'
    Body = @{
        Filter = '*'
    } | ConvertTo-Json -Compress
}

Invoke-RestMethod @InvokeRestMethodParams
