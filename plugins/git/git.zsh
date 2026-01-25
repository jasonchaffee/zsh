# -------------------------------------------------------------------
# Run git up recursively over the specified directory
# -------------------------------------------------------------------
git_up() {
  PROJECT_DIR=$1

  for directory in $(find "${PROJECT_DIR}" -type d); do
    if [ -d "${directory}/.git" ]; then
      pushd "${directory}"
      echo "${directory}"
      git up
      popd
    fi
  done
}