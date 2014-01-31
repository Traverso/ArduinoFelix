module pipe(length=100,rad=4)
{
	difference()
	{
		
		cylinder(r=rad,h=length,$fn=100); 
        translate([0,0,-5])
		cylinder(r=rad-1,h=length + 10,$fn=100); 
			
	}
}
module shin(knee_angle=0,length=65)
{
  rotate([knee_angle,0,90])
	color("Gainsboro")
  {
    difference()
    {
      translate([0,0,(length - 20) *-1])
      pipe(length,rad=3);

      union()
      {

        translate([-6,0,0]) //hole for the knee
        rotate([0,90,0])
        cylinder(r=1.25,h=12,$fn=100);

        translate([-6,0,15]) //hole for the knee linkage
        rotate([0,90,0])
        cylinder(r=1.25,h=12,$fn=100);

        translate([-6,0,-40]) //hole for the pastern
        rotate([0,90,0])
        cylinder(r=1.25,h=12,$fn=100);
      }
    }
  }
}

module pastern_linkage(knee_angle=0,length=50)
{
  rotate([knee_angle,0,90])
	color("Gainsboro")
  {
    difference()
    {
      translate([0,0,(length - 5) *-1])
      pipe(length,rad=3);

      union()
      {

        translate([-6,0,0]) //hole for the knee
        rotate([0,90,0])
        cylinder(r=1.25,h=12,$fn=100);

        translate([-6,0,-40]) //hole for the pastern
        rotate([0,90,0])
        cylinder(r=1.25,h=12,$fn=100);
      }
    }
  }
}


//shin();
//pastern_linkage();

