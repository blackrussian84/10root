#!/bin/bash

set -e

function _list_passwords_from_compose() {
  local workdir=$1

  if [[ -e "${workdir}/docker-compose.yml" || -e "${workdir}/docker-compose.yaml" ]]; then
    local name=$(ls "${workdir}"/docker-compose.y* | grep -E 'ya?ml$' | head -n 1)
    # Env secrets
    mapfile -t env_secrets < <(sed -n 's#.*\(env\..*\.secret\).*#\1#p' "${name}" | sort | uniq)
    if [[ ${#env_secrets[@]} -gt 0 ]]; then
      printf "%s\n" "${env_secrets[@]}"
    fi
    if [[ ${#build_secrets[@]} -gt 0 ]]; then
      printf "%s\n" "${build_secrets[@]}"
    fi
    mapfile -t build_secrets < <(sed -En 's#.*:\s*(\b.*\.passwd).*#\1#p' "${name}" | sort | uniq)
    printf "%s\n" "${build_secrets[@]}"
  fi
}

  if [[ ${#env_files[@]} -gt 0 ]]; then
    printf "%s\n" "${env_files[@]}"
  if [[ ${#passwd_files[@]} -gt 0 ]]; then
    printf "%s\n" "${passwd_files[@]}"
  fi
  local workdir=$1

  mapfile -t env_files < <(find "$workdir" -type f -not -empty -name 'env.*.secret' -exec basename {} \;)
  printf "%s\n" "${env_files[@]}"
  mapfile -t passwd_files < <(find "$workdir" -type f -not -empty -name '*.passwd' -exec basename {} \;)
  printf "%s\n" "${passwd_files[@]}"
}

function check_password_generator() {
  if [[ -z "${PASSWORD_GENERATOR}" ]]; then
    # Recommended: `apg -n 1 -m 16 -x 20 -MSNCL`
    export PASSWORD_GENERATOR="LC_ALL=C tr -dc 'A-Za-z0-9-_!' </dev/urandom | head -c 16"
  fi
}

function setup_shell() {
  # We can not rely on ${SHELL} variable
  export SH=${SH:-/bin/bash}
}

function generate_passwords_if_required() {
  local workdir=$1

  printf "Start generating passwords...\n"
  if [[ "${GENERATE_PASSWORDS}234${GENERATE_ALL_PASSWORDS}" != 234 ]]; then
    mapfile -t required < <(_list_passwords_from_compose "$workdir")
          sh -c "${PASSWORD_GENERATOR}" > "${workdir}/${var}"
      mapfile -t existing < <(_list_password_files_with_passwords "$workdir")
      if [[ ${#existing[@]} -gt 0 ]]; then
        # Two matching names means we have the same thing defined in docker-compose.yaml and env secrets
        mapfile -t defined < <(printf "%s\n%s\n" "${required[@]}" "${existing[@]}" | sort | uniq -c | sort -rn | grep -E '\s*2' | awk '{print $2}')
        # Filter out extra env secrets that are not required
        mapfile -t undefined < <(printf "%s\n%s\n" "${required[@]}" "${defined[@]}" | sort | uniq -c | sort -rn | grep -E '\s*1' | awk '{print $2}')
        for var in "${undefined[@]}"; do
          printf "%s\n" "$(sh -c "${PASSWORD_GENERATOR}")" > "${workdir}/${var}"
        done
      fi
    else
      for var in "${required[@]}"; do
        printf "%s\n" "$(sh -c "${PASSWORD_GENERATOR}")" > "${workdir}/${var}"
      done
    fi
  fi
}

setup_shell
check_password_generator
