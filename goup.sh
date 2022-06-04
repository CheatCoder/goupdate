#!/bin/sh


if ! [ "$(id -u)" = 0 ]; then
   echo "Run me as Root"
   exit 1
fi


get_latest_version_url(){
    url="https://go.dev"$(curl -s "https://go.dev/dl/" |  grep -o "/dl/[go1234567890\.]*\.linux-$(uname -m).tar.gz" | head -n1)
    filename="${url##*/}"
}

fresh_install(){
    echo "No version found at /src/local/go install new ..."
    get_latest_version_url
    curl -OL "$url"
    tar -C /usr/local -xzf "$filename"
    rm "$filename"

    echo "add >export PATH=$PATH:/usr/local/go/bin< to your .profile or .bash"
}

update_go(){
    echo "Updating go"
    get_latest_version_url
    curl -OL "$url"
    rm -rf /usr/local/go 2>/dev/null
    tar -C /usr/local -xzf "$filename"
    rm "$filename"
}

localversion(){
    
    if ! type "/usr/local/go/bin/go" 2> /dev/null;then
        fresh_install
    fi

    version=$(/usr/local/go/bin/go version| grep -o "go[\.1234567890]*" | tail -n1)
    echo "$version"
}

echo "Testing Local go version ..."
localversion

echo "Testing remote version against local version"
get_latest_version_url

if echo "$filename" | grep -q "$version" ; then
  echo "No new found ... exit"
  exit
fi
update_go
