clc; clear; close all
%% main

% 主要参数
rlist = [1];                % 颗粒半径列表
meshsize = 2.5*min(rlist);  % 网格单元法，网格大小
xmax = 1000;                % 生成空间范围，xyz
xmin = 0   ;                % 注意：x、y、z的范围取值应大于等于0
ymax = 80  ;
ymin = 0   ;
zmax = 80  ;
zmin = 0   ;
% 元胞数组，用于存储颗粒信息，包括坐标、半径
% 索引代表不同的网格区间
position = cell( ceil((xmax-xmin)/meshsize), ceil((ymax-ymin)/meshsize), ceil((zmax-zmin)/meshsize) );
% n×3矩阵，用于存储变量 position 中 相同索引的颗粒数量
nump     = zeros( ceil((xmax-xmin)/meshsize), ceil((ymax-ymin)/meshsize), ceil((zmax-zmin)/meshsize) );
targetnum = 500*40*40;      % 生成的目标颗粒数量
realnum   = 0;              % 当前真实的、已经的 生成的颗粒数量
maxtry    =300;             % 生成第i个颗粒时，最大尝试次数

%
i = 1;
while(i<=targetnum)     %生成第i个颗粒
    
    if(rem(i, 100)==0)
        disp('==============================================================================================')
        fprintf('生成第%d个颗粒\n', i)
        fprintf('生成成功%d次\n', realnum)
        disp('==============================================================================================')
    end

    i = i+1;
    j = 0;
    while(j<maxtry)    % 第i个颗粒第j次尝试
        j = j+1;
        % 生成颗粒
        [x, y, z, r] = generate(xmax, xmin, ymax, ymin, zmax, zmin, rlist);
        % 获取索引
        xindex = ceil(x/meshsize); yindex = ceil(y/meshsize); zindex = ceil(z/meshsize);
        if( contactdetection(x, y, z, r, xindex, yindex, zindex, position) )
        
        else
            position{xindex, yindex, zindex} = [ position{xindex, yindex, zindex}; [x, y, z, r] ];
            realnum = realnum+1;
            break
        end
    end
end

huatu(position)

%% 生成颗粒
function [x, y, z, r] = generate(xmax, xmin, ymax, ymin, zmax, zmin, rlist)
    x = rand * ( xmax - xmin) + xmin;
    y = rand * ( ymax - ymin) + ymin;
    z = rand * ( zmax - zmin) + zmin;
    r = rlist(1);
end

%% 判断颗粒所属网格的位置
% 具体分为顶点、边、面、体
function ptype = judgetype(x, y, z, xindex, yindex, zindex, position)

    % 8个顶点的坐标
    a = [1               , 1               , 1               ;
         1               , 1               , size(position,3);
         1               , size(position,2), 1               ;
         1               , size(position,2), size(position,3);
         size(position,1), 1               , 1               ;
         size(position,1), 1               , size(position,3);
         size(position,1), size(position,2), 1               ;
         size(position,1), size(position,2), size(position,3)];

% 默认是体
ptype = 4;
    % 判断是否是边界面，6个面
    if( xindex == 1 | yindex==1 | zindex==1 | xindex==size(position,1) | yindex==size(position,2) | zindex==size(position,3) )
        ptype = 3;
        % 判断是否是边界边，12条
        if( (xindex==1&yindex==1) | (xindex==1&yindex==size(position,2)) | ...
            (xindex==1&zindex==1) | (xindex==1&zindex==size(position,3)) | ...
            (yindex==1&zindex==1) | (yindex==1&zindex==size(position,3)) | ...
            (yindex==size(position,2)&zindex==1) | (yindex==size(position,2)&zindex==size(position,3)) | ...
            (xindex==size(position,1)&yindex==1) | (xindex==size(position,1)&yindex==size(position,2)) | ...
            (xindex==size(position,1)&zindex==1) | (xindex==size(position,1)&zindex==size(position,3)))
            ptype = 2;
            % 判断是否是8个顶点
            if( any( all( a==[xindex, yindex, zindex], 2 ) ) )
                ptype = 1;  % 点
            end
        end
    end
end

%% 拼接矩阵 用在顶点、线、面、体的处理
function results = pinjie(A, B)
   results =  [A; B];
   results = unique(results, 'rows');
end

%% 获取相邻网格的索引
function results = generateindex(xindex, yindex, zindex, position)
    a = [xindex+1 yindex+1 zindex+1;
        xindex-1 yindex-1 zindex-1;
        xindex   yindex   zindex  ;
    
        xindex+1 yindex+1 zindex-1;
        xindex+1 yindex+1 zindex  ;
        xindex+1 yindex-1 zindex+1;
        xindex+1 yindex-1 zindex-1;
        xindex+1 yindex-1 zindex  ;
        xindex+1 yindex   zindex+1;
        xindex+1 yindex   zindex-1;
        xindex+1 yindex   zindex;
    
        xindex-1 yindex+1 zindex+1;
        xindex-1 yindex+1 zindex-1;
        xindex-1 yindex+1 zindex  ;
        xindex-1 yindex-1 zindex+1;
        xindex-1 yindex-1 zindex;
        xindex-1 yindex   zindex+1;
        xindex-1 yindex   zindex-1;
        xindex-1 yindex   zindex  ;
    
        xindex   yindex+1 zindex+1;
        xindex   yindex+1 zindex-1;
        xindex   yindex+1 zindex  ;
        xindex   yindex-1 zindex+1;
        xindex   yindex-1 zindex-1;
        xindex   yindex-1 zindex  ;
        xindex   yindex   zindex+1;
        xindex   yindex   zindex-1];
    j = 1;
    for i = 1:1:size(a,1)
        if(all(a(i, :))>0 & all(a(i, 1)<=size(position,1)) & all(a(i, 2)<=size(position,2)) & all(a(i, 3)<=size(position,3)) )
            index(j) = i;
            j = j+1;
        end
    end
    results = a(index, :);
    results = unique(results, 'rows');
end


%% 接触检测
function flag = contactdetection(x, y, z, r, xindex, yindex, zindex, position)
    ptype = judgetype(x, y, z, xindex, yindex, zindex, position);
    switch ptype
        case 1  % 8个顶点
            % 获取相邻网格的索引
            index = generateindex(xindex, yindex, zindex, position);
            if(size(index, 1)==8)
            else
                fprintf('generateindex函数出错\n')
            end
            
            temp = [];
            for i=1:1:size(index, 1)
                temp = [temp; [position{index(i,1), index(i,2), index(i,3)}(:,:)] ];
            end
            if(isempty(temp))
                flag = 0;
            else
                dist = sqrt( (x - temp(:,1)).^2 + (y - temp(:,2)).^2 + (z - temp(:,3)).^2 );
                if(all((dist-temp(:,4)-r)>=0))
                    flag = 0;
                else
                    flag = 1;
                end
            end

        case 2
            % 获取相邻网格的索引
            index = generateindex(xindex, yindex, zindex, position);
            if(size(index, 1)==12)
            else
                fprintf('generateindex函数出错\n')
            end
            
            temp = [];
            for i=1:1:size(index, 1)
                temp = [temp; [position{index(i,1), index(i,2), index(i,3)}(:,:)] ];
            end
            if(isempty(temp))
                flag = 0;
            else
                dist = sqrt( (x - temp(:,1)).^2 + (y - temp(:,2)).^2 + (z - temp(:,3)).^2 );
                if(all((dist-temp(:,4)-r)>=0))
                    flag = 0;
                else
                    flag = 1;
                end
            end

        case 3
            % 获取相邻网格的索引
            index = generateindex(xindex, yindex, zindex, position);
            if(size(index, 1)==18)
            else
                fprintf('generateindex函数出错\n')
            end
            
            temp = [];
            for i=1:1:size(index, 1)
                temp = [temp; [position{index(i,1), index(i,2), index(i,3)}(:,:)] ];
            end
            if(isempty(temp))
                flag = 0;
            else
                dist = sqrt( (x - temp(:,1)).^2 + (y - temp(:,2)).^2 + (z - temp(:,3)).^2 );
                if(all((dist-temp(:,4)-r)>=0))
                    flag = 0;
                else
                    flag = 1;
                end
            end


        case 4
            % 获取相邻网格的索引
            index = generateindex(xindex, yindex, zindex, position);
            if(size(index, 1)==27)
            else
                fprintf('generateindex函数出错\n')
            end
            
            temp = [];
            for i=1:1:size(index, 1)
                temp = [temp; [position{index(i,1), index(i,2), index(i,3)}(:,:)] ];
            end
            if(isempty(temp))
                flag = 0;
            else
                dist = sqrt( (x - temp(:,1)).^2 + (y - temp(:,2)).^2 + (z - temp(:,3)).^2 );
                if(all((dist-temp(:,4)-r)>=0))
                    flag = 0;
                else
                    flag = 1;
                end
            end

        otherwise
            disp('接触检测函数出错')
    end
end

%% 画图
function aaa=huatu(position)
    temp = [];
    for i = 1:1:size(position,1)
        for j = 1:1:size(position,2)
            for k = 1:1:size(position,3)
                temp = [temp; position{i, j, k}];
            end
        end
    end
    figure
    scatter3(temp(:,1),temp(:,2),temp(:,3), 140 , '.','r')

%     figure
%     for i = 1:1:max(size(temp(:, 1:3)))
%         hold on
%         drawsphere(temp(i,1), temp(i,2), temp(i,3), temp(i,4))
%     end
end

























