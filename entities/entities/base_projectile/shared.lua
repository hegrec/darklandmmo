ENT.Type = "anim"
ENT.Base = "base_anim" 


 function ENT:Draw() 
 	--self.Entity:DrawModel() 
 end 
   
 /*--------------------------------------------------------- 
    Name: DrawTranslucent 
    Desc: Draw translucent 
 ---------------------------------------------------------*/ 
 function ENT:DrawTranslucent() 
   
 	// This is here just to make it backwards compatible. 
 	// You shouldn't really be drawing your model here unless it's translucent 
   
 	self:Draw() 
 	 
 end 