
module top_rounded_c_beam(length=60)
{
	difference()
	{
		union()
		{
			cube(size=[10,10,length - 10]);
			translate([0,5,length - 10])	
			rotate([0,90,0])
		
			cylinder(r=5,h=10,$fn=100); //rounded top
		}
		union()
		{
			translate([1,1,-1])
			cube(size=[8,10,length + 2]);
			translate([1,-2,length - 25])
			cube(size=[8,10,25]);


      translate([-1,5,length - 10])
      rotate([0,90,0])
      cylinder(r=1.25,h=12,$fn=100);

      translate([-1,5,length - 20])
      rotate([0,90,0])
      cylinder(r=1.25,h=12,$fn=100);
		}
	}

}

module pastern_raw()
{
	difference()
	{
		top_rounded_c_beam(60);
		translate([-1,1,0])
		rotate([-13,0,0])
		cube(size=[12,12,40]);
	}
}

module shue()
{
	union()
	{
		translate([-6,1,0])
		cube(size=[8,4,25]);
		
		translate([-6,-5,0])
		rotate([-10,0,0])
		cube(size=[8,4,25]);

		translate([-6,0,0])
		rotate([0,90,0])
		cylinder(r=5,h=8,$fn=100);
	}
}

module pastern(pastern_angle=0,details=1)
{
	color("Gainsboro")
	rotate([pastern_angle,0,270])
	translate([-4,-5,-40])
	pastern_raw();
	
	if(details==1)
	{
		
		rotate([pastern_angle,0,270])
		translate([3,-5,-40])
		color("DarkGray")
		shue();
	}
}


//pastern(details=1);
