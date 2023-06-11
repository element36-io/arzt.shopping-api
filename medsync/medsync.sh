#!/bin/bash
script="${1:-medsync}"

docker pull mcr.microsoft.com/powershell
docker run --rm -v "$PWD:/scripts" --workdir "/scripts" mcr.microsoft.com/powershell  pwsh ${script}.ps1

