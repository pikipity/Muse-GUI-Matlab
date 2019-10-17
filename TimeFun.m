function TimeFun(obj, event, hObject)
    handles=guidata(hObject);
    set(handles.Sys_time,'String',char(datetime('now','Format','yy-MM-dd HH:mm:ss')))
    set(handles.Recording_digital,'Value',handles.record_en)
    if handles.connect_en && ~isempty(handles.inlet)
        inlet=handles.inlet;
        inf=inlet.info();
        % srate
        srate=inf.nominal_srate();
        handles.fs=srate;
        set(handles.samplerate_text,'String',num2str(srate));
        % channel
        if isempty(handles.channel_name)
            ch_total_count=inf.channel_count();
            ch = inf.desc().child('channels').child('channel');
            channel_name=cell(1,ch_total_count);
            for ch_count=1:ch_total_count
                channel_name{ch_count}=ch.child_value('label');
                ch=ch.next_sibling();
            end
            handles.channel_name=channel_name;
        else
            ch_total_count=inf.channel_count();
            channel_name=handles.channel_name;
        end
        % get time data
        [chunk,timestamps]=inlet.pull_chunk();
        if isempty(chunk)
            [~,~]=inlet.pull_chunk();
            [chunk,timestamps]=inlet.pull_chunk();
        end
        if ~isempty(chunk)
            datapoint=floor(handles.winlen*srate);
            if isempty(handles.timedata)
                handles.t_axis=linspace(0,handles.winlen-1/srate,datapoint);
                handles.t_axis=handles.t_axis-handles.t_axis(end);
                handles.timedata=zeros(ch_total_count,datapoint);
            end
            chunk=detrend(chunk')';
            timestamps=timestamps-timestamps(1)+handles.t_axis(end)+1/srate;
            if handles.record_en && ~isempty(handles.record_path)
                if exist(handles.record_path,'file')
                    dlmwrite(handles.record_path,[timestamps;chunk]','-append','delimiter',',')
                else
                    writetable(cell2table(channel_name),handles.record_path,'WriteVariableNames',0)
                end
            end
            in_len=size(chunk,2);
            if in_len>datapoint
                chunk=chunk(:,end-datapoint+1:end);
                timestamps=timestamps(:,end-datapoint+1:end);
                in_len=size(chunk,2);
            end
            handles.t_axis(:,1:datapoint-in_len)=handles.t_axis(:,in_len+1:end);
            handles.t_axis(:,datapoint-in_len+1:end)=timestamps;
            handles.timedata(:,1:datapoint-in_len)=handles.timedata(:,in_len+1:end);
            handles.timedata(:,datapoint-in_len+1:end)=chunk;
            % filter
%             handles.timedata(1:end-1,:)=filtfilt(handles.notch_filter.notchB,handles.notch_filter.notchA,handles.timedata(1:end-1,:)')';
            if handles.bandpass_filter.en
                handles.timedata=filtfilt(handles.bandpass_filter.b,handles.bandpass_filter.a,handles.timedata')';
            end
            if handles.ica_para.en
                if handles.ica_para.numic>ch_total_count-1
                    handles.ica_para.numic=ch_total_count-1;
                    set(handles.numofic_text,'String',num2str(handles.ica_para.numic));
                    if max(handles.ica_para.removedic)>=handles.ica_para.numic
                        handles.ica_para.removedic=1:2;
                        set(handles.removedic_1_text,'String',num2str(min(handles.ica_para.removedic)));
                        set(handles.removedic_2_text,'String',num2str(max(handles.ica_para.removedic)));
                    end
                end
                [icasig, A, ~] = fastica(handles.timedata(1:end-1,:),'numOfIC',handles.ica_para.numic,...
                                         'verbose','off','displayMode','off');
                keepic=setdiff(1:size(icasig,1),handles.ica_para.removedic);
                handles.timedata(1:end-1,:)=A(:,keepic)*icasig(keepic,:);
            end
            % plot time data
            plot_data=handles.timedata;
            Y_Tick=zeros(1,ch_total_count);
            for ch_count=1:ch_total_count
                plot_data(ch_count,:)=plot_data(ch_count,:)./(max(plot_data(ch_count,:))-min(plot_data(ch_count,:))).*100;
                plot_data(ch_count,:)=plot_data(ch_count,:)+120*(ch_count-1);
                Y_Tick(ch_count)=0+120*(ch_count-1);
            end
            plot(handles.time_domain_fig,handles.t_axis,plot_data');
            set(handles.time_domain_fig,'YTick',Y_Tick);
            set(handles.time_domain_fig,'YTickLabel',channel_name)
            set(handles.time_domain_fig, 'XLimMode', 'manual', 'XLim', [min(handles.t_axis) max(handles.t_axis)])
            set(handles.time_domain_fig, 'YLimMode', 'manual', 'YLim', [min(Y_Tick)-100 max(Y_Tick)+100])
            % plot freq data
            [ frequency,plot_data ] = fft_plot(plot_data,srate);
            frequency=frequency(1,:);
            plot_data=2*abs(plot_data);
            Y_Tick=zeros(1,ch_total_count);
            for ch_count=1:ch_total_count
                plot_data(ch_count,:)=plot_data(ch_count,:)./(max(plot_data(ch_count,:))-min(plot_data(ch_count,:))).*100;
                plot_data(ch_count,:)=plot_data(ch_count,:)+120*(ch_count-1);
                Y_Tick(ch_count)=0+120*(ch_count-1);
            end
            plot(handles.freq_domain_fig,frequency,plot_data');
            set(handles.freq_domain_fig,'YTick',Y_Tick);
            set(handles.freq_domain_fig,'YTickLabel',channel_name)
            set(handles.freq_domain_fig, 'XLimMode', 'manual', 'XLim', [min(frequency) max(frequency)])
            set(handles.freq_domain_fig, 'YLimMode', 'manual', 'YLim', [min(Y_Tick)-100 max(Y_Tick)+100])
        end
    end
    guidata(hObject, handles);
end