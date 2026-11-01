# Tiny static file server for local testing. Needs nothing but Windows PowerShell.
# Usage:  powershell -ExecutionPolicy Bypass -File tools\serve.ps1 [port]
param([int]$Port = 8080)

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Types = @{
  '.html'='text/html; charset=utf-8'; '.htm'='text/html; charset=utf-8'
  '.js'='text/javascript; charset=utf-8'; '.mjs'='text/javascript; charset=utf-8'
  '.css'='text/css; charset=utf-8'; '.json'='application/json; charset=utf-8'
  '.png'='image/png'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.gif'='image/gif'
  '.svg'='image/svg+xml'; '.webp'='image/webp'; '.ico'='image/x-icon'
  '.mp3'='audio/mpeg'; '.ogg'='audio/ogg'; '.wav'='audio/wav'; '.mp4'='video/mp4'
  '.woff'='font/woff'; '.woff2'='font/woff2'; '.ttf'='font/ttf'
  '.txt'='text/plain; charset=utf-8'; '.md'='text/plain; charset=utf-8'; '.wasm'='application/wasm'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Serving $Root at http://localhost:$Port/  (Ctrl+C to stop)"

try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request; $res = $ctx.Response
    try {
      $rel = [Uri]::UnescapeDataString($req.Url.AbsolutePath).TrimStart('/') -replace '/', '\'
      $path = Join-Path $Root $rel
      if (Test-Path $path -PathType Container) {
        if (-not $req.Url.AbsolutePath.EndsWith('/')) {
          $res.StatusCode = 301; $res.RedirectLocation = $req.Url.AbsolutePath + '/'; $res.Close(); continue
        }
        $path = Join-Path $path 'index.html'
      }
      $full = [IO.Path]::GetFullPath($path)
      if (-not $full.StartsWith($Root, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path $full -PathType Leaf)) {
        $res.StatusCode = 404
        $bytes = [Text.Encoding]::UTF8.GetBytes("404 Not Found: $($req.Url.AbsolutePath)")
        $res.ContentType = 'text/plain; charset=utf-8'
      } else {
        $bytes = [IO.File]::ReadAllBytes($full)
        $ext = [IO.Path]::GetExtension($full).ToLower()
        $res.ContentType = if ($Types.ContainsKey($ext)) { $Types[$ext] } else { 'application/octet-stream' }
        $res.Headers['Cache-Control'] = 'no-store'
      }
      $res.ContentLength64 = $bytes.Length
      if ($req.HttpMethod -ne 'HEAD') { $res.OutputStream.Write($bytes, 0, $bytes.Length) }
      Write-Host ("{0} {1} {2}" -f $res.StatusCode, $req.HttpMethod, $req.Url.AbsolutePath)
    } catch {
      Write-Host "Error: $_"
    } finally {
      try { $res.Close() } catch {}
    }
  }
} finally {
  $listener.Stop()
}
