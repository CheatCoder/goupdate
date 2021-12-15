#!/bin/sh


if ! [ $(id -u) = 0 ]; then
   echo "Run me as Root"
   exit 1
fi


function get_latest_version_url(){
    url=$(curl -s "https://go.dev/dl/" |  grep -o /dl/[go1234567890\.]*\.linux-amd64.tar.gz | head -n1)
    filename=$(echo "${url##*/}")
}

function fresh_install(){
    echo "No version found at /src/local/go install new ..."
    curl -OL $url
    tar -C /usr/local -xzf $filename
    rm $filename

    echo "add >export PATH=$PATH:/usr/local/go/bin< to your .profile or .bash"
}

function update_go(){
    echo "Updating go"
    curl -OL $url
    rm -rf /usr/local/go 2>/dev/null
    tar -C /usr/local -xzf $filename
    rm $filename
}

function localversion(){
    
    if ! version=$(/usr/local/go/bin/go version| grep -o go[\.1234567890]* | tail -n1); then
        fresh_install
        exit
    fi

    echo $version
}

echo "Testing Local go version ..."
localversion

echo "Testing remote version against local version"
get_latest_version_url

if [[ $filename == *$version* ]]; then
  echo "No new found ... exit"
  exit
fi

update_go
