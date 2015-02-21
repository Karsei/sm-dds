        
        <section id="contents" class="row">
            <article>
                <div class="title">
                    <i class="fa <? echo $icon; ?> fa-2x"></i><h3 class="clearfix"><? echo $title; ?></h3>
                </div>
                <div class="detail">
                    <div class="myinfo clearfix">
                        <img class="profileimg" src="<? echo $profileimg; ?>" />
                        <ul>
                            <li class="name"><? echo $name; ?></li>
                            <li><label><? echo $langData->line('myinfo_profileadrs'); ?></label><a href="<? echo $profileurl; ?>" target="_blank"><? echo $profileurl; ?></a></li>
                            <li><label><? echo $langData->line('myinfo_authid'); ?></label><? echo $authid; ?></li>
                            <li><label><? echo $langData->line('myinfo_logstatus'); ?></label> <? echo $logstatus ? $langData->line('myinfo_logstatus_on') : $langData->line('myinfo_logstatus_off'); ?></li>
                            <li><label><? echo $langData->line('myinfo_lastlogin'); ?></label><? echo $lastlogoff; ?></li>
                        </ul>
                    </div>

                    <div class="myinfo-inven">
                        <h4 class="sub"><? echo $langData->line('myinfo_haveinven'); ?></h4>
                        <div class="myinfo-list">
                        </div>
                    </div>
                </div>
            </article>
        </section>

        <script type="text/javascript">
            ;$(function($) {
                loadList('inven', <? echo $authid; ?>, '<? echo site_url(); ?>');
            });
        </script>