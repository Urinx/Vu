#!/usr/bin/env python
# coding: utf-8

import urllib,re
from json import *

def vu(url):
	html=urllib.urlopen(url).read().replace('\n','').replace('\r','').replace('\t','').replace('&#8211;','-').replace('&amp;','&')
	reg1=r'<a href="([^"]*?)" target="_blank" title="([^"]*?)"><img class="thumbnail" src="([^"]*?)" />'
	reg2=r'<div class="post_views">\s*?([^\s]*?)\s*?</div>'
	reg3=r'<div class="post_comments">\s*?<a href="[^"]*?" title="[^"]*?">(\d*?)</a>'
	reg4=r'([\d,]*?)\s*?</li>'
	reg5=r'<img src="([^"]*?)"/></a></div><div class="hottitle"><a href="([^"]*?)"\s*?title="([^"]*?)">'
	reg6=r'<div class="post_premetadata">([^\s]*?) /'
	res1=re.findall(reg1,html)
	res2=re.findall(reg2,html)
	res3=re.findall(reg3,html)
	res4=[i.replace(',','') for i in re.findall(reg4,html) if i]
	res5=re.findall(reg5,html)
	res6=re.findall(reg6,html)

	data={
		'new':[],
		'hot':[],
		'event':[],
		'recommen':[],
	}
	n1=len(res3)
	n2=7
	n3=5
	n4=5
	for i in range(n1):
		t={}
		t['src']=res1[i][0]
		t['title']=res1[i][1].decode('utf-8')
		t['thumbnail']=res1[i][2]
		t['views']=res2[i].replace(',','')
		t['comments']=res3[i]
		t['time']=res6[i]
		data['new'].append(t)

	for i in range(n2):
		t={}
		t['src']=res1[n1+i][0]
		t['title']=res1[n1+i][1].decode('utf-8')
		t['thumbnail']=res1[n1+i][2]
		t['views']=res4[i]
		t['comments']=' - '
		data['event'].append(t)

	for i in range(n3):
		t={}
		t['src']=res5[i][1]
		t['title']=res5[i][2].decode('utf-8')
		t['thumbnail']=res5[i][0]
		t['views']=res4[n2+i]
		t['comments']=' - '
		data['hot'].append(t)

	for i in range(n4):
		t={}
		t['src']=res1[n1+n2+i][0]
		t['title']=res1[n1+n2+i][1].decode('utf-8')
		t['thumbnail']=res1[n1+n2+i][2]
		t['views']=res4[n2+n3+i]
		t['comments']=' - '
		data['recommen'].append(t)

	return JSONEncoder().encode(data)


def sid(url):
	data2={
		'sid': '',
		'src': '',
		'title': '',
		'pubTime': '',
		'category': '',
		'tag': [],
		'view': '',
		'comment': [],
		'related': [],
	}

	html=urllib.urlopen(url).read().replace('\n','').replace('\r','').replace('\t','').replace('&#8211;','-').replace('&amp;','&')
	reg1=r'rel="bookmark" title="([^"]*?)"'
	reg2=r'<iframe height=519 width=850 src="http://player.youku.com/embed/([^"]*?)" frameborder=0 allowfullscreen></iframe>'
	reg3=r'\xe5\x8f\x91\xe5\xb8\x83\xe6\x97\xb6\xe9\x97\xb4\xef\xbc\x9a([^<]*?)<br\/>'
	reg4=r'rel="category tag">(.*?)<\/a>'
	reg5=r'rel="tag">(.*?)<\/a>'
	reg6=r'font-size:20px;">(.*?) </span>'
	reg7=r'<div class="comment-content"><p>(.*?)<\/p>'
	reg8=r'<span class="fn">(.*?)<\/span>'
	reg9=r'<time pubdate datetime=".*?">(.*?)</time>'
	res1=re.findall(reg1,html)
	res2=re.findall(reg2,html)
	res3=re.findall(reg3,html)
	res4=re.findall(reg4,html)
	res5=re.findall(reg5,html)
	res6=re.findall(reg6,html)
	res7=re.findall(reg7,html)
	res8=re.findall(reg8,html)
	res9=re.findall(reg9,html)
	
	data2['title']=res1[0].decode('utf-8')
	data2['sid']=res2[0]
	data2['src']='http://player.youku.com/embed/'+res2[0]
	data2['pubTime']=res3[0].decode('utf-8')
	data2['category']=res4[0].decode('utf-8')
	data2['tag']=res5
	data2['view']=res6[0].replace(',','')
	for i in range(len(res7)):
		c={}
		c['name'] = re.sub('(<[^>]*?>)','',res8[i]).decode('utf-8')
		c['said'] = re.sub('(<[^>]*?>)','',res7[i]).decode('utf-8')
		c['time'] = re.sub('(<[^>]*?>)','',res9[i]).decode('utf-8')
		data2['comment'].append(c)
	return JSONEncoder().encode(data2)

def vu_search(key):
	url='http://www.vhiphop.com/?s='+key+'&x=0&y=0'
	return vu(url)

def vu_page(path,n):
	url='http://www.vhiphop.com/'+path+'/page/'+n
	return vu(url)

#vu_page('','1')