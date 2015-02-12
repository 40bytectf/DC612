#!/usr/bin/env bash

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
xz -d -k -c DatSecrets.pcap.xz > ${soldir}/DatSecrets.pcap

# carve out the documents.zip file
echo -ne "Carving Documents.zip ....."
tshark \
	-r ./${soldir}/DatSecrets.pcap \
	-Y "(smb.fid == 0x8008 and ip.src==172.29.1.23) && (smb.cmd == 0x2f)" \
	-T fields \
	-e smb.file_data | \
	tr -d ":" | \
	xxd -r -p > ${soldir}/Documents.zip

echo " Done."
echo -ne "Extracting Document.zip....."

# extract the Documents.zip file
unzip -q ${soldir}/Documents.zip -d ${soldir}/
echo " Done."

# pull out all the plaintext from docx file
echo  "Extracting zips and docx's ..... "
find ${soldir} -type f -name "*docx" > ${soldir}/tmpfile
mkdir -p ${soldir}/docfiles
num=0

# pull all the document.xmls out and base64 decode the txt
while read line
do
	echo "   Extracting file $line...as number $num"
	unzip -q -c "${line}" word/document.xml| \
	grep -v "<?xml"|\
	sed 's/\(<[^>]*>\)//g'|\
	base64 -D > ${soldir}/docfiles/file-$num.txt
	((num+=1))	
done < ${soldir}/tmpfile
echo "Done."
echo "Check your plaintext files in $soldir/docfiles/"
