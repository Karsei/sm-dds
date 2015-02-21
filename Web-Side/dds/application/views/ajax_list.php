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
                                    <td><? echo $langData->line('tb_cate_action'); ?></td>
                                </tr>
                            </thead>
                            <tbody>
<? foreach($list as $inven): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $count; ?></td>
                                    <td><? echo SplitStrByGeoName(GetCodeByLanguage($usrLang), $inven['icname']); ?></td>
                                    <td><? echo SplitStrByGeoName(GetCodeByLanguage($usrLang), $inven['ilname']); ?></td>
                                    <td><? echo date("Y-m-d H:i:s", $inven['buydate']); ?></td>
                                    <td><? echo str_replace(array(0, 1), array($langData->line('myinfo_list_have'), $langData->line('myinfo_list_applied')), $inven['aplied']); ?></td>
                                    <td><?
                                    if ($inven['aplied'] >= 1) echo '<span data-dt="item-applycancel" data-t="' . $type . '" data-ilidx="' . $inven['idx'] . '" data-icidx="' . $inven['icidx'] . '" data-aid="' . $authid . '" data-url="' . $surl . '" data-p="' . $pageIdx . '" class="btnaplcan">' . $langData->line('myinfo_list_applycancel') . '</span><span data-dt="item-drop" data-t="' . $type . '" data-ilidx="' . $inven['idx'] . '" data-icidx="' . $inven['icidx'] . '" data-aid="' . $authid . '" data-url="' . $surl . '" data-p="' . $pageIdx . '" class="btndrop">' . $langData->line('myinfo_list_drop') . '</span>';
                                    else echo '<span data-dt="item-apply" data-t="' . $type . '" data-ilidx="' . $inven['idx'] . '" data-icidx="' . $inven['icidx'] . '" data-aid="' . $authid . '" data-url="' . $surl . '" data-p="' . $pageIdx . '" class="btnapl">' . $langData->line('myinfo_list_apply') . '</span><span data-dt="item-drop" data-t="' . $type . '" data-ilidx="' . $inven['idx'] . '" data-icidx="' . $inven['icidx'] . '" data-aid=" ' . $authid . '" data-url="' . $surl . '" data-p="' . $pageIdx . '" class="btndrop">' . $langData->line('myinfo_list_drop') . '</span>'; 
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
            echo '<td data-t="' . $type . '" data-aid=" ' . $authid . '" data-url="' . $surl . '" class="focus">' . ($i + 1) .'</td>';
        else
            echo '<td data-t="' . $type . '" data-aid=" ' . $authid . '" data-url="' . $surl . '">' . ($i + 1) . '</td>';
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
                                    <td><? echo $langData->line('tb_cate_action'); ?></td>
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
                                    <td><? echo '<span data-dt="item-buy" data-t="' . $type . '" data-ilidx="' . $buy['ilidx'] . '" data-aid="' . $authid . '" data-url="' . $surl . '" data-p="' . $pageIdx . '" class="btnbuy">' . $langData->line('buy_list_buy') . '</span>'; ?></td>
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
            echo '<td data-t="' . $type . '" data-aid=" ' . $authid . '" data-url="' . $surl . '" class="focus">' . ($i + 1) .'</td>';
        else
            echo '<td data-t="' . $type . '" data-aid=" ' . $authid . '" data-url="' . $surl . '">' . ($i + 1) . '</td>';
}

?>
                                </tr>
                            </table>
                        </div>
<? endif; ?>
<? /** BUY **/ ?>
<? elseif (strcmp($type, 'usrlist') == 0): ?>
                        <table>
                            <thead>
                                <tr>
                                    <td><? echo $langData->line('tb_cate_usridx'); ?></td>
                                    <td><? echo $langData->line('tb_cate_authid'); ?></td>
                                    <td><? echo $langData->line('tb_cate_money'); ?></td>
                                    <td><? echo $langData->line('tb_cate_ingame'); ?></td>
                                    <td><? echo $langData->line('tb_cate_action'); ?></td>
                                </tr>
                            </thead>
                            <tbody>
<? foreach($list as $usrlist): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $usrlist['idx']; ?></td>
                                    <td><? echo $usrlist['authid']; ?></td>
                                    <td><? echo $usrlist['money']; ?></td>
                                    <td><? echo $usrlist['ingame']; ?></td>
                                    <td><? echo $langData->line('admin_usrlist_modify'); ?></td>
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
            echo '<td data-t="' . $type . '" data-aid=" ' . $authid . '" data-url="' . $surl . '" class="focus">' . ($i + 1) .'</td>';
        else
            echo '<td data-t="' . $type . '" data-aid=" ' . $authid . '" data-url="' . $surl . '">' . ($i + 1) . '</td>';
}

?>
                                </tr>
                            </table>
                        </div>
<? endif; ?>
<? endif; ?>
<?php } ?>