<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        
        <title><? echo PRODUCT_NAME; ?> :: Login</title>
        <link rel="stylesheet" href="<? echo assets_url(); ?>css/login.css">
        <link rel="shortcut icon" type="image/x-icon" href="<? echo images_url(); ?>favicon.ico">
    </head>
    
    <body>
        <div id="container">
            <div id="header">
                <h1><? echo PRODUCT_NAME; ?></h1>
            </div>
        
            <div id="login">
                <h2>환영합니다!</h2>
                <p>웹 패널로 접속하기 위해서는 로그인이 필요합니다.<br>별 다른 가입없이 스팀 아이디로 로그인이 가능합니다.</p>
                <p>(참고로, 서버에 접속하시면 자동으로 가입됩니다.)</p>
                <p>아래의 이미지를 클릭하시면 로그인을 하실 수 있습니다.</p>

                <? echo $setform; ?>
            </div>
        
            <div id="copyright">Copyright (c) 2012-2015 Karsei All Rights Reserved</div>
        </div>
    </body>
</html>