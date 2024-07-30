#!/bin/bash

######################################################################
###This script will remove a local user account to a macOS device. ###
###It is written to be deployed via MDM. If run ad-hoc,    ###########
###add a 'sudo' to the beginning of each line and run each ###########
###line one by one, supplying your password as needed.   #############
######################################################################

#remove the USERNAME account
dscl . delete /users/USERNAME

#remove the USERNAME home directory
rm -rf /users/USERNAME