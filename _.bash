#!/usr/bin/env bash
set -o pipefail

echo Usage: [GATEWAY=https://arweave.*] [OWNER=owner_address] "$0" [tag=value]...
echo Note: data is not encoded so no quotes

if [ -z "$GATEWAY" ]
then
    GATEWAY=https://arweave.net
    #GATEWAY=https://arweave.dev
    #GATEWAY=https://arweave.live # paid
    #GATEWAY=https://arweave-dev.everpay.io
fi

if [ -n "$OWNER" ]
then
    OWNER=", owners: [\\\"$OWNER\\\"]"
fi

TAGS=''
for tag in "$@"
do
    TAG_NAME="${tag%%=*}"
    TAG_VALUE="${tag#*=}"
    if [ -n "$TAGS" ]
    then
        TAGS="$TAGS,"
    fi
    TAGS="$TAGS"'{name:\"'"$TAG_NAME"'\", values:[\"'"$TAG_VALUE"'\"]}'
done
if [ -z "$TAGS" ]
then
    TAGS='[ {name:\"git\",values:[\"git\"]} ]'
fi

#TAG_NAME="Content-Type"
#TAG_VALUE="text/html"
#TAGS='[ {name:\"'"$TAG_NAME"'\", values:[\"'"$TAG_VALUE"'\"]} ]'
GRAPHQL='{
    "query":
        "query{ transactions( '"tags: $TAGS $OWNER"' ) { edges { node { id owner { address } tags { name value } } } } }",
    "variables":{}
}'

#echo "$GRAPHQL"
curl --fail-with-body -v -H 'Content-Type: application/json' -d "$GRAPHQL" "$GATEWAY"/graphql |
    sed -e 's!{!{\n!g' |
    sed -ne 's!.*"id":"\([^"]*\)".*!'"$GATEWAY"'/\1!p; s!.*"name":"\(.*\)","value":"\(.*\)".*!\t\1=\2!p; s!.*"address":"\([^"]*\)".*!\taddress \1!p;' || { echo 'FAIL' 1>&2; false; }
    #sed -ne 's!.*"id":"\([^"]*\)".*!'"$GATEWAY"'/\1!p; '

