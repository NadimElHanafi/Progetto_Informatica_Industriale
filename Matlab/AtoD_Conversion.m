clear all;
close all;

set(0,'DefaultAxesFontName','arial');
set(0,'DefaultAxesFontSize',24);

global nstart nstep Nsample LSB indexsh indexs;
global vin vins vinsh;
global nfig;

nfig=1;

%%%%%%%%% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k=13.8e-24;
T=300;

%%% Full-scale
FS=1;

%%% Input Signal and Sampling frequency, Bits Resolution
f0=1e3;
T0=1/f0;
fs=64e3;
Nb=6;
LSB=FS/2^Nb;

%%%%%%%%%%%% Input signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=FS/2;

Nperiod=1;
N=Nperiod*128*fs/f0;
Nsample=Nperiod*round(fs/f0);

vnrms=1e-9;

%%% Time Axis
T=Nperiod/f0;
t=1:1:N;
t=t/N;
t=t*T;
vin=A*sin(2*pi*f0*t);
% vns=vnrms*randn(1,N);
vin=vin; %+0*vns;

%%%%%%%%%%%%%%%%%%% Sampling %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[vins,vins2,vinsh]=sampling(t,vin,Nperiod*fs,f0,0);

%%%%%%%%%%%%%%%%%%% Quantization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[vinq,vinq2,eq]=quantization(t,vin,vins2,fs,f0,FS,Nb,0);

%%%%%%%%%%%%%%%%%% FFT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% NEW Time aXIS
t1(1:1:Nperiod*fs/f0)=t(1:128:N);
vns=vnrms*randn(1,length(t1));
vinq2=vinq2+vns;
[f,P1]=myfft2(t1,vinq2,Nperiod,T0);
P1dB=20*log10(abs(P1));

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PLOT in Time Domain
%%% Sampling Plots
figure(nfig);
plot(t,vin,'-k','LineWidth',4);
hold on;
grid on;
xlabel('Time - [sec]');ylabel('Amplitude - [V]');
legend('vin');
nfig=nfig+1;

figure(nfig);
plot(t,vin,'-k','LineWidth',4);
hold on;
plot(t,vins,'-ro','LineWidth',1,'MarkerSize',8);
grid on;
xlabel('Time - [sec]');ylabel('Amplitude - [V]');
legend('vin','vins');
nfig=nfig+1;

figure(nfig);
plot(t,vin,'-k','LineWidth',4);
hold on;
plot(t,vins,'-ro','LineWidth',1,'MarkerSize',8);
plot(t,vinsh,'m','LineWidth',2);
grid on;
xlabel('Time - [sec]');ylabel('Amplitude - [V]');
legend('vin','vins','vinsh');
nfig=nfig+1;

figure(nfig);
plot(t,vin,'-k','LineWidth',4);
hold on;
plot(t,vins,'-ro','LineWidth',1,'MarkerSize',8);
plot(t,vinsh,'m','LineWidth',2);
plot(t,vin-vinsh,'b','LineWidth',2);
grid on;
xlabel('Time - [sec]');ylabel('Amplitude - [V]');
legend('vin','vins','vinsh','error');
nfig=nfig+1;

%%% Quantization Plots
figure(nfig);
plot(t,vin,'-k','LineWidth',4);
hold on;
plot(t,vinsh,'m','LineWidth',2);
plot(t,vinq,'b','LineWidth',2);
grid on;
xlabel('Time - [sec]');ylabel('Amplitude - [V]');
legend('vin','vinsh','vinshq');
nfig=nfig+1;

figure(nfig);
plot(t,vin,'-k','LineWidth',4);
hold on;
plot(t,vinsh,'m','LineWidth',2);
plot(t,vinq,'b','LineWidth',2);
plot(t,eq,'r','LineWidth',2);
grid on;
xlabel('Time - [sec]');ylabel('Amplitude - [V]');
legend('vin','vinsh','vinshq','eq');
nfig=nfig+1;

figure(nfig);
plot(t,vin,'-k','LineWidth',4);
hold on;
plot(t,vins,'m','LineWidth',2);
plot(t,vinq,'b','LineWidth',2);
plot(t,eq,'r','LineWidth',2);
grid on;
xlabel('Time - [sec]');ylabel('Amplitude - [V]');
legend('vin','vins','vinshq','eq');
nfig=nfig+1;

% figure(nfig);
% plot(f,P1dB,'-k','LineWidth',2);
% hold on;
% xlabel('Frequency - [MHz]');ylabel('Output Power - [dBV_0_-_P_E_A_K]')
% grid on;

