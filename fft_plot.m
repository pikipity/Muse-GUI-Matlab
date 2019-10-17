function [ frequency,fft_result ] = fft_plot( data,Fs,varargin )
% Calculate or plot directly fft results of data.
%
% [ frequency,fft_result ] = fft_plot( data,Fs,'plot' )
% [ frequency,fft_result ] = fft_plot( data,Fs,'dbplot' )
%
% inputs:
%   (1) data: data used to analysis. one row -> one data
%   (2) Fs: sample frequency
%   (3) 'plot': veriable input. if there is not this input, fft results will not be
%   ploted
% output:
%   (1) freqeuncy: frequency corresponding to the fft results
%   (2) fft_result: fft results
NFFT=0;
plot_flag=0;
detrend_flag=1;
if isempty(varargin)
    plot_flag=0;
    detrend_flag=1;
else
    for n=1:length(varargin)
        if isstr(varargin{n}) && isequal(varargin{n},'plot')
            plot_flag=1;
        elseif isstr(varargin{n}) && isequal(varargin{n},'detrend')
            detrend_flag=2;    
        elseif isstr(varargin{n}) && isequal(varargin{n},'detrend')
            detrend_flag=1;
        elseif isstr(varargin{n}) && isequal(varargin{n},'noplot')
            plot_flag=0;
        elseif isstr(varargin{n}) && isequal(varargin{n},'nodetrend')
            detrend_flag=0;
        elseif isstr(varargin{n}) && isequal(varargin{n},'n')
            NFFT=varargin{n+1};
        end
    end
end


if nargin<2
    error('data and Fs must be given');
elseif nargin>=2 && plot_flag==0
    for k=1:size(data,1)
        size_data=size(data(k,:));
        if size_data(1)~=1 && size_data(2)~=1
            error('the length or the number of rows must be one.');
        end
        if detrend_flag==1
            data(k,:)=detrend(data(k,:));
        end
        L=length(data(k,:));
        if NFFT==0
            NFFT=2^nextpow2(L);
        else
%             NFFT=2^nextpow2(NFFT);
            NFFT=NFFT;
        end
        fft_result_temp=fft(data(k,:),NFFT)/length(data(k,:));
        fft_result(k,:)=fft_result_temp(1:NFFT/2+1);
        frequency(k,:)=Fs/2*linspace(0,1,NFFT/2+1);
    end
elseif nargin>=2 && plot_flag==1
    figure;
    title('FFT Amp')
    for k=1:size(data,1)
%         if strcmp(varargin,'plot')
             size_data=size(data(k,:));
            if size_data(1)~=1 && size_data(2)~=1
                error('the length or the number of rows must be one.');
            end
            if detrend_flag==1
                data(k,:)=detrend(data(k,:));
            end
            L=length(data(k,:));
            if NFFT==0
                NFFT=2^nextpow2(L);
            else
%               NFFT=2^nextpow2(NFFT);
                NFFT=NFFT;
            end
            fft_result_temp=fft(data(k,:),NFFT)/length(data(k,:));
            frequency(k,:)=Fs/2*linspace(0,1,NFFT/2+1);
            fft_result(k,:)=fft_result_temp(1:NFFT/2+1);
            subplot(size(data,1),1,k);
            plot(frequency(k,:),(2*abs(fft_result(k,:))));
            xlabel('Frequency (Hz)','Fontsize',16)
            ylabel('Amplitude','Fontsize',16)
%         else
%             error('variable input must be ''plot''');
%         end
    end
    figure;
    title('FFT Phase')
    for k=1:size(data,1)
%         if strcmp(varargin,'plot')
             size_data=size(data(k,:));
            if size_data(1)~=1 && size_data(2)~=1
                error('the length or the number of rows must be one.');
            end
            if detrend_flag==1
                data(k,:)=detrend(data(k,:));
            end
            L=length(data(k,:));
            if NFFT==0
                NFFT=2^nextpow2(L);
            else
                NFFT=2^nextpow2(NFFT);
            end
            fft_result_temp=fft(data(k,:),NFFT)/length(data(k,:));
            frequency(k,:)=Fs/2*linspace(0,1,NFFT/2+1);
            fft_result(k,:)=fft_result_temp(1:NFFT/2+1);
            subplot(size(data,1),1,k);
            plot(frequency(k,:),(angle(fft_result(k,:))/pi));
            xlabel('Frequency (Hz)','Fontsize',16)
            ylabel('Phase (pi)','Fontsize',16)
%         else
%             error('variable input must be ''plot''');
%         end
    end
elseif nargin>=2 && plot_flag==2
    figure;
    title('FFT Amp')
    for k=1:size(data,1)
%         if strcmp(varargin,'plot')
             size_data=size(data(k,:));
            if size_data(1)~=1 && size_data(2)~=1
                error('the length or the number of rows must be one.');
            end
            if detrend_flag==1
                data(k,:)=detrend(data(k,:));
            end
            L=length(data(k,:));
            if NFFT==0
                NFFT=2^nextpow2(L);
            else
                NFFT=2^nextpow2(NFFT);
            end
            fft_result_temp=fft(data(k,:),NFFT)/length(data(k,:));
            frequency(k,:)=Fs/2*linspace(0,1,NFFT/2+1);
            fft_result(k,:)=fft_result_temp(1:NFFT/2+1);
            subplot(size(data,1),1,k);
            plot(frequency(k,:),20.*log10(2*abs(fft_result(k,:))));
            xlabel('Frequency (Hz)','Fontsize',16)
            ylabel('Amplitude','Fontsize',16)
%         else
%             error('variable input must be ''plot''');
%         end
    end
    figure;
    title('FFT Phase')
    for k=1:size(data,1)
%         if strcmp(varargin,'plot')
             size_data=size(data(k,:));
            if size_data(1)~=1 && size_data(2)~=1
                error('the length or the number of rows must be one.');
            end
            if detrend_flag==1
                data(k,:)=detrend(data(k,:));
            end
            L=length(data(k,:));
            if NFFT==0
                NFFT=2^nextpow2(L);
            else
                NFFT=2^nextpow2(NFFT);
            end
            fft_result_temp=fft(data(k,:),NFFT)/length(data(k,:));
            frequency(k,:)=Fs/2*linspace(0,1,NFFT/2+1);
            fft_result(k,:)=fft_result_temp(1:NFFT/2+1);
            subplot(size(data,1),1,k);
            plot(frequency(k,:),(angle(fft_result(k,:))/pi));
            xlabel('Frequency (Hz)','Fontsize',16)
            ylabel('Phase (pi)','Fontsize',16)
%         else
%             error('variable input must be ''plot''');
%         end
    end
end
end


