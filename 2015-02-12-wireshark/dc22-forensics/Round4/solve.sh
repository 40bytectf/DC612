#!/usr/bin/env bash
#

soldir="."
pcap="TwueLub.pcap"
clear

# extract file
echo -ne "Extracting pcap...."
xz -d -k -c ${pcap}.xz > ${soldir}/${pcap}
echo " Done"


tcpdump -r ${soldir}/${pcap} -A  "udp src port 16402"|\
	grep -v "10\:12" |\
	grep @127.0|\
	grep -e '[a-z0-9\-\@\.]\+'|\
	sed 's/^\(.*\.\([a-z][0-9a-zA-Z-]*\)@.*$\)/\2/'|\
	uniq


rm ${soldir}/${pcap}
