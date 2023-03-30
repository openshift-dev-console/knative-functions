#!/bin/bash

set -e

echo func $(func version)

if [[ `git status --porcelain` ]]; then
    echo "Git repo is not clean. Please commit or revert your local changes first."
    exit -1
fi

for language in go node python quarkus rust springboot; do
    for template in cloudevents http; do
        rm -rf "$language-$template"
        func create -l "$language" -t "$template" "$language-$template"
        sed '/created:/d' -i "$language-$template/func.yaml"
        git add "$language-$template"
        git commit -m "Create $language $template"
    done
done
