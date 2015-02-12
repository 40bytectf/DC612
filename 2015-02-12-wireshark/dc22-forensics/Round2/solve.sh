#!/usr/bin/env bash
#

soldir="solution"
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
xz -d -k -c FIFA22.pcap.xz > ${soldir}/FIFA22.pcap
echo " Done"

# process file data requests
echo -ne "Extracting IRC requests...."
tshark -r ${soldir}/FIFA22.pcap \
	-Y "(irc.request.trailer and irc.request.command==\"PRIVMSG\")" \
	-E separator=',' -T fields \
	-e frame.number \
	-e irc.request.command \
	-e irc.request.command_parameter \
	-e irc.request.trailer|\
	tr -d '\t'|tr -d ' '|grep -v "PING" > ${soldir}/tmpfile.txt
echo " Done."
echo -ne "Extracting IRC responses...."
# process file data responses
tshark -r ${soldir}/FIFA22.pcap \
	-Y "(irc.response.trailer and irc.response.command==\"PRIVMSG\")" \
	-E separator=',' -T fields \
	-e frame.number \
	-e irc.response.command \
	-e irc.response.command_parameter \
	-e irc.response.trailer|\
	tr -d '\t'|tr -d ' ' >> ${soldir}/tmpfile.txt
echo " Done."
echo -ne "Sorting output ...."
sort -n -k 1 -t ',' -o ${soldir}/sorted.txt   ${soldir}/tmpfile.txt 
echo " Done."

echo  -ne "Decoding IRC messages...."
/usr/bin/env python ./parse-irc.py > ${soldir}/chat.txt
echo " Done"
