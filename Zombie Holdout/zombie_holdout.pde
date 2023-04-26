// Zombie survival top down shoot-em-up game by vvixi in P3
// loosely inspired by Zombies Ate My Neighbors
//
// added performance improvements
// added minor improvements to visual style and weapons class
// some weapons need finished
// needs collisions, title screen, game over, level tilemaps
// needs state machine, dif zombie types, movement code needs cleaned up

boolean [] keys = new boolean[256];
boolean [] lastKeys = new boolean[256];
PImage player_sprite;
PImage crate_sprite;
PImage floors_sprite;
PImage walls_sprite;
PImage zombie_sprite;
PImage weapon_sprite;
PVector loc, locB;
// 10, 5
int blk = 16, offs = 8;
// 0 up, 1 right, 2 down, 3 left
int curDir = 7;
int curLevel = 1, score = 0;
int start, timeElapsed;
int cols, rows;
int AreaCols, AreaRows;

PVector up = new PVector(0, -10);
PVector upright = new PVector(10, -10);
PVector down = new PVector(0, 10);
PVector downright = new PVector(10, 10);
PVector right = new PVector(10, 0);
PVector upleft = new PVector(-10, -10);
PVector left = new PVector(-10, 0);
PVector downleft = new PVector(-10, 10);
PVector[] dirs = {up, upright, right, downright, down, downleft, left, upleft};
char keyHit = ' ';
PVector[] dropLocs = {new PVector(random(width-80, width-12), random(12, 64)), new PVector(random(20), random(60)), new PVector(12, 64, random(height-64, height-12)), new PVector(random(width-64, width-12), random(height-64, height-12))};
//Entity entity;
Player player;
Weapon weapon;
//Sprite sprite;
ParticleSystem ps;
ArrayList<Drop> drops = new ArrayList<Drop>();
ArrayList<Zombie> zombies = new ArrayList<Zombie>();
ArrayList<Stain> stains = new ArrayList<Stain>();
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
int[][] path;
private state _state = state.TITLE;

public enum state {
  GAMEOVER,
  TITLE,
  ROUNDSTART,
  PLAY,
  PAUSE 
}
PVector world2map(float _x, float _y) {
  int newX = int(_x / 16 +1);
  int newY = int(_y / 16 +2);
  path[newX][newY] = 1;
  return new PVector(newX, newY);
}

void setup() {
  //font = createFont("assets/moonhouse.ttf", 128);
  size(600, 600);
  frameRate(32);
  noStroke();
  //rectMode(CENTER);
  strokeWeight(5);
  dropWeapon();
  cols = width/blk+64;
  rows = height/blk+64;
  path = new int[rows][cols];
  player = new Player();
  //player.setup();
  //player_sprite = loadImage("assets/player.png");
  //floors_sprite = new Sprite();
  // blocked test
  
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      path[i][j] = 0;
    }
  }
  world2map(player.loc.x, player.loc.y);
  
  crate_sprite = loadImage("assets/crate.png");
  floors_sprite = loadImage("assets/ground.png");
  walls_sprite = loadImage("assets/walls.png");
  //weapon_sprite = loadImage("assets/guns.png");

  
}

void dropWeapon() {
  int randInt = int(random(0, dropLocs.length));
  drops.add(new Drop(dropLocs[randInt]));
}
  
Boolean timer(int _wait) {
  int wait = _wait;
  timeElapsed = millis() - start;
  if (timeElapsed > wait) {
    return true;
  }
  return false;
}
void drawHUD() {
  int totalFrames = 4;
  int row = 0;
  int xFrame = 0;
  int x = int(width-32);
  int y = 0;
  int sx = 1;
  int offsX = xFrame * sx; // replace 0 with mult of w
  int offsY = 0 * sx;
  int w = 16;
  int h = w;
  fill(200);
  textSize(24);
  text(String.valueOf(score), 10, 24);
  textSize(24);
  if (player.weapon.loadedAmmo < 6) {
    fill(255, 200, 0);
  }
  
  text(String.valueOf(player.weapon.loadedAmmo), width-64, 24);
  textSize(24);
  text(String.valueOf(player.weapon.totalAmmo), width-64, 54);
  copy(weapon_sprite, sx+offsX, sx+offsY, w, h, x, y, w*2, h*2);

}
void draw() {
  clear();
  if (player.weapon.totalAmmo < 12) {
    dropWeapon();
  }
  // needs replaced with floor and wall tiles
  //background(30, 30, 0);
  // grid lines for debugging
  for (int i = 0; i < cols/2; i++) {
    for (int j = 0; j < rows/2; j++) {
      //strokeWeight(1);
      //stroke(80);
      //noFill();
      fill(0);
      //rect(i * blk, j * blk, blk, blk);
      //copy(floors_sprite, 0, 0, blk+blk, blk+blk, i*blk*2, j*blk*2, blk*2, blk*2);
      copy(floors_sprite, 8, 8, blk, blk, i*blk*2, j*blk, blk*2, blk*2);
      if (path[i][j] == 1) {
        fill(50);
        //rect(i * blk, j * blk, blk, blk);
      }
    }
  }
  for (int i =0; i < stains.size(); i++) {
    Stain stain = stains.get(i);
    stain.display();
  }
  //switch(_state) {
  //  case TITLE:
  if (zombies.size() < 100 && frameCount % 32 == 0) {
    zombies.add(new Zombie(int(random(2))));
  }
  for (int j =0; j < drops.size(); j++) {
    Drop drop = drops.get(j);
    drop.display();
  }
  for (int j =0; j < zombies.size(); j++) {
    Zombie zombie = zombies.get(j);
    zombie.update();
    zombie.display();
    for (int i =0; i < bullets.size(); i++) {
      Bullet bullet = bullets.get(i);
      //println(bullet.locB.x, zombie.loc.x, bullet.locB.y, zombie.loc.y);
      if (bullet.locB.x > zombie.loc.x-10-offs && bullet.locB.x < zombie.loc.x+10+offs && bullet.locB.y > zombie.loc.y-10-offs && bullet.locB.y < zombie.loc.y+10+offs) {
        bullets.remove(i);
        ps = new ParticleSystem(new PVector((zombie.loc.x + zombie.sz/2), (zombie.loc.y + zombie.sz/2)));
        for (int t =0; t < 10; t++) {
          if (t % 2 == 0) {
            ps.addParticle();
            //ps.run();
          }
          
        }
        
        zombie.damage();
        if (zombie.health <= 0) {
          stains.add(new Stain(zombie.loc));
          zombies.remove(j);
          score += 150;
        }
      }
    }
  }
  
  for (int i =0; i < bullets.size(); i++) {
    Bullet bullet = bullets.get(i);
    bullet.update();
    bullet.display();
    if (bullet.locB.x < 0 || bullet.locB.x > width || bullet.locB.y > height || bullet.locB.y < 0) {
      bullets.remove(i);
    }


      
  }
  player.display();
  player.keyPressed();
  //println(player.loc);
  //println(curDir);
  if(ps != null) {
    ps.run();
  }
  //strokeWeight(3);

  
  //copy(weapon_sprite, sx+offsX, sx+offsY, w, h, x, y, w*2, h*2);
  drawHUD();
}

void keyPressed() {
  player.setKey(true);
}

void keyReleased() {
  player.setKey(false);
  player.keyReleased();
}
class Drop {
  // weapons drop
  PVector loc = new PVector(0, 0);
  Boolean weapon = false;
  Boolean opened = false;
  String[] weapons = { "pistol", "revolver", "shotty", "smg", "smg2", "rifle", "bazooka" };
  int selWeapon = 2;
  int sz = 12;
  
  Drop (PVector _loc) {
    loc = _loc;
    
  }
  void display() {
    if (!opened) {
      fill(120, 120, 0);
      //rect(loc.x, loc.y, 12, 12);
      //copy(crate_sprite, sx+offsX, sx+offsY, w, h, int(loc.x), int(loc.y), w*2, h*2);
      copy(crate_sprite, 0, 0, 16, 16, int(loc.x), int(loc.y), 16*2, 16*2);
      // basic collision
      if (player.loc.x >= loc.x - sz && player.loc.x <= loc.x + sz && player.loc.y >= loc.y - sz && player.loc.y < loc.y + sz) {
        opened = true;
        if (!weapon) {
          player.weapon.totalAmmo += 200;
        }
      }
    }
    // need else block displaying weapon sprite at loc 
  }
}

class Bullet {
  float xpos, ypos;
  PVector locB, dir;
  int sz = 5;
  Boolean pen = false;
  
  // types: basic mult speeds, shotty, bazooka
  
  Bullet(int _type, PVector _loc, PVector _dir) {
    //xpos = _loc.x;
    //ypos = _loc.y;
    fill(0, 0, 240);
    locB = _loc;
    //if (player.weapon.selWeapon == 2) {
    //  locB.add(new PVector(8, 8));
      
    //  locB.add(new PVector(8, 8));
    //  locB.add(new PVector(8, 8));
    //}
    //if (player.weapon.selWeapon == 2) {
    //  locB.add(new PVector(8+random(-1, 2), 8+random(-1, 2)));
    //  locB.add(new PVector(8+random(-1, 2), 8+random(-1, 2)));
      
    //} else {
    locB.add(new PVector(8, 8));
    
    
    
    dir = _dir;
      
    
  }
  void update() {
    //PVector _dir = dirs[curDir];
    locB.add(dir);
    //locB.x++;

  }
  void display() {
    noStroke();
    fill(255, 213, 0);
    rect(locB.x, locB.y, sz, sz);
  }
}
class Sprite {
  int totalFrames = 12;
  int curFrame = 0;
  int row = 0;
  int hold = 0;
  int xFrame = 0;
  int delay = 1;
  int x = int(width-32);
  int y = 0;
  int sx = 0;
  int sy = 0;
  int offsX = xFrame * sx; // replace 0 with mult of w
  int offsY = 0 * sx;
  int w = 16;
  int h = w;
  Boolean playing = false;
  
  Sprite() {
    
  }
  void update() {
    if (playing) {
      sx = curFrame * w;
      sy = row * h;
      hold = (hold +1)% delay;
      if (hold == 0) {
        curFrame = (curFrame+1) % totalFrames;
        //if (curFrame == totalFrames) {
        //  row += 1;
        //  curFrame = 0;
        //}
      }
    }
  }
}
class Weapon {
  String[] type = { "pistol", "revolver", "shotty", "smg", "smg2", "rifle", "bazooka" };
  //int[] type = { 0, 1, 2, 3, 4, 5, 6, 7};
  int[] curMag = {10, 6, 8, 20, 25, 30, 1};
  int selWeapon = 4;
  int[] shootTimers = {300, 350, 400, 100, 80, 150, 600 };
  int shootTimer = shootTimers[selWeapon];
  int totalAmmo = 50;
  int magazine = curMag[selWeapon];
  int loadedAmmo = magazine;
  //Sprite = new Sprite();
  
  Weapon(int _selWeapon) {
    selWeapon= _selWeapon;
  }
  
  void switchWeapon(int _selWeapon) {
    // switch weapons
    selWeapon = _selWeapon;
    xFrame = selWeapon * 16;
    magazine = curMag[selWeapon];
    shootTimer = shootTimers[selWeapon];
  }
}
  
  
class Player {
  PVector loc;
  int counter;
  Weapon weapon;
  // pistol, revolver, shotty, smg, smg2, rifle, bazooka
  // pistol basic shot 10 rounds
  // revolver, fast reload, pen shot 6 rounds
  // shotty spread shot, more dmg 8 rounds
  // smg1 fast reload fast shot, no pen 20 rounds
  // rifle fast reload, fast shot 30 rounds
  // bazooka slow reload slow shot radius area of effect 1 round
  
  //int[] shootTimers = {300, 350, 400, 100, 80, 150, 600 };
  //int shootTimer = shootTimers[0];
  //int totalAmmo = 50;
  //int magazine = 10;
  //int loadedAmmo = magazine;
  Sprite sprite;

  
  Player() {
    loc = new PVector(width/2, height/2);
    weapon = new Weapon(4);
    //loc = new PVector(width/2, height/2);
    //loc.x = constrain(loc.x, 0, width);
    //loc.y = constrain(loc.y, 0, height);
    player_sprite = loadImage("assets/player.png");
    sprite = new Sprite();
    sprite.playing = false;
    sprite.curFrame = 0;
  }
  void shoot(PVector _dir) {
    //PVector spread1 = _dir.add(random(1), random(1));
    //PVector spread2 = _dir.add(random(1,2), random(1,2));
    int type = 0;
    PVector bulletLoc;
    start = millis();
    if (weapon.loadedAmmo > 0) {
      weapon.loadedAmmo -= 1;
      if (weapon.selWeapon == 2) {
        //PVector rand = new PVector(random(-1, 2), random(01,2));
        //bulletLoc = new PVector(loc.x+5, loc.y+5);
        //bulletLoc.add(rand);
        //bulletLoc = new PVector(loc.x+5, loc.y+5);
        //bulletLoc.add(rand);
        bulletLoc = new PVector(loc.x+5, loc.y+5);
      }
      bulletLoc = new PVector(loc.x+5, loc.y+5);
    } else {
      return;
    }
    bullets.add(new Bullet(type, bulletLoc, _dir));
    //bullets.add(new Bullet(type, bulletLoc, spread1));
    //bullets.add(new Bullet(type, bulletLoc, spread2));
  }
  void reload() {
    if (weapon.loadedAmmo == 0 && weapon.totalAmmo > 0) {
      if (weapon.totalAmmo >= weapon.magazine) {
        weapon.totalAmmo -= weapon.magazine;
        weapon.loadedAmmo = weapon.magazine;
        
      } else if (weapon.totalAmmo < weapon.magazine) {
        weapon.loadedAmmo = weapon.totalAmmo;
        weapon.totalAmmo = 0;
      }
    }
  }
  void keyPressed() {
    if (!sprite.playing) {
      sprite.playing = true;
    }
    // up left shot 
    if (keys['a'] && keys['w']) { 
      player.loc.x-=1;
      player.loc.y-=1;
      curDir = 7;
    }
    // up right shot
    else if (keys['d'] && keys['w']) {
      player.loc.x+=1;
      player.loc.y-=1;
      curDir = 1;
    }
    // down right shot
    else if (keys['d'] && keys['s']) { 
      player.loc.x+=1;
      player.loc.y+=1;
      curDir = 3;
    }
    // down left shot
    else if (keys['a'] && keys['s']) { 
      player.loc.x-=1;
      player.loc.y+=1;
      curDir = 5;
    }
    //left
    else if (keys['a']) { 
      sprite.row = 8;
      player.loc.x-=2; curDir = 6;
    }
    
    else if (keys['d']) { 
      sprite.row = 6;
      player.loc.x+=2; curDir = 2;
    }
    else if (keys['w']) { 
      sprite.row = 4;
      player.loc.y-=2; curDir = 0;
    }
    else if (keys['s']) { 
      sprite.row = 2;
      player.loc.y+=2; curDir = 4;
    }
    else if (!keys['a'] && !keys['w'] && !keys['s'] && !keys['d']) {
      // idle up
      if (curDir == 0) {
        sprite.curFrame = 0;
        sprite.row = 1;
      }
      // idle right
      if (curDir == 2) {
        sprite.curFrame = 0;
        sprite.row = 6;
      }
      // idle left
      if (curDir == 6) {
        sprite.curFrame = 0;
        sprite.row = 8;
      }
      // idle down
      else if (curDir == 4) {
        sprite.curFrame = 0;
        sprite.row = 0;
      }
      
    }
    if (keys['j']) { 
      if (timer(weapon.shootTimer)) {
        player.shoot(dirs[curDir]);
      }
    }
    if (keys['k']) player.reload();
    
    
    lastKeys = keys.clone();
    
  }
  
  void keyReleased() {

  }

  void setKey(boolean state) {
    int rawKey = key;
    if (rawKey < 256) {
      if ((rawKey>64) && (rawKey < 91)) {
        rawKey+=32;
      }
      if ((state) && (!lastKeys[rawKey])) {
        keyHit = (char) (rawKey);
      }
      keys[rawKey] = state;
    }
  }
  
  void display() {
    sprite.update();

    noStroke();
    //int x = (counter % 4) * 16;
    //fill(200);
    //image(sprite, x, loc.x, 16, 16, 0, 0, 16, 16);
    //rect(loc.x, loc.y, 10, 10);
    copy(player_sprite, sprite.sx+sprite.offsX, sprite.sy+sprite.offsY, sprite.w, sprite.h, int(loc.x), int(loc.y), sprite.w*2, sprite.h*2);
  }
}
class Stain {
  PVector location = new PVector(0, 0);
  float size;
  
  Stain(PVector _loc) {
    location = _loc;
    size = random(5,12);
  }
  void display() {
    fill(100, 0, 0);
    noStroke();
    circle(location.x, location.y, size);
  }
}

class Zombie {
  PVector spawnLoc1 = new PVector(random(width), 0);
  PVector spawnLoc2 = new PVector(random(width), height);
  PVector[] spawnPoints = {spawnLoc1, spawnLoc2};
  PVector loc;
  int type = 0;
  color myClr = color(140, 200, 0);
  int counter;
  float speed=0.5;
  int health = 1;
  int sz = 16;
  Boolean hitflash = false;
  color flashClr = color(200, 50, 0);
  color Clr;
  Sprite sprite;

  
  Zombie(int _type) {
    zombie_sprite = loadImage("assets/zombie_1.png");
    sprite = new Sprite();
    sprite.playing = true;
    sprite.delay = 2;
    //sprite.y = 0;
    sprite.row = 2;
    type = _type;
    //loc = new PVector(random(width), height);
    loc = spawnPoints[int(random(2))];
    if (type == 1) {
      health = 3;
      speed = 0.3;
      myClr = color(80, 120, 0);
      Clr = myClr;
      //sz = 15;
    }
    //loc.x = constrain(loc.x, 0, width);
    //loc.y = constrain(loc.y, 0, height);
  }
  void damage() {
    health-=1;
    start = millis();
    myClr = flashClr;
    if (timer(50)) {
      myClr = Clr;
    }
    
  }
  void update() {
    //ps = new ParticleSystem(new PVector((loc.x*blk)+offs, (loc.y*blk)+offs));
    //case type:
    sprite.update();
    //sprite.curFrame = 0;
    
    // early movement for prototyping phase,
    // needs replaced with boids like collision and movement
    //  match 0:
    if (type == 0) {
      if (loc.x < player.loc.x) {
        loc.x+=speed;
        //loc.y+=random(1);
      }
      if (loc.x > player.loc.x) {
        loc.x-=speed;
        //loc.y+=random(1);
      }
      if (loc.y < player.loc.y) {
        loc.y+=speed;
        //loc.x+=random(1);
      }
      if (loc.y > player.loc.y) {
        loc.y-=speed;
        //loc.x+=random(1);
      }
    } else if (type == 1) {
      // hulk
      if (health == 3) {
        if (loc.y < player.loc.y) {
          loc.y+=speed;
        }
        if (loc.y > player.loc.y) {
          loc.y-=speed;
        }
        loc.add(random(-1, 2), 0);
      } else {
        speed = 0.7;
        //if (loc.x > player.loc.x || loc.x < player.loc.x) {
        //  loc.x *= -speed;
        //}
        if (loc.y < player.loc.y) {
          loc.y+=speed;
        }
        if (loc.y > player.loc.y) {
          loc.y-=speed;
        }
        if (loc.x < player.loc.x) {
          loc.x+=speed;
        }
        if (loc.x > player.loc.x) {
          loc.x-=speed;
        }
      }
    }
    
  }
  void display() {
    PVector w2m = world2map(loc.x, loc.y);
    noStroke();
    //ps = new ParticleSystem(new PVector((loc.x), (loc.y)));
    //int x = (counter % 4) * 16;
    //fill(myClr);
    //image(sprite, x, loc.x, 16, 16, 0, 0, 16, 16);
    //circle(loc.x, loc.y, sz);
    //sx = curFrame * w;
    //sy = row * h;
    //PVector w2m = world2map(loc.x, loc.y);
    if (w2m.x >= 3 && w2m.x <= cols && w2m.y >= 3 && w2m.y <= rows ) {
      
      copy(zombie_sprite, sprite.sx+sprite.offsX, sprite.sy+sprite.offsY, sprite.w, sprite.h, int(loc.x), int(loc.y), sprite.w*2, sprite.h*2);
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
    accel = new PVector(0, 0.05);
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
    life -= 10.0;
  }
  void display() {
    fill(170, 0, 0, life);
    circle(pos.x, pos.y, 5);
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
