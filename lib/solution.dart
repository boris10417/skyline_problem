/*
  設 
    所有的垂直線，p1都是下方點，p2都是上方點
    所有的水平線，p1都是左方點，p2都是右方點

  已知
    一個組合建築輪廓的右下點必為天際線頂點
    nodePath中，偶數索引位置都是天際線頂點
 */

import 'package:skyline_problem/model/line.dart';
import 'package:skyline_problem/model/node.dart';

enum Direction { up, down, right, none }

class Solution {
  // 建立映射表，x 對 x上的垂直線
  Map<int, List<Line>> xToVerticalLine = {};

  // 建立映射表，y 對 y上的水平線
  Map<int, List<Line>> yToHorizontalLine = {};

  //所有垂直線可能的x座標們
  List<int> xCoordinateOfVerticalLines = [];

  //所有水平線可能的y座標們
  List<int> yCoordinateOfHorizontalLines = [];

  List<List<int>> getSkyline(List<List<int>> buildings) {
    buildVerticalLineAndHorzontalLine(buildings);

    // 計算起點到終點的頂點路徑
    List<Node> nodePath = collectNodePath();

    // print("nodePath:$nodePath");

    // 根據nodePath找出答案節點...
    // 此節點滿足 任一垂直線的p1 且 任一水平線的p1 則為答案
    // 最右下角的點只要存在一個buildings就必為答案之一

    //取得天際點
    List<Node> allSkylinePoints = getSkylineFromNodePath(nodePath);

    //List<Node> -> List<List<int>>
    List<List<int>> answer = allSkylinePoints.map((e) => [e.x, e.y]).toList();
    // print("answer = $answer");
    return answer;
  }

  ///取出垂直線與水平線
  void buildVerticalLineAndHorzontalLine(List<List<int>> buildings) {
    // 所有的垂直線和水平線
    List<Line> allVerticalLines = [];
    List<Line> allHorizontalLines = [];

    for (var building in buildings) {
      int leftX = building[0];
      int rightX = building[1];
      int height = building[2];
      allVerticalLines.addAll([
        Line(Node(leftX, 0), Node(leftX, height)),
        Line(Node(rightX, 0), Node(rightX, height))
      ]);
      allHorizontalLines.addAll([
        Line(Node(leftX, 0), Node(rightX, 0)),
        Line(Node(leftX, height), Node(rightX, height))
      ]);
    }

    //從左到右排序
    allVerticalLines = sortVerticalLinesInAscend(allVerticalLines);
    //從高到低排序
    allHorizontalLines = sortHorizontalLinesInDescend(allHorizontalLines);

    //建立 x 對 x上的垂直線 的映射表
    buildMapXToVerticalLine(allVerticalLines);
    //建立 y 對 y上的水平線 的映射表
    buildMapYToHorizontalLine(allHorizontalLines);

    xCoordinateOfVerticalLines = xToVerticalLine.keys.toList();
    yCoordinateOfHorizontalLines = yToHorizontalLine.keys.toList();
  }

  /// 從nodePath中取出天際線點
  List<Node> getSkylineFromNodePath(List<Node> orderNodePath) {
    List<Node> newOrderNodePath = orderNodePath;

    if (newOrderNodePath.length % 2 != 0) {
      //若nodePath長度為奇數

      //刪除Node (0,0)
      newOrderNodePath.removeAt(0);
    }

    List<Node> answer = [];
    for (var i = 0; i < newOrderNodePath.length; i++) {
      //只要索引為奇數，紀錄為天際線點(也就是在陣列中的偶數位置 例如: arr[1] arr[3] ...)
      if (i % 2 != 0) {
        answer.add(newOrderNodePath[i]);
      }
    }
    return answer;
  }

  //建立 x 對 x上的垂直線 的映射表
  void buildMapXToVerticalLine(List<Line> allVerticalLines) {
    for (var element in allVerticalLines) {
      if (xToVerticalLine[element.p1.x] == null) {
        xToVerticalLine[element.p1.x] = [element];
      } else {
        xToVerticalLine[element.p1.x]!.add(element);
      }
    }
  }

  //建立 y 對 y上的水平線 的映射表
  void buildMapYToHorizontalLine(List<Line> allHorizontalLines) {
    for (var element in allHorizontalLines) {
      if (yToHorizontalLine[element.p1.y] == null) {
        yToHorizontalLine[element.p1.y] = [element];
      } else {
        yToHorizontalLine[element.p1.y]!.add(element);
      }
    }
  }

  ///存在一條向右的路
  bool existOneRoadToRight(Node currentPosition, List<Line> horizontalLines) {
    if (currentPosition.y == 0) {
      //地平線必有路向右
      return true;
    }
    //現在位置在水平線上 且 現在位置不是水平線右端點
    bool hasRightRoadOnBuilding = horizontalLines.any((e) {
      return e.isNodeOnLine(currentPosition) &&
          isNotSameNode(e.p2, currentPosition);
    });

    return hasRightRoadOnBuilding;
  }

  //計算下個前進的方向
  Direction calculateNextDirection(
      Node currentPosition, Direction lastDirection) {
    //與現在位置連通的垂直線們
    List<Line>? availableVerticalLines = xToVerticalLine[currentPosition.x];

    if (availableVerticalLines == null) {
      // 僅有一種情況可能找不到垂直線，就是現在位置為(0,0)時，此時直接方向固定為右
      //ps:因為有時不存在垂直線在x = 0上，但仍有的測試資料垂直線在x = 0，例如 building = [0,2,3]。
      return Direction.right;
    }

    //若 存在一條垂直線，p2.y比現在位置.y高 且 上一輪的方向不是往下，則上方有路
    bool upHasRoad = availableVerticalLines.any(
        (e) => e.p2.y > currentPosition.y && lastDirection != Direction.down);
    if (upHasRoad) {
      return Direction.up;
    }
    //右方或下方有路

    bool rightHasRoad = existOneRoadToRight(
        currentPosition, yToHorizontalLine[currentPosition.y]!);

    if (rightHasRoad) {
      return Direction.right;
    }
    //下方有路
    return Direction.down;
  }

  ///找上方的前進終點
  Node calculateNextPositionInUp(Node currentPosition) {
    //取得該x的所有垂直線
    List<Line> availableVerticalLines = xToVerticalLine[currentPosition.x]!;
    //取得p2.y最大的該條垂直線當終點
    Line highestVerticalLine =
        getTheHighestVerticalLine(availableVerticalLines);

    return Node(currentPosition.x, highestVerticalLine.p2.y);
  }

  ///找右方的前進終點
  Node calculateNextPositionInRight(Node currentPosition) {
    return getRightPosition(currentPosition);
  }

  ///取得右側的終點，此方法不考慮垂直線的高度，無條件取最靠近的垂直線，因此可能會出現多次向右的情況
  ///
  ///輸入: 現在位置
  Node getRightPosition(Node currentPosition) {
    int firstXIndex = (currentPosition.x == 0)
        //現在位置.x == 0時，取不到垂直線，直接取第1個就好
        ? 0
        //其他位置存在索引
        : xCoordinateOfVerticalLines.indexOf(currentPosition.x);
    for (var i = firstXIndex; i < xCoordinateOfVerticalLines.length; i++) {
      if (currentPosition.x < xCoordinateOfVerticalLines[i]) {
        //取最靠左的垂直線

        return Node(xCoordinateOfVerticalLines[i], currentPosition.y);
      }
    }
    throw "發生錯誤，找不到一條垂直線";
  }

  ///取得下方的終點，此方法不考慮水平線是否相交，無條件取最高的水平線，因此可能會出現多次向下的情況
  Node getDownPosition(Node currentPosition) {
    //最高的y
    int firstYIndex = yCoordinateOfHorizontalLines.indexOf(currentPosition.y);
    for (var i = firstYIndex; i < yCoordinateOfHorizontalLines.length; i++) {
      if (currentPosition.y > yCoordinateOfHorizontalLines[i]) {
        //取第一個現在位置.y之下的水平線投影點
        return Node(currentPosition.x, yCoordinateOfHorizontalLines[i]);
      }
    }
    //找不到水平線，回傳與地平線的交點
    return Node(currentPosition.x, 0);
  }

  ///找下方的前進終點
  Node calculateNextPositionInDown(Node currentPosition) {
    return getDownPosition(currentPosition);
  }

  /// 將輸入的垂直線們從x小排到x大
  List<Line> sortVerticalLinesInAscend(List<Line> verticalLines) {
    verticalLines.sort((a, b) => a.p1.x.compareTo(b.p1.x));

    return verticalLines;
  }

  /// 將輸入的水平線們從y高排到y低
  List<Line> sortHorizontalLinesInDescend(List<Line> horizontalLines) {
    horizontalLines.sort((a, b) => b.p2.y.compareTo(a.p2.y));

    return horizontalLines;
  }

  /// 取得p2.y最高的那條垂直線
  Line getTheHighestVerticalLine(List<Line> verticalLines) {
    Line highest = verticalLines[0];

    for (var i = 1; i < verticalLines.length; i++) {
      if (verticalLines[i].p2.y > highest.p2.y) {
        highest = verticalLines[i];
      }
    }

    return highest;
  }

  //還沒到終點時
  bool notReachEndPoint(Node currentPosition, Node endPoint) {
    return isSameNode(currentPosition, endPoint) == false;
  }

  /// 計算起點到終點的頂點路徑
  List<Node> collectNodePath() {
    //從原點開始走
    Node currentPosition = Node(0, 0);

    //初始方向為無
    Direction currentDirection = Direction.none;

    //起點到終點的頂點路徑(記錄用)
    List<Node> answerPath = [Node(0, 0)];

    //紀錄初始/上一輪的方向
    Direction lastDirection = currentDirection;

    //終點
    Node endPoint = Node(xCoordinateOfVerticalLines.last, 0);

    //當還沒到終點時
    while (notReachEndPoint(currentPosition, endPoint)) {
      //根據目前位置，判斷下個前進位置的方向
      Direction nextDirection =
          calculateNextDirection(currentPosition, lastDirection);

      switch (nextDirection) {
        case Direction.up:

          //計算上方的終點位置
          Node nextPosition = calculateNextPositionInUp(currentPosition);

          //更新現在位置
          currentPosition = nextPosition;

          //紀錄相交頂點
          answerPath.add(currentPosition);

          break;
        case Direction.right:

          //計算右方的終點位置
          Node nextPosition = calculateNextPositionInRight(currentPosition);

          //更新現在位置
          currentPosition = nextPosition;

          //紀錄相交頂點
          answerPath.add(currentPosition);

          //若上一輪是向右
          if (lastDirection == Direction.right) {
            //刪除中間節點(在邊上而不在轉角的頂點)
            answerPath.removeAt(answerPath.length - 2);
          }

          break;
        case Direction.down:

          //計算下方的終點位置
          Node nextPosition = calculateNextPositionInDown(currentPosition);

          //更新現在位置
          currentPosition = nextPosition;

          //紀錄相交頂點
          answerPath.add(currentPosition);

          if (lastDirection == Direction.down) {
            //刪除中間節點(在邊上而不在轉角的頂點)
            answerPath.removeAt(answerPath.length - 2);
          }

          break;
        default:
          throw "發生錯誤";
      }

      //紀錄本輪的方向
      lastDirection = nextDirection;
    }

    return answerPath;
  }
}
