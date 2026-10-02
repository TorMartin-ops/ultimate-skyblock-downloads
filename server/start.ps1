<#
.SYNOPSIS
    Runs the Voidhome server: backup, start, and start again after /skyblock restart.

.DESCRIPTION
    Every start:
      1. Zips the world folder (level-name in server.properties, default "world") into
         backups\, keeping the newest 10 of these zips.
      2. Runs: java -Xms2G -Xmx4G -jar fabric-server-launch.jar nogui
    When the server stops:
      - if ultimateskyblock\restart.json exists (written by /skyblock restart), the server
        starts again, and the mod archives the old world and creates a fresh one;
      - with -RestartOnCrash, a non-zero exit code also starts it again (it gives up after
        3 crashes in a row within 2 minutes of starting);
      - otherwise the script ends.
    Stop the server with the "stop" command in its console, not by closing the window.

.PARAMETER RestartOnCrash
    Start the server again when it exits with an error.

.PARAMETER Java
    The java.exe to use. Default: the Minecraft Launcher's Java 25, JAVA_HOME, or java on PATH.

.EXAMPLE
    .\start.bat -RestartOnCrash
#>
[CmdletBinding()]
param(
    [switch]$RestartOnCrash,
    [string]$Java
)

$ErrorActionPreference = 'Stop'
$ServerDir = $PSScriptRoot
$KeepBackups = 10
$MarkerFile = Join-Path $ServerDir 'ultimateskyblock\restart.json'
$StoreJava = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.4297127D64EC6_8wekyb3d8bbwe\LocalCache\Local\runtime\java-runtime-epsilon\windows-x64\java-runtime-epsilon\bin\java.exe'

function Write-Note([string]$Text) { Write-Host "[start] $Text" -ForegroundColor Cyan }
function Write-Problem([string]$Text) { Write-Host "[start] $Text" -ForegroundColor Yellow }

function Get-JavaMajor([string]$Exe) {
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $Exe
        $psi.Arguments = '-version'
        $psi.UseShellExecute = $false
        $psi.RedirectStandardError = $true
        $psi.RedirectStandardOutput = $true
        $psi.CreateNoWindow = $true
        $proc = [Diagnostics.Process]::Start($psi)
        $text = $proc.StandardError.ReadToEnd() + $proc.StandardOutput.ReadToEnd()
        $proc.WaitForExit()
        $m = [regex]::Match($text, 'version "(\d+)(?:\.(\d+))?')
        if (-not $m.Success) { return 0 }
        $major = [int]$m.Groups[1].Value
        if ($major -eq 1 -and $m.Groups[2].Success) { $major = [int]$m.Groups[2].Value }
        return $major
    } catch {
        return 0
    }
}

function Find-Java25 {
    $candidates = New-Object System.Collections.ArrayList
    [void]$candidates.Add($StoreJava)
    [void]$candidates.Add((Join-Path $env:APPDATA '.minecraft\runtime\java-runtime-epsilon\windows-x64\java-runtime-epsilon\bin\java.exe'))
    if ($env:JAVA_HOME) { [void]$candidates.Add((Join-Path $env:JAVA_HOME 'bin\java.exe')) }
    $onPath = Get-Command java.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($onPath) { [void]$candidates.Add($onPath.Path) }
    foreach ($c in $candidates) {
        if ((Test-Path -LiteralPath $c -PathType Leaf) -and (Get-JavaMajor $c) -ge 25) { return $c }
    }
    return $null
}

function ConvertFrom-PropertyValue([string]$Value) {
    # Undoes .properties escapes: a backslash before a character, and backslash-u hex codes.
    $evaluator = [Text.RegularExpressions.MatchEvaluator] {
        param($m)
        $s = $m.Groups[1].Value
        if ($s.Length -eq 5) { return [string][char][Convert]::ToInt32($s.Substring(1), 16) }
        if ($s -eq 't') { return "`t" }
        return $s
    }
    return [regex]::Replace($Value, '\\(u[0-9a-fA-F]{4}|.)', $evaluator)
}

function Get-LevelName {
    $file = Join-Path $ServerDir 'server.properties'
    if (Test-Path -LiteralPath $file -PathType Leaf) {
        foreach ($line in [IO.File]::ReadAllLines($file)) {
            $m = [regex]::Match($line, '^\s*level-name\s*[=:]\s*(.*?)\s*$')
            if ($m.Success -and $m.Groups[1].Value) { return (ConvertFrom-PropertyValue $m.Groups[1].Value) }
        }
    }
    return 'world'
}

function Get-MarkerStamp {
    if (Test-Path -LiteralPath $MarkerFile -PathType Leaf) { return (Get-Item -LiteralPath $MarkerFile).LastWriteTimeUtc.Ticks }
    return $null
}

function Backup-World([string]$Level) {
    $world = Join-Path $ServerDir $Level
    if (-not (Test-Path -LiteralPath $world -PathType Container)) {
        Write-Note "No world folder '$Level' yet, so there is nothing to back up."
        return
    }
    $backups = Join-Path $ServerDir 'backups'
    [void][IO.Directory]::CreateDirectory($backups)
    Get-ChildItem -LiteralPath $backups -Filter '*.zip.partial' -File | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }
    $safe = $Level -replace '[\\/:*?"<>|]', '_'
    $zip = Join-Path $backups ('{0}_{1}.zip' -f $safe, (Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'))
    while (Test-Path -LiteralPath $zip) {
        # Two starts within one second would get the same name.
        Start-Sleep -Milliseconds 300
        $zip = Join-Path $backups ('{0}_{1}.zip' -f $safe, (Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'))
    }
    $partial = "$zip.partial"
    Write-Note "Backing up '$Level' to backups\$(Split-Path -Leaf $zip) ..."
    try {
        Add-Type -AssemblyName System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [IO.Compression.ZipFile]::CreateFromDirectory($world, $partial, [IO.Compression.CompressionLevel]::Fastest, $true)
        [IO.File]::Move($partial, $zip)
    } catch {
        Write-Problem "Backup failed: $($_.Exception.Message)"
        if (Test-Path -LiteralPath $partial) { Remove-Item -LiteralPath $partial -Force }
        return
    }
    Write-Note ('Backup done ({0:N1} MB).' -f ((Get-Item -LiteralPath $zip).Length / 1MB))
    # Only zips made by this script are rotated; anything else in backups\ is left alone.
    $pattern = '^' + [regex]::Escape($safe) + '_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}\.zip$'
    $old = @(Get-ChildItem -LiteralPath $backups -Filter '*.zip' -File | Where-Object { $_.Name -match $pattern } |
        Sort-Object Name -Descending | Select-Object -Skip $KeepBackups)
    foreach ($f in $old) {
        Remove-Item -LiteralPath $f.FullName -Force
        Write-Note "Removed old backup $($f.Name)"
    }
}

# ---------------------------------------------------------------- checks

Set-Location -LiteralPath $ServerDir
if (-not (Test-Path -LiteralPath (Join-Path $ServerDir 'fabric-server-launch.jar') -PathType Leaf)) {
    Write-Problem 'fabric-server-launch.jar is missing here. Run server\setup-server.ps1 first.'
    exit 1
}
$eulaFile = Join-Path $ServerDir 'eula.txt'
$eulaOk = (Test-Path -LiteralPath $eulaFile -PathType Leaf) -and ([IO.File]::ReadAllText($eulaFile) -match '(?m)^[ \t]*eula[ \t]*=[ \t]*true[ \t]*\r?$')
if (-not $eulaOk) {
    Write-Problem 'The Minecraft EULA is not accepted yet. Read https://aka.ms/MinecraftEULA, then run setup-server.ps1 again with -AcceptEula.'
    exit 1
}
if ($Java) {
    if (-not (Test-Path -LiteralPath $Java -PathType Leaf)) { Write-Problem "Java not found: $Java"; exit 1 }
} else {
    $Java = Find-Java25
    if (-not $Java) {
        Write-Problem 'Java 25 or newer was not found. Install it with: winget install EclipseAdoptium.Temurin.25.JRE'
        exit 1
    }
}
Write-Note "Java: $Java"

# ---------------------------------------------------------------- loop

$quickCrashes = 0
$code = 0
while ($true) {
    $level = Get-LevelName
    Backup-World $level
    $markerBefore = Get-MarkerStamp
    Write-Note "Starting the server (world '$level'). Type stop in this window to shut it down."
    $clock = [Diagnostics.Stopwatch]::StartNew()
    $saved = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { & $Java -Xms2G -Xmx4G -jar fabric-server-launch.jar nogui } finally { $ErrorActionPreference = $saved }
    $code = $LASTEXITCODE
    $clock.Stop()

    $markerAfter = Get-MarkerStamp
    if ($null -ne $markerAfter) {
        if ($null -ne $markerBefore -and $markerAfter -eq $markerBefore) {
            Write-Problem 'ultimateskyblock\restart.json is still there after a whole run, so this version of the mod did not handle it. Delete the file and start again.'
            $code = 1
            break
        }
        Write-Note 'Restart requested (/skyblock restart). Starting again; the mod archives the old world and makes a new one.'
        $quickCrashes = 0
        continue
    }
    if ($RestartOnCrash -and $code -ne 0) {
        if ($clock.Elapsed.TotalSeconds -lt 120) { $quickCrashes++ } else { $quickCrashes = 1 }
        if ($quickCrashes -ge 3) {
            Write-Problem "The server crashed 3 times in a row within 2 minutes of starting (exit code $code). Not restarting; see logs\latest.log."
            break
        }
        Write-Problem "The server exited with code $code. Restarting in 10 seconds (Ctrl+C cancels)..."
        Start-Sleep -Seconds 10
        continue
    }
    Write-Note "The server stopped (exit code $code)."
    break
}
exit $code
