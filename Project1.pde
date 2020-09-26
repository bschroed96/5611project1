//"Bugs"
//CSCI 5611 Project 1
// Ben Schroeder
int counter = 0;
boolean pause = false;
boolean flock = false;
boolean pull = false;
boolean predator = false;
boolean light = false;
boolean emergent = false;
int agents = 100;
int width = 1200;
int height = 900;
int tooBigBug = 25;
int maxMass = 2;
int minMass = 1;
float wallBuff = 20;
float neighborDist = 85.0;
Vec2 bulbPos = new Vec2(470, 180);
float predatorDist = 40.0;

float x = 100;
float y = 100;
float angle1 = 0.0;
float segLength = 1;

Vec2 dir[] = new Vec2[agents];//keep for new class based system
float sepDist = 19.0;
float maxSpeed = 20;
float maxAcc = 65;
float radius = 2;
float dt = .1;
float speed = 4;
float m;
Vec2 pos;
Vec2 vel;
Vec2 acc;

Vec2 orient;
     
PImage bug;
PImage bgrnd;
Bug stew[] = new Bug[agents];
Lights lit;
Vec2 lightPos = new Vec2(100,100);
void setup() {
   size(1200, 900);
   surface.setTitle("Bugs!");
   bgrnd = loadImage("background1.png");
   bgrnd.resize(width,height);
   bug = loadImage("bug.png");
   bug=loadImage("bug.png");

   for (int i = 0; i < agents; i++){
     m = (minMass + random(maxMass));
     pos = new Vec2(100, 100 + i*100);
     vel= new Vec2(5+(random(20)), (0-random(15)+5));
     acc = new Vec2(1, 1);
     
     stew[i] = new Bug(pos, vel, acc, m);
     
   }
   lit = new Lights(lightPos, 100.0, 100.0, 10);
}

void draw() {
   background(bgrnd);
   mousePred();
   noStroke();  
   
   if (light) {lightOn();}
   for (int i = 0; i < agents; i++){
     if (stew[i] == null) {continue;}
     float dxx = (stew[i].position.x + stew[i].velocity.normalized().x) - stew[i].position.x;
     float dyy = (stew[i].position.y + stew[i].velocity.normalized().y) - stew[i].position.y;
    angle1 = atan2(dyy, dxx);
    x = (stew[i].position.x + stew[i].velocity.normalized().x) - (cos(angle1) * segLength) -.1;
    y = (stew[i].position.y + stew[i].velocity.normalized().y) - (sin(angle1) * segLength) -.1;
     //stew[i].renderCirc(bug);
     segment(x, y, angle1, stew[i]);
     
   }

// position and velocitty update
  for ( int i = 0; i < agents; i++){
    if (stew[i] == null) {continue;}
    Vec2 avgPos = new Vec2(0,0);
    Vec2 avgVel = new Vec2(0,0);
    Vec2 nearPos = new Vec2(10000,10000);
    //stew[i].orient(bug);
    if (light) {
    if (stew[i].attToLight(bulbPos)) {
      Vec2 posDif;
      posDif = bulbPos.minus(stew[i].position);
      float dist = posDif.length();
      posDif.normalize();
      stew[i].acceleration = stew[i].acceleration.plus(posDif.times(6));
      stew[i].velocity = stew[i].velocity.plus(posDif.times(4/dist));
    }
    }
    
    stew[i].updatePosVel();
    int neighborsVisited = 0;
    int velCount = 0;
     for (int j = 0; j < agents; j++){
       if (stew[j] == null) {continue;}
       if (stew[i] == null) {continue;}
       if (i ==j) continue;
         float dist = stew[i].position.distanceTo(stew[j].position);
         //
         // Separation Force... based on mass. Greater mass means a greater separation force
         //
         if (dist < sepDist + stew[i].mass && dist > 0.01) {
           stew[i].separate(stew[j]); // separation force
         }
         //
         // handles ball to ball collision using collide
         //
         
           if (dist < radius+stew[i].mass + stew[j].mass +radius
           && dot(stew[i].position.minus(stew[j].position), (stew[i].velocity.minus(stew[j].velocity))) < 0){
               if (emergent && random(50) > 44) {
                 if (stew[i].mass < stew[j].mass) {
                   stew[j].mass += 1;
                   if(stew[j].mass > tooBigBug) {
                   stew[j].mass = tooBigBug;
                 }
                 stew[i] = null;
                 } else {
                   stew[i].mass += 1;
                   if(stew[i].mass > tooBigBug) {
                   stew[i].mass = tooBigBug;
                 }
                 stew[j] = null;
                 }
             }   
             else {
             stew[j].velocity = stew[i].collide(stew[j]);  // collision physics
             stew[i].acceleration = stew[i].velocity.normalized().times(dt);
             stew[j].acceleration = stew[j].velocity.normalized().times(dt);
         }
           }
         if (stew[i] ==null){continue;}
         if (stew[j] == null){continue;}
         //
         // Cohesion Force..
         //
         if (stew[i].position.distanceTo(stew[j].position) <= neighborDist) {
           if (nearPos.length() > stew[i].position.distanceTo(stew[j].position)) {
             nearPos = stew[j].position;
           }
           avgPos.add(stew[j].position);
           neighborsVisited++;
         }
         
         if (nearPos.length() < 100) {
           Vec2 near = nearPos.minus(stew[i].position);
           near.normalize();
           stew[i].acceleration = stew[i].acceleration.plus(near);
         }
         
         //
         // Alignment force...
         //
         
         if (dist < 20 && dist > 0) {
           avgVel.add(stew[j].velocity);
           velCount ++;
         }
     }

         if (stew[i] == null){continue;}

         
     avgVel.mul(1.0/(float)velCount);
     if (velCount > 0) {
       Vec2 dirTo = avgVel.minus(stew[i].velocity).normalized();
       stew[i].acceleration = stew[i].acceleration.plus(dirTo);
     }
     
     if (neighborsVisited > 0) {
     avgPos.x = avgPos.x / neighborsVisited;
     avgPos.y = avgPos.y / neighborsVisited;
     
     Vec2 direct = avgPos.minus(stew[i].position);
     direct.normalize();
     stew[i].acceleration = stew[i].acceleration.plus(direct.times(stew[i].mass));
     }
     // keep balls within bounds using boundaryCheck()
     stew[i].boundaryCheck();
     
     float dx = stew[i].velocity.x - stew[i].position.x;
     float dy = stew[i].velocity.y - stew[i].position.y;
     float angle1 = atan2(dy, dx);
     pushMatrix();
     imageMode(CENTER);
     translate(stew[i].position.x, stew[i].position.y);
     rotate(angle1);
     popMatrix();
  }
}

void mousePressed(){
      print(mouseX + " " + mouseY);
     Vec2 mouseClick = new Vec2(mouseX, mouseY);
  
  for (int i = 0; i<agents; i++) {
    if (stew[i] == null) {continue;}
  if (mouseClick.distanceTo(stew[i].position) < stew[i].mass+radius){
    print("bullsete");
    for (int j = 0; j < 3; j++){
      stew[i].rgb[j] = stew[i].rgb[j] % 5 + random(85*i);
    }
  }
  }
  
  if (pull) {
  float mouseSpeed = 100.0;
  float length = 0;
  for (int i = 0; i < agents; i++){
    if (stew[i] == null) {continue;}
    dir[i] = mouseClick.minus(stew[i].position);
    length = dir[i].length()*10;
    mouseSpeed += length % 9;
    dir[i].normalize();
    stew[i].velocity = stew[i].velocity.plus(dir[i].times(dt*mouseSpeed));
    //print(velocity[i].length());
    if (stew[i].velocity.length() > maxSpeed) {
      stew[i].velocity = dir[i].times(dt*maxSpeed).normalized().times(maxSpeed);
    }
  }
  }
  
  if (flock) {
      for (int i = 0; i < 25; i++){
      if (stew[i] == null) {counter = (counter+1)%agents;continue;}
      stew[counter].position = mouseClick;
      counter = (counter+1)%agents;
      }
  }
  
}

void mousePred() {
  if (predator) {
  Vec2 mouseClick = new Vec2(mouseX, mouseY);
    for (int i = 0; i < agents; i++){
      if (stew[i] == null) {continue;}
      Vec2 mouseToB = stew[i].position.minus(mouseClick);
      if (stew[i].position.distanceTo(mouseClick) < predatorDist) {
        Vec2 avoidVel = projAB(mouseToB, mouseClick);
        avoidVel.normalize();
        stew[i].acceleration = stew[i].acceleration.plus(avoidVel.times(-9));
        stew[i].velocity = stew[i].velocity.plus(avoidVel.times(6*stew[i].mass));
      }
    }
  }
}

void segment(float x, float y, float a, Bug stew) {
  pushMatrix();
  translate(x, y);
  imageMode(CENTER);
  rotate(a);
  image(  bug, -(5+radius*stew.mass/2), -(5+radius*stew.mass/2), 5+radius*stew.mass, 5+radius*stew.mass);
  
  //line(0, 0, segLength, 0);
  popMatrix();
}

void lightOn() {
   for(int i = 0; i < 20; i++) {
     fill(255-i, 255-i, 0, 10);
     circle(bulbPos.x, bulbPos.y, i*35);
   }
}

void keyPressed() {
  if (key == ' ') {print(pause); if (!pause) {noLoop(); pause = !pause; print(pause);} else {loop(); pause=!pause; }}
  if (key == 'f') {flock = !flock; pull = false; predator = false;light = false;}
  if (key == 'p') {pull = !pull; flock = false; predator = false;light = false;}
  if (key == 'a') {predator = !predator; flock = false; pull = false;}
  if (key == 'l') {
   light = !light;
    flock = false; pull = false;
 }
 if (key == 'e') {
   emergent = !emergent;
 }
}
