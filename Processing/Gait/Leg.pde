
class Leg
{
  Point origin;
  String id;
  int index;
  int femur_length = 100;
  int tibia_length = 90;
  int pastern_length = 90;
  int hip_angle = 125;
  int knee_angle = 40;
  int pastern_angle = 130;

  int offset_x = 15;
  int offset_y = 140;
  int step_width = 50;
  int step_height = 30;

  Segment femur,tibia,pastern;
  ArrayList<Point> trajectory;


  Leg(int idx,String id,Point orig)
  {
    this.index = idx;
    this.id = id;
    this.origin = orig;
    femur = new Segment(femur_length);
    tibia = new Segment(tibia_length);
    pastern = new Segment(pastern_length);
    position();
  }

  void load_trajectory()
  {
      trajectory = new ArrayList<Point>();

      //find the current step 
      int c_step = GAITS[CURRENT_GAIT][CURRENT_STEP][this.index];
      
      //find the next step
      int n_step = GAITS[CURRENT_GAIT][(CURRENT_STEP == (STEPS_IN_WALK - 1))? 0:CURRENT_STEP + 1][this.index];
      
      boolean flight = false;

      if((c_step == 4 && n_step == 1) || (c_step == 1 && n_step == 4) ) //flight phase
      {
         //create an elliptical trajectory
         trajectory.addAll(elliptical_trajectory(GRANULARITY,this.load_arc(),false));
         flight = true;
      }
      
      if(c_step == 1 && n_step == 4) reverse_trajectory();
      if(flight) return;
      
      Point p_1 = point_for_pose(c_step);
      Point p_2 = point_for_pose(n_step);
      Line l = new Line(p_1.x,p_1.y,p_2.x,p_2.y);
      trajectory.addAll(linear_trajectory(GRANULARITY,l,false));
  }

  Point point_for_pose(int step)
  {
    int x_a = (int)(this.origin.x - this.step_width) + this.offset_x;
    int x_b = (int)(this.origin.x + this.step_width) + this.offset_x;
    int y = (int)(this.origin.y + this.offset_y);
    int d = x_b - x_a;

    if(step == 1) return new Point(x_a,y);
    if(step == 4) return new Point(x_b,y);
    if(step == 2) return new Point(x_a + (d/3),y); 
    if(step == 3) return new Point(x_b - (d/3),y); 
    
    return new Point(0,0);
  }
  void reverse_trajectory()
  {
    ArrayList<Point> tmp = new ArrayList<Point>();
    for(int i=this.trajectory.size() - 1;i >0;i--)
    {
      tmp.add(this.trajectory.get(i));
    }
    this.trajectory = tmp;
  }

  Arc load_arc()
  {
    int x_a = (int)(this.origin.x - this.step_width) + this.offset_x;
    int x_b = (int)(this.origin.x + this.step_width) + this.offset_x;
    int y = (int)(this.origin.y + this.offset_y);
    return new Arc(new Point((int)this.origin.x + this.offset_x, y), 
                   new Point(this.step_width,this.step_height),
                   360, 180);
  }

  void position()
  {
    femur.setOrigin(this.origin);
    femur.setRotation(hip_angle);
    tibia.setOrigin(femur.P2);
    tibia.setRotation(knee_angle);
    pastern.setOrigin(tibia.P2);
    pastern.setRotation(pastern_angle);   
  }

  void trajectory_position()
  {
    Point p = this.trajectory.get(CURRENT_TICK);
    Point rots =  IK(this.origin,femur_length,tibia_length,p);

    femur.setRotation(rots.x);
    tibia.setOrigin(femur.P2);
    tibia.setRotation(rots.y);
    pastern.setOrigin(tibia.P2);
    pastern.setRotation(pastern_angle);
  }

  void draw()
  {
    stroke(#333333);
    strokeWeight(1);

    femur.draw();
    tibia.draw();
    pastern.draw();
    
    draw_trajectory();
  }
  
  void draw_trajectory()
  {
    noStroke();
    fill(#333333);
    for (int i = 0; i < this.trajectory.size(); i++) 
    {
      Point p = this.trajectory.get(i);
      ellipse(p.x,p.y,1,1);
    }
  }
}




/**********************************************************
 * Inverse Kinematic function for a two link planar system.
 * Given the size of the two links an a desired position, 
 * it returns the angles for both links
 **********************************************************/
 Point IK(Point origin,int a,int b,Point d)
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
/**
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
**/
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
    Point P1,P2;
    float rotation;

    Segment(int s)
    {
        size = s;
        P1 = new Point(0,0);
        P2 = new Point(0,0);
    }
    
    void setOrigin(Point orig)
    {
      P1.x = orig.x;
      P1.y = orig.y;
    }
    
    void setRotation(float rotation)
    {
      this.rotation = rotation;
      P2.x = (int)(P1.x + this.size * cos(radians(this.rotation)));
      P2.y = (int)(P1.y + this.size * sin(radians(this.rotation)));
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
