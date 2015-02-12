import os,sys

fname = "file.bin"
cwd = os.getcwd()
soldir = "solution"

ZIPS = ["breaking_bad_season_6.zip","34jdsioj.zip","canc3l.zip"]

TRLR = "\"\r\n"
ZCON = "Content-Type: application/zip\r\n\r\n"
ZEND = "\r\n---------------------"

f= open( cwd + os.sep + soldir + os.sep + fname,'rb' )
data = f.read()
f.close()


for i in ZIPS:
    z1s = data.find(i+TRLR) + len(i) + len(TRLR) + len(ZCON)
    z1e = data.find(ZEND, z1s)
    z1f = data[z1s:z1e]

    z1 = open(soldir+os.sep+i,'w+b')
    z1.write(z1f)
    z1.flush()
    z1.close()
