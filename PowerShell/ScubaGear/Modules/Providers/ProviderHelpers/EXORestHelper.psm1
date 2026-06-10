Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "../../Utility/Utility.psm1") -Function Invoke-ScubaRestMethod

function Get-ExchangeOnlineScope {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("commercial", "gcc", "gcchigh", "dod")]
        [string]$M365Environment
    )

    switch ($M365Environment.ToLower()) {
        "commercial" { return "https://outlook.office365.com/.default" }
        "gcc"        { return "https://outlook.office365.com/.default" }
        "gcchigh"    { return "https://outlook.office365.us/.default" }
        "dod"        { return "https://outlook-dod.office365.us/.default" }
    }
}

function Get-ExchangeOnlineApiEndpoint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$TenantDomain,

        [Parameter(Mandatory = $true)]
        [ValidateSet("commercial", "gcc", "gcchigh", "dod")]
        [string]$M365Environment,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

    $AdminApiFrontDoorBaseUri = switch ($M365Environment.ToLower()) {
        "commercial" { "https://outlook.office365.com" }
        "gcc"        { "https://outlook.office365.com" }
        "gcchigh"    { "https://outlook.office365.us" }
        "dod"        { "https://outlook-dod.office365.us" }
    }

    $BackendSuffix = switch ($M365Environment.ToLower()) {
        "commercial" { ".outlook.office365.com" }
        "gcc"        { ".outlook.office365.com" }
        "gcchigh"    { ".outlook.office365.us" }
        "dod"        { ".outlook-dod.office365.us" }
    }

    $Headers = @{
        "Authorization"   = "Bearer $AccessToken"
        "X-AnchorMailbox" = "UPN:SystemMailbox{bb558c35-97f1-4cb9-8ff7-d53741dc928c}@$TenantDomain"
    }

    $DefaultInvokeEndpoint = "$AdminApiFrontDoorBaseUri/adminapi/beta/$TenantId/InvokeCommand"

    $Handler = $null
    $HttpClient = $null
    $Request = $null
    $Response = $null

    try {
        $FrontDoorEndpoint = "$AdminApiFrontDoorBaseUri/AdminApi/v1.0/$TenantId/EXOModuleFile"

        $Handler = [System.Net.Http.HttpClientHandler]::new()
        $Handler.AllowAutoRedirect = $false
        $HttpClient = [System.Net.Http.HttpClient]::new($Handler)
        $Request = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get, $FrontDoorEndpoint)

        foreach ($Header in $Headers.GetEnumerator()) {
            $null = $Request.Headers.TryAddWithoutValidation($Header.Key, $Header.Value)
        }

        $Response = $HttpClient.SendAsync(
            $Request,
            [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead
        ).GetAwaiter().GetResult()

        if ((([int]$Response.StatusCode) -ge 300) -and (([int]$Response.StatusCode) -lt 400) -and $Response.Headers.Location) {
            $RedirectUri = $Response.Headers.Location
            if (-not $RedirectUri.IsAbsoluteUri) {
                $RedirectUri = [Uri]::new([Uri]$AdminApiFrontDoorBaseUri, $RedirectUri)
            }
            $Prefix = $RedirectUri.Host.Split('.')[0]
            return "https://$Prefix$BackendSuffix/adminapi/beta/$TenantId/InvokeCommand"
        }

        return $DefaultInvokeEndpoint
    }
    catch {
        throw "Failed to resolve Exchange Online API endpoint: $($_.Exception.Message)"
    }
    finally {
        if ($Response) {
            $Response.Dispose()
        }
        if ($Request) {
            $Request.Dispose()
        }
        if ($HttpClient) {
            $HttpClient.Dispose()
        }
        if ($Handler) {
            $Handler.Dispose()
        }
    }
}

function Invoke-EXORestMethod {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CmdletName,

        [Parameter(Mandatory = $true)]
        [string]$ApiEndpoint,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken,

        [Parameter(Mandatory = $false)]
        [hashtable]$Parameters = @{}
    )

    $Headers = @{
        "Authorization"     = "Bearer $AccessToken"
        "Prefer"            = "odata.maxpagesize=1000"
        "X-ResponseFormat"  = "json"
        "client-request-id" = [guid]::NewGuid().ToString()
        "User-Agent"        = "ScubaGear"
    }

    $Body = @{
        CmdletInput = @{
            CmdletName = $CmdletName
            Parameters = $Parameters
        }
    } | ConvertTo-Json -Depth 5

    try {
        $Response = Invoke-RestMethod -Method POST -Uri $ApiEndpoint -Headers $Headers -Body $Body -ContentType "application/json"
        return $Response.value
    }
    catch {
        throw "Exchange Online API call '$CmdletName' failed: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function @(
    'Get-ExchangeOnlineScope',
    'Get-ExchangeOnlineApiEndpoint',
    'Invoke-EXORestMethod'
)
