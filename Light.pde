// Lights can be turned on and off and attract bugs
// they are physical and can be avoided

public class Lights {
  public Vec2 pos;
  public float wid;
  public float hgt;
  public float rad;
  public float rgb[];
  
  public Lights(Vec2 pos, float wid, float hgt, float rad) {
    rgb = new float[3];
    this.pos = pos;
    this.wid = wid;
    this.hgt = hgt;
    this.rad = rad;
    rgb[0] = 255;
    rgb[1] = 255;
    rgb[2] = 255;
  }
  
  public void renderLight() {
    fill(rgb[0], rgb[1], rgb[2]);
    rect(pos.x, pos.y, wid, hgt);
  }
  
  public boolean lightBugCollide(Student stew) {
    float xDist = abs(stew.position.x - pos.x-(.5*wid));
    float yDist = abs(stew.position.y - pos.y-(.5*hgt));
    if (xDist > (wid/2 + rad)) {return false;}
    if (yDist > (hgt/2 + rad)) {return false;}
    if (xDist <= (wid/2)) {return true;}
    if (yDist <= (wid/2)) {return true;}
    
    float cDist = pow((xDist = wid/2), 2) + pow(yDist - (hgt/2), 2);
    return (cDist <= (rad*rad + 2*stew.mass));
  }
  
  public int checkSide(Student stew) {
    if (stew.position.x >= pos.x+wid) {
      return 0;
    }
    else if (stew.position.x < pos.x+wid) {return 1;}
    else if (stew.position.y >= pos.y+hgt){
      return 2;
    } else {return 3;}
    
  }
  
}
