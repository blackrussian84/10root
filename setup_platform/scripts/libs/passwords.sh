#!/bin/bash

set -e

function _list_passwords_from_compose() {
  local workdir=$1

  if [[ -e "${workdir}/docker-compose.yml" || -e "${workdir}/docker-compose.yaml" ]]; then
    local name
    name=$(find "${workdir}" -maxdepth 1 -name 'docker-compose.y*' | grep -E 'ya?ml$' | head -n 1)
    # Env secrets
    mapfile -t env_secrets < <(sed -n 's#.*\(env\..*\.secret\).*#\1#p' "${name}" | sort | uniq)
    if [[ ${#env_secrets[@]} -gt 0 ]]; then
      printf "%s\n" "${env_secrets[@]}"
    fi
    mapfile -t build_secrets < <(sed -En 's#.*:\s*(\b.*\.passwd).*#\1#p' "${name}" | sort | uniq)
    if [[ ${#build_secrets[@]} -gt 0 ]]; then
      printf "%s\n" "${build_secrets[@]}"
    fi
    printf "%s\n" "${build_secrets[@]}"
  fi
}

_list_password_files() {
  local workdir=$1

  # shellcheck disable=SC2044
  for i in "$workdir"/env.*.secret "$workdir"/*.passwd; do
    [[ -f $i ]] || continue
    printf '%s\n' "${i##*/}"
  done
}

function check_password_generator() {
  if [[ -z "${PASSWORD_GENERATOR}" ]]; then
    # Recommended: `apg -n 1 -m 16 -x 20 -MSNCL`
    export PASSWORD_GENERATOR="LC_ALL=C tr -dc 'A-Za-z0-9-_!' </dev/urandom | head -c 16"
  fi
}

setup_shell() {
  SH=${SH:-$(command -v bash)}
}

function generate_passwords_if_required() {
  local workdir=$1

  printf "Start generating passwords...\n"
  if [[ "${GENERATE_PASSWORDS}234${GENERATE_ALL_PASSWORDS}" != 234 ]]; then
    mapfile -t required < <(_list_passwords_from_compose "$workdir")
    mapfile -t existing < <(_list_password_files "$workdir")
      if [[ ${#existing[@]} -gt 0 ]]; then
        # Two matching names means we have the same thing defined in docker-compose.yaml and env secrets
        mapfile -t defined < <(printf "%s\n%s\n" "${required[@]}" "${existing[@]}" | sort | uniq -c | sort -rn | grep -E '\s*2' | awk '{print $2}')
        # Filter out extra env secrets that are not required
        mapfile -t undefined < <(printf "%s\n%s\n" "${required[@]}" "${defined[@]}" | sort | uniq -c | sort -rn | grep -E '\s*1' | awk '{print $2}')
        for var in "${undefined[@]}"; do
          printf "%s\n" "$(sh -c "${PASSWORD_GENERATOR}")" > "${workdir}/${var}"
        done
      fi
      for var in "${required[@]}"; do
        printf "%s\n" "$(sh -c "${PASSWORD_GENERATOR}")" > "${workdir}/${var}"
      done
    fi
  }

setup_shell
check_password_generator
