function [ output_args ] = GlobalMCA( params )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Lmax = 255;
lambda = 1;
J = 200;
Xc = params.x;
Xt = 0;
delta = lambda*Lmax;

for i=1:J
    %fix Xt, update Xc
    r = x - Xt - Xc

end

