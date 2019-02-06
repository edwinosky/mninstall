# MNinstall
Masternode Auto Install

Shell script to install a AdevPlus2.0 Masternode on a Linux server running Ubuntu 16.04

# VPS installation
```
git clone https://github.com/edwinosky/mninstall.git
cd mninstall
bash mninstall.sh
```

# Desktop wallet setup
After the daemon is compiled and synchronized in the vps, you must configure the desktop wallet with the following steps:

1:) Open the altbet Desktop Wallet.
2:) Go to RECEIVE and create a New Address: MN1

3:) Send 26000 ADV2 to MN1. You need to send all 26000 coins in one single transaction.

4:) Wait for 20 confirmations.

5:) Go to **Help -> "Debug Window - Console"**

6:) Type the following command: **masternode outputs**
you will get the TxHash TxIndex

7:) Go to **Tools -> "Open Masternode Configuration File"**
8:) Add the following entry:
    Alias Address Privkey TxHash TxIndex
    Alias: **MN1**
    Address: **VPS_IP:PORT**
    Privkey: **Masternode Private Key**
    TxHash: **First value from Step 6**
    TxIndex: **Second value from Step 6**
Save and close the file.

9:) Go to **Masternode Tab**. If you tab is not shown, please enable it from: Settings - Options - Wallet - Show Masternodes Tab and restart

10:) Click **Update status** to see your node. If it is not shown, close the wallet and start it again. Make sure the wallet is unlocked.

11-a:) Select your MN and click **Start Alias** to start it.

11-b:) Alternatively, open Debug Console and type:
       ```
       masternode start-alias MN1
       ```
       OR
       ```
       startmasternode alias false MN1
       ```

Login to your VPS and check your masternode status by running the following command to confirm your MN is running:
adevplus20-cli masternode status


##Usage:
```
adevplus20-cli masternode status
adevplus20 getinfo
adevplus20-cli mnsync status
```

## Contact
https://discord.gg/VWC8b7a
