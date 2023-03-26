import requests
import re
import os
import sys
from tqdm import tqdm
import threading
from Crypto.Cipher import AES
from concurrent.futures import ThreadPoolExecutor
m3u8 = input('m3u8= ')
if not (m3u8 and 'http' in m3u8):
    exit()
elif '.ts' in m3u8:
    m3u8=re.sub(r'/[^/]+\.ts','/index.m3u8',m3u8)
    print('To',m3u8)
Name = input('name= ')
if not Name:
    exit()  # 名字很重要，不要重名，除非是同一个，可以继续下载
start = 1
end = 0  # 0表示到最后一个
done = []


def down(url, name):
    try:
        nm = './m3u8/'+Name+'/'+name
        if (os.path.exists(nm)):
            if '.ts' in name:
                done.append(name)
                pbar.update(1)
                return False
            else:
                with open(nm, 'r') as f:
                    return f.read()
        for i in range(3):
            try:
                res = requests.get(url, timeout=10)
            except:
                if (i == 2):
                    print('Failed:', name,url)
                    if 'm3u8' in name: exit()
                    return False
                continue
            else:
                break
        open(nm, 'w').close()
        with open(nm, "rb+") as f:
            con = res.content
            if '.ts' in name:
                pbar.update(1)
            if (encrypted & KEY):
                con = aes.decrypt(con)
            f.write(con)
            if '.ts' in name:
                done.append(name)
    except Exception as e:
        print(name, ':', e)
    return res.text
def tonum(n):
    if re.match(r'^\d+',n):
        return int(re.sub(r'^(\d+).*$',r'\1',n))
    else: return None
cwd = os.getcwd()
# 给定m3u8地址
path = re.sub(r'^(.*\/)[^\.]+\.m3u8.*$', r'\1', m3u8)
if (len(path) < 4):
    print('Invalid!')
    sys.exit()
# 给定名称
try:
    os.mkdir('./m3u8/'+Name)
except:
    try:
        os.mkdir('./m3u8')
        os.mkdir('./m3u8/'+Name)
    except:
        pass
encrypted = False
with open('./m3u8/'+Name+'/url.txt', 'w') as f:
    f.write(m3u8)
print('Geting m3u8...')
part = down(m3u8, 'index.m3u8').split('\n')
vpart = []
for i in range(len(part)):
    x = part[i]
    if '#EXT-X-KEY' in x:
        print('m3u8 is encrypted!')
        encrypted = True
        encStr = x
        encUrl = re.sub(r'^.*URI="?([^"]+)".*$', r'\1', x, flags=re.I)
        encMethod = re.sub(r'^.*METHOD=([^,]+),?.*$', r'\1', x, flags=re.I)
        encIV = re.sub(r'^.*IV=(.*)$', r'\1', x, flags=re.I)
        print(encIV)
        if ('#' in encIV):
            encIV = b'0000000000000000'
        else:
            encIV = encIV[2:18]
    elif not '#' in x:
        vpart.append(x)
if (encrypted):
    print('Geting key...')
    if not 'http' in encUrl:encUrl=path+encUrl
    key = requests.get(encUrl)
    KEY = True
    if key.status_code != 200 :
        print('Key not available! Status code',key.status_code)
        if (input('Ignore? y/other')=='y'):
            KEY = False
        else:
            exit()
    else:
        key = key.content
        open("./m3u8/"+Name+'/key.key', 'w').close()
        with open("./m3u8/"+Name+'/key.key', 'rb+') as f:
            f.write(key)
        print('Method =', encMethod, ', Key =', key, ', IV =', encIV)
        aes = AES.new(key=key, IV=encIV, mode=AES.MODE_CBC)
l=len(vpart)
print('total ts file',l)
while 1:
    start=tonum(input('start= '))
    end=tonum(input('end  = '))
    if not (start and end):
        print('Invalid')
    elif start<1 or start>l or end<start or end>l:
        print('Range is from 1 to ',l)
    else:
        break
n = 0
if end == 0:
    end = l
elif end > l:
    print('Out of range!')
    exit()
l = len(vpart)
sl = len(str(l))
index = open("./m3u8/"+Name+'/index.txt', 'w')
with tqdm(total=end-start+1, desc='Downloading', unit=' 个') as pbar:
    with ThreadPoolExecutor() as p:
        futures = []
        for i in range(start-1, end):
            line = vpart[i]
            vname = str(f'%(v)0{sl}d' % {'v': i+1})
            if(len(line)<4):
                continue
            elif (line[0:4] == 'http'):
                url = line
            else:
                if line[0] == '/':
                    line = line[1:]
                url = path+line
            futures.append(p.submit(down, url, vname+'.ts'))
""" with tqdm(total=end-start+1, desc='Downloading', unit=' 个') as pbar:
    for i in range(start-1, end):
        line = vpart[i]
        vname = str(f'%(v)0{sl}d' % {'v': i+1})
        if(len(line)<4):
            continue
        elif (line[0:4] == 'http'):
            url = line
        else:
            if line[0] == '/':
                line = line[1:]
            url = path+line
        th = threading.Thread(target=down, args = (url,vname+'.ts'))
        th.start()
        th.join() """
done.sort()
txt=''
for i in done:
    txt+=f'file \'{cwd}\\m3u8\\{Name}\\{i}\'\n'
index.write(txt)
index.close()
cmd = f'ffmpeg -loglevel warning -f concat -safe 0 -i "{cwd}\\m3u8\\{Name}\\index.txt" -c copy "{cwd}\\m3u8\\{Name}.mp4"'
print(cmd)
os.system(cmd)
os.system('pause')