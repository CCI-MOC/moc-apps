#!/bin/bash

find_overlays() {
    find . -type f -regex '.*/overlays/.*/kustomization.yaml' -printf '%h\n'
}

for overlay in $(find_overlays); do
    pushd $overlay > /dev/null
    echo "Running kustomize in $overlay..."
    kustomize build > /dev/null || exit 1
    popd > /dev/null
done
