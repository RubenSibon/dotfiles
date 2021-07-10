function check_for_git {
  if ! command -v git > /dev/null; then
    echo "Git is not found. Please install it."
    echo "See: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
    exit 0
  fi
}
