%------------------------------------------------------------------------
% M-File:
%    read_lidar_faraday.m
%
% Authors:
%    H.M.J. Barbosa (hbarbosa@if.usp.br), IF, USP, Brazil
%    B. Hesse (heese@tropos.de), IFT, Leipzig, Germany
%
% Description
%
%    Reads data from Manaus/Embrapa Lidar in ascii format. This
%    version is based on original code written by Birgit Hesse, from
%    iFT, Leipzig. Cleaning, debugging, commenting and modification in
%    variable's names done by hbarbosa.
%
%    File format is shown below. Here only the glued elastic (355nm
%    column #4) and glued raman (387nm column #7) channels are used.
%
%    alt  355 An  355 PC  355 GL 387 An  387 PC  387 GL  407 PC
%     7.5  7.542  285.38  474.00  1.265   97.24   96.25  1.9387
%    15.0  7.343  282.61  461.47  1.241   94.71   94.45  1.8420
%    22.5  7.184  279.49  451.47  1.216   92.16   92.52  1.7977
%    30.0  7.018  276.89  441.07  1.185   89.55   90.21  1.7141
%    37.5  6.640  270.42  417.35  1.162   83.20   88.43  1.5305
%
% Input
%
%    filelist{1} - path and filename to list of embrapa files
%
% Ouput
%
%    rangebins - number of bins in lidar signal
%    r_bin     - vertical resolution in [m]
%    alt  (rangebins, 1) - altitude in [m]
%    altsq(rangebins, 1) - altitude squared in [m2]
%
%    P  (rangebins, 2) - signal to be processed (avg, bg, glue, etc...)
%    Pr2(rangebins, 2) - range corrected signal to be processed 
%
% Usage
%
%    Just execute this script.
%
%------------------------------------------------------------------------

clear nfile heads chphy altsq alt rangebins r_bin glue355 glue387 P Pr2

%%------------------------------------------------------------------------
%%  READ DATA
%%------------------------------------------------------------------------

%datain='/Volumes/work/DATA/EMBRAPA/lidar/data';

[nfile, heads, chphy]=profile_read_dates(datain, ...
					 jdi, jdf, 10, 0.004, 0, 4000);

if (nfile<1) return; end

%% RANGE IN METERS
rangebins=heads(1).ch(1).ndata;
alt(:,1)=(1:rangebins)*heads(1).ch(1).binw;

%%------------------------------------------------------------------------
%% RANGE CORRECTION AND OTHER SIGNAL PROCESSING
%%------------------------------------------------------------------------

% calculate the range^2 [m^2]
altsq = alt.*alt;

% bin height in m
r_bin=(alt(2)-alt(1)); 

% matrix to hold lidar received power P(z, lambda)
% anything user needs: time average, bg correction, glueing, etc..

%% GLUE ANALOG+PC
glue355=glue(chphy(1).data, heads(1).ch(1), chphy(2).data, heads(1).ch(2));
glue387=glue(chphy(3).data, heads(1).ch(3), chphy(4).data, heads(1).ch(4));

%glue355=chphy(1).data;
%glue387=chphy(3).data;

if (debug>0)
  figure(100)
  tmp=remove_bg(glue355, 500, -10);
  for j=1:nfile
    tmp(:,j)=tmp(:,j).*altsq(:);
  end
  gplot2(tmp(1:2000,:),[0:2e7:2e9],[],alt(1:2000)*1e-3);
  title([datestr(jdi) ' - ' datestr(jdf)]);
end

% number of photons should be summed and not averaged
P(:,1)=squeeze(nansum(glue355,2));
P(:,2)=squeeze(nansum(glue387,2));

% range corrected signal Pz2(z, lambda)
for j = 1:2
  Pr2(:,j) = P(:,j).*altsq(:);
end

%------------------------------------------------------------------------
%  Plots
%------------------------------------------------------------------------
if (debug<2)
  return
end

%
%
figure(1)
xx=xx0+1*wdx; yy=yy0+1*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
grid on
hold on
xlabel('signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
plot(P(:,1),alt*1.e-3,'b')
plot(P(:,2),alt*1.e-3,'c')
hold off
%
figure(2)
xx=xx0+2*wdx; yy=yy0+2*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
grid on
hold on
xlabel('RCS','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
plot(Pr2(:,1),alt*1.e-3,'b')
plot(Pr2(:,2),alt*1.e-3,'c')
hold off
% 
figure(3)
xx=xx0+3*wdx; yy=yy0+3*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
grid on
hold on
xlabel('log RCS','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
plot(log(P(:,1)),alt*1.e-3,'b')
plot(log(P(:,2)),alt*1.e-3,'c')
hold off
% 
% end of program read_lidar_faraday.m ***    
