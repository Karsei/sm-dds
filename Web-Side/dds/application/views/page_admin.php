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
                        <div class="admin-list">
                        </div>
                    </div>
                </div>
            </article>
        </section>

        <script type="text/javascript">
            ;$(function($) {
                loadList('usrlist', <? echo $authid; ?>, '<? echo site_url(); ?>');
            });
        </script>