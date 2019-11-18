function [H_interpolated] = interpolate(H,pilot_loc,Nfft,method)
% Input: H           = Channel estimation using pilot sequence
%        pilot_loc   = Location of pilot sequence
%        Nfft        = FFT size
%        method      = 'linear'/'spline'
% Output:H_interpoltated = interpolated channel

if pilot_loc(1)>1                                                          % ΪʲôҪ���������֣�����Ϊmatlab�е����в�ֵ�� interp1(x,y,xi,'method')
    slope = (H(2)-H(1))/(piloc_loc(2)-pilot_loc(1));                       % Ҫ��x�ǵ����ģ�����xi���ܳ���x�ķ�Χ
    H = [H(1)-slope*(pilot_loc(1)-1) H];                                   % Ϊ�˽��в�ֵ����˼·��ʹ����ֵ���ƾ��������β����ֵ����
    pilot_loc = [1 pilot_loc];                                             % ����Ϊ�˱�֤��λ��1����ֵ���ο��ڲ幫ʽ
end

if pilot_loc(end)<Nfft                                                     % ����Ϊ�˱�֤βλ��Nfft����ֵ���ο��ڲ干ʶ                                 
    slope = (H(end)-H(end-1))/(pilot_loc(end)-pilot_loc(end-1));
    H = [H H(end)+slope*(Nfft-pilot_loc(end))];
    pilot_loc = [pilot_loc Nfft];
end

if lower(method(1))=='l'
    H_interpolated = interp1(pilot_loc,H,[1:Nfft]);
else
    H_interpolated = interp1(pilot_loc,H,[1:Nfft],'spline');
end

end