#!/bin/bash

OPT_BASE_REF='HEAD^'

while getopts fr: ch; do
    case "$ch" in
        (r)     OPT_BASE_REF=$OPTARG
                ;;

        (f)     OPT_FORCE=1
        ;;

        (\?)    echo "ERROR: unknown optoin: $1" >&2
                exit 2
                ;;
    esac
done
shift $(( OPTIND - 1 ))

if [[ -z "$1" ]]; then
    echo "ERROR: missing required argument <overlay>" >&2
    exit 2
fi

overlay=$1
shift

if ! [[ -d "$overlay" ]]; then
    echo "ERROR: overlay $overlay does not exist" >&2
    exit 1
fi

if [[ -z $OPT_FORCE ]] && ! git diff-index --quiet HEAD; then
    echo "ERROR: please commit your changes first." >&2
    exit 1
fi

set -e

workdir=$(mktemp -d tmp.kustomizeXXXXXX)
trap "rm -rf $workdir" EXIT

mkdir -p $workdir/prev $workdir/head
git archive "${OPT_BASE_REF}" | tar -C $workdir/prev -xf -
git archive HEAD | tar -C $workdir/head -xf -

diff -u \
    <(kustomize build $workdir/prev/${overlay}) \
    <(kustomize build $workdir/head/${overlay})
