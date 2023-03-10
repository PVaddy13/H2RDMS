clc
close all
clear all

global XYZ;
XYZ = [];

%% Phase selcection

uifig = uifigure('Name','Post HRW Test Analysis',...
                   'Position',[100, 100, 400, 545]);
               
lmpLoadFile = uilamp(uifig,...
                'Color', 'Red',...
                'Position', [180, 305, 20, 20]);
lmpPhase1 = uilamp(uifig,...
                'Color', 'Red',...
                'Position', [360, 222, 20, 20]);
lmpPhase2 = uilamp(uifig,...
                'Color', 'Red',...
                'Position', [360, 127, 20, 20]);
            
HeadTxt = uitextarea(uifig,...
                'Value', 'Heave Height and Rut Depth Measurement Software (H2RDMS)',...
                'FontWeight', 'Bold',...
                'FontSize',20,...
                'HorizontalAlignment', 'Center',...
                'Position', [50, 440, 300, 85]);

btnNewPro = uibutton(uifig,'push',...
               'Text', 'New Project',...
               'FontWeight', 'Bold',...
               'FontSize',15,...
               'Position',[200-(125/2), 360, 125, 50],...
               'ButtonPushedFcn', @(btnNewPro,event) plotButtonNewProPushed(btnNewPro,XYZ,lmpLoadFile,lmpPhase1,lmpPhase2));

btnLoadFile = uibutton(uifig,'push',...
               'Text', 'Load file',...
               'FontWeight', 'Bold',...
               'FontSize',15,...
               'Position',[50, 290, 125, 50],...
               'ButtonPushedFcn', @(btnLoadFile,event) plotButtonLoadFilePushed(btnLoadFile,XYZ,lmpLoadFile));

btnPhase1 = uibutton(uifig,'push',...
               'Text', 'Phase 1: (Selection of Ref Z)',...
               'FontWeight', 'Bold',...
               'FontSize',15,...
               'Position',[50, 195, 300, 75],...
               'ButtonPushedFcn', @(btnPhase1,event) plotButtonPhase1Pushed(btnPhase1,lmpPhase1));
         
btnPhase2 = uibutton(uifig,'push',...
               'Text', 'Phase 2: (Measurement of HH and RD)',...
               'FontWeight', 'Bold',...
               'FontSize',15,...
               'Position',[50, 100, 300, 75],...
               'ButtonPushedFcn', @(btnPhase2,event) plotButtonPhase2Pushed(btnPhase2,lmpPhase2));
            
btnClose = uibutton(uifig,'push',...
               'Text', 'Close',...
               'FontWeight', 'Bold',...
               'Position',[150, 30, 100, 50],...
               'FontSize',15,...
               'ButtonPushedFcn', @(btnClose,event) plotButtonClosePushed(btnClose,uifig));

btn3dPreview = uibutton(uifig,'push',...
               'Text', '3D Preview',...
               'FontWeight', 'Bold',...
               'Position',[225, 290, 125, 50],...
               'FontSize',15,...
               'ButtonPushedFcn', @(btn3dPreview,event) plotButton3dPreviewPushed(btn3dPreview));



%% %%%%%%%%%%%%% Button-New %%%%%%%%%%%%%%%%%%%%%%%
function plotButtonNewProPushed(btnNewPro,XYZ,lmpLoadFile,lmpPhase1,lmpPhase2)
    global XYZ
    XYZ = [];
    lmpLoadFile.Color = [1 0 0];
    lmpPhase1.Color = [1 0 0];
    lmpPhase2.Color = [1 0 0];
end


%% %%%%%%%%%%%%% Button-Load File %%%%%%%%%%%%%%%%%%%%%%%
function plotButtonLoadFilePushed(btnLoadFile,XYZ,lmpLoadFile)    
    global filePath1 fileName1
    [fileName1, filePath1] = uigetfile('*.*', 'Select one of the text files containing coordinates details ...');
    
    global XYZ X Y Z X1 Y1 Z1 X2 Y2 Z2 Z3 Z4 numPixs delZ imLenX imLenY;
    XYZ = load([filePath1 fileName1]);
    lmpLoadFile.Color = [0 1 0];
    
    X = [];
    Y = [];
    Z = [];
    
    X = XYZ(:,1);
    Y = XYZ(:,2);
    Z = XYZ(:,3);

    imLenX = max(X)-min(X);
    imLenY = max(Y)-min(Y);

    X1 = X - min(X);
    Y1 = Y - min(Y);
    Z1 = Z - min(Z);
    
    Xmin = min(X1);
    Xmax = max(X1);

    Ymin = min(Y1);
    Ymax = max(Y1);
  
    %% conversion of extracted xyz coordinates into a 3d mesh grid 

    numPixs = 1500;
    F = scatteredInterpolant(X1,Y1,Z1);
    [X2, Y2] = meshgrid(linspace(Xmin,Xmax,numPixs), linspace(Ymin,Ymax,numPixs)); 
    Z2 = F(X2,Y2);
    
    %% conversion of xyz data to an image

    Zmax = max(max(Z2));
    Zmin = min(min(Z2));
    delZ = Zmax - Zmin;

    Z3 = Z2*(255/delZ);
    Z4 = uint8(Z3);
    
end


%% %%%%%%%%%%%%% Button-3d Preview %%%%%%%%%%%%%%%%%%%%%%%

function plotButton3dPreviewPushed(btn3dPreview)
    global X2 Y2 Z4 numPixs delZ;
    figQ1 = figure();
    imshow(Z4)
    title('Select the test specimen area')
    
    cirArea1 = impoly;
    cirArea2 = createMask(cirArea1);
    cirArea3 = double(cirArea2);
    cirArea4 = zeros(numPixs);
    cirArea5 = zeros(numPixs);
    close(figQ1)
    
    for i=1:1:numPixs
        for j=1:1:numPixs
            cirArea4(i,j) = Z4(i,j)*cirArea3(i,j);
        end
    end
    
    for i=1:1:numPixs
        for j=1:1:numPixs
            if cirArea4(i,j)== 0
               cirArea5(i,j)= NaN;
            else
               cirArea5(i,j)= cirArea4(i,j);
            end
        end
    end
    
    cirArea5MM = cirArea5/255*delZ;
    
    figure('Position', [600, 500, 1000, 700],'Name','3D profile of post-HRW tested sample')
    surf(X2,Y2,cirArea5MM,'FaceColor','flat')
    daspect([1,1,1])
    shading interp
    colormap jet
    axis off
    set(gcf,'color','k')

end

%% %%%%%%%%%%%%%%%% Button-Phase 1 %%%%%%%%%%%%%%%%%
function plotButtonPhase1Pushed(btnPhase1,lmpPhase1)
    global X1 Y1 Z1;
    figure('Position', [500, 500, 500, 300],'Name','Figure out a reference Z coordinate')
    plot3(X1,Y1,Z1,'r.')
    daspect([1,1,1])
    view(-90,2)
    
    lmpPhase1.Color = [0 1 0];
    
    pause()
end


%% %%%%%%%%%%%%%% Button-Phase 2 %%%%%%%%%%%%%%%%%%%%%%
function plotButtonPhase2Pushed(btnPhase2,lmpPhase2)
    
    %% Reference depth information
    prompt = {'Enter Specimen height (in mm):','Enter Reference Z Coordinate:'};
    dlgtitle = 'Input details';
    dims = [1 45];
    definput = {'60','4.2'};
    inpDetails = inputdlg(prompt,dlgtitle,dims,definput);
    
    specHt = str2double(inpDetails{1});
    delHt = specHt-60;

    inZref = str2double(inpDetails{2});
    
    global Zref;
    Zref = inZref + delHt;

    % heave analysis

    global Z2 Z3 Z4 numPixs delZ imLenY Zref;
    figP1 = figure('Name','Select the heaved region');
    imshow(Z4)
    
    p1 = impoly;
    heave1Mask = createMask(p1);
    p2 = impoly;    
    heave2Mask = createMask(p2);
    heaveMasks = heave1Mask+heave2Mask;
    close(figP1)
    
    %

    for i=1:1:numPixs
        for j=1:1:numPixs
            heaveData(i,j) = Z3(i,j)*heaveMasks(i,j);
        end
    end
    
    heaveDataMM = heaveData/255*delZ;

    for y=1:1:numPixs
        p = 1;
        Q = [0];
        for x=1:1:numPixs
            if heaveDataMM(y,x)~=0
               Q(p)=heaveDataMM(y,x);
               p = p+1;
            end
        end
        meanheave(y,1) = y;
        meanheave(y,2) = y/numPixs*imLenY; % conversion to y coordinate
        meanheave(y,3) = length(Q);
        meanheave(y,4) = mean(Q);
    end

    % calcualtions in terms of pixel intensity
    maxHeaveMatY = max(heaveDataMM.').';
    maxheaveOverall = max(max(heaveDataMM));
    meanheaveOverall = mean(meanheave(:,4));

    % correction to results to incorporate ref Z
    maxheaveOverall2 = maxheaveOverall-Zref;
    meanheaveOverall2 = meanheaveOverall-Zref;

    % Rut depth analysis

    figP3 = figure('Name','Select the rut region');
    rutRegion = imcrop(Z4);
    rutRegionMM = double(rutRegion)/255*delZ;
    meanrutDepthMatY = (mean(rutRegionMM.')).';
    maxrutDepthMatY = (min(rutRegionMM.')).';
    rutDepthYco = ([1:numPixs]/numPixs*imLenY).';
    close(figP3)
    
    meanRutMatY = Zref - meanrutDepthMatY;
    size(meanRutMatY)
    maxRutMatY = Zref - maxrutDepthMatY;
    meanRutOverall = Zref - mean(meanRutMatY);
    maxRutOverall = Zref - min(maxRutMatY);

    % Final figures
    
%     figure('Position', [100, 100, 2000, 1000])
%     subplot 231
%     plot(meanheave(:,2),meanheave(:,4))
%     title('Mean heave height wrt Y distance')
%     xlabel('Distance in Y direction (mm)')
%     ylabel('Mean heave height (mm)')
% 
%     subplot 232
%     plot(meanheave(:,2),maxHeaveMatY)
%     title('Max heave height wrt Y distance')
%     xlabel('Distance in Y direction (mm)')
%     ylabel('Max heave height (mm)')
%     
%     subplot 233
%     plot(meanheave(:,2),meanRutMatY)
%     title('Mean rut depth wrt Y distance')
%     xlabel('Distance in Y direction (mm)')
%     ylabel('Mean rut depth (mm)')
% 
%     subplot 234
%     plot(meanheave(:,2),meanheave(:,4)+meanRutMatY)
%     title('Mean heave height + mean rut depth wrt Y distance')
%     xlabel('Distance in Y direction (mm)')
%     ylabel('Mean heave height + mean rut depth (mm)')
% 
%     subplot 235
%     plot(meanheave(:,2),maxHeaveMatY+meanRutMatY)
%     title('Max heave height + mean rut depth wrt Y distance')
%     xlabel('Distance in Y direction (mm)')
%     ylabel('Max heave height + mean rut depth (mm)')
%     
%     diffHeaveRutMat = maxHeaveMatY + maxRutMatY;
%     maxDiffHeaveRutMat = max(maxHeaveMatY + maxRutMatY);
%     maxDiffLoc = find(diffHeaveRutMat==maxDiffHeaveRutMat);
%     
%     figure('Position', [550, 550, 1000, 400])
%     plot(rutDepthYco,Z2(maxDiffLoc,:))
%     title('Heave-Rut profile at max differece in HH and RD')
%     daspect([1,1,1])
%     axis off
%     set(gcf,'color','W')
    
    maxheaveOverall2
    meanheaveOverall2
    meanRutOverall
    
    OutputMat = [];
    OutputMat(:,1) = rutDepthYco;
    OutputMat(:,2) = meanheave(:,4);
    OutputMat(:,3) = maxHeaveMatY;
    OutputMat(:,4) = meanRutMatY;
    
    %%
    clc
    global filePath1 fileName1
    %[fileName2, filePath2] = uigetfile('*.*', 'Select H2RDMS Output Template File ...');
    %templateFile = [filePath2 fileName2];
    templateFile = 'H2RDMS_Output_Template.xlsx';
    
    nameOutputFile = [filePath1 fileName1(1:end-4) '_Output.xlsx'];
    copyfile(templateFile, nameOutputFile)
    xlswrite(nameOutputFile,OutputMat,'Sheet1','B8')
    
    lmpPhase2.Color = [0 1 0];
    pause()
end


%% %%%%%%%%%%%%% Button-Close %%%%%%%%%%%%%%%%%%%%%%%
function plotButtonClosePushed(btnClose,uifig)
    close(uifig)
    exit()
end



