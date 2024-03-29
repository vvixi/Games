// Space Invaders clone in P3 by vvixi
// improved hit detection on enemies
// improved particle effects
// todo: additional enemy movement patterns
// power ups need improvement

import processing.sound.*;
SoundFile[] sounds = new SoundFile[5];

float t, blk, offs, noise;
int i, row=10, col=10, score, grdSz, wave=-1, curLev=0, start, timeElapsed;
ArrayList<Laser> lasers = new ArrayList<Laser>();
ArrayList<Alien> aliens = new ArrayList<Alien>();
ArrayList<PowerUp> powerup = new ArrayList<PowerUp>();
Player player;
PFont font;
PImage bg;
ParticleSystem ps;
ParticleSystem psP;

private state _state = state.GAMEOVER;

public enum state {
  GAMEOVER,
  TITLE,
  ROUNDSTART,
  PLAY,
  
}

void setup() {
  background(0);
  Sound s = new Sound(this);
  //s.list(); // you may need to choose a dif device number for your soundcard below
  // uncomment above to list your available devices
  s.outputDevice(1);
  sounds[0] = new SoundFile(this, "assets/pew.wav");
  sounds[1] = new SoundFile(this, "assets/powerup.wav");
  sounds[2] = new SoundFile(this, "assets/enemy_death.wav");
  sounds[3] = new SoundFile(this, "assets/player_hit.wav");
  sounds[4] = new SoundFile(this, "assets/player_death.wav");
  
  font = createFont("assets/moonhouse.ttf", 128);
  textFont(font);
  size(700, 700);
  frameRate(32);
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
void spawn_powerup(int _locX, int _locY) {
  powerup.add(new PowerUp(_locX, _locY));
}

void keyPressed() {
  player.keyPressed();
}

Boolean timer(int _wait) {
  int wait = _wait;
  timeElapsed = millis() - start;
  if (timeElapsed > wait) {
    return true;
  }
  return false;
}
void draw() {

  bg = loadImage("assets/sb3.png");
  //bg = loadImage("assets/sb" + wave + ".png");
  bg.resize(700, 700);
  switch(_state) {
    case TITLE:

      background(bg);
      textSize(64);
      fill(255);
      text("E A R T H", 130, height/3); 
      textSize(48);
      text("I N T R U D E R S", 100, height/3+50);
      textSize(20);
      text("Move: Left and Right Arrows", 100, height-100);
      text("Shoot: Up Arrow", 100, height-120);
      break;

    case GAMEOVER:

      textSize(28);
      fill(255);
      text("G  A  M  E    O  V  E  R", width/3, height/2); 
      break;
      
    case ROUNDSTART:
      // this mode is the setup before round start

      if (timer(2000)) {
        
        spawn_aliens();
        start = millis();

        _state = state.PLAY;
      }

      textSize(28);
      fill(255);
      text("W A V E  "+wave, width/2-80, height/2); 
      break;
      
    case PLAY:
      // this mode indicates round is started
      background(bg);
      if (aliens.size()-1 == 0) { 

        start = millis();
        if (wave < 6) {
          wave++;   
        } else {
          wave = int(random(1,6));
        }
        start = millis();
        lasers.clear();
        _state = state.ROUNDSTART; 
      }
      
      // decoupled from aliens loop, fixes laser sizing/speed bug
      for (int j = 0; j < lasers.size(); j++) {
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
        if (alien.xpos == player.xpos && alien.ypos == player.ypos) { player.hit(); }
        if (int(alien.ypos) == 8) { player.death(); }
        switch(wave) {
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
            alien.moveMode = "descending8";
            break;
          case 5:
            alien.moveMode = "aggro";
            break;
          default:
            alien.moveMode = "static";
            break;
        }
        for (int k = 0; k < powerup.size(); k++) {
          PowerUp powup = powerup.get(k);
          powup.update();
          powup.display();
          
          if ((int(powup.ypos) == int(player.ypos)) && (int(powup.xpos) == int(player.xpos))) {
            sounds[1].play();
            if (player.selectedLaser < 2) {
              player.selectedLaser += 1;
            }
            powerup.remove(powup);
          }
        }
        alien.display();
        alien.update();
        // for debugging hitboxes
        //rect(alien.xpos*blk, alien.ypos*blk, blk, blk);
        for (int j = 0; j < lasers.size(); j++) {
          Laser las = lasers.get(j);

          if (las.type == "player") {

            if ((int(las.ypos) == int(alien.ypos)) && (las.xpos > int(alien.xpos) && las.xpos < alien.xpos+.65)) {
              // timer for particle effect
              ps = new ParticleSystem(new PVector((alien.xpos*blk)+offs/2, (alien.ypos*blk)+offs/2));
              sounds[2].play();
              
              for (int t =0; t < 60; t++) {
                ps.addParticle();
              }
              // spawn powerups
              if (random(200) > 198) {
                spawn_powerup(int(alien.xpos), int(alien.ypos));
              }
              lasers.remove(j);
              if (aliens.size()-1 > 0) {
                aliens.remove(i);
                score+=30;
                
              }
              
            }
              
          } else if (las.type == "enemy") 
            if ((int(las.ypos) == int(player.ypos)) && (int(las.xpos) == int(player.xpos))) {

              player.hit();
              lasers.remove(j);
                           
            } else if (las.ypos < -1 || _state != state.PLAY) { lasers.remove(j); 
          }   
        }      
      }
      fill(200);
      textSize(28);
      text("SCORE: "+ String.valueOf(score), 12, 28); 
      player.display();
      if(ps != null) {
        ps.run();
      }
      break;
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
    //ps = new ParticleSystem(new PVector((xpos*blk)+offs, (ypos*blk)+offs));
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
    if (_state == state.PLAY) {
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
      if (xpos > 9) { dir = -1; ypos += .5; spd += .0025; }
      if (xpos < 0) { dir = 1; ypos += .5; }


    }   
    if (moveMode == "loop") {
      if (xpos > 9) { dir = -1; ypos += .5; spd += .0025; }
      if (xpos < 0) { dir = 1; ypos -= .5; }

    }   
    if (moveMode == "line") {
      if (xpos > 9 || xpos < 0) { dir *= -1; spd+= .0025; }
      
    }   
    if (moveMode == "aggro") {
      dir = 0;
      ypos += .005;
      
    }
    if (moveMode == "descending8") {
      if (dir == 0) { dir = 1; }
      if (xpos > 9 || xpos < 0) { dir *= -1; spd += .0025; ypos += .5;}
      if (ypos > 6 &&  xpos > 9 || ypos < 0 && xpos < 0) { ypos *= -1; }

    }
    if (moveMode != "static") {
      xpos+=dir*spd;
    }
  }
  
}
class Laser {
  float xpos, ypos, spd=.4;
  int pixelsize = 4;
  String type;
  String[][] sprite = {{

    "0012000",
    "0012000",
    "0012000",
    "0012000",
    "0012000",
    "0012000"},
  {
    "0112110",
    "0112110",
    "0112110",
    "0112110",
    "0112110",
    "0112110"},
  {
    "1122211",
    "1122211",
    "1122211",
    "1122211",
    "1122211",
    "1122211"}};

  Laser(float _startX, float _startY, String _type) {
  xpos = _startX; ypos = _startY; type = _type;
  }
  void display() {
    String row = (String) sprite[0][0];
    noStroke();
    // draw sprite
    for (int i = 0; i < 6; i++) {
      if (type == "player") {
        row = (String) sprite[player.selectedLaser][0];
      } 
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
  }
  // adjust laser direction
  void update() {
    if (type == "enemy") { ypos -= -spd;
    } else { 
    ypos -= spd; }      
  }
}

class Player {
  Boolean hitflash;
  int hfOpacity = 255;
  float xpos, ypos;
  int health, selectedLaser;
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
    health = 2;
    selectedLaser = 0;
    hitflash = false;
    
  }
  
  
  void display() {
    fill(255, 0, 0);
    xpos = constrain(xpos, 0.0, 9.0);
    // draw sprite
    noise+=.2;
    float r = noise(noise) * 255;
    stroke(0, 100, 245);

    psP = new ParticleSystem(new PVector((xpos*blk)+blk/2, (ypos*blk)+blk/2));
    int pixelsize = 7;
    for (int i = 0; i < sprite.length; i++) {
      String row = (String) sprite[i];
      for (int j = 0; j < row.length(); j++) {
        if (row.charAt(j) == '1') {
          fill(0, 240, 100);
          if (hitflash) {
            
            fill(255, 0, 0, hfOpacity);
            hfOpacity--;
            if (hfOpacity == 80) {
              player.hitflash = false;
              hfOpacity = 255;
            }
          } 
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
        // make sure player is allowed to shoot
        if (_state == state.PLAY && player.health >= 0) {
          
          playerShoot();
        
        // start round if player shoots on Title screen or Game Over
        } else if (_state == state.TITLE) {
          start = millis();
          _state = state.ROUNDSTART; aliens.clear(); lasers.clear(); health = 2; score = 0; wave = 0;

        } else if (_state == state.GAMEOVER) {
          
          //int wait = 2000;
          //timeElapsed = millis() - start;
          if (timer(2000)) {
            _state = state.TITLE;
          }

        }
      }
    }
  }
  void playerShoot() { 
    float x = player.xpos+.25;
    sounds[0].play();
    lasers.add(new Laser(x, player.ypos, "player")); 
  }
  void hit() { 
    sounds[3].play();
    hitflash = true;
    if (health>0) { 
      health-=1; 
    } else { 
      death();
      start = millis();
    }
  }

  void death() {
    sounds[4].play();
    // timer for particle effect
    for (int t =0; t < 120; t++) {
      psP.addParticle();
      psP.run();
      if (t == 119) {
        _state = state.GAMEOVER;
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
    accel = new PVector(0, 0);
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
    life -= 1.0;
  }
    
  void display() {
    stroke(255, life);
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

class PowerUp {
  float xpos, ypos, spd=0.005;
  String moveMode;
  String[] sprite = {
    "00000000000",
    "00111111000",
    "00100000100",
    "00100000010",
    "00111111100",
    "00100000000",
    "00100000000",
    "00100000000"};
  PowerUp (float _xpos, float _ypos) {
    xpos = _xpos;
    ypos = _ypos;
  }
  void display() {
    //draw sprite
    stroke(0, 100, 245);
    fill(200, 50, 0);
    for (int i = 0; i < sprite.length; i++) {
      String row = (String) sprite[i];
      for (int j = 0; j < row.length(); j++) {
        if (row.charAt(j) == '1') {
          fill(200, 100, 0);
          rect(xpos*blk+(j * 12)/2, ypos*blk+(i * 8)/2, 6, 4);
        } else if (row.charAt(j) == '0') {
          fill(0, 0, 200);
          rect(xpos*blk+(j * 12)/2, ypos*blk+(i * 8)/2, 6, 4);
        }
      }
    }

  }
  void update() {
    ypos += spd;     
  }
  
}
