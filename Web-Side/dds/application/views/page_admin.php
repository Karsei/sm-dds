        <section id="contents" class="row">
            <article>
                <div class="title">
                    <i class="fa <? echo $icon; ?> fa-2x"></i><h3 class="clearfix"><? echo $title; ?></h3>
                    <nav>
                        <ul class="clearfix">
                            <li>유저 관리</li>
                            <li>아이템 관리</li>
                            <li>아이템 종류 관리</li>
                        </ul>
                    </nav>
                </div>
                <div class="detail">
                    <h4>유저 관리</h4>
                    <div class="admin-user">
                        <table>
                            <thead>
                                <tr>
                                    <td>번호</td>
                                    <td>고유번호</td>
                                    <td>금액</td>
                                    <td>게임접속</td>
                                    <td>행동</td>
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
                loadList('usrlist', '.admin-user', <? echo $authid; ?>, '<? echo site_url(); ?>');
            })
        </script>