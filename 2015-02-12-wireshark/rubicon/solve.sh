#!/bin/bash
#  
# In order to use this, you must have a Configuration Profile built into wireshark called "ftp_disabled" which stops wireshark from
# trying to parse the ftp protocol and let's use use it as raw tcp data
# To do this first go into wireshark, under Edit choose Configuration profiles
# create one called ftp_disabled (don't check global) and save it
# then from the command line create a file called  disabled_protos with one line "ftp" in ~/.wireshark/profiles/ftp_disabled/
#

soldir="solution"
clear
# make solution directory
if [[ -d ${soldir} ]];
then
	read -p "Directory ${soldir} exists, delete [y/n] ? " answer
	if [[ $answer != 'y' ]] && [[ $answer != 'Y' ]];
	then
#		echo "answer = $answer"
		echo 'Exiting...'
		exit 0
	fi
fi

rm -rf ${soldir}
mkdir -p ${soldir}

# extract pcap
xz -f -d -k -c rubicon.pcap.xz > ${soldir}/rubicon.pcap

# get key
tshark -r ${soldir}/rubicon.pcap -Y "frame.number==1497 && (frame.len==85) && (tcp.flags.syn==0)" -C ftp_disabled -e data -Tfields|cut -b 7- > ${soldir}/208_key

# get encrypted file
tshark  -r ${soldir}/rubicon.pcap -Y  "(tcp.dstport==43516) && (frame.number!=1497) && (frame.len>70) && (tcp.flags.syn==0)" -e data -Tfields -C ftp_disabled|tr -d '\n'|xxd -r -p > ${soldir}/f1

# decrypt file
#./decrypt_rc4 f1 $(cat 208_key) > f1.bin
openssl rc4 -d -in ${soldir}/f1 -K $(cat ${soldir}/208_key)  > ${soldir}/f1.bin

# extract payload
binwalk -ez ${soldir}/f1.bin
