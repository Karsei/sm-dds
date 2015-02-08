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
                            <li>프로필 주소: <a href="<? echo $profileurl; ?>"><? echo $profileurl; ?></a></li>
                            <li>고유 번호: <? echo $authid; ?></li>
                            <li>로그인 상태: <? echo $logstatus; ?></li>
                            <li>마지막 접속(스팀): <? echo $lastlogoff; ?></li>
                        </ul>
                    </div>
                </div>
            </article>
        </section>
