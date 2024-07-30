#!/bin/bash

######################################################################
###This script will add a new local user account to a macOS device. ##
###It is written to be deployed via MDM. If run ad-hoc,    ###########
###remove the 'sudo' from each line, run 'sudo su -' at the terminal #
###and type your password (assuming you have admin rights).   ########
###Then run each line one by one.   ##################################
######################################################################

sudo dscl . -create /Users/USERNAME
sudo dscl . -create /Users/USERNAME UserShell /bin/bash
sudo dscl . -create /Users/USERNAME RealName "USERNAME"
sudo dscl . -create /Users/USERNAME UniqueID "565"
sudo dscl . -create /Users/USERNAME PrimaryGroupID 80
sudo dscl . -create /Users/USERNAME NFSHomeDirectory /Users/USERNAME
sudo dscl . -passwd /Users/USERNAME PASSWORD
sudo dscl . -append /Groups/admin GroupMembership USERNAME