function features=scissionComputeFeature(data)
if(~isempty(data))
    data_mean=mean(data);
    data_std=std(data);
    data_var=var(data);
    data_skew=skewness(data);
    data_kurt=kurtosis(data);
    data_rms=rms(data);
    data_max=max(data);
    data_energy=data_rms^2;

    Nfft=2^(8);
    fft_val=fftshift(fft(data,Nfft));
    %f_vec=[0:1:Nfft-1]*Fsamp/Nfft-Fsamp/2;
    fft_data=abs(fft_val);%/Fsamp;

    fft_mean=mean(fft_data);
    fft_std=std(fft_data);
    fft_var=var(fft_data);
    fft_skew=skewness(fft_data);
    fft_kurt=kurtosis(fft_data);
    fft_rms=rms(fft_data);
    fft_max=max(fft_data);
    fft_energy=fft_rms^2;

    features=[data_mean,data_std,data_var,data_skew,data_kurt,data_rms,data_max,data_energy,...
              fft_mean,fft_std,fft_var,fft_skew,fft_kurt,fft_rms,fft_max,fft_energy];
else
    features=zeros(1,16);
end