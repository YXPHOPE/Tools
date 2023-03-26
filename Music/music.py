# 利用果核音乐的接口做的一个简易下载音乐程序
# 0是直接退出(一路return 0)，不输是返回上一步(return -1)
from requests import post,get
from json import loads as json_loads
import traceback
import configparser
from sys import executable
# 在cmd上显示色彩有两种方法
# 1. 引入colorama使用autoreset
# from colorama import init
# init(autoreset=True)
# 2. 清屏
from os import system as os_system
os_system("cls")


def_conf = {
    'password':'ghyynb',
    'savePath':'D:\\Media\\Music\\Music\\',
    'url': 'https://music.ghxi.com/wp-admin/admin-ajax.php',
    'cookie': 'PHPSESSID=nigrbvt6pdlpbelr404ngvti30',
}
config_path = executable
config = configparser.ConfigParser()
Header = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:82.0) Gecko/20100101 Firefox/82.0',
    'Accept-Encoding': 'gzip, deflate, br',
    'Cookie': 'PHPSESSID=nigrbvt6pdlpbelr404ngvti30', # 主要受这个cookie和下面的CORS政策影响
    'Referer': 'https://music.ghxi.com/',
    'Origin': 'https://music.ghxi.com',
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'X-Requested-With': 'XMLHttpRequest'
}
Size = { 'size128':'128', 'size320':'320', 'sizeflac':'flac'}
Style = {
'':'0', # 默认
' ':'0',
'h':'1', # 高亮
'u':'4', # 下划线
't':'5', # 闪烁
'v':'7', # 反显verse
'n':'8', # 不可见none
'b':'30', # 黑色前景
'r':'31', # 红色前景
'g':'32', # 绿色前景
'y':'33', # 黄色前景
'l':'34', # 蓝色前景(拼音l)
'm':'35', # 紫色前景magenta
'c':'36', # 青色前景cyan
'w':'37', # 白色前景
'bb':'40', # 黑色背景
'br':'41', # 红色背景
'bg':'42', # 绿色背景
'by':'43', # 黄色背景
'bl':'44', # 蓝色背景
'bm':'45', # 紫色背景
'bc':'46', # 青色背景
'bw':'47', # 白色背景
}
def parse_style(style):
    res = ''
    sty = style.split(';')
    for i in range(len(sty)):
        if sty[i] in Style:
            res += Style[sty[i]]+';'
    if res: return res[:-1]
    else: return '0'

def prtfmt(str,style='',prt=True,end = '\n'):
    # <[style]text>    style:h;r;bg   python中的C格式码:  \033[效果;前景色;背景色m文本\033[0m    \033为ESC控制符，各效果和颜色由数字指代
    p = j = k = 0
    i = str.find('<[')
    res = ''
    if i== -1:
        if style:
            res = '\033['+parse_style(style)+'m'+str+'\033[0m'
        else: res = str
    while i!= -1:
        j = str.find(']',i)
        if j==-1: j=i+7
        k = str.find('>',j)
        if k==-1: k = len(str) # 没有关闭符>直接到最后
        #      前文本             style                           格式化文本
        res += str[p:i] + '\033[' + parse_style(str[i+2:j]) + 'm' + str[j+1:k] + '\033[0m'
        i = str.find('<[',k)
        p = k+1
    if p: res += str[p:]
    if prt: print(res,end = end)
    return res

def prterr(e):
    prtfmt("Error: "+str(e), 'h;r')
    errstr = traceback.format_exc()
    errstr = errstr.replace(', line ',', <[h;y]line ')
    errstr = errstr.replace(', in ','>, in ')
    prtfmt(errstr)
# 检查cookie的有效性
def check_cookie():
    isauth = post(Url, data={
        "action": "gh_music_ajax",
        "type": "isauth"
    }, headers=Header)
    if isauth.ok & (isauth.text == '{"code":200}'):
        prtfmt('Authorized','c')
    else:
        # 无效,重设cookie
        prtfmt('UnAuthorized','c')
        try:
            cookie = isauth.headers['set-cookie'][0:-8]
            print('cookie=',cookie)
            Header['Cookie'] = cookie
            config.set('config', 'cookie', cookie)
            config.write(open(config_path, 'w',encoding='utf-8'))
        except: pass # 出错只能是原来的cookie正确，只是要重新输密码认证，所以服务器没有返回新的set-cookie
        # POST密码获得验证
        auth = post(Url, data={
            "action": "gh_music_ajax",
            "type": "postAuth",
            "code": Password
        }, headers=Header)
        if (auth.ok and auth.text.find('{"code":200') >= 0):
            prtfmt('Success','c')
            return 1
        else:
            print(json_loads(auth.text))
            prtfmt('Check the password?','r')
            return 0

def toNum(s):
    if s == '': return -1
    elif s == '0': return 0
    n = '0123456789'
    r = ''
    for i in s:
        if n.find(i) >= 0: r += i
        elif r != '': break
    if r: return int(r)
    else: return -1

def get_song(song, T, size):
    dat = {
        "action": "gh_music_ajax",
        "type": "getMusicUrl",
        "music_type": T,
        "music_size": size,
        "songid": song['songid']
    }
    prtfmt("Getting music url...",'g')
    geturl = post(Url, data=dat, headers=Header)
    print('\033[1A'+' '*20+'\033[20D',end='')
    if geturl.ok:
        songurl = json_loads(geturl.text)['url']
        print(songurl)
        prtfmt('Downloading...','g')
        download = get(songurl)
        print('\033[1A'+' '*14+'\033[14D',end='')
        if download.ok:
            e = '.mp3'
            if size == 'flac': e = '.flac'
            name = Path+song['singer']+' - '+song['songname']+e
            with open(name, 'wb') as f:
                f.write(download.content)
                prtfmt('Saved to %s' % name,';g')
            return 1
        else:
            prtfmt('failed to download song','r')
            return -1
    else:
        prtfmt('failed to get songurl','r')
        return -1


def search_song(name, T):
    data = {
        "action": "gh_music_ajax",
        "type": "search",
        "music_type": T,
        "search_word": name
    }
    prtfmt('Searching...','g')
    res = post(Url, data=data, headers=Header)
    print('\033[1A            \033[12D',end='')
    if not res.ok:
        prtfmt('Search failed: %s' % res.status_code,'r')
        return -1
    res = json_loads(res.text)
    if res['code'] != 200:
        prtfmt('Search failed','r')
        return -1
    list = []
    try:
        list = res['data']
    except Exception as e:
        prterr(e)
        print(res)
        return -1
    prtfmt('Num. Singer\t\tSong\t\t\tAlbum\n','c')
    cur = 1
    bg = ''
    while True:
        if cur==1:n='n'
        else:
            prtfmt('Select a song: ','c',end='')
            n=input()
        if n == 'n':
            if cur>=len(list):
                prtfmt('No more results','r')
                continue
            print('\033[1A'+' '*40+'\033[40D',end='')
            for i in list[cur-1:cur+9]:
                if cur % 2:bg = '\033[37m'
                else : bg = '\033[35m'
                print(bg+'%-5d%-8s\t%-14s\t%s\033[0m' %
                  (cur, i['singer'], i['songname'], i['albumname']))
                cur += 1
            continue
        else: n = toNum(n)
        if n <= 0:
            return n
        elif n > 0 & n <= len(list):
            song = list[n-1]
            print('%d\t%s\t%s\t%s' %
                  (n, song['singer'], song['songname'], song['albumname']))
            a = []
            for i in Size:
                if song[i]: a.append(Size[i])
            for o in range(len(a)):
                print('%d: %s' % (o+1, a[o]), end='\t')
            prtfmt('\nSelect a size: ','c',end='')
            o = toNum(input())
            if o == -1:continue
            elif o==0:return 0
            elif (o > 0 & o <= len(a)):
                get_song(song, T, a[o-1])


def main():
    prtfmt('Welcome to Music.ghxi.com','h;y')
    prtfmt('Checking cookie...','c')
    global Password
    while check_cookie() == 0:
        prtfmt('Input the password: ','c')
        Password = input()
        if Password == '' or Password=='0':
            return 0
    if Password != config.get('config','Password'):
        config.set('config','Password',Password)
        config.write(open(config_path,'w',encoding='utf-8'))
    while True:
        prtfmt("<[;c]Search by:>\n1.QQ(default) \n2.NetEase\n<[;c]Choose a num: >",end='')
        TYPE = input()
        if TYPE == '' or TYPE == '0': return 0
        elif TYPE != '2': TYPE = 'qq'
        else: TYPE = 'wy'
        while True:
            prtfmt('Search: ','c',end='')
            word = input()
            if word == '0': return 0
            elif word == '': break
            try:
                s = search_song(word, TYPE)
                if s == -1: continue
                elif s == 0: return 0
            except Exception as e:
                prterr(e)

if __name__ == '__main__':
    # 配置文件
    config_path = config_path[:config_path.rfind('\\')+1]
    config_path+='GhMusic.ini'
    config.read(config_path)
    if not config.has_section('config'):
        config.add_section('config')
    for key in def_conf:
        if not config.has_option('config',key):
            config.set('config',key,def_conf[key])
    config.write(open(config_path,'w',encoding='utf-8'))
    Password = config.get('config','password')
    Path = config.get('config','savePath')
    Url = config.get('config','url')
    Header['Cookie'] = config.get('config','cookie')
    try:
        if main()==0: prtfmt('Exit','h;c')
    except Exception as e:
        prtfmt("Error:",'r')
        print(e)
        prtfmt('Exit','m')

