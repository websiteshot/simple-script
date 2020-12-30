#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] -p projectId -a apiKey -w https://websiteshot.app -c

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-p, --project   Argument: ProjectId
-a, --apikey    Argument: API Key
-j, --job       Argument: JobId
-w, --website   Argument: URL of Website
-vw, --width    Argument: Width of View
-vh, --height   Argument: Height of View
-c, --create    Creates a new Screenshot Job
-g, --get       Get needed data for JobId
EOF
    exit
}

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    # script cleanup here
}

setup_colors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
    else
        NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
    fi
}

msg() {
    echo >&2 -e "${1-}"
}

die() {
    local msg=$1
    local code=${2-1} # default exit status 1
    msg "$msg"
    exit "$code"
}

parse_params() {
    baseurl='https://api.websiteshot.app'
    project=''
    apikey=''
    job='unset'
    website='https://websiteshot.app'
    width='1200'
    height='720'
    name='unset'
    downloadurl='unset'
    response=''

    while :; do
        case "${1-}" in
        -h | --help) usage ;;
        -v | --verbose) set -x ;;
        --no-color) NO_COLOR=1 ;;
        -p | --project)
            project="${2-}"
            shift
            ;;
        -a | --apikey)
            apikey="${2-}"
            shift
            ;;
        -j | --job)
            job="${2-}"
            shift
            ;;
        -vw | --width)
            width="${2-}"
            shift
            ;;
        -vh | --height)
            height="${2-}"
            shift
            ;;
        -w | --website)
            website="${2-}"
            shift
            ;;
        -c | --create)
            job=$(curl -H 'Authorization: '"${apikey}"'' -H "Content-Type: application/json" -d '{"screenshotParameter":{"width":'"${width}"', "height":'"${height}"'}, "urls":[{"url":"'"${website}"'", "name":"'"${website}"'"}]}' -X POST ${baseurl}/api/projects/${project} | jq -r '.jobId')
            response="${response}Create Request for Project ${project}"
            return 0
            ;;
        -g | --get)
            res=$(curl -H 'Authorization: '"${apikey}"'' ${baseurl}/api/projects/${project}/screenshots/root/${job})
            downloadurl=$(echo ${res} | jq -r '.jobs[0].data')
            name=$(echo ${res} | jq -r '.jobs[0].uuid')
            width=$(echo ${res} | jq -r '.jobs[0].screenshotParameter.width')
            height=$(echo ${res} | jq -r '.jobs[0].screenshotParameter.height')
            response="${response}Get Request for Job ${job} of Project ${project}"
            return 0
            ;;
        -d | --download)
            res=$(curl -H 'Authorization: '"${apikey}"'' ${baseurl}/api/projects/${project}/screenshots/root/${job})
            downloadurl=$(echo ${res} | jq -r '.jobs[0].data')
            name=$(echo ${res} | jq -r '.jobs[0].uuid')
            width=$(echo ${res} | jq -r '.jobs[0].screenshotParameter.width')
            height=$(echo ${res} | jq -r '.jobs[0].screenshotParameter.height')
            curl ${downloadurl} --output ${name}.png
            response="${response}Get Request for Job ${job} of Project ${project}\nSaved file to ${name}.png"
            return 0
            ;;
        -?*) die "Unknown option: $1" ;;
        *) break ;;
        esac
        shift
    done

    args=("$@")

    # check required params and arguments
    [[ -z "${project-}" ]] && die "Project missing"
    [[ -z "${apikey-}" ]] && die "API Key missing"

    return 0
}

parse_params "$@"
setup_colors

# script logic here

msg ""
msg ""
msg "${GREEN}${response}"
msg "${PURPLE}Project: ${project}"
msg "${ORANGE}Website: ${website}"
msg "${CYAN}Job: ${job}"
msg "${CYAN}Screenshot Url: ${downloadurl}"
msg "${BLUE}Width: ${width}"
msg "${BLUE}Height: ${height}"
