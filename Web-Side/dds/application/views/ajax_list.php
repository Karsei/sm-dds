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
                        <table>
                            <thead>
                                <tr>
                                    <td><? echo $langData->line('tb_cate_idx'); ?></td>
                                    <td><? echo $langData->line('tb_cate_category'); ?></td>
                                    <td><? echo $langData->line('tb_cate_name'); ?></td>
                                    <td><? echo $langData->line('tb_cate_buydate'); ?></td>
                                    <td><? echo $langData->line('tb_cate_status'); ?></td>
                                    <td><? echo $langData->line('tb_cate_select'); ?></td>
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
                        <div class="detail-pagination">
                            <table>
                                <tr>
<? 
for ($i = 0; $i < $pageTotal; $i++)
{
    if ((($pageIdx - $pageSideCount) <= ($i + 1)) && (($pageIdx + $pageSideCount) >= ($i + 1)))
        if ($pageIdx == ($i + 1))
            echo '<td data-t="' . $type . '" data-tar=".myinfo-list" class="focus">' . ($i + 1) .'</td>';
        else
            echo '<td data-t="' . $type . '" data-tar=".myinfo-list">' . ($i + 1) . '</td>';
}

?>
                                </tr>
                            </table>
                        </div>
<? endif; ?>
<? /** BUY **/ ?>
<? elseif (strcmp($type, 'buy') == 0): ?>
                        <table>
                            <thead>
                                <tr>
                                    <td><? echo $langData->line('tb_cate_itidx'); ?></td>
                                    <td><? echo $langData->line('tb_cate_category'); ?></td>
                                    <td><? echo $langData->line('tb_cate_name'); ?></td>
                                    <td><? echo $langData->line('tb_cate_money'); ?></td>
                                    <td><? echo $langData->line('tb_cate_havtime'); ?></td>
                                    <td><? echo $langData->line('tb_cate_select'); ?></td>
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
                        <div class="detail-pagination">
                            <table>
                                <tr>
<? 
for ($i = 0; $i < $pageTotal; $i++)
{
    if ((($pageIdx - $pageSideCount) <= ($i + 1)) && (($pageIdx + $pageSideCount) >= ($i + 1)))
        if ($pageIdx == ($i + 1))
            echo '<td data-t="' . $type . '" data-tar=".buy-list" class="focus">' . ($i + 1) .'</td>';
        else
            echo '<td data-t="' . $type . '" data-tar=".buy-list">' . ($i + 1) . '</td>';
}

?>
                                </tr>
                            </table>
                        </div>
<? endif; ?>
<? /** ADMIN-UserList **/ ?>
<? elseif (strcmp($type, 'usrlist') == 0): ?>
                        <h4><? echo $langData->line('admin_usrlist'); ?></h4>
                        <table>
                            <thead>
                                <tr>
                                    <td><? echo $langData->line('tb_cate_usridx'); ?></td>
                                    <td><? echo $langData->line('tb_cate_authid'); ?></td>
                                    <td><? echo $langData->line('tb_cate_money'); ?></td>
                                    <td><? echo $langData->line('tb_cate_ingame'); ?></td>
                                    <td><? echo $langData->line('tb_cate_select'); ?></td>
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
                                    <td><span class="btnusrmodify" data-dt="admin-usrmodify" data-t="<? echo $type; ?>" data-uidx="<? echo $usrlist['idx']; ?>" data-url="<? echo $surl; ?>" data-p="<? echo $pageIdx; ?>" data-aid="<? echo $authid; ?>"><? echo $langData->line('btn_modify'); ?></span></td>
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
                        <div class="detail-pagination">
                            <table>
                                <tr>
<? 
for ($i = 0; $i < $pageTotal; $i++)
{
    if ((($pageIdx - $pageSideCount) <= ($i + 1)) && (($pageIdx + $pageSideCount) >= ($i + 1)))
        if ($pageIdx == ($i + 1))
            echo '<td data-t="' . $type . '" data-tar=".admin-list" class="focus">' . ($i + 1) .'</td>';
        else
            echo '<td data-t="' . $type . '" data-tar=".admin-list">' . ($i + 1) . '</td>';
}

?>
                                </tr>
                            </table>
                        </div>
<? endif; ?>
<? /** ADMIN-ItemList **/ ?>
<? elseif (strcmp($type, 'itemlist') == 0): ?>
                        <h4><? echo $langData->line('admin_itemlist'); ?></h4>
                        <table>
                            <thead>
                                <tr>
                                    <td><? echo $langData->line('tb_cate_itidx'); ?></td>
                                    <td><? echo $langData->line('tb_cate_category'); ?></td>
                                    <td><? echo $langData->line('tb_cate_name'); ?></td>
                                    <td><? echo $langData->line('tb_cate_money'); ?></td>
                                    <td><? echo $langData->line('tb_cate_havtime'); ?></td>
                                    <td><? echo $langData->line('tb_cate_env'); ?></td>
                                    <td><? echo $langData->line('tb_cate_status'); ?></td>
                                    <td><? echo $langData->line('tb_cate_select'); ?></td>
                                </tr>
                            </thead>
                            <tbody>
<? foreach($list as $itemlist): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $itemlist['ilidx']; ?></td>
                                    <td><? echo SplitStrByGeoName(GetCodeByLanguage($usrLang), $itemlist['icname']); ?></td>
                                    <td><? echo SplitStrByGeoName(GetCodeByLanguage($usrLang), $itemlist['itname']); ?></td>
                                    <td><? echo $itemlist['money']; ?></td>
                                    <td><? echo $itemlist['havtime']; ?></td>
                                    <td><? echo $itemlist['env']; ?></td>
                                    <td><? echo str_replace(array(0, 1), array($langData->line('admin_list_nouse'), $langData->line('admin_list_use')), $itemlist['status']); ?></td>
                                    <td>수정</td>
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
                        <div class="detail-pagination">
                            <table>
                                <tr>
<? 
for ($i = 0; $i < $pageTotal; $i++)
{
    if ((($pageIdx - $pageSideCount) <= ($i + 1)) && (($pageIdx + $pageSideCount) >= ($i + 1)))
        if ($pageIdx == ($i + 1))
            echo '<td data-t="' . $type . '" data-tar=".admin-list" class="focus">' . ($i + 1) .'</td>';
        else
            echo '<td data-t="' . $type . '" data-tar=".admin-list">' . ($i + 1) . '</td>';
}

?>
                                </tr>
                            </table>
                        </div>
<? endif; ?>
<? /** ADMIN-ItemCGList **/ ?>
<? elseif (strcmp($type, 'itemcglist') == 0): ?>
                        <h4><? echo $langData->line('admin_itemcglist'); ?></h4>
                        <table>
                            <thead>
                                <tr>
                                    <td><? echo $langData->line('tb_cate_icidx'); ?></td>
                                    <td><? echo $langData->line('tb_cate_name'); ?></td>
                                    <td><? echo $langData->line('tb_cate_orderidx'); ?></td>
                                    <td><? echo $langData->line('tb_cate_env'); ?></td>
                                    <td><? echo $langData->line('tb_cate_status'); ?></td>
                                    <td><? echo $langData->line('tb_cate_select'); ?></td>
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
                                    <td>수정</td>
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
                        <div class="detail-pagination">
                            <table>
                                <tr>
<? 
for ($i = 0; $i < $pageTotal; $i++)
{
    if ((($pageIdx - $pageSideCount) <= ($i + 1)) && (($pageIdx + $pageSideCount) >= ($i + 1)))
        if ($pageIdx == ($i + 1))
            echo '<td data-t="' . $type . '" data-tar=".admin-list" class="focus">' . ($i + 1) .'</td>';
        else
            echo '<td data-t="' . $type . '" data-tar=".admin-list">' . ($i + 1) . '</td>';
}

?>
                                </tr>
                            </table>
                        </div>
<? endif; ?>
<? /** ADMIN-DataLogList **/ ?>
<? elseif (strcmp($type, 'dataloglist') == 0): ?>
                        <h4><? echo $langData->line('admin_dataloglist'); ?></h4>
                        <table>
                            <thead>
                                <tr>
                                    <td><? echo $langData->line('tb_cate_idx'); ?></td>
                                    <td><? echo $langData->line('tb_cate_authid'); ?></td>
                                    <td><? echo $langData->line('tb_cate_action'); ?></td>
                                    <td><? echo $langData->line('tb_cate_data'); ?></td>
                                    <td><? echo $langData->line('tb_cate_date'); ?></td>
                                    <td><? echo $langData->line('tb_cate_ip'); ?></td>
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
                        <div class="detail-pagination">
                            <table>
                                <tr>
<? 
for ($i = 0; $i < $pageTotal; $i++)
{
    if ((($pageIdx - $pageSideCount) <= ($i + 1)) && (($pageIdx + $pageSideCount) >= ($i + 1)))
        if ($pageIdx == ($i + 1))
            echo '<td data-t="' . $type . '" data-tar=".admin-list" class="focus">' . ($i + 1) .'</td>';
        else
            echo '<td data-t="' . $type . '" data-tar=".admin-list">' . ($i + 1) . '</td>';
}

?>
                                </tr>
                            </table>
                        </div>
<? endif; ?>
<? endif; ?>
<?php } ?>