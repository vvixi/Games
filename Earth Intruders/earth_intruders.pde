float t, blk, offs, noise;
int i, row=10, col=10, score, grdSz, mode=0, wave=1, curLev=0, start, timeElapsed;
ArrayList<Laser> lasers = new ArrayList<Laser>();
ArrayList<Alien> aliens = new ArrayList<Alien>();
//ArrayList<PowerUp> powerup = new ArrayList<PowerUp>();
Player player;
PImage bg;
ParticleSystem ps;
ParticleSystem psP;
// Space Invaders clone in P3 by vvixi
// fixed: player pos, laser pos, player hitbox, player death, gameover, health, player particles

// todo:
// needs level progression tied in with patterns, reordered
// needs additional enemies / enemy animations
// needs powerups implemented

void setup() {
  start = millis();
  size(700, 700);
  frameRate(30);
  smooth();
  grdSz = row*col;
  blk = width/col;
  offs = blk/2;
  
  player = new Player(5+offs, 9);
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
  // update to switch / case, implement -1 as Game Over
  if (mode == -1) { 
    background(bg);
    textSize(28);
    fill(255);
    text("G  A  M  E    O  V  E  R", width/2-60, height/2); 
  }
  // this mode is before round start
  if (mode == 0) {   
    
    int wait = 2000;
    timeElapsed = millis() - start;
    if (timeElapsed > wait) {
      
      spawn_aliens();
      start = millis();
      mode+=1;
    }
    bg = loadImage("assets/sb3.png");
    //bg = loadImage("assets/sb" + wave + ".png");
    bg.resize(700, 700);
    background(bg);
    textSize(28);
    fill(255);
    text("W A V E  "+wave, width/2-80, height/2); 

  }
  // this mode indicates round is started
  if (mode == 1) {
    
    //stroke(0);
    bg = loadImage("assets/sb3.png");
    //bg = loadImage("assets/sb" + wave + ".png");
    bg.resize(700, 700);
    background(bg);
    
    //print(aliens.size());
    
    if (aliens.size()-1 == 0) { 
      wave++;   
      
      start = millis();
      lasers.clear();
      mode = 0;  
    }
    
    // decoupled from aliens loop, fixes laser sizing/speed bug
    for (int j = 0; j < lasers.size()-1; j++) {
      Laser las = lasers.get(j);
      las.update();
      las.display();
    }
    //// grid lines
    //for (int x = 0; x < col; x++) {
    //  for (int y = 0; y < row; y++) {
    //    //fill(0);
    //    stroke(240);
    //    rect(x*blk, y*blk, blk, blk);
    //  }
    //}
    for (int i = 0; i < aliens.size()-1; i++) {
      //stroke(0, 100, 245);
      Alien alien = aliens.get(i);
      switch(4) {
        case 0:
          alien.moveMode = "static";
          break;
        case 1:
          alien.moveMode = "line";
          break;
        case 2:
          alien.moveMode = "loop";
          break;
        case 3:
          alien.moveMode = "snake";
          break;
        case 4:
          alien.moveMode = "aggro";
          break;
        default:
          alien.moveMode = "static";
          break;
      }

      ps = new ParticleSystem(new PVector((alien.xpos*blk)+offs, (alien.ypos*blk)+offs));
      alien.display();
      alien.update();
      //rect(alien.xpos*blk, alien.ypos*blk, blk, blk);
      for (int j = 0; j < lasers.size(); j++) {
        Laser las = lasers.get(j);
        // make the hitbox detection more universal
        //stroke(0, 100, 245);

        if (las.type == "player") {
          if ((int(las.ypos) == int(alien.ypos)) && (int(las.xpos) == int(alien.xpos))) {
            stroke(245);
            //if (int(las.ypos) < int(alien.ypos+blk) && int(las.ypos) > int(alien.ypos-blk) && int(las.xpos) > int(alien.xpos-blk) && int(las.xpos) < int(alien.xpos+blk)) {

            // timer for particle effect
            for (int t =0; t < 60; t++) {
            //  //rect(x*blk, y*blk, blk, blk);
              ps.addParticle();
              ps.run();
            }
            
            lasers.remove(j);
            if (aliens.size()-1 > 0) {
              aliens.remove(i);
              score+=30;
            }
          }
            
        } else if (las.type == "enemy") 
          if ((int(las.ypos) == int(player.ypos)) && (int(las.xpos) == int(player.xpos))) {
            lasers.remove(j);
            player.hit();
            
            //if (int(las.ypos) < int(alien.ypos+blk) && int(las.ypos) > int(alien.ypos-blk) && int(las.xpos) > int(alien.xpos-blk) && int(las.xpos) < int(alien.xpos+blk)) {

          } else if (las.ypos < 0 || mode != 1) { lasers.remove(j); 
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
    stroke(0, 100, 245);
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

    if (xpos == player.xpos && ypos == player.ypos) { player.hit(); }
    // make sure enemy is allowed to shoot
    if (mode == 1) {
      // hard mode
      if (random(400) > 399.5) {
        //(alien.xpos*blk)+blk/2, (alien.ypos*blk)+blk/2)
        lasers.add(new Laser(xpos+.25, ypos, "enemy"));
      }
    }
    if (dir == 0) { dir = 1; }
    if (moveMode == "static") {

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
      if (xpos > 9 || xpos < 0) { dir *= -1; spd+= .0025; }
      xpos+=dir*spd;
    }   
    if (moveMode == "aggro") {
      ypos += .005;
    }
    //xpos+=dir*spd;
  }
}
class Laser {
  float xpos, ypos, spd=.4;
  int pixelsize = 4;
  String type;
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
    noStroke();
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
    if (type == "enemy") { ypos -= -spd;
    } else { ypos -= spd; }      
  }
}

class Player {
  float xpos, ypos;
  int health;
  String[] sprite = {
    "000010000",
    "000131000",
    "000131000",
    "001131100",
    "001111100",
    "012000210",
    "020000020"};
  Player (float _xpos, float _ypos) {
    xpos = _xpos;
    ypos = _ypos;
    health = 3;
    
  }
  
  
  void display() {
    // draw sprite
    noise+=.1;
    float r = noise(noise) * 255;
    stroke(0, 100, 245);
    if (health > 0) {
      xpos = constrain(xpos, 0, 9);
      psP = new ParticleSystem(new PVector((xpos*blk)+blk/2, (ypos*blk)+blk/2));
      int pixelsize = 7;
      for (int i = 0; i < sprite.length; i++) {
        String row = (String) sprite[i];
        for (int j = 0; j < row.length(); j++) {
          if (row.charAt(j) == '1') {
            fill(0, 240, 100);
            rect(xpos*blk+(j * pixelsize), ypos*blk+(i * pixelsize), pixelsize, pixelsize);
          } else if (row.charAt(j) == '2') {
            fill(r, 40, 0); 
            rect(xpos*blk+(j * pixelsize), ypos*blk+(i * pixelsize), pixelsize, pixelsize);
          } else if (row.charAt(j) == '3') {
            fill(100, 100, 200);
            rect(xpos*blk+(j * pixelsize), ypos*blk+(i * pixelsize), pixelsize, pixelsize);
          }
        }
      } 
    } else { mode = -1; }
  }
  void keyPressed() {
    
    if(key == CODED) {
      if(keyCode == LEFT) {
        this.xpos-=1;
      }
      else if(keyCode == RIGHT) {
        this.xpos+=1;
      }
      else if(keyCode == UP) {
        // make sure player is allowed to shoot
        if (mode == 1 && player.health > 0) {
          playerShoot();
        } else if (mode == 1 && player.health >= 0) {
          mode = 0; aliens.clear(); lasers.clear(); health = 3; score = 0; wave = 1;
        }
      }
    }
  }
  void playerShoot() { lasers.add(new Laser(player.xpos+.25, player.ypos, "player")); }
  void hit() { 
    if (health>0) { health-=1; stroke(255); fill(255, 0, 0); 
    }
    if (health<=0) { death();
    }
  }
  void death() {
    // timer for particle effect
    for (int t =0; t < 120; t++) {
      psP.addParticle();
      psP.run();
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
    //fill(255, life);
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
  void draw() {
    background(0);
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
