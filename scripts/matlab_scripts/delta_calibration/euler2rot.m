function R = euler2rot(x,y,z)
    X = [1 0 0; 0 cos(x) -sin(x); 0 sin(x) cos(x)];
    Y = [cos(y) 0 sin(y); 0 1 0; -sin(y) 0 cos(y)];
    Z = [cos(z) -sin(z) 0; sin(z) cos(z) 0; 0 0 1];
    R = Z*Y*X;