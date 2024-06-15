---
title:  网易云音乐二维码扫码登录过程解析
date: 2021-12-14 23:06:16
tags:
    - NetEase Music
categories:
    - Notes
---


之前写网易云登录过程时用的账号+密码方式，最近兴起又找了个时间研究二维码的登录过程，这里记录下过程。

<!-- more -->

## 一、请求生成二维码的unikey参数

```shell
curl 'https://music.163.com/weapi/login/qrcode/unikey?csrf_token=' \
  -H 'authority: music.163.com' \
  -H 'sec-ch-ua: " Not;A Brand";v="99", "Google Chrome";v="97", "Chromium";v="97"' \
  -H 'dnt: 1' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'content-type: application/x-www-form-urlencoded' \
  -H 'accept: */*' \
  -H 'origin: https://music.163.com' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-dest: empty' \
  -H 'referer: https://music.163.com/' \
  -H 'accept-language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7,en-GB;q=0.6' \
  --data-raw 'params=T23YDKo3vZeDF08%2B9qzHkHSiTJBoh4EMEXEXsgKznUc%3D&encSecKey=a86543e1747eee2ed23eda4c72109d69d71d10ea2e34298fb5da654697fdd411673e6783eba86bc2f3e9c11b24d9d50b0cc6347056049f79b230302b440fe10c76e082a475a83530f56fe90514dbdd169f572d75d65a73b0fb8a6233f6e484c066b359640529112299876a666576fd2d12b0d938cbc39c74f70d8578de3c608c' \
  --compressed

```

请求参数`params`、`encSecKey`需要经过加密计算得到，生成过程可参考下面的文章：

- [网易云音乐资源爬取（登录+评论）](https://www.jianshu.com/p/07ebbb142c73)
- [网易云音乐 web 加密参数分析](https://imwtx.com/archives/179/)
- [【2021-07-15】JS逆向之网易云音乐登入--最新](https://blog.csdn.net/qq_26079939/article/details/115404275)
- [Java实现：网易云音乐资源爬取（登录+评论）](https://www.jianshu.com/p/07ebbb142c73)



根据上面的文章可以了解到网易云以json形式提供接口的正常参数，对该json作加密得到的params参数。这里，获得unikey的接口请求参数只需要提供下面的json体作为参数进行加密计算。

```json
{
    "type": "1"
}
```





加密计算得到`params`、`encSecKey`后，该接口在发送请求前还需要对参数`params`进行urlEncode编码，否则提交请求后无法得到响应内容。即：

```java
String params = "T23YDKo3vZeDF08+9qzHkHSiTJBoh4EMEXEXsgKznUc=";
String encodedParams = java.net.URLEncoder.encode(params, "utf-8");

// 得到：`T23YDKo3vZeDF08%2B9qzHkHSiTJBoh4EMEXEXsgKznUc%3D`
```



发送请求后响应结果如下:

```
RESP：
HTTP/2 200 OK
server: nginx
date: Tue, 14 Dec 2021 12:33:43 GMT
content-type: application/json;charset=UTF-8
content-length: 86
mconfig-bucket: 999999
x-traceid: 0000017db8ef3348120f0aaba5091b19
set-cookie: NMTID=00OvVGYx2nayOb900GKiprHmv6QWogAAAF9uO8zTQ; Max-Age=315360000; Expires=Fri, 12 Dec 2031 12:33:43 GMT; Path=/; Domain=music.163.com
cache-control: no-cache, no-store
expires: Thu, 01 Jan 1970 00:00:00 GMT
gw-thread: 861939
gw-time: 1639485223753
content-encoding: gzip
x-via: MusicServer
x-from-src: 114.249.199.224
X-Firefox-Spdy: h2


{"code":200,"unikey":"aca65293-5459-40ed-899d-7c597a613d52"}
```



## 二、使用unikey参数拼接文本并生成二维码

将上面响应得到的`unikey`属性值拼接到`http://music.163.com/login?codekey=`之后，得到：`http://music.163.com/login?codekey=aca65293-5459-40ed-899d-7c597a613d52`

然后可以用在线工具将其生成二维码，戳：https://cli.im/text
或者，前端做开发用可以引入`qrcodejs`库文件生成二维码。

- qrcode.js：https://github.com/davidshimjs/qrcodejs
- 示例：http://code.ciaoca.com/javascript/qrcode/

**成品：**

```html
<!DOCTYPE html>
<html>
<head>
	<title></title>
</head>
<body>

	<script src="https://cdn.jsdelivr.net/gh/davidshimjs/qrcodejs@master/qrcode.min.js" type="text/javascript"></script>

	<div id="qrcode"></div>
<script type="text/javascript">
var qrcode = new QRCode(document.getElementById("qrcode"), {
	text: "http://music.163.com/login?codekey=ac3aebd0-65c1-4cae-8a6f-869dc91c4ca8",
	width: 128,
	height: 128,
	colorDark : "#000000",
	colorLight : "#ffffff",
	correctLevel : QRCode.CorrectLevel.H
});
</script>

</body>
</html>
```



## 三、扫描二维码，在程序中定时发送请求监听接口响应。




```shell
curl 'https://music.163.com/weapi/login/qrcode/client/login?csrf_token=' -X POST -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:95.0) Gecko/20100101 Firefox/95.0' -H 'Accept: */*' -H 'Accept-Language: zh-CN,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: https://music.163.com' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Referer: https://music.163.com/' -H 'Cookie: JSESSIONID-WYYY=nTMmRIoCA2Jc2di7BekaMqJURs5QDBjR%2BqB3oylo5RVfhFZj%2ByCIgCDCYcXCUK5P%2BqdA0sCC2P6Jlu1nd2sVsiTI6yUoiUzOln4tccCsvEO%2Fyu64wpEg8lMpFG36Df0t3F4QidNji61Hf%5Cb4ytKU4rVP7abY7aNjVGijbhY0FZ1pV%5Cn%2F%3A1639486553309; _iuqxldmzr_=32; _ntes_nnid=45012cca304d2b0405504aa0e3d59608,1637477815806; _ntes_nuid=45012cca304d2b0405504aa0e3d59608; NMTID=00OaZEG2hgdKpIzSEKUjsOrj_uxGbsAAAF9QUicBQ; WEVNSM=1.0.0; WNMCID=jckbry.1637477818458.01.0; WM_NI=1sNokZHm%2BXycMu%2BBQGyrfN22O%2FcEas%2FSx026e6Yyqoj%2BWShZgukne1u6%2Bd5FhlQhbBNvz%2B%2Bhuo9Swigq%2FEc%2FjzTj3mtBqoGF4ZrhMM9RD8%2FsR7JpO9O4xS7lvRO6bRzuZlE%3D; WM_NIKE=9ca17ae2e6ffcda170e2e6eed7bb5e8cbb9a82c133f1e78fb6c84f928a8eaef565b1af8a93cc4b859100daf12af0fea7c3b92af3ad8290ea528cb3e5b9fc698fabe5a3d44dbbaeaaafb13a8df1ada6e479ed8db8d1b13ea7ea979af465aaf599b4eb52a5aba58fe83bb7eae585b84eacb49f89e14a8eaab6ccaa64b7b1f7b4f663a5afe1a6e225aaa69c8bb267b89ebf90c64ef886be89d047fb8e8cd9ae7992e98691ce338decb8b4b668b68e81d7e15abaab968dc837e2a3; WM_TID=%2BOLLkHyHl35FRVQRUQJu5nEGMdTeTGDa; hb_MA-BE1B-B326EA1BA2C0_source=ym.163.com; ntes_kaola_ad=1' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-origin' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: trailers' --data-raw 'params=T23YDKo3vZeDF08+9qzHkHSiTJBoh4EMEXEXsgKznUc=&encSecKey=a86543e1747eee2ed23eda4c72109d69d71d10ea2e34298fb5da654697fdd411673e6783eba86bc2f3e9c11b24d9d50b0cc6347056049f79b230302b440fe10c76e082a475a83530f56fe90514dbdd169f572d75d65a73b0fb8a6233f6e484c066b359640529112299876a666576fd2d12b0d938cbc39c74f70d8578de3c608c'
```

params加密参数，由参数内容加密计算得到：
```
{
  "csrf_token": "",
  "key": "1825b24c-bcc1-486f-8e81-bb27011c7a8a",
  "type": "1"
}
```
key为前面请求得到的unikey。

接口响应的几种情况：

一、过期
```json
{
  "code":800,
  "message":"二维码不存在或已过期"
}
```


二、等待扫码。

```json
{"code":801,"message":"等待扫码"}
```


三、进行中，返回扫码用户信息。

```json
{"nickname":"xxx","avatarUrl":"https://p2.music.126.net/xxxxx==/xxxxxxxx.jpg","code":802,"message":"授权中"}
```


四、完成登录。

```json
{"code":803,"message":"授权登陆成功"}
```

响应头：
```
HTTP/2 200 OK
server: nginx
date: Sat, 29 Jan 2022 05:02:49 GMT
content-type: application/json;charset=UTF-8
content-length: 69
x-traceid: 0000017ea436eb0d08b20aa4683d1289
mconfig-bucket: 999999
set-cookie: MUSIC_A_T=1453993203804; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/wapi/feedback; Domain=.music.163.com; HTTPOnly
MUSIC_R_T=1509816911102; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/weapi/feedback; Domain=.music.163.com; HTTPOnly
MUSIC_A_T=1453993203804; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/weapi/feedback; Domain=.music.163.com; HTTPOnly
MUSIC_SNS=; Max-Age=0; Expires=Sat, 29 Jan 2022 05:02:49 GMT; Path=/
MUSIC_A_T=1453993203804; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/neapi/clientlog; Domain=.music.163.com; HTTPOnly
MUSIC_R_T=1509816911102; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/wapi/feedback; Domain=.music.163.com; HTTPOnly
MUSIC_R_T=1509816911102; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/wapi/clientlog; Domain=.music.163.com; HTTPOnly
MUSIC_R_T=1509816911102; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/api/feedback; Domain=.music.163.com; HTTPOnly
MUSIC_R_T=1509816911102; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/neapi/feedback; Domain=.music.163.com; HTTPOnly
MUSIC_R_T=1509816911102; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/openapi/clientlog; Domain=.music.163.com; HTTPOnly
MUSIC_A_T=1453993203804; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/api/clientlog; Domain=.music.163.com; HTTPOnly
MUSIC_A_T=1453993203804; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/weapi/clientlog; Domain=.music.163.com; HTTPOnly
MUSIC_R_T=1509816911102; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/eapi/clientlog; Domain=.music.163.com; HTTPOnly
MUSIC_R_T=1509816911102; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/neapi/clientlog; Domain=.music.163.com; HTTPOnly
MUSIC_R_T=1509816911102; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/eapi/feedback; Domain=.music.163.com; HTTPOnly
MUSIC_R_T=1509816911102; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/api/clientlog; Domain=.music.163.com; HTTPOnly
MUSIC_A_T=1453993203804; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/api/feedback; Domain=.music.163.com; HTTPOnly
__csrf=0df88dc1e8c79da3cf22bc2f7dfc6858; Max-Age=1296010; Expires=Sun, 13 Feb 2022 05:02:59 GMT; Path=/; Domain=.music.163.com
MUSIC_U=06d5ac0e4fab058e396543df5a323517c32d9eecd799a0f1e32fc59568244c038a08bd5bf851808fd78b6050a17a35e705925a4e6992f61dfe3f0151024f9e31; Max-Age=15552000; Expires=Thu, 28 Jul 2022 05:02:49 GMT; Path=/; Domain=.music.163.com; HTTPOnly
MUSIC_R_T=1509816911102; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/weapi/clientlog; Domain=.music.163.com; HTTPOnly
MUSIC_A_T=1453993203804; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/eapi/feedback; Domain=.music.163.com; HTTPOnly
MUSIC_A_T=1453993203804; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/neapi/feedback; Domain=.music.163.com; HTTPOnly
MUSIC_A_T=1453993203804; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/eapi/clientlog; Domain=.music.163.com; HTTPOnly
MUSIC_A_T=1453993203804; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/openapi/clientlog; Domain=.music.163.com; HTTPOnly
MUSIC_A_T=1453993203804; Max-Age=2147483647; Expires=Thu, 16 Feb 2090 08:16:56 GMT; Path=/wapi/clientlog; Domain=.music.163.com; HTTPOnly
cache-control: no-cache, no-store
expires: Thu, 01 Jan 1970 00:00:00 GMT
gw-thread: 756664
gw-time: 1643432569622
content-encoding: gzip
x-via: MusicServer
x-from-src: 1.202.220.130
X-Firefox-Spdy: h2
```


~~BTW: 自己写的一个小程序（Just for fun）：https://github.com/imbennie/netease-music-tools~~
目前闭源。
