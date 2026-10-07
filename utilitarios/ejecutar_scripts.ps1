param(
    [string]$Server = 'localhost,1433',
    [string]$Username = 'sa',
    [int]$StartAt = 1
)

$ErrorActionPreference = 'Stop'

$sqlcmd = Get-Command sqlcmd -ErrorAction Stop
$scripts = Get-ChildItem -Path $PSScriptRoot -Recurse -File -Filter '*.sql' |
    Sort-Object -Property FullName

if (-not $scripts) {
    throw "No se encontraron archivos SQL en '$PSScriptRoot'."
}
if ($StartAt -lt 1 -or $StartAt -gt $scripts.Count) {
    throw "StartAt debe estar entre 1 y $($scripts.Count)."
}

$securePassword = Read-Host "Contrasena para $Username en $Server" -AsSecureString
$passwordPointer = [IntPtr]::Zero
$previousPassword = $env:SQLCMDPASSWORD

try {
    $passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    $env:SQLCMDPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)

    for ($index = $StartAt - 1; $index -lt $scripts.Count; $index++) {
        $script = $scripts[$index]
        $relativePath = $script.FullName.Substring($PSScriptRoot.Length + 1)
        Write-Host "[$($index + 1)/$($scripts.Count)] $relativePath"

        & $sqlcmd.Source -S $Server -U $Username -b -r 1 -C -f 'i:65001' -i $script.FullName
        if ($LASTEXITCODE -ne 0) {
            throw "sqlcmd fallo con codigo $LASTEXITCODE al ejecutar '$relativePath'. Se detuvo el proceso."
        }
    }

    Write-Host "Se ejecutaron correctamente los $($scripts.Count) archivos SQL."
}
finally {
    if ($null -eq $previousPassword) {
        Remove-Item Env:\SQLCMDPASSWORD -ErrorAction SilentlyContinue
    }
    else {
        $env:SQLCMDPASSWORD = $previousPassword
    }

    if ($passwordPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
    }
}