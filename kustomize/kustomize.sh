#!/bin/bash
ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"
cat <&0 > ${ABSOLUTE_PATH}custom.yaml
kustomize build ${ABSOLUTE_PATH}