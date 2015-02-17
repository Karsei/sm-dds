        
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
                            <li>프로필 주소: <a href="<? echo $profileurl; ?>" target="_blank"><? echo $profileurl; ?></a></li>
                            <li>고유 번호: <? echo $authid; ?></li>
                            <li>로그인 상태: <? echo $logstatus; ?></li>
                            <li>마지막 접속(스팀): <? echo $lastlogoff; ?></li>
                        </ul>
                    </div>

                    <div class="myinfo-inven">
                        <h4 class="sub">현재 가지고 있는 아이템</h4>
                        <table>
                            <thead>
                                <tr>
                                    <td>번호</td>
                                    <td>종류</td>
                                    <td>이름</td>
                                    <td>구매일자</td>
                                    <td>상태</td>
                                    <td>선택</td>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
            </article>
        </section>

        <script type="text/javascript">
            ;$(function($) {
                loadList('inven', '.myinfo-inven', <? echo $authid; ?>, '<? echo site_url(); ?>');
            })
        </script>