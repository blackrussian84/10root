#!/bin/bash

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'

echo -e "${GREEN}+++ RUNNING A PRIMITIVE TEST SUITE +++${NC}"
for t in $(find . -name '*_testcase.sh');
do
  echo -n "Running ${t}: "
  {
      IFS=$'\n' read -r -d '' CAPTURED_STDOUT;
      IFS=$'\n' read -r -d '' CAPTURED_STDERR;
      (IFS=$'\n' read -r -d '' _ERRNO_; exit ${_ERRNO_});
  } < <((printf '\0%s\0%d\0' "$(((({ /bin/bash ${t}; echo "${?}" 1>&3-; } | tr -d '\0' 1>&4-) 4>&2- 2>&1- | tr -d '\0' 1>&4-) 3>&1- | exit "$(cat)") 4>&1-)" "${?}" 1>&2) 2>&1)
  _ERRNO_=${?}
  if [[ "${_ERRNO_}" -eq 0 ]]
  then
    echo -e "${GREEN}OK${NC}"
  else
    echo -e "${RED}FAIL: exit code $(printf "%u" ${_ERRNO_})${NC}"
  fi
  echo "=== OUTPUT ==="
  echo ${CAPTURED_STDOUT}
  echo "=== ERROR ==="
  echo ${CAPTURED_STDERR}
done

echo -e "${GREEN}--- PRIMITIVE TEST SUITE DONE ---${NC}"