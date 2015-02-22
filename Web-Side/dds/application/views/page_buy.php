        <section id="contents" class="row">
            <article>
                <div class="title">
                    <i class="fa <? echo $icon; ?> fa-2x"></i><h3 class="clearfix"><? echo $title; ?></h3>
                </div>
                <div class="detail">
                    <div class="buy">
                        <p class="buy-mymoney"><label><? echo $langData->line('buy_mymoney'); ?></label>: <? echo $usrprf[0]['money']; ?></p>
                        <div class="buy-list">
                        </div>
                    </div>
                </div>
            </article>
        </section>

        <script type="text/javascript">;$(function($){loadList('buy', '.buy-list');});</script>