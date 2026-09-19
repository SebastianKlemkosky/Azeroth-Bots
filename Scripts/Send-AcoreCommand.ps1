param(
    [Parameter(Mandatory = $true)]
    [string]$Command
)

$ErrorActionPreference = "Stop"

$secretFile = Join-Path $PSScriptRoot "soap-secrets.txt"

if (-not (Test-Path $secretFile)) {
    Write-Host "[ERROR] Missing soap-secrets.txt"
    exit 1
}

$secretLines = Get-Content -LiteralPath $secretFile

if ($secretLines.Count -lt 2) {
    Write-Host "[ERROR] soap-secrets.txt must contain username and password."
    exit 1
}

$username = $secretLines[0].Trim()
$password = $secretLines[1]

$escapedCommand =
    [System.Security.SecurityElement]::Escape($Command)

$body = @"
<?xml version="1.0" encoding="utf-8"?>
<SOAP-ENV:Envelope
 xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
 xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:xsd="http://www.w3.org/2001/XMLSchema"
 xmlns:ns1="urn:AC">
    <SOAP-ENV:Body>
        <ns1:executeCommand>
            <command>$escapedCommand</command>
        </ns1:executeCommand>
    </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
"@

$authString = "${username}:${password}"
$authBytes = [System.Text.Encoding]::ASCII.GetBytes($authString)
$authBase64 = [Convert]::ToBase64String($authBytes)

$headers = @{
    Authorization = "Basic $authBase64"
}

try {
    $response = Invoke-WebRequest `
        -Uri "http://127.0.0.1:7878/" `
        -Method POST `
        -Headers $headers `
        -ContentType "text/xml; charset=utf-8" `
        -Body $body `
        -UseBasicParsing `
        -TimeoutSec 10

    [xml]$xmlResponse = $response.Content

    $result =
        $xmlResponse.SelectSingleNode(
            "//*[local-name()='result']"
        )

    if ($result) {
        Write-Host $result.InnerText.Trim()
    }

    exit 0
}
catch {
    Write-Host "[ERROR] SOAP command failed:"
    Write-Host $_.Exception.Message
    exit 1
}