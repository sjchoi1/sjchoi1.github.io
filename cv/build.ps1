[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$sourceName = 'CV_sangjinchoi.tex'
$documentName = [System.IO.Path]::GetFileNameWithoutExtension($sourceName)
$buildDirectory = Join-Path $PSScriptRoot 'build'
$outputDirectory = Join-Path $PSScriptRoot 'output\pdf'
$builtPdf = Join-Path $buildDirectory "$documentName.pdf"
$publishedPdf = Join-Path $outputDirectory "$documentName.pdf"

$pdflatex = Get-Command pdflatex -ErrorAction Stop

New-Item -ItemType Directory -Path $buildDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$viewerNames = @('Acrobat', 'AcroRd32', 'SumatraPDF', 'FoxitPDFReader', 'PDFXEdit')
$openViewers = Get-Process -Name $viewerNames -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowTitle -like "*$documentName*" }

foreach ($viewer in $openViewers) {
    Write-Host "Closing open CV viewer: $($viewer.ProcessName)"
    if ($viewer.CloseMainWindow()) {
        $viewer.WaitForExit(3000) | Out-Null
    }
}

$arguments = @(
    '-interaction=nonstopmode'
    '-halt-on-error'
    '-file-line-error'
    "-output-directory=$buildDirectory"
    $sourceName
)

Push-Location $PSScriptRoot
try {
    for ($pass = 1; $pass -le 2; $pass++) {
        Write-Host "LaTeX pass $pass of 2"
        & $pdflatex.Source @arguments
        if ($LASTEXITCODE -ne 0) {
            throw "pdflatex failed on pass $pass with exit code $LASTEXITCODE."
        }
    }

    if (-not (Test-Path -LiteralPath $builtPdf)) {
        throw "Expected PDF was not created: $builtPdf"
    }

    $published = $false
    for ($attempt = 1; $attempt -le 60; $attempt++) {
        try {
            Copy-Item -LiteralPath $builtPdf -Destination $publishedPdf -Force
            $published = $true
            break
        }
        catch [System.IO.IOException] {
            if ($attempt -eq 60) {
                throw "Could not update $publishedPdf. Close any remaining PDF viewer or wait for OneDrive to release the file, then run the build again."
            }
            Start-Sleep -Milliseconds 500
        }
    }

    if (-not $published) {
        throw "The PDF compiled but could not be published."
    }

    Write-Host "Published PDF: $publishedPdf"
}
finally {
    Pop-Location
}
