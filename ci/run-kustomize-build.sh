#!/bin/bash

for overlay in cluster-scope/overlays/*; do
    pushd $overlay > /dev/null
    echo "Running kustomize in $overlay..."
    kustomize build > /dev/null || exit 1
    popd > /dev/null
done
