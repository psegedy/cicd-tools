#!/bin/bash

ARTIFACTS_DIR="grype-vuln-artifacts"
IMAGE_TAG="quay.io/gburges/kibana:latest"

mkdir -p "$ARTIFACTS_DIR"

function download (){
    curl -sSfL https://raw.githubusercontent.com/anchore/$1/main/install.sh | sh -s -- -b ./bin
}

if ! ./bin/syft; then
    download syft
fi

if ! ./bin/grype; then
    download grype
fi

#install and run syft
# curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b ./bin
./bin/syft -v ${IMAGE_TAG} > "${ARTIFACTS_DIR}/syft-sbom-results.txt"

#install and run grype
# curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b ./bin
./bin/grype -v -o table ${IMAGE_TAG} > "${ARTIFACTS_DIR}/grype-vuln-results-full.txt"
./bin/grype -v -o table --only-fixed ${IMAGE_TAG} > "${ARTIFACTS_DIR}/grype-vuln-results-fixable.txt"
./bin/grype -v -o table --only-fixed --fail-on high ${IMAGE_TAG}; 
