$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$port = 8765
$prefix = "http://localhost:$port/"
$listener = [Net.HttpListener]::new()
$listener.Prefixes.Add($prefix)
$listener.Start()

$edge = Join-Path ${env:ProgramFiles(x86)} "Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edge)) { $edge = Join-Path $env:ProgramFiles "Microsoft\Edge\Application\msedge.exe" }
if (-not (Test-Path $edge)) { throw "Microsoft Edge est introuvable." }
Start-Process $edge "$prefix`Assistant%20creation.html"

$mime = @{
  ".html" = "text/html; charset=utf-8"
  ".js" = "text/javascript; charset=utf-8"
  ".json" = "application/manifest+json; charset=utf-8"
  ".css" = "text/css; charset=utf-8"
  ".xlsx" = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
}
try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    try {
      $relative = [Uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart('/'))
      if ([string]::IsNullOrWhiteSpace($relative)) { $relative = "Assistant creation.html" }
      $file = [IO.Path]::GetFullPath((Join-Path $root $relative))
      if (-not $file.StartsWith($root, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $file -PathType Leaf)) {
        $context.Response.StatusCode = 404
      } else {
        $bytes = [IO.File]::ReadAllBytes($file)
        $extension = [IO.Path]::GetExtension($file).ToLowerInvariant()
        $context.Response.ContentType = if ($mime.ContainsKey($extension)) { $mime[$extension] } else { "application/octet-stream" }
        $context.Response.ContentLength64 = $bytes.Length
        $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
      }
    } finally {
      $context.Response.Close()
    }
  }
} finally {
  $listener.Stop()
  $listener.Close()
}