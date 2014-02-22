ArrayList<Leg> legs;
Point origin;
Leg back_left, back_right, front_left, front_right;
int[][][] GAITS = {
                    {  
                       //CREEPING GAIT: FL->BR->FR->BL
                       {1,4,2,3},
                       {2,1,3,4},
                       {3,2,4,1},
                       {4,3,1,2}
                    },
                    {  
                       //CREEPING GAIT (BACKWARD): FL->BR->FR->BL
                       {3,4,2,1},
                       {2,3,1,4},
                       {1,2,4,3},
                       {4,1,3,2}
                    },
                     {  
                       //CREEPING GAIT: FL->FR->BR->BL
                       {1,4,3,2},
                       {2,1,4,3},
                       {3,2,1,4},
                       {4,3,2,1}
                    },
                    {  
                       //CREEPING GAIT (BACKWARD): FL->FR->BR->BL
                       {3,4,1,2},
                       {2,3,4,1},
                       {1,2,3,4},
                       {4,1,2,3}
                    }
                  
                 };
                 
int CURRENT_TICK = 0;
int CURRENT_STEP = 0;
int STEP_COUNT = 0;
int STEPS_IN_WALK = 4;
int GRANULARITY = 20;
int WALK_CYCLE_COUNT = 0;
int CURRENT_GAIT = 0;

void setup()
{  
  size(700,600,P2D);
  origin = new Point(width/2, height/4);  
  Point back = new Point(origin.x + 150, origin.y);
  Point front = new Point(origin.x - 120, origin.y);
 
  back_left = new Leg(0,"back_left",new Point(back.x - 40, back.y - 50));
  front_left = new Leg(1,"front_left",new Point(front.x - 40, back.y - 50));
  front_right = new Leg(2,"front_right",new Point(front.x + 40, back.y + 50));
  back_right = new Leg(3,"back_right",new Point(back.x + 40, back.y + 50));
  
  legs = new ArrayList<Leg>();

  legs.add(back_left);
  legs.add(front_left);
  legs.add(front_right);
  legs.add(back_right);

 
  
  frameRate(25);
}

void draw()
{
  background(128); 

  update_walk();
  
  for(int i=0;i < legs.size();i++)
  {
     legs.get(i).draw();
  }
 
}

void update_walk()
{
  //new keyframe, generate a new trajectory
  if(CURRENT_TICK == 0)
  {
      for(int i=0;i < legs.size();i++)
      {
         legs.get(i).load_trajectory();
      }
  }

  //update the position of the legs according to the 
  //current point in the trajectory
  for(int i=0;i < 4;i++) 
  {
      legs.get(i).trajectory_position(); 
  }

  CURRENT_TICK++;

  //end of trajectory, new step
  if(CURRENT_TICK >= (GRANULARITY - 1)) 
  {
        STEP_COUNT++;
        CURRENT_STEP++;
        CURRENT_TICK = 0;
  }

  //done with the steps, gait new cycle
  if(CURRENT_STEP >= STEPS_IN_WALK) 
  {
        WALK_CYCLE_COUNT++;
        CURRENT_STEP = 0;
  }
}

