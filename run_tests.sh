#!/bin/bash

set -e

./mount_image.sh ./copy_to_final.sh

pushd tests/

./run.sh

popd
