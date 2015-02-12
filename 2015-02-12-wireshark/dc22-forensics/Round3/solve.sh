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
xz -d -k -c FearThePackets.pcap.xz > ${soldir}/FearThePackets.pcap
echo " Done"


# extract sandofwhich.zip from ftp-data
echo "Extracting zip files from pcap ...."
echo -e "\tsandofwhich.zip...."
tshark -r ${soldir}/FearThePackets.pcap \
	-Y "(tcp.stream==158) && (tcp.dstport == 51463)" \
	-C ftp_disabled -T fields -e data|\
	tr -d '\n'|xxd -r -p > ${soldir}/sandofwhich.zip

# extract ojd34.zip from ftp-data
echo -e "\tojd34.zip...."
tshark -r ${soldir}/FearThePackets.pcap \
	-Y "(tcp.stream==159) && (tcp.dstport == 51464)" \
	-C ftp_disabled -T fields -e data|tr -d '\n'|\
	xxd -r -p > ${soldir}/ojd34.zip

# extract 34jdsioj.zip from http POST (same as breaking_bad_season_6.zip) - packet 2666
# extract breaking_bad_season_6.zip from http POST (same as 34jdsioj.zip) - packet 2666
echo -e "\t34jdsioj.zip...."
echo -e "\tbreaking_bad_season_6.zip...."
tshark -r ${soldir}/FearThePackets.pcap \
	-Y "tcp.stream eq 42 && tcp.dstport==80 && tcp.ack == 4880" \
	-C no_http -T fields  -e data|\
	tr -d '\n'|xxd -p -r > ${soldir}/file.bin

# extract canc3l.zip from POST ( packet #8190 )
echo -e "\tcanc3l.zip...."
tshark -r ${soldir}/FearThePackets.pcap \
	-Y "tcp.stream eq 42 && tcp.dstport==80 && tcp.ack == 28662" \
	-C no_http -T fields  -e data|\
	tr -d '\n'|xxd -p -r >> ${soldir}/file.bin
echo "Done."

# pull zips from bin
/usr/bin/env python parse_zips.py

# extract zips
echo -ne "Extracting 5 zips..."
for i in $(ls solution/*.zip); do unzip -oqq $i -d solution; done
echo " Done."

# rearrang jpgs
find ${soldir} -type f -name "*.jpg" -exec mv {} ${soldir} \;

# clean up
echo -ne "Cleaning up ...."
find ${soldir} -type d -d 1 -exec rmdir {} \; >/dev/null 2>&1
rm ${soldir}/file.bin
rm ${soldir}/FearThePackets.pcap
rm ${soldir}/*.zip
echo " Done."

echo -ne "Building final.jpg ...."
for i in $(cat quote.txt); do cat ${soldir}/$i.jpg >> ${soldir}/final_pic.jpg; done;
echo " Done."














