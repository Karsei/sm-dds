        
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
                            <li><label>프로필 주소</label><a href="<? echo $profileurl; ?>" target="_blank"><? echo $profileurl; ?></a></li>
                            <li><label>고유 번호</label><? echo $authid; ?></li>
                            <li><label>로그인 상태</label> <? echo $logstatus; ?></li>
                            <li><label>마지막 접속(스팀)</label><? echo $lastlogoff; ?></li>
                        </ul>
                    </div>

                    <div class="myinfo-inven">
                        <h4 class="sub">현재 가지고 있는 아이템</h4>
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