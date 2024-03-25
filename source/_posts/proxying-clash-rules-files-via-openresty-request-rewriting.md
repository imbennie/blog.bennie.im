---
title: 使用Openresty请求重写来代理Clash rules文件 
date: 2024-03-25 14:06:02
tags:
   - Openresty
   - Clash 
categories:
	- Scripts

---

# 背景
[clash-rules](https://github.com/Loyalsoldier/clash-rules) 项目提供了很多clash代理规则集，包含了大多数的场景，省去了我们维护的必要性。

日常使用时，我们只需要在此基础上我们再添加自定义的rule即可。
由于rules是需要通过http请求github的原始文件主机`https://raw.githubusercontent.com`进行下载的，因此如果下载时机器没有设置代理，就会导致网络问题无法链接，实际情况一直提示超时报错。虽然项目也提供了`jsdelivr.net`的cdn代理，但经过测试网络连接依然不够理想。
考虑到我手上有一台海外的VPS，因此可以用来做一层代理，将`rule-providers`的下载的url替换掉，这样即可解决问题。
实际上在此之前已经有了方案V1，python脚本+crontab来定时下载最新的release文件。 
虽然一直以来都工作正常，但总觉不够优雅，于是有了现在的v2方案：基于openresty的`rewrite_by_lua_block`指令重写请求的机制来实现。

<!-- more -->


# V2方案

openresty能够支持lua脚本，内置了一些指令能够重写nginx的请求，相当于是nginx外挂的存在。

以前的工作场景中也用过openresty的外挂lua脚本做过一些业务功能的开发，有过一些基本了解。

再者，在现在这个AI时代，代码都不用自己动手写，直接把需求描述给Coze（字节的机器人，内置GPT-4模型）。

两分钟一个配置实现就得到了：

```java
http {
    server {
        listen 80;
        listen 443 ssl;
        server_name 123.com; # 你的域名

        location ~ ^/clash/rules/(.+) {
            set $proxy_url 'https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/$1';

            rewrite_by_lua_block {
                local http = require "resty.http"
                local httpc = http.new()

                local res, err = httpc:request_uri(ngx.var.proxy_url, {
                    method = ngx.var.request_method,
                    body = ngx.var.request_body,
                    headers = ngx.req.get_headers(),
                    ssl_verify = false
                })

                if not res then
                    ngx.status = 500
                    ngx.say("Failed to request: ", err)
                    return
                end

                ngx.status = res.status
                for k,v in pairs(res.headers) do
                    ngx.header[k] = v
                end
                ngx.say(res.body)
                ngx.exit(res.status)
            }
        }
    }
}
```

这个脚本是用到了openresty的[lua_nginx_module](https://github.com/openresty/lua-nginx-module)模块下的`rewrite_by_lua_block`指令来重写请求。配合nginx的location指令使用正则匹配请求，将路径最后的字符串作为`proxy_url`变量的参数（`$1`用来引用这个变量）。然后发起http请求将代理URL的响应重写原始请求的响应。

这里用到的http库是`lua-resty-http`，由于openresty默认未安装，因此需要手动安装：

```bash
opm get ledgetech/lua-resty-http
```

或者使用luarocks，Lua的包管理器：

```bash
luarocks install lua-resty-http
```

安装完成后需要重启openresty：

```bash
sudo systemctl restart openresty
```

访问 `https://123.com/clash/rules/google.txt`

**搞定？**并没有！

发现报错：

> Failed to request: no resolver defined to resolve "[raw.githubusercontent.com](http://raw.githubusercontent.com/)"
> 

丢给机器人。回复说是因为在 OpenResty 的配置中没有指定 DNS 解析器，而 Lua 脚本需要这个解析器来解析外部域名。

在 Openresty（基于 nginx）的配置文件中，可以通过在 `http` 块中添加 `resolver` 指令来定义 DNS 解析器。

```bash
http {
    resolver 8.8.8.8 8.8.4.4 valid=300s;  # 添加此行来设置 DNS 解析器
    resolver_timeout 5s;  # 设置 DNS 解析器的超时时间

    server {
        # ... 其他配置 ...
    }
}
```

再次reload下配置：

```bash
sudo systemctl reload openresty
```

再次访问`https://123.com/clash/rules/google.txt`测试。

这时候发现能够正常响应了，但是得到了github的一些错误信息，猜测是没有添加官方的请求头。

于是修改lua的http请求头，设置来UA和Referer、host这些关键字段，使其符合实际情况。

```bash
local headers = ngx.req.get_headers()
headers["Referer"] = "https://github.com/Loyalsoldier/clash-rules"
headers["Host"] = "raw.githubusercontent.com"
headers["host"] = "raw.githubusercontent.com"
headers["Cache-Control"] = "no-cache"
headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
headers["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15; rv:124.0) Gecko/20100101 Firefox/124.0"

local res, err = httpc:request_uri(ngx.var.proxy_url, {
	  method = ngx.var.request_method,
	  body = ngx.var.request_body,
    headers = headers,
    ssl_verify = false
})
```

可以看到这里配置了`Host`和`host` ，这是做了覆盖，不然lua的请求头是读取的原始请求的值。

`Host`应该并不需要的，但是`host`一定需要覆写。这点我没有做进一步测试。

设置后可以打印出来看下，为了方便也打印代理URL

```bash
# 打印URL
ngx.log(ngx.ERR, "Proxy URL: ", ngx.var.proxy_url)

# 打印Header
if headers then
	for key, value in pairs(headers) do
	ngx.log(ngx.ERR, "Header: ", key, " Value: ", value)
	end
end
```

继续reload 配置，然后tail打印下，请求时就可以看到日志了。

```bash
tail -f /usr/local/openresty/nginx/logs/error.log
```

此时再次访问测试，此时能够正常显示内容了。

至此，搞定，回到clash中替换到对应的url即可。

完整配置如下（测试通过后日志部分的代码可以去掉）。

```bash
location ~ ^/clash/rules/(.+) {
    set $proxy_url 'https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/$1';
    # set $proxy_url 'https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/$1';
    rewrite_by_lua_block {
        local http = require "resty.http"
        local httpc = http.new()

				local headers = ngx.req.get_headers()
				headers["Referer"] = "https://github.com/Loyalsoldier/clash-rules"
				headers["Host"] = "raw.githubusercontent.com"
				headers["host"] = "raw.githubusercontent.com"
				headers["Cache-Control"] = "no-cache"
				headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
	  		headers["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15; rv:124.0) Gecko/20100101 Firefox/124.0"

				# 打印URL
				ngx.log(ngx.ERR, "Proxy URL: ", ngx.var.proxy_url)
	
				# 打印Header
				if headers then
					for key, value in pairs(headers) do
					ngx.log(ngx.ERR, "Header: ", key, " Value: ", value)
					end
				end
	
	      local res, err = httpc:request_uri(ngx.var.proxy_url, {
	          method = ngx.var.request_method,
	          body = ngx.var.request_body,
	          headers = headers,
	          ssl_verify = false
	      })

	      if not res then
	          ngx.status = 500
	          ngx.say("Failed to request: ", err)
	          return
	      end
	
	      ngx.status = res.status
	      for k,v in pairs(res.headers) do
	          ngx.header[k] = v
	      end

	      ngx.say(res.body)
			  ngx.exit(res.status)
    }
}
```

# V1方案

v1方案比较简单粗暴，使用python来下载最新release下的所有文件到nginx的html目录下进行托管。

再配合crontab定时触发就行了。

```python
import requests
import os

def get_latest_release_info(user, repo):
    url = f"https://api.github.com/repos/{user}/{repo}/releases/latest"
    response = requests.get(url)
    if response.status_code == 200:
        release_data = response.json()
        return release_data["published_at"], [(asset["name"], asset["browser_download_url"]) for asset in release_data.get("assets", [])]
    else:
        return None, None

def download_file(url, local_filename):
    """当然，我会针对您提到的 download_file 函数中的每个部分进行详细解释：
    requests.get(url, stream=True) 中的 stream=True:
        在使用 requests 库向一个 URL 发起 GET 请求时，stream=True 参数告诉 requests 使用流式传输。这意味着当你下载大文件时，requests 不会立即下载整个文件。相反，它会保持连接打开，允许你按需下载文件的部分内容。这种方式对于处理大文件或需要较长时间下载的内容非常有效，因为它可以避免一次性加载整个文件到内存中。

    r.raise_for_status():
        当执行一个网络请求（如 requests.get）后，r.raise_for_status() 会检查响应的状态码。如果状态码指示有一个错误（例如，4xx客户端错误或5xx服务器错误），raise_for_status() 会抛出一个 HTTPError 异常。这是一种快速检查请求是否成功的方法，并且在出错时立即报告问题，而不是在后续的代码中处理错误响应。

    open(local_filename, 'wb') 中的 'wb':
        这行代码是在以“写入”模式打开一个文件，准备向其中写入数据。'wb' 模式是指“写入二进制”模式。
        'w' 代表写入模式，与读取模式 ('r') 相反。
        'b' 指的是二进制模式，这对于非文本文件（如图片、音频、视频等）来说是必需的。在二进制模式下，数据被写入文件时不会进行任何转换。这对于下载的文件（可能是图像、压缩文件等）来说是重要的，因为它们必须按原样保存。

    for chunk in r.iter_content(chunk_size=8192):
        r.iter_content(chunk_size=8192) 是一种高效处理响应内容的方式。这个方法逐块（每块大小由 chunk_size 指定）迭代返回文件内容，而不是一次性将整个文件加载到内存。
        chunk_size=8192 表示每次迭代将处理 8192 字节（8KB）的数据。这是一个缓冲区大小的选择，可根据需要调整。
        for chunk in r.iter_content(chunk_size=8192) 通过遍历所有块，使你能够以可管理的块大小处理文件内容。在每次迭代中，chunk 包含文件的一小部分内容，然后通过 f.write(chunk) 写入到本地文件中。这种逐块写入的方式使得函数能够下载大文件，同时保持内存使用的低效率。
    """
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(local_filename, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192): 
                f.write(chunk)
    return local_filename

def download_release_assets(user, repo, download_path, timestamp_file):
    latest_release_time, assets = get_latest_release_info(user, repo)

    if latest_release_time and assets:
        print("新发布时间：", latest_release_time)
        # 读取上次发布时间
        if os.path.exists(timestamp_file):
            with open(timestamp_file, 'r') as f:
                last_release_time = f.read().strip()
        else:
            last_release_time = ''

        # 如果有新的发布，则下载文件
        if latest_release_time != last_release_time:
            print("检测到新的 Release，开始下载...")
            if not os.path.exists(download_path):
                os.makedirs(download_path)
            for name, url in assets:
                if not str.endswith(name, '.txt'): continue
                local_filename = os.path.join(download_path, name)
                print(f"正在下载 {name}...")
                download_file(url, local_filename)
            print("所有文件下载完成。")

            # 更新发布时间
            with open(timestamp_file, 'w') as f:
                f.write(latest_release_time)
        else:
            print("当前 Release 与上次检查的相同，无需下载。")
    else:
        print("无法获取最新 Release 信息或无文件可下载。")

# 示例使用
user = "Loyalsoldier"  # 更换为你关注的仓库的用户名
repo = "clash-rules"  # 更换为你关注的仓库名
base_path = "/usr/local/openresty/nginx/html/clash/"
download_path = os.path.join(base_path, "rules")  # 设置下载文件的本地存储路径
timestamp_file = os.path.join(download_path, "release_time.txt") # 存储上次发布时间的文件路径
download_release_assets(user, repo, download_path, timestamp_file)
```

代码同样基于ChatGPT。

添加crontab：

```python
# download clash rules everyday 01:00
0 1 * * * /usr/bin/python3 /opt/utility-scripts/download_clash_rules.py
```

# 对比

V2方案的url在访问时可能会产生：`Failed to request: network is unreachable` 报错，这会使得clash无法下载文件，原因可能是github官方服务的请求造成。但就实际情况来说并不影响使用。

V1方案简单粗暴，一切都好，但需要下载文件。按照哲学家奥卡姆的话来说“如无必要，勿增实体”。实际上我连一个字节都不想浪费。
