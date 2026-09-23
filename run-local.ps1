$ErrorActionPreference = "Stop"

$listeners = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue
if ($listeners) {
    $listeners | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object {
        Stop-Process -Id $_ -Force
    }
}

$maven = (Get-Command mvn.cmd -ErrorAction SilentlyContinue).Source
if (-not $maven) {
    $maven = "C:\Program Files\Apache NetBeans\java\maven\bin\mvn.cmd"
}
if (-not (Test-Path $maven)) {
    throw "Maven was not found. Install Maven or set mvn.cmd on PATH."
}

& $maven jetty:run