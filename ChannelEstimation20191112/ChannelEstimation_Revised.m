
%% Channel Estimation_for LS/DFT Channel Estimation with linear/Spline interpolation_Revised
%% Revised_Revised_Revised_Revised_Revised_Revised_Revised_Revised_Revised_Revised_Revised_Revised
close all;
clc
clf                                                                        % �����ǰͼ�񴰿�

%% Paramter Setting
Nfft = 32;                                                                 % FFT����32
Ng = Nfft/8;                                                               % ѭ��ǰ׺����8
Nofdm = Nfft + Ng;                                                         % һ��OFDM�����ܹ���32+8=40��
Nsym = 100;                                                                % OFDM����ĿΪ100��
Nps = 4;                                                                   % ��Ƶ���4
Np = Nfft/Nps;                                                             % ��Ƶ��8
Nd = Nfft-Np;                                                              % ���ݵ�24 
Nbps = 4;
M = 2^Nbps;                                                                % ÿ�����ѵ��ƣ����ŵ�λ��16

% mod_object = modem.qammod('M',M,'SymbolOrder','gray');
% ���Ʋ���,modem.qammod�Ѿ���matlab�߼��汾ɾ��,ֱ��ʹ��qammod���Ƽ���
% demod_object = modem.qamdemod('M',M,'SymbolOrder','gray');              
% �������,modem,qamdemod�Ѿ���matlab�߼��汾ɾ��,ֱ��ʹ��deqammod�������

Es = 1;                                                                    % �ź�����
A = sqrt(3/2/(M-1)*Es);                                                    % QAM��һ������ 
SNRs = [30];                                                                  % �����30dB
sq2 = sqrt(2);                                                             % ����2

for i = 1:length(SNRs)
    SNR = SNRs(i);
    rand('seed',1);
    randn('seed',1);
    MSE = zeros(1,6);
    nose = 0;



















