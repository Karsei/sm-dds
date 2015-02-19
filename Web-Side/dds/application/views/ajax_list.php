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
                                    <td>번호</td>
                                    <td>종류</td>
                                    <td>이름</td>
                                    <td>구매일자</td>
                                    <td>상태</td>
                                    <td>선택</td>
                                </tr>
                            </thead>
                            <tbody>
<? foreach($list as $inven): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $count; ?></td>
                                    <td><? echo $inven['icname']; ?></td>
                                    <td><? echo $inven['ilname']; ?></td>
                                    <td><? echo date("Y-m-d H:i:s", $inven['buydate']); ?></td>
                                    <td><? echo str_replace(array(0, 1), array('소지', '적용됨'), $inven['aplied']); ?></td>
                                    <td><?
                                    if ($inven['aplied'] >= 1) echo '<span data-dt="item-drop" data-t="' . $type . '" data-ilidx="' . $inven['idx'] . '" data-aid="' . $authid . '" data-url="' . $surl . '" data-p="' . $pageIdx . '" class="btndrop">버리기</span>';
                                    else echo '<span data-dt="item-apply" data-t="' . $type . '" data-ilidx="' . $inven['idx'] . '" data-aid="' . $authid . '" data-url="' . $surl . '" data-p="' . $pageIdx . '" class="btnapl">장착</span><span data-dt="item-drop" data-t="' . $type . '" data-ilidx="' . $inven['idx'] . '" data-aid=" ' . $authid . '" data-url="' . $surl . '" data-p="' . $pageIdx . '" class="btndrop">버리기</span>'; 
                                    ?></td>
                                </tr>
<? endforeach; ?>
<? if ($count == 0): ?>
								<tr>
									<td colspan="6">결과가 없습니다.</td>
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
                                    <td>번호</td>
                                    <td>종류</td>
                                    <td>이름</td>
                                    <td>금액</td>
                                    <td>지속 속성</td>
                                    <td>선택</td>
                                </tr>
                            </thead>
                            <tbody>
<? foreach($list as $buy): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $buy['ilidx']; ?></td>
                                    <td><? echo $buy['icname']; ?></td>
                                    <td><? echo $buy['itname']; ?></td>
                                    <td><? echo $buy['money']; ?></td>
                                    <td><? echo $buy['havtime']; ?></td>
                                    <td><? echo '<span data-dt="item-buy" data-t="' . $type . '" data-ilidx="' . $buy['ilidx'] . '" data-aid="' . $authid . '" data-url="' . $surl . '" data-p="' . $pageIdx . '" class="btnbuy">구매</span>'; ?></td>
                                </tr>
<? endforeach; ?>
<? if ($count == 0): ?>
                                <tr>
                                    <td colspan="6">결과가 없습니다.</td>
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
                                    <td>번호</td>
                                    <td>고유번호</td>
                                    <td>금액</td>
                                    <td>게임접속</td>
                                    <td>행동</td>
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
                                    <td><? echo '수정'; ?></td>
                                </tr>
<? endforeach; ?>
<? if ($count == 0): ?>
                                <tr>
                                    <td colspan="6">결과가 없습니다.</td>
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