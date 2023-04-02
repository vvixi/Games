// breakout clone in P3 by vvixi
// todo: add sound files, fix paddle side collisions, enable powerups, level progression
boolean blocks_set = false;
int cols = 6, rows = 5;
int lives = 3, score = 0;
int timeElapsed, start;
float blk;
//Ball ball;
Powerup powerup;
Player player;
ArrayList<Ball> balls = new ArrayList<Ball>();
ArrayList<Block> blocks = new ArrayList<Block>();
String[] level = { "1111111",
                   "1000001",
                   "1111111",
                   "1000001",
                   "1111111",
                   "1000001"};
          
PFont font;
ParticleSystem ps;
import processing.sound.*;
SoundFile[] sounds = new SoundFile[4];

private state _state = state.TITLE;

public enum state {
  GAMEOVER,
  TITLE,
  PLAY,
  
}

void set_blocks() {
  // create level from level array
  //for (int i = 0; i < level.length; i++) {
  //  String row = (String) level[i];
  //  for (int j = 0; j < level.length; j++) {
  //    if (row.charAt(j) == '1') {
  //      blocks.add(new Block(i, j+1));
  //      ps = new ParticleSystem(new PVector((i*blk), ((j)*blk)));
  //    }
  //  }
  //}
  //blocks_set = true;
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      //rect(i * blk, j * blk/3, blk, blk/3);
      blocks.add(new Block(i, j+1));
      ps = new ParticleSystem(new PVector((i*blk), ((j)*blk)));
    }
  }
  blocks_set = true;
}

void setup() {
  noCursor();
  background(40);
  size(800, 600);
  //fullScreen();
  font = createFont("assets/BrokenGlass.otf", 128);
  textFont(font);
  textSize(20);
  blk = width/6;
  fill(120);
  set_blocks();
  lives = 3;
  Sound s = new Sound(this);
  //s.list(); // you may need to choose a dif device number for your soundcard below
  // uncomment above to list your available devices
  s.outputDevice(1);
  sounds[0] = new SoundFile(this, "assets/paddle.wav");
  sounds[1] = new SoundFile(this, "assets/block.wav");
  sounds[2] = new SoundFile(this, "assets/lostball.wav");
  sounds[3] = new SoundFile(this, "assets/unbreakable.wav");
  //int wait = 2000;
  
}
void mouseReleased() {
  if (_state == state.PLAY) {
    //if (!ball.launched) {
    //  ball.launched = true;
    //}
    //balls.get(0).launched = true;
    if (balls.size() > 0) {
      if (!balls.get(0).launched) {
        balls.get(0).launched = true;
        start = millis();
      }
    }
  } else if (_state == state.TITLE) {
    _state = state.PLAY;
  } else if (_state == state.GAMEOVER) {
    _state = state.TITLE;
  }
}
void load_level() {
  
}
void draw() {
  background(40);
  rectMode(CORNER);
  //for (int i = 0; i < cols; i++) {
  //  for (int j = 0; j < rows; j++) {
  //    rect(i * blk, j * blk/3, blk, blk/3);
  //  }
  //}
  
  switch(_state) {
    case TITLE:
      show_title();
      textSize(70);
      //fill(0, 100, 240);
      text("Click to play", 200, 400);
      if (!blocks_set) {
        set_blocks();
      }
      fill(0, 100, 240);
      circle(540, 370, 70);
      lives = 3;
      if (balls.size() < 1) {
        balls.add(new Ball(width/2, height -height/12));
      }
      player = new Player(width/2, height-30);
      //powerup = new Powerup(4 * blk, 0 * blk);
      break;
    
    case PLAY:
      for (int i = 0; i < blocks.size(); i++) {
        Block bk = blocks.get(i);
        bk.display();
      }
      if (blocks.size() == 0) {
        set_blocks();
      }
      for (int j = 0; j < balls.size(); j++) {
        Ball bal = balls.get(j);
        bal.update();
        bal.display();
      }
      powerup.display();
      powerup.update();
      player.update();
      player.display();
      textSize(35);
      text("S C O R E : "+ String.valueOf(score), 50, 30);
      for (int i = 0; i < lives; i++) {
        circle(width - 70 + (i * 20), 20, 10);
      }
      ps.run();
      break;

      
    case GAMEOVER:
      blocks.clear();
      blocks_set = false;
      fill(200);
      textSize(height/8);
      text("G A M E  O V E R", 200, height/2);
      break;
  }
  
  
  
  
}
void show_title() {
  textSize(180);
  text("Break Room", 110, 200);
  if (frameCount % 3 == 0) {
    fill(255);
  } else {
    fill(200);
  }
}

class Ball {
  int num = 20;
  int[] x = new int[num];
  int[] y = new int[num];
  int indexPos = 0;
  String type = "standard";
  float posx, posy;
  int sz;
  int xspd, yspd;
  boolean launched;
  int count = 1;
  
  Ball(float _x, float _y) {
    //posx = width/2;
    //posy = height -height/12;
    posx = _x;
    posy = _y;
    sz = 10;
    xspd = 5;
    yspd = 5;
    launched = false;
  }
  
  void update() {

    if (!launched) {
      posx = player.posx;
      posy = player.posy - 20;
    }
    if (launched) {
      posx += xspd;
      posy += yspd;
    }
    if (posx > width || posx < 0) {
      xspd *= -1;
    }
    if (posy < 0) {
      yspd *= -1;
    }
    // count needs fixed
    if (posy > height) {
      sounds[2].play();
      balls.get(0).type = "standard";
      launched = false;
      if (count < 2) {
        lives -= 1;
      } else {
        count -= 1;
      }
      if (lives < 1) {
        _state = state.GAMEOVER;
      }
    }
    //circle(player.posx - player.w/2, player.posy, 10);
    // collision with paddle, needs troubleshooting
    for (int j = 0; j < balls.size(); j++) {
      Ball ball = balls.get(j);
      
      // test for which side of paddle the ball hits
      if (ball.posy > player.posy -player.h && ball.posy < player.posy + player.h) {
        if (ball.posx > player.posx - player.w / 2 && ball.posx < player.posx + player.w / 2) {     
          sounds[0].play();
          yspd *= -1;
        }
        
        // detect hitting very edge of paddle, needs work
        if (ball.posx < player.posx - player.w / 2 - sz && ball.posx > player.posx + player.w /2 + sz) {
          sounds[0].play();
          xspd *= -1;
          yspd *= -1;
        }
      }
      // collision with blocks
      for (int i = 0; i < blocks.size(); i++) {
        Block bk = blocks.get(i);
        
        // if ball is at the same y location as brick
        if (ball.posy > bk.posy * blk/3 && ball.posy < bk.posy * blk/3 + blk/3) {
        // if ball is within the length of the block
          if (ball.posx > bk.posx * blk && ball.posx < bk.posx * blk + blk) {
            if (ball.type != "big") {
              sounds[1].play();
              yspd *= -1;
            }
            for (int k = 0; k < 3; k++) {
              ps.addParticle(new PVector(bk.posx * blk + blk /2, bk.posy * blk / 3 + blk /3 -15));
            }
            blocks.remove(bk);
            score += 150;
  
          
          } 
          // collision with left side of block, then right
          if (ball.posx < bk.posx * blk && ball.posx > bk.posx * blk - ball.sz || ball.posx > bk.posx * blk + blk && ball.posx < bk.posx * blk + blk + ball.sz) {
            if (ball.type != "big") {
              sounds[1].play();
              xspd *= -1;
            }
  
            for (int k = 0; k < 3; k++) {
              ps.addParticle(new PVector(bk.posx * blk + blk /2, bk.posy * blk / 3 + blk /3 -15));
            }
            blocks.remove(bk);
            score += 150;
          
          }
        }   
      }
    }
        
  }
  
  void display() {
    //fill(0, 100, 240);
    
    if (type == "standard") {
      sz = 10;
      noStroke();
      fill(180);
      circle(posx, posy, sz);
      fill(250);
      circle(posx+2, posy-2, sz-6);
    }
    if (type == "multi") {
      //sz = 10;
      //noStroke();
      //fill(180);
      //circle(posx, posy, sz);
      //fill(250);
      //circle(posx+2, posy-2, sz-6);
      ////if (launched) {
      //// needs fixed
      //int wait = 400;
      //timeElapsed = millis() - start;
      //if (timeElapsed > wait) {
      //  if (balls.size() < 2) {
      //    balls.add(new Ball(random(3) + posx, posy - random(10)));
      //    balls.get(0).launched = true;
      //    balls.get(1).launched = true;
      //  }
      //}
    }
    if (type == "big") {
      sz = 35;
      noStroke();
      fill(180);
      circle(posx, posy, sz);
      fill(250);
      circle(posx+6, posy-6, sz-25);
    }
    if (type == "fire") {
      sz = 12;
      stroke(240, 0, 0);
      fill(240, 100, 0);
      x[indexPos] = int(posx);
      y[indexPos] = int(posy);
      indexPos = (indexPos + 1) % num;
      for (int i = 0; i < num; i++) {
        int pos = (indexPos + i) % num;
        float radius = (num + i) / 2.0;
        if (indexPos == 0) {
          fill(180);
        } else {
          fill(240, 200, 0);
        }
        ellipse(x[pos], y[pos], radius, radius);
      }
      fill(180);
      circle(posx, posy, sz);
    }
  }
}

class Player {
  int posx, posy;
  //int dir;
  int sz;
  float w, h;
  boolean alive;
  boolean flash = false;
  Player(int _posx, int _posy) {
    posx = _posx;
    posy = _posy;
    w = width/8;
    h = 15;
    alive = true;
  }
  
  void update() {
    posx = mouseX;
  }
  
  void display() {
    //constrain(player.posx, w, width-w);
    rectMode(CENTER);
    fill(100);
    if (flash) {
      stroke(255);
    }
    stroke(0, 100, 240);
    rect(posx, posy, w, h);
  }

}
class Powerup {
  float posx, posy;
  
  Powerup(float _x, float _y) {
    posx = _x;
    posy = _y;
  }
  
  void update() {
    posy+=5;
    // collision with player
    if (posy > player.posy -player.h && posy < player.posy + player.h) {
      if (posx > player.posx - player.w / 2 && posx < player.posx + player.w / 2) {
        balls.get(0).type = "big";
      }
    }
  }
  
  void display() {
    fill(240, 100, 0);
    for (int i = 0; i < 20; i++) {
      circle(posx+i, posy, 20);
    }
  }
  
}

class Block {
  float posx, posy;
  int c=255;
  int flash = 255;
  boolean hitflash = false;
  Block(float _posx, float _posy) {
    posx = _posx;
    posy = _posy;
  }
  
  void update() {
    
  }

  void display() {
    if (hitflash) {
      stroke(flash);
      flash--;
      if (flash == 0) {
        hitflash = false;
        flash = 255;
      }
    } else {
    stroke(0);
    }
    fill(0, 100, 240);
    rect(posx * blk, posy * blk/3, blk, blk/3);
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
    accel = new PVector(0, 0.1);
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
    life -= 8.0;
  }
    
  void display() {
    stroke(random(255),200, 220, life);
    //rect(pos.x, pos.y, random(2, 6), random(2, 6));
    triangle(pos.x-random(-10, 10), pos.y-random(-10, 10), pos.x-random(-10, 10), pos.y-random(-10, 10), pos.x-(random(-10, 10)), pos.y-(random(-10, 10)));
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
