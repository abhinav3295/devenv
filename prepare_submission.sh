#!/usr/bin/env bash

RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'

BASEDIR=`pwd`
PROBLEM_NAME="parking_lot"
SUBMISSION_NAME=${PROBLEM_NAME}.tar.gz

function create_submission(){
    rm -f ${BASEDIR}/${SUBMISSION_NAME} &&\
    cp -r ${BASEDIR} /tmp/${PROBLEM_NAME} &&\
    tar -cf /${BASEDIR}/${SUBMISSION_NAME} -C /tmp ${PROBLEM_NAME}
}

if ! ${BASEDIR}/bin/setup ; then
    echo -e "[${RED}ERROR${NC}] Failed to build project, make sure that 'bin/setup' file has correct content"
    exit -1
else
    echo -e "[${GREEN}SUCCESS${NC}] Build Success"
fi

if ! ${BASEDIR}/bin/run_functional_tests ; then
    echo -e "[${RED}ERROR${NC}] Failed to execute functional test. Have you really finished the implementation?"
    exit -1
else
    echo -e "[${GREEN}SUCCESS${NC}] Sample test passed."
fi


if ! create_submission; then
    echo -e "[${RED}ERROR${NC}] Failed to create submission"
    exit -1
else
    echo -e "[${GREEN}SUCCESS${NC}] Submit ${GREEN}${SUBMISSION_NAME}${NC} to the coordinator."
fi
