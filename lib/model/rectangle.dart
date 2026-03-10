import 'package:skyline_problem/model/node.dart';

class Rectangle {
  //長方形固定4頂點
  List<Node> nodes;

  Rectangle(this.nodes) : assert(nodes.length == 4, "長方形固定4頂點!");

  ///找出x的座標範圍
  (int, int) getXRange() {
    // 用互為對角的兩個座標(假設節點的輸入是有序排列)，座標由小到大排列，例如:(0,2) 而不是(2,0)
    // ps:假設長方形的節點紀錄是點依序連線紀錄的情況下，互為對角的兩個點可以直接拿來計算，避免了同x或同y的情況。
    return (nodes[0].x < nodes[2].x)
        ? (nodes[0].x, nodes[2].x)
        : (nodes[2].x, nodes[0].x);
  }

  ///找出y的座標範圍
  (int, int) getYRange() {
    // 用互為對角的兩個座標，座標由小到大排列
    return (nodes[0].y < nodes[2].y)
        ? (nodes[0].y, nodes[2].y)
        : (nodes[2].y, nodes[0].y);
  }
}
