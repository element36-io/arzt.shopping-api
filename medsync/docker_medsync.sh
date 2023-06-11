docker pull mcr.microsoft.com/powershell
#docker run --rm -v "$PWD:/scripts" --workdir "/scripts" mcr.microsoft.com/powershell  pwsh init.psm1
#docker run --rm -v "$PWD:/scripts" --workdir "/scripts" mcr.microsoft.com/powershell  pwsh medsync.ps1
docker run --rm -v "$PWD:/scripts" --workdir "/scripts" mcr.microsoft.com/powershell  pwsh updater.ps1

