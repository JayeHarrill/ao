# update
sudo apt update -yqqq 2>/dev/null
sudo apt autoremove -yqqq
echo apt update complete

# upgrade
sudo apt upgrade -yqqq
echo apt upgrade complete

# install git
if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo git already installed
else
	sudo apt install -y git
fi

# install sqlite3
if [ $(dpkg-query -W -f='${Status}' sqlite3 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo sqlite3 already installed
else
	sudo apt install -y sqlite3
fi

cd ~
if [ ! -d "$HOME/.ao" ];
then
	mkdir -p $HOME/.ao
fi

# install npm
if [ $(dpkg-query -W -f='${Status}' npm 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	NPMVERSION=`npm -v`
	echo npm v$NPMVERSION already installed
else
	sudo apt install -y npm
fi

# install nvm
if [ -f "$HOME/.nvm/nvm.sh" ];
then
	. ~/.nvm/nvm.sh
fi

if [ $(command -v nvm | grep -c "nvm") -eq 1 ];
then
	NVMVERSION=`nvm --version`
	echo nvm v$NVMVERSION already installed
else
	git clone https://github.com/creationix/nvm.git ~/.nvm 2>/dev/null
	sudo echo "source ~/.nvm/nvm.sh" >> ~/.bashrc
	sudo echo "source ~/.nvm/nvm.sh" >> ~/.profile
	source ~/.bashrc
	source ~/.profile
fi

NODEVERSION=`nvm current`

# install node
if [ $(echo $NODEVERSION | grep -c "v11") -eq 1 ];
then
	echo node $NODEVERSION already installed
else
	nvm install 11
fi

#install yarn
if [ $(yarn --version | grep -c "1\.17\.3") -eq 1 ];
then
	echo yarn v1.17.3 already installed
else
	cd ~
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
	sudo apt-get update && sudo apt-get install -y --no-install-recommends yarn
	yarn cache clean
fi

# install c-lightning
# test these to see which are optional. autodev-tools might be optional.
if [ $(dpkg-query -W -f='${Status}' zlib1g-dev 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo zlib1g-dev already installed
else
	sudo apt install -y zlib1g-dev
fi

if [ $(dpkg-query -W -f='${Status}' libtool 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo libtool already installed
else
	sudo apt install -y libtool
fi

if [ $(dpkg-query -W -f='${Status}' autoconf 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo autoconf already installed
else
	sudo apt install -y autoconf
fi

if [ $(dpkg-query -W -f='${Status}' automake 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo automake already installed
else
	sudo apt install -y automake
fi

if [ $(dpkg-query -W -f='${Status}' autotools-dev 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo autotools-dev already installed
else
	sudo apt install -y autotools-dev
fi

if [ $(dpkg-query -W -f='${Status}' libgmp-dev 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo libgmp-dev already installed
else
	sudo apt install -y libgmp-dev
fi

if [ $(dpkg-query -W -f='${Status}' libsqlite3-dev 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo libsqlite3-dev already installed
else
	sudo apt install -y libsqlite3-dev
fi

if [ $(dpkg-query -W -f='${Status}' python 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo python already installed
else
	sudo apt install -y python
fi

if [ $(dpkg-query -W -f='${Status}' python3 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo python3 already installed
else
	sudo apt install -y python3
fi

if [ $(dpkg-query -W -f='${Status}' python3-mako 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo python3-mako already installed
else
	sudo apt install -y python3-mako
fi

if [ $(dpkg-query -W -f='${Status}' libsodium-dev 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo libsodium-dev already installed
else
	sudo apt install -y libsodium-dev
fi

if [ $(lightning-cli --version 2>/dev/null | grep -c "v0\.7\.2") -eq 1 ];
then
	echo c-lightning v0.7.2 already installed
else
	cd ~
	git clone https://github.com/ElementsProject/lightning.git
	lightning=true
	cd lightning
	./configure
	make
	sudo make install
fi

# bitcoin: download a hosted copy of the current bitcoin executable for pi

# install tor
if [ $(tor --version  2>/dev/null | grep -c "0\.4\.0\.5") -eq 1 ];
then
	echo tor v0.4.0.5 already installed
else
	if [ $(dpkg-query -W -f='${Status}' build-essential 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		sudo apt install -y build-essential
	fi

	if [ $(dpkg-query -W -f='${Status}' fakeroot 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		sudo apt install -y fakeroot
	fi

	if [ $(dpkg-query -W -f='${Status}' devscripts 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		sudo apt install -y devscripts
	fi

	if [ $(dpkg-query -W -f='${Status}' libevent-dev 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		sudo apt install -y libevent-dev
	fi

	if [ $(dpkg-query -W -f='${Status}' libssl-dev 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		sudo apt install -y libssl-dev
	fi

	cd ~
	wget https://dist.torproject.org/tor-0.4.0.5.tar.gz
	tor=true
	tar xf tor-0.4.0.5.tar.gz
	cd tor-0.4.0.5
	./configure
	make
	sudo make install
fi

# configure tor
TORRCPATH='/usr/local/etc/tor/torrc'

if [ ! -f $TORRCPATH ];
then
	sudo cp $TORRCPATH.sample $TORRCPATH
fi

if [ $(cat $TORRCPATH | grep -c "HiddenServiceDir /var/lib/tor/ao") -eq 0 ];
then
	echo "HiddenServiceDir /var/lib/tor/ao" | sudo tee -a $TORRCPATH 1>/dev/null 2>&1
fi

if [ $(cat $TORRCPATH | grep -c "HiddenServiceDir /var/lib/tor/ao") -eq 0 ];
then
	echo "HiddenServiceDir /var/lib/tor/ao" | sudo tee -a $TORRCPATH 1>/dev/null 2>&1
fi

if [ $(cat $TORRCPATH | grep -c "HiddenServicePort 80 127\.0\.0\.1:8003") -eq 0 ];
then
	echo "HiddenServicePort 80 127.0.0.1:8003" | sudo tee -a $TORRCPATH 1>/dev/null 2>&1
fi

# install borgbackup
if [ $(dpkg-query -W -f='${Status}' borgbackup 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo borgbackup already installed
else
	sudo apt install -y borgbackup
fi

# clone the AO repository
cd ~
if find "ao" -mindepth 1 -print -quit 2>/dev/null | grep -q .;
then
	echo ao git repository already cloned
else
	git clone https://github.com/autonomousorganization/ao
fi

# install project dependencies
cd ao
if [ $(yarn check --integrity | grep -c "success") -eq 1 ];
then
	echo 'yarn install' already complete
else
	yarn install --network-timeout 10000000
fi

# create configuration.js
if [ -f "$HOME/ao/configuration.js" ];
then
	echo configuration.js already exists
else
	CONFIG="module.exports = {
    bitcoind: {
        network: 'regtest'
    },
    bitcoinAverage: {
        pub: '',
        secret: ''
    },
    sqlite3: {
        file: '$HOME/.ao/database.sqlite3'
    },
    clightning: {
        dir: '$HOME/.lightning/'
    },
}"
    echo "$CONFIG" > $HOME/ao/configuration.js
    echo configuration.js file created
fi

# set up AO to autostart as a daemon via systemd
if [ -f "/etc/systemd/system/ao.service" ];
then
	echo systemd startup file already exists
else
	UNIT="[Unit]
Description=ao-daemon

[Service]
ExecStart=$HOME/.nvm/versions/node/v11.15.0/bin/node $HOME/ao/production/server/app.js
User=doge
Type=simple
Restart=always
RestartSec=30
PrivateTmp=true

[Install]
WantedBy=multi-user.target"

	echo "$UNIT" | sudo tee -a /etc/systemd/system/ao.service 1>/dev/null 2>&1
	sudo systemd startup file created
fi

if [ $(sudo systemctl status ao | grep -c "disabled") -eq 0 ];
then
	echo systemd startup already enabled
else
	sudo systemctl enable ao
	echo systemd startup enabled
fi

# cleanup c-lightning install
cd ~
if [ "$lightning" = true ];
then
	rm -rf lightning
fi

# cleanup tor install
if [ "$tor" = true ];
then
	rm -rf tor-*
	rm tor-0.4.0.5.tar.gz
fi

echo the AO is installed