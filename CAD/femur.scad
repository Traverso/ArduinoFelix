
module femur_raw(length=70)
{
	difference()
	{
		union()
		{
			translate([0,0,5])
			cube(size=[10,10,length - 10]);
			
			//rounded top
			translate([0,5,length - 5])	
			rotate([0,90,0])
			cylinder(r=5,h=10,$fn=100); 
			
			//rounded bottom
			translate([0,5,5])	
			rotate([0,90,0])
			cylinder(r=5,h=10,$fn=100); 
			
		}
		union()
		{
			
			translate([1,1,-10])
			cube(size=[8,10,length + 20]); //diff for hip joins

			translate([1,-2,length - 25]) //diff to knee joints
			cube(size=[8,10,25]);

      translate([-3,-2,0]) //diff to clear space for the servo horn
      cube(size=[12,14,16]);

      translate([5,5,5]) //hole for the knee linkage
      rotate([0,90,0])
      cylinder(r=1.25,h=10,$fn=100);

      translate([-1,5,65]) //hole for the knee 
      rotate([0,90,0])
      cylinder(r=1.25,h=12,$fn=100);

      translate([-1,5,55]) //hole for the pastern linkage
      rotate([0,90,0])
      cylinder(r=1.25,h=12,$fn=100);

		}
	}


}

module femur(hip_angle=45)
{
	color("Gainsboro")
	rotate([(hip_angle * -1),180,90])
	translate([-2,-5,-5])
	femur_raw();
}

//femur();

