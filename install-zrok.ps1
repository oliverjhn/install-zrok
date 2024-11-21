# Download latest release
$repoName = "openziti/zrok"
$assetPattern = "*_windows_amd64.tar.gz"
$extractDirectory = "C:\Users\$env:USERNAME\Downloads"


$releasesUri = "https://api.github.com/repos/$repoName/releases/latest"
$asset = (Invoke-WebRequest $releasesUri | ConvertFrom-Json).assets | Where-Object name -like $assetPattern
$downloadUri = $asset.browser_download_url

$extractPath = [System.IO.Path]::Combine($extractDirectory, $asset.name)
Invoke-WebRequest -Uri $downloadUri -Out $extractPath

# Extract and Install
cd "C:\Users\$env:USERNAME\Downloads"

# Get the actual filename that matches our pattern
$zrokFile = Get-ChildItem -Path "zrok_*_windows_amd64.tar.gz" | Select-Object -First 1

if ($null -eq $zrokFile) {
    Write-Error "Could not find zrok archive file"
    exit 1
}

# Extract using the actual filename
New-Item -Path "$env:TEMP\zrok" -ItemType Directory -ErrorAction SilentlyContinue
tar -xf $zrokFile.Name -C "$env:TEMP\zrok"

$source = Join-Path -Path $env:TEMP -ChildPath "zrok\zrok.exe"
# $destination = Join-Path -Path $env:USERPROFILE -ChildPath "bin\zrok.exe"
$destination = Join-Path -Path $env:USERPROFILE -ChildPath "bin"
New-Item -Path $destination -ItemType Directory -ErrorAction SilentlyContinue
Copy-Item -Path $source -Destination $destination
$env:path += ";"+$destination

# Update PATH permanently (no admin required - user level only)
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$destination*") {
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$userPath;$destination",
        "User"
    )
}

# Update current session PATH
# $env:Path = [Environment]::GetEnvironmentVariable("Path", "User")
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")


zrok version