include <leg.scad>


translate([40,-45,-12.5])
leg(-20,65);

translate([40,45,-12.5])
mirror([0,1,0])
leg(-20,65);


translate([-40,-45,-12.5])
leg_mirrow(-20,65);

translate([-40,45,-12.5])
mirror([0,1,0])
leg_mirrow(-20,65);
