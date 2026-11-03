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
# Passcode screen for the public testing site (not shown in the claude.ai preview).
# Only a scrambled SHA-256 fingerprint of the passcode is stored here, never the passcode itself.
# To change the passcode, compute SHA-256 of "frankiesfortress:" + the new passcode in lowercase.
$passHash = "6ff93ad3daa87b457b1d6ed26953dc3e2999bb576db68e1f91d7597045da73ae"
$gate = @'
<style>
html.ff-locked body > *:not(#ff-gate) { display: none !important; }
#ff-gate, #ff-gate * { box-sizing: border-box; }
#ff-gate { position: fixed; inset: 0; z-index: 100; overflow-y: auto; display: flex; align-items: center; justify-content: center; background: #E3DED5; color: #2B2420; font: 16px/1.55 Inter, "Segoe UI", system-ui, sans-serif;
  padding: max(24px, env(safe-area-inset-top, 0px)) max(16px, env(safe-area-inset-right, 0px)) max(24px, env(safe-area-inset-bottom, 0px)) max(16px, env(safe-area-inset-left, 0px)); }
#ff-gate form { width: 100%; max-width: 420px; margin: auto; background: #F3F0EA; border: 1px solid #D0C7BB; border-radius: 14px; overflow: hidden; display: flex; flex-direction: column; }
#ff-gate img { width: 100%; height: 170px; object-fit: cover; object-position: 50% 45%; display: block; }
#ff-gate .ffg-in { padding: 20px; display: flex; flex-direction: column; gap: 12px; }
#ff-gate h1 { font: 600 2rem/1.15 Newsreader, Georgia, "Times New Roman", serif; margin: 0; }
#ff-gate p { margin: 0; }
#ff-gate label { font-weight: 700; font-size: 0.95rem; }
#ff-gate input { font: inherit; width: 100%; padding: 12px 14px; border-radius: 10px; border: 1.5px solid #D0C7BB; background: #fff; color: inherit; }
#ff-gate input:focus { outline: none; border-color: #B8661E; }
#ff-gate button { font: inherit; font-weight: 700; padding: 13px 18px; border-radius: 10px; border: 0; background: #B8661E; color: #FFF8EF; cursor: pointer; }
#ff-gate .ffg-msg { color: #8A4710; font-size: 0.92rem; min-height: 1.2em; }
#ff-gate .ffg-crisis { font-size: 0.88rem; color: #675C54; border-top: 1px solid #D0C7BB; padding-top: 12px; }
@media (prefers-color-scheme: dark) {
  #ff-gate { background: #191512; color: #EDE5DA; }
  #ff-gate form { background: #231D19; border-color: #3A3029; }
  #ff-gate input { background: #191512; border-color: #3A3029; }
  #ff-gate .ffg-msg { color: #F0B26B; }
  #ff-gate .ffg-crisis { color: #AB9E91; border-color: #3A3029; }
}
</style>
<script>document.documentElement.classList.add("ff-locked");</script>
<div id="ff-gate">
  <form id="ffg-form" autocomplete="off">
    <img src="images/castle.jpg" alt="">
    <div class="ffg-in">
      <h1>Frankie's Fortress</h1>
      <p>This site is being tested privately. Please enter the passcode you were given.</p>
      <label for="ffg-pass">Passcode</label>
      <input id="ffg-pass" type="password" autocapitalize="none" autocorrect="off" spellcheck="false">
      <button type="submit">Enter</button>
      <p class="ffg-msg" id="ffg-msg" role="alert"></p>
      <p class="ffg-crisis">Need help right now? Call or text <strong>988</strong>, any time.</p>
    </div>
  </form>
</div>
<script>
(function () {
  var HASH = "__HASH__", gate = document.getElementById("ff-gate");
  function open() { document.documentElement.classList.remove("ff-locked"); if (gate.parentNode) gate.parentNode.removeChild(gate); }
  var remembered = false;
  try { remembered = localStorage.getItem("ff.pass") === HASH; } catch (e) {}
  if (remembered) { open(); return; }
  document.getElementById("ffg-form").addEventListener("submit", function (e) {
    e.preventDefault();
    var msg = document.getElementById("ffg-msg");
    var value = document.getElementById("ffg-pass").value.trim().toLowerCase();
    if (!value) { msg.textContent = "Please type the passcode."; return; }
    if (!(window.crypto && crypto.subtle && window.TextEncoder)) { msg.textContent = "Please open https://frankiesfortress.org to enter the passcode."; return; }
    crypto.subtle.digest("SHA-256", new TextEncoder().encode("frankiesfortress:" + value)).then(function (buf) {
      var hex = Array.prototype.map.call(new Uint8Array(buf), function (b) { return ("0" + b.toString(16)).slice(-2); }).join("");
      if (hex === HASH) { try { localStorage.setItem("ff.pass", HASH); } catch (err) {} open(); }
      else { msg.textContent = "That passcode isn't right. Please check with the person who shared this site."; }
    });
  });
})();
</script>
'@
$gate = $gate.Replace("__HASH__", $passHash)
$html = $skeleton + $gate + $page + "`n</body>`n</html>`n"
[System.IO.File]::WriteAllText((Join-Path $out "index.html"), $html, (New-Object System.Text.UTF8Encoding($false)))
Copy-Item (Join-Path $root "images\*") (Join-Path $out "images") -Force
# Tell GitHub Pages to serve the files as-is.
[System.IO.File]::WriteAllText((Join-Path $out ".nojekyll"), "")
# The site's own web address (set up on Namecheap).
[System.IO.File]::WriteAllText((Join-Path $out "CNAME"), "frankiesfortress.org`n")
"Built docs/index.html"
