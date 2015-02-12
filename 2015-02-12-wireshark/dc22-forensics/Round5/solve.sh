#!/usr/bin/env bash
#

soldir="solution"
pcap="RomanticDate.pcap"
clear

# make solution directory
if [[ -d ${soldir} ]];
then
        read -p "Directory ${soldir} exists, delete [y/n] ? " answer
        if [[ $answer != 'y' ]] && [[ $answer != 'Y' ]];
        then
                echo 'Exiting...'
                exit 0
        fi
fi
rm -rf ${soldir}
mkdir -p ${soldir}

# extract file
echo -ne "Extracting pcap...."
xz -d -k -c ${pcap}.xz > ${soldir}/${pcap}
echo " Done"



echo -ne "Extracting json from pcap...."
tshark -r ${soldir}/${pcap} -Y "json and (not tcp.analysis.retransmission)" -w ${soldir}/json.pcap -F pcap
tshark -r ${soldir}/json.pcap -C no_http -Tfields -e data |xxd -r -p > ${soldir}/json.txt
echo " Done"

echo -ne "Parsing json...."
/usr/bin/env python parse_json.py
echo " Done"

echo -ne "Extracting conversations...."
sort -u -t ',' -k 1 ${soldir}/jtext.txt |sort -t ',' -k 2 |cut -d ',' -f3- > ${soldir}/conversations.txt
echo " Done"


echo -ne "Extracting map coordinates...."
tshark -r ${soldir}/${pcap} -Y "http.request.method==GET" 2>/dev/null|sed 's/^.*location=\(.*\)$/\1/'|sed 's/%2C/,/'|cut -d' ' -f1|grep ',' 2> /dev/null 1>${soldir}/coordinates.txt
echo " Done"

echo -ne "Cleaning up...."
rm ${soldir}/json.pcap
rm ${soldir}/json.txt
rm ${soldir}/jtext.txt
echo " Done"
