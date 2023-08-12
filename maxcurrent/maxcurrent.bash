#!/bin/bash
# (c) 2023 Niklas Ögren <no@nod.se>
# Use Charge Amps eapi to login/refresh tokens, show status, and set maxCurrent.
# https://eapi.charge.space/swagger

set -eu

usage() {
    echo "Usage:" 1>&2
    echo "       $0 -a login -k <apikey> -e <email> [-p <password>]" 1>&2
    echo "                - login and save token. If no password, it will be asked for on stdin." 1>&2
    echo "                - Get your apikey from your Charge Amps contact." 1>&2
    echo "       $0 -a refresh" 1>&2
    echo "                - refresh tokens and save." 1>&2
    echo "       $0 -a status" 1>&2
    echo "                - fetch some status objects and print out json" 1>&2
    echo "       $0 -a maxcurrent [-i <maxCurrent>]" 1>&2
    echo "                - set maxCurrent for first chargePointId connected to user" 1>&2
}


save() {
    echo "Writing out ${vars} ..."
    cat <<EOF > "${vars}"
token="${token}"
refreshToken="${refreshToken}"
chargePointId="${chargePointId}"
EOF
}

login() {
    curl -o "${out}" -fsX 'POST' \
	 "${baseUrl}/api/v4/auth/login" \
	 -H 'accept: application/json' \
	 -H "apiKey: ${apiKey}" \
	 -H 'Content-Type: application/json' \
	 -d "{ 
	 \"email\": \"${email}\",
	 \"password\": \"${password}\"
	 }"
    cat < "${out}" | jq '.'
    token="$(cat < "${out}" | jq -r '.token')"
    refreshToken="$(cat < "${out}" | jq -r '.refreshToken')"
    curl -o "${out}" -fsX 'GET' \
	 "${baseUrl}/api/v4/chargepoints/owned" \
	 -H 'accept: application/json' \
	 -H "Authorization: Bearer ${token}" \
	 -H 'Content-Type: application/json'
    chargePointId="$(cat < "${out}" | jq -r '.[0].id')" # grab first chargepoint
    save
}

refresh() {
    curl -o "${out}" -fsX 'POST' \
	 "${baseUrl}/api/v4/auth/refreshtoken" \
	 -H 'accept: application/json' \
	 -H 'Content-Type: application/json' \
	 -d "{ 
	 \"token\": \"${token}\",
	 \"refreshToken\": \"${refreshToken}\"
	 }"
    token="$(cat < "${out}" | jq -r '.token')"
    refreshToken="$(cat < "${out}" | jq -r '.refreshToken')"
    save
}

setcharge() {
    curl -fsX 'PUT' \
	 "${baseUrl}/api/v4/chargepoints/${chargePointId}/settings" \
	 -H 'accept: application/json' \
	 -H "Authorization: Bearer ${token}" \
	 -H 'Content-Type: application/json' \
	 -d "{ 
	 \"id\": \"${chargePointId}\",
	 \"maxCurrent\": ${maxCurrent}
	 }" | jq '.'
}

status() {
    curl -fsX 'GET' \
	 "${baseUrl}/api/v4/chargepoints/owned" \
	 -H 'accept: application/json' \
	 -H "Authorization: Bearer ${token}" \
	 -H 'Content-Type: application/json' | jq '.'
    curl -fsX 'GET' \
	 "${baseUrl}/api/v4/chargepoints/${chargePointId}" \
	 -H 'accept: application/json' \
	 -H "Authorization: Bearer ${token}" \
	 -H 'Content-Type: application/json' | jq '.'
    curl -fsX 'GET' \
	 "${baseUrl}/api/v4/chargepoints/${chargePointId}/settings" \
	 -H 'accept: application/json' \
	 -H "Authorization: Bearer ${token}" \
	 -H 'Content-Type: application/json' | jq '.'
    curl -fsX 'GET' \
	 "${baseUrl}/api/v4/chargepoints/${chargePointId}/status" \
	 -H 'accept: application/json' \
	 -H "Authorization: Bearer ${token}" \
	 -H 'Content-Type: application/json' | jq '.'
}

action=""
maxCurrent="16"
apiKey=""
while getopts ":a:e:p:i" o; do
    case "${o}" in
        a)
            action="${OPTARG}"
            ;;
        e)
            email="${OPTARG}"
            ;;
        p)
            password="${OPTARG}"
            ;;
        i)
            maxCurrent="${OPTARG}"
            ;;
        k)
            apiKey="${OPTARG}"
            ;;
        *)
            usage
	    exit 1
            ;;
    esac
done
shift $((OPTIND-1))

baseUrl="https://eapi.charge.space"
THISDIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
vars="${THISDIR}/maxcurrent.vars"
out="$(mktemp)"

if [ -r "$vars" ]; then
    # shellcheck source=/dev/null
    source "$vars"
fi

# shellcheck disable=SC2317
at_exit() {
    rm -f "${out}"
}
trap at_exit EXIT

if [ "${action}" = "login" ]; then
    if [ "${email:-}" = "" ]; then
	echo "ERROR: Missing email (option -e)" 1>&2
	usage
	exit 1
    fi
    if [ "${password:-}" = "" ]; then
	read -ersp "Password: " password
    fi
    if [ "${apiKey:-}" = "" ]; then
	echo "ERROR: You need to provide apiKey." 1>&2
	usage
	exit 1
    fi
    login
    exit
fi
if [ "${action}" = "refresh" ]; then
    refresh
    exit
fi
if [ "${action}" = "status" ]; then
    status
    exit
fi
if [ "${action}" = "maxcurrent" ]; then
    echo "Setting max charging current to ${maxCurrent} for ${chargePointId} ..."
    setcharge
    status
    exit
fi

usage
exit 1
