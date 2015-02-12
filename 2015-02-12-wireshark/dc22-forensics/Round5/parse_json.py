#/usr/bin/env python

import json
import os,sys
import time,calendar

# some constants for file manipulation
cdir = os.getcwd()
soldir = "solution"
jfile = "json.txt"
jtext = "jtext.txt"
smesg = "sentMessages"
rmesg = "recMessages"
fields = ['messageId','time','senderName','messageText']

# files to read and write
f = open(cdir + os.sep + soldir + os.sep + jfile,'rb')
fo = open(cdir + os.sep + soldir + os.sep + jtext,"w+b")

data = f.readlines()
jlist=list()
f.close()

#  some cleanup messages to prune
jstr = '{"supportedMessages":["bsm"]}'
jlen = len(jstr)

for x in range(0, len(data)):
    i=data[x]
    tmp=i.lstrip()
    if tmp[0:1]=='{':
        if (tmp.rfind('}') != -1 ):
            tmp=tmp[:tmp.rfind('}')+1]
            if ((tmp.find(jstr) != -1) and (tmp.find(jstr)+jlen == len(tmp))):
                continue
            elif (tmp.find(jstr) != -1):
                tmp=tmp[jlen:]
        else:
            continue
        try:
            jtmp=json.loads(tmp)
            if (jtmp.has_key('result')):
                mtmp=jtmp.get('result')
                if mtmp.has_key(smesg):
                    jlist.append(mtmp.get(smesg))
                if mtmp.has_key(rmesg):
                    jlist.append(mtmp.get(rmesg))
        except ValueError as ve:
            print ("Received: " + str(ve) + " on record: " + str(x) + "\n")

for i in jlist:
    try:
        j=(i[0])
        t=""
        for x in fields:
            if x=="time":
                foo=calendar.timegm(time.strptime(j.get(x),"%Y-%m-%d %H:%M:%S"))
            else:
                foo=j.get(x)
            if foo != "":
                t += str(foo) + ','
        fo.write(str(t.rstrip(','))+'\n')
    except IndexError:
        continue

fo.flush()
fo.close()
    

