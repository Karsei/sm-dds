<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="keywords" content="Dynamic Dollar Shop">
        <meta name="author" content="Karsei">
        
        <title><? echo PRODUCT_NAME; ?></title>
        <link rel="stylesheet" href="<? echo assets_url(); ?>css/main.css">
        <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css">
        <link rel="shortcut icon" type="image/x-icon" href="<? echo images_url(); ?>favicon.ico">

        <script type="text/javascript" src="<? echo assets_url(); ?>js/jquery-1.11.2.min.js"></script>
        <!--[if lt IE 9]>
            <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
            <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->
    </head>
    
    <body>
        <div class="ddscon row">
            <header class="row">
                <h2 id="title"><? echo PRODUCT_NAME; ?></h2>
                <nav id="gnb">
                    <ul class="clearfix">
                        <? echo $menuset; ?>
                    </ul>
                </nav>
            </header>
            