function [H_LS] = LS_CE(Y,Xp,pilot_loc,Nfft,Nps,int_opt)
% LS Estimation
% Inputs:
%        Y         = Frequency_domain received signal
%        Xp        = Pilot signal
%        pliot_loc = Pilot Location
%        N         = FFT size
%        Nps       = Pilot spacing
%        int_opt   = 'linear' or 'spline'
% Output:
%        H_LS      = LS Channel Estimation

Np = Nfft/Nps;                                                             % ��Ƶ��
k = 1:Np;                                                                  % �������еĵ�Ƶλ��
LS_est(k) = Y(pilot_loc(k))./Xp(k);                                        % LS�ŵ����ƣ���Ƶλ�ô����ŵ����ƣ�

if lower(int_opt(1)=='l')                                                  % �жϲ�ֵ����
    method = 'linear';
else
    method = 'spline';
end

H_LS = interpolate(LS_est,pilot_loc,Nfft,method);                          % ��ֵ,�����interpolate���Լ�����ĺ���

end
