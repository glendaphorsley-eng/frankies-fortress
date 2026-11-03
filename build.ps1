# Builds the public website copy in docs/ (served by GitHub Pages) from index.html.
# index.html is written for claude.ai previews, which add the page skeleton automatically,
# so this script adds that skeleton (plus a "don't list in search engines" tag) for the public copy.
# Run from the project folder:  powershell -ExecutionPolicy Bypass -File build.ps1

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$out = Join-Path $root "docs"
New-Item -ItemType Directory -Force (Join-Path $out "images") | Out-Null

$page = [System.IO.File]::ReadAllText((Join-Path $root "index.html"))
$skeleton = @'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="robots" content="noindex, nofollow">
<style>
:root{color-scheme:light;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}
body{margin:0;font:14px/1.4 system-ui,-apple-system,"Segoe UI",sans-serif}
img{max-width:100%}
[hidden]{display:none!important}
</style>
</head>
<body>
'@
$html = $skeleton + $page + "`n</body>`n</html>`n"
[System.IO.File]::WriteAllText((Join-Path $out "index.html"), $html, (New-Object System.Text.UTF8Encoding($false)))
Copy-Item (Join-Path $root "images\*") (Join-Path $out "images") -Force
# Tell GitHub Pages to serve the files as-is.
[System.IO.File]::WriteAllText((Join-Path $out ".nojekyll"), "")
# The site's own web address (set up on Namecheap).
[System.IO.File]::WriteAllText((Join-Path $out "CNAME"), "frankiesfortress.org`n")
"Built docs/index.html"
