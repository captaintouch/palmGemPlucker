#!/usr/bin/env bash

pilotDevice="usb:" # Usually used for Palm OS 5 devices
#pilotDevice="/dev/pilot" # Uncomment if you are not using a usb connection
deviceWidth=320
export needSudo=y

# Configure your gemini sites to fetch here (format: ["DatabaseName_WithoutSpaces"]="geminiUri")
declare -A gems=(
    [capcom]="gemini://gemini.circumlunar.space/capcom"
    [captain]="gemini://gemini.ctrl-c.club/~captain/"
    [cosmos]="gemini://skyjake.fi/~Cosmos/"
    #[comitium]="gemini://gemini.cyberbot.space/feed.gmi"
    #[midnightPub]="gemini://midnight.pub"
    #[station]="gemini://station.martinrue.com"
)

scriptPath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function dependencyCheck {
    cd $scriptPath

    if [ ! -d dependencies ]; then
        mkdir dependencies
    fi
    
    if ! command -v pcre2grep &> /dev/null; then
        echo "System is missing pcre2grep"
        exit 1
    fi

    if ! command -v git &> /dev/null; then
        echo "System is missing git"
        exit 1
    fi
    
    if [ ! -f dependencies/pyplucker/PyPlucker/Spider.py ]; then
        echo "Setting up PyPlucker"
        git clone https://github.com/lxmx/PyPlucker.git dependencies/pyplucker
        chmod +x dependencies/pyplucker/PyPlucker/Spider.py
    fi
    
    if [ ! -f dependencies/gemget/gemget ]; then
        echo "Setting up GemGet"
        git clone https://github.com/makeworld-the-better-one/gemget dependencies/gemget
        cd dependencies/gemget
        make
        cd ../..
    fi
    
    if [ ! -f dependencies/gmi2html.awk ]; then
        echo "Fetching gem to html converter"
        wget -O dependencies/gmi2html.awk "https://gist.githubusercontent.com/dracometallium/bf70ae09b4dd9a857d33e93daa2810c4/raw/6d865c2582521ef6f4210afe87948bb500a556a1/gmi2html.awk"
    fi
    
    if [ ! -f dependencies/rewrite-gmi.awk ]; then
        echo "Fetching gem local url converter"
        wget -O dependencies/rewrite-gmi.awk "https://paste.sr.ht/blob/8c159101723e5fa093b34a0cbf1ac23f23021203"
    fi
    
    chmod +x dependencies/*.awk
}

function createPluckerDB {
    export geminiUri=$1
    dbName=$2
    gemstorage=$3
    
    rootOutputPath="$gemstorage/output.gmi"
    linksOutputPath="$gemstorage/links"
    finalOutputGemPath="$gemstorage/start.gmi"
    finalOutputHtmlPath="$gemstorage/start.html"
    
    gemget -s "$geminiUri" -o "$rootOutputPath"
    cat $rootOutputPath | pcre2grep -M -o1 "^=>\s*(.*?)\s" | sed 's#^/##g' | sed -E '/^(gemini:\/\/)/! s#^#'"$geminiUri"'/#' | xargs -I {} dependencies/gemget/gemget -t 3 -s -i -e -d "$gemstorage/" {}
    dependencies/rewrite-gmi.awk $rootOutputPath > $finalOutputGemPath
    sed -i 's/.gmi/.html/g' $finalOutputGemPath
    for gemFile in $gemstorage/*.gmi; do dependencies/gmi2html.awk $gemFile > ${gemFile%.*}.html; done
    dependencies/pyplucker/PyPlucker/Spider.py -H "$finalOutputHtmlPath" -M 2 -f "$dbName" --bpp=4 --maxwidth="$deviceWidth" --zlib-compression -p"$gemstorage"
}

function transferToPilot {
    transferCommand="pilot-xfer -p $pilotDevice -i $gemstorage/*.pdb"
    if [ $needSudo == "y" ]; then
        transferCommand="sudo $transferCommand"
    fi
    eval $transferCommand
}

dependencyCheck

export gemstorage=$(mktemp -d)
trap 'rm -rf -- "$gemstorage"' EXIT

for gem in "${!gems[@]}"; do
    createPluckerDB "${gems[$gem]}" "$gem" "$gemstorage"
done

read -r -p "Would you like to Hotsync? (y/N) " input
if [[ "$input" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    transferToPilot
else
    read -p "PDB files are stored in $gemstorage, tap any key to remove the files and close this script."
fi
