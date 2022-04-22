% Read audio file 
[original_audio,fs]=audioread('tryst.wav');

% Add noise
y = original_audio(:,1)+0.1*rand(size(original_audio(:,1)));
x=y; 
Nx=length(x);

%Initialize parameters
apriori_SNR=1;  
alpha=0.05;      
beta1=0.5;
beta2=1;
lambda=2;

%STFT parameters
NFFT=4096;
window_length=round(0.03*fs); 
window=hamming(window_length);
window = window(:);
overlap=floor(0.2*window_length); 

% Define interval of noise
t_min=0;   
t_max=0.1; 

%Compute STFT for all frames
[S,F,T] = spectrogram(x+1i*eps,window,window_length-overlap,NFFT,fs); 
[Nf,Nw]=size(S);

%Find Noise power
t_index=find(T>t_min & T<t_max);
absS_vuvuzela=abs(S(:,t_index)).^2;
vuvuzela_spectrum=mean(absS_vuvuzela,2); 
vuvuzela_specgram=repmat(vuvuzela_spectrum,1,Nw);

%Compute the SNR of all frames
absS=abs(S).^2;
SNR_est=max((absS./vuvuzela_specgram)-1,0); 
if apriori_SNR==1
    SNR_est=filter((1-alpha),[1 -alpha],SNR_est); 
end    

% Calculate Attenuation map
att_map=max((1-lambda*((1./(SNR_est+1)).^beta1)).^beta2,0);
STFT=att_map.*S;

%Compute the inverse STFT
ind=mod((1:window_length)-1,Nf)+1;
output_signal=zeros((Nw-1)*overlap+window_length,1);
for indice=1:Nw 
    left_index=((indice-1)*overlap) ;
    index=left_index+[1:window_length];
    temp_ifft=real(ifft(STFT(:,indice),NFFT));
    output_signal(index)= output_signal(index)+temp_ifft(ind).*window;
end

%Plot Noise band and noisy audio
subplot(2,1,1);
t_index=find(T>t_min & T<t_max);
plot([1:length(x)]/fs,x);
xlabel('Time (s)');
ylabel('Amplitude');
hold on;
noise_interval=floor([T(t_index(1))*fs:T(t_index(end))*fs]);
plot(noise_interval/fs,x(noise_interval),'r');
hold off;
legend('Noisy signal','Noise Only');
title('Noisy Audio and initialization of Noise Band');

%Plot denoised audio
subplot(2,1,2);
plot([1:length(output_signal)]/fs,output_signal );
xlabel('Time (s)');
ylabel('Amplitude');
title('Denoised Sound');

%To listen to any audios uncomment below lines
%sound(x(:,1),Fe);
%sound(output_signal(:,1),Fe);

% Proposed lowpass filter
[num_lowpass, den_lowpass] = butter(2,2400/(fs));
low_pass = filter(num_lowpass,den_lowpass,output_signal(:,1));
%Audio of the lowpass filter
%sound(low_pass(:,1),fs);

% Write audio
audiowrite('vuvuzela_tryst.wav',output_signal,fs);
audiowrite('final_tryst.wav',low_pass,fs)

%Compute MSE
MSE_vuvuzela = sum((normalize(output_signal(:,1))-normalize(original_audio(1:length(output_signal),1))).^2)/length(original_audio(1:length(output_signal),1))