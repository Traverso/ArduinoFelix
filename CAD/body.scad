include <leg.scad>


module legs_side()
{
  //front leg
  leg(-20,65);

  //back leg
  translate([-80,0,0])
  mirror([1,0,0])
  leg(-20,65);
}

translate([40,-45,-12.5])
legs_side();

translate([40,45,-12.5])
mirror([0,1,0])
legs_side();
