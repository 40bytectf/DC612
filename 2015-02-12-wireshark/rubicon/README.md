First find lolcats login and subsequent password request / entry
Next TCP port used for information exchange (i.e. 43515 was login, 43516 was next)

so this filter "tcp.port==43516 && ftp" will get us the relevent packets


