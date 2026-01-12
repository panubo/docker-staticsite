# Load bats libraries

# This list of PATHs should cover Linux, Mac and GitHub Actions
BATS_LIB_PATH="~/.bats/libs:/opt/homebrew/lib:/usr/local/bats:/usr/local:/usr/lib/bats:/usr/lib"}
export BATS_LIB_PATH
bats_load_library bats-support
bats_load_library bats-assert
bats_load_library bats-file
bats_load_library bats-detik/utils.bash
bats_load_library bats-detik/detik.bash
