# One-time setup: creates the public "frankies-fortress" project on GitHub,
# uploads the site, and turns on GitHub Pages so it has a public web address.
# Run with:  powershell -ExecutionPolicy Bypass -File C:\Users\mhors\Projects\frankies-fortress\publish.ps1

$env:Path = "C:\Program Files\Git\cmd;" + $env:Path
$gh = "C:\Program Files\GitHub CLI\gh.exe"
Set-Location $PSScriptRoot

Write-Host "Step 1 of 2: creating the GitHub project and uploading the site..." -ForegroundColor Cyan
& $gh repo create frankies-fortress --public --description "A private, dignity-first way to surround families in crisis with support. In honor of Frankie." --source . --remote origin --push
if ($LASTEXITCODE -ne 0) { Write-Host "Step 1 did not finish. Copy everything above and paste it into your chat with Claude." -ForegroundColor Yellow; exit 1 }

Write-Host "Step 2 of 2: turning on the website..." -ForegroundColor Cyan
& $gh api -X POST repos/glendaphorsley-eng/frankies-fortress/pages -f "source[branch]=main" -f "source[path]=/docs" | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "Step 2 did not finish. Copy everything above and paste it into your chat with Claude." -ForegroundColor Yellow; exit 1 }

Write-Host ""
Write-Host "Done! In 1 to 2 minutes your site will be live at:" -ForegroundColor Green
Write-Host "https://glendaphorsley-eng.github.io/frankies-fortress/" -ForegroundColor Green
