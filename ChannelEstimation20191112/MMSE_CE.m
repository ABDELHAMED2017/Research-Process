function [H_MMSE] = MMSE_CE(Y,Xp,pilot_loc,Nfft,Nps,h,SNR)
% MMSE Channel Estimation function
% Inputs:
%        Y         = Frequency_domain received signal
%        Xp        = Pilot signal
%        pliot_loc = Pilot Location
%        Nfft      = FFT size
%        Nps       = Pilot spacing
%        h         = Channel impulse response
%        SNR       = Signal-to-Noise Ratio[dB]
% Output:
%       H_MMSE     = MMSE channel estimation

snr = 10^(SNR*0.1);                                                        % �����dB����ֵת��
Np = Nfft/Nps;                                                             % ��Ƶ��

k = 1:Np;
H_tilde = Y(1,pilot_loc(k))./Xp(k);                                        % LS�ŵ�����

k = 0:length(h)-1;                                                         % k_ts = k*ts;
hh = h*h';
tmp = h.*conj(h).*k;                                                       % tmp = h.*conj(h).*k_ts;

r = sum(tmp)/hh;
r2 = tmp*k.'/hh;                                                           % r2 = tmp*k_ts.'/hh;

tau_rms = sqrt(r2-r^2);                                                    % rms delay ������ʵ�����������ƽ��ʱ��tau_rms
df = 1/Nfft;                                                               % 1/(Nfft*ts)
j2pi_tau_df = 1j*2*pi*tau_rms*df;

K1 = repmat((0:Nfft-1).',1,Np);                                            % K1,sK2�ܿ�������ֵ�õ�
K2 = repmat([0:Np-1],Nfft,1);

rf = 1./(1+j2pi_tau_df*(K1-K2*Nps));                                       %%?? ���������ڴˣ�Ϊʲô��Ҫʹ��(K1-K2*Nps)
%K1_K2chengNps = K1-K2*Nps;

K3 = repmat((0:Np-1).',1,Np);                                              % K3,K4�ܿ�������ֵ�õ�
K4 = repmat([0:Np-1],Np,1);

rf2 = 1./(1+j2pi_tau_df*Nps*(K3-K4));                                      %%?? �����ڴˣ�Ϊʲô��Ҫʹ��(K3-K4)*Nps

Rhp = rf;                                                                  % ����Ļ���غ�������ʵ�ŵ�h��LS�����ŵ�����p����أ�Ӧ����32��8��
                                                                           % 32����ʵ�ŵ����г��ȣ�8�ǹ��Ƴ����ŵ����г���
Rpp = rf2+ eye(length(H_tilde),length(H_tilde))/snr;                       % ����������������LS�����ŵ�����p������أ�Ӧ����8��8��

% z = autocorr(H_tilde);
% Rpp_test = toeplitz(z);
% Rpp_test1 = corrmtx()
% �����ñ�����������غ���Rpp����������Ľ�������ܺ������ƥ��

H_MMSE = transpose(Rhp*inv(Rpp)*H_tilde.');                                % ���и�������⹫ʽ

end