% Read File
t = readtable('D:\University Cources\Term 8\Projects\Economics-1\Exchange Rate\USD_to_EUR_June1_to_January1.xlsx');
t.Properties.VariableNames = {'date' 'exchange'};
t.exchange = str2double(t.exchange);
digits(6)
% Calculate Daily Volatility (Pt)
Pt = [];
abs_Pt = [];
for i = 1:size(t,1)-1
    tmp = vpa( (t.exchange(i+1) - t.exchange(i))/t.exchange(i) );
    Pt = [Pt , tmp ];
    abs_Pt = [abs_Pt , abs(tmp)];
end

% what is Pt of last row?
Pt = [Pt, vpa(0.001)];
abs_Pt = [abs_Pt, vpa(0.001)];

Pt = Pt';
abs_Pt = abs_Pt';

t.Pt = Pt;
t.abs_Pt = abs_Pt;

g = vpa(0.0001);
L_array = [1 10 20 30 40 50 60 70 80 90 100];
t2 = [];
for L = L_array
    fprintf('L= %d\n' ,L);
    entry = [L g];
    eq17_values = L * (t.abs_Pt + g);
    
    q_h = t.abs_Pt(find(eq17_values >= 1));
    q_l = setdiff(t.abs_Pt , q_h, 'stable');
    q = size( q_h , 1 );
    entry = [entry, q];
    
    P = geomean(t.abs_Pt);
    P_h = geomean(q_h);
    if isequal( size(q_h,1) , 0)
        P_h = 0;
    end
    P_l = geomean(q_l);
    if isequal( size(q_l,1) , 0)
        P_l = 0;
    end
    P_E = 1 - power( vpa(0.5) , q );
    P_F = 1 - P_E;
    entry = [entry, P, P_E, P_F];

    N = size(t, 1);
    if isequal( (1 + P_h - L*g) , 0 )
        disp("1")
        n0 = ((q - N)*log(1 - L * P_l - L * g)) / ( log(1 + L * P_l - L * g) - log(1 - L * P_l - L * g) );
    elseif isequal( (1 - L * P_l - L * g) , 0 )
        disp("2")
        n0 = -q * log(1 + P_h - L * g) / ( log(1 + L * P_l - L * g) - log(1 - L * P_l - L * g) );
    else
        disp("3..")
        n0 = ((q - N) * log(1 - L * P_l - L * g) - q * log(1 + P_h - L * g)) / ( log(1 + L * P_l - L * g) - log(1 - L * P_l - L * g) );
    end

    n0 = floor(n0);
    P_loss_E = 1;
    P_loss_F = 0;
    for i = 0:n0
        P_loss_F = vpa( P_loss_F + (nchoosek(N-q , i) * power(0.5 , N-q)) );
    end
    P_loss = (P_E * P_loss_E) + (P_F * P_loss_F);
    entry = [entry , n0 , P_loss_E , P_loss_F , P_loss];
    t2 = [t2;entry];
disp('---------------------------------------------')
end
disp('t2(Leverage, g, q, P, P_E, P_F, n0, P_loss_E , P_loss_F , P_loss)')
t2
draw_plots(t, t2)
