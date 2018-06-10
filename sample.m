function [ pos] = sample( rect,radius,nr,nt )

   radius=radius/100;
   rstep=radius/nr;
   tstep=2*pi/nt;
   pos=[rect];
   for ir =1:nr
		 phase = mod(ir,2)*tstep/2;
		for it=1:nt
			dx = ir*rstep*cos(it*tstep+phase);
			dy = ir*rstep*sin(it*tstep+phase);
            
			pos=[pos;[rect(1)+dx,rect(2)+dy]];
        end
   end
   

end

