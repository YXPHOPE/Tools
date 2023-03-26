import ipaddress
import requests
import threading
ip = [192,168,0,0]
print(str(ip)[1:-1].split(', '))
ipad = '.'.join(str(ip)[1:-1].split(', '))
def connect(ipad=''):
    try:
        res = requests.head('http://'+ipad,timeout=0.5)
        if res.ok :
            print("\033[1;33m"+ipad +"\033[0m\n",end='')
    except:pass

for i in range(256):
    ip[2] = i
    for j in range(256):
        ip[3] = j
        ipaddress = '.'.join(str(ip)[1:-1].split(', '))
        t = threading.Thread(target=connect,kwargs={'ipad':ipaddress})
        t.start()