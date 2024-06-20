---
title: HTML图片预览及AJAX上传Demo
date: 2017-01-02 20:16:39
tags:
    - Frontend
categories:
	- IT Notes

---


效果：
![](/images/2018-05-29-173832.jpg)

用CSS做了一些界面上的处理，预览是用HTML5中的File和FileRead对象来实现(具体看下文代码注释中描述)，AJAX上传部分主要用到了FormData对象，该对象的作用就是可以让AJAX来异步上传一个二进制文件。
后端的处理代码用到是Servlet中提供的两个框架，分别是: `commons-fileupload-1.3.1.jar`和`commons-io-2.4.jar`，可以在: http://archive.apache.org/dist/commons/ 下载到这2个jar包.

下面的实现代码中，会对CSS，JS，以及后端的Java部分进行说明，相关的HTML5对象会提供详细的文档链接。

最后推荐大家 **Web API 接口一览表: https://developer.mozilla.org/zh-CN/docs/Web/API** 这个地方。
理由是：当使用Javascript编写网页代码时，有很多API可以使用并提供相关的示例代码。



<!-- more -->

前台界面及处理代码

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AJAX图片上传</title>
    <style>

        body {
            color: #333;
        }

        p.title {
            font-size: 30px;
            width: 500px;
            hegith: auto;
            padding-left: 10px;
            border-left: 5px solid dodgerblue;
        }

        div.big，div.middle，div.small {
            display: inline-block;
            margin-right: 10px;
        }

        .big img.avatar {
            width: 200px;
            height: 200px;
        }

        .middle img.avatar {
            width: 100px;
            height: 100px;
        }

        .small img.avatar {
            width: 50px;
            height: 50px;
        }

        .desc {
            color: #999;
        }

        .wrapper {
            position: relative;
        }


        .wrapper input {
            width: 130px;
            height: 38px;
            cursor: pointer;
        }

        .wrapper .portrait-filebtn {
            outline: none;
            border: none;
            padding: 0;
            background: url("https://ss1.bdstatic.com/5KZ1bjqh_Q23odCf/static/princess/img/setportrait_btn_da8845e1.png") no-repeat 0 0px;
        }

        .wrapper .portrait-file {
            opacity: 0;
            position: absolute;
            left: 0;
            top: 0;

        }

        div#info {
            padding: 10px 0;
            font-size: 15px;
        }
    </style>

    <script type="text/Javascript">

        window.onload = function () {
            var fileInput = document.getElementById("fileImg");
            var infoDiv = document.getElementById("info");
            var avatarImgs = document.getElementsByClassName("avatar");
            
            // 为文件选择input绑定一个change事件监听.
            fileInput.addEventListener("change", function (event) {
                /**
                 * 所以这里的this指针是input对象
                 * this.files获取的是WEB_API中的FileList对象。
                 * 参考: https://developer.mozilla.org/zh-CN/docs/Web/API/FileList
                 * */
                var file = this.files[0]; 
                
                // 获取文件的大小且四舍五入后不保留小数。
                var fileSize = (file.size / 1024).toFixed(); 
                
                // 获取文件名
                var fileName = file.name; 
                infoDiv.innerHTML = "<b>Size: </b>" + fileSize + "Kib<br />" + "<b>Name: </b>" + fileName;

                /**
                 * WEB_API FileReader对象，参考: https://developer.mozilla.org/zh-CN/docs/Web/API/FileReader
                 */
                var fileReader = new FileReader(); 
                
                /**
                 * 开始读取指定的File对象中的内容。
                 * 将File对象中的文件内容读入到FileReader对象result属性中。
                 * 关于这个方法的介绍推荐大家阅读: https://developer.mozilla.org/zh-CN/docs/Web/API/FileReader
                 */
                fileReader.readAsDataURL(file);
                
                // 当fileReader载入的时候，我们把读入的数据给下面我们定义的img标签的src属性中。
                fileReader.onload = function (event) {
                    // 我这里循环是因为我弄了3种尺寸的预览图.
                    for (var i = 0; i < avatarImgs.length; i++) {
                        var avatarImg = avatarImgs[i];
                        
                        /**
                         * 上面说了读入的会把File对象的文件内容读到result属性，
                         * 所以这里获取result的值赋给img标签的src属性，就可以实现在上传前图片预览的功能了。
                         *
                         * 这里的result指的是: 读取到File对象中的图片文件内容。
                         * 这个属性中的值的格式就是一个经过base64编码的图片数据URL。
                         * 差不多就是这样的格式，应该都见过的。
                         * data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEBLAEsAAD/7R+KUGhvdG9zaG9wIDMuMAA4QklNBAQAAAAAADwcAVo
                         * 
                         * 了解更多请看: https://developer.mozilla.org/zh-CN/docs/Web/API/FileReader/result
                         */
                        avatarImg.src = this.result;
                        //avatarImg.src = event.target.result;
                    }
                    // ajax发送请求上传文件.
                    ajaxSaveToServer(file);
                }

            }，false);
        };

        // AJAX上传
        function ajaxSaveToServer(imgFile) {

            var xhr = new XMLHttpRequest();
            xhr.open("post", "saveImg"，true);

            /**
             * XMLHttpRequest Level 2添加了一个新的接口FormData。
             * 利用FormData对象，我们可以通过Javascript用一些键值对来模拟一系列表单控件，
             * 我们还可以使用XMLHttpRequest的send()方法来异步的提交这个"表单"。
             * 比起普通的ajax，使用FormData的最大优点就是我们可以异步上传一个二进制文件。
             *
             * 上面的解释很清楚了，更多信息可以参考这里: https://developer.mozilla.org/zh-CN/docs/Web/API/FormData
             */
            var formData = new FormData();

            /**
             * 给当前FormData对象添加一个键/值对。
             */
            formData.append("img"，imgFile);
            
            // 后面的就是发送请求处理响应了。
            xhr.send(formData);
            xhr.onreadystatechange = function () {
                var state = xhr.readyState;
                var status = xhr.status;
                if (state == 4 && status == 200) {
                    alert(xhr.responseText);
                }

            }
        }
    </script>
</head>
<body>

    <p class="title">Choose Image</p>
    
    <div class="wrapper">
        <input type="button" class="portrait-filebtn" value="Choose">
        <input type="file" class="portrait-file" name="file" id="fileImg" accept=".jpg,.png,.gif,.bmp,.jpeg">
        <span class="pass-portrait-msg">Supporting formats: jpg、jpeg、gif、png、bmp</span>
    </div>
    
    <div id="info">
    </div>


    <p class="title">Image Preview</p>

    <div class="preview">

        <div class="big">
            <p class="desc">200x200 Pixel</p>
            <img src="" class="avatar">
        </div>

        <div class="middle">
            <p class="desc">100x100 Pixel</p>
            <img src="" class="avatar">
        </div>

        <div class="small">
            <p class="desc">50x50 Pixel</p>
            <img src="" class="avatar">
        </div>
    </div>

</body>
</html>

```


上面在注释里js和WEB_API的介绍说完了，这里说一下css代码相关的地方。
首先。class为wrapper的div，需要设置position为relative，然后将里面的第二个input，也就是文件选择的input。
它的position设置为absolute，absolute会相关于第一个position为非static的父元素来定位。
所以这里就是相对于刚才那个class为container的div来定位，然后我们让它left和top都为0，让它紧贴着div，然后再给它的透明度设置为0，通过`opacity: 0;`来设置。
这样子做了之后他前面的类型为button的input就会"覆盖"它，说是覆盖其实是因为透明度为0，人的眼睛看不到了。但是在页面上还是存在，所以我们不能设置display为none这个样式。因为我们需要能点击它。

其他的css就是我个人的一些处理，没什么特别的地方。

再然后我们来看服务端java代码，我用的servlet配合2个jar包来实现上传。


```java
package com.xxxx.servlet;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.List;


public class SaveFile extends HttpServlet {

    // 文件上传路径
    private static final String UPLOAD_DIRECTORY = "upload";
    
    // 文件路径分隔符，linux为/，windows为\
    private static final String File_SEPARATOR = File.separator;
    
    // 允许的文件contentype类型.
    private static final String[] ALLOWED_TYPE = { "image/jpg"，"image/jpeg"，"image/png"，"image/gif"，"image/bmp" };
    

    /**
     * 检查是否为允许的文件类型。
     * 
     * @param contentType
     * @return
     */
    private boolean checkContentype (String contentType) {
        if ( contentType == null ) return false;
        
        // 将数组转成list.
        List<String> list = Arrays.asList(ALLOWED_TYPE);
        
        // 查看是否存在于list中，如果有任意一个存在，那么就是合法的类型，否则就是不合法的。
        return list.contains(contentType);
    }
    
    
    protected void doPost (HttpServletRequest request，HttpServletResponse response)
            throws ServletException，IOException {

        request.setCharacterEncoding("utf-8");
        response.setContentType("text/html;charset=utf-8");

        PrintWriter writer = response.getWriter();

        try {
            // 如果不是二进制文件，那么上传失败。
            if ( !ServletFileUpload.isMultipartContent(request) ) {
                writer.write("上传失败");
                return;
            }
            
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload fileUpload = new ServletFileUpload(factory);
            List<FileItem> fileItems = fileUpload.parseRequest(request);
            FileItem fileItem = fileItems.get(0);

            String contentType = fileItem.getContentType();
            if ( !checkContentype(contentType) ) {
                writer.write("非法文件，请选择正确的图片文件");
                return;
            }
            
            // 获取上传文件的文件夹真实的物理路径。
            String uploadPath = getServletContext().getRealPath(File_SEPARATOR + UPLOAD_DIRECTORY);
            File uploadPathFile = new File(uploadPath);

            // 文件夹不存在则创建文件夹.
            if ( !uploadPathFile.exists() ) {
                uploadPathFile.mkdir();
            }

            // 获取文件名.
            String name = fileItem.getName();
            
            // 如果文件名是完整的路径形式(火狐浏览器会存在这个现象)，那么截取出文件名。
            if ( name.contains(File_SEPARATOR) ) {
                name = name.substring(name.lastIndexOf(File_SEPARATOR) + 1);
            }
            
            // 文件夹 + 文件名
            File imgFile = new File(uploadPath + File_SEPARATOR + name);
            fileItem.write(imgFile);
            
            // 删除临时文件，这个方法也可以不调，因为在FileItem对象实例被回收的时候会自动清空临时文件，但框架注释说了，为了确保万一最好调用一下。
            fileItem.delete();

            if ( imgFile.exists() ) {
                writer.write("上传成功!");
            }
        } catch ( FileUploadException e ) {
            e.printStackTrace();
        } catch ( Exception e ) {
            e.printStackTrace();
        } finally {
            writer.flush();
            writer.close();
        }
    }

    protected void doGet (HttpServletRequest request，HttpServletResponse response)
            throws ServletException，IOException {
        doPost(request，response);
    }
}
```

到此就结束了。没什么技术含量，主要是我写来玩的，同时也只用于参考。
大家可以看一下上面用的几个HTML5 API对象来了解更多，以便按照自己的需求来开发。

这里推荐大家阅读张鑫旭的一篇相关博文以获得更多相关的知识《[基于HTML5的可预览多图片Ajax上传](http://www.zhangxinxu.com/wordpress/2011/09/%E5%9F%BA%E4%BA%8Ehtml5%E7%9A%84%E5%8F%AF%E9%A2%84%E8%A7%88%E5%A4%9A%E5%9B%BE%E7%89%87ajax%E4%B8%8A%E4%BC%A0/)》
