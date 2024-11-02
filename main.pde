int cols = 10;
int rows = 30;
int blockSize = 30; //height=blocksize*cols ; width=blockSize*rows
int[][] grid = new int[cols][rows];
Tetromino currentPiece;
int dropDelay = 200; // Adjust this value to control the speed of falling blocks
int lastUpdateTime = 0;
int score = 0;

void setup() {
  size(300, 900); // Increased height for score display
  currentPiece = new Tetromino();
}

void draw() {
  background(0);
  
  // Draw grid
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (grid[i][j] != 0) {
        fill(grid[i][j]);
        rect(i * blockSize, j * blockSize, blockSize, blockSize);
      }
    }
  }
  
  // Draw score
  fill(255);
  textSize(20);
  text("Score: " + score, 10, 30);
  
  // Move and draw current piece
  if (millis() - lastUpdateTime > dropDelay) {
    currentPiece.update();
    lastUpdateTime = millis();
  }
  currentPiece.show();
}

void keyPressed() {
  if (keyCode == LEFT) {
    currentPiece.move(-1, 0);
  } else if (keyCode == RIGHT) {
    currentPiece.move(1, 0);
  } else if (keyCode == DOWN) {
    currentPiece.move(0, 1);
  } else if (key == 'e' || key == 'E') {
    currentPiece.rotateClockwise();
  } else if (key == 'q' || key == 'Q') {
    currentPiece.rotateCounterClockwise();
  }
}

class Tetromino {
  int x, y;
  int[][] shape;
  color c;
  
  Tetromino() {
    x = cols / 2 - 1;
    y = 0;
    shape = generateRandomShape();
    c = color(random(255), random(255), random(255));
  }
  
  void update() {
    if (canMove(0, 1)) {
      y++;
    } else {
      // Lock piece in place
      for (int i = 0; i < shape.length; i++) {
        int px = x + shape[i][0];
        int py = y + shape[i][1];
        if (py < 0) {
          gameOver(); // Game Over condition
          return;
        }
        grid[px][py] = c;
      }
      
      // Check for completed rows
      for (int j = rows - 1; j >= 0; j--) {
        boolean isRowFull = true;
        for (int i = 0; i < cols; i++) {
          if (grid[i][j] == 0) {
            isRowFull = false;
            break;
          }
        }
        if (isRowFull) {
          clearRow(j);
          j++; // Recheck the same row as new blocks may have moved down
          score++; // Update score
        }
      }
      
      // Create a new piece
      currentPiece = new Tetromino();
    }
  }
  
  void show() {
    fill(c);
    for (int i = 0; i < shape.length; i++) {
      int px = x + shape[i][0];
      int py = y + shape[i][1];
      rect(px * blockSize, py * blockSize, blockSize, blockSize);
    }
  }
  
  void move(int dx, int dy) {
    if (canMove(dx, dy)) {
      x += dx;
      y += dy;
    }
  }
  
  void rotateClockwise() {
    int[][] newShape = new int[shape.length][2];
    for (int i = 0; i < shape.length; i++) {
      newShape[i][0] = -shape[i][1];
      newShape[i][1] = shape[i][0];
    }
    if (canMove(0, 0, newShape)) {
      shape = newShape;
    }
  }
  
  void rotateCounterClockwise() {
    int[][] newShape = new int[shape.length][2];
    for (int i = 0; i < shape.length; i++) {
      newShape[i][0] = shape[i][1];
      newShape[i][1] = -shape[i][0];
    }
    if (canMove(0, 0, newShape)) {
      shape = newShape;
    }
  }
  
  boolean canMove(int dx, int dy) {
    return canMove(dx, dy, shape);
  }
  
  boolean canMove(int dx, int dy, int[][] testShape) {
    for (int i = 0; i < testShape.length; i++) {
      int px = x + testShape[i][0] + dx;
      int py = y + testShape[i][1] + dy;
      if (px < 0 || px >= cols || py >= rows || (py >= 0 && grid[px][py] != 0)) {
        return false;
      }
    }
    return true;
  }
  
  void clearRow(int rowIndex) {
    for (int j = rowIndex; j > 0; j--) {
      for (int i = 0; i < cols; i++) {
        grid[i][j] = grid[i][j-1];
      }
    }
    for (int i = 0; i < cols; i++) {
      grid[i][0] = 0;
    }
  }
  
  int[][] generateRandomShape() {
    int[][][] shapes = {
      {{0, 0}, {1, 0}, {0, 1}, {1, 1}}, // Square
      {{0, -1}, {0, 0}, {0, 1}, {0, 2}}, // Line
      {{0, 0}, {0, 1}, {1, 1}, {2, 1}}, // L
      {{0, 1}, {1, 1}, {2, 1}, {2, 0}}, // J
      {{0, 1}, {1, 1}, {1, 0}, {2, 0}}, // S
      {{0, 0}, {1, 0}, {1, 1}, {2, 1}}, // Z
      {{0, 1}, {1, 0}, {1, 1}, {2, 1}} // T
    };
    return shapes[int(random(shapes.length))];
  }
  
  void gameOver() {
    println("Game Over!");
    noLoop(); // Stop the game
  }
}
