#!/bin/bash

find_overlays() {
    find * -type f -regex '.*/overlays/.*/kustomization.yaml' -printf '%h\n'
}

cat <<EOF
##
## Verify that 'kustomize build' runs without errors
## for all overlays.
##

EOF

tmpfile=$(mktemp buildXXXXXX)
trap "rm -f $tmpfile" EXIT

for overlay in $(find_overlays); do
    echo -n "$overlay..."
    if kustomize build $overlay > /dev/null 2> $tmpfile; then
        echo "$(tput setaf 2)ok$(tput sgr0)"
    else
        echo "$(tput setaf 1)failed$(tput sgr0)"
    echo
        cat $tmpfile
        exit 1
    fi
done
