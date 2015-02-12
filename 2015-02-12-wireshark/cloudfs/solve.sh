#/bin/bash
# http://pastebin.com/qmQsK8gu
#

soldir="solution"
clear
# make solution directory
if [[ -d ${soldir} ]];
then
        read -p "Directory ${soldir} exists, delete [y/n] ? " answer
        if [[ $answer != 'y' ]] && [[ $answer != 'Y' ]];
        then
#               echo "answer = $answer"
                echo 'Exiting...'
                exit 0
        fi
fi

rm -rf ${soldir}
mkdir -p ${soldir}

xz -d -k -c cloudfs.pcapng.xz > ${soldir}/cloudfs.pcapng


# on to the extraction
tshark \
  -r ${soldir}/cloudfs.pcapng \
  -Y "icmp.type==8 && (icmp.ident == 13 ||icmp.ident == 14 ||icmp.ident == 15 ||icmp.ident == 16)"\
  -s0 \
  -e frame.number \
  -e data  \
  -T fields \
  -E separator=, 2>/dev/null|\
sort -t "," -k 2 -u|\
sort -t "," -k 1 -g|\
cut \
  -d "," \
  -f2|\
grep \
  -e "^0030.*425a\|^699b\|6790\|81a7.*f0c0$"|\
tr \
  -d '\n' |\
cut \
  -b 41-|\
xxd \
  -r \
  -p \
  > ${soldir}/file.tar.bz2

# extract the goodies
tar xvf ${soldir}/file.tar.bz2 -C ${soldir}/

# display
cd ${soldir}
clear
ls -l
echo
cat key


