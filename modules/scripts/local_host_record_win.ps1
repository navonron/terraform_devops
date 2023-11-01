param (
    [String]$ip = "ip",
    [String]$host_name = "host_name",
    [String]$action = "action"
)

$file = "C:\Windows\System32\drivers\etc\hosts"

if ($action -eq "add")
{
    $hostfile = "$ip $host_name"
    Add-Content -Path $file -Value $hostfile -Force
}
else {
    $lines = Get-Content -Path $file
    $pattern = "^$ip\s+$host_name"
    $lines = $lines | Where-Object { $_ -notmatch $pattern }
    Write-Host "Remaining Lines:"
    $lines
    $lines | Set-Content -Path $file -Force
}
