Write-Host "Initializing Proxies for Intel network"
$env:HTTP_PROXY = "http://proxy-dmz.intel.com:912"
$env:HTTPS_PROXY = "http://proxy-dmz.intel.com:912"
$env:no_proxy= "localhost,127.0.0.1,intel.com,windows.net,azure.net"