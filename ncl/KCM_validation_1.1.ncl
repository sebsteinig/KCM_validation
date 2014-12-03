;*****************************************************************************************
;                                       KCM Validation
;*****************************************************************************************
;
; Calculate and plot basic transport quantities for KCM ORCA2 and ORCA05 experiments
;
; 
; History:      
;           1.0  :  Nov. 2014  :  annual mean time series         :  S.Steinig
;           1.1  :  Dez. 2014  :  added monthly mean time series  :  S.Steinig
;*****************************************************************************************



begin

;*****************************************************************************************
; Load data
;*****************************************************************************************

; define function to find closest value

function closest_val_AnyOrder(xVal[1]:numeric, x:numeric)
local xAbsDif, xMinVal, iClose
begin
  xAbsDif = abs(xVal-x)
  iClose  = minind(xAbsDif)
  return(iClose)   ; original doc says "first occurence"
end


; specify directory
dir = "/Users/ssteinig/Documents/Uni/Master/HiWi/KCM"

exp_list=(/"P18","P19","P20","P21"/)
;exp_list=(/"P14","P15","P16","P17"/)


; detect length of time series for array initialisation
first_year=9999
last_year=0
do nn=0,dimsizes(exp_list)-1
    f=systemfunc ("ls "+dir+"/data/"+exp_list(nn)+"/"+exp_list(nn)+"_ym*moc*.nc")
    file_tmp=addfile(f,"r")
    moc=file_tmp->zomsfglo(:,:,:,0)
    
    ; get time information
    if ( isfilevarcoord( file_tmp, "time_counter", "time_counter") .eq. True ) then
        time_axis=file_tmp->time_counter
        time_axis!0="time"
    else
        time_axis=file_tmp->time
    end if   
    time_new=cd_calendar(time_axis,-5)
    
    if (exp_list(nn) .eq. "P15") then
        years=ispan(799,886,1)
    else if (exp_list(nn) .eq. "P16") then
        years=ispan(799,1005,1)
    else if (exp_list(nn) .eq. "P17") then
        years=ispan(799,999,1)
    else
        years=time_new(:,0)
    end if
    end if 
    end if

    length=dimsizes(years)

    if (years(0) .lt. first_year) then
        first_year=years(0)
    end if
    
    if (years(length-1) .gt. last_year) then
        last_year=years(length-1)
    end if
    delete([/f,file_tmp,moc,time_axis,time_new,years,length/])
end do

time_range=ispan(first_year,last_year,1)


;*****************************************************************************************
; MOC

; create array and load in data
AMOC_26_5N=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")
AMOC_30S=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")
STC=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")

do nn=0,dimsizes(exp_list)-1
    f=systemfunc ("ls "+dir+"/data/"+exp_list(nn)+"/"+exp_list(nn)+"_ym*moc*.nc")
    file_tmp=addfile(f,"r")
    moc=file_tmp->zomsfatl(:,:,:,0)
    stc=file_tmp->zomsfinp(:,:,:,0)

    ; get time information
    if ( isfilevarcoord( file_tmp, "time_counter", "time_counter") .eq. True ) then
        time_axis=file_tmp->time_counter
        time_axis!0="time"
    else
        time_axis=file_tmp->time
    end if   
    time_new=cd_calendar(time_axis,-5)
    if (exp_list(nn) .eq. "P15") then
        years=ispan(800,886,1)
    else if (exp_list(nn) .eq. "P16") then
        years=ispan(800,1005,1)
    else if (exp_list(nn) .eq. "P17") then
        years=ispan(800,999,1)
    else
        years=time_new(:,0)
    end if
    end if 
    end if
    yy=dimsizes(years)

    ;attach latitude coordinate
    lat=file_tmp->nav_lat(:,0)
    depth=file_tmp->depthw

    ;printVarSummary(stc)
    moc!2="latitude"
    stc!2="latitude"
    moc&latitude=lat
    stc&latitude=lat
    index_26_5N=closest_val_AnyOrder(26.5,lat) ;find indices of latitudes closest to chosen
    index_30S=closest_val_AnyOrder(-30,lat)
    index_8N=closest_val_AnyOrder(8,lat)
    index_12N=closest_val_AnyOrder(12,lat)
    index_8S=closest_val_AnyOrder(-8,lat)
    index_12S=closest_val_AnyOrder(-12,lat)
    depth_index_stc=closest_val_AnyOrder(-300,depth)
    ;find maximum of moc in vertical at chosen latitude and write to corresponding year
    AMOC_26_5N(nn,years(0)-2:years(0+yy-1)-2)=dim_max_n(moc(:,:,index_26_5N),1) 
    AMOC_30S(nn,years(0)-2:years(0+yy-1)-2)=dim_max_n(moc(:,:,index_30S),1)
    STC_north=dim_max_n(moc(:,0:depth_index_stc,index_8N:index_12N),1)
    STC_south=dim_min_n(moc(:,0:depth_index_stc,index_8S:index_12S),1)
    ;STC(nn,years(0)-2:years(0+yy-1)-2)=dim_max_n(STC_north,1)-dim_max_n(STC_south,1)
    STC(nn,years(0)-2:years(0+yy-1)-2)=dim_max_n(STC_north,1)

    delete([/f,file_tmp,moc,depth,depth_index_stc,stc,STC_north,STC_south,lat,time_axis,time_new,years,yy,index_26_5N,index_30S/])
end do


;*****************************************************************************************
; Transports

; create array and load in data
ACC=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")
IT=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")

do nn=0,dimsizes(exp_list)-1
    f=systemfunc ("ls "+dir+"/data/"+exp_list(nn)+"/"+exp_list(nn)+"_ym*psi*.nc")
    file_tmp=addfile(f,"r")
    psi_tmp=file_tmp->sobarstf
    psi=psi_tmp/1000000
    copy_VarMeta(psi_tmp,psi)

    ; get time information
    if ( isfilevarcoord( file_tmp, "time_counter", "time_counter") .eq. True ) then
        time_axis=file_tmp->time_counter
        time_axis!0="time"
    else
        time_axis=file_tmp->time
    end if   
    time_new=cd_calendar(time_axis,-5)
    if (exp_list(nn) .eq. "P15") then
        years=ispan(800,886,1)
    else if (exp_list(nn) .eq. "P16") then
        years=ispan(800,1005,1)
    else if (exp_list(nn) .eq. "P17") then
        years=ispan(800,999,1)
    else
        years=time_new(:,0)
    end if
    end if 
    end if
    yy=dimsizes(years)
    
    ;attach lat-lon coordinates
    lat=file_tmp->nav_lat(:,0)
    lon=file_tmp->nav_lon(0,:)
    psi!1="latitude"
    psi!2="longitude"

    psi&latitude=lat
    psi&longitude=lon
    
    ; Coordinates from Rafael:
        ; Drake Pass.:  (j=120,i=440)-(j=80,i=448)  ->  (54.2°S,67.5°W)-(64.1°S,63°W)
        ; Indonesian:   (j=205,i=85)-(j=233,i=85)   ->  (21.7°S,115°E)-(8.2S°,115°E)
        ; Denmark:      (j=416,i=528)-(j=425,i=523) ->  (48°N,25.5°W)-(48.4°N,26°W)
        ; Iceland:      (j=412,i=578)-(j=412,j=523) ->  (47.8°N,1.5°E)-(47.8°N,26°W)
        ; Bering Str.:  (j=418,i=232)-(j=418,i=227) ->  (48.1°N,171.5°W)-(48.1°N,-174°W)
        
        ; 
            
    Drake_j1=closest_val_AnyOrder(-54.2,lat) ;find indices closest to chosen coordinates
    Drake_j2=closest_val_AnyOrder(-64.1,lat)
    Drake_i1=closest_val_AnyOrder(-67.5,lon)
    Drake_i2=closest_val_AnyOrder(-63,lon)
    
    Ind_j1=closest_val_AnyOrder(-21.7,lat)
    Ind_j2=closest_val_AnyOrder(-8.2,lat)
    Ind_i1=closest_val_AnyOrder(115,lon)
    Ind_i2=closest_val_AnyOrder(115,lon)

    ;calculate transports between the two points
    ACC(nn,years(0)-2:years(0+yy-1)-2)=psi(:,Drake_j2,Drake_i2)-psi(:,Drake_j1,Drake_i1)
    IT(nn,years(0)-2:years(0+yy-1)-2)=psi(:,Ind_j2,Ind_i2)-psi(:,Ind_j1,Ind_i1)
    delete([/f,file_tmp,psi,psi_tmp,lat,lon,time_axis,time_new,years,yy,Drake_j1,Drake_j2,Drake_i1,Drake_i2,Ind_j1,Ind_j2,Ind_i1,Ind_i2/])
end do

;*****************************************************************************************
; Overflow Water Masses

; create array and load in data
DSOW_T=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")
DSOW_S=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")
DSOW_sig=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")

do nn=0,dimsizes(exp_list)-1
    f=systemfunc ("ls "+dir+"/data/"+exp_list(nn)+"/"+exp_list(nn)+"_ym*bottom*.nc")
    file_tmp=addfile(f,"r")
    temp=file_tmp->votemper
    sal=file_tmp->vosaline
    dens=file_tmp->sobotsig0

    ; get time information
    if ( isfilevarcoord( file_tmp, "time_counter", "time_counter") .eq. True ) then
        time_axis=file_tmp->time_counter
        time_axis!0="time"
    else
        time_axis=file_tmp->time
    end if   
    time_new=cd_calendar(time_axis,-5)
    if (exp_list(nn) .eq. "P15") then
        years=ispan(800,886,1)
    else if (exp_list(nn) .eq. "P16") then
        years=ispan(800,1005,1)
    else if (exp_list(nn) .eq. "P17") then
        years=ispan(800,999,1)
    else
        years=time_new(:,0)
    end if
    end if 
    end if
    yy=dimsizes(years)
    
    ;attach lat-lon coordinates
    lat=file_tmp->nav_lat(:,0)
    lon=file_tmp->nav_lon(0,:)
    temp!1="latitude"
    temp!2="longitude"
    temp!0="time"
    sal!0="time"
    dens!0="time"


    temp&latitude=lat
    temp&longitude=lon
    
    ; Coordinates from Rafael:
        ; DSOW:  (j=414:419)-(i=519:524)  ->  (47.9-48.1°N)-(28.3:25.8°W)

    DSOW_j1=closest_val_AnyOrder(47.9,lat) ;find indices closest to chosen coordinates
    DSOW_j2=closest_val_AnyOrder(48.1,lat)
    DSOW_i1=closest_val_AnyOrder(-28.3,lon)
    DSOW_i2=closest_val_AnyOrder(-25.8,lon)
    
    ;calculate properties of DSOW
    DSOW_T(nn,years(0)-2:years(0+yy-1)-2)=dim_avg_n_Wrap(temp(:,DSOW_j1:DSOW_j2,DSOW_i1:DSOW_i2),(/1,2/))
    DSOW_S(nn,years(0)-2:years(0+yy-1)-2)=dim_avg_n_Wrap(sal(:,DSOW_j1:DSOW_j2,DSOW_i1:DSOW_i2),(/1,2/))
    DSOW_sig(nn,years(0)-2:years(0+yy-1)-2)=dim_avg_n_Wrap(dens(:,DSOW_j1:DSOW_j2,DSOW_i1:DSOW_i2),(/1,2/))
    
    delete([/f,file_tmp,temp,sal,dens,lat,lon,time_axis,time_new,years,yy,DSOW_j1,DSOW_j2,DSOW_i1,DSOW_i2/])
end do

;*****************************************************************************************
; Plots
;*****************************************************************************************

colors=(/"black","dodgerblue4","firebrick4","olivedrab4","purple4","darkorange4","yellow","violetred4"/)

res                                = True
res@gsnDraw                        = False                         
res@gsnFrame                       = False

res@xyDashPattern                  = 0

res@trXMaxF                        = first_year 
;res@trXMinF                        = 800      
res@trXMaxF                        = last_year 
res@xyLineThicknessF               = 4.0 
res@tiYAxisString                  = "Sv"
res@tiXAxisString                  = "Model Year"
res@xyLineColors                    = colors

; Define Legend
res@pmLegendDisplayMode    = "Always"            ; turn on legend

res@pmLegendSide           = "Top"               ; Change location of 
res@pmLegendParallelPosF   = .8                 ; move units right
res@pmLegendOrthogonalPosF = -0.45                ; move units down

res@pmLegendWidthF         = 0.18               ; Change width and
res@pmLegendHeightF        = 0.18                ; height of legend.
res@lgLabelFontHeightF     = .03                 ; change font height
res@lgTitleOn              = False                ; turn on legend title
res@xyExplicitLegendLabels = " "+exp_list         ; explicit labels
items                      = ispan(0,dimsizes(exp_list)-1,1)
res@lgItemOrder            = items(::-1)              ; reverse legend

wks                                 = gsn_open_wks("pdf" ,dir+"/plots/KCM_validation") 
;wks                                 = gsn_open_wks("pdf" ,dir+"/plots/KCM_validation_orca05") 

plot                               = new(9,graphic)

res@trYMinF                        = min(AMOC_26_5N)-(max(AMOC_26_5N)-min(AMOC_26_5N))*0.1     
res@trYMaxF                        = max(AMOC_26_5N)+(max(AMOC_26_5N)-min(AMOC_26_5N))*0.1  
res@tiMainString                  = "AMOC 26.5N"
plot(0)                            = gsn_csm_xy (wks,time_range,AMOC_26_5N,res)
res@trYMinF                        = min(AMOC_30S)-(max(AMOC_30S)-min(AMOC_30S))*0.1 
res@trYMaxF                        = max(AMOC_30S)+(max(AMOC_30S)-min(AMOC_30S))*0.1
res@tiMainString                  = "AMOC 30S"
plot(3)                            = gsn_csm_xy (wks,time_range,AMOC_30S,res) 
res@trYMinF                        = min(STC)-(max(STC)-min(STC))*0.1 
res@trYMaxF                        = max(STC)+(max(STC)-min(STC))*0.1
res@tiMainString                  = "STC strength IndPac(max(8-12N) upper 300m)"
plot(6)                            = gsn_csm_xy (wks,time_range,STC,res)

res@tiMainString                  = "ACC"
res@trYMinF                        = min(ACC)-(max(ACC)-min(ACC))*0.1     
res@trYMaxF                        = max(ACC)+(max(ACC)-min(ACC))*0.1 
plot(1)                            = gsn_csm_xy (wks,time_range,ACC,res)  
res@tiMainString                  = "Indonesian Throughflow"
res@trYMinF                        = min(IT)-(max(IT)-min(IT))*0.1      
res@trYMaxF                        = max(IT)+(max(IT)-min(IT))*0.1
plot(4)                            = gsn_csm_xy (wks,time_range,IT,res) 

res@tiMainString                  = "DSOW Temperature"
res@tiYAxisString                  = "~C~C"
res@trYMinF                        = min(DSOW_T)-(max(DSOW_T)-min(DSOW_T))*0.1      
res@trYMaxF                        = max(DSOW_T)+(max(DSOW_T)-min(DSOW_T))*0.1      
plot(2)                            = gsn_csm_xy (wks,time_range,DSOW_T,res) 
res@tiMainString                  = "DSOW Salinity"
res@tiYAxisString                  = ""
res@trYMinF                        = min(DSOW_S)-(max(DSOW_S)-min(DSOW_S))*0.1     
res@trYMaxF                        = max(DSOW_S)+(max(DSOW_S)-min(DSOW_S))*0.1    
plot(5)                            = gsn_csm_xy (wks,time_range,DSOW_S,res) 
resP                                = True
resP@gsnMaximize                    = True
resP@txString                       = ""
res@tiMainString                  = "DSOW Density (sig0)"
res@tiYAxisString                  = "kg/m3"
res@trYMinF                        = min(DSOW_sig)-(max(DSOW_sig)-min(DSOW_sig))*0.1  
res@trYMaxF                        = max(DSOW_sig)+(max(DSOW_sig)-min(DSOW_sig))*0.1  
plot(8)                            = gsn_csm_xy (wks,time_range,DSOW_sig,res) 

resP                                = True
resP@gsnMaximize                    = True
resP@txString                       = "KCM validation"
gsn_panel(wks,plot,(/3,3/),resP)   



end