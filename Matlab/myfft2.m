function[f,P1]=myfft2(t1,y5,Mp,T0)
%%% t1 time axis
%%% y5 the signal
%%% Mperiods number of periods
%%% T0 period of the input sinusoidal signal

L=length(t1)
Fs=L/(Mp*T0)
Y5f = fft(y5);

P2 = abs(Y5f/L);
% P1 = P2(1:round(L/2)+1);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(round(L/2)))/L;