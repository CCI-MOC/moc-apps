#!/bin/bash

: ${KUSTOMIZE:=kustomize}
: ${KUBEVAL:=kubeval}
: ${CONFTEST:=conftest}
: ${SCHEMA_LOCATION:=https://raw.githubusercontent.com/CCI-MOC/openshift-schemas/master/schemas/}

find_overlays() {
    find * -type f -regex '.*/overlays/.*/kustomization.yaml' -printf '%h\n'
}

okay() {
    echo -n "$(tput setaf 2)${1}:okay$(tput sgr0) "
}

fail() {
    echo "$(tput setaf 1)${1}:failed$(tput sgr0)"
    [[ -s "$tmpdir/stdout" ]] && { echo; cat $tmpdir/stdout; }
    [[ -s "$tmpdir/stderr" ]] && { echo; cat $tmpdir/stderr; }
    exit 1
}

while getopts vis: ch; do
    case $ch in
        (i) IGNORE_MISSING_SCHEMAS=1
            ;;

        (s) SCHEMA_LOCATION=$OPTARG
            ;;
    esac
done
shift $(( OPTIND - 1 ))

tmpdir=$(mktemp -d buildXXXXXX)
trap "rm -rf $tmpdir" EXIT

for overlay in $(find_overlays); do
    > $tmpdir/stdout

    echo -n "$overlay "
    if $KUSTOMIZE build $overlay > $tmpdir/manifests.yaml 2> $tmpdir/stderr; then
        okay build
    else
        fail build
    fi

    if $KUBEVAL --strict \
        ${IGNORE_MISSING_SCHEMAS:+--ignore-missing-schemas} \
        ${SCHEMA_LOCATION:+--additional-schema-locations $SCHEMA_LOCATION} \
            $tmpdir/manifests.yaml > $tmpdir/stdout 2> $tmpdir/stderr; then
        okay schema
    else
        fail schema
    fi

    echo
done
