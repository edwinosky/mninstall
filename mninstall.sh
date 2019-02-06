#!/bin/sh

noflags() {
        echo "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"
    echo "Usage: mninstall"
    echo "Example: mninstall"
    echo "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"
    exit 1
}

message() {
        echo "╒═════════════════════════════════════<<<**>>>═══════════════════════════════════>>>"
        echo "| $1"
        echo "╘═════════════════════════════════════<<<**>>>═══════════════════════════════════>>>"
}

error() {
        message "An error occured, you must fix it to continue!"
        exit 1
}

prepdependencies() { #TODO: add error detection
        message "Installing dependencies..."
        sudo apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
        sudo apt-get install automake libdb++-dev build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev libminiupnpc-dev git software-properties-common g++ bsdmainutils libevent-dev -y
        sudo add-apt-repository ppa:bitcoin/bitcoin -y
        sudo apt-get update
        sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
}

createswap() { #TODO: add error detection
        message "Creating 2GB temporary swap file...this may take a few minutes..."
        sudo dd if=/dev/zero of=/swapfile bs=1M count=2000
        sudo mkswap /swapfile
        sudo chown root:root /swapfile
        sudo chmod 0600 /swapfile
        sudo swapon /swapfile

        #make swap permanent
        sudo echo "/swapfile none swap sw 0 0" >> /etc/fstab
}
clonerepo() { #TODO: add error detection
        message "Cloning from github repository..."
        cd ~/
        git clone https://github.com/FabiannoLimma/project-adevplus2.0.git
}
compile() {
        cd project-adevplus2.0 #TODO: squash relative path
        message "Preparing to build..."
        chmod 777 autogen.sh && ./autogen.sh
        if [ $? -ne 0 ]; then error; fi
        message "Configuring build options..."
        ./configure $1 --disable-tests --with-gui=no
        if [ $? -ne 0 ]; then error; fi
        message "Building AdevPlus2.0...this may take a few minutes..."
        chmod 777 share/genbuild.sh && make
        if [ $? -ne 0 ]; then error; fi
        message "Installing AdevPlus2.0..."
        sudo make install
        if [ $? -ne 0 ]; then error; fi
}

createconf() {
        #TODO: Can check for flag and skip this
        #TODO: Random generate the user and password

        message "Creating adevplus20.conf..."
        MNPRIVKEY="66M7PXr6q8LCQdafoAwoxa927T2jowafosA7vAYAPnRMw3BYX4a"
        CONFDIR=~/.adevplus20
        CONFILE=$CONFDIR/adevplus20.conf
        if [ ! -d "$CONFDIR" ]; then mkdir $CONFDIR; fi
        if [ $? -ne 0 ]; then error; fi

        mnip=$(curl -s https://api.ipify.org)
        rpcuser=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
        rpcpass=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
        printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" > $CONFILE

        adevplus20d
        message "Wait 10 seconds for daemon to load..."
        sleep 20s
        MNPRIVKEY=$(adevplus20-cli masternode genkey)
        adevplus20-cli stop
        message "wait 10 seconds for deamon to stop..."
        sleep 10s
        sudo rm $CONFILE
        message "Updating adevplus20.conf..."
        printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcport=5471" "rpcallowip=127.0.0.1" "externalip=$mnip:5472" "listen=1" "server=1" "daemon=1" "maxconnections=256" "masternode=1" "masternodeprivkey=$MNPRIVKEY" "addnode=177.97.39.28" "addnode=179.177.14.57" "addnode=82.239.216.33" "addnode=187.40.209.150" "addnode=187.44.209.14" "addnode=46.234.130.173" > $CONFILE

}
success() {
        adevplus20d
        message "SUCCESS! Your AdevPlus2.0 has started. Masternode.conf setting below..."
        message "MN $mnip:5472 $MNPRIVKEY TXHASH INDEX"
        exit 0
}

install() {
        prepdependencies
        createswap
        clonerepo
        compile $1
        createconf
        success
}

#main
#default to --without-gui
install --without-gui
