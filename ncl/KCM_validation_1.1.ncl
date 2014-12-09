;*****************************************************************************************
;                                       KCM Validation
;*****************************************************************************************
;
; Calculate and plot basic transport quantities for KCM ORCA2 and ORCA05 experiments
;
; 
; History:      
;           1.0  :  Nov. 2014  :  annual mean time series         :  S. Steinig
;           1.1  :  Dez. 2014  :  added choice between ym and 1m  :  S. Steinig
;*****************************************************************************************

;*****************************************************************************************
; User input
;*****************************************************************************************

; specify directory
dir = "/Users/ssteinig/Documents/Uni/Master/HiWi/KCM"

exp_list=(/"P18","P19","P20","P21"/)
;exp_list=(/"P15","P16","P17"/)
var_list=(/"moc"/) ; moc, psi, mhst, bottom 

delta_t="1m" ; ym or 1m
plot_running_avg = 1 ; 0=no, 1=yes
running_avg_window = 1 ; number of years to include in the running mean

;*****************************************************************************************
; Define own functions
;*****************************************************************************************

; Find closest value
function closest_val_AnyOrder(xVal[1]:numeric, x:numeric)
local xAbsDif, xMinVal, iClose
begin
    xAbsDif = abs(xVal-x)
    iClose  = minind(xAbsDif)
    return(iClose)   ; original doc says "first occurence"
end

; Extract a substring from another string
function substring (instr[1]:string, first[1]:numeric, last[1]:numeric)
local instr, first, last, main, p2
begin
   main = stringtochar (instr)		; convert input string to char array
					                ; terminal null character is included    
   if (last .ge. first) then		; check requested end position
      p2 = last				        ; go to last position specified
   else					            ; but if less than first:
      p2 = dimsizes (main) - 2		; go to last avail char in main string
   end if   
   return (chartostring (main(first:p2)))	; extract substring
end

begin

;*****************************************************************************************
; Set parameters
;*****************************************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

; define which plots and data are needed based on the user selection of "var_list" 
load_moc            =   0
load_psi            =   0
load_mhst           =   0
load_bottom         =   0

plot_moc_time_series        =   0
plot_psi_time_series        =   0
plot_bottom_time_series     =   0
plot_overturning            =   0

do nn=0,dimsizes(var_list)-1
    if (var_list(nn) .eq. "moc") then
      load_moc              =   1	
      plot_moc_time_series  =   1	
      plot_overtuning       =   1			     
    else if (var_list(nn) .eq. "psi") then
      load_psi              =   1					            
      plot_time_series      =   1
    end if
    end if
end do   

; detect horizontal grid size
do nn=0,dimsizes(exp_list)-1
    f=systemfunc ("ls "+dir+"/data/"+exp_list(nn)+"/"+exp_list(nn)+"_*"+var_list(0)+"*.nc")
    file_tmp=addfile(f(0),"r")
    lat=file_tmp->nav_lat(:,0)
    if (nn .eq. 0) then ; set grid configuration based on number of latitude indices
        if (dimsizes(lat) .eq. 511) then
            grid="ORCA05"
        else if (dimsizes(lat) .eq. 149) then
            grid="ORCA2"
        end if
        end if
    else ; check whether all following experiments have same grid, otherwise stop script with error
        if (dimsizes(lat) .eq. 511 .and. grid .eq. "ORCA05") then
            grid="ORCA05"
        else if (dimsizes(lat) .eq. 149 .and. grid .eq. "ORCA2") then
            grid="ORCA2"
        else
            print ("ERROR: Experiments do not have same grid sizes!")
            exit
        end if
        end if
    end if
    delete([/f,file_tmp,lat/])
end do

if (grid .eq. "ORCA05") then
    frequency="1m"
else if (grid .eq. "ORCA2") then
    frequency="ym"
end if
end if
    
;*****************************************************************************************
; Load data
;*****************************************************************************************

; detect length of time series for array initialisation
model_years=new((/dimsizes(exp_list),2/),"integer")
do nn=0,dimsizes(exp_list)-1
    f=systemfunc ("ls "+dir+"/data/"+exp_list(nn)+"/"+exp_list(nn)+"_"+frequency+"*"+var_list(0)+"*.nc")
    i1  = str_index_of_substr(f, var_list(0), 1)
    model_years(nn,0)=stringtointeger(substring(f,i1-10,i1-7))
    model_years(nn,1)=stringtointeger(substring(f,i1-5,i1-2))
    delete([/f/])
end do

first_year=dim_min(model_years(:,0))
last_year=dim_max(model_years(:,1))

if (delta_t .eq. "ym") then		
    time_range=ispan(first_year,last_year,1)
    running_window=running_avg_window
else if (delta_t .eq. "1m" .and. grid .eq. "ORCA05")			        
    time_range=ispan(first_year*12-11,last_year*12,1)
    running_window=running_avg_window*12
else if (delta_t .eq. "1m" .and. grid .eq. "ORCA2")		
    print("ERROR: No monthly mean data available for ORCA2 experiments")
end if
end if
end if 

length_time=dimsizes(time_range)

; define available timesteps for each experiments on common time vector "time_range"
model_timesteps=new((/dimsizes(exp_list),2/),"integer")
do nn=0,dimsizes(exp_list)-1
    if (delta_t .eq. "ym") then		
        model_timesteps(nn,0)=model_years(nn,0)-first_year
        model_timesteps(nn,1)=model_years(nn,1)-first_year
    else if (delta_t .eq. "1m" .and. grid .eq. "ORCA05")			        
        time_range=ispan(first_year*12-11,last_year*12,1)
        model_timesteps(nn,0)=(model_years(nn,0)-first_year)*12
        model_timesteps(nn,1)=(model_years(nn,1)-first_year)*12+11
    end if
    end if    
end do
 

;*****************************************************************************************
; MOC

if (load_moc .eq. 1) then

   ; create array and load in data
    AMOC_26N=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")
    AMOC_30S=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")
    TC_PAC=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")
    STC_PAC=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")
    
    ; Define lat and depth indices for moc calculations
    ;
    ;                                          ; ORCA05             ; ORCA2
    ; AMOC 26.5°N:                             ; j=305              ; j=95
    ; AMOC 30°S:                               ; j=187              ; j=50
    ; TC: max (5S-5N, upper 250m) -            ;                    ;
    ;     min (5S-5N, upper 250m)              ;                    ;
    ; TC_PAC:                                  ; j=240:260, z=1:16  ; j=65:83, z=1:18
    ; STC: max (10N-30N, upper 250m) -         ;                    ; 
    ;      min (30S-10S, upper 250m)           ;                    ; 
    ; STC_NPAC:                                ; j=270:313, z=1:16  ; j=86:97, z=1:18
    ; STC_SPAC:                                ; j=187:230, z=1:16  ; j=50:61, z=1:18
    ; STC_PAC: STC_NPAC - STC_SPAC             ;                    ;

    ; NCL array indexing starts at 0!
    if (grid .eq. "ORCA05") then
        index_26N       =   304
        index_30S       =   186
        index_5S        =   239
        index_5N        =   259
        index_10S       =   229
        index_10N       =   269
        index_30N       =   312
        index_depth_moc =   15
    else if (grid .eq. "ORCA2") then    
        index_26N       =   94
        index_30S       =   49
        index_5S        =   64
        index_5N        =   82
        index_10S       =   60
        index_10N       =   85
        index_30N       =   96
        index_depth_moc =   17  
    end if          
    end if

    do nn=0,dimsizes(exp_list)-1
        f=systemfunc ("ls "+dir+"/data/"+exp_list(nn)+"/"+exp_list(nn)+"_"+frequency+"*moc*.nc")
        file_tmp=addfile(f,"r")
        moc_atl_tmp=file_tmp->zomsfatl(:,:,:,0)
        moc_inp_tmp=file_tmp->zomsfinp(:,:,:,0)
        
        if (grid .eq. "ORCA05" .and. delta_t .eq. "ym")
            moc_atl=month_to_annual(moc_atl_tmp,1)
            moc_inp=month_to_annual(moc_inp_tmp,1)
        else
            moc_atl=moc_atl_tmp
            moc_inp=moc_inp_tmp
        end if

        AMOC_26N(nn,model_timesteps(nn,0):model_timesteps(nn,1))=dim_max_n(moc_atl(:,:,index_26N),1) 
        AMOC_30S(nn,model_timesteps(nn,0):model_timesteps(nn,1))=dim_max_n(moc_atl(:,:,index_30S),1) 
        TC_max=dim_max_n(moc_inp(:,0:index_depth_moc,index_5N:index_5S),1)
        TC_min=dim_min_n(moc_inp(:,0:index_depth_moc,index_5N:index_5S),1)
        TC_PAC(nn,model_timesteps(nn,0):model_timesteps(nn,1))=dim_max_n(TC_max,1)-dim_min_n(TC_min,1)        
        STC_NPAC=dim_max_n(moc_inp(:,0:index_depth_moc,index_10N:index_30N),1)
        STC_SPAC=dim_min_n(moc_inp(:,0:index_depth_moc,index_10S:index_30S),1)
        STC_PAC(nn,model_timesteps(nn,0):model_timesteps(nn,1))=dim_max_n(STC_NPAC,1)-dim_min_n(STC_SPAC,1)
                
    delete([/f,file_tmp,moc_atl,moc_atl_tmp,moc_inp,moc_inp_tmp,STC_NPAC,STC_SPAC,TC_max,TC_min/])
    end do

end if

;*****************************************************************************************
; Transports

if (load_psi .eq. 1) then


; create array and load in data
ACC=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")
IT=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")

do nn=0,dimsizes(exp_list)-1
    f=systemfunc ("ls "+dir+"/data/"+exp_list(nn)+"/"+exp_list(nn)+"_"+frequency+"*psi*.nc")
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

end if
;*****************************************************************************************
; Overflow Water Masses

if (load_bottom .eq. 1) then

; create array and load in data
DSOW_T=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")
DSOW_S=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")
DSOW_sig=new((/dimsizes(exp_list),dimsizes(time_range)/),"float")

do nn=0,dimsizes(exp_list)-1
    f=systemfunc ("ls "+dir+"/data/"+exp_list(nn)+"/"+exp_list(nn)+"_"+frequency+"*bottom*.nc")
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

end if
;*****************************************************************************************
; Plots
;*****************************************************************************************

;*****************************************************************************************
; MOC

colors=(/"black","dodgerblue4","firebrick4","olivedrab4","purple4","darkorange4","yellow","violetred4"/)

res_time_series                                = True
res_time_series@gsnDraw                        = False                         
res_time_series@gsnFrame                       = False

res_time_series@xyDashPattern                  = 0

res_time_series@trXMaxF                        = time_range(length_time-1) 
res_time_series@trXMinF                        = time_range(0)  
line_thickness                                 = 300/int2flt(length_time) ; adapt line thickness to number of plotted time steps
if (line_thickness .ge. 4) then ; limit line thickness
    line_thickness = 4
end if
res_time_series@xyLineThicknessF               = line_thickness
res_time_series@tiYAxisString                  = "Sv"
res_time_series@tiXAxisString                  = "Model Year"

; format the x-axis (time axis)
restick = True
time_range!0="time"
if (delta_t .eq. "1m") then
    time_range@units="months since 0001-01-01"
else
    time_range@units="years since 0000-01-01"
end if
restick@ttmFormat = "%Y" ; 4 digit year
time_axis_labels(time_range,res_time_series,restick)

res_time_series@xyLineColors                    = colors

; Define Legend
res_time_series@pmLegendDisplayMode    = "Always"            ; turn on legend

res_time_series@pmLegendSide           = "Top"               ; Change location of 
res_time_series@pmLegendParallelPosF   = .8                 ; move units right
res_time_series@pmLegendOrthogonalPosF = -0.45                ; move units down

res_time_series@pmLegendWidthF         = 0.18               ; Change width and
res_time_series@pmLegendHeightF        = 0.18                ; height of legend.
res_time_series@lgLabelFontHeightF     = .03                 ; change font height
res_time_series@lgTitleOn              = False                ; turn on legend title
res_time_series@xyExplicitLegendLabels = " "+exp_list         ; explicit labels
legend_items                      = ispan(0,dimsizes(exp_list)-1,1)
res_time_series@lgItemOrder            = legend_items(::-1)              ; reverse legend

wks                                 = gsn_open_wks("pdf" ,dir+"/plots/KCM_validation_"+grid+"_"+delta_t) 
;wks                                 = gsn_open_wks("pdf" ,dir+"/plots/KCM_validation_orca05") 

plot_moc                               = new(12,graphic)
plot_running_mean                      = new(12,graphic)


if (plot_moc_time_series .eq. 1) then
    res_time_series@trYMinF                        = min(AMOC_26N)-(max(AMOC_26N)-min(AMOC_26N))*0.1     
    res_time_series@trYMaxF                        = max(AMOC_26N)+(max(AMOC_26N)-min(AMOC_26N))*0.1  
    res_time_series@tiMainString                   = "AMOC 26.5N"
    plot_moc(0)                                    = gsn_csm_xy (wks,time_range,AMOC_26N,res_time_series)
    res_time_series@trYMinF                        = min(AMOC_30S)-(max(AMOC_30S)-min(AMOC_30S))*0.1 
    res_time_series@trYMaxF                        = max(AMOC_30S)+(max(AMOC_30S)-min(AMOC_30S))*0.1
    res_time_series@tiMainString                   = "AMOC 30S"
    plot_moc(3)                                    = gsn_csm_xy (wks,time_range,AMOC_30S,res_time_series) 
    res_time_series@trYMinF                        = min(STC_PAC)-(max(STC_PAC)-min(STC_PAC))*0.1 
    res_time_series@trYMaxF                        = max(STC_PAC)+(max(STC_PAC)-min(STC_PAC))*0.1
    res_time_series@tiMainString                   = "STC strength IndPac(max(10-30N)-min(10-30S) upper 250m)"
    plot_moc(6)                                    = gsn_csm_xy (wks,time_range,STC_PAC,res_time_series)
    res_time_series@trYMinF                        = min(TC_PAC)-(max(TC_PAC)-min(TC_PAC))*0.1 
    res_time_series@trYMaxF                        = max(TC_PAC)+(max(TC_PAC)-min(TC_PAC))*0.1
    res_time_series@tiMainString                   = "TC strength IndPac(max(5S-5N)-min(5S-5N) upper 250m)"
    plot_moc(9)                                    = gsn_csm_xy (wks,time_range,TC_PAC,res_time_series)

    if (plot_running_avg .eq. 1) then
        if (4*line_thickness .ge. 4) then ; limit line thickness
            res_time_series@xyLineThicknessF    =  6
        else
            res_time_series@xyLineThicknessF    =  4*line_thickness
        end if
        plot_running_mean(0)                            = gsn_csm_xy (wks,time_range,runave(AMOC_26N,running_window,0),res_time_series)
        plot_running_mean(3)                            = gsn_csm_xy (wks,time_range,runave(AMOC_30S,running_window,0),res_time_series) 
        plot_running_mean(6)                            = gsn_csm_xy (wks,time_range,runave(STC_PAC,running_window,0),res_time_series)
        plot_running_mean(9)                            = gsn_csm_xy (wks,time_range,runave(TC_PAC,running_window,0),res_time_series)

        overlay(plot_moc(0),plot_running_mean(0))
        overlay(plot_moc(3),plot_running_mean(3))
        overlay(plot_moc(6),plot_running_mean(6))
        overlay(plot_moc(9),plot_running_mean(9))

    end if
      
resP                                = True
resP@gsnMaximize                    = True
resP@txString                       = "KCM validation "+grid+" MOC"
gsn_panel(wks,plot_moc,(/4,3/),resP) 

end if
  

;*****************************************************************************************
; PSI

if (plot_psi_time_series .eq. 1) then
res@tiMainString                  = "ACC"
res@trYMinF                        = min(ACC)-(max(ACC)-min(ACC))*0.1     
res@trYMaxF                        = max(ACC)+(max(ACC)-min(ACC))*0.1 
plot(1)                            = gsn_csm_xy (wks,time_range,ACC,res)  
res@tiMainString                  = "Indonesian Throughflow"
res@trYMinF                        = min(IT)-(max(IT)-min(IT))*0.1      
res@trYMaxF                        = max(IT)+(max(IT)-min(IT))*0.1
plot(4)                            = gsn_csm_xy (wks,time_range,IT,res) 

resP                                = True
resP@gsnMaximize                    = True
resP@txString                       = "KCM validation"
gsn_panel(wks,plot_moc,(/3,3/),resP)  
end if

if (plot_bottom_time_series .eq. 1) then
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
gsn_panel(wks,plot_moc,(/3,3/),resP)  

end if
 



end