PVector origin;
int femur_length, tibia_length, pastern_length;
int hip_angle,knee_angle, pastern_angle;
Segment femur,tibia,pastern;
PVector drag_delta = new PVector(0,0);
int hock_radius = 35;
boolean hock_drag = false;
int OFFSET_X = 15;
int OFFSET_Y = 140;
int STEP_WIDTH = 50;
int STEP_HEIGHT = 30;
ArrayList<Point> trajectory;
int step_in_trajectory = 0;

void setup()
{  
  size(400,450,P2D);
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

  trajectory = generate_trajectory(20);
  frameRate(20);
}

void draw()
{
    move_leg();
    
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
    
    draw_trajectory();
}

void move_leg()
{

  if(step_in_trajectory >= trajectory.size()) step_in_trajectory = 0;
   
  Point p = trajectory.get(step_in_trajectory);
  Point rots =  IK(femur_length,tibia_length,p);

  femur.setRotation(rots.x);
  tibia.setOrigin(femur.P2);
  tibia.setRotation(rots.y);
  pastern.setOrigin(tibia.P2);
  pastern.setRotation(pastern_angle);

  step_in_trajectory++;
 
}

void draw_trajectory()
{
  noStroke();
  fill(#333333);
  for (int i = 0; i < trajectory.size(); i++) 
  {
    Point p = trajectory.get(i);
    ellipse(p.x,p.y,1,1);
  }
}


/**********************************************************
 * Inverse Kinematic function for a two link planar system.
 * Given the size of the two links an a desired position, 
 * it returns the angles for both links
 **********************************************************/
 Point IK(int a,int b,Point d)
 {
     Point rotations = new Point(0,0);
     
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
     
     rotations.x = (int)hip_angle;
     rotations.y = (int)knee_angle;
     
     return rotations;
}

ArrayList<Point> generate_trajectory(int granularity)
{
  ArrayList<Point> steps = new ArrayList<Point>();
  
  
  int x_a = (int)(origin.x - STEP_WIDTH ) + OFFSET_X;
  int x_b = (int)(origin.x + STEP_WIDTH) + OFFSET_X;
  int y = (int)(origin.y + OFFSET_Y);
  Arc ac = new Arc(new Point((int)origin.x + OFFSET_X, y), 
                   new Point(STEP_WIDTH,STEP_HEIGHT),
                   360, 180);
                   
 
  steps.addAll(linear_trajectory(granularity,new Line(x_a,y,x_b,y),false));
  steps.addAll(elliptical_trajectory(granularity,ac,false));
  return steps;
}

/*********************************************************
 * generate a linear trajectory plan (steps) between two points
 * with the required granularity (number of points)
 * The last parameter tells if you want the first point in the plan or not
 *********************************************************/
ArrayList<Point> linear_trajectory(int granularity, Line line, boolean skip_start_point)
{
     ArrayList<Point> steps = new ArrayList<Point>();

     // find the slopes/delta
     float delta_x = line.b.x - line.a.x;
     float delta_y = line.b.y - line.a.y;
     
     //calculate the distance between the two points
     float distance = sqrt( ((delta_x) * (delta_x)) + ((delta_y) * (delta_y)) );

     //divide the line int the required number of points
     //decrease the granularity one step to be able to include the end point
     int skip = (skip_start_point)? 0:1;
     float step_size = distance / (granularity - skip);

     float c_step = (skip_start_point)? step_size:0;
      
     for(int i=0;i < granularity;i++)
     {
        float inc = c_step / distance;
        float x = line.a.x + (inc * delta_x);
        float y = line.a.y + (inc * delta_y);

        steps.add(new Point((int)x,(int)y));
        c_step+= step_size;
     }
     return steps; 
}

/*********************************************************
 * Generate an elliptical trajectory plan 
 * with the required granularity for the provided arc struct. 
 * The last parameter tells if you want the first point in the plan or not
 *********************************************************/
ArrayList<Point> elliptical_trajectory(int granularity, Arc a, boolean skip_start_point)
{
      ArrayList<Point> steps = new ArrayList<Point>();

      //divide the angles int the required number of points
      //decrease the granularity one step to be able to include the end point
      int skip = (skip_start_point)? 0:1;
      
      float step_size = (a.end_angle - a.start_angle) / (granularity - skip);
      float c_angle = a.start_angle;
      
      if(skip_start_point) c_angle+= step_size;
      
      for(int i=0;i < granularity;i++)
      {
        float x = a.origin.x + a.radius.x * cos(radians(c_angle));
        float y = a.origin.y + a.radius.y * sin(radians(c_angle));

        steps.add(new Point((int)x, (int)y));
       
        c_angle+= step_size;
      }
      
      return steps;
}
class Point
{
  int x;
  int y;

  Point(int x,int y)
  {
    this.x = x;
    this.y = y;
  }
}

class Line
{
  Point a;
  Point b;

  Line(int a_x, int a_y, int b_x, int b_y)
  {
    this.a = new Point(a_x,a_y);
    this.b = new Point(b_x,b_y);
  }
}

class Arc
{
  Point origin;
  Point radius;
  int start_angle;
  int end_angle;

  Arc(Point origin,Point radius,int start_angle,int end_angle)
  {
    this.origin = origin;
    this.radius = radius;
    this.start_angle = start_angle;
    this.end_angle = end_angle;
  }
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
