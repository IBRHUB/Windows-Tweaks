# ✨ About
This open-source tool is designed to enhance computer performance. Results may vary based on your system's configuration.

# ⚠️ Disclaimer
The author is not responsible for any damages that may occur from using this tool. Use at your own risk.

# 💻 Requirements
- Windows 10 or 11
- Internet Connection
- Administrator Permissions

# 🛠️ How to Use
1. Visit the [Releases](https://github.com/ibrpride/Windows-Tweaks/releases) page.
2. Download 
```
Invoke-WebRequest -Uri "https://github.com/ibrpride/Windows-Tweaks/archive/refs/heads/main.zip" -OutFile "$env:USERPROFILE\Desktop\Windows-Tweaks-main.zip"
```



```
if (-not (Test-Path "C:\Program Files\7-Zip\7z.exe")) { $installer = "$env:TEMP\7zinstaller.msi"; Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z2201-x64.msi" -OutFile $installer; Start-Process msiexec.exe -ArgumentList "/i `"$installer`" /quiet /norestart" -Wait; Remove-Item $installer -Force } $zipPath = "$env:USERPROFILE\Desktop\Windows-Tweaks-main.zip"; $extractPath = "$env:USERPROFILE\Desktop\Windows-Tweaks-main"; if (Test-Path $zipPath) { if (-not (Test-Path $extractPath)) { New-Item -ItemType Directory -Path $extractPath | Out-Null } Start-Process "C:\Program Files\7-Zip\7z.exe" -ArgumentList "x `"$zipPath`" -o`"$extractPath`" -y" -Wait } else { Write-Error "ZIP file not found: $zipPath" }
```

3. Double-click the file to execute it.

[Watch the video tutorial here] soon

# 🌐 Community
Join the [IBR HUB Discord](https://discord.gg/ibrpride-961025296088301648) 

