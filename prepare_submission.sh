#!/usr/bin/env bash

RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'

BASEDIR=`pwd`
PROBLEM_NAME="$1"
SUBMISSION_NAME=${PROBLEM_NAME}.tar.gz
SETUP_FILE=${BASEDIR}/bin/setup
FUNCTIONAL_TEST=${BASEDIR}/bin/run_functional_tests
CLEANUP=${BASEDIR}/bin/cleanup

RETVAL_GET_CORRECT_FILENAME=""
function detectBinFiles(){
    if getCorrectFileName ${SETUP_FILE}; then
        SETUP_FILE=${RETVAL_GET_CORRECT_FILENAME}
        echo -e "[${GREEN}SUCCESS${NC}] Using 'bin/${SETUP_FILE##*/}' as setup file"
    else
        echo -e "[${RED}ERROR${NC}] Setup file ('bin/setup') not found in root folder"
        return -1
    fi

    if getCorrectFileName ${CLEANUP}; then
        CLEANUP=${RETVAL_GET_CORRECT_FILENAME}
        echo -e "[${GREEN}SUCCESS${NC}] Using 'bin/${CLEANUP##*/}' for cleanup"
    else
        echo -e "[${RED}ERROR${NC}] Cleanup script ('bin/cleanup') not found in root folder"
        return -1
    fi

    if getCorrectFileName ${FUNCTIONAL_TEST}; then
        FUNCTIONAL_TEST=${RETVAL_GET_CORRECT_FILENAME}
        echo -e "[${GREEN}SUCCESS${NC}] Using 'bin/${FUNCTIONAL_TEST##*/}' for executing functional test"
    else
        echo -e "[${RED}ERROR${NC}] Functional Test file ('bin/run_functional_tests') not found in root folder"
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
    ${CLEANUP} &&\
    rm -f ${BASEDIR}/${SUBMISSION_NAME} &&\
    cp -r ${BASEDIR} /tmp/${PROBLEM_NAME} &&\
    tar -cf /${BASEDIR}/${SUBMISSION_NAME} -C /tmp ${PROBLEM_NAME}
}

function valid_git_repo(){
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

function has_readme(){
    [[ -n $(find ${BASEDIR} -name "README.*" -maxdepth 1 ) ]]
}

function fix_functional_test_runner(){
    sed "s:^system cmd:exit system cmd:" -i ${FUNCTIONAL_TEST}
}

if ! detectBinFiles ; then
    echo -e "[${RED}ERROR${NC}] Failed to find bin files"
    exit -1
fi

fix_functional_test_runner

if ! valid_git_repo ; then
    echo -e "[${RED}ERROR${NC}] This is not a valid git repository!!, probably '.git' folder is missing"
    exit -1
fi

if ! has_readme ; then
    echo -e "[${RED}ERROR${NC}] 'README' is not present in project root folder"
    exit -1
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
    echo -e "Sample tests executed, check console for result"
fi

if ! create_submission; then
    echo -e "[${RED}ERROR${NC}] Failed to create submission"
    exit -1
else
    echo -e "[${GREEN}SUCCESS${NC}] Submit ${GREEN}${SUBMISSION_NAME}${NC} to the coordinator."
fi