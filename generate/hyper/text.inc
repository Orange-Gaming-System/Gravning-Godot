#version 3.7;
global_settings {
    assumed_gamma 1.0
}
#default{ finish{ ambient 0.1 diffuse 0.9 }}

#include "colors.inc"

light_source {
	<-100000, 0, -100000>, White
	parallel
	point_at <0,0,0>
}

camera {
       orthographic
       right		x*image_width/image_height
       up		    y
       location		<0,0,-1000>
       look_at		<0,0,0>
}

#declare Thickness = 0.1;

text {
     ttf "../../PressStart2P-Regular.ttf", Text, Thickness, 0.0

     texture{ pigment{ color rgb<1,1,1> }
	      // normal { bumps 0.5  scale 0.01 }
	      // finish { phong 0.1 }
     } // end of texture

      // To match the PNG coordinate system
      translate<-X,-Y,-Thickness/2>
      scale<1,1,1>*0.25*Scale
     rotate<0,Degrees,0>
} // end of text object ---------------------------------------------
