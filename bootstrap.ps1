# Creates a portable development environment that uses Node.js and npm.
# Copyright 2014 Wong Yong Jie. See LICENSE for details.

# Versions of stuff.
$node_version = "6.9.1"
$npm_version = "3.10.8"

# Common variables.
$runtime_dir = "{0}\.runtime" -f $pwd
$path_to_node = "{0}\node.exe" -f $runtime_dir
$path_to_npm_archive = "{0}\npm.zip" -f $runtime_dir
$path_to_npm = "{0}\node_modules\npm" -f $runtime_dir

# Create the runtime directory.
New-Item -ItemType directory -Path $runtime_dir -Force | Out-Null

# Import ZIP file support from .NET.
Add-Type -AssemblyName "System.IO.Compression.FileSystem"

# Download Node.js.
if (-Not (Test-Path $path_to_node)) {
    # Determine the appropriate binary for the architecture.
    Write-Host -NoNewline "Downloading Node.js runtime... "
    If ($env:processor_architecture -eq "AMD64") {
        $script:node_url = "http://nodejs.org/dist/v{0}/win-x64/node.exe" -f $node_version
    } ElseIf ($env:processor_architecture -eq "x86") {
        $script:node_url = "http://nodejs.org/dist/v{0}/win-x86/node.exe" -f $node_version
    } Else {
        throw "Unsupported architecture found."
    }

    # Download the binary.
    Start-BitsTransfer -Source $node_url -Destination $path_to_node -DisplayName "Node.js"
    Write-Host -ForegroundColor green "OK"
}

# Download NPM.
if (-Not (Test-Path $path_to_npm)) {
    Write-Host -NoNewline "Downloading Node Package Manager (NPM)... "
    $npm_url = "https://github.com/npm/npm/archive/v{0}.zip" -f $npm_version

    Start-BitsTransfer -Source $npm_url -Destination $path_to_npm_archive -DisplayName "Node Package Manager (NPM)"
    Write-Host -ForegroundColor green "OK"

    # Extract the NPM archive.
    Write-Host -NoNewline "Extracting the NPM archive... "
    [IO.Compression.ZipFile]::ExtractToDirectory($path_to_npm_archive, $runtime_dir)
    New-Item -Path $runtime_dir -ItemType "directory" -Name "node_modules" | Out-Null
    Move-Item -Path ("{0}\npm-{1}" -f $runtime_dir,$npm_version) -Destination $path_to_npm
    Copy-Item -Path ("{0}\bin\npm.cmd" -f $path_to_npm) -Destination $runtime_dir
    Write-Host -ForegroundColor green "OK"

    # Remove the archive.
    Remove-Item $path_to_npm_archive
}

# Return the binaries to stdout.
Write-Host $runtime_dir
