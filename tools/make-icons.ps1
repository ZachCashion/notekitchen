# Generates the app icons (SVG + PNGs) from one shape list, so they always match.
# Usage: powershell -ExecutionPolicy Bypass -File tools/make-icons.ps1
Add-Type -AssemblyName System.Drawing

$out = Join-Path $PSScriptRoot '..\app\images'

# Geometry on a 512x512 grid. Everything sits inside the central 80% so the icon is maskable.
$shapes = New-Object System.Collections.ArrayList
function Add-Rect($x, $y, $w, $h, $r, $fill) { [void]$shapes.Add(@{ t = 'rect'; x = $x; y = $y; w = $w; h = $h; r = $r; fill = $fill }) }
function Add-Circle($cx, $cy, $r, $fill) { [void]$shapes.Add(@{ t = 'circle'; x = $cx; y = $cy; r = $r; fill = $fill }) }

Add-Rect 0 0 512 512 0 '#7CBFDA'            # page blue
Add-Rect 88 184 336 168 18 '#b23b3b'        # piano shadow edge
Add-Rect 88 176 336 168 18 '#db7a7a'        # piano body
foreach ($cx in 128, 160, 192) {
  Add-Circle $cx 208 11 '#b23b3b'
  Add-Circle $cx 207 8 '#e58a8a'
}
Add-Rect 104 236 304 92 6 '#6c0b0b'         # keybed
$whiteW = 304 / 7
$lit = 0, 2, 4                              # C, E, G
for ($i = 0; $i -lt 7; $i++) {
  $fill = if ($lit -contains $i) { '#1ba7d1' } else { '#FFFFFF' }
  Add-Rect (104 + $i * $whiteW + 2) 238 ($whiteW - 4) 86 4 $fill
}
foreach ($i in 1, 2, 4, 5, 6) {
  Add-Rect (104 + $i * $whiteW - 13) 238 26 50 3 '#333333'
}

# SVG
$svg = @('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">')
foreach ($s in $shapes) {
  $inv = [Globalization.CultureInfo]::InvariantCulture
  if ($s.t -eq 'rect') {
    $svg += [string]::Format($inv, '  <rect x="{0:0.##}" y="{1:0.##}" width="{2:0.##}" height="{3:0.##}" rx="{4}" fill="{5}"/>', $s.x, $s.y, $s.w, $s.h, $s.r, $s.fill)
  } else {
    $svg += [string]::Format($inv, '  <circle cx="{0}" cy="{1}" r="{2}" fill="{3}"/>', $s.x, $s.y, $s.r, $s.fill)
  }
}
$svg += '</svg>'
[IO.File]::WriteAllText((Join-Path $out 'icon.svg'), ($svg -join "`n") + "`n", (New-Object Text.UTF8Encoding $false))

# PNGs
function Get-RoundedRect($x, $y, $w, $h, $r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  if ($r -le 0) { $p.AddRectangle((New-Object System.Drawing.RectangleF $x, $y, $w, $h)); return $p }
  $d = 2 * $r
  $p.AddArc($x, $y, $d, $d, 180, 90)
  $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

foreach ($size in @(@{ n = 'icon-192.png'; s = 192 }, @{ n = 'icon-512.png'; s = 512 }, @{ n = 'apple-touch-icon.png'; s = 180 })) {
  $bmp = New-Object System.Drawing.Bitmap $size.s, $size.s
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $k = $size.s / 512
  $g.ScaleTransform($k, $k)
  foreach ($s in $shapes) {
    $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($s.fill))
    if ($s.t -eq 'rect') {
      $g.FillPath($brush, (Get-RoundedRect $s.x $s.y $s.w $s.h $s.r))
    } else {
      $g.FillEllipse($brush, $s.x - $s.r, $s.y - $s.r, 2 * $s.r, 2 * $s.r)
    }
    $brush.Dispose()
  }
  $g.Dispose()
  $bmp.Save((Join-Path $out $size.n), [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
}
Write-Host "Icons written to $out"
