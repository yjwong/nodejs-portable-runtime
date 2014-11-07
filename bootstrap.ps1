# Creates a portable development environment that uses Node.js and npm.
# Copyright 2014 Wong Yong Jie. See LICENSE for details.

# Common variables.
$runtime_dir = "{0}\.runtime" -f $pwd
$path_to_node = "{0}\node.exe" -f $runtime_dir
$path_to_npm_archive = "{0}\npm.zip" -f $runtime_dir
$path_to_npm = "{0}\npm.cmd" -f $runtime_dir

# Create the runtime directory.
New-Item -ItemType directory -Path $runtime_dir -Force | Out-Null

# Download Node.js.
if (-Not (Test-Path $path_to_node)) {
    # Determine the appropriate binary for the architecture.
    Write-Host -NoNewline "Downloading Node.js runtime... "
    If ($env:processor_architecture -eq "AMD64") {
        $script:node_url = "http://nodejs.org/dist/v0.10.33/x64/node.exe"
    } ElseIf ($env:processor_architecture -eq "x86") {
        $script:node_url = "http://nodejs.org/dist/v0.10.33/node.exe"
    } Else {
        throw "Unsupported architecture found."
    }

    # Download the binary.
    $node_web_client = New-Object System.Net.WebClient

    Register-ObjectEvent -InputObject $node_web_client `
                         -EventName DownloadProgressChanged `
                         -SourceIdentifier WebClient.DownloadProgressChanged `
                         -Action {
                             Write-Progress -Activity "Downloading: $($EventArgs.ProgressPercentage)% Completed" `
                                            -Status $node_url `
                                            -PercentComplete $EventArgs.ProgressPercentage
                         } | Out-Null

    Register-ObjectEvent -InputObject $node_web_client `
                         -EventName DownloadFileCompleted `
                         -SourceIdentifier WebClient.DownloadFileCompleted `
                         -Action {
                             Unregister-Event WebClient.DownloadProgressChanged
                             Unregister-Event WebClient.DownloadFileCompleted
                             New-Event NodeDownloadFileCompleted
                         } | Out-Null

    $node_web_client.DownloadFileAsync($node_url, $path_to_node)

    Wait-Event -SourceIdentifier NodeDownloadFileCompleted | Out-Null
    $node_web_client.Dispose()
    Write-Host -ForegroundColor green "OK"
}

# Download NPM.
if (-Not (Test-Path $path_to_npm)) {
    Write-Host -NoNewline "Downloading Node Package Manager (NPM)... "
    $npm_web_client = New-Object System.Net.WebClient
    $npm_url = "http://nodejs.org/dist/npm/npm-1.4.12.zip"

    Register-ObjectEvent -InputObject $npm_web_client `
                         -EventName DownloadProgressChanged `
                         -SourceIdentifier WebClient.DownloadProgressChanged `
                         -Action {
                             Write-Progress -Activity "Downloading: $($EventArgs.ProgressPercentage)% Completed" `
                                            -Status $npm_url `
                                            -PercentComplete $EventArgs.ProgressPercentage
                         } | Out-Null

    Register-ObjectEvent -InputObject $npm_web_client `
                         -EventName DownloadFileCompleted `
                         -SourceIdentifier WebClient.DownloadFileCompleted `
                         -Action {
                             Unregister-Event WebClient.DownloadProgressChanged
                             Unregister-Event WebClient.DownloadFileCompleted
                             New-Event NpmDownloadFileCompleted
                         } | Out-Null

    $npm_web_client.DownloadFileAsync($npm_url, $path_to_npm_archive)

    Wait-Event -SourceIdentifier NpmDownloadFileCompleted | Out-Null
    $npm_web_client.Dispose()
    Write-Host -ForegroundColor green "OK"

    # Extract the NPM archive.
    Write-Host -NoNewline "Extracting the NPM archive... "
    $npm_shell = New-Object -ComObject Shell.Application
    $npm_zip = $npm_shell.NameSpace($path_to_npm_archive)
    foreach ($npm_item in $npm_zip.items()) {
        $npm_shell.NameSpace($runtime_dir).copyhere($npm_item)
    }
    Write-Host -ForegroundColor green "OK"

    # Remove the archive.
    Remove-Item $path_to_npm_archive
}

# Return the binaries to stdout.
Write-Host $runtime_dir
