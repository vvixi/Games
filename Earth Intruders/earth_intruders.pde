float t, blk;
int i, row=10, col=10, score, grdSz, mode=0, wave=1, curLev=0;
ArrayList<Laser> lasers = new ArrayList<Laser>();
ArrayList<Alien> aliens = new ArrayList<Alien>();
//ArrayList<PowerUp> powerup = new ArrayList<PowerUp>();
Player player;
PImage bg;
ParticleSystem ps;

// Space Invaders clone in P3 by vvixi
// fix enemy laser positioning
// laser needs fixed: it skips some places on the board
// needs level progression tied in with patterns
// needs additional enemies / enemy animations
// needs powerups implemented
// needs enemy laser collision with player
// particle system needs review
// needs refactoring and cleanup
// timer needs fixed
// scoreboard

void setup() {
  size(700, 700);
  frameRate(60);
  //smooth();
  grdSz = row*col;
  blk = width/col;
  player = new Player(5, 9);
  spawn_aliens();
}
void spawn_aliens() {
  for (int i = 1; i < 9; i++) {
    for (int j = 1; j < 4; j++) {
      aliens.add(new Alien(i, j));
    }
  }
}
void keyPressed() {
  player.keyPressed();
}
void draw() {
  if (mode == 0) {
    int time = millis();
    int start = time / 1000;
    int wait = 2000;
    //println(millis() - start);
    if (time - start >= wait) {
      //start = millis();
      //spawn_aliens();
      mode+=1;
    }
    bg = loadImage("assets/sb3.png");
    //bg = loadImage("assets/sb" + wave + ".png");
    bg.resize(700, 700);
    background(bg);
    textSize(28);
    //print(time);
    text("W A V E  "+wave, width/2-80, height/2); 

  }
  
  if (mode == 1) {
  //stroke(0);
    bg = loadImage("assets/sb3.png");
    //bg = loadImage("assets/sb" + wave + ".png");
    bg.resize(700, 700);
    background(bg);
    //print(aliens.size());
    
    if (aliens.size()-1 == 0) { 
      spawn_aliens();
      mode = 0;
      wave++;
      //spawn_aliens();
      
    }
    
    // decoupled from aliens loop, fixes laser sizing/speed bug
    for (int j = 0; j < lasers.size()-1; j++) {
      Laser las = lasers.get(j);
      las.update();
      las.display();
    }
    // grid lines
    //for (int x = 0; x < col; x++) {
    //  for (int y = 0; y < row; y++) {
    //    fill(0);
    //    stroke(240);
    //    rect(x*blk, y*blk, blk, blk);
    //  }
    //}
    for (int i = 0; i < aliens.size()-1; i++) {
      stroke(0, 100, 245);
      Alien alien = aliens.get(i);
      if (wave == 1) {
        alien.moveMode = "static";
      } else if (wave == 2) {
        alien.moveMode = "line";
      } else if (wave == 3) {
        alien.moveMode = "loop";
      } else if (wave == 4) {
        alien.moveMode = "snake";
      }
      ps = new ParticleSystem(new PVector(alien.xpos*blk, alien.ypos*blk));
      alien.display();
      alien.update();
      //println(int(alien.xpos)); // alien never reaches xpos 9
      for (int j = 0; j < lasers.size(); j++) {
        Laser las = lasers.get(j);
        
        //stroke(0, 100, 245);
        if (las.type == "player") {
          if ((int(las.ypos) == int(alien.ypos)) && (int(las.xpos) == int(alien.xpos))) {
            stroke(245);
          //if (int(las.ypos) < int(alien.ypos+blk) && int(las.ypos) > int(alien.ypos-blk) && int(las.xpos) > int(alien.xpos-blk) && int(las.xpos) < int(alien.xpos+blk)) {
            for (int t =0; t < 90; t++) {
              //rect(x*blk, y*blk, blk, blk);
              //ps = new ParticleSystem(new PVector(x*blk, y*blk));
              //stroke(0, 100, 255);
              
              ps.addParticle();
              ps.run();
            }
            
            lasers.remove(j);
            aliens.remove(i);
            score+=100;
          } else if (las.ypos < 0) { lasers.remove(j);
          }
        }
          
      }
      
    }
    fill(200);
    textSize(28);
    text("SCORE: "+ String.valueOf(score), 12, 28); 
    player.display();
  }
}
class Alien {
  float xpos, ypos, spd=0.05;
  int dir=0;
  String moveMode;
  String[] sprite = {
    "00100000100",
    "00010001000",
    "00111111100",
    "01101110110",
    "11111111111",
    "10111111101",
    "10100000101",
    "00011011000"};
  Alien (float _xpos, float _ypos) {
    xpos = _xpos;
    ypos = _ypos;
  }
  void display() {
    //draw sprite
    fill(0, 200, 200);
    for (int i = 0; i < sprite.length; i++) {
      String row = (String) sprite[i];
      for (int j = 0; j < row.length(); j++) {
        if (row.charAt(j) == '1') {
          rect(xpos*blk+(j * 12)/2, ypos*blk+(i * 8)/2, 6, 4);
        }
      }
    }

  }
  void update() {
    if (random(400) > 399.5) {
      lasers.add(new Laser(xpos, ypos, "enemy")); }
    if (dir == 0) { dir = 1; }
    if (moveMode == "static") {
      if (xpos > 9) {
        dir = -1; 
        ypos += .5;
        spd += .005;
      }
      if (xpos < 0) {
        dir = 1;
        ypos += .5;
      }
      xpos+=dir*spd;
    }   
    if (moveMode == "snake") {
      if (xpos > 9) {
        dir = -1; 
        ypos += .5;
        spd += .005;
      }
      if (xpos < 0) {
        dir = 1;
        ypos += .5;
      }
      xpos+=dir*spd;

    }   
    if (moveMode == "loop") {
      if (xpos > 9) {
        dir = -1; 
        ypos += .5;
        spd += .005;
      }
      if (xpos < 0) {
        dir = 1;
        ypos -= .5;
      }
      xpos+=dir*spd;
    }   
    if (moveMode == "line") {
      if (xpos > 9) {
        dir = -1; 
        //ypos += .5;
        spd += .005;
      }
      if (xpos < 0) {
        dir = 1;
        //ypos += .5;
        //ypos -= .5;
      }
    xpos+=dir*spd;
    //println(spd);
    }   
  }
}
class Laser {
  float xpos, ypos, spd=.4;
  int pixelsize = 4;
  String type;
  String[] sprite2 = {
    "0011100",
    "0111110",
    "0111110",
    "0011100",
    "0011100",
    "0001000"};
  String[] sprite = {
    "0112110",
    "0112110",
    "0112110",
    "0112110",
    "0112110",
    "0112110"};
  Laser(float _startX, float _startY, String _type) {
  xpos = _startX; ypos = _startY; type = _type;
  type = _type;
  }
  void display() {
    
    // draw sprite
    //stroke(245);
    for (int i = 0; i < sprite.length; i++) {
      String row = (String) sprite[i];
      for (int j = 0; j < row.length(); j++) {
        if (row.charAt(j) == '1') {
          if (type == "player") {
            fill(100, 0, 200);
          } else { fill(200, 80, 0); }
          rect(xpos*blk+(j * pixelsize), ypos*blk+(i * pixelsize), pixelsize, pixelsize);
        } else if (row.charAt(j) == '2') {
            fill(250);
            rect(xpos*blk+(j * pixelsize), ypos*blk+(i * pixelsize), pixelsize, pixelsize);
          
        }
      }
    }

    //stroke(0, 100, 255);
    //line(((xpos*blk)+blk/2), ypos*blk, (xpos*blk)+blk/2, (ypos*blk)-20);
  }
  void update() {
    //if (type == "enemy") { spd *= -1;
    if (type == "enemy") { ypos -= -spd;
    } else { ypos -= spd; }
    if (type == "player") {
      xpos = player.xpos; // not ideal
    }
      
  }
}
class Player {
  float xpos, ypos;
  String[] sprite = {
    "0001000",
    "0013100",
    "0013100",
    "0113110",
    "0111110",
    "1100011",
    "2000002"};
  Player (float _xpos, float _ypos) {
    xpos = _xpos;
    ypos = _ypos;
  }
  
  
  void display() {
    // draw sprite
    noStroke();
    xpos = constrain(xpos, 0, 9);
    
    int pixelsize = 6;
    //translate(xpos*blk, ypos*blk);
    for (int i = 0; i < sprite.length; i++) {
      String row = (String) sprite[i];
      for (int j = 0; j < row.length(); j++) {
        if (row.charAt(j) == '1') {
          fill(0, 240, 100);
          rect(xpos*blk+(j * pixelsize), ypos*blk+(i * pixelsize), pixelsize, pixelsize);
        } else if (row.charAt(j) == '2') {
          fill(240, 100, 0);
          rect(xpos*blk+(j * pixelsize), ypos*blk+(i * pixelsize), pixelsize, pixelsize);
        } else if (row.charAt(j) == '3') {
          fill(100, 100, 200);
          rect(xpos*blk+(j * pixelsize), ypos*blk+(i * pixelsize), pixelsize, pixelsize);
        }
      }
    }
    // draw the player ship
    //noStroke();
    //translate(xpos*blk, ypos*blk);
    //fill(255, 0, 0);
    //rect(xpos*blk, ypos*blk, blk, blk);
    //triangle(0, blk-4, blk, blk-4, blk/2, 0);
    //triangle(0, blk-4, blk, blk-4, 8, blk/2);
    //triangle(0, blk-4, blk, blk-4, blk-8, blk/2);
    //fill(0, 100, 255);
    //ellipseMode(CORNER);
    //ellipse(0+4, blk-8, blk-8, blk/10);
    //ellipse(blk/3, blk/2, blk/3, blk/4);
  }
  void keyPressed() {
    
    if(key == CODED) {
      if(keyCode == LEFT) {
        xpos-=1;
      }
      else if(keyCode == RIGHT) {
        xpos+=1;
      }
      else if(keyCode == UP) {
        lasers.add(new Laser(xpos, ypos, "player"));
      }
    }
  }
}

// particles
class Particle {
  PVector pos;
  PVector velo;
  PVector accel;
  float life;
  
  Particle(PVector l) {
    //accel = new PVector(0, 0.05);
    velo = new PVector(random(-1, 1), random(-1, 1));
    pos = l.copy();
    life = 255.0;
  }
  void run() {
    update();
    display();
  }
  
  void update() {
    //velo.add(accel);
    pos.add(velo);
    life -= 3.0;
  }
    
  void display() {
    stroke(255, life);
    fill(0, 0, 255, life);
    rect(pos.x, pos.y, 2, 2);
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
  
  void addParticle() {
    particles.add(new Particle(origin));
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
