        <section id="contents" class="row">
            <article>
                <div class="title">
                    <i class="fa <? echo $icon; ?> fa-2x"></i><h3 class="clearfix"><? echo $title; ?></h3>
                </div>
                <div class="detail">
                    <p>아이템 구매 페이지입니다.</p>
                    <div class="buy">
                        <div class="buy-list">
                        </div>
                    </div>
                </div>
            </article>
        </section>

        <script type="text/javascript">
            ;$(function($) {
                loadList('buy', <? echo $authid; ?>, '<? echo site_url(); ?>');
            });
        </script>