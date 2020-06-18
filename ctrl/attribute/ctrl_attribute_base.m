function [glav poboch] = ctrl_attribute_base(app, audio_signal, Nframe)
% % --------------------------------------------------
% Код программы алгоритмов интепретации просодических признаков

for i=1:(Nframe-1)
    c(i).slog=0;
    c(i).udarenie_OT=0;
    c(i).udarenie_OT_for_skorost=0;
    c(i).udarenie_E=0;
    %c(i).udarenie_E_pob=0;
    %c(i).udarenie_E_glavnoe=0;
    c(i).slovo=0; %слово может содержать несколько отрезков ЧОТ
    c(i).sintagma=0;
    c(i).predlogenie=0;
    c(i).class_prosod=0;
    c(i).udarenie_glavnoe=0;
    priznak_prosod(i)=0;
end

%разбивка на слоги по признаку voiced1
metka_sloga=0;
j=1;

for i=1:(Nframe-1)
    if (c(i).voiced1==1 && metka_sloga==0)
        slog(1,j)=i;
        metka_sloga=1;
        c(i).slog=1; %начало
    end
    if (c(i).voiced1==0 && metka_sloga==1)
        slog(2,j)=i-1;
        metka_sloga=0;
        j=j+1;
        c(i).slog=-1; %конец
    end
    if (i==(Nframe-1) && c(i).voiced1==1 && metka_sloga==1)
        slog(2,j)=i;
        metka_sloga=0;
        c(i).slog=-1; %конец
    end
end

%разбивка на слоги по признаку pitch>0
metka_sloga=0;
j=1;
for i=1:(Nframe-1)
    if (c(i).pitch>0 && metka_sloga==0)
        slog(1,j)=i;
        metka_sloga=1;
        c(i).slog=1; %начало
    end
    if (c(i).pitch<=0 && metka_sloga==1)
        slog(2,j)=i-1;
        metka_sloga=0;
        j=j+1;
        c(i).slog=-1; %конец
    end
    if (i==(Nframe-1) && c(i).pitch>0 && metka_sloga==1)
        slog(2,j)=i;
        metka_sloga=0;
        c(i).slog=-1; %конец
    end
end

%разбивка на слоги по признаку voiced
metka_sloga=0;
j=1;
for i=1:(Nframe-1)
    if (c(i).voiced==1 && metka_sloga==0)
        slog(1,j)=i;
        metka_sloga=1;
        c(i).slog=1; %начало
    end
    if (c(i).voiced==0 && metka_sloga==1)
        slog(2,j)=i-1;
        metka_sloga=0;
        j=j+1;
        c(i).slog=-1; %конец
    end
    if (i==(Nframe-1) && c(i).voiced==1 && metka_sloga==1)
        slog(2,j)=i;
        metka_sloga=0;
        c(i).slog=-1; %конец
    end
end

%определение места ударения на слоге - по максимуму ЧОТ
if size(slog)==[2, 1]
    length_slog=1;
else
    length_slog=length(slog);
end
for i=1:length_slog
    temp_OT=[];
    for j=slog(1,i):slog(2,i)
        temp_OT(j)=c(j).pitch;
    end
    [max_OT,max_OT_num]=max(temp_OT);
    if max_OT>0
        c(max_OT_num).udarenie_OT=2;
    end
end

%определение места ударения на слоге - по максимуму E
if size(slog)==[2, 1]
    length_slog=1;
else
    length_slog=length(slog);
end
for i=1:length_slog
    temp_E=[];
    for j=slog(1,i):slog(2,i)
        temp_E(j)=c(j).E;
    end
    [max_E,max_E_num]=max(temp_E);
    if max_E>0
        c(max_E_num).udarenie_E=1;
    end
end

%определение места ударения на слоге + членение на слоги - по максимуму и минимуму E
if size(slog)==[2, 1]
    length_slog=1;
else
    length_slog=length(slog);
end

for i=1:length_slog
    temp_E=[];
    for j=slog(1,i):slog(2,i)
        temp_E(1,j)=c(j).E;
        temp_E(2,j)=0;
    end
    
%вычисление перегибов в зависимости от отношения энергий двух сегментов
    if slog(2,i)-slog(1,i)>=5
    for j=(slog(1,i)+2):(slog(2,i)-2)
        if c(j-2).E<c(j-1).E && c(j-1).E<c(j).E && c(j).E>c(j+1).E && c(j+1).E>c(j+2).E141
            temp_E(2,j)=1;
            c(j).udarenie_E=1;
        end
        if c(j-2).E>c(j-1).E && c(j-1).E>c(j).E && c(j).E<c(j+1).E && c(j+1).E<c(j+2).E
            temp_E(2,j)=-1;
            c(j).udarenie_E=-1;
        end
        if j==2
            if (c(j-1).E>c(j).E && (c(j-1).E/c(j).E)>1.1)
                temp_E(2,j-1)=1;
                c(j-1).udarenie_E=1;
            end
        end
        if j==Nframe-2
            if (c(j+1).E>c(j).E && (c(j+1).E/c(j).E)>1.1)
                temp_E(2,j+1)=1;
                c(j+1).udarenie_E=1;
            end
        end
    end
    end

    if (slog(2,i)-slog(1,i))>2 && (slog(2,i)-slog(1,i))<5
    for j=(slog(1,i)+1):(slog(2,i)-1)
        if c(j-1).E<c(j).E && c(j).E>c(j+1).E
               temp_E(2,j)=1;
                c(j).udarenie_E=1;
        end
        if c(j-2).E>c(j-1).E && c(j-1).E>c(j).E && c(j).E<c(j+1).E && c(j+1).E<c(j+2).E
             temp_E(2,j)=-1;
             c(j).udarenie_E=-1;
         end
        if j==2
            if (c(j-1).E>c(j).E && (c(j-1).E/c(j).E)>1.1)
                temp_E(2,j-1)=1;
                c(j-1).udarenie_E=1;
            end
        end
        if j==Nframe-2
            if (c(j+1).E>c(j).E && (c(j+1).E/c(j).E)>1.1)142
                temp_E(2,j+1)=1;
                c(j+1).udarenie_E=1;
            end
        end
    end
    end

    [max_E,max_E_num]=max(temp_E(1,:));
    if max_E>1e8
        c(max_E_num).udarenie_E=2;
    end
end

t=1:(Nframe-1);
for i=1:(Nframe-1) aertE(i)=c(i).E; end
for i=1:(Nframe-1) aertudarenie_E(i)=c(i).udarenie_E; end
for i=1:(Nframe-1) aertu(i)=c(i).pitch; end
for i=1:(Nframe-1) aertudarenie_OT(i)=c(i).udarenie_OT; end
for i=1:(Nframe-1) aerta(i)=c(i).voiced1; end
%for i=1:(Nframe-1) aerty(i)=c(i).udarenie_E_glavnoe; end
%for i=1:(Nframe-1) aerts(i)=c(i).udarenie_E_pob; end
%for i=1:(Nframe-1) aerta(i)=c(i).voiced; end

%plot(t,aerty*1e10,'k',t,aertu,'g')
%plot(t,aerts*1e10,'k',t,aertu,'g')
plot(t,aertudarenie_OT*100,'k',t,aertu,'g',t,aerta*10,'k:',t,aertE/1e8,'r',t,aertudarenie_E*100,'r:');
%поиск переломов ЧОТ + поиск максимального ЧОТ на слоге + поиск самого
%максимального и минимального ЧОТ на аудиосообщении
%поиск переломов ЧОТ + поиск максимального ЧОТ на слоге + поиск самого
%максимального и минимального ЧОТ на аудиосообщении
%разбивка на слоги по признаку pitch>0 - специально для вычисения
%наименьшего ЧОТ
metka_sloga=0;
j=1;
for i=1:(Nframe-1)
    if (c(i).pitch>0 && metka_sloga==0)
        slog_OT(1,j)=i;
        metka_sloga=1;
        %c(i).slog_OT=1; %начало
    end
    if (c(i).pitch<=0 && metka_sloga==1)
        slog_OT(2,j)=i-1;
        metka_sloga=0;
        j=j+1;
        %c(i).slog_OT=-1; %конец
    end
    if (i==(Nframe-1) && c(i).pitch>0 && metka_sloga==1)
        slog_OT(2,j)=i;
        metka_sloga=0;
        %c(i).slog_OT=-1; %конец
    end
end

abs_max_OT=0;
abs_max_OT_num=0;
abs_min_OT=10000000;
abs_min_OT_num=0;
temp_abs_min_OT=10000000;
slog_abs_min_OT=10000000;
slog_abs_min_OT_num=0;
temp_abs_min_OT_num=0;

%вычисение наименьшего ЧОТ
if size(slog_OT)==[2, 1]
    length_slog_OT=1;
else
    length_slog_OT=length(slog_OT);
end
for i=1:length_slog_OT
    temp_OT=[];
    if slog_OT(2,i)-slog_OT(1,i)>2
        for j=1:(slog_OT(1,i)-1)
           temp_OT(j)=1e7;
        end
        
        for j=slog_OT(1,i):slog_OT(2,i)
            temp_OT(j)=c(j).pitch;
        end
    
        [min_OT,min_OT_num]=min(temp_OT);
        if min_OT>0 && min_OT<abs_min_OT
            abs_min_OT=min_OT;
            abs_min_OT_num=min_OT_num;
        end
    end
end

%вычисление перегибов ЧОТ и наибольшего ЧОТ
if size(slog)==[2, 1]
    length_slog=1;144
else
    length_slog=length(slog);
end

for i=1:length_slog
    temp_OT=[];
    for j=slog(1,i):slog(2,i)
        temp_OT(1,j)=c(j).pitch;
        temp_OT(2,j)=0;
    end
    if (slog(2,i)-slog(1,i))>2 %%&& (slog(2,i)-slog(1,i))<5
    for j=(slog(1,i)+1):(slog(2,i)-1)
        if c(j-1).pitch>0 && c(j-1).pitch<c(j).pitch && c(j).pitch>c(j+1).pitch &&
            c(j+1).pitch>0 %&& abs(c(j-1).pitch-c(j).pitch)>2 && abs(c(j).pitch-c(j+1).pitch)>2
        temp_OT(2,j)=1;
        c(j).udarenie_OT=1;
    end
    
    if c(j-1).pitch>0 && c(j-1).pitch>c(j).pitch && c(j).pitch<c(j+1).pitch &&
        c(j+1).pitch>0 && c(j).pitch>0 %&& abs(c(j-1).pitch-c(j).pitch)>2 && abs(c(j).pitch-
            c(j+1).pitch)>2
            temp_OT(2,j)=-1;
            c(j).udarenie_OT=-1;
    end
    
    if j==2
        if c(j-1).pitch>0 && c(j-1).pitch>c(j).pitch && c(j).pitch>0 % && abs(c(j-1).pitch-c(j).pitch)>2
            temp_OT(2,j-1)=1;
            c(j-1).udarenie_OT=1;
        end
    end

    if j>2
        if c(j-2).pitch<=0 && c(j-1).pitch>0 && c(j-1).pitch>c(j).pitch && c(j).pitch>0 %&& abs(c(j-1).pitch-c(j).pitch)>2
            temp_OT(2,j-1)=1;
            c(j-1).udarenie_OT=1;
        end
    end
    
    if j==Nframe-2
        if c(j+1).pitch>0 && c(j+1).pitch>c(j).pitch && c(j).pitch>0 %&&
            abs(c(j).pitch-c(j+1).pitch)>2
            temp_OT(2,j+1)=1;
            c(j+1).udarenie_OT=1;145
        end
    end
    
    if j<Nframe-2
        if c(j+2).pitch<=0 && c(j+1).pitch>0 && c(j+1).pitch>c(j).pitch && c(j).pitch>0 %&& abs(c(j).pitch-c(j+1).pitch)>2
            temp_OT(2,j+1)=1;
            c(j+1).udarenie_OT=1;
        end
    end
  end
    end

    [max_OT,max_OT_num]=max(temp_OT(1,:));
    if max_OT>abs_max_OT
        abs_max_OT=max_OT;
        abs_max_OT_num=max_OT_num;
    end
    if max_OT>0
        c(max_OT_num).udarenie_OT=2;
    end
end

c(abs_max_OT_num).udarenie_OT=3;
c(abs_min_OT_num).udarenie_OT=-3;

%вычисление диапазона изменения ЧОТ
diapazon_OT=abs_max_OT-abs_min_OT;
t=1:(Nframe-1);
for i=1:(Nframe-1) aertu(i)=c(i).pitch; end
for i=1:(Nframe-1) aerty(i)=c(i).udarenie_OT; end
for i=1:(Nframe-1) aerta(i)=c(i).voiced1; end

plot(t,aerty*100,'k',t,aertu,'g',t,aerta*10,'k:')

%сбор статистики по длительности пауз по voiced1
pauz_stat=[];
if size(slog)==[2, 1]
length_slog=1;
else
length_slog=length(slog);
end
for i=1:length_slog-1
    metka_ucheta_sloga=0;
    dlit_pauzi=slog(1,i+1)-slog(2,i)-1;
    if size(pauz_stat)==[2, 1]
        length_pauz_stat=1;
    else
        length_pauz_stat=length(pauz_stat);146
    end
    for j=1:length_pauz_stat
        if pauz_stat(1,j)==dlit_pauzi
            pauz_stat(2,j)=pauz_stat(2,j)+1;
            metka_ucheta_sloga=1;
        end
    end

if metka_ucheta_sloga==0
    pauz_stat(1,length_pauz_stat+1)=dlit_pauzi;%первая строка - длительности пауз
    pauz_stat(2,length_pauz_stat+1)=1;%вторая строка-число пауз длительностью из первой строки
end
end
%сбор статистики по длительности слогов по voiced1
slog_stat=[];
if size(slog)==[2, 1]
length_slog=1;
else
length_slog=length(slog);
end
for i=1:length_slog
metka_ucheta_sloga=0;
dlit_sloga=slog(2,i)-slog(1,i)+1;
if size(slog_stat)==[2, 1]
length_slog_stat=1;
else
length_slog_stat=length(slog_stat);
end
for j=1:length_slog_stat
if slog_stat(1,j)==dlit_sloga
slog_stat(2,j)=slog_stat(2,j)+1;
metka_ucheta_sloga=1;
end
end
if metka_ucheta_sloga==0
slog_stat(1,length_slog_stat+1)=dlit_sloga; % длина слога
slog_stat(2,length_slog_stat+1)=1; %число слогов
end
end
%сбор статистики по длительности пауз по pitch
pauz_stat_OT=[];
if size(slog_OT)==[2, 1]
length_slog_OT=1;
else147
length_slog_OT=length(slog_OT);
end
for i=1:length_slog_OT-1
    metka_ucheta_sloga=0;
    dlit_pauzi=slog_OT(1,i+1)-slog_OT(2,i)-1;
    if size(pauz_stat_OT)==[2, 1]
        length_pauz_stat=1;
    else
        length_pauz_stat=length(pauz_stat_OT);
    end
    for j=1:length_pauz_stat
        if pauz_stat_OT(1,j)==dlit_pauzi
            pauz_stat_OT(2,j)=pauz_stat_OT(2,j)+1;
            metka_ucheta_sloga=1;
        end
    end
    if metka_ucheta_sloga==0
        pauz_stat_OT(1,length_pauz_stat+1)=dlit_pauzi;%первая строка - длительности пауз
        pauz_stat_OT(2,length_pauz_stat+1)=1;%вторая строка - число пауз длительностью из первой строки
    end
end

%сбор статистики по длительности слогов по pitch
slog_stat_OT=[];
if size(slog_OT)==[2, 1]
    length_slog=1;
else
    length_slog=length(slog_OT);
end

for i=1:length_slog
    metka_ucheta_sloga=0;
    dlit_sloga=slog_OT(2,i)-slog_OT(1,i)+1;
    if size(slog_stat_OT)==[2, 1]
        length_slog_stat=1;
    else
        length_slog_stat=length(slog_stat_OT);
    end
    for j=1:length_slog_stat
        if slog_stat_OT(1,j)==dlit_sloga
            slog_stat_OT(2,j)=slog_stat_OT(2,j)+1;
            metka_ucheta_sloga=1;
        end
    end
    
    if metka_ucheta_sloga==0148
        slog_stat_OT(1,length_slog_stat+1)=dlit_sloga; % длина слога
        slog_stat_OT(2,length_slog_stat+1)=1; %число слогов
    end
end

%функция вычисления скорости изменения ОТ
slog_OT_skorost=[];
if size(slog_OT)==[2, 1]
    length_slog_OT=1;
else
    length_slog_OT=length(slog_OT);
end

k=1;
% вычисление отрезков увеличения/уменьшения ЧОТ
for i=1:length_slog_OT
  metka_nachala=slog_OT(1,i);
  for j=slog_OT(1,i):slog_OT(2,i)
        if j==slog_OT(1,i)
            slog_OT_skorost(1,k)=metka_nachala;
        end
    if j>slog_OT(1,i) && j<slog_OT(2,i)
        if c(j).udarenie_OT==1 || c(j).udarenie_OT==2 || c(j).udarenie_OT==3 ||
            c(j).udarenie_OT==-1 || c(j).udarenie_OT==-3
            slog_OT_skorost(2,k)=j;
            k=k+1;
            metka_nachala=j;
            slog_OT_skorost(1,k)=metka_nachala;
        end
    end
    if j==slog_OT(2,i)
        slog_OT_skorost(2,k)=slog_OT(2,i);
        k=k+1;
    end
  end
end

%вычисление скорости увеличения/уменьшения ЧОТ
%вычисление абсолютного приращения ЧОТ
if size(slog_OT_skorost)==[2, 1]
    length_slog_OT_skorost=1;
else
    length_slog_OT_skorost=length(slog_OT_skorost);
end

for i=1:length_slog_OT_skorost149
  if (slog_OT_skorost(2,i)-slog_OT_skorost(1,i))==0
      slog_OT_skorost(3,i)=0;
  end
  raznost=0;
  if (slog_OT_skorost(2,i)-slog_OT_skorost(1,i))>0
        slog_OT_skorost(3,i)=c(slog_OT_skorost(2,i)).pitch-
        c(slog_OT_skorost(1,i)).pitch; %абсолютное приращение ЧОТ
        %вычисление среднего приращения ЧОТ
    for j=(slog_OT_skorost(1,i)+1):slog_OT_skorost(2,i)
        delta=c(j).pitch-c(j-1).pitch;
        raznost=raznost+delta;
        if slog_OT_skorost(3,i)>0 && delta<0
            warning='ошибка!!!!!!!!!!!!!!!'
        end
        if slog_OT_skorost(3,i)<0 && delta>0
            warning='ошибка!!!!!!!!!!!!!!!'
        end
    end
    
        slog_OT_skorost(4,i)=raznost/(slog_OT_skorost(2,i)-
        slog_OT_skorost(1,i));%среднее приращение ЧОТ
  end
end

% определение слов, синтагм, предложений
% из этой проги для синтагм и предложений просто заменить слово slovo
slovo=[];
if size(slog_OT)==[2, 1]
    length_slog_OT=1;
else
    length_slog_OT=length(slog_OT);
end
k=1;
for i=1:length_slog_OT-1
    if i==1
        slovo(1,k)=slog_OT(1,i);
    end
    if i==length_slog_OT-1
        slovo(2,k)=slog_OT(2,length_slog_OT);
    end
    dlit_pauzi=slog_OT(1,i+1)-slog_OT(2,i)-1;150
    if dlit_pauzi>2 %этот параметр должен задаваться автоматически при обучении системы
        slovo(2,k)=slog_OT(2,i);
        k=k+1;
        slovo(1,k)=slog_OT(1,i+1);
    end
end

if size(slovo)==[2, 1]
    length_slovo=1;
else
    length_slovo=length(slovo);
end

for i=1:length_slovo
    for j=slovo(1,i):slovo(2,i)
        c(j).slovo=1;
    end
end
t=1:(Nframe-1);

for i=1:(Nframe-1) aertu(i)=c(i).pitch; end
for i=1:(Nframe-1) aerty(i)=c(i).udarenie_OT; end
for i=1:(Nframe-1) aerta(i)=c(i).slovo; end

plot(t,aerty*100,'k',t,aertu,'g',t,aerta*10,'k:')

if size(slog_OT_skorost)==[2, 1]
    length_slog_OT_skorost=1;
else
    length_slog_OT_skorost=length(slog_OT_skorost);
end

for i=1:length_slog_OT_skorost
    for j=slog_OT_skorost(1,i):slog_OT_skorost(2,i)
      if slog_OT_skorost(3,i)>0
        c(j).class_prosod=2;
        priznak_prosod(j)=2;
      end
     if slog_OT_skorost(3,i)<0
        c(j).class_prosod=-2;
        priznak_prosod(j)=-2;
     end
    end
end

% замена массива priznak
for i=1:Nframe-1151
    if c(i).class==2
        c(i).class_prosod=0;
        priznak_prosod(i)=0;
    end
    if c(i).class==1
        c(i).class_prosod=1;
        priznak_prosod(i)=1;
    end
  if c(i).class==0
        if c(i).udarenie_OT==2
            c(i).class_prosod=6;
            priznak_prosod(i)=6;
        end
    if c(i).udarenie_OT==1
        c(i).class_prosod=5;
        priznak_prosod(i)=5;
    end
    if c(i).udarenie_OT==3
        c(i).class_prosod=6;%7;
        priznak_prosod(i)=6;%7;
    end
    if c(i).udarenie_OT==-1
        c(i).class_prosod=-5;%3;
        priznak_prosod(i)=-5;%3;
    end
    if c(i).udarenie_OT==-3
        c(i).class_prosod=-5;%4;
        priznak_prosod(i)=-5;%4;
    end
  end
end

%функция вычисления интервалов изменения ЧОТ
raznost=fix(diapazon_OT/5);
interval1=abs_min_OT+raznost;
interval2=interval1+raznost;
interval3=interval2+raznost;
interval4=interval3+raznost;
if size(slog_OT_skorost)==[2, 1]
    length_slog_OT_skorost=1;
else
    length_slog_OT_skorost=length(slog_OT_skorost);
end

for i=1:length_slog_OT_skorost
%проверяем начало отрезка изменения ЧОТ
    if c(slog_OT_skorost(1,i)).pitch>=abs_min_OT
        c(slog_OT_skorost(1,i)).pitch<interval1
        slog_OT_skorost(5,i)=1;
    end

    if c(slog_OT_skorost(1,i)).pitch>=interval1
        c(slog_OT_skorost(1,i)).pitch<interval2
        slog_OT_skorost(5,i)=2;
    end
    if c(slog_OT_skorost(1,i)).pitch>=interval2
        c(slog_OT_skorost(1,i)).pitch<interval3
        slog_OT_skorost(5,i)=3;
    end

    if c(slog_OT_skorost(1,i)).pitch>=interval3
        c(slog_OT_skorost(1,i)).pitch<interval4
        slog_OT_skorost(5,i)=4;
    end
    if c(slog_OT_skorost(1,i)).pitch>=interval4
        c(slog_OT_skorost(1,i)).pitch<=abs_max_OT
        slog_OT_skorost(5,i)=5;
    end

%проверяем конец отрезка изменения ЧОТ
    if c(slog_OT_skorost(2,i)).pitch>=abs_min_OT
        c(slog_OT_skorost(2,i)).pitch<interval1
        slog_OT_skorost(6,i)=1;
    end
    if c(slog_OT_skorost(2,i)).pitch>=interval1
        c(slog_OT_skorost(2,i)).pitch<interval2
        slog_OT_skorost(6,i)=2;
    end
    if c(slog_OT_skorost(2,i)).pitch>=interval2
        c(slog_OT_skorost(2,i)).pitch<interval3
        slog_OT_skorost(6,i)=3;
    end
    if c(slog_OT_skorost(2,i)).pitch>=interval3
        c(slog_OT_skorost(2,i)).pitch<interval4
        slog_OT_skorost(6,i)=4;
    end
    if c(slog_OT_skorost(2,i)).pitch>=interval4
        c(slog_OT_skorost(2,i)).pitch<=abs_max_OT
        slog_OT_skorost(6,i)=5;
    end
end

%альтернативный способ построения последовательности
% замена массива priznak
j=1;
for i=1:Nframe-1
    if c(i).class==2
        c(i).class_prosod=0;
        priznak_prosod(i)=0;
    end
    if c(i).class==1
        c(i).class_prosod=1;
        priznak_prosod(i)=1;
    end
    if c(i).class==0
        if c(i).pitch>=abs_min_OT && c(i).pitch<interval1
            c(i).class_prosod=2;
            priznak_prosod(i)=2;
        end
    if c(i).pitch>=interval1 && c(i).pitch<interval2
        c(i).class_prosod=3;
        priznak_prosod(i)=3;
    end
    if c(i).pitch>=interval2 && c(i).pitch<interval3
        c(i).class_prosod=4;
        priznak_prosod(i)=4;
    end
    if c(i).pitch>=interval3 && c(i).pitch<interval4
        c(i).class_prosod=5;
        priznak_prosod(i)=5;
    end
    if c(i).pitch>=interval4 && c(i).pitch<=abs_max_OT
        c(i).class_prosod=6;
        priznak_prosod(i)=6;
    end
  end
end

for i=1:(Nframe-1)
    c(i).udarenie_glavnoe=0;
end

sdvig=2;%окно, в котором ищется наличие одновременно максимума ЧОТ и максимума Е
if size(slog_OT)==[2, 1]
    length_slog_OT=1;
else
    length_slog_OT=length(slog_OT);
end
for i=1:length_slog_OT
    for j=slog_OT(1,i):slog_OT(2,i)
        if c(j).udarenie_OT>0
           if j>sdvig && j<length(c)-sdvig
                for k=j-sdvig:j+sdvig
                    if c(k).udarenie_E==1
                        c(j).udarenie_glavnoe=1;
                    end
                    if c(k).udarenie_E==2
                        c(j).udarenie_glavnoe=2;
                    end
                end
           end
        if j<=sdvig && j<length(c)-sdvig
            for k=1:j+sdvig
                if c(k).udarenie_E==1
                    c(j).udarenie_glavnoe=1;
                end
                if c(k).udarenie_E==2
                    c(j).udarenie_glavnoe=2;
                end
            end
        end
        
        if j>sdvig && j>=length(c)-sdvig
            for k=j-sdvig:length(c)
                if c(k).udarenie_E==1
                    c(j).udarenie_glavnoe=1;
                end
                if c(k).udarenie_E==2
                    c(j).udarenie_glavnoe=2;
                end
            end
        end
        
    if j<=sdvig && j>=length(c)-sdvig
        for k=1:length(c)
          if c(k).udarenie_E==1
                c(j).udarenie_glavnoe=1;
          end
          if c(k).udarenie_E==2
             c(j).udarenie_glavnoe=2;
          end
        end
    end
   end
  end
end

t=1:(Nframe-1);
for i=1:(Nframe-1) aertE(i)=c(i).E; end
for i=1:(Nframe-1) aertudarenie_E(i)=c(i).udarenie_E; end
for i=1:(Nframe-1) aertu(i)=c(i).pitch; end
for i=1:(Nframe-1) aertudarenie_OT(i)=c(i).udarenie_OT; end
for i=1:(Nframe-1) aerta(i)=c(i).voiced1; end
for i=1:(Nframe-1) udar_glavnoe(i)= c(i).udarenie_glavnoe; end

plot(t,aertudarenie_OT*100,'k',t,aertu,'g',t,aerta*10,'k:',t,aertE/1e8,'r',t,aertudarenie_E*100,'r:',t,udar_glavnoe*100,'b')

%положение ударений относительно начала по pitch
if size(slog_OT)==[2, 1]
    length_slog_OT=1;
else
    length_slog_OT=length(slog_OT);
end

statistica_udareniy_glav=[];
statistica_udareniy_poboch=[];
l_pob=1;
l_glav=1;
for i=1:length_slog_OT
    len_sloga_OT=slog_OT(2,i)-slog_OT(1,i)+1;
    ot_nachala=0;
    ot_konza=len_sloga_OT+1;
    for j=slog_OT(1,i):slog_OT(2,i)
        ot_nachala=ot_nachala+1;
        ot_konza=ot_konza-1;
        if c(j).udarenie_glavnoe==1
            statistica_udareniy_poboch(1,l_pob)=ot_nachala;
            statistica_udareniy_poboch(3,l_pob)=ot_konza;
            statistica_udareniy_poboch(2,l_pob)=ot_nachala/len_sloga_OT;
            statistica_udareniy_poboch(4,l_pob)=ot_konza/len_sloga_OT;
            l_pob= l_pob+1;
        end
        if c(j).udarenie_glavnoe==2
            statistica_udareniy_glav(1,l_glav)=ot_nachala;
            statistica_udareniy_glav(3,l_glav)=ot_konza;
            statistica_udareniy_glav(2,l_glav)=ot_nachala/len_sloga_OT;
            statistica_udareniy_glav(4,l_glav)=ot_konza/len_sloga_OT;
            l_glav= l_glav+1;
        end
    end
end

%положение ударений OT относительно начала по pitch
if size(slog_OT)==[2, 1]
    length_slog_OT=1;
else
    length_slog_OT=length(slog_OT);
end

statistica_udareniy_OT_glav=[];
statistica_udareniy_OT_poboch=[];
l_pob=1;
l_glav=1;
for i=1:length_slog_OT
    len_sloga_OT=slog_OT(2,i)-slog_OT(1,i)+1;
    ot_nachala=0;
    ot_konza=len_sloga_OT+1;
    for j=slog_OT(1,i):slog_OT(2,i)
        ot_nachala=ot_nachala+1;
        ot_konza=ot_konza-1;
        if c(i).udarenie_OT==1
            statistica_udareniy_OT_poboch(1,l_pob)=ot_nachala;
            statistica_udareniy_OT_poboch(3,l_pob)=ot_konza;
            statistica_udareniy_OT_poboch(2,l_pob)=ot_nachala/len_sloga_OT;
            statistica_udareniy_OT_poboch(4,l_pob)=ot_konza/len_sloga_OT;
            l_pob= l_pob+1;
        end
        
        if c(j).udarenie_OT==2
            statistica_udareniy_OT_glav(1,l_glav)=ot_nachala;
            statistica_udareniy_OT_glav(3,l_glav)=ot_konza;
            statistica_udareniy_OT_glav(2,l_glav)=ot_nachala/len_sloga_OT;
            statistica_udareniy_OT_glav(4,l_glav)=ot_konza/len_sloga_OT;
            l_glav= l_glav+1;
        end
    end
end