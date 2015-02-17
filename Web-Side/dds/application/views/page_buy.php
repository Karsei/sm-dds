        <section id="contents" class="row">
            <article>
                <div class="title">
                    <i class="fa <? echo $icon; ?> fa-2x"></i><h3 class="clearfix"><? echo $title; ?></h3>
                </div>
                <div class="detail">
                    <p>아이템 구매 페이지입니다.</p>
                    <div class="buy">
                        <table>
                            <thead>
                                <tr>
                                    <td>번호</td>
                                    <td>종류</td>
                                    <td>이름</td>
                                    <td>금액</td>
                                    <td>지속 속성</td>
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
                loadList('buy', '.buy', <? echo $authid; ?>, '<? echo site_url(); ?>');
            })
        </script>