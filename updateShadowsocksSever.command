#!/usr/bin/python
# coding: utf-8
import requests
from bs4 import BeautifulSoup
from biplist import *
import biplist
import os
import json


def loadHtml(url):
    print '******* load shadowsocks VPN *******\n'
    headers = {}
    headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36'
    # headers['Host'] = 'www.ishadowsocks.me'
    headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    headers['Accept-Language'] = 'zh,zh-CN;q=0.8'
    try:
        res = requests.get(url, headers = headers)
        res.encoding = 'utf-8'
    except Exception as e:
        print 'load html error! reason:%s' % e
    else:
        getInfo(res.text)
    

def getInfo(html):
    soup = BeautifulSoup(html, 'html.parser')
    configDic            = {}
    configDic['current'] = '1'
    profiles             = []
    for p in soup.select('#free .col-sm-4'):
        sever                = {}
        sever['remarks']     = ''
        severInfo            = p.select('h4')
        sever['server']      = severInfo[0].text.split(':')[1]
        sever['server_port'] = severInfo[1].text.split(':')[1]
        sever['password']    = severInfo[2].text.split(':')[1]
        sever['method']      = severInfo[3].text.split(':')[1]
        profiles.append(sever);
    configDic['profiles']   = profiles
    updateShadowsocksSever(configDic)
    

def updateShadowsocksSever(config):
    try:
        file_path = '/Users/mac/Library/Preferences/clowwindy.ShadowsocksX.plist'
        plist = readPlist(file_path);
        print plist
    except InvalidPlistException, e:
        print "Not a Plist or Plist Invalid:",e
    else:
        plist["config"]         = biplist.Data(json.dumps(config, indent=None, separators=(',', ':')))
        serverInfo = config['profiles'][0]
        plist['proxy ip']       = serverInfo['server'];
        plist['proxy port']     = serverInfo['server_port']
        plist['proxy password'] = serverInfo['password']
        try:  
            writePlist(plist, file_path)  
        except (InvalidPlistException, NotBinaryPlistException), e:  
            print "Something bad happened:", e
        else:
            os.system("defaults read " + file_path)
            os.system("killall ShadowsocksX")
            os.system("open -a ShadowsocksX")
            print 'shadowSockX sever update completed!'

loadHtml("http://www.ishadowsocks.me")

