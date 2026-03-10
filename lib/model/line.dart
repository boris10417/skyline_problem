import 'package:skyline_problem/model/node.dart';

class Line {
  Node p1;
  Node p2;
  String get text {
    if (isVertical()) {
      return "垂直線:(${p1.x},${p1.y}) - (${p2.x},${p2.y})";
    }
    return "水平線:(${p1.x},${p1.y}) - (${p2.x},${p2.y})";
  }

  Line(this.p1, this.p2) : assert(isNotSameNode(p1, p2), "線必須由不同位置的兩頂點組成!");

  bool isVertical() {
    return p1.x == p2.x;
  }

  bool isHorizontal() {
    return p1.y == p2.y;
  }

  /// 輸入的頂點是否在線上，在兩頂點也算線上
  bool isNodeOnLine(Node node) {
    if (isVertical()) {
      return node.x == p1.x && (node.y <= p2.y) && (node.y >= p1.y);
    }
    // isHorizontal()...
    return node.y == p1.y && (node.x <= p2.x) && (node.x >= p1.x);
  }
}

bool isSameNode(Node a, Node b) {
  return a.x == b.x && a.y == b.y;
}

bool isNotSameNode(Node a, Node b) {
  return isSameNode(a, b) == false;
}

// 兩線是否相交
bool isTwoLineCrossed(Line vertical, Line horizontal) {
  //預計相交的頂點
  Node crossedNode = Node(vertical.p1.x, horizontal.p1.y);

  // 若頂點同時在兩條邊的線上，則兩線相交
  return vertical.isNodeOnLine(crossedNode) &&
      horizontal.isNodeOnLine(crossedNode);
}
