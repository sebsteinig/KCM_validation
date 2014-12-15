;*****************************************************************************************
;                                       KCM Validation
;*****************************************************************************************
;
; Calculate and plot basic transport quantities for KCM ORCA2 and ORCA05 experiments. The
; script expects the data in sub-folders for each experiment (e.g. dir/data/P18/P18_1m_00
; 02-0019.moc.nc) like it is created by the "run_cdftools.1.0.sh" script.
;
; 
; History:      
;           1.0  :  Nov. 2014  :  annual mean time series         :  S. Steinig
;           1.1  :  Dez. 2014  :  added choice between ym and 1m  :  S. Steinig
;           1.2  :  Dez. 2014  :  added choice for sub period     :  S. Steinig
;           1.3  :  Dez. 2014  :  added MOC sections              :  S. Steinig
;           1.4  :  Dez. 2014  :  added psi plots                 :  S. Steinig
;           1.4  :  Dez. 2014  :  added ORCA05 transports         :  S. Steinig
;
;*****************************************************************************************

;*****************************************************************************************
; User input
;*****************************************************************************************
begTime = get_cpu_time()
; specify directory
dir                     = "/Users/ssteinig/Documents/Uni/Master/HiWi/KCM"

exp_list                = (/"P18","P20"/)
;exp_list                = (/"P18","P19","P20","P21","P22"/)
;exp_list               = (/"P15","P16","P17"/)
reference_experiment    = "P18"
var_list                = (/"psi"/)                     ; moc, psi, mhst, bottom 

delta_t                 = "ym"                          ; ym or 1m
plot_running_avg        = 1                             ; 0=no, 1=yes
running_avg_window      = 1                             ; number of years to include in the running mean
plot_sub_period         = 0                             ; 0=no, 1=yes
sub_period              = "10-49"

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
plot_psi                    =   0
plot_bottom_time_series     =   0
plot_overturning            =   0

do nn=0,dimsizes(var_list)-1
    if (var_list(nn) .eq. "moc") then
      load_moc              =   1	
      plot_moc_time_series  =   1	
      plot_overturning      =   1			     
    else if (var_list(nn) .eq. "psi") then
      load_psi              =   1					            
      plot_psi              =   1
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
            number_of_latitudes=dimsizes(lat)
            number_of_longitudes=722
            number_of_depths=46
        else if (dimsizes(lat) .eq. 149) then
            grid="ORCA2"
            number_of_latitudes=dimsizes(lat)
            number_of_longitudes=182
            number_of_depths=31
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

if (plot_sub_period .eq. 1) then
    period_str=str_split(sub_period,"-")
    period_start=stringtoint(period_str(0))
    period_end=stringtoint(period_str(1))
end if

if (grid .eq. "ORCA05") then
    frequency="1m"
else if (grid .eq. "ORCA2") then
    frequency="ym"
end if
end if

; find index of chosen reference experiment in exp_list
ref_exp=str_match_ind(exp_list,reference_experiment)

    
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
    
    if (plot_sub_period .eq. 1) then
        period_start_index=period_start-first_year
        period_end_index=last_year-(last_year-period_end)-first_year
    end if
    
else if (delta_t .eq. "1m" .and. grid .eq. "ORCA05")			        
    time_range=ispan(first_year*12-11,last_year*12,1)
    running_window=running_avg_window*12
    
    if (plot_sub_period .eq. 1) then
        period_start_index=(period_start-first_year)*12
        period_end_index=(last_year-(last_year-period_end)-first_year)*12+11
    end if

else if (delta_t .eq. "1m" .and. grid .eq. "ORCA2")		
    print("ERROR: No monthly mean data available for ORCA2 experiments")
end if
end if
end if 


; define available timesteps for each experiment on common time vector "time_range"
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

; check whether reference experiment has data for chosen sub-period, otherwise exit
if (plot_sub_period .eq. 1) then
    if (model_timesteps(ref_exp,1) .le. period_start_index .or. model_timesteps(ref_exp,0) .ge. period_end_index) then
    print("EROOR: Data for reference experiment does not include the chosen sub-period!")
    exit
    end if
end if


;*****************************************************************************************
; MOC

if (load_moc .eq. 1) then

   ; create array to put all experiments on the same time axis "time_range"
    moc_glo_tmp=new((/dimsizes(exp_list),dimsizes(time_range),number_of_depths,number_of_latitudes/),"float")
    moc_atl_tmp=new((/dimsizes(exp_list),dimsizes(time_range),number_of_depths,number_of_latitudes/),"float")
    moc_inp_tmp=new((/dimsizes(exp_list),dimsizes(time_range),number_of_depths,number_of_latitudes/),"float")
    
    do nn=0,dimsizes(exp_list)-1
        f=systemfunc ("ls "+dir+"/data/"+exp_list(nn)+"/"+exp_list(nn)+"_"+frequency+"*moc*.nc")
        file_tmp=addfile(f,"r")
        
        ; load model fields and put it at the time periods calculated in "model_timesteps"
        moc_glo_all=file_tmp->zomsfglo(:,:,:,0)
        moc_atl_all=file_tmp->zomsfatl(:,:,:,0)
        moc_inp_all=file_tmp->zomsfinp(:,:,:,0)
        moc_lat=file_tmp->nav_lat(:,0)
        
        if (grid .eq. "ORCA05") then ;correct lasts latitudes to have monotonically increasing lat vector
            moc_lat(510)=90.0
        else if (grid .eq. "ORCA2") then
            moc_lat(147)=89.75 ;
            moc_lat(148)=90.0
        end if
        end if
        
        moc_glo_all&y=moc_lat ; add latitude values to y-xis
        moc_atl_all&y=moc_lat
        moc_inp_all&y=moc_lat
        
        ; if needed calculate annual mean data  
        if (grid .eq. "ORCA05" .and. delta_t .eq. "ym")
            moc_glo_tmp(nn,model_timesteps(nn,0):model_timesteps(nn,1),:,:)=month_to_annual(moc_glo_all,1)
            moc_atl_tmp(nn,model_timesteps(nn,0):model_timesteps(nn,1),:,:)=month_to_annual(moc_atl_all,1)
            moc_inp_tmp(nn,model_timesteps(nn,0):model_timesteps(nn,1),:,:)=month_to_annual(moc_inp_all,1)
        else
            moc_glo_tmp(nn,model_timesteps(nn,0):model_timesteps(nn,1),:,:)=moc_glo_all
            moc_atl_tmp(nn,model_timesteps(nn,0):model_timesteps(nn,1),:,:)=moc_atl_all
            moc_inp_tmp(nn,model_timesteps(nn,0):model_timesteps(nn,1),:,:)=moc_inp_all
        end if
                                        
        delete([/f,file_tmp,moc_glo_all,moc_atl_all,moc_inp_all,moc_lat/])
    end do
    
    if (plot_sub_period .eq. 1) then
        moc_glo=moc_glo_tmp(:,period_start_index:period_end_index,:,:)
        moc_atl=moc_atl_tmp(:,period_start_index:period_end_index,:,:)
        moc_inp=moc_inp_tmp(:,period_start_index:period_end_index,:,:)
    else
        moc_glo=moc_glo_tmp
        moc_atl=moc_atl_tmp
        moc_inp=moc_inp_tmp
    end if
    
    delete([/moc_glo_tmp,moc_inp_tmp,moc_atl_tmp/])

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

    ; calculate desired moc quantities based on the i,j,k indices above
    AMOC_26N=dim_max_n(moc_atl(:,:,:,index_26N),2) 
    AMOC_30S=dim_max_n(moc_atl(:,:,:,index_30S),2) 
    TC_max=dim_max_n(moc_inp(:,:,0:index_depth_moc,index_5N:index_5S),2)
    TC_min=dim_min_n(moc_inp(:,:,0:index_depth_moc,index_5N:index_5S),2)
    TC_PAC=dim_max_n(TC_max,2)-dim_min_n(TC_min,2)        
    STC_NPAC=dim_max_n(moc_inp(:,:,0:index_depth_moc,index_10N:index_30N),2)
    STC_SPAC=dim_min_n(moc_inp(:,:,0:index_depth_moc,index_10S:index_30S),2)
    STC_PAC=dim_max_n(STC_NPAC,2)-dim_min_n(STC_SPAC,2)
    
    ; calculate mean sections
    MOC_glo=dim_avg_n_Wrap(moc_glo(:,:,:,:),1)
    MOC_atl=dim_avg_n_Wrap(moc_atl(:,:,:,:),1)
    MOC_inp=dim_avg_n_Wrap(moc_inp(:,:,:,:),1)
    
    ; calculate differences relative to chosen reference experiment
    MOC_glo_diff=new((dimsizes(MOC_glo)),"float")
    MOC_atl_diff=new((dimsizes(MOC_atl)),"float")
    MOC_inp_diff=new((dimsizes(MOC_inp)),"float")
    
    copy_VarMeta(MOC_glo,MOC_glo_diff)
    copy_VarMeta(MOC_atl,MOC_atl_diff)
    copy_VarMeta(MOC_inp,MOC_inp_diff)
    
    do nn=0,dimsizes(exp_list)-1
        MOC_glo_diff(nn,:,:)=MOC_glo(nn,:,:)-MOC_glo(ref_exp,:,:)
        MOC_atl_diff(nn,:,:)=MOC_atl(nn,:,:)-MOC_atl(ref_exp,:,:)
        MOC_inp_diff(nn,:,:)=MOC_inp(nn,:,:)-MOC_inp(ref_exp,:,:)
    end do    
    
end if

;*****************************************************************************************
; PSI

if (load_psi .eq. 1) then

   ; create array to put all experiments on the same time axis "time_range"
    PSI=new((/dimsizes(exp_list),dimsizes(time_range),number_of_latitudes,number_of_longitudes/),"float")

    do nn=0,dimsizes(exp_list)-1
    print("loading "+exp_list(nn)+" data")
        f=systemfunc ("ls "+dir+"/data/"+exp_list(nn)+"/"+exp_list(nn)+"_"+frequency+"*psi*.nc")
        file_tmp=addfile(f,"r")
        psi=file_tmp->sobarstf
        psi@_FillValue = 9999
        psi=psi/1000000
        psi_lat=file_tmp->nav_lat
        psi_lon=file_tmp->nav_lon
        delete([/f,file_tmp/])
          
        ; if needed calculate annual mean data  
        if (grid .eq. "ORCA05" .and. delta_t .eq. "ym")
            PSI(nn,model_timesteps(nn,0):model_timesteps(nn,1),:,:)=month_to_annual(psi,1)
        else
            PSI(nn,model_timesteps(nn,0):model_timesteps(nn,1),:,:)=psi
        end if                                      
        delete([/psi/])
    end do
    
    if (plot_sub_period .eq. 1) then
        PSI:=PSI(:,period_start_index:period_end_index,:,:)
    end if

    dims_psi=dimsizes(PSI)
    ; calculate transports, PSI dimensions are: model x time x lat x lon
    transports=(/"ACC","BER","BAR","DAV","FRA","SPG","GSG","KOR","SOY","KUR"/)
    transport_indices=new((/dimsizes(transports),4/),"integer")
    TRANSPORTS=new((/dimsizes(transports),dims_psi(0),dims_psi(1)/),"float")
        
    
    ; Define lat and lon indices for transport calculations
    ;
    ;                       ; ORCA05                        ; ORCA2
    ; ACC (+eastward)       ; (i=448,j=80)-(i=440,j=120)    ; (i=112,j=24)-(i=108,j=34)
    ; BER (+northward)      ; (i=232,j=418)-(i=227,j=418)   ; (i=57,j=124)-(i=55,j=124)
    ; BAR (+northward)      ; (i=591,j=451)-(i=562,j=467)   ; (i=145,j=131)-(i=140,j=137)
    ; DAV (+northward)      ; (i=484,j=427)-(i=466,j=429)   ; (i=119,j=143)-(i=117,j=143)
    ; FRA (+northward)      ; (i=557,j=471)-(i=532,j=471)   ; (i=140,j=137)-(i=133,j=137)
    ; SPG (-stronger gyre)  ; min(i=474:553,j=357:391)      ; min(i=115:135,j=108:115)
    ; GSG (-stronger gyre)  ; min(i=532:584,j=424:462)      ; min(i=132:145,j=124:132)
    ; KOR (+northward)      ; (i=118,j=321)-(i=111,j=327)   ; (i=27,j=100)-(i=26,j=101)
    ; SOY (+northward)      ; (i=141,j=352)-(i=141,j=356)     ; (i=31,j=104)-(i=32,j=105)
    ; KUR (+northward)      ; (i=120,j=312)-(i=98,j=312)  ; (i=26,j=95)-(i=20,j=95)

    ; NCL array indexing starts at 0!
    if (grid .eq. "ORCA05") then
        transport_indices(0,:) = (/447,79,439,119/)
        transport_indices(1,:) = (/231,417,226,417/) 
        transport_indices(2,:) = (/590,450,561,466/) 
        transport_indices(3,:) = (/483,426,465,428/) 
        transport_indices(4,:) = (/556,470,531,470/) 
        transport_indices(5,:) = (/473,552,356,390/) 
        transport_indices(6,:) = (/531,583,423,461/) 
        transport_indices(7,:) = (/117,320,110,326/) 
        transport_indices(8,:) = (/140,351,140,355/) 
        transport_indices(9,:) = (/119,311,97,311/)  
    else if (grid .eq. "ORCA2") then    
        transport_indices(0,:) = (/111,23,107,33/) 
        transport_indices(1,:) = (/56,123,54,123/) 
        transport_indices(2,:) = (/144,130,139,136/) 
        transport_indices(3,:) = (/118,142,116,143/) 
        transport_indices(4,:) = (/139,137,132,136/) 
        transport_indices(5,:) = (/114,134,107,114/) 
        transport_indices(6,:) = (/131,144,123,131/) 
        transport_indices(7,:) = (/26,99,25,100/) 
        transport_indices(8,:) = (/30,103,31,104/) 
        transport_indices(9,:) = (/25,94,20,94/) 
    end if          
    end if
    
    
    TRANSPORTS(0,:,:)=PSI(:,:,transport_indices(0,1),transport_indices(0,0))-PSI(:,:,transport_indices(0,3),transport_indices(0,2))
    TRANSPORTS(1,:,:)=PSI(:,:,transport_indices(1,1),transport_indices(1,0))-PSI(:,:,transport_indices(1,3),transport_indices(1,2))
    TRANSPORTS(2,:,:)=PSI(:,:,transport_indices(2,1),transport_indices(2,0))-PSI(:,:,transport_indices(2,3),transport_indices(2,2))
    TRANSPORTS(3,:,:)=PSI(:,:,transport_indices(3,1),transport_indices(3,0))-PSI(:,:,transport_indices(3,3),transport_indices(3,2))
    TRANSPORTS(4,:,:)=PSI(:,:,transport_indices(4,1),transport_indices(4,0))-PSI(:,:,transport_indices(4,3),transport_indices(4,2))
    TRANSPORTS(5,:,:)=dim_min_n(dim_min_n(PSI(:,:,transport_indices(5,2):transport_indices(5,3),transport_indices(5,0):transport_indices(5,1)),2),2)
    TRANSPORTS(6,:,:)=dim_min_n(dim_min_n(PSI(:,:,transport_indices(6,2):transport_indices(6,3),transport_indices(6,0):transport_indices(6,1)),2),2)
    TRANSPORTS(7,:,:)=PSI(:,:,transport_indices(7,1),transport_indices(7,0))-PSI(:,:,transport_indices(7,3),transport_indices(7,2))
    TRANSPORTS(8,:,:)=PSI(:,:,transport_indices(8,1),transport_indices(8,0))-PSI(:,:,transport_indices(8,3),transport_indices(8,2))
    TRANSPORTS(9,:,:)=PSI(:,:,transport_indices(9,1),transport_indices(9,0))-PSI(:,:,transport_indices(9,3),transport_indices(9,2))

    ; calculate spatial differences of mean fields relative to chosen reference experiment
    print("Calculating spatial differences in psi")

    PSI_mean_ref=new((/dimsizes(exp_list),number_of_latitudes,number_of_longitudes/),"float")
    PSI_diff=new((/dimsizes(exp_list),number_of_latitudes,number_of_longitudes/),"float")

    PSI_mean_ref(0,:,:)=dim_avg_n_Wrap(PSI(ref_exp,:,:,:),0)      
    copy_VarMeta(PSI_mean_ref,PSI_diff)
    
    do nn=0,dimsizes(exp_list)-1
        if (nn .ne. ref_exp) then
            print("averaging "+exp_list(nn)+" field")
            PSI_diff(nn,:,:)=dim_avg_n_Wrap(PSI(nn,:,:,:),0)-PSI_mean_ref(0,:,:)
        end if
    end do    
    delete([/PSI/])
        
end if

;*****************************************************************************************
; Plots
;*****************************************************************************************

; if sub-period is desired, cut the common time vector to chosen period 
if (plot_sub_period .eq. 1) then
    time_range_period=time_range(period_start_index:period_end_index)
    delete(time_range)
    time_range=time_range_period
    first_plotted_year=period_start
    last_plotted_year=period_end
else
    first_plotted_year=first_year
    last_plotted_year=last_year
end if

length_time=dimsizes(time_range)

; define colours for time series
colors=(/"black","dodgerblue4","firebrick4","olivedrab4","purple4","darkorange4","yellow","violetred4"/)


;*****************************************************************************************
; MOC

; define plot resoures
res_moc_time_series                                = True
res_moc_time_series@gsnDraw                        = False                         
res_moc_time_series@gsnFrame                       = False
res_moc_time_series@xyDashPattern                  = 0
res_moc_time_series@trXMinF                        = time_range(0) 
res_moc_time_series@trXMaxF                        = time_range(length_time-1)
res_moc_time_series@xyLineColors                    = colors
line_thickness                                 = 300.0/int2flt(length_time) ; adapt line thickness to number of plotted time steps
if (line_thickness .ge. 4) then ; limit line thickness
    line_thickness = 4
end if
res_moc_time_series@xyLineThicknessF               = line_thickness
res_moc_time_series@tiYAxisString                  = "Sv"
res_moc_time_series@tiXAxisString                  = "Model Year"

; Define Legend
res_moc_time_series@pmLegendDisplayMode    = "Always"            ; turn on legend
res_moc_time_series@pmLegendSide           = "Top"               ; Change location of 
res_moc_time_series@pmLegendParallelPosF   = .8                  ; move units right
res_moc_time_series@pmLegendOrthogonalPosF = -0.45               ; move units down
res_moc_time_series@pmLegendWidthF         = 0.18                ; Change width and
res_moc_time_series@pmLegendHeightF        = 0.18                ; height of legend.
res_moc_time_series@lgLabelFontHeightF     = .03                 ; change font height
res_moc_time_series@lgTitleOn              = False               ; turn on legend title
res_moc_time_series@xyExplicitLegendLabels = " "+exp_list        ; explicit labels
legend_items                           = ispan(0,dimsizes(exp_list)-1,1)
res_moc_time_series@lgItemOrder            = legend_items(::-1)  ; reverse legend

; format the x-axis (time axis)
restick = True
time_range!0="time"
if (delta_t .eq. "1m") then
    time_range@units="months since 0001-01-01"
else
    time_range@units="years since 0000-01-01"
end if
restick@ttmFormat = "%Y" ; 4 digit year
time_axis_labels(time_range,res_moc_time_series,restick)


if (plot_moc_time_series .eq. 1) then

    res_overturning                                = True
    res_overturning@gsnDraw                        = False                         
    res_overturning@gsnFrame                       = False
    res_overturning@cnFillOn                       = True             
    res_overturning@cnLevelSelectionMode           = "ExplicitLevels"
    res_overturning@tiMainString                   = exp_list(ref_exp)
    res_overturning@gsnContourNegLineDashPattern   = 1
    res_overturning@cnLineLabelsOn                 = True
    res_overturning@cnLineLabelPlacementMode       = "computed"
    res_overturning@cnFillPalette                  = "BlueDarkRed18"
    res_overturning@gsnYAxisIrregular2Linear       = True
    res_overturning@gsnXAxisIrregular2Linear       = True
    res_overturning@tiMainString                   = reference_experiment+" (reference)"
    res_overturning@gsnRightString                 = "Sv"
    res_overturning@lbOrientation                  = "vertical" 
    res_overturning@tiYAxisString                  = ""

    ; calculate contour intervals
    contour_intervals_glo=(/floattointeger(min(MOC_glo(ref_exp,:,:))),floattointeger(max(MOC_glo(ref_exp,:,:)))/)
    contour_intervals_atl=(/floattointeger(min(MOC_atl(ref_exp,:,{-35:90}))),floattointeger(max(MOC_atl(ref_exp,:,{-35:90})))/)
    contour_intervals_inp=(/floattointeger(min(MOC_inp(ref_exp,:,{-35:90}))),floattointeger(max(MOC_inp(ref_exp,:,{-35:90})))/)
    contour_intervals_stc=(/floattointeger(min(MOC_inp(ref_exp,0:index_depth_moc,{-30:30}))),floattointeger(max(MOC_inp(ref_exp,0:index_depth_moc,{-30:30})))/)

    contour_limit_glo=max(abs(contour_intervals_glo))
    contour_limit_atl=max(abs(contour_intervals_atl))
    contour_limit_inp=max(abs(contour_intervals_inp))
    contour_limit_stc=max(abs(contour_intervals_stc))

    contour_interval_glo=2*contour_limit_glo/20
    contour_interval_atl=2*contour_limit_atl/20
    contour_interval_inp=2*contour_limit_inp/20
    contour_interval_stc=2*contour_limit_stc/20

    res_overturning_glo=res_overturning
    res_overturning_atl=res_overturning
    res_overturning_inp=res_overturning
    res_overturning_stc=res_overturning

    res_overturning_glo@gsnLeftString           = "Global"
    res_overturning_atl@gsnLeftString           = "Atlantic"
    res_overturning_inp@gsnLeftString           = "Indo-Pacific"
    res_overturning_stc@gsnLeftString           = "STC"

    res_overturning_atl@trXMinF                = -35       
    res_overturning_atl@trXMaxF                =  90 
    res_overturning_inp@trXMinF                = -35       
    res_overturning_inp@trXMaxF                =  90
    res_overturning_stc@trXMinF                = -35 
    res_overturning_stc@trXMaxF                =  35 

    res_overturning_glo_diff=res_overturning_glo
    res_overturning_atl_diff=res_overturning_atl
    res_overturning_inp_diff=res_overturning_inp
    res_overturning_stc_diff=res_overturning_stc

    res_overturning_glo@cnLevels               = ispan(-1*contour_limit_glo,contour_limit_glo,contour_interval_glo)
    res_overturning_atl@cnLevels               = ispan(-1*contour_limit_atl,contour_limit_atl,contour_interval_atl)
    res_overturning_inp@cnLevels               = ispan(-1*contour_limit_inp,contour_limit_inp,contour_interval_inp)
    res_overturning_stc@cnLevels               = ispan(-1*contour_limit_stc,contour_limit_stc,contour_interval_stc)

    res_overturning_glo_diff@cnLevels               = ispan(-50,50,5)/10.0
    res_overturning_atl_diff@cnLevels               = ispan(-50,50,5)/10.0
    res_overturning_inp_diff@cnLevels               = ispan(-50,50,5)/10.0
    res_overturning_stc_diff@cnLevels               = ispan(-50,50,5)/10.0
                                                         
    wks                                 = gsn_open_wks("pdf" ,dir+"/plots/KCM_validation_moc_"+grid+"_"+delta_t+"_"+sprintf("%04.0f",first_plotted_year)+"-"+sprintf("%04.0f",last_plotted_year)) 

    plot_moc                               = new(12,graphic)
    plot_running_mean                      = new(12,graphic)

    ; plot time series
    res_moc_time_series@trYMinF                        = min(AMOC_26N)-(max(AMOC_26N)-min(AMOC_26N))*0.1     
    res_moc_time_series@trYMaxF                        = max(AMOC_26N)+(max(AMOC_26N)-min(AMOC_26N))*0.1  
    res_moc_time_series@tiMainString                   = "AMOC 26.5N"
    plot_moc(0)                                    = gsn_csm_xy (wks,time_range,AMOC_26N,res_moc_time_series)
    res_moc_time_series@trYMinF                        = min(AMOC_30S)-(max(AMOC_30S)-min(AMOC_30S))*0.1 
    res_moc_time_series@trYMaxF                        = max(AMOC_30S)+(max(AMOC_30S)-min(AMOC_30S))*0.1
    res_moc_time_series@tiMainString                   = "AMOC 30S"
    plot_moc(3)                                    = gsn_csm_xy (wks,time_range,AMOC_30S,res_moc_time_series) 
    res_moc_time_series@trYMinF                        = min(STC_PAC)-(max(STC_PAC)-min(STC_PAC))*0.1 
    res_moc_time_series@trYMaxF                        = max(STC_PAC)+(max(STC_PAC)-min(STC_PAC))*0.1
    res_moc_time_series@tiMainString                   = "STC strength IndPac"
    plot_moc(6)                                    = gsn_csm_xy (wks,time_range,STC_PAC,res_moc_time_series)
    res_moc_time_series@trYMinF                        = min(TC_PAC)-(max(TC_PAC)-min(TC_PAC))*0.1 
    res_moc_time_series@trYMaxF                        = max(TC_PAC)+(max(TC_PAC)-min(TC_PAC))*0.1
    res_moc_time_series@tiMainString                   = "TC strength IndPac"
    plot_moc(9)                                    = gsn_csm_xy (wks,time_range,TC_PAC,res_moc_time_series)

    if (plot_running_avg .eq. 1) then
        
        if (line_thickness .le. 1) then
            res_moc_time_series@xyLineThicknessF    =  4*line_thickness
        else
            res_moc_time_series@xyLineThicknessF    =  2*line_thickness
        end if

        plot_running_mean(0)                            = gsn_csm_xy (wks,time_range,runave(AMOC_26N,running_window,0),res_moc_time_series)
        plot_running_mean(3)                            = gsn_csm_xy (wks,time_range,runave(AMOC_30S,running_window,0),res_moc_time_series) 
        plot_running_mean(6)                            = gsn_csm_xy (wks,time_range,runave(STC_PAC,running_window,0),res_moc_time_series)
        plot_running_mean(9)                            = gsn_csm_xy (wks,time_range,runave(TC_PAC,running_window,0),res_moc_time_series)

        overlay(plot_moc(0),plot_running_mean(0))
        overlay(plot_moc(3),plot_running_mean(3))
        overlay(plot_moc(6),plot_running_mean(6))
        overlay(plot_moc(9),plot_running_mean(9))
    end if

    ; plot sections of reference experiment
    plot_moc(1)                            = gsn_csm_contour(wks,MOC_glo(ref_exp,:,:),res_overturning_glo)
    plot_moc(4)                            = gsn_csm_contour(wks,MOC_atl(ref_exp,:,:),res_overturning_atl)
    plot_moc(7)                            = gsn_csm_contour(wks,MOC_inp(ref_exp,:,:),res_overturning_inp)
    plot_moc(10)                           = gsn_csm_contour(wks,MOC_inp(ref_exp,0:index_depth_moc,:),res_overturning_stc)

    ; plot sections of differences  
    column=2
    page=0
    do nn=0,dimsizes(exp_list)-1
        if (nn .ne. ref_exp)
            res_overturning_glo_diff@tiMainString           = exp_list(nn)+" minus "+reference_experiment
            res_overturning_atl_diff@tiMainString           = exp_list(nn)+" minus "+reference_experiment
            res_overturning_inp_diff@tiMainString           = exp_list(nn)+" minus "+reference_experiment
            res_overturning_stc_diff@tiMainString           = exp_list(nn)+" minus "+reference_experiment

            plot_moc(column)                            = gsn_csm_contour(wks,MOC_glo_diff(nn,:,:),res_overturning_glo_diff)
            plot_moc(column+3)                          = gsn_csm_contour(wks,MOC_atl_diff(nn,:,:),res_overturning_atl_diff)
            plot_moc(column+6)                          = gsn_csm_contour(wks,MOC_inp_diff(nn,:,:),res_overturning_inp_diff)
            plot_moc(column+9)                          = gsn_csm_contour(wks,MOC_inp_diff(nn,0:index_depth_moc,:),res_overturning_stc_diff)
            column=column+1
        else
            nn=ref_exp
        end if
        
        ; if third column is used, draw the panel plot and advance to next page
        if (column .eq. 3 .or. nn .eq. dimsizes(exp_list)-1) then   
            resP                                = True
            resP@gsnMaximize                    = True
            resP@txString                       = grid+" MOC"+" "+delta_t+" "+sprintf("%04.0f",first_plotted_year)+"-"+sprintf("%04.0f",last_plotted_year)
            if (page .eq. 0) then
                resP@gsnPanelXWhiteSpacePercent     = 10
            else
                resP@gsnPanelXWhiteSpacePercent     = 1
            end if
            gsn_panel(wks,plot_moc,(/4,3/),resP) 
            page=page+1
            column=0
        end if          
    end do
end if
  

;*****************************************************************************************
; PSI

if (plot_psi .eq. 1) then

print("start plotting time series")
    res_psi_time_series                     = res_moc_time_series
    
    res_polymarker                            = True
    res_polymarker@gsMarkerIndex = 5            ; choose circle as polymarker
    res_polymarker@gsLineThicknessF = 3.0           ; select size to avoid streaking
    res_polymarker@gsLineColor = "green"
    res_polymarker@sfXArray              =  psi_lon                ;-- longitude grid cell center
    res_polymarker@sfYArray              =  psi_lat                ;-- latitude grid cell center
    
    res_psi                                 = True 
    res_psi@gsnDraw                         = False                         
    res_psi@gsnFrame                        = False   
    res_psi@gsnContourZeroLineThicknessF    = 0                 ; eliminates zero contour
    res_psi@gsnContourNegLineDashPattern    = 1                 ; sets negative contours to dash pattern 1 
    res_psi@cnFillOn                        = True              
    res_psi@cnLineDrawOrder                 = "Predraw"         ; Draw lines and filled areas before map gets set
    res_psi@cnFillDrawOrder                 = "Predraw"          
    res_psi@gsnRightString                  = "Sv"
    res_psi@cnFillMode                      = "RasterFill"     
    res_psi@cnLevelSelectionMode            = "ExplicitLevels"  
    res_psi@cnLevels                        = (/-200,-175,-150,-125,-100,-90,-80,-70,-60,-50,-40,-30,-20,-10,0,10,20,30,40,50,60,70,80,90,100,125,150,175,200/)   ; set the contour levels
    res_psi@gsnZonalMean                    = False
    res_psi@cnFillPalette                   = "NCV_blu_red"
    res_psi@cnLineLabelsOn                  = True        		
    res_psi@cnLineLabelPlacementMode        = "computed"
    res_psi@cnLineLabelBackgroundColor      = "white"
    res_psi@mpFillOn                        = True
    res_psi@sfXArray              =  psi_lon                ;-- longitude grid cell center
    res_psi@sfYArray              =  psi_lat                ;-- latitude grid cell center
    res_psi@gsnAddCyclic          =  False                ; don't add lon cyclic point
    
    res_psi_diff                  = res_psi
    delete(res_psi_diff@cnLevels)
    res_psi_diff@cnLevels                        = ispan(-15,15,2) 
    res_psi_diff@cnLinesOn                       = False             
    res_psi_diff@cnLineLabelsOn                  = False  

    wks                                 = gsn_open_wks("pdf" ,dir+"/plots/KCM_validation_psi_"+grid+"_"+delta_t+"_"+sprintf("%04.0f",first_plotted_year)+"-"+sprintf("%04.0f",last_plotted_year)) 

    plot_transports                                   = new(dimsizes(transports),graphic)
    plot_transports_running_mean                      = new(dimsizes(transports),graphic)
    grid_points                                   = new(number_of_longitudes*number_of_latitudes,graphic)
    plot_psi_2d                                   = new(dimsizes(exp_list),graphic)


    do nn=0,dimsizes(transports)-1
        line_thickness                                 = 300.0/int2flt(length_time) ; adapt line thickness to number of plotted time steps
        if (line_thickness .ge. 4) then ; limit line thickness
            line_thickness = 4
        end if
        res_psi_time_series@xyLineThicknessF    =  line_thickness
        res_psi_time_series@trYMinF                        = min(TRANSPORTS(nn,:,:))-(max(TRANSPORTS(nn,:,:))-min(TRANSPORTS(nn,:,:)))*0.1     
        res_psi_time_series@trYMaxF                        = max(TRANSPORTS(nn,:,:))+(max(TRANSPORTS(nn,:,:))-min(TRANSPORTS(nn,:,:)))*0.1  
        res_psi_time_series@tiMainString                   = transports(nn)
        plot_transports (nn)                                    = gsn_csm_xy (wks,time_range,TRANSPORTS(nn,:,:),res_psi_time_series)
    
        if (plot_running_avg .eq. 1) then
            if (line_thickness .le. 1) then
                res_psi_time_series@xyLineThicknessF    =  4*line_thickness
            else
                res_psi_time_series@xyLineThicknessF    =  2*line_thickness
            end if
            
            plot_transports_running_mean(nn)                            = gsn_csm_xy (wks,time_range,runave(TRANSPORTS(nn,:,:),running_window,0),res_psi_time_series)
            overlay(plot_transports(nn),plot_transports_running_mean(nn))
        end if

    end do

    resP                                = True
    resP@gsnMaximize                    = True
    resP@txString                       = grid+" psi"+" "+delta_t+" "+sprintf("%04.0f",first_plotted_year)+"-"+sprintf("%04.0f",last_plotted_year)
    resP@gsnPanelXWhiteSpacePercent     = 10
    gsn_panel(wks,plot_transports,(/4,3/),resP)
  
  print("start plotting 2d fields")
    row=1
    do nn=0,dimsizes(exp_list)-1
        if (nn .eq. ref_exp) then
            res_psi@tiMainString                    = reference_experiment+" (reference)"
            plot_psi_2d(0)                          = gsn_csm_contour_map(wks,PSI_mean_ref(0,:,:),res_psi)
            do tt=0,dimsizes(transports)-1
                if (tt .ne. 5 .and. tt .ne. 6) then
                    grid_points(tt)                          = gsn_add_polyline(wks,plot_psi_2d(0),(/psi_lon(transport_indices(tt,1),transport_indices(tt,0)),psi_lon(transport_indices(tt,3),transport_indices(tt,2))/),(/psi_lat(transport_indices(tt,1),transport_indices(tt,0)),psi_lat(transport_indices(tt,3),transport_indices(tt,2))/),res_polymarker)
                end if
            end do
        else
            res_psi_diff@tiMainString               = exp_list(nn)+" minus "+reference_experiment
            plot_psi_2d(row)                       = gsn_csm_contour_map(wks,PSI_diff(nn,:,:),res_psi_diff)
            row=row+1
        end if
    end do
    
    number_of_rows=dimsizes(exp_list)/3+1       
    resP                                = True
    resP@gsnMaximize                    = True
    resP@txString                       = grid+" psi"+" "+delta_t+" "+sprintf("%04.0f",first_plotted_year)+"-"+sprintf("%04.0f",last_plotted_year)
    resP@gsnPanelXWhiteSpacePercent     = 10
    gsn_panel(wks,plot_psi_2d ,(/3,number_of_rows/),resP) 

    print("Calculated script in " + (get_cpu_time() - begTime) + " seconds") 

end if


end