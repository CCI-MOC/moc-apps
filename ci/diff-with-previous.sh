#!/bin/bash

OPT_REVISION='HEAD^'

while getopts r: ch; do
    case "$1" in
        (-r)    OPT_REVISION=$OPTARG
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

if ! git diff-index --quiet HEAD; then
    echo "ERROR: please commit your changes first." >&2
    exit 1
fi

set -e

workdir=$(mktemp -d tmp.kustomizeXXXXXX)
trap "rm -rf $workdir" EXIT

mkdir -p $workdir/prev $workdir/head
git archive "${OPT_REVISION}" | tar -C $workdir/prev -xf -
git archive HEAD | tar -C $workdir/head -xf -

diff -u \
    <(cd $workdir/prev/${overlay} && kustomize build) \
    <(cd $workdir/head/${overlay} && kustomize build)
