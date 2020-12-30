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
    project='noproject'
    apikey='noapikey'
    job='nojob'
    website='nowebsite'
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
        -w | --website)
            website="${2-}"
            shift
            ;;
        -c | --create)
            curl -H 'Authorization: '"${apikey}"'' -H "Content-Type: application/json" -d '{"screenshotParameter":{"width":1200, "height":720}, "urls":[{"url":"'"${website}"'", "name":"dev.to"}]}' -X POST https://api.websiteshot.app/api/projects/${project}
            response="Create Request for Project ${project}"
            return 0
            ;;
        -g | --get)
            curl -H 'Authorization: '"${apikey}"'' https://api.websiteshot.app/api/projects/${project}/screenshots/root/${job}
            response="Get Request for Job ${job} of Project ${project}"
            return 0
            ;;
        -?*) die "Unknown option: $1" ;;
        *) break ;;
        esac
        shift
    done

    args=("$@")

    # check required params and arguments
    [[ -z "${param-}" ]] && die "Missing required parameters"
    [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

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
