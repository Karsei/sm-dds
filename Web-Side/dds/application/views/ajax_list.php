<?php
/*****************************************
 * GET LIST BY POST (AJAX)
 * Karsei
******************************************/
?>

<?php

if (isset($list)) {
    $count = 0;
?>
<? /** INVENTORY **/ ?>
<? if (strcmp($type, 'inven') == 0): ?>
                        <table id="user-invenlist" class="table">
                            <thead>
                                <tr>
                                    <th><? echo $langData->line('tb_cate_idx'); ?></th>
                                    <th><? echo $langData->line('tb_cate_category'); ?></th>
                                    <th><? echo $langData->line('tb_cate_name'); ?></th>
                                    <th><? echo $langData->line('tb_cate_buydate'); ?></th>
                                    <th><? echo $langData->line('tb_cate_status'); ?></th>
                                    <th><? echo $langData->line('tb_cate_select'); ?></th>
                                </tr>
                            </thead>
                            <tbody>
<? foreach($list as $inven): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $inven['idx']; ?></td>
                                    <td><? echo SplitStrByGeoName(GetCodeByLanguage($usrLang), $inven['icname']); ?></td>
                                    <td><? echo SplitStrByGeoName(GetCodeByLanguage($usrLang), $inven['ilname']); ?></td>
                                    <td><? echo date("Y-m-d H:i:s", $inven['buydate']); ?></td>
                                    <td><? echo str_replace(array(0, 1), array($langData->line('myinfo_list_have'), $langData->line('myinfo_list_applied')), $inven['aplied']); ?></td>
                                    <td><?
                                    if ($inven['aplied'] >= 1) echo '<span data-dt="item-applycancel" data-t="' . $type . '" data-ilidx="' . $inven['idx'] . '" data-icidx="' . $inven['icidx'] . '" data-p="' . $pageIdx . '" class="btnaplcan">' . $langData->line('myinfo_list_applycancel') . '</span><span data-dt="item-drop" data-t="' . $type . '" data-ilidx="' . $inven['idx'] . '" data-icidx="' . $inven['icidx'] . '" data-aid="' . $authid . '" data-url="' . $surl . '" data-p="' . $pageIdx . '" class="btndrop">' . $langData->line('myinfo_list_drop') . '</span>';
                                    else echo '<span data-dt="item-apply" data-t="' . $type . '" data-ilidx="' . $inven['idx'] . '" data-icidx="' . $inven['icidx'] . '" data-p="' . $pageIdx . '" class="btnapl">' . $langData->line('myinfo_list_apply') . '</span><span data-dt="item-drop" data-t="' . $type . '" data-ilidx="' . $inven['idx'] . '" data-icidx="' . $inven['icidx'] . '" data-p="' . $pageIdx . '" class="btndrop">' . $langData->line('myinfo_list_drop') . '</span>'; 
                                    ?></td>
                                </tr>
<? endforeach; ?>
<? if ($count == 0): ?>
								<tr>
									<td colspan="6"><? echo $langData->line('msg_results_none'); ?></td>
								</tr>
                            </tbody>
                        </table>
<? else: ?>
                            </tbody>
                        </table>
                        <ul class="pagination">
<? 
for ($i = 0; $i < $pageTotal; $i++)
{
    if ((($pageIdx - $pageSideCount) <= ($i + 1)) && (($pageIdx + $pageSideCount) >= ($i + 1)))
        if ($pageIdx == ($i + 1))
            echo '<li class="active"><a href="#" data-t="' . $type . '" data-tar="#myinfo-list">' . ($i + 1) .'</a></li>';
        else
            echo '<li><a href="#" data-t="' . $type . '" data-tar="#myinfo-list">' . ($i + 1) . '</a></li>';
}

?>
                        </ul>
<? endif; ?>
<? /** BUY **/ ?>
<? elseif (strcmp($type, 'buy') == 0): ?>
                        <p class="buy-mymoney"><label><? echo $langData->line('buy_mymoney'); ?></label>: <? echo $usrprofile[0]['money']; ?></p>
                        <table id="user-buylist" class="table">
                            <thead>
                                <tr>
                                    <th><? echo $langData->line('tb_cate_itidx'); ?></th>
                                    <th><? echo $langData->line('tb_cate_category'); ?></th>
                                    <th><? echo $langData->line('tb_cate_name'); ?></th>
                                    <th><? echo $langData->line('tb_cate_money'); ?></th>
                                    <th><? echo $langData->line('tb_cate_havtime'); ?></th>
                                    <th><? echo $langData->line('tb_cate_select'); ?></th>
                                </tr>
                            </thead>
                            <tbody>
<? foreach($list as $buy): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $buy['ilidx']; ?></td>
                                    <td><? echo SplitStrByGeoName(GetCodeByLanguage($usrLang), $buy['icname']); ?></td>
                                    <td><? echo SplitStrByGeoName(GetCodeByLanguage($usrLang), $buy['itname']); ?></td>
                                    <td><? echo $buy['money']; ?></td>
                                    <td><? echo $buy['havtime']; ?></td>
                                    <td><? echo '<span data-dt="item-buy" data-t="' . $type . '" data-ilidx="' . $buy['ilidx'] . '" data-p="' . $pageIdx . '" class="btnbuy">' . $langData->line('buy_list_buy') . '</span>'; ?></td>
                                </tr>
<? endforeach; ?>
<? if ($count == 0): ?>
                                <tr>
                                    <td colspan="6"><? echo $langData->line('msg_results_none'); ?></td>
                                </tr>
                            </tbody>
                        </table>
<? else: ?>
                            </tbody>
                        </table>
                        <ul class="pagination">
<? 
for ($i = 0; $i < $pageTotal; $i++)
{
    if ((($pageIdx - $pageSideCount) <= ($i + 1)) && (($pageIdx + $pageSideCount) >= ($i + 1)))
        if ($pageIdx == ($i + 1))
            echo '<li class="active"><a href="#" data-t="' . $type . '" data-tar="#buy-list">' . ($i + 1) .'</a></li>';
        else
            echo '<li><a href="#" data-t="' . $type . '" data-tar="#buy-list">' . ($i + 1) . '</a></li>';
}

?>
                        </ul>
<? endif; ?>
<? /** ADMIN-UserList **/ ?>
<? elseif (strcmp($type, 'usrlist') == 0): ?>
                        <div class="box-sub-title">
                            <h1><? echo $langData->line('admin_usrlist'); ?></h1>
                        </div>
                        <table id="admin-userlist" class="table">
                            <thead>
                                <tr>
                                    <th><? echo $langData->line('tb_cate_usridx'); ?></th>
                                    <th><? echo $langData->line('tb_cate_authid'); ?></th>
                                    <th><? echo $langData->line('tb_cate_money'); ?></th>
                                    <th><? echo $langData->line('tb_cate_ingame'); ?></th>
                                    <th><? echo $langData->line('tb_cate_select'); ?></th>
                                </tr>
                            </thead>
                            <tbody>
<? foreach($list as $usrlist): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $usrlist['idx']; ?></td>
                                    <td><? echo $usrlist['authid']; ?></td>
                                    <td class="usrmoney" data-uidx="<? echo $usrlist['idx']; ?>"><? echo $usrlist['money']; ?></td>
                                    <td><? echo str_replace(array(0, 1), array($langData->line('admin_list_gameoff'), $langData->line('admin_list_gameon')), $usrlist['ingame']); ?></td>
                                    <td><span class="btn_usrmodify" data-dt="admin-usrmodify" data-t="<? echo $type; ?>" data-uidx="<? echo $usrlist['idx']; ?>" data-p="<? echo $pageIdx; ?>"><? echo $langData->line('btn_modify'); ?></span></td>
                                </tr>
<? endforeach; ?>
<? if ($count == 0): ?>
                                <tr>
                                    <td colspan="5"><? echo $langData->line('msg_results_none'); ?></td>
                                </tr>
                            </tbody>
                        </table>
<? else: ?>
                            </tbody>
                        </table>
                        <ul class="pagination">
<? 
for ($i = 0; $i < $pageTotal; $i++)
{
    if ((($pageIdx - $pageSideCount) <= ($i + 1)) && (($pageIdx + $pageSideCount) >= ($i + 1)))
        if ($pageIdx == ($i + 1))
            echo '<li class="active"><a href="#" data-t="' . $type . '" data-tar="#admin-list">' . ($i + 1) .'</a></li>';
        else
            echo '<li><a href="#" data-t="' . $type . '" data-tar="#admin-list">' . ($i + 1) . '</a></li>';
}

?>
                        </ul>
<? endif; ?>
<? /** ADMIN-ItemList **/ ?>
<? elseif (strcmp($type, 'itemlist') == 0): ?>
                        <div class="box-sub-title">
                            <h1><? echo $langData->line('admin_itemlist'); ?></h1>
                        </div>
                        <table id="admin-itemlist" class="table">
                            <thead>
                                <tr>
                                    <th><? echo $langData->line('tb_cate_itidx'); ?></th>
                                    <th><? echo $langData->line('tb_cate_category'); ?></th>
                                    <th><? echo $langData->line('tb_cate_name'); ?></th>
                                    <th><? echo $langData->line('tb_cate_money'); ?></th>
                                    <th><? echo $langData->line('tb_cate_havtime'); ?></th>
                                    <th><? echo $langData->line('tb_cate_env'); ?></th>
                                    <th><? echo $langData->line('tb_cate_status'); ?></th>
                                    <th><? echo $langData->line('tb_cate_select'); ?></th>
                                </tr>
                            </thead>
                            <tbody>
<? foreach($list as $itemlist): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $itemlist['ilidx']; ?></td>
                                    <td><? echo SplitStrByGeoName(GetCodeByLanguage($usrLang), $itemlist['icname']). '(' . $itemlist['icidx'] . ')'; ?></td>
                                    <td><? echo SplitStrByGeoName(GetCodeByLanguage($usrLang), $itemlist['itname']); ?></td>
                                    <td><? echo $itemlist['money']; ?></td>
                                    <td><? echo $itemlist['havtime']; ?></td>
                                    <td><? echo $itemlist['env']; ?></td>
                                    <td><? echo str_replace(array(0, 1), array($langData->line('admin_list_nouse'), $langData->line('admin_list_use')), $itemlist['status']); ?></td>
                                    <td><span class="btn_itemmodify" data-dt="admin-itemmodify" data-t="<? echo $type; ?>" data-ilidx="<? echo $itemlist['ilidx']; ?>" data-p="<? echo $pageIdx; ?>"><? echo $langData->line('btn_modify'); ?></span><span class="btn_itemdelete" data-dt="admin-itemdelete" data-t="<? echo $type; ?>" data-ilidx="<? echo $itemlist['ilidx']; ?>" data-p="<? echo $pageIdx; ?>"><? echo $langData->line('btn_delete'); ?></span></td>
                                </tr>
<? endforeach; ?>
<? if ($count == 0): ?>
                                <tr>
                                    <td colspan="8"><? echo $langData->line('msg_results_none'); ?></td>
                                </tr>
                            </tbody>
                        </table>
<? else: ?>
                            </tbody>
                        </table>
                        <ul class="pagination">
<? 
for ($i = 0; $i < $pageTotal; $i++)
{
    if ((($pageIdx - $pageSideCount) <= ($i + 1)) && (($pageIdx + $pageSideCount) >= ($i + 1)))
        if ($pageIdx == ($i + 1))
            echo '<li class="active"><a href="#" data-t="' . $type . '" data-tar="#admin-list">' . ($i + 1) .'</a></li>';
        else
            echo '<li><a href="#" data-t="' . $type . '" data-tar="#admin-list">' . ($i + 1) . '</a></li>';
}

?>
                        </ul>
<? endif; ?>
<? /** ADMIN-ItemCGList **/ ?>
<? elseif (strcmp($type, 'itemcglist') == 0): ?>
                        <div class="box-sub-title">
                            <h1><? echo $langData->line('admin_itemcglist'); ?></h1>
                        </div>
                        <table id="admin-itemcglist" class="table">
                            <thead>
                                <tr>
                                    <th><? echo $langData->line('tb_cate_icidx'); ?></th>
                                    <th><? echo $langData->line('tb_cate_name'); ?></th>
                                    <th><? echo $langData->line('tb_cate_orderidx'); ?></th>
                                    <th><? echo $langData->line('tb_cate_env'); ?></th>
                                    <th><? echo $langData->line('tb_cate_status'); ?></th>
                                    <th><? echo $langData->line('tb_cate_select'); ?></th>
                                </tr>
                            </thead>
                            <tbody>
<? foreach($list as $cglist): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $cglist['icidx']; ?></td>
                                    <td><? echo SplitStrByGeoName(GetCodeByLanguage($usrLang), $cglist['gloname']); ?></td>
                                    <td><? echo $cglist['orderidx']; ?></td>
                                    <td><? echo $cglist['env']; ?></td>
                                    <td><? echo str_replace(array(0, 1), array($langData->line('admin_list_nouse'), $langData->line('admin_list_use')), $cglist['status']); ?></td>
                                    <td><span class="btn_itemcgmodify" data-dt="admin-itemcgmodify" data-t="<? echo $type; ?>" data-icidx="<? echo $cglist['icidx']; ?>" data-p="<? echo $pageIdx; ?>"><? echo $langData->line('btn_modify'); ?></span><span class="btn_itemcgdelete" data-dt="admin-itemcgdelete" data-t="<? echo $type; ?>" data-icidx="<? echo $cglist['icidx']; ?>" data-p="<? echo $pageIdx; ?>"><? echo $langData->line('btn_delete'); ?></span></td>
                                </tr>
<? endforeach; ?>
<? if ($count == 0): ?>
                                <tr>
                                    <td colspan="6"><? echo $langData->line('msg_results_none'); ?></td>
                                </tr>
                            </tbody>
                        </table>
<? else: ?>
                            </tbody>
                        </table>
                        <ul class="pagination">
<? 
for ($i = 0; $i < $pageTotal; $i++)
{
    if ((($pageIdx - $pageSideCount) <= ($i + 1)) && (($pageIdx + $pageSideCount) >= ($i + 1)))
        if ($pageIdx == ($i + 1))
            echo '<li class="active"><a href="#" data-t="' . $type . '" data-tar="#admin-list">' . ($i + 1) .'</a></li>';
        else
            echo '<li><a href="#" data-t="' . $type . '" data-tar="#admin-list">' . ($i + 1) . '</a></li>';
}

?>
                        </ul>
<? endif; ?>
<? /** ADMIN-DataLogList **/ ?>
<? elseif (strcmp($type, 'dataloglist') == 0): ?>
                        <div class="box-sub-title">
                            <h1><? echo $langData->line('admin_dataloglist'); ?></h1>
                        </div>
                        <table id="admin-dataloglist" class="table">
                            <thead>
                                <tr>
                                    <th><? echo $langData->line('tb_cate_idx'); ?></th>
                                    <th><? echo $langData->line('tb_cate_authid'); ?></th>
                                    <th><? echo $langData->line('tb_cate_action'); ?></th>
                                    <th><? echo $langData->line('tb_cate_data'); ?></th>
                                    <th><? echo $langData->line('tb_cate_date'); ?></th>
                                    <th><? echo $langData->line('tb_cate_ip'); ?></th>
                                </tr>
                            </thead>
                            <tbody>
<? foreach($list as $dllist): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $dllist['idx']; ?></td>
                                    <td><? echo $dllist['authid']; ?></td>
                                    <td><? echo $dllist['action']; ?></td>
                                    <td><? echo $dllist['setdata']; ?></td>
                                    <td><? echo date("Y-m-d H:i:s", $dllist['thisdate']); ?></td>
                                    <td><? echo $dllist['usrip']; ?></td>
                                </tr>
<? endforeach; ?>
<? if ($count == 0): ?>
                                <tr>
                                    <td colspan="6"><? echo $langData->line('msg_results_none'); ?></td>
                                </tr>
                            </tbody>
                        </table>
<? else: ?>
                            </tbody>
                        </table>
                        <ul class="pagination">
<? 
for ($i = 0; $i < $pageTotal; $i++)
{
    if ((($pageIdx - $pageSideCount) <= ($i + 1)) && (($pageIdx + $pageSideCount) >= ($i + 1)))
        if ($pageIdx == ($i + 1))
            echo '<li class="active"><a href="#" data-t="' . $type . '" data-tar="#admin-list">' . ($i + 1) .'</a></li>';
        else
            echo '<li><a href="#" data-t="' . $type . '" data-tar="#admin-list">' . ($i + 1) . '</a></li>';
}

?>
                        </ul>
<? endif; ?>
<? endif; ?>
<?php } ?>