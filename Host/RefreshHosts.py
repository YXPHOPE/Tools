import requests
url = 'https://raw.hellogithub.com/hosts'
def main():
    hosts = requests.get(url)
    if hosts.status_code == 200:
        newhosts = hosts.text
        old = ''
        with open('C:\Windows\System32\drivers\etc\hosts','r') as file:
            old = file.read()
        start = old.find('#Start')+7
        end = old.find('#End')
        if start== -1 or end== -1:
            print('Error: Cannot find #Start or #End')
            return 0
        newhosts = old[:start] + newhosts + old[end:]
        with open('C:\Windows\System32\drivers\etc\hosts','w') as file:
            file.write(newhosts)
            print('Successfully updated hosts file')
    else:print("Error: faile to get %s, code:%d"%(url,hosts.status_code))
if __name__ == '__main__':
    main()
