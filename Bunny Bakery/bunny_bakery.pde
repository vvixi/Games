// puzzle matching game in P3 by vvixi
// 
// swap horizontally: left click
// swap vertically: right click

int scoreTxt = 33;
int clicks = 0, chain = 0, boardSize = 9;
int cols = 3, rows = 3, numTreats = 5;
IntList boardState = new IntList(boardSize);
boolean selected, visible=true, titleScreen = true;
PFont font;
float blk, offs, rand;
PImage [] dish = new PImage[7];
PImage wood = new PImage();
PImage chainIco = new PImage();
int score;
ParticleSystem ps;
//int [] boardState = new int[boardSize];
Cell[][] board = new Cell[cols][rows];

void setup() {
  font = createFont("assets/led_display-7.ttf", 10);
  textFont(font);
  rand = random(1);
  stroke(200);
  blk = width/3;
  offs = blk/2;
  size(310, 340);
  background(200, 160, 90);
  wood = loadImage("assets/wood_tex1.png");
  wood.resize(128, 0);
  chainIco = loadImage("assets/chain.png");
  chainIco.resize(18, 0);

  dish[0] = null;
  dish[1] = loadImage("assets/CarrotCake.png");
  dish[2] = loadImage("assets/ChocolateCake.png");
  dish[3] = loadImage("assets/CherryShortcake.png");
  dish[4] = loadImage("assets/CookieCheesecake.png");
  dish[5] = loadImage("assets/Tirimasu.png");
  dish[6] = loadImage("assets/LemonCake.png");
  
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      //image(wood, i * 100, j * 100+40);
      board[i][j] = new Cell(i*100, j*100, 100, 100);
      
      // board array contains cell object which has a spot that holds the int referring to dessert image
      board[i][j].img = int(random(numTreats));
      ps = new ParticleSystem(new PVector((i*100)/100, ((j*100)/100)+10));
    }
  }
}
void title() {
  fill(80, 60, 35);
  rect(0, 0, width, height);
  image(dish[5], width/2, height/2+50);
  fill(220);
  textSize(66);
  text("Bunny", 20, height/2-50);
  text("Bakery", 30, height/2);
  textSize(16);
  text("Click to begin", width/2-80, height-50);
  text("left click / right click", 10, height-25);
}
  
void score() {
  fill(220);
  textSize(scoreTxt);
  text(String.valueOf(score), 12, 28); 
  text("X"+ String.valueOf(chain), width-74, 26);
}

void draw() {
  background(80, 60, 35);
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      image(wood, x * 128, y * 120+100);
      //image(wood, x * 100+55, y * 100+90);
    }
  }
  image(chainIco, width-15, 20);
  
  // scale images
  for (int i = 1; i < dish.length; i++) {
    if (visible) {
      dish[i].resize(96, 0);
    } else {
      dish[i].resize(1, 0);
    }
    
  }
  //background(200, 180, 90);
  
  if (frameCount % 60 == 0) { 
    // test for matches
    // check for horizontal matches
    if (board[0][0].img == board[1][0].img && board[1][0].img == board[2][0].img) {
      println("match horizontal top");
      visible = false;
      // spawn new treats in these spaces
      if (!visible) {
        visible = true;
        spawnTreat(1, 0, false);
      }
    }
    if (board[0][1].img == board[1][1].img && board[1][1].img == board[2][1].img) {
      println("match horizontal middle");
      visible = false;
      // spawn new treats
      if (!visible) {
        visible = true;
        spawnTreat(0, 1, false);
      }
    } else if (board[0][2].img == board[1][2].img && board[1][2].img == board[2][2].img) {
      println("match horizontal bottom");
      visible = false;
      // spawn new treats
      if (!visible) {
        visible = true;
        spawnTreat(1, 2, false);
      }
    }
    // check for vertical matches
    else if (board[0][0].img == board[0][1].img && board[0][1].img == board[0][2].img) {
      println("match vertical left");
      visible = false;
      // spawn new treats
      if (!visible) {
        visible = true;
        spawnTreat(0, 0, true);
      }
    } else if (board[1][0].img == board[1][1].img && board[1][1].img == board[1][2].img) {
      println("match vertical middle");
      visible = false;
      // spawn new treats
      if (!visible) {
        visible = true;
        spawnTreat(1, 0, true);
      }
    }
    else if (board[2][0].img == board[2][1].img && board[2][1].img == board[2][2].img) {
      println("match vertical right");
      visible = false;
      // spawn new treats
      if (!visible) {
        visible = true;
        spawnTreat(2, 0, true);

      }
    } 
    
  }

  for (int i =0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {

      imageMode(CENTER);
      image(dish[board[i][j].img+1], i*blk+offs, j*blk+offs+15);
      checkMouse(board[i][j]);
    }
  } 
  ps.run();
  score();
  if (titleScreen) {
    title();
  }
}

public void spawnTreat(int _row, int _col, Boolean _flipIter) {
  // boolean moves the iterator between row or col in grid

  if (clicks < 2) { 
    chain += 1;     
  } else { chain = 0; }
  score += 100 + (chain * 50);
  
  for (int i = 0; i < 3; i++) {
    if (!_flipIter) {
      for (int k = 0; k < 50; k++) {
        ps.addParticle(new PVector(board[i][_col].x+50, board[i][_col].y+60));
      }
      if (int(random(2)) == 1) {
        board[i][_col].img = int(random(numTreats));
      } else { board[i][_col].img = board[int(random(3))][int(random(3))].img;
      }
    } else {
      for (int k = 0; k < 50; k++) {
        ps.addParticle(new PVector(board[_row][i].x+50, board[_row][i].y+60));
      }
      if (int(random(2)) == 1) {
        board[_row][i].img = int(random(numTreats));
      } else { board[_row][i].img = board[int(random(3))][int(random(3))].img;
      }
    }
  }
  clicks = 0;
  scoreTxt = 33;
}

void checkMouse(Cell a) {
  if (mousePressed) {
    if (!selected) {
      
      int tmp = a.img;
      if (mouseButton == LEFT && mouseX > a.x && mouseX < a.x+a.w && mouseY > a.y && mouseY < a.y+a.h) {
        if (titleScreen) { titleScreen = false; }
        //a.state = 2;
        clicks += 1;
        // swap left 
        
        // test if x is >= 0, ie col zero or greater
        if (int(a.x/100)-1 >= 0) {
          a.img = board[int((a.x/100)-1)][int(a.y/100)].img;
          board[int((a.x/100)-1)][int(a.y/100)].img = tmp;
          selected = true;

        } else {
          a.img = board[int((a.x/100)+1)][int(a.y/100)].img;
          board[int((a.x/100+1))][int(a.y/100)].img = tmp;
          selected = true;
        }
      } // switch the y cells
      else if (mouseButton == RIGHT && mouseX > a.x && mouseX < a.x+a.w && mouseY > a.y && mouseY < a.y+a.h) {
        //a.state = 0;
        clicks += 1;
        //int tmp = a.img;
        if (int(a.y/100)-1 >= 0) {
          a.img = board[int(a.x/100)][int((a.y/100)-1)].img;
          board[int(a.x/100)][int((a.y/100)-1)].img = tmp;
          selected = true;
        } else {
          a.img = board[int(a.x/100)][int((a.y/100)+1)].img;
          board[int(a.x/100)][int((a.y/100)+1)].img = tmp;
          selected = true;
        }
      }
      
    } 
  } else { selected = false; }
}
// needs review / consolidation
class Cell {
  float x;
  float y;
  float w;
  float h;
  int img;

  Cell (float _x, float _y, float _w, float _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    
  }
  void display() {

    fill(255);
    rect(x,y-blk,blk,blk);
  }
}

// particles
class Particle {
  PVector pos;
  PVector velo;
  PVector accel;
  float life;
  
  Particle(PVector l) {
    accel = new PVector(0, 0.005);
    velo = new PVector(random(-1, 1), random(-1, 1));
    pos = l.copy();
    life = 255.0;
  }
  void run() {
    update();
    display();
  }
  
  void update() {
    velo.add(accel);
    pos.add(velo);
    life -= 3.0;
  }
    
  void display() {
    stroke(255, life);
    rect(pos.x, pos.y, random(2,6), random(2, 6));
  }
  
  boolean isDead() {
    if (life < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  
  ParticleSystem(PVector pos) {
    origin = pos.copy();
    particles = new ArrayList<Particle>();
  }
  
  void addParticle(PVector _orig) {
    //particles.add(new Particle(origin));
    particles.add(new Particle(_orig));
  }
  
  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}
