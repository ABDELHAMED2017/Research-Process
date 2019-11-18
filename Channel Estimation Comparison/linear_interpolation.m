function output = linear_interpolation(received_data,H_estimation,pilot_inter)
%�������256��*126�о������֮����źž�����������Ϊ�����⣬Ӧ���Ƚ���20����Ƶ������ȡ������Ȼ����ܽ��н����
%���뾭����ͬ��ʽ�����ŵ�����֮��ĵ�Ƶλ�ô����ŵ���Ӧֵ
%��Ƶ�����5


[Ncarriers,NL]=size(received_data);%---------------------------------------���յ����źž���Ĵ�С��ΪNcarrier=256���У���NL=120���У�
[NCarriers,Npilot]=size(H_estimation);%------------------------------------�õ���Ƶλ�ô����ŵ���Ӧ����ֵ�����С��ΪNcarrier=256���У���Npilot=20���У�


H_data_plus_pilot = zeros(Ncarriers,NL-pilot_inter);%----------------------ȥ����Ƶ֮��Ľ���źž����С��ΪNcarrier=256���У���NL-pilot_inter=115(��)��������������

for j = 1:Npilot-1
    for i=1:Ncarriers
        H_data_plus_pilot(i, (pilot_inter+1)*(j-1)+1  :  (pilot_inter+1)*(j-1)+(pilot_inter+2) ) = linspace( H_estimation(i, j),   H_estimation(i, j+1), (pilot_inter+2));
    end
end


for i = 1:NL-pilot_inter
    recover_data(:, i ) = received_data(:, i)./H_data_plus_pilot(:,i );
end

OFDM_symbols = NL-Npilot-pilot_inter;

output = zeros(Ncarriers,OFDM_symbols);

for i = 1 : OFDM_symbols
    output(:, i) = recover_data(:, i+ceil(i/pilot_inter));
end

%�������������������������������������������������������������������������������������������Ը�������ʾ���ɣ���ò���֮ǰ�ù���interp1����


