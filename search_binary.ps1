# 获取传入的参数 - 7 位十六进制字符串
$search_hex = $args[0]

# 获取当前脚本所在文件夹路径
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# 定义要搜索的文件路径
$file_path = Join-Path -Path $scriptDirectory -ChildPath "\mp_package_hg2259\Bin\HDFED1.0.bin"

# 尝试以文本形式读取文件并搜索十六进制字符串
try {
    $content = Get-Content -Path $file_path -Raw
    $content = Get-Content -Path $file_path -Raw

    if ($content -match $search_hex) {
        Write-Host "Hex string '$search_hex' found in the file."
    } else {
        Write-Host "Hex string '$search_hex' not found in the file."
    }
} catch {
    Write-Host "Error occurred while reading or searching the file: $_"
}