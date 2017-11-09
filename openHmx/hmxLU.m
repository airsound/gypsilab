function [Lh,Uh] = hmxLU(Mh)
%+========================================================================+
%|                                                                        |
%|         OPENHMX - LIBRARY FOR H-MATRIX COMPRESSION AND ALGEBRA         |
%|           openHmx is part of the GYPSILAB toolbox for Matlab           |
%|                                                                        |
%| COPYRIGHT : Matthieu Aussal (c) 2015-2017.                             |
%| PROPERTY  : Centre de Mathematiques Appliquees, Ecole polytechnique,   |
%| route de Saclay, 91128 Palaiseau, France. All rights reserved.         |
%| LICENCE   : This program is free software, distributed in the hope that|
%| it will be useful, but WITHOUT ANY WARRANTY. Natively, you can use,    |
%| redistribute and/or modify it under the terms of the GNU General Public|
%| License, as published by the Free Software Foundation (version 3 or    |
%| later,  http://www.gnu.org/licenses). For private use, dual licencing  |
%| is available, please contact us to activate a "pay for remove" option. |
%| CONTACT   : matthieu.aussal@polytechnique.edu                          |
%| WEBSITE   : www.cmap.polytechnique.fr/~aussal/gypsilab                 |
%|                                                                        |
%| Please acknowledge the gypsilab toolbox in programs or publications in |
%| which you use it.                                                      |
%|________________________________________________________________________|
%|   '&`   |                                                              |
%|    #    |   FILE       : hmxLU.m                                       |
%|    #    |   VERSION    : 0.30                                          |
%|   _#_   |   AUTHOR(S)  : Matthieu Aussal                               |
%|  ( # )  |   CREATION   : 14.03.2017                                    |
%|  / 0 \  |   LAST MODIF : 31.10.2017                                    |
%| ( === ) |   SYNOPSIS   : LU factorization of H-Matrix                  |
%|  `---'  |                                                              |
%+========================================================================+

% H-Matrix (recursion)
if (Mh.typ == 0)
    % Lower initialisation    
    Lh     = hmx(Mh.dim(1),Mh.dim(2),Mh.tol);
    Lh.row = Mh.row;
    Lh.col = Mh.col;
    Lh.typ = 0;
    
    % Nullify upper corner
    Lh.chd{2}     = hmx(Mh.chd{2}.dim(1),Mh.chd{2}.dim(2),Mh.tol);
    Lh.chd{2}.dat = sparse(Lh.chd{2}.dim(1),Lh.chd{2}.dim(2));
    Lh.chd{2}.typ = 3;

    % Upper initialisation
    Uh     = hmx(Mh.dim(1),Mh.dim(2),Mh.tol);
    Uh.row = Mh.row;
    Uh.col = Mh.col;
    Uh.typ = 0;
    
    % Nullify lower corner    
    Uh.chd{3}     = hmx(Mh.chd{3}.dim(1),Mh.chd{3}.dim(2),Mh.tol);
    Uh.chd{3}.dat = sparse(Uh.chd{3}.dim(1),Uh.chd{3}.dim(2));
    Uh.chd{3}.typ = 3;
    
    % [L11,U11] -> M11
    [Lh.chd{1},Uh.chd{1}] = hmxLU(Mh.chd{1});

    % U12 -> L11 \ M12
    Uh.chd{2} = hmxSolveLower(Lh.chd{1},Mh.chd{2});

    % L21 -> M21 / U11
    Lh.chd{3} = hmxSolveUpper(Mh.chd{3},Uh.chd{1});
    
    % M22 -> M22 - L21*U12
    Mh.chd{4} = Mh.chd{4} - Lh.chd{3} * Uh.chd{2};
    
    % [L22,U22] -> M22
    [Lh.chd{4},Uh.chd{4}] = hmxLU(Mh.chd{4});
    
    % Fusion
    Lh = hmxFusion(Lh);
    Uh = hmxFusion(Uh);

% Compressed leaf
elseif (Mh.typ == 1)
    error('hmxLU.m : unavailable case')
    
% Full leaf
elseif (Mh.typ == 2)
    [L,U]  = lu(Mh.dat);
    Lh     = hmx(Mh.dim(1),Mh.dim(2),Mh.tol);
    Lh.dat = L;
    Lh.typ = 2;
    Uh     = hmx(Mh.dim(1),Mh.dim(2),Mh.tol);
    Uh.dat = U;
    Uh.typ = 2;    

% Sparse leaf
elseif (Mh.typ == 3)
    [L,U]  = lu(Mh.dat);
    Lh     = hmx(Mh.dim(1),Mh.dim(2),Mh.tol);
    Lh.dat = L;
    Lh.typ = 3;
    Uh     = hmx(Mh.dim(1),Mh.dim(2),Mh.tol);
    Uh.dat = U;
    Uh.typ = 3;    

% Unknown type
else
    error('hmxLU.m : unavailable case')
end
end