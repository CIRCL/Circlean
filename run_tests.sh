#!/bin/bash

TEST_PART_TYPE=${1}
TEST_SOURCE_TYPE=${2}

if [ -z "$1" ]; then
    TEST_PART_TYPE="VFAT_NORM"
fi
if [ -z "$2" ]; then
    TEST_SOURCE_TYPE="t_images1"
fi

set -e

./mount_image.sh ./copy_to_final.sh

pushd tests/

./run.sh ${TEST_PART_TYPE} ${TEST_SOURCE_TYPE}
./check_results.sh ${TEST_SOURCE_TYPE}

popd
