$root = "$PSScriptRoot\BasedDepartment"

$dl = "$root\dl"

if (!(Test-Path $root))
{
    New-Item -ItemType Directory -Path $root
}

if (!(Test-Path $dl))
{
    New-Item -ItemType Directory -Path $dl
}

$wc = New-Object System.Net.WebClient

if (!(Test-Path "$root\mpv"))
{
    $mpvRepo = "stax76/mpv.net"

    $mpvReleases = "https://api.github.com/repos/$mpvRepo/releases"

    $mpvTag = (Invoke-WebRequest $mpvReleases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

    $mpcDownloadURL = "https://github.com/$mpvRepo/releases/download/$mpvTag/mpv.net-portable-x64-$mpvTag.zip"

    $wc.DownloadFile($mpcDownloadURL, "$dl\mpv.zip")

    Expand-Archive -Path "$dl\mpv.zip" -DestinationPath "$root\mpv"

    Remove-Item -Path "$dl\mpv.zip"
}

if (!(Test-Path "$root\mpv\shaders"))
{
    $a4kRepo = "bloc97/Anime4K"

    $a4kReleases = "https://api.github.com/repos/$a4kRepo/releases"

    $a4kTag = (Invoke-WebRequest $a4kReleases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

    $mpcDownloadURL = "https://github.com/$a4kRepo/releases/download/$a4kTag/Anime4K_v$a4kTag.zip"

    $wc.DownloadFile($mpcDownloadURL, "$dl\a4k.zip")

    Expand-Archive -Path "$dl\a4k.zip" -DestinationPath "$root\mpv\shaders"

    Remove-Item -Path "$dl\a4k.zip"
}

if (!(Test-Path "$root\mpv\portable_config\mpv.conf"))
{
    if (!(Test-Path "$root\mpv\portable_config"))
    {
        New-Item -ItemType Directory -Path "$root\mpv\portable_config"
    }
    $confPath = "$root\mpv\portable_config\mpv.conf"
    New-Item -ItemType File -Path $confPath

    $shaderDir = "$root\mpv\shaders"

    [IO.File]::WriteAllLines($confPath,
"input-default-bindings
keep-open
hwdec=auto
profile=gpu-hq
keep-open=always
vo=gpu
start-size=video
gpu-api=opengl
slang=en,eng
alang=ja,jpn
deband-grain=0
dither-depth=no")

    $shaders = "glsl-shaders=`"$shaderDir\Anime4K_Denoise_Bilateral_Mode.glsl;$shaderDir\Anime4K_Deblur_DoG.glsl;$shaderDir\Anime4K_DarkLines_HQ.glsl;$shaderDir\Anime4K_ThinLines_HQ.glsl;$shaderDir\Anime4K_Upscale_CNN_L_x2_Deblur.glsl`""
    Add-Content -Path $confPath -Value $shaders
}

if (!(Test-Path "$root\syncplay"))
{
    $syncplayRepo = "Syncplay/syncplay"

    $syncplayReleases = "https://api.github.com/repos/$syncplayRepo/releases"

    $syncplayTag = (Invoke-WebRequest $syncplayReleases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

    $syncplayFileTag = $syncplayTag.substring(1)

    $syncplayDownloadURL = "https://github.com/$syncplayRepo/releases/download/$syncplayTag/Syncplay_${syncplayFileTag}_Portable.zip"

    $wc.DownloadFile($syncplayDownloadURL, "$dl\syncplay.zip")

    Expand-Archive -Path "$dl\syncplay.zip" -DestinationPath "$root\syncplay"

    Remove-Item -Path "$dl\syncplay.zip"
}

Remove-Item -Path $dl

$username = $env:USERNAME

Start-Process -FilePath "$root\syncplay\Syncplay.exe" -ArgumentList "--host syncplay.pl:8999", "--name $username", "--room BasedDepartment", "--player-path `"$root\mpv\mpvnet.exe`""