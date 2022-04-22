%Storing original audio and the sampling rate
[original_audio,fs] = audioread("tryst.wav");

%Creating a Butterworth filter of order 4 and normalized cutoff
%2*pi*1600/fs
[num_lowpass, den_lowpass] = butter(4,2000/(fs));

%Adding AWGN to the original audio
noise_audio = original_audio(:,1)+0.1*rand(size(original_audio(:,1)));

%Audio after passing through the low pass filter
low_pass = filter(num_lowpass,den_lowpass,noise_audio(:,1));

%Obtaining the audio after passing through a wiener filter with window size
%50 (Weighing over 50 data points)
wiener_audio = wiener2(noise_audio,[50 1],'gaussian');

%Calculating Discrete Wavelet coefficients using 5 levels and Daubechies
%Mother Wavelet of 4 vanishing moments.

[wav_tran,l] = wavedec(noise_audio,5,'db4');

%Thresholding the coefficients with parameter 0.05
filter_wave_tran = wthresh(wav_tran,'s',0.05);

%Recreating the audio using the new coefficients
wavelet_audio = waverec(filter_wave_tran,l,'db4');

%Gains of different audios to better hear the audios
% gain_noise = 1;
% gain_wiener = 2;
% gain_wavelet =2;
% 
%Plots of audios in time domain
subplot(3,2,1)
plot(original_audio(:,1))
title('Original Audio')
subplot(3,2,3)
plot(noise_audio(:,1))
title('Noisy Audio')
subplot(3,2,5)
plot(wavelet_audio)
title('Discrete Wavelet Transform Audio')
% 
%Calculating the fourier transform of audios
fft_data = fftshift(fft(noise_audio));
fft_data_wiener = fftshift(fft(wiener_audio(:,1)));
fft_data_wavelet = fftshift(fft(wavelet_audio));
% 
%Plots of audios in frequency domain
subplot(3,2,2)
plot(abs(fft_data(:,1)));
title('Noise Audio')
subplot(3,2,4)
plot(abs(fft_data_wiener(:,1)));
title('Wiener Filter Audio')
subplot(3,2,6)
plot(abs(fft_data_wavelet(:,1)));
title('Discrete Wavelet Transform Audio')

% %To listen to any of the sounds, uncomment any one of the lines below
% sound(original_audio(:,1),fs);
% sound(gain_noise*noise_audio(:,1),fs);
% sound(gain_wiener*wiener_audio(:,1),fs);
% sound(gain_wavelet*wavelet_audio(:,1),fs);

audiowrite('noise_tryst.wav',noise_audio(:,1),fs);
audiowrite('wiener_tryst.wav',wiener_audio(:,1),fs);
audiowrite('wavelet_tryst.wav',wavelet_audio(:,1),fs);

% MSE of different filter
MSE_wiener = sum((normalize(wiener_audio(:,1))-normalize(original_audio(:,1))).^2)/length(original_audio(:,1))
MSE_wavelet = sum((normalize(wavelet_audio(:,1))-normalize(original_audio(:,1))).^2)/length(original_audio(:,1))