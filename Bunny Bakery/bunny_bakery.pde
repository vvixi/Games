// puzzle matching game in P3 by vvixi
// 
// this update adds sound
// swap horizontally: left click
// swap vertically: right click
int ringSz = 0, sz, timeElapsed;
int scoreTxt = 33;
int clicks = 0, chain = 0, boardSize = 16;
int cols = 4, rows = 4, numTreats = 7;
IntList boardState = new IntList(boardSize);
boolean selected, visible=true, titleScreen = true;
PFont font;
float blk, offs, rand, rotation;
PImage [] dish = new PImage[8];
PImage wood = new PImage();
PImage chainIco = new PImage();
int score;
ParticleSystem ps;
Cell[][] board = new Cell[cols][rows];
import processing.sound.*;
SoundFile[] sounds = new SoundFile[5];

void setup() {
  Sound s = new Sound(this);
  //s.list(); // you may need to choose a dif device number for your soundcard below
  // uncomment above to list your available devices
  s.outputDevice(1);
  sounds[0] = new SoundFile(this, "assets/chain1.wav");
  sounds[1] = new SoundFile(this, "assets/chain2.wav");
  sounds[2] = new SoundFile(this, "assets/chain3.wav");
  sounds[3] = new SoundFile(this, "assets/chain4.wav");
  sounds[4] = new SoundFile(this, "assets/snap.wav");

  font = createFont("assets/led_display-7.ttf", 10);
  textFont(font);
  rand = random(1);
  stroke(200);
  blk = width/cols;
  sz = int(blk/3);
  offs = blk/2;
  size(620, 680);
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
  dish[7] = loadImage("assets/Cinnamonroll.png");
  
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      board[i][j] = new Cell(i*blk, j*blk, blk, blk);
      
      // board array contains cell object which has a spot that holds the int referring to dessert image
      board[i][j].img = int(random(numTreats));
      ps = new ParticleSystem(new PVector((i*blk)/blk, ((j*blk)/blk)+10));
    }
  }
}
void title() {
  fill(80, 60, 35);
  rect(0, 0, width, height);
  image(dish[5], width/2, height/2+50);
  fill(220);
  textSize(99);
  text("Bunny", 20, height/4);
  text("Bakery", 60, height/4+100);
  textSize(16);
  text("Click to begin", width/2-80, height-120);
  text("left click: swap horizontal", 10, height-55);
  text("right click: swap vertical", 10, height-25);
}
  
void score() {
  fill(220);
  textSize(scoreTxt);
  text(String.valueOf(score), 12, 28); 
  text("X"+ String.valueOf(chain), width-94, 26);
}
void spinner(float _locx, float _locy) {
  fill(255);
  pushMatrix();
  translate(_locx*blk-80, _locy*blk-40);
  rotate(rotation);
  rect(0, 0, sz, sz);
  popMatrix();
  rotation+=1;
  sz+=1;
  if (sz > blk*2) {
    sz = 0;
  }
  
}
void checkMatch() {
  for (int i = 0; i < 1; i++ ) {
    for (int col = 0; col < cols; col++) {
      // add special cases like clearing entire board or multiple matches
      
      
      // horizontal matches of 3 or 4 pieces
      if (board[i][col].img == board[i+1][col].img && board[i+1][col].img == board[i+2][col].img && board[i+2][col].img == board[i+3][col].img) {
        visible = false;
        spawnTreat(i, i+3, i, col, false);
        
      }else if (board[i][col].img == board[i+1][col].img && board[i+1][col].img == board[i+2][col].img) {
        visible = false;
        spawnTreat(i, i+2, i, col, false);
        
      } else if (board[i+1][col].img == board[i+2][col].img && board[i+2][col].img == board[i+3][col].img) {
        visible = false;
        spawnTreat(i+1, i+3, i, col, false);
      }
      // vertical matches of 3 or 4 pieces
      // change iterator to cols
      int row = col;
      if (board[row][i].img == board[row][i+1].img && board[row][i+1].img == board[row][i+2].img && board[row][i+2].img == board[row][i+3].img) {
        visible = false;
        spawnTreat(i, i+3, row, i, true);
        
      }else if (board[row][i].img == board[row][i+1].img && board[row][i+1].img == board[row][i+2].img) {
        visible = false;
        spawnTreat(i, i+2, row, i, true);
      
      } else if (board[row][i+1].img == board[row][i+2].img && board[row][i+2].img == board[row][i+3].img) {
        visible = false;
        spawnTreat(i+1, i+3, row, i, true);
      }
    }
  }
}


void draw() {
  background(80, 60, 35);
  for (int x = 0; x < cols*2; x++) {
    for (int y = 0; y < rows*2; y++) {
      image(wood, x * 128, y * 120+blk);
    }
  }
  image(chainIco, width-15, 20);
  
  // scale images
  for (int i = 1; i < dish.length; i++) {
    if (visible) {
      dish[i].resize(152, 0);
    } else {
      dish[i].resize(1, 0);
    }
    
  }
  
  if (frameCount % 32 == 0) { 
    checkMatch();
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

public void spawnTreat(int _start, int _end, int _row, int _col, Boolean _flipIter) {
  // boolean moves the iterator between row or col in grid
  
  if (clicks < 2) { 
    chain += 1;     
    sounds[chain%4].play();
  } else { chain = 0; }
  score += blk + (chain * 50);
  if (!visible) {
    visible = true;
  }
  for (int i = _start; i < _end+1; i++) {
    if (!_flipIter) {
      for (int j = 0; j < _end+1; j++) {
        spinner(j, _col+1);
      }
      sounds[4].play();
      for (int k = 0; k < 50; k++) {
        ps.addParticle(new PVector(board[i][_col].x+blk/2, board[i][_col].y+blk/2));
      }
      if (int(random(2)) == 1) {
        board[i][_col].img = int(random(numTreats));
      } else { board[i][_col].img = board[int(random(3))][int(random(3))].img;
      }
    } else {
      for (int j = 0; j < _end+1; j++) {
        spinner(_row+1, j);
      }
      sounds[4].play();
      for (int k = 0; k < 50; k++) {
        ps.addParticle(new PVector(board[_row][i].x+blk/2, board[_row][i].y+blk/2));
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

        clicks += 1;
        // swap x cells
        // test if x is >= 0, ie col zero or greater
        if (int(a.x/blk)-1 >= 0) {
          a.img = board[int((a.x/blk)-1)][int(a.y/blk)].img;
          board[int((a.x/blk)-1)][int(a.y/blk)].img = tmp;
          selected = true;

        } else {
          a.img = board[int((a.x/blk)+1)][int(a.y/blk)].img;
          board[int((a.x/blk+1))][int(a.y/blk)].img = tmp;
          selected = true;
        }
      } // swap y cells
      else if (mouseButton == RIGHT && mouseX > a.x && mouseX < a.x+a.w && mouseY > a.y && mouseY < a.y+a.h) {
        
        clicks += 1;
        if (int(a.y/blk)-1 >= 0) {
          a.img = board[int(a.x/blk)][int((a.y/blk)-1)].img;
          board[int(a.x/blk)][int((a.y/blk)-1)].img = tmp;
          selected = true;
        } else {
          a.img = board[int(a.x/blk)][int((a.y/blk)+1)].img;
          board[int(a.x/blk)][int((a.y/blk)+1)].img = tmp;
          selected = true;
        }
      }
      
    } 
  } else { selected = false; }
}

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
}

// particles
class Particle {
  PVector pos;
  PVector velo;
  PVector accel;
  float life;
  
  Particle(PVector l) {
    // previous .005 and -1 , 1
    accel = new PVector(0, 0.05);
    velo = new PVector(random(-2, 2), random(-2, 2));
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
    life -= 6.0;
  }
    
  void display() {
    stroke(random(255),200, 220, life);
    rect(pos.x, pos.y, random(5,10), random(5, 10));
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
