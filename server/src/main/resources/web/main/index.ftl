<!DOCTYPE html>

<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>文件预览</title>
    <link rel="icon" href="./favicon.ico" type="image/x-icon">
    <link rel="stylesheet" href="css/loading.css"/>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="bootstrap-table/bootstrap-table.min.css"/>
    <link rel="stylesheet" href="css/theme.css"/>
    <script type="text/javascript" src="js/jquery-3.6.1.min.js"></script>
    <script type="text/javascript" src="js/jquery.form.min.js"></script>
    <script type="text/javascript" src="bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="bootstrap-table/bootstrap-table.min.js"></script>
    <script type="text/javascript" src="js/base64.min.js"></script>
    <style>
        <#-- 删除文件密码弹窗居中 -->
        h1 {
            text-align: center;
        }
        .alert {
            width: 50%;
        }
        <#-- 删除文件验证码弹窗居中 -->
        .modal {
            width:100%;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            -ms-transform: translate(-50%, -50%);
        }
    </style>
</head>

<body>
    <h1>文件在线预览</h1>
<#-- 删除文件验证码弹窗  -->
<script>
    <#if deleteCaptcha >
        $("#deleteCaptchaImg").click(function() {
            $("#deleteCaptchaImg").attr("src","${baseUrl}deleteFile/captcha?timestamp=" + new Date().getTime());
        });
        $("#deleteCaptchaConfirmBtn").click(function() {
            var fileName = $("#deleteCaptchaFileName").val();
            var deleteCaptchaText = $("#deleteCaptchaText").val();
            $.get('${baseUrl}deleteFile?fileName=' + fileName +'&password=' + deleteCaptchaText, function(data){
                if ("删除文件失败，密码错误！" === data.msg) {
                    alert(data.msg);
                } else {
                    $('#table').bootstrapTable("refresh", {});
                    $("#deleteCaptchaText").val("");
                    $("#deleteCaptchaModal").modal("hide");
                }
            });
        });
        function deleteFile(fileName) {
            $("#deleteCaptchaImg").click();
            $("#deleteCaptchaFileName").val(fileName);
            $("#deleteCaptchaText").val("");
            $("#deleteCaptchaModal").modal("show");
        }
    <#else>
        function deleteFile(fileName) {
            if (window.confirm('你确定要删除文件吗？')) {
                password = prompt("请输入默认密码:123456");
                $.ajax({
                    url: '${baseUrl}deleteFile?fileName=' + fileName +'&password='+password,
                    success: function (data) {
                        if ("删除文件失败，密码错误！" === data.msg) {
                            alert(data.msg);
                        } else {
                            $("#table").bootstrapTable("refresh", {});
                        }
                    }
                });
            } else {
                return false;
            }
        }
    </#if>

    function showLoadingDiv() {
        var height = window.document.documentElement.clientHeight - 1;
        $(".loading_container").css("height", height).show();
    }

    function onFileSelected() {
        var file = $("#fileSelect").val();
        $("#fileName").text(file);
    }

    function checkUrl(url) {
        //url= 协议://(ftp的登录信息)[IP|域名](:端口号)(/或?请求参数)
        var strRegex = '^((https|http|ftp)://)'//(https或http或ftp)
            + '(([\\w_!~*\'()\\.&=+$%-]+: )?[\\w_!~*\'()\\.&=+$%-]+@)?' //ftp的user@  可有可无
            + '(([0-9]{1,3}\\.){3}[0-9]{1,3}' // IP形式的URL- 3位数字.3位数字.3位数字.3位数字
            + '|' // 允许IP和DOMAIN（域名）
            + '(localhost)|'	//匹配localhost
            + '([\\w_!~*\'()-]+\\.)*' // 域名- 至少一个[英文或数字_!~*\'()-]加上.
            + '\\w+\\.' // 一级域名 -英文或数字  加上.
            + '[a-zA-Z]{1,6})' // 顶级域名- 1-6位英文
            + '(:[0-9]{1,5})?' // 端口- :80 ,1-5位数字
            + '((/?)|' // url无参数结尾 - 斜杆或这没有
            + '(/[\\w_!~*\'()\\.;?:@&=+$,%#-]+)+/?)$';//请求参数结尾- 英文或数字和[]内的各种字符
        var re = new RegExp(strRegex, 'i');//i不区分大小写
        //将url做uri转码后再匹配，解除请求参数中的中文和空字符影响
        return re.test(encodeURI(url));
    }

    $(function () {
        $('#table').bootstrapTable({
            url: 'listFiles',
            pageNumber: ${homePageNumber},//初始化加载第一页
            pageSize:${homePageSize}, //初始化单页记录数
            pagination: ${homePagination}, //是否分页
            pageList: [5, 10, 20, 30, 50, 100, 200, 500],
            search: ${homeSearch}, //显示查询框
            columns: [{
                field: 'fileName',
                title: '文件名'
            }, {
                field: 'action',
                title: '操作',
                align: 'center',
                width: 160
            }]
        }).on('pre-body.bs.table', function (e, data) {
            // 每个data添加一列用来操作
            $(data).each(function (index, item) {
                item.action = "<a class='btn btn-success' target='_blank' href='${baseUrl}onlinePreview?url=" + encodeURIComponent(Base64.encode('${baseUrl}' + item.fileName)) + "'>预览</a>" +
                    "<a class='btn btn-danger' style='margin-left:10px;' href='javascript:void(0);' onclick='deleteFile(\"" +  encodeURIComponent(Base64.encode('${baseUrl}' + item.fileName)) + "\")'>删除</a>";
            });
            return data;
        }).on('post-body.bs.table', function (e, data) {
            return data;
        });

        $('#previewByUrl').on('click', function () {
            var _url = $("#_url").val();
            if (!checkUrl(_url)) {
                $("#previewCheckAlert").addClass("show");
                window.setTimeout(function () {
                    $("#previewCheckAlert").removeClass("show");
                }, 3000);//显示的时间
                return false;
            }

            var b64Encoded = Base64.encode(_url);

            window.open('${baseUrl}onlinePreview?url=' + encodeURIComponent(b64Encoded));
        });

        $("#fileUploadBtn").click(function () {
            var filepath = $("#file").val();
            if(!checkFileSize(filepath)) {
                return false;
            }
            showLoadingDiv();
            $("#fileUpload").ajaxSubmit({
                success: function (data) {
                    // 上传完成，刷新table
                    if (1 === data.code) {
                        alert(data.msg);
                    } else {
                        $('#table').bootstrapTable('refresh', {});
                    }
                    $("#fileName").text("");
                    $(".loading_container").hide();
                },
                error: function () {
                    alert('上传失败，请联系管理员');
                    $(".loading_container").hide();
                },
                url: 'fileUpload', /*设置post提交到的页面*/
                type: "post", /*设置表单以post方法提交*/
                dataType: "json" /*设置返回值类型为文本*/
            });
        });
    });
    function checkFileSize(filepath) {
        var daxiao= "${size}";
        daxiao= daxiao.replace("MB","");
        // console.log(daxiao)
        var maxsize = daxiao * 1024 * 1024;
        var errMsg = "上传的文件不能超过${size}喔！！！";
        var tipMsg = "您的浏览器暂不支持上传，确保上传文件不要超过${size}，建议使用IE、FireFox、Chrome浏览器";
        try {
            var filesize = 0;
            var ua = window.navigator.userAgent;
            if (ua.indexOf("MSIE") >= 1) {
                //IE
                var img = new Image();
                img.src = filepath;
                filesize = img.fileSize;
            } else {
                filesize = $("#file")[0].files[0].size; //byte
            }
            if (filesize > 0 && filesize > maxsize) {
                alert(errMsg);
                return false;
            } else if (filesize === -1) {
                alert(tipMsg);
                return false;
            }
        } catch (e) {
            alert("上传失败，请重试");
            return false;
        }
        return true;
    }
</script>
</body>
</html>
