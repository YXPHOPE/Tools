# 哔哩哔哩下载器
version = '1.0.1'
decription = 'bilibiliDownloader'
import requests as req
import os
import sys
import time
def main():
    print('bilibili Downloader  v'+version)
    # 文件名、音频地址、视频地址
    arg = sys.argv
    key = ['-v','-o','-a','-p','-n']
    config = {}
    path = 'D:\\download\\'
    for i in range(1, len(arg)):
        s = arg[i]
        if s in key:
            config[s] = arg[i+1]
    if '-o' in config or '-p' in config:
        s = config['-o'] if '-o' in config else config['-p']
        if '\\' in s:
            path = s[:s.rfind('\\')+1]
            if '-n' not in config:
                config['-n'] = s[s.rfind('\\')+1:]
            if not os.path.exists(path):
                os.makedirs(path)
    if '-v' in config or '-a' in config:
        s = config['-v'] if '-v' in config else config['-a']
        i = s.rfind('/')+1
        if '-n' not in config:config['-n'] = time.strftime("%Y%m%d-%H%M%S", time.localtime())+'-'+s[i:s.find('.',i)]
    else:
        print('参数错误')
        return 0
    header = {
        "Origin": "https://www.bilibili.com",
        'Referer':'https://www.bilibili.com/',
        'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:82.0) Gecko/20100101 Firefox/82.0'
    }
    def download(url, name=None, header=None):
        res = req.get(url, headers=header)
        if res.ok and name != None:
            with open(name, 'wb') as f:
                f.write(res.content)
                print('Downloaded:',name)
        else:print('name:%s, code:%d\nurl:%s'%(name,res.status_code,url))
    # 下载
    name = path+config['-n']
    try:
        if '-a' in config:
            print('audio...')
            download(config['-a'],name=name+'.mp3',header=header)
        if '-v' in config:
            print('video...')
            download(config['-v'],name=name+'.v.mp4',header=header)
        if '-a' in config and '-v' in config:
            s = 'ffmpeg -i "%s" -i "%s" -c:v copy -c:a copy -bsf:a aac_adtstoasc "%s"'%(name+'.mp3',name+'.v.mp4',name+'.mp4'+' -loglevel 8')
            print('Merging...\n'+s)
            os.system(s)
    except Exception as e:
        print("Error: "+str(e))
if __name__ == '__main__':
    main()