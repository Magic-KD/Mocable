Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

function Get-JpegCodec {
  [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object { $_.MimeType -eq "image/jpeg" } |
    Select-Object -First 1
}

function Save-Jpeg {
  param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Destination,
    [int]$MaxWidth = 1400,
    [int]$MaxHeight = 1400,
    [int]$Quality = 78
  )

  $src = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $Source))
  try {
    $scale = [Math]::Min($MaxWidth / $src.Width, $MaxHeight / $src.Height)
    if ($scale -gt 1) { $scale = 1 }
    $width = [Math]::Max(1, [int][Math]::Round($src.Width * $scale))
    $height = [Math]::Max(1, [int][Math]::Round($src.Height * $scale))

    $bitmap = New-Object System.Drawing.Bitmap $width, $height
    try {
      $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
      try {
        $graphics.Clear([System.Drawing.Color]::White)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.DrawImage($src, 0, 0, $width, $height)
      } finally {
        $graphics.Dispose()
      }

      $codec = Get-JpegCodec
      $params = New-Object System.Drawing.Imaging.EncoderParameters 1
      $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([int64]$Quality)
      $tmp = "$Destination.tmp"
      $bitmap.Save($tmp, $codec, $params)
      Move-Item -LiteralPath $tmp -Destination $Destination -Force
    } finally {
      $bitmap.Dispose()
    }
  } finally {
    $src.Dispose()
  }
}

$conversions = @(
  @{ Source = "outputs/assets/advantages/advantage-oem-odm.png"; Destination = "outputs/assets/advantages/advantage-oem-odm.jpg"; MaxWidth = 900; MaxHeight = 675; Quality = 78 },
  @{ Source = "outputs/assets/advantages/advantage-sample-support.png"; Destination = "outputs/assets/advantages/advantage-sample-support.jpg"; MaxWidth = 900; MaxHeight = 675; Quality = 78 },
  @{ Source = "outputs/assets/advantages/advantage-quality-control.png"; Destination = "outputs/assets/advantages/advantage-quality-control.jpg"; MaxWidth = 900; MaxHeight = 675; Quality = 78 },
  @{ Source = "outputs/assets/advantages/advantage-global-response.png"; Destination = "outputs/assets/advantages/advantage-global-response.jpg"; MaxWidth = 900; MaxHeight = 675; Quality = 78 },
  @{ Source = "outputs/assets/factory-photo-appacs.png"; Destination = "outputs/assets/factory-photo-appacs.jpg"; MaxWidth = 1200; MaxHeight = 676; Quality = 78 },
  @{ Source = "outputs/assets/adapter-category/u87-cc-adapter.png"; Destination = "outputs/assets/adapter-category/u87-cc-adapter.jpg"; MaxWidth = 900; MaxHeight = 1276; Quality = 78 },
  @{ Source = "outputs/assets/usb-c-category/u87-cc-adapter.png"; Destination = "outputs/assets/usb-c-category/u87-cc-adapter.jpg"; MaxWidth = 900; MaxHeight = 1276; Quality = 78 }
)

foreach ($item in $conversions) {
  if (Test-Path -LiteralPath $item.Source) {
    Save-Jpeg @item
  }
}

$jpgs = Get-ChildItem -Path "outputs/assets" -Recurse -File -Include *.jpg,*.jpeg |
  Where-Object { $_.Length -gt 300KB }

foreach ($file in $jpgs) {
  $maxW = 1200
  $maxH = 1800
  if ($file.Name -like "main-*") {
    $maxW = 900
    $maxH = 900
  }
  if ($file.FullName -like "*\detail-*") {
    $maxW = 900
    $maxH = 1600
  }

  $tmpOut = "$($file.FullName).opt.jpg"
  Save-Jpeg -Source $file.FullName -Destination $tmpOut -MaxWidth $maxW -MaxHeight $maxH -Quality 78
  if ((Get-Item -LiteralPath $tmpOut).Length -lt $file.Length) {
    Move-Item -LiteralPath $tmpOut -Destination $file.FullName -Force
  } else {
    Remove-Item -LiteralPath $tmpOut -Force
  }
}

Write-Output "Static image optimization complete."
