function yp=l1eq_cvx(z, Afun, N, epsilon)

if nargin < 4
    epsilon = 0;
end

if isa(Afun,'function_handle')
    % This assumes that Afun can take a 2D matrix as input
    B=Afun(eye(N));
else
    B=Afun;
end

cvx_quiet(true)
cvx_clear
cvx_begin
    variable yp(N) complex
    minimize (norm(yp, 1))
    subject to
        norm(B*yp - z)/norm(z) <= epsilon
cvx_end
