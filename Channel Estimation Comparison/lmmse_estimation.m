function output1=lmmse_estimation(input,pilot_inter,pilot_sequence,trms,t_max,snr)
%����256��*120�е��źž��󣬵�Ƶ���5����Ƶ����Xp��256��*1�У�snr������ȵ���ֵ
%trmsΪ�ྭ�ŵ���ƽ����ʱ���˴����е�ʱ�䶼���Ѿ��Բ���������˹�һ����Ľ����ֵΪ0.4937
%t_maxΪ�����ʱ,�˴����е�ʱ�䶼���Ѿ��Բ���������˹�һ����Ľ����ֵΪ1.5744

beta=17/9;%----------------------------------------------------------------16QAMʱϵ����17/9��64QAM��������������������
[N,NL]=size(input);%-------------------------------------------------------�����źž���Ĵ�С��N=256���У���NL=120���У�
Rhh=zeros(N,N);%-----------------------------------------------------------����ؾ���Ϊһ��256��*256�еķ���
j=sqrt(-1);%---------------------------------------------------------------����j

%%%%%%%%%%%%���븺ָ���ֲ�ʱ��������ŵ��������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k=1:N
    for l=1:N
        Rhh(k,l)=(1-exp((-1)*t_max*((1/trms)+j*2*pi*(k-l)/N)))./(trms*(1-exp((-1)*t_max/trms))*((1/trms)+j*2*pi*(k-l)/N));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%����LS�ŵ�����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=1;
count=1;
while i<=NL
    Hi(:,count)=input(:,i)./pilot_sequence;
    count=count+1;
    i=i+pilot_inter+1;
end

%%%%%%���ݹ�ʽHlmmse=Rhh*Hls*inv(Rhh+beta/snr*I)����LMMSE�ŵ�����%%%%%%%%%%%%
weiner_coeff=Rhh*inv(Rhh+(beta/snr)*eye(N));
output1=weiner_coeff*Hi;

%   output2=weiner_coeff^2*Hi;%%%���ݹ�ʽHlmmse=Rhh*Hls*inv(Rhh+beta/snr*I)
%   output3=weiner_coeff^3*Hi;
%   output1(:,count)=weiner_coeff*Hi;%%%���ݹ�ʽHlmmse=Rhh*Hls*inv(Rhh+beta/snr*I)
%   output2(:,count)=weiner_coeff^2*Hi;%%%���ݹ�ʽHlmmse=Rhh*Hls*inv(Rhh+beta/snr*I)
%   output3(:,count)=weiner_coeff^3*Hi;
  
  
  
% while i<=NL
%     Hi=input(:,i)./pilot_sequence;
%     weiner_coeff=Rhh*inv(Rhh+(beta/snr)*eye(N));
%     H_LMMSE=weiner_coeff*Hi;%%%���ݹ�ʽHlmmse=Rhh*Hls*inv(Rhh+beta/snr*I)
%     %        Rx_symbols_dft=ifft( H_LMMSE);%%%ֱ����iFFT
%     %        Rx_symbols_ifft_dft=zeros(N,1);%%%������һ��winnum*1�ľ���
%     %        Rx_symbols_ifft_dft(1:winnum,:)=Rx_symbols_dft(1:winnum,:);% ֻ����ѭ��ǰ׺����CP=winnum���ڵ��ŵ�����ֵ����ѭ��ǰ׺������Ϊ���ŵ�����ֵ��Ϊ0
%     %        Rx_training_symbols_dft=fft(Rx_symbols_ifft_dft);
%    H_LMMSE_iteration1=weiner_coeff^2*Hi;%%%���ݹ�ʽHlmmse=Rhh*Hls*inv(Rhh+beta/snr*I)
%    H_LMMSE_iteration2=weiner_coeff^3*Hi;
% %     H_LMMSE_iteration1=Rhh*inv(Rhh+(beta/snr)*eye(N))*H_LMMSE;%%%���ݹ�ʽHlmmse=Rhh*Hls*inv(Rhh+beta/snr*I)
% %     H_LMMSE_iteration2=Rhh*inv(Rhh+(beta/snr)*eye(N))*H_LMMSE_iteration1;
%     output1(:,count)= H_LMMSE;
%     output2(:,count)= H_LMMSE_iteration1;
%     output3(:,count)= H_LMMSE_iteration2;
%     
%     
%     count=count+1;
%     i=i+pilot_inter+1;
% end

