param(
    [Parameter(Mandatory = $true)]
    [string]$AndroidRoot,
    [Parameter(Mandatory = $true)]
    [string]$FlutterRoot
)

$ErrorActionPreference = 'Stop'
$androidNs = 'http://schemas.android.com/apk/res/android'
$aaptNs = 'http://schemas.android.com/aapt'
$invariant = [Globalization.CultureInfo]::InvariantCulture
$manifestEntries = [Collections.Generic.List[object]]::new()

function Ensure-Directory([string]$Path) {
    [IO.Directory]::CreateDirectory($Path) | Out-Null
}

function Xml-Escape([string]$Value) {
    return [Security.SecurityElement]::Escape($Value)
}

function Format-Number([double]$Value) {
    return $Value.ToString('0.########', $invariant)
}

function Relative-Path([string]$Root, [string]$Path) {
    $rootPath = [IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    $filePath = [IO.Path]::GetFullPath($Path)
    $rootUri = [Uri]::new($rootPath)
    $fileUri = [Uri]::new($filePath)
    return [Uri]::UnescapeDataString($rootUri.MakeRelativeUri($fileUri).ToString())
}

function Convert-AndroidColor([string]$Value) {
    $hex = $Value.Trim().TrimStart('#')
    if ($hex.Length -eq 3) {
        $hex = "{0}{0}{1}{1}{2}{2}" -f $hex[0], $hex[1], $hex[2]
    }
    if ($hex.Length -eq 8) {
        $alpha = [Convert]::ToInt32($hex.Substring(0, 2), 16) / 255.0
        return @{
            Color = '#' + $hex.Substring(2, 6)
            Opacity = $alpha
        }
    }
    return @{
        Color = '#' + $hex
        Opacity = 1.0
    }
}

function Android-Attribute([Xml.XmlElement]$Element, [string]$Name, [string]$Default = '') {
    $value = $Element.GetAttribute($Name, $androidNs)
    if ([string]::IsNullOrEmpty($value)) { return $Default }
    return $value
}

function Render-Gradient([Xml.XmlElement]$Gradient, [string]$Id) {
    $startX = Android-Attribute $Gradient 'startX' '0'
    $startY = Android-Attribute $Gradient 'startY' '0'
    $endX = Android-Attribute $Gradient 'endX' '0'
    $endY = Android-Attribute $Gradient 'endY' '0'
    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add("    <linearGradient id=`"$Id`" x1=`"$startX`" y1=`"$startY`" x2=`"$endX`" y2=`"$endY`" gradientUnits=`"userSpaceOnUse`">")
    foreach ($item in $Gradient.ChildNodes | Where-Object { $_.LocalName -eq 'item' }) {
        $offset = Android-Attribute $item 'offset' '0'
        $converted = Convert-AndroidColor (Android-Attribute $item 'color' '#000000')
        $opacity = if ($converted.Opacity -lt 1) { " stop-opacity=`"$(Format-Number $converted.Opacity)`"" } else { '' }
        $lines.Add("      <stop offset=`"$offset`" stop-color=`"$($converted.Color)`"$opacity />")
    }
    $lines.Add('    </linearGradient>')
    return $lines
}

function Render-Path(
    [Xml.XmlElement]$Path,
    [Collections.Generic.List[string]]$Definitions,
    [ref]$GradientIndex
) {
    $attributes = [Collections.Generic.List[string]]::new()
    $attributes.Add('d="' + (Xml-Escape (Android-Attribute $Path 'pathData')) + '"')

    $gradient = $null
    foreach ($child in $Path.ChildNodes) {
        if ($child.NamespaceURI -eq $aaptNs -and $child.LocalName -eq 'attr') {
            $gradient = $child.ChildNodes | Where-Object { $_.LocalName -eq 'gradient' } | Select-Object -First 1
        }
    }

    if ($null -ne $gradient) {
        $gradientIndex.Value++
        $id = "gradient$($GradientIndex.Value)"
        foreach ($line in (Render-Gradient $gradient $id)) { $Definitions.Add($line) }
        $attributes.Add("fill=`"url(#$id)`"")
    } else {
        $fill = Convert-AndroidColor (Android-Attribute $Path 'fillColor' '#000000')
        $attributes.Add("fill=`"$($fill.Color)`"")
        $fillAlpha = [double]::Parse((Android-Attribute $Path 'fillAlpha' '1'), $invariant)
        $combinedAlpha = $fill.Opacity * $fillAlpha
        if ($combinedAlpha -lt 1) {
            $attributes.Add("fill-opacity=`"$(Format-Number $combinedAlpha)`"")
        }
    }

    $fillType = Android-Attribute $Path 'fillType'
    if ($fillType -eq 'evenOdd') { $attributes.Add('fill-rule="evenodd"') }

    $strokeValue = Android-Attribute $Path 'strokeColor'
    if (-not [string]::IsNullOrEmpty($strokeValue)) {
        $stroke = Convert-AndroidColor $strokeValue
        $attributes.Add("stroke=`"$($stroke.Color)`"")
        if ($stroke.Opacity -lt 1) {
            $attributes.Add("stroke-opacity=`"$(Format-Number $stroke.Opacity)`"")
        }
        $attributes.Add('stroke-width="' + (Android-Attribute $Path 'strokeWidth' '0') + '"')
    }

    return '  <path ' + ($attributes -join ' ') + ' />'
}

function Render-Children(
    [Xml.XmlElement]$Parent,
    [Collections.Generic.List[string]]$Definitions,
    [ref]$GradientIndex,
    [int]$Indent = 0
) {
    $lines = [Collections.Generic.List[string]]::new()
    $prefix = '  ' * $Indent
    foreach ($child in $Parent.ChildNodes) {
        if ($child.LocalName -eq 'path') {
            $lines.Add($prefix + (Render-Path $child $Definitions $GradientIndex).TrimStart())
        } elseif ($child.LocalName -eq 'group') {
            $scaleX = Android-Attribute $child 'scaleX' '1'
            $scaleY = Android-Attribute $child 'scaleY' '1'
            $translateX = Android-Attribute $child 'translateX' '0'
            $translateY = Android-Attribute $child 'translateY' '0'
            $transform = "translate($translateX $translateY) scale($scaleX $scaleY)"
            $lines.Add("$prefix  <g transform=`"$transform`">")
            foreach ($line in (Render-Children $child $Definitions $GradientIndex ($Indent + 1))) {
                $lines.Add($line)
            }
            $lines.Add("$prefix  </g>")
        }
    }
    return $lines
}

function Convert-VectorDrawable([string]$Source, [string]$Target) {
    [xml]$document = Get-Content -Raw -LiteralPath $Source
    $vector = $document.DocumentElement
    $viewWidth = Android-Attribute $vector 'viewportWidth'
    $viewHeight = Android-Attribute $vector 'viewportHeight'
    $width = (Android-Attribute $vector 'width').Replace('dp', '')
    $height = (Android-Attribute $vector 'height').Replace('dp', '')
    $definitions = [Collections.Generic.List[string]]::new()
    $gradientIndex = 0
    $body = Render-Children $vector $definitions ([ref]$gradientIndex)

    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add('<?xml version="1.0" encoding="UTF-8"?>')
    $lines.Add("<svg xmlns=`"http://www.w3.org/2000/svg`" width=`"$width`" height=`"$height`" viewBox=`"0 0 $viewWidth $viewHeight`">")
    if ($definitions.Count -gt 0) {
        $lines.Add('  <defs>')
        foreach ($line in $definitions) { $lines.Add($line) }
        $lines.Add('  </defs>')
    }
    foreach ($line in $body) { $lines.Add($line) }
    $lines.Add('</svg>')
    Ensure-Directory ([IO.Path]::GetDirectoryName($Target))
    [IO.File]::WriteAllLines($Target, $lines, [Text.UTF8Encoding]::new($false))
}

function Add-ManifestEntry(
    [string]$Type,
    [string]$Source,
    [string]$Target,
    [string]$Conversion
) {
    $sourceRelative = Relative-Path $AndroidRoot $Source
    $targetRelative = Relative-Path $FlutterRoot $Target
    $manifestEntries.Add([ordered]@{
        type = $Type
        source = $sourceRelative
        target = $targetRelative
        sourceSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $Source).Hash.ToLowerInvariant()
        targetSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $Target).Hash.ToLowerInvariant()
        conversion = $Conversion
    })
}

function Copy-Asset([string]$Type, [string]$Source, [string]$Target) {
    Ensure-Directory ([IO.Path]::GetDirectoryName($Target))
    Copy-Item -LiteralPath $Source -Destination $Target -Force
    Add-ManifestEntry $Type $Source $Target 'copied-byte-for-byte'
}

$drawableRoot = Join-Path $AndroidRoot 'app/src/main/res/drawable'
$iconTargetRoot = Join-Path $FlutterRoot 'assets/icons'
Ensure-Directory $iconTargetRoot
foreach ($source in Get-ChildItem -LiteralPath $drawableRoot -Filter '*.xml' | Sort-Object Name) {
    $target = Join-Path $iconTargetRoot ($source.BaseName + '.svg')
    Convert-VectorDrawable $source.FullName $target
    Add-ManifestEntry 'vector' $source.FullName $target 'android-vector-to-svg-v1'
}

Copy-Asset 'image' (Join-Path $drawableRoot 'md_sw.png') (Join-Path $FlutterRoot 'assets/images/md_sw.png')
Copy-Asset 'image' (Join-Path $drawableRoot 'darwin.webp') (Join-Path $FlutterRoot 'assets/images/darwin.webp')
Copy-Asset 'launcher' (Join-Path $AndroidRoot 'app/src/main/ic_launcher-playstore.png') (Join-Path $FlutterRoot 'assets/launcher/ic_launcher-playstore.png')

foreach ($density in @('mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi')) {
    foreach ($name in @('ic_launcher.webp', 'ic_launcher_round.webp')) {
        $source = Join-Path $AndroidRoot "app/src/main/res/mipmap-$density/$name"
        $target = Join-Path $FlutterRoot "assets/launcher/mipmap-$density/$name"
        Copy-Asset 'launcher' $source $target
    }
}

foreach ($name in @('ic_launcher.xml', 'ic_launcher_round.xml')) {
    $source = Join-Path $AndroidRoot "app/src/main/res/mipmap-anydpi-v26/$name"
    $target = Join-Path $FlutterRoot "assets/launcher/mipmap-anydpi-v26/$name"
    Copy-Asset 'launcher-adaptive' $source $target
}

foreach ($name in @('Bluetooth.json', 'Bluetooth_of.json')) {
    Copy-Asset 'animation' (Join-Path $AndroidRoot "app/src/main/assets/$name") (Join-Path $FlutterRoot "assets/animations/$name")
}

foreach ($name in @('connection.mp3', 'disconnection.mp3')) {
    Copy-Asset 'audio' (Join-Path $AndroidRoot "app/src/main/res/raw/$name") (Join-Path $FlutterRoot "assets/audio/$name")
}

$manifest = [ordered]@{
    schemaVersion = 1
    snapshotDate = '2026-09-29'
    sourceRoot = 'SensyWall/'
    assetCount = $manifestEntries.Count
    assets = $manifestEntries
}
$manifestPath = Join-Path $FlutterRoot 'assets/assets_manifest.json'
$manifestJson = $manifest | ConvertTo-Json -Depth 6
[IO.File]::WriteAllText($manifestPath, $manifestJson, [Text.UTF8Encoding]::new($false))

Write-Output "Converted/copied $($manifestEntries.Count) assets."
