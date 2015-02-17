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
<? foreach($list as $inven): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $count; ?></td>
                                    <td><? echo $inven['icname']; ?></td>
                                    <td><? echo $inven['ilname']; ?></td>
                                    <td><? echo date("Y-m-d H:i:s", $inven['buydate']); ?></td>
                                    <td><? echo str_replace(array(0, 1), array('', '적용됨'), $inven['aplied']); ?></td>
                                    <td><? echo '장착 / 버리기'; ?></td>
                                </tr>
<? endforeach; ?>
<? if ($count == 0): ?>
								<tr>
									<td colspan="6">결과가 없습니다.</td>
								</tr>
<? endif; ?>
<? /** BUY **/ ?>
<? elseif (strcmp($type, 'buy') == 0): ?>
<? foreach($list as $buy): ?>
<? $count++; ?>
                                <tr>
                                    <td><? echo $buy['ilidx']; ?></td>
                                    <td><? echo $buy['icname']; ?></td>
                                    <td><? echo $buy['itname']; ?></td>
                                    <td><? echo $buy['money']; ?></td>
                                    <td><? echo $buy['havtime']; ?></td>
                                    <td><? echo '구매'; ?></td>
                                </tr>
<? endforeach; ?>
<? if ($count == 0): ?>
                                <tr>
                                    <td colspan="6">결과가 없습니다.</td>
                                </tr>
<? endif; ?>
<? /** BUY **/ ?>
<? elseif (strcmp($type, 'usrlist') == 0): ?>
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
<? endif; ?>
<? endif; ?>
<?php } ?>