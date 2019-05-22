#!/usr/bin/env bash

RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'

BASEDIR=`pwd`
PROBLEM_NAME="parking_lot"
SUBMISSION_NAME=${PROBLEM_NAME}.tar.gz
SETUP_FILE=${BASEDIR}/bin/setup
FUNCTIONAL_TEST=${BASEDIR}/bin/run_functional_tests

RETVAL_GET_CORRECT_FILENAME=""
function detectBinFiles(){
    if getCorrectFileName ${SETUP_FILE}; then
        SETUP_FILE=${RETVAL_GET_CORRECT_FILENAME}
        echo -e "[${GREEN}SUCCESS${NC}] Using 'bin/${SETUP_FILE##*/}' as setup file"
    else
        echo -e "[${RED}ERROR${NC}] Setup file not found in 'bin' folder"
        return -1
    fi

    if getCorrectFileName ${FUNCTIONAL_TEST}; then
        FUNCTIONAL_TEST=${RETVAL_GET_CORRECT_FILENAME}
        echo -e "[${GREEN}SUCCESS${NC}] Using 'bin/${FUNCTIONAL_TEST##*/}' for executing functional test"
    else
        echo -e "[${RED}ERROR${NC}] Functional Test file not found in 'bin' folder"
        return -1
    fi
}
function getCorrectFileName() {
    BASE_NAME=$1
    if [ -f ${BASE_NAME} ]
    then 
        RETVAL_GET_CORRECT_FILENAME=${BASE_NAME}
        return
    fi
    if [ -f ${BASE_NAME}.sh ]
    then
        RETVAL_GET_CORRECT_FILENAME=${BASE_NAME}.sh
        return
    fi
    return -1
}

function create_submission(){
    rm -f ${BASEDIR}/${SUBMISSION_NAME} &&\
    cp -r ${BASEDIR} /tmp/${PROBLEM_NAME} &&\
    tar -cf /${BASEDIR}/${SUBMISSION_NAME} -C /tmp ${PROBLEM_NAME}
}

if ! detectBinFiles ; then
    echo -e "[${RED}ERROR${NC}] Failed to find bin files"
fi

if ! ${SETUP_FILE} ; then
    echo -e "[${RED}ERROR${NC}] Failed to build project, make sure that 'bin/setup' file has correct content"
    exit -1
else
    echo -e "[${GREEN}SUCCESS${NC}] Build Success"
fi

if ! ${FUNCTIONAL_TEST} ; then
    echo -e "[${RED}ERROR${NC}] Failed to execute functional test. Have you really finished the implementation?"
    exit -1
else
    echo -e "Sample tests executed, check console for resilt"
fi

if ! create_submission; then
    echo -e "[${RED}ERROR${NC}] Failed to create submission"
    exit -1
else
    echo -e "[${GREEN}SUCCESS${NC}] Submit ${GREEN}${SUBMISSION_NAME}${NC} to the coordinator."
fi
