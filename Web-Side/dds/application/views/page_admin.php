        <section id="contents" class="row">
            <article>
                <div class="title">
                    <i class="fa <? echo $icon; ?> fa-2x"></i><h3 class="clearfix"><? echo $title; ?></h3>
                    <nav class="sub-ad-gnb">
                        <ul class="clearfix">
                            <li><span data-t="usrlist" data-url="<? echo base_url(); ?>"><? echo $langData->line('admin_usrlist'); ?></span></li>
                            <li><span data-t="itemlist" data-url="<? echo base_url(); ?>"><? echo $langData->line('admin_itemlist'); ?></span></li>
                            <li><span data-t="itemcglist" data-url="<? echo base_url(); ?>"><? echo $langData->line('admin_itemcglist'); ?></span></li>
                            <li><span data-t="dataloglist" data-url="<? echo base_url(); ?>"><? echo $langData->line('admin_dataloglist'); ?></span></li>
                        </ul>
                    </nav>
                </div>
                <div class="detail">
                    <div class="admin">
                        <div class="admin-list">
                        </div>
                    </div>
                </div>
            </article>
            <div class="detail-info">
            </div>
        </section>

        <script type="text/javascript">;$(function($){loadList('usrlist','.admin-list');});</script>