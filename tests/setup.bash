# Load bats libraries

BATS_LIB_PATH=${BATS_LIB_PATH:-"~/.bats/libs:/usr/lib/bats"}
if BREW_PREFIX="$(brew --prefix)"; then
  BATS_LIB_PATH="${BATS_LIB_PATH}:${BREW_PREFIX}/lib"
fi
export BATS_LIB_PATH
bats_load_library bats-support
bats_load_library bats-assert
bats_load_library bats-file
bats_load_library bats-detik/utils.bash
bats_load_library bats-detik/detik.bash
