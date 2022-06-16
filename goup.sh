#!/bin/sh
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-hv] [-x] [-o]
#%
#% DESCRIPTION
#%    A simple Scritp to Update or Install the newest GO version.
#%    
#%
#% OPTIONS
#%    -o [file], --output=[file]    Set log file (default=/dev/null)
#%                                  use DEFAULT keyword to autoname file
#%                                  The default value is /dev/null. - TODO
#%    -x, --ignorelock              Ignore if lock file exists
#%    -h, --help                    Print this help
#%    -v, --version                 Print script information
#%
#% EXAMPLES
#%    ${SCRIPT_NAME} -o DEFAULT arg1 arg2
#%
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} (CheatCoder) 0.0.1
#-    author          CheatCoder
#-    copyright       Copyright (c) CheatCoder
#-    license         unlicense
#-
#================================================================
#  HISTORY
#     16/06/2022 : CheatCoder : script creating
#     
# 
#================================================================
# END_OF_HEADER
#================================================================

#== needed variables ==#
SCRIPT_HEADSIZE=$(head -200 ${0} |grep -n "^# END_OF_HEADER" | cut -f1 -d:)
SCRIPT_NAME="$(basename ${0})"

#== usage functions ==#
usage() { printf "Usage: "; head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#+" | sed -e "s/^#+[ ]*//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ; }
usagefull() { head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#[%+-]" | sed -e "s/^#[%+-]//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ; }
scriptinfo() { head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#-" | sed -e "s/^#-//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g"; }



while getopts ":i:vh" optname
  do
    case "$optname" in
      "v" | "version")
        scriptinfo
        exit 0;
        ;;
      "h"|help)
	usagefull
        exit 0;
        ;;
      "x")
	SKIP=true
	;;
      "?")
        usage
        exit 0;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done

# -----------------------------------------------------------------

if [ !$SKIP ]; then
	LOCK_FILE=/tmp/${SCRIPT_NAME}.lock

	if [ -f "$LOCK_FILE" ]; then
		echo "Script is already running"
		exit
	fi
fi

# -----------------------------------------------------------------
trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE 

# -----------------------------------------------------------------
#  SCRIPT LOGIC GOES HERE
# -----------------------------------------------------------------


if ! [ "$(id -u)" = 0 ]; then
   echo "Run me as Root"
   exit 1
fi

case "$(uname -m)" in
   aarch64)   arch="arm64";;
   x86_64)   arch="amd64";;
   x86)   arch="386";;
esac



get_latest_version_url(){
    # Looking for a version for all linux variants
    url="https://go.dev"$(curl -s "https://go.dev/dl/" |  grep -o "/dl/[go1234567890\.]*\.linux-"$arch".tar.gz" | head -n1)
    filename="${url##*/}"
}

fresh_install(){
    echo "No version found at /src/local/go install new ..."
    get_latest_version_url
    curl -OL "$url"
    tar -C /usr/local -xzf "$filename"
    rm "$filename"

    echo 'add >export PATH=$PATH:/usr/local/go/bin< to your .profile or .bash'
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
