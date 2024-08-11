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
if (-not (Test-Path "C:\Program Files\7-Zip\7z.exe")) { Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z2100-x64.msi" -OutFile "$env:TEMP\7zinstaller.msi"; Start-Process msiexec.exe -ArgumentList "/i `"$env:TEMP\7zinstaller.msi`" /quiet /norestart" -Wait; if (-not (Test-Path "C:\Program Files\7-Zip\7z.exe")) { Write-Error "7-Zip installation failed"; Exit 1 } } $zipPath = "$env:USERPROFILE\Desktop\Windows-Tweaks-main.zip"; if (Test-Path $zipPath) { Start-Process "C:\Program Files\7-Zip\7z.exe" -ArgumentList "x `"$zipPath`" -o`"$env:USERPROFILE\Desktop\Windows-Tweaks-main`" -y" -Wait } else { Write-Error "ZIP file not found: $zipPath" }

```

3. Double-click the file to execute it.

[Watch the video tutorial here] soon

# 🌐 Community
Join the [IBR HUB Discord](https://discord.gg/ibrpride-961025296088301648) 

