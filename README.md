# ✨ About
This open-source tool is designed to enhance computer performance. Results may vary based on your system's configuration.

# 💻 Requirements
- Windows 10 or 11
- Internet Connection
- Administrator Permissions

# 💡  How to Use
1. **Start menu Method:**
   - Right-click on the start menu.
   - Choose "Windows PowerShell (Admin)" (for Windows 10) or "Terminal (Admin)" (for Windows 11).

2. **Search and Launch Method:**
   - Press the Windows key.
   - Type "PowerShell" or "Terminal" (for Windows 11).
   - Press `Ctrl + Shift + Enter` or Right-click and choose "Run as administrator" to launch it with administrator privileges.

#### Stable Branch 
```
Invoke-WebRequest -Uri "https://github.com/ibrpride/Windows-Tweaks/archive/refs/heads/main.zip" -OutFile "$env:USERPROFILE\Desktop\Windows-Tweaks-main.zip"; $sevenZipPath = "C:\Program Files\7-Zip\7z.exe"; if (-Not (Test-Path $sevenZipPath)) { Write-Host "7-Zip not found. Downloading and installing..."; $sevenZipInstaller = "$env:USERPROFILE\Desktop\7z.exe"; Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z2301-x64.exe" -OutFile $sevenZipInstaller; Start-Process -FilePath $sevenZipInstaller -ArgumentList "/S" -Wait; Remove-Item $sevenZipInstaller }; & $sevenZipPath x "$env:USERPROFILE\Desktop\Windows-Tweaks-main.zip" -o"$env:USERPROFILE\Desktop" -y; Rename-Item -Path "$env:USERPROFILE\Desktop\Windows-Tweaks-main" -NewName "Windows Tweaks Free"; Remove-Item "$env:USERPROFILE\Desktop\Windows-Tweaks-main.zip"
```


# [Watch the video tutorial here] soon

# 🌐 Community
Join the [IBR HUB Discord](https://discord.gg/ibrpride-961025296088301648) 



