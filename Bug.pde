// Bug class for project1
// each Bug has unique attributes
// some attributes can be changed by the user
// attributes affect how the Bug interacts with other Bugs
// this has poor style, as all member variables are public...

public class Bug {
   public Vec2 position, velocity, acceleration;
   public float mass;
   public float rgb[];
   
   public Bug() {
     rgb = new float[3];
     position = new Vec2(100,100);
     rgb[0] = 255;
     rgb[1] = 255;
     rgb[2] = 255;
   }
   
   public Bug(Vec2 position, Vec2 velocity, Vec2 acceleration, float mass){
      rgb = new float[3];
      this.position = position;
      this.velocity = velocity;
      this.acceleration = acceleration;
      this.mass = mass;
      rgb[0] = 255;
      rgb[1] = 255;
      rgb[2] = 255;
   }
   
   public void renderCirc (PImage img){
     fill(rgb[0], rgb[1], rgb[2]);
     //float angle = atan2(velocity.y,velocity.x);
     ////circle(position.x, position.y, radius+mass*2);
     //pushMatrix();
     //imageMode(CENTER);
     //translate(this.position.x, this.position.y);
     //rotate(angle);
     image(img, position.x, position.y, 5+radius*mass, 5+radius*mass);
     //popMatrix();
   }
   
   public Vec2 collide (Bug stew2) {
     float mSum = mass + stew2.mass;
     float m1 = 2*stew2.mass/mSum;
     Vec2 p1mp2 = position.minus(stew2.position).normalized();
     float dp1 = dot(p1mp2, velocity.minus(stew2.velocity));
     Vec2 tempV1 = velocity.minus(p1mp2.times(dp1*(m1)));
           
     float m2 = 2*mass/mSum; 
     Vec2 p2mp1 = stew2.position.minus(position).normalized();
     float dp2 = dot(p2mp1, stew2.velocity.minus(velocity));
     Vec2 tempV2 = stew2.velocity.minus(p2mp1.times(dp2*(m2)));
     
     //acceleration = tempV1.times(1/dt);
     
     velocity = tempV1;
     return tempV2;
   }
   
   public void boundaryCheck() {
     if (position.x > width ) { 
       position.x = 0;
     }
     if (position.x < 0) { 
       position.x = width;
     }
     if (position.y > height) { 
       position.y = 0;
     }
     if (position.y < 0) { 
       position.y = height;
     }
   }
   
   public void separate(Bug stew2) {
      Vec2 sep = position.minus(stew2.position).normalized();
      sep.setToLength(stew2.mass);
      acceleration = acceleration.plus(sep.times(mass));
      if (acceleration.length() > maxAcc) {
        acceleration.normalize();
        acceleration.times(maxAcc);
      }
   }
   
   public void updatePosVel () {
     position = position.plus(velocity.times(dt));
     velocity = velocity.plus(acceleration.times(dt));
     acceleration = new Vec2(0,0);
     if (velocity.length() > maxSpeed){
       velocity.normalize();
       velocity.mul(maxSpeed);
     }
   }
   
   public Vec2 findNearest(Bug stew, float neighborDist, Vec2 avgPos) {
     if (position.distanceTo(stew.position) <= neighborDist) {
       return stew.position;
     }
     return avgPos;
   }
   
   public void orient(PImage img) {
     float dx = velocity.x - position.x;
     float dy = velocity.y - position.y;
     float angle = atan2(dy,dx);
     float newX = velocity.x - (cos(angle));
     float newY = velocity.y - (sin(angle));
     pushMatrix();
     translate(newX, newY);
     rotate(angle);
     image(img, -5+radius*mass, -5+radius*mass);
     popMatrix();
   }

  public boolean attToLight (Vec2 light) {
    return (light.distanceTo(position) <= 180 && light.distanceTo(position) > 140);
  }

}
