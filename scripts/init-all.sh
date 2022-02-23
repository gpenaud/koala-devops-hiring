#! /bin/bash

for directory in $(find . -type d ! -path '*/.terraform*'); do
  # determine .tf presence in potential terraform directories
  # avoid to execute terraform init for nothing
  [[ $(ls -1 ${directory}/*.tf 2>/dev/null | wc -l) == 0 ]] && {
    continue
  }

  # initialize terraform only if needed or forced by user
  if [ ! -d "${directory}/.terraform" ] || [ ! -f "${directory}/.terraform.lock.hcl" ]; then
    terraform -chdir=${directory} init
  fi
done

exit 0
