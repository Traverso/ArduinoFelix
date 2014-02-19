PVector origin;
int femur_length, tibia_length, pastern_length;
int hip_angle,knee_angle, pastern_angle;
Segment femur,tibia,pastern;
PVector drag_delta = new PVector(0,0);
int hock_radius = 35;
boolean hock_drag = false;


void setup()
{  
  size(500,500,P2D);
  origin = new PVector(width/2, height/4);  
  femur_length = 100;
  tibia_length = 90;
  pastern_length = 90;
  hip_angle = 125;
  knee_angle = 40;
  pastern_angle = 130;

  femur = new Segment(femur_length);
  femur.setOrigin(this.origin);
  femur.setRotation(hip_angle);

  tibia = new Segment(tibia_length);
  tibia.setOrigin(femur.P2);
  tibia.setRotation(knee_angle);

  pastern = new Segment(pastern_length);
  pastern.setOrigin(tibia.P2);
  pastern.setRotation(pastern_angle);   
  
}

void draw()
{
    background(128); 
    stroke(#333333);
    strokeWeight(1);

    femur.draw();
    tibia.draw();
    pastern.draw();
    
    stroke(#333333);
    fill(#333333);
    text("Hip angle: "+ int(femur.rotation), 10, 20);
    text("Knee angle: "+ int(tibia.rotation), 10, 40);

    if(mouse_over_hock()) draw_hock();
}

boolean mouse_over_hock()
{
  return ( dist(tibia.P2.x, tibia.P2.y, mouseX, mouseY) <= hock_radius);    
}

void draw_hock()
{
   noStroke();
   fill(#CC3300,100);
   ellipse(tibia.P2.x,tibia.P2.y,hock_radius,hock_radius);
}

void mousePressed() 
{
   if(!mouse_over_hock()) return;
   hock_drag = true;
   drag_delta.x = tibia.P2.x - mouseX;
   drag_delta.y = tibia.P2.y - mouseY;
}

void mouseDragged() 
{
   if(!hock_drag) return;

   PVector target = new PVector( drag_delta.x + mouseX, drag_delta.y + mouseY);
   PVector rots =  IK(femur_length,tibia_length,target);

   femur.setRotation(rots.x);
   tibia.setOrigin(femur.P2);
   tibia.setRotation(rots.y);
   pastern.setOrigin(tibia.P2);
   pastern.setRotation(pastern_angle);

}

void mouseReleased() 
{
    if(hock_drag) hock_drag = false;
}

/**********************************************************
 * Inverse Kinematic function for a two link planar system.
 * Given the size of the two links an a desired position, 
 * it returns the angles for both links
 **********************************************************/
 PVector IK(int a,int b,PVector d)
 {
     PVector rotations = new PVector(0,0);
     
     float dx = d.x - origin.x;
     float dy = d.y - origin.y;
     
     //calculates the distance beetween the first link and the endpoint
     float distance = sqrt(dx*dx+dy*dy);
     float c = min(distance, a + b);

     //Find wich cartesian quadrant the solution should be in
     float D = atan2(dy,dx);

     //calculates the angle between the distance segment and the first link
     float B = acos((b * b - a * a - c * c)/(-2 * a * c));

     //calculate the angle between the first and second link
     float C = acos((c * c - a * a - b * b)/(-2 * a * b));

     float hip_angle = degrees(D + B); 
     float knee_angle = degrees(D + B + PI + C);
    
     if(hip_angle > 360) hip_angle -= 360;
     if(knee_angle > 360) knee_angle -= 360;
     
     rotations.x = hip_angle;
     rotations.y = knee_angle;
     
     return rotations;
 }

class Segment
{
    int size;
    PVector P1,P2;
    float rotation;

    Segment(int s)
    {
        size = s;
        P1 = new PVector(0,0);
        P2 = new PVector(0,0);
    }
    
    void setOrigin(PVector orig)
    {
      P1.x = orig.x;
      P1.y = orig.y;
    }
    
    void setRotation(float rotation)
    {
      this.rotation = rotation;
      P2.x = P1.x + this.size * cos(radians(this.rotation));
      P2.y = P1.y + this.size * sin(radians(this.rotation));
    }

    void draw()
    {
      
      stroke(0);
      strokeWeight(2);
      line(P1.x,P1.y,P2.x,P2.y);
      
      stroke(255,0,0,100);
      fill(240,0,0,200);
      ellipse(P1.x,P1.y,4,4);
    }

}
