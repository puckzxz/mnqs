# Check if the directory where all our files will go exists
# If it doesn't then we create the directory
if (!(Test-Path "$PSScriptRoot\MelonMovieNight"))
{
    New-Item -ItemType Directory -Path "$PSScriptRoot\MelonMovieNight"
}

# Check if the folder where all our downloaded files will go exists
# If it doesn't exist then we create the directory
if (!(Test-Path "$PSScriptRoot\MelonMovieNight\dl"))
{
    New-Item -ItemType Directory -Path "$PSScriptRoot\MelonMovieNight\dl"
}

# Points to the contents of the MelonMovieNight directory
$root = "$PSScriptRoot\MelonMovieNight"

# Points to the contents of our download folder
$dl = "$PSScriptRoot\MelonMovieNight\dl"

# Creates the WebClient that we'll use to download our files
$wc = New-Object System.Net.WebClient

# Checks if the mpc directory exists
# If it doesn't then we download our media player and unzip it to the /MelonMovieNight/mpc directory
if (!(Test-Path "$root\mpc"))
{
    # This gets the URL to the most recent version from GitHub
    $mpcRepo = "clsid2/mpc-hc"

    $mpcReleases = "https://api.github.com/repos/$mpcRepo/releases"

    $mpcTag = (Invoke-WebRequest $mpcReleases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

    $mpcDownloadURL = "https://github.com/$mpcRepo/releases/download/$mpcTag/MPC-HC.$mpcTag.x64.zip"

    # Downloads the .zip archive containing the media player
    $wc.DownloadFile($mpcDownloadURL, "$dl\mpc.zip")

    # Unzips the archive
    Expand-Archive -Path "$dl\mpc.zip" -DestinationPath "$root\mpc"

    # Delete the archive since we no longer need it
    Remove-Item -Path "$dl\mpc.zip"
}

# Checks if the syncplay directory exists
# If it doesn't then we download syncplay and unzip it to the /MelonMovieNight/syncplay directory
if (!(Test-Path "$root\syncplay"))
{
    # This gets the URL to the most recent version from GitHub
    $syncplayRepo = "Syncplay/syncplay"

    $syncplayReleases = "https://api.github.com/repos/$syncplayRepo/releases"

    $syncplayTag = (Invoke-WebRequest $syncplayReleases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

    # Syncplay tags their releases with vX.X.X but the files have X.X.X so we need to remove the v
    $syncplayFileTag = $syncplayTag.substring(1)

    $syncplayDownloadURL = "https://github.com/$syncplayRepo/releases/download/$syncplayTag/Syncplay_${syncplayFileTag}_Portable.zip"

    # Downloads the .zip archive containing syncplay
    $wc.DownloadFile($syncplayDownloadURL, "$dl\syncplay.zip")

    # Unzips the archive
    Expand-Archive -Path "$dl\syncplay.zip" -DestinationPath "$root\syncplay"

    # Delete the archive since we no longer need it
    Remove-Item -Path "$dl\syncplay.zip"
}

# Deletes the dl folder since we don't need it anymore
Remove-Item -Path $dl

# Gets the username from your computer to use as your username in syncplay
$username = $env:USERNAME

# Starts syncplay and automatically connects you to the room
Start-Process -FilePath "$root\syncplay\Syncplay.exe" -ArgumentList "--host syncplay.pl:8999", "--name $username", "--room MelonPatchMovieNight", "--player-path `"$root\mpc\mpc-hc64.exe`""