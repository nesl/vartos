%% Housekeeping
clc; clear all; close all;

% lifetime = (1:8760)/24;
% quality_norm = 0.5*ones(1,length(lifetime));
% quality_death = 0.6*ones(1,length(lifetime));
% death1 = 215*24;
% death2 = 290*24;
% death3 = 310*24;
% quality_death(death1:end) = 0.4;
% quality_death(death2:end) = 0.3;
% quality_death(death3:end) = 0.2;
% quality_wc = 0.3*ones(1,length(lifetime));
% 
% %% Plot
% cfigure(18,10);
% hold on;
% plot(lifetime,quality_norm,'-k','LineWidth',2);
% plot(lifetime,quality_death,'--b','LineWidth',2);
% plot(lifetime,quality_wc,'-.r','LineWidth',2);
% ylim([0 1]);
% xlim([0 365]);
% grid on;
% ylabel('Normalized Quality','FontSize',12);
% xlabel('Time (days)','FontSize',12);

cfigure(18,10);
hold on;

radius = 0.7;
ang_s = 78;
ang_f = 12;
lifes = radius*cosd(ang_s):0.01:radius*cosd(ang_f);
curve1 = sqrt(0.5-lifes.^2);
curve2 = radius*sind(ang_s) - (lifes-lifes(1));
curve3 = exp(-3.1*lifes);
curve3 = curve3 - curve3(1) + curve2(1);
plot(lifes, curve1, '--k','LineWidth',2);
plot(lifes, curve2,'-.k','LineWidth',2);
plot(lifes, curve3,'-k','LineWidth',2);

angle = ang_s;
plot([0 radius*cosd(angle)],[radius*sind(angle) radius*sind(angle)],'-k','LineWidth',2);
plot([radius*cosd(angle) radius*cosd(angle)],[0 radius*sind(angle)],'-k','LineWidth',2);
plot(radius*cosd(angle),radius*sind(angle),'o','Color',[1 1 1],'LineWidth',2,'MarkerFaceColor','b','MarkerSize',15);
text(0.05,0.85,'Understimation of','FontSize',12);
text(0.13,0.80,'Power','FontSize',12);

angle = 45;
plot(radius*cosd(angle),radius*sind(angle),'s','Color',[1 1 1],'LineWidth',2,'MarkerFaceColor','b','MarkerSize',17);
text(0.43,0.75,'Instance- and Temperature-','FontSize',12);
text(0.50,0.70,'Aware Power','FontSize',12);

angle = ang_f;
plot([0 radius*cosd(angle)],[radius*sind(angle) radius*sind(angle)],'-k','LineWidth',2);
plot([radius*cosd(angle) radius*cosd(angle)],[0 radius*sind(angle)],'-k','LineWidth',2);
plot(radius*cosd(angle),radius*sind(angle),'^','Color',[1 1 1],'LineWidth',2,'MarkerFaceColor','b','MarkerSize',17);
text(0.70,0.35,'Guardbanded','FontSize',12);
text(0.70,0.30,'Specifications','FontSize',12);




xlim([0 1]);
ylim([0 1]);
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
ylabel('Quality','FontSize',12);
xlabel('Lifetime','FontSize',12);
saveplot('../tecs/figures/intro_quality_vs_lifetime');