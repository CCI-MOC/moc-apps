#!/bin/bash

find_overlays() {
    find * -type f -regex '.*/overlays/.*/kustomization.yaml' -printf '%h\n'
}

OPT_BASE_REF='HEAD^'

while getopts fr: ch; do
    case "$ch" in
        (r)     OPT_BASE_REF=$OPTARG
                ;;

        (f)     OPT_FORCE=1
                ;;

        (\?)    echo "ERROR: unknown option: $1" >&2
                exit 2
                ;;
    esac
done
shift $(( OPTIND - 1 ))

cat <<EOF
##
## Diff 'kustomize build' between $OPT_BASE_REF and HEAD
##

EOF

for overlay in $(find_overlays); do
    echo "=== $overlay ==="
    ./ci/diff-with-previous.sh -r ${OPT_BASE_REF} ${OPT_FORCE:+-f} $overlay
done
