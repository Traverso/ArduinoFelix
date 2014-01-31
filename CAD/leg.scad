include <femur.scad>
include <shin.scad>
include <pastern.scad>
include <servo.scad>

module knee(knee_angle=0)
{
    translate([0,-3,-50])
    pastern_linkage(knee_angle);
    
    translate([0,-3,-60])
    rotate([0,knee_angle,0])
    {
      shin();
      
      translate([0,0,-40])
      pastern(knee_angle);
    }
}

module linkage_knee()
{
		cylinder(r=0.5,h=55,$fn=100);

    translate([0,0,0])
    rotate([270,0,0])
		cylinder(r=0.5,h=8,$fn=100);

    translate([0,-7,55])
    rotate([270,0,0])
		cylinder(r=0.5,h=8,$fn=100);
}

module linkage_hip()
{
		cylinder(r=0.5,h=24.5,$fn=100);

    translate([0,0,0])
    rotate([90,0,0])
		cylinder(r=0.5,h=8,$fn=100);

    translate([0,0,24])
    rotate([270,0,0])
		cylinder(r=0.5,h=8,$fn=100);
}

module leg(hip_angle=0,knee_angle=0)
{
  rotate([0,90,0])
  MG995WithSingleHorn(hip_angle);

  translate([0,-8,0])
  rotate([90,-25,0])
  MG995DoubleHorn();

  translate([-24,-5,-11])
  rotate([0,-3,0])
  linkage_hip();

  translate([0,0,25])
  {
    rotate([0,90,0])
    MG995WithSingleHorn(knee_angle);

  }

  rotate([0,hip_angle,0])
  {
	  femur(0);

    translate([14,-7,-54])
    linkage_knee();

    knee(knee_angle);

  }
}

leg(-20,65);
