# skyline_problem
https://leetcode.com/problems/the-skyline-problem/description/

## 解題時間
約8天，4天寫出方法，4天優化到不會timeout

## 執行時間
本地測約300ms
網站測1400ms

## 額外說明
flutter專案是預備給以後圖形化解題過程用，目前還沒實踐。

## 演算法(自己發想的)

## 從原點出發，找一條nodePath描出建築物的輪廓線

當 尚未抵達終點 :

1.若上方有路 且 上一輪沒走過 走上方

2.若上方沒路，右方有路，走右方

3.若上方右方都沒路，走下方，若下方沒路，直接前進至地平線投影點。

抵達終點後，回傳nodePath


## 規律，nodePath上的偶數點就是天際點(需排序)

nodePath由於是從左往右走，因此x的排序已自動完成

經觀察發現skyline出現在nodePath的偶數位置(原點是否有建築物會影響，視情況在nodePath中去除原點)



