# Install on linux

Go to directory where it should reside.
Setup will download files and add cron entry:


`
wget -O - "https://api.github.com/repos/element36-io/arzt.shopping-api/contents//medsync/medsync.sh?ref=medisync" |  jq -r '.content' | base64 --decode | bash
chmod u+x install_linux.sh
`




# Install on Windows


# Both: modify medsync.txt and values

