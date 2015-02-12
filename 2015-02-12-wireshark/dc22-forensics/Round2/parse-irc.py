#! /usr/bin/python

from base64 import *
import sys,os
import re

path = os.getcwd()
soldir = "solution"

path = path + os.sep + soldir + os.sep
cfile = "sorted.txt"

f = open(path + cfile)
d = f.read().rstrip().split()
f.close()

def decode( m ):
    mb = list()
    prev = ""
    for i in m:
        x = i.split(',')
        name = x[2]
        tmp = ""
        try:
            tmp = b64decode(x[3])
        except TypeError as te:
            pass
        try:
            if (tmp.count(' ')==1 and len(tmp)> 100):  #edge case
                tmp = tmp[ tmp.index(' ')+1 : ]
            tmp = b32decode(tmp)
        except TypeError as te:
            pass
        try:
            tmp = tmp.decode('hex')
        except TypeError as te:
            pass
        try:
            if ( tmp.replace(' ','').isdigit() and len(tmp) > 1 ):
                s=""
                for i in tmp.split(' '):
                    s += (chr(int(i,8)))
                tmp = s
        except TypeError:
            pass
        except Exception as e:
            raise e
        tmp = re.sub(r'[^\x20-\x7e]','',tmp)
        if (prev != tmp and len(tmp)>1):
            prev = tmp
            mb.append(( name, tmp ))
    return mb


def oct_tostring( foo ):
    s=""
    for i in foo.split():
        try:
            s=s+(chr(int(i,8)))
        except Exception as e:
            raise e
    return s


if __name__ == "__main__":
    g=decode(d)
    for i in g:
        print (i[0] + ":" + i[1])

        
