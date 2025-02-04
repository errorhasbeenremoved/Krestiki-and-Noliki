import 'dart:io';
import 'dart:math';

class Board {
  List<String> cells;
  int size;

  Board({required this.size}) : cells = List<String>.filled(size * size, '.');

  void printBoard() {
    stdout.write("  ");
    for (int i = 1; i <= size; i++) {
      stdout.write("$i ");
    }
    print("");

    for (int i = 0; i < size; i++) {
      stdout.write("${i + 1} ");
      var row = cells.sublist(i * size, (i + 1) * size);
      print(row.join(' '));
    }
  }

  bool isCellEmpty(int index) {
    return cells[index] == '.';
  }

  void setCell(int index, String player) {
    cells[index] = player;
  }

  String? checkWin() {
    var winningCombinations = <List<int>>[
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (var combination in winningCombinations) {
      var a = cells[combination[0]];
      var b = cells[combination[1]];
      var c = cells[combination[2]];

      if (a != '.' && a == b && a == c) {
        return a;
      }
    }
    return null;
  }

  bool isDraw() {
    return !cells.any((cell) => cell == '.');
  }

  bool isValidMove(int row, int col) {
    if (row < 0 || row >= size || col < 0 || col >= size) {
      return false;
    }
    return cells[row * size + col] == '.';
  }
}

int getComputerMove(Board board, String computerPlayer) {
  for (var i = 0; i < board.cells.length; i++) {
    if (board.isCellEmpty(i)) {
      board.setCell(i, computerPlayer);
      if (board.checkWin() == computerPlayer) {
        board.setCell(i, '.');
        return i;
      }
      board.setCell(i, '.');
    }
  }

  var humanPlayer = (computerPlayer == 'X') ? 'O' : 'X';

  for (var i = 0; i < board.cells.length; i++) {
    if (board.isCellEmpty(i)) {
      board.setCell(i, humanPlayer);
      if (board.checkWin() == humanPlayer) {
        board.setCell(i, '.');
        return i;
      }
      board.setCell(i, '.');
    }
  }

  var availableMoves = <int>[];
  for (var i = 0; i < board.cells.length; i++) {
    if (board.isCellEmpty(i)) {
      availableMoves.add(i);
    }
  }

  if (availableMoves.isNotEmpty) {
    var random = Random();
    var randomIndex = random.nextInt(availableMoves.length);
    return availableMoves[randomIndex];
  }

  return -1;
}

int getBoardSize() {
  int size;
  while (true) {
    print("Введите размер игрового поля (3-9):");
    try {
      String? input = stdin.readLineSync();
      size = int.parse(input!);
      if (size >= 3 && size <= 9) {
        break;
      } else {
        print("Недопустимый размер, пожалуйста, введите снова.");
      }
    } catch (e) {
      print("Неверный ввод. Пожалуйста, введите число от 3 до 9.");
    }
  }
  return size;
}

void playGame(bool againstComputer, int boardSize) {
  var board = Board(size: boardSize);
  var player1 = 'X';
  var player2 = 'O';
  var random = Random();
  var currentPlayer = random.nextBool() ? player1 : player2;
  print('${currentPlayer == player1 ? "Игрок 1" : "Игрок 2"} ходит первым.');
  while (true) {
    board.printBoard();
    int row = -1;
    int col = -1;
    if (currentPlayer == player1 || !againstComputer) {
      while (true) {
        print('${(currentPlayer == player1) ? "Ход Игрока 1" : "Ход Игрока 2"} (строка столбец, например 1 2):');
        String? input = stdin.readLineSync();
        try {
          List<String> moves = input!.split(' ');
          row = int.parse(moves[0]) - 1;
          col = int.parse(moves[1]) - 1;
        } catch (e) {
          print("Некорректный ввод. Пожалуйста, введите ряд и столбец (например, 1 2).");
          continue;
        }

        if (board.isValidMove(row, col)) {
          break;
        } else {
          print('Некорректный ход. Попробуйте снова.');
        }
      }
    } else {
      print('Ход Компьютера...');
      int move = getComputerMove(board, player2);
      if (move == -1) {
        print('Ничья!');
        return;
      }
      row = (move / boardSize).floor();
      col = move % boardSize;
    }

    if (row != -1 && col != -1) {
      board.setCell(row * boardSize + col, currentPlayer);
    }

    var winner = board.checkWin();
    if (winner != null) {
      board.printBoard();
      print('${winner == player1 ? "Игрок 1" : "Игрок 2"} выиграл!');
      break;
    }

    if (board.isDraw()) {
      board.printBoard();
      print('Ничья!');
      break;
    }

    currentPlayer = (currentPlayer == player1) ? player2 : player1;
  }
}

void main() {
  while (true) {
    print("Выберите режим игры:");
    print("1. Игрок против игрока");
    print("2. Игрок против компьютера");
    print("3. Выход");

    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        int boardSize = getBoardSize();
        playGame(false, boardSize);
        break;
      case '2':
        int boardSize = getBoardSize();
        playGame(true, boardSize);
        break;
      case '3':
        return;
      default:
        print("Неверный выбор. Пожалуйста, попробуйте снова.");
    }
  }
}