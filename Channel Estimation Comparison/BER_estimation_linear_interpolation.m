clear all
close all
clc
format long %--------------------------------------------------------------��ʾ15λ���������

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����Ԥ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pilot_inter=5;%------------------------------------------------------------��Ƶ���5
N_carrier=256;%------------------------------------------------------------���ز���256��
channel_type = 'EPA';%-----------------------------------------------------��Ϊ�������涨���EPA�ŵ���������ŵ����Ƶ�
j=sqrt(-1);%---------------------------------------------------------------�ͱ�ʾ����i
cp_length=16;%-------------------------------------------------------------ѭ��ǰ׺����16
SNR_dB=1:2:26;%------------------------------------------------------------��������ο���ȡֵ��15��20��25dB
modemNum =16;%-------------------------------------------------------------64QAM
loop_num=1;%---------------------------------------------------------------ѭ����һ��
ofdm_symbol_num=100;%------------------------------------------------------OFDM������100��
sample_rate = 3.84e6;%-----------------------------------------------------������3840000
t_interval = 1/sample_rate;%-----------------------------------------------����ʱ�������ǲ����ʵĵ�����Ϊ��ɢ�ŵ�����ʱ����������OFDM���ų���/(���ز�����+cp����lp)
fd=10;%--------------------------------------------------------------------������Ƶ��10Hz
counter=200000;%-----------------------------------------------------------������200000

if(channel_type ==  'EPA')%------------------------------------------------EPA�ŵ���7��·����ʱ��ֵ�Ѿ�����
    delay = ([0 30 70 90 110 190 410])*1e-9;
    pathNum = 7;
elseif(channel_type ==  'EVA')%--------------------------------------------EVA�ŵ���9��·����ʱ��ֵ�Ѿ�����
    delay =  ([0 30 150 310 370 710 1090 1730 2510])*1e-9;
    pathNum = 9;
elseif(channel_type ==  'ETU')%--------------------------------------------ETUI�ŵ���9��·����ʱ��ֵ�Ѿ�����
    delay =  ([0 50 120 200 230 500 1600 2300 5000])*1e-9;
    pathNum = 9;
else
    error('Channel mode WRONG!!!');
end

trms = mean(delay);%-------------------------------------------------------ȡƽ��ʱ��ֵ
var_pow=10*log10(exp(-delay/trms));%---------------------------------------�������������ƽ������,��λdB
% trms_1=trms;
% t_max=max(delay);
trms_1=trms/t_interval;%---------------------------------------------------trmsΪ�ྭ�ŵ���ƽ����ʱ���˴����е�ʱ�䶼���Ѿ��Բ���������˹�һ����Ľ��
t_max=max(delay)/t_interval;%----------------------------------------------%t_maxΪ�����ʱ,�˴����е�ʱ�䶼���Ѿ��Բ���������˹�һ����Ľ��

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%���濪ʼ%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(SNR_dB)
    
    LS_error_num = 0;%-----------------------------------------------------LS������
    DFT_error_num = 0;%----------------------------------------------------
    LMMSE_error_num = 0;%--------------------------------------------------
    SVD_error_num = 0;%----------------------------------------------------
    MMSE_error_num = 0;%---------------------------------------------------
    
    for l=1:loop_num%------------------------------------------------------ѭ��һ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%���ɵ�Ƶ����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pilot_symbol = 2*randi([0,1])-1  + (2*randi([0,1])-1)*j;%----------��Ƶֻ��һ������Ƶ��ʲô����-1+1j
        bit_source=randi([0 1],N_carrier*ofdm_symbol_num*log2(modemNum),1);%����0����1������ֲ�������N_carrier*ofdm_symbol_num*log2(modemNum)=153600��*1��
        nbit=length(bit_source);%------------------------------------------��Ҫ���Ƶ�bit���ݵĳ���
       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%64QAM����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %h = modem.pskmod('M', modemNum, 'SymbolOrder', 'Gray', 'InputType', 'bit');
        h = modem.qammod('M', modemNum, 'SymbolOrder', 'Gray', 'InputType', 'bit');
        %------------------------------------------------------------------����һ������ϵͳ������64QAM��ʹ�ø����룬��������������bit       
        map_out_pre = modulate(h, bit_source);
        %------------------------------------------------------------------64QAM����       
        map_out = reshape(map_out_pre,N_carrier,ofdm_symbol_num);
        %------------------------------------------------------------------����reshape�����õ��ĵ������б�� N_carrier��*fdm_symbol_num�У���256��*100�еĵ��Ʒ��ž������Ｔ����100���źŷ��ź�256����Ƶ 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%���뵼Ƶ����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        [insert_pilot_out,pilot_num,pilot_sequence]=insert_pilot(pilot_inter,pilot_symbol,map_out);
        %------------------------------------------------------------------���õ�Ƶ���뺯�������뵼Ƶ�������Ƶ���ݣ���Ƶ��ʲô�������Լ��õ���256��*100�е��ѵ��ź�
        %------------------------------------------------------------------���������������֣����뵼Ƶ������С����뵼Ƶ�ĸ��������뵼Ƶ���ݣ����뵼Ƶ���ų�ʲô����
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%IFFTģ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        ofdm_modulation_out=ifft(insert_pilot_out,N_carrier);%-------------�Ե��뵼Ƶ������н���256��FFT��任���任��ʱ��
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����ѭ���������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
        
        ofdm_cp_out=insert_cp(ofdm_modulation_out,cp_length);
        %------------------------------------------------------------------����ѭ��ǰ׺���뺯��������ʱ���źź�ѭ��ǰ׺����
              
        %counter=200000;%�����ŵ��Ĳ���������Ӧ�ô����ŵ��������������������������ŵ���������
        %count_begin=(l-1)*(5*counter);%ÿ�η����ŵ������Ŀ�ʼλ��
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����ת��+���ŵ�%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %passchan_ofdm_symbol=multipath_chann(ofdm_cp_out,pathNum,var_pow,delay,fd,t_interval,counter,count_begin);
        %�õ�7��*32640�е�ͨ���ŵ�֮���7��·������Ӧ��������Ƶ��˥���ԣ�
        %�����˼·�����⣺��Ϊ����OFDM��ԭ��ͼ��Ӧ��Ҫ�Ƚ��ź����б�ɴ������ݣ�Ȼ���ͨ���ŵ���������ı�̲�û�в���ת��
        
        serial_ofdm_cp_out = reshape(ofdm_cp_out,272*120,1);%--------------���������ͽ�����ѭ��ǰ׺����źű�ɴ��е�����
         [Ts, Fd, Tau, Pdb]=LTEchannel(channel_type);%---------------------��EPA�ŵ������Եõ���Ӧ�Ĳ���
         Fading_chan= rayleighchan(Ts, Fd, Tau, Pdb);%---------------------������õ��Ĳ������������ŵ�ģ��
         passchan_ofdm_symbol = filter(Fading_chan,serial_ofdm_cp_out);%---�Դ��������������ŵ�ģ�Ͷ�������˲���Ȼ��͵õ�ͨ���ŵ�����������
         passchan_nonoise_matrix = reshape(passchan_ofdm_symbol,272,120);%-��ͨ���ŵ�˥����ķ����ٴα��272��*120�е��źž���
        
%%%%%%%%%%%%%%%%%%%%%%%%%ofdm���żӸ�˹������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        receive_ofdm_symbol=awgn(passchan_ofdm_symbol,SNR_dB(i),'measured'); %�������ŵ�˥�����ź������ٸ����ϸ�˹������
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ȥ��ѭ��ǰ׺%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        passchan_withnoise_parallel = reshape(receive_ofdm_symbol,272,120);%-���Ӹ�˹������֮�󣬽����������������ٴ�ת��Ϊ��������
       
        cutcp_ofdm_symbol_nonoise=cut_cp(passchan_nonoise_matrix,cp_length);
        %------------------------------------------------------------------ȥ��ѭ��ǰ׺,�����ź���272��*120�У�û�и��Ӹ�˹������
        cutcp_ofdm_symbol=cut_cp(passchan_withnoise_parallel,cp_length);
        %------------------------------------------------------------------ȥ��ѭ��ǰ׺�������ź���272��*120�У������˸�˹������
        
        var(i)=sum(sum(abs(cutcp_ofdm_symbol-cutcp_ofdm_symbol_nonoise).^2))/(N_carrier*ofdm_symbol_num);  
        %------------------------------------------------------------------����������ķ���

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FFTģ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        ofdm_demodulation_out_nonoise=fft(cutcp_ofdm_symbol_nonoise,N_carrier);
        %------------------------------------------------------------------FFTģ�顢�����ź���256��*120�У�û�и��Ӹ�˹������
        ofdm_demodulation_out=fft(cutcp_ofdm_symbol,N_carrier);
        %------------------------------------------------------------------FFTģ�顢�����ź���256��*120�У������˸�˹������
        
%%%%%%%%%%%%%�ص㣺���¾��ǶԽ���OFDM�źŽ����ŵ����ƺ��źż��Ĺ���%%%%%%%%%%
        snr=10^(SNR_dB(i)/10);%----------------------------------------------------------------------------------������ȵ�dBֵ��Ϊ��ֵ
        H_real=ls_estimation(ofdm_demodulation_out_nonoise,pilot_inter,pilot_sequence);%-------------------------ͨ��FFT��û�и��Ӹ�˹���������ź���Ϊ�ŵ����в�������ʵֵ
        H_LS=ls_estimation(ofdm_demodulation_out,pilot_inter,pilot_sequence);%-----------------------------------LS�ŵ�����
        H_DFT=ls_DFT_estimation(ofdm_demodulation_out,pilot_inter,pilot_sequence,cp_length);%--------------------LS_DFT�ŵ�����
        H_LMMSE=lmmse_estimation(ofdm_demodulation_out,pilot_inter,pilot_sequence,trms_1,t_max,snr);%------------LMMSE�ŵ�����
        H_SVD=lr_lmmse_estimation(ofdm_demodulation_out,pilot_inter,pilot_sequence,trms_1,t_max,snr,cp_length);%-SVD�ŵ�����
        H_MMSE=mmse_estimation(ofdm_demodulation_out,pilot_inter,pilot_sequence,trms_1,t_max,var(i));%-----------MMSE�ŵ�����
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ͳ��MSE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        MSE_LS(l)=sum(sum(abs(H_LS-H_real).^2))/(N_carrier*ofdm_symbol_num/pilot_inter);%------------------------����ƽ���������ŵ�����ʵ�ŵ�ÿ��Ԫ��֮��Ĳ�ֵ��ƽ����
        MSE_DFT(l)=sum(sum(abs(H_DFT-H_real).^2))/(N_carrier*ofdm_symbol_num/pilot_inter);%----------------------���H_real��������real��
        MSE_LMMSE(l)=sum(sum(abs(H_LMMSE-H_real).^2))/(N_carrier*ofdm_symbol_num/pilot_inter);
        MSE_SVD_MMSE(l)=sum(sum(abs(H_SVD-H_real).^2))/(N_carrier*ofdm_symbol_num/pilot_inter);
        MSE_MMSE(l)=sum(sum(abs(H_MMSE-H_real).^2))/(N_carrier*ofdm_symbol_num/pilot_inter);
        
     
%%%%%%%%%%%%%%%%%%%%%%%%%%ʱ�����Բ�ֵ�����ݻָ�%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        LS_data  = linear_interpolation(ofdm_demodulation_out,H_LS,pilot_inter);%----------------------------------ʱ���ֵ������OFDM���Ų���100����������ô�����95����
        DFT_data  = linear_interpolation(ofdm_demodulation_out,H_DFT,pilot_inter);
        LMMSE_data  = linear_interpolation(ofdm_demodulation_out,H_LMMSE,pilot_inter);
        SVD_data  = linear_interpolation(ofdm_demodulation_out,H_SVD,pilot_inter);
        MMSE_data  = linear_interpolation(ofdm_demodulation_out,H_MMSE,pilot_inter);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ��� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %H_demod = modem.pskdemod('M', modemNum, 'SymbolOrder', 'Gray', 'OutputType', 'bit');%
        H_demod = modem.qamdemod('M', modemNum, 'SymbolOrder', 'Gray', 'OutputType', 'bit');%----------------------�źŽ��
        LS_demod_bit = demodulate(H_demod,LS_data);%---------------------------------------------------------------OFDM���Ų���100����������ôҲ�����95����
        DFT_demod_bit = demodulate(H_demod,DFT_data);
        LMMSE_demod_bit = demodulate(H_demod,LMMSE_data);
        SVD_demod_bit = demodulate(H_demod,SVD_data);
        MMSE_demod_bit = demodulate(H_demod,MMSE_data);
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ͳ�ƴ���bit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        for m = 1:ofdm_symbol_num - pilot_inter%---------------------------ֻͳ����95��OFDM�����BER���
            for n = 1:N_carrier*log2(modemNum);
                if (LS_demod_bit(n,m) ~= bit_source((m-1)*N_carrier*log2(modemNum) + n))
                    LS_error_num = LS_error_num +1;
                end
                if (DFT_demod_bit(n,m) ~= bit_source((m-1)*N_carrier*log2(modemNum) + n))
                    DFT_error_num = DFT_error_num +1;
                end
                if (LMMSE_demod_bit(n,m) ~= bit_source((m-1)*N_carrier*log2(modemNum) + n))
                    LMMSE_error_num = LMMSE_error_num +1;
                end
                if (SVD_demod_bit(n,m) ~= bit_source((m-1)*N_carrier*log2(modemNum) + n))
                    SVD_error_num = SVD_error_num +1;
                end
                if (MMSE_demod_bit(n,m) ~= bit_source((m-1)*N_carrier*log2(modemNum) + n))
                    MMSE_error_num = MMSE_error_num +1;
                end
            end
        end
        
%    LS_BER(l) = LS_error_num / ((ofdm_symbol_num - pilot_inter)*N_carrier*log2(modemNum));
%    DFT_BER(l) = DFT_error_num / ((ofdm_symbol_num - pilot_inter)*N_carrier*log2(modemNum));
%    MMSE_BER(l) = MMSE_error_num / ((ofdm_symbol_num - pilot_inter)*N_carrier*log2(modemNum));
%    LMMSE_BER(l) = LMMSE_error_num / ((ofdm_symbol_num - pilot_inter)*N_carrier*log2(modemNum));
%    SVD_BER(l) = SVD_error_num / ((ofdm_symbol_num - pilot_inter)*N_carrier*log2(modemNum));
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MSE_LS_dB(i)=mean(MSE_LS);%--------------------------------------------������ƽ����ƽ����������Ǿ������
    MSE_DFT_dB(i)=mean(MSE_DFT);
    MSE_MMSE_dB(i)=mean(MSE_MMSE);
    MSE_LMMSE_dB(i)=mean(MSE_LMMSE);
    MSE_SVD_MMSE_dB(i)=mean(MSE_SVD_MMSE);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%% BER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Num_bit= ((ofdm_symbol_num - pilot_inter)*N_carrier*log2(modemNum));%--��������
    LS_BER_dB(i) = LS_error_num /Num_bit;
    DFT_BER_dB(i) = DFT_error_num / Num_bit;
    MMSE_BER_dB(i) = MMSE_error_num / Num_bit;
    LMMSE_BER_dB(i) = LMMSE_error_num / Num_bit;
    SVD_BER_dB(i) = SVD_error_num /Num_bit;
    
end

figure(1);
semilogy(SNR_dB,MSE_LS_dB,'-ro',SNR_dB,MSE_DFT_dB,'-black^',SNR_dB,MSE_MMSE_dB,'-bo',SNR_dB,MSE_LMMSE_dB,'-c+',SNR_dB,MSE_SVD_MMSE_dB,'--md','LineWidth',1.5);
legend('LS','IDFT-DFT','MMSE','LMMSE','SVD-MMSE');
grid on
xlabel('SNR-dB');
ylabel('MSE');
title('�ŵ������㷨MSE���ܱȽ�');

% saveas(gcf, 'C:\Users\Administrator\Desktop\Simulation_diagram\�ŵ�����EPA_Fd10_MSE_64QAM_256_20', 'fig');

figure(2);
semilogy(SNR_dB,LS_BER_dB,'-ro',SNR_dB,DFT_BER_dB,'-black^',SNR_dB,MMSE_BER_dB,'-bo',SNR_dB,LMMSE_BER_dB,'-c+',SNR_dB,SVD_BER_dB,'--md','LineWidth',1.5);
legend('LS','IDFT-DFT','MMSE','LMMSE','SVD-MMSE');
grid on
xlabel('SNR-dB');
ylabel('BER');
title('�ŵ������㷨BER���ܱȽ�');

% saveas(gcf,  'C:\Users\Administrator\Desktop\Simulation_diagram\�ŵ�����EPA_Fd10_BER_64QAM_256_20', 'fig');
