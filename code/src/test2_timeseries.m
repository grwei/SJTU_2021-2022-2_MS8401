% this file is tsunami:/usra/mcduff/oc540/timeseries.m
% http://www2.ocean.washington.edu/oc540/lec01-12/matlab.html
echo on
hold off
whitebg
% Example of the time series numerical methods discussed in class, this
% demonstration applies "matlab" to a synthetic series of data
%
% First need to create our synthetic data.  Make our unit of time 1000 years
% = 1 ky and sample a 500,000 year record in 2 ky increments.  We first create
% a vector containing the times:
%

t=0:2:500;

% We want to have a record with multiple periodic components.  To mimic the
% expected orbital forcing, create a vector d, of the same length as vector t
% and with components that have periods of 100 ky, 41 ky and 21 ky, weighted
% 2.5:1.5:1, then plot it
echo off
axis ([0 500 -5 +8])
echo on

d=2.5*sin(2*pi*t/100)+1.5*sin(2*pi*t/41)+1*sin(2*pi*t/21);
plot(t,d,'b')
pause
clc

% We add some normally distributed random noise to the record:

dn=d+0.5*randn(size(d));
hold
plot(t,dn,'g')
pause
clc

% And also add a long term trend

dnt=dn+3*t/500;
plot(t,dnt,'r')
pause
clc

% Our time series has 251 elements.  To improve computation efficiency we will
% pad it with zeros and extended it to 256 elements (a multiple of 2).
% Taking the Fourier transform:

DNT=fft(dnt,256);
hold off
plot(real(DNT),'b')

% By convention, the inverse transform has elements equally spaced in
% frequency, with the first corresponding to f=0, then up to the Nyquist
% frequency at the middle of the record, then the negative frequencies from
% large to small in the remaining elements.

pause
clc
% The negative frequencies contain redundant
% information so we look only at the positive frequencies.  These frequencies
% are (for our 2 ky sampling interval the Nyquist frequency is 1/4 ky):

f=0.25*(0:128)/128;

% The power spectrum is estimated as:

PNT=DNT .* conj(DNT)/(256*256);

% (the norm of a complex number is the number multiplied by its complex
% conjugate):
% We are interested in the parts of this spectrum corresponding to positive
% frequencies

hold off
plot (f,PNT(1:129),'b')

% readily see the peaks at frequencies of about .01, .025 and .05 per ky
% the power is in approximate proportion to the amplitude squared (25:9:4
% or approximately 6:2:1)

% Notice the power present as the frequency goes to 0 corresponding to the
% long term trend.  This can be removed by detrending the data or for us
% working with the dn record.  Apply the same steps

pause
clc
DN=fft(dn,256);
PN=DN .* conj(DN)/(256*256);
hold
plot (f,PN(1:129),'g')

% The low frequency contamination is removed

pause
clc
hold off

% work with detrended dn record from now on
% apply a Hamming window to it first


z=hamming(251);
plot(z,'b')
pause
clc

dnz=dn .* z';
plot(dnz,'b')
pause
clc

% now do the power spectra (PNZ) and compare to the situation with no window
% (PN)

DNZ=fft(dnz,256);
PNZ=DNZ .* conj(DNZ)/(256*sum(z));
plot (f,PNZ(1:129),'b')
hold
plot (f,PN(1:129),'g')

pause
clc
hold off


% try to extract parts of record, say the 21 ky band
% need bandpass filter to let through frequencies between say .04 to .06 /ky

[b,a]=butter(5,[.04/.25 .06/.25]);
plot (filter(b,a,dn),'b')

% see about 500/21=24 cycles of amplitude 1 once 5 cycles into series

pause
clc


% also wanted to look at spectral characteristics of autocorrelated data

dna=xcorr(dn);
plot (dna,'b')

% no lag is in the middle, negative lag to left and positive to right, 
% symmetric because compared to self

pause
clc

% next find power spectra

DNA=fft(dna,512);
PNA=DNA .* conj(DNA)/(512*512);
f2=.25*(0:256)/256;
plot(f2,PNA(1:257),'b')

% get out same spectra working with the autocorrelation
% the difference being that the power is a measure of the variance due
% to that periodic component, i.e., most of the variance is explained by
% the 100 ky period
