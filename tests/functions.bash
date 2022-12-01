diag() {
	echo "$@" | sed -e 's/^/# /' >&3 ;
}

newer_than() {
	local required actual
	actual="${1}"
	required="${2}"
	printf '%s\n' "${required}" "${actual}" | sort --version-sort --check=quiet
}

# From https://github.com/panubo/bash-container/blob/master/functions/wait_http.sh
wait_http() {
  # Wait for http service to be available
  command -v curl >/dev/null 2>&1 || { error "This function requires curl to be installed."; return 1; }
  local url="${1:-'http://localhost'}"
  local timeout="${2:-30}"
  local http_timeout="${3:-2}"
  echo -n "Connecting to HTTP at ${url}"
  for (( i=0;; i++ )); do
    if [[ "${i}" -eq "${timeout}" ]]; then
      echo " timeout!"
      return 99
    fi
    sleep 1
    (curl --max-time "${http_timeout}" "${url}") &>/dev/null && break
    echo -n "."
  done
  echo " connected."
  exec 3>&-
  exec 3<&-
}
