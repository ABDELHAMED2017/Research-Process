function output=lr_lmmse_estimation(input,pilot_inter,pilot_sequence,trms,t_max,snr,NCP)
%trmsΪ�ྭ�ŵ���ƽ����ʱ��t_maxΪ�����ʱ,�˴����е�ʱ�䶼���Ѿ��Բ���������˹�һ����Ľ��
beta=17/9;
j=sqrt(-1);
[N,NL]=size(input);
Rhh=zeros(N,N);
for k=1:N
    for l=1:N
        Rhh(k,l)=(1-exp((-1)*t_max*((1/trms)+j*2*pi*(k-l)/N)))./(trms*(1-exp((-1)*t_max/trms))*((1/trms)+j*2*pi*(k-l)/N));
    end
end
%���¹����Ƕ�Rhh�����������ֵ�ֽ⣬��������ֵ��С�Ŷӣ�ѡ����16������ֵ
[U,D]=eig(Rhh);%UΪ��������D��������ֵΪ���Խ��ߵĶԽ���
dlamda=diag(D);%ȡD�Խ�Ԫ�ع���������
[dlamda_sort,IN]=sort(dlamda);%���������и�����ֵ��dlamda_sortΪ��������INΪ��Ԫ����ԭ�����е�λ������
for k=1:N
    lamda_sort(k)=dlamda_sort(N-k+1);%���ս������и�����ֵ
    IN_new(k)=IN(N-k+1);
end
%���°���IN_new˳������U�ĸ���
U_new=zeros(N,N);
for k=1:N
    U_new(:,k)=U(:,IN_new(k));
end
%����ֻȡǰcp������ֵ�����µĶԽ���
delta=zeros(N,1);
for k=1:N
    if k<=NCP
       delta(k)=lamda_sort(k)/(lamda_sort(k)+beta/snr);
    else
        delta(k)=0;
    end
end
D_new=diag(delta);
i=1;
count=1;
while i<=NL
    Hi=input(:,i)./pilot_sequence;
    output(:,count)=U_new*D_new*(U_new')*Hi;
    count=count+1;
    i=i+pilot_inter+1;
end
  
