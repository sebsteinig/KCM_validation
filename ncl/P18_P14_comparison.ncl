;***************************************************************************************** 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"  
;*****************************************************************************************

begin

;*****************************************************************************************
; Load data
;*****************************************************************************************

; detect directory
dir = systemfunc("pwd")

; P14 data
file_P14_psi = systemfunc ("ls "+dir+"/processed/P14/*psi*r182*.nc")
P14_psi_tmp=addfile(file_P14_psi,"r")
P14_psi_temp=P14_psi_tmp->sobarstf(0,:,:)
P14_psi=P14_psi_temp/1000000 ; convert to Sverdrup
copy_VarMeta(P14_psi_temp,P14_psi)

file_P14_mhst = systemfunc ("ls "+dir+"/processed/P14/*mhst*timmean.nc")
P14_mhst_tmp=addfile(file_P14_mhst,"r")
P14_mhst_atl=P14_mhst_tmp->zomht_atl(0,:,0)
P14_mhst_glo=P14_mhst_tmp->zomht_glo(0,:,0)
P14_mhst_pac=P14_mhst_tmp->zomht_pac(0,:,0)
P14_mhst_ind=P14_mhst_tmp->zomht_ind(0,:,0)

file_P14_moc = systemfunc ("ls "+dir+"/processed/P14/*moc*timmean.nc")
P14_moc_tmp=addfile(file_P14_moc,"r")
P14_moc_glo=P14_moc_tmp->zomsfglo(0,:,:,0)
P14_moc_atl=P14_moc_tmp->zomsfatl(0,:,:,0)
P14_moc_pac=P14_moc_tmp->zomsfpac(0,:,:,0)
P14_moc_ind=P14_moc_tmp->zomsfind(0,:,:,0)

P14_lat=P14_moc_tmp->nav_lat(:,0)
P14_lat(147)=89.75 ; correct last latitudes to have monotonically increasing vector for interpolation 
P14_lat(148)=90.0

; P18 data
file_P18_psi = systemfunc ("ls "+dir+"/processed/P18/*psi*r182.nc")
P18_psi_tmp=addfile(file_P18_psi,"r")
P18_psi_temp=P18_psi_tmp->sobarstf(0,:,:)
P18_psi=P18_psi_temp/1000000 ; convert to Sverdrup
copy_VarMeta(P18_psi_temp,P18_psi)

file_P18_mhst = systemfunc ("ls "+dir+"/processed/P18/*mhst*timmean.nc")
P18_mhst_tmp=addfile(file_P18_mhst,"r")
P18_mhst_atl=P18_mhst_tmp->zomht_atl(0,:,0)
P18_mhst_glo=P18_mhst_tmp->zomht_glo(0,:,0)
P18_mhst_pac=P18_mhst_tmp->zomht_pac(0,:,0)
P18_mhst_ind=P18_mhst_tmp->zomht_ind(0,:,0)

file_P18_moc = systemfunc ("ls "+dir+"/processed/P18/*moc*timmean.nc")
P18_moc_tmp=addfile(file_P18_moc,"r")
P18_moc_glo=P18_moc_tmp->zomsfglo(0,:,:,0)
P18_moc_atl=P18_moc_tmp->zomsfatl(0,:,:,0)
P18_moc_pac=P18_moc_tmp->zomsfpac(0,:,:,0)
P18_moc_ind=P18_moc_tmp->zomsfind(0,:,:,0)

P18_lat=P18_moc_tmp->nav_lat(:,0)
P18_lat(510)=90.0 ; correct last latitudes to have monotonically increasing vector for interpolation 

; P19 data
file_P19_psi = systemfunc ("ls "+dir+"/processed/P19/*psi*r182.nc")
P19_psi_tmp=addfile(file_P19_psi,"r")
P19_psi_temp=P19_psi_tmp->sobarstf(0,:,:)
P19_psi=P19_psi_temp/1000000 ; convert to Sverdrup
copy_VarMeta(P19_psi_temp,P19_psi)

file_P19_mhst = systemfunc ("ls "+dir+"/processed/P19/*mhst*timmean.nc")
P19_mhst_tmp=addfile(file_P19_mhst,"r")
P19_mhst_atl=P19_mhst_tmp->zomht_atl(0,:,0)
P19_mhst_glo=P19_mhst_tmp->zomht_glo(0,:,0)
P19_mhst_pac=P19_mhst_tmp->zomht_pac(0,:,0)
P19_mhst_ind=P19_mhst_tmp->zomht_ind(0,:,0)

file_P19_moc = systemfunc ("ls "+dir+"/processed/P19/*moc*timmean.nc")
P19_moc_tmp=addfile(file_P19_moc,"r")
P19_moc_glo=P19_moc_tmp->zomsfglo(0,:,:,0)
P19_moc_atl=P19_moc_tmp->zomsfatl(0,:,:,0)
P19_moc_pac=P19_moc_tmp->zomsfpac(0,:,:,0)
P19_moc_ind=P19_moc_tmp->zomsfind(0,:,:,0)

P19_lat=P19_moc_tmp->nav_lat(:,0)
P19_lat(510)=90.0 ; correct last latitudes to have monotonically increasing vector for interpolation 

; P20 data
file_P20_psi = systemfunc ("ls "+dir+"/processed/P20/*psi*r182.nc")
P20_psi_tmp=addfile(file_P20_psi,"r")
P20_psi_temp=P20_psi_tmp->sobarstf(0,:,:)
P20_psi=P20_psi_temp/1000000 ; convert to Sverdrup
copy_VarMeta(P20_psi_temp,P20_psi)

file_P20_mhst = systemfunc ("ls "+dir+"/processed/P20/*mhst*timmean.nc")
P20_mhst_tmp=addfile(file_P20_mhst,"r")
P20_mhst_atl=P20_mhst_tmp->zomht_atl(0,:,0)
P20_mhst_glo=P20_mhst_tmp->zomht_glo(0,:,0)
P20_mhst_pac=P20_mhst_tmp->zomht_pac(0,:,0)
P20_mhst_ind=P20_mhst_tmp->zomht_ind(0,:,0)

file_P20_moc = systemfunc ("ls "+dir+"/processed/P20/*moc*timmean.nc")
P20_moc_tmp=addfile(file_P20_moc,"r")
P20_moc_glo=P20_moc_tmp->zomsfglo(0,:,:,0)
P20_moc_atl=P20_moc_tmp->zomsfatl(0,:,:,0)
P20_moc_pac=P20_moc_tmp->zomsfpac(0,:,:,0)
P20_moc_ind=P20_moc_tmp->zomsfind(0,:,:,0)

P20_lat=P20_moc_tmp->nav_lat(:,0)
P20_lat(510)=90.0 ; correct last latitudes to have monotonically increasing vector for interpolation 

; load vertical coordinates and invert direction because interpolation function expects increasing values
P14_depw_tmp=P14_moc_tmp->gdepw
P14_depw=P14_depw_tmp*(-1)
copy_VarMeta(P14_depw_tmp,P14_depw)

P18_depw_tmp=P18_moc_tmp->gdepw
P18_depw=P18_depw_tmp*(-1)
copy_VarMeta(P18_depw_tmp,P18_depw)

P19_depw_tmp=P19_moc_tmp->gdepw
P19_depw=P19_depw_tmp*(-1)
copy_VarMeta(P19_depw_tmp,P19_depw)

P20_depw_tmp=P20_moc_tmp->gdepw
P20_depw=P20_depw_tmp*(-1)
copy_VarMeta(P20_depw_tmp,P20_depw)

depw=ispan(0,5000,100) ; define new vertical coordinate to which both fields should be interpolated

; perform linear interpolation of MOC fields to same grid
P14_moc_glo_new=linint2_Wrap(P14_lat,P14_depw,P14_moc_glo,False,P14_lat,depw,0)
P14_moc_atl_new=linint2_Wrap(P14_lat,P14_depw,P14_moc_atl,False,P14_lat,depw,0)
P14_moc_pac_new=linint2_Wrap(P14_lat,P14_depw,P14_moc_pac,False,P14_lat,depw,0)
P14_moc_ind_new=linint2_Wrap(P14_lat,P14_depw,P14_moc_ind,False,P14_lat,depw,0)

P18_moc_glo_new=linint2_Wrap(P18_lat,P18_depw,P18_moc_glo,False,P14_lat,depw,0)
P18_moc_atl_new=linint2_Wrap(P18_lat,P18_depw,P18_moc_atl,False,P14_lat,depw,0)
P18_moc_pac_new=linint2_Wrap(P18_lat,P18_depw,P18_moc_pac,False,P14_lat,depw,0)
P18_moc_ind_new=linint2_Wrap(P18_lat,P18_depw,P18_moc_ind,False,P14_lat,depw,0)

P19_moc_glo_new=linint2_Wrap(P19_lat,P19_depw,P19_moc_glo,False,P14_lat,depw,0)
P19_moc_atl_new=linint2_Wrap(P19_lat,P19_depw,P19_moc_atl,False,P14_lat,depw,0)
P19_moc_pac_new=linint2_Wrap(P19_lat,P19_depw,P19_moc_pac,False,P14_lat,depw,0)
P19_moc_ind_new=linint2_Wrap(P19_lat,P19_depw,P19_moc_ind,False,P14_lat,depw,0)

P20_moc_glo_new=linint2_Wrap(P20_lat,P20_depw,P20_moc_glo,False,P14_lat,depw,0)
P20_moc_atl_new=linint2_Wrap(P20_lat,P20_depw,P20_moc_atl,False,P14_lat,depw,0)
P20_moc_pac_new=linint2_Wrap(P20_lat,P20_depw,P20_moc_pac,False,P14_lat,depw,0)
P20_moc_ind_new=linint2_Wrap(P20_lat,P20_depw,P20_moc_ind,False,P14_lat,depw,0)

P14_moc_glo_new&GDEPW=depw*(-1)
P14_moc_atl_new&GDEPW=depw*(-1)
P14_moc_pac_new&GDEPW=depw*(-1)
P14_moc_ind_new&GDEPW=depw*(-1)

P18_moc_glo_new&GDEPW=depw*(-1)
P18_moc_atl_new&GDEPW=depw*(-1)
P18_moc_pac_new&GDEPW=depw*(-1)
P18_moc_ind_new&GDEPW=depw*(-1)

P19_moc_glo_new&GDEPW=depw*(-1)
P19_moc_atl_new&GDEPW=depw*(-1)
P19_moc_pac_new&GDEPW=depw*(-1)
P19_moc_ind_new&GDEPW=depw*(-1)

P20_moc_glo_new&GDEPW=depw*(-1)
P20_moc_atl_new&GDEPW=depw*(-1)
P20_moc_pac_new&GDEPW=depw*(-1)
P20_moc_ind_new&GDEPW=depw*(-1)

; calculate differences between P18 and P14
P18_P14_moc_glo_diff=P18_moc_glo_new-P14_moc_glo_new
P18_P14_moc_atl_diff=P18_moc_atl_new-P14_moc_atl_new
P18_P14_moc_pac_diff=P18_moc_pac_new-P14_moc_pac_new
P18_P14_moc_ind_diff=P18_moc_ind_new-P14_moc_ind_new

P19_P14_moc_glo_diff=P19_moc_glo_new-P14_moc_glo_new
P19_P14_moc_atl_diff=P19_moc_atl_new-P14_moc_atl_new
P19_P14_moc_pac_diff=P19_moc_pac_new-P14_moc_pac_new
P19_P14_moc_ind_diff=P19_moc_ind_new-P14_moc_ind_new

P20_P14_moc_glo_diff=P20_moc_glo_new-P14_moc_glo_new
P20_P14_moc_atl_diff=P20_moc_atl_new-P14_moc_atl_new
P20_P14_moc_pac_diff=P20_moc_pac_new-P14_moc_pac_new
P20_P14_moc_ind_diff=P20_moc_ind_new-P14_moc_ind_new

P19_P18_moc_glo_diff=P19_moc_glo_new-P18_moc_glo_new
P19_P18_moc_atl_diff=P19_moc_atl_new-P18_moc_atl_new
P19_P18_moc_pac_diff=P19_moc_pac_new-P18_moc_pac_new
P19_P18_moc_ind_diff=P19_moc_ind_new-P18_moc_ind_new

P20_P18_moc_glo_diff=P20_moc_glo_new-P18_moc_glo_new
P20_P18_moc_atl_diff=P20_moc_atl_new-P18_moc_atl_new
P20_P18_moc_pac_diff=P20_moc_pac_new-P18_moc_pac_new
P20_P18_moc_ind_diff=P20_moc_ind_new-P18_moc_ind_new

copy_VarMeta(P18_moc_glo_new,P18_P14_moc_glo_diff)
copy_VarMeta(P18_moc_atl_new,P18_P14_moc_atl_diff)
copy_VarMeta(P18_moc_pac_new,P18_P14_moc_pac_diff)
copy_VarMeta(P18_moc_ind_new,P18_P14_moc_ind_diff)

copy_VarMeta(P19_moc_glo_new,P19_P14_moc_glo_diff)
copy_VarMeta(P19_moc_atl_new,P19_P14_moc_atl_diff)
copy_VarMeta(P19_moc_pac_new,P19_P14_moc_pac_diff)
copy_VarMeta(P19_moc_ind_new,P19_P14_moc_ind_diff)

copy_VarMeta(P20_moc_glo_new,P20_P14_moc_glo_diff)
copy_VarMeta(P20_moc_atl_new,P20_P14_moc_atl_diff)
copy_VarMeta(P20_moc_pac_new,P20_P14_moc_pac_diff)
copy_VarMeta(P20_moc_ind_new,P20_P14_moc_ind_diff)

copy_VarMeta(P19_moc_glo_new,P19_P18_moc_glo_diff)
copy_VarMeta(P19_moc_atl_new,P19_P18_moc_atl_diff)
copy_VarMeta(P19_moc_pac_new,P19_P18_moc_pac_diff)
copy_VarMeta(P19_moc_ind_new,P19_P18_moc_ind_diff)

copy_VarMeta(P20_moc_glo_new,P20_P18_moc_glo_diff)
copy_VarMeta(P20_moc_atl_new,P20_P18_moc_atl_diff)
copy_VarMeta(P20_moc_pac_new,P20_P18_moc_pac_diff)
copy_VarMeta(P20_moc_ind_new,P20_P18_moc_ind_diff)

P14_psi@_FillValue = 9999
P18_psi@_FillValue = 9999
P19_psi@_FillValue = 9999
P20_psi@_FillValue = 9999

P18_P14_psi_diff=P18_psi-P14_psi
P19_P14_psi_diff=P19_psi-P14_psi
P20_P14_psi_diff=P20_psi-P14_psi

P19_P18_psi_diff=P19_psi-P18_psi
P20_P18_psi_diff=P20_psi-P18_psi

copy_VarMeta(P18_psi,P18_P14_psi_diff)
copy_VarMeta(P19_psi,P19_P14_psi_diff)
copy_VarMeta(P20_psi,P20_P14_psi_diff)

copy_VarMeta(P19_psi,P19_P18_psi_diff)
copy_VarMeta(P20_psi,P20_P18_psi_diff)


;*****************************************************************************************
; Plots
;*****************************************************************************************

; PSI

plot_psi=0

if (plot_psi .eq. 1) then

wks                                 = gsn_open_wks("pdf" ,dir+"/plots/psi_KCM") 
plot                                = new(9,graphic)

res                                 = True 
res@gsnDraw                         = False                         
res@gsnFrame                        = False   
res@gsnContourZeroLineThicknessF    = 0                 ; eliminates zero contour
res@gsnContourNegLineDashPattern    = 1                 ; sets negative contours to dash pattern 1 
res@cnFillOn                        = True              
res@cnLineDrawOrder                 = "Predraw"         ; Draw lines and filled areas before map gets set
res@cnFillDrawOrder                 = "Predraw"          
res@gsnRightString                  = "Sv"
res@cnFillMode                      = "RasterFill"     
res@cnLevelSelectionMode            = "ExplicitLevels"  
res@cnLevels                        = (/-200,-175,-150,-125,-100,-90,-80,-70,-60,-50,-40,-30,-20,-10,0,10,20,30,40,50,60,70,80,90,100,125,150,175,200/)   ; set the contour levels
res@gsnZonalMean                    = False
res@cnFillPalette                   = "NCV_blu_red"
res@cnLineLabelsOn                  = True        		
res@cnLineLabelPlacementMode        = "computed"
res@mpFillOn                        = True

res@tiMainString                    = "P14"
plot(0)                             = gsn_csm_contour_map(wks,P14_psi,res)

res@tiMainString                    = "P18"
plot(1)                             = gsn_csm_contour_map(wks,P18_psi,res)
res@tiMainString                    = "P19"
plot(4)                             = gsn_csm_contour_map(wks,P19_psi,res)
res@tiMainString                    = "P20"
plot(7)                             = gsn_csm_contour_map(wks,P20_psi,res)

delete(res@cnLevels)
res@cnLevels                        = ispan(-20,20,2) 
res@cnLinesOn                       = False             
res@cnLineLabelsOn                  = False  

res@tiMainString                    = "P18 minus P14"      		
plot(2)                             = gsn_csm_contour_map(wks,P18_P14_psi_diff,res)
res@tiMainString                    = "P19 minus P14"      		
plot(5)                             = gsn_csm_contour_map(wks,P19_P14_psi_diff,res)
res@tiMainString                    = "P20 minus P14"      		
plot(8)                             = gsn_csm_contour_map(wks,P20_P14_psi_diff,res)
res@tiMainString                    = "P19 minus P18"      		
plot(3)                             = gsn_csm_contour_map(wks,P19_P18_psi_diff,res)
res@tiMainString                    = "P20 minus P18"      		
plot(6)                             = gsn_csm_contour_map(wks,P20_P18_psi_diff,res)

resP                                = True     			
resP@txString                       = "                          Mean barotropic streamfunction ~C~ ~Z75~ contour interval: 10Sv for abs < 100Sv, 25Sv for abs between 100 and 200"
resP@gsnMaximize                    = True          	
gsn_panel(wks,plot,(/3,3/),resP)               			

end if

;*****************************************************************************************
; MHST

plot_mhst=0

if (plot_mhst .eq. 1) then

colors=(/"black","dodgerblue4","firebrick4","olivedrab4"/)

res2                                = True
res2@gsnDraw                        = False                         
res2@gsnFrame                       = False
res2@trYMinF                        = -2.5        
res2@trYMaxF                        = 2.5 
res2@trXMinF                        = -90       
res2@trXMaxF                        = 90 
res2@xyLineThicknessF               = 4.0 
res2@tiYAxisString                  = ""
res2@xyLineColor                    = colors(0)

res3                                = True
res3@gsnDraw                        = False                         
res3@gsnFrame                       = False
res3@trYMinF                        = -2.5        
res3@trYMaxF                        = 2.5 
res3@trXMinF                        = -90       
res3@trXMaxF                        = 90 
res3@xyLineThicknessF               = 4.0     
res3@tiYAxisString                  = ""
res3@xyLineColor                    = colors(1)

res4                                = True
res4@gsnDraw                        = False                         
res4@gsnFrame                       = False
res4@trYMinF                        = -2.5        
res4@trYMaxF                        = 2.5 
res4@trXMinF                        = -90       
res4@trXMaxF                        = 90 
res4@xyLineThicknessF               = 4.0     
res4@tiYAxisString                  = ""
res4@xyLineColor                    = colors(2)

res5                                = True
res5@gsnDraw                        = False                         
res5@gsnFrame                       = False
res5@trYMinF                        = -2.5        
res5@trYMaxF                        = 2.5 
res5@trXMinF                        = -90       
res5@trXMaxF                        = 90 
res5@xyLineThicknessF               = 4.0     
res5@tiYAxisString                  = ""
res5@xyLineColor                    = colors(3) 

wks                                 = gsn_open_wks("pdf" ,dir+"/plots/mht_KCM") 
plot2                               = new(4,graphic)
plot3                               = new(4,graphic)
plot4                               = new(4,graphic)
plot5                               = new(4,graphic)

res2@tiMainString                   = "Global"
plot2(0)                            = gsn_csm_xy (wks,P14_lat,P14_mhst_glo,res2) 
plot3(0)                            = gsn_csm_xy (wks,P18_lat,P18_mhst_glo,res3) 
plot4(0)                            = gsn_csm_xy (wks,P19_lat,P19_mhst_glo,res4) 
plot5(0)                            = gsn_csm_xy (wks,P20_lat,P20_mhst_glo,res5) 
overlay(plot2(0),plot3(0))
overlay(plot2(0),plot4(0))
overlay(plot2(0),plot5(0))

res2@tiMainString                   = "Atlantic"
plot2(1)                            = gsn_csm_xy (wks,P14_lat,P14_mhst_atl,res2) 
plot3(1)                            = gsn_csm_xy (wks,P18_lat,P18_mhst_atl,res3) 
plot4(1)                            = gsn_csm_xy (wks,P19_lat,P19_mhst_atl,res4) 
plot5(1)                            = gsn_csm_xy (wks,P20_lat,P20_mhst_atl,res5) 
overlay(plot2(1),plot3(1))
overlay(plot2(1),plot4(1))
overlay(plot2(1),plot5(1))

res2@tiMainString                   = "Pacific"
plot2(2)                            = gsn_csm_xy (wks,P14_lat,P14_mhst_pac,res2) 
plot3(2)                            = gsn_csm_xy (wks,P18_lat,P18_mhst_pac,res3) 
plot4(2)                            = gsn_csm_xy (wks,P19_lat,P19_mhst_pac,res4) 
plot5(2)                            = gsn_csm_xy (wks,P20_lat,P20_mhst_pac,res5) 
overlay(plot2(2),plot3(2))
overlay(plot2(2),plot4(2))
overlay(plot2(2),plot5(2))

res2@tiMainString                   = "Indian"
plot2(3)                            = gsn_csm_xy (wks,P14_lat,P14_mhst_ind,res2) 
plot3(3)                            = gsn_csm_xy (wks,P18_lat,P18_mhst_ind,res3) 
plot4(3)                            = gsn_csm_xy (wks,P19_lat,P19_mhst_ind,res4) 
plot5(3)                            = gsn_csm_xy (wks,P20_lat,P20_mhst_ind,res5) 
overlay(plot2(3),plot3(3))
overlay(plot2(3),plot4(3))
overlay(plot2(3),plot5(3))

; Attach a legend
lgres                    = True
lgres@lgLineColors       = colors(::-1)
lgres@lgLineThicknessF   = 4.0

lgres@lgItemType         = "Lines"        ; show lines only (default)
lgres@lgLabelFontHeightF = .08            ; legend label font thickness
lgres@vpWidthF           = 0.2           ; width of legend (NDC)
lgres@vpHeightF          = 0.2           ; height of legend (NDC)
lgres@lgPerimThicknessF  = 2.0            ; thicken the box perimeter
lgres@lgMonoDashIndex    = True
lgres@lgDashIndex        = 0

labels = (/"  P20","  P19","  P18","  P14"/)
legend = gsn_create_legend (wks, 4, labels,lgres)
legend2 = gsn_create_legend (wks, 4, labels,lgres)
legend3 = gsn_create_legend (wks, 4, labels,lgres)
legend4 = gsn_create_legend (wks, 4, labels,lgres)

amres                  = True
amres@amJust           = "BottomRight"    ; Use bottom right corner of box
                                        ; for determining its location.
amres@amParallelPosF   = 0.5              ; Move legend to right
amres@amOrthogonalPosF = 0.5              ; Move legend down.

annoid = gsn_add_annotation(plot2(0),legend,amres)  ; add legend to plot
annoid2 = gsn_add_annotation(plot2(1),legend2,amres)  ; add legend to plot
annoid3 = gsn_add_annotation(plot2(2),legend3,amres)  ; add legend to plot
annoid4 = gsn_add_annotation(plot2(3),legend4,amres)  ; add legend to plot

resP                                = True
resP@gsnMaximize                    = True
resP@txString                       = "Meridional heat transport in PW"
gsn_panel(wks,plot2,(/2,2/),resP)    

end if

;*****************************************************************************************
; MOC

plot_moc=1

if (plot_moc .eq. 1) then

res4                                = True
res4@gsnDraw                        = False                         
res4@gsnFrame                       = False
res4@cnFillOn                       = True             
res4@cnLevelSelectionMode           = "ExplicitLevels"
res4@cnLevels                       = ispan(-40,40,5)
res4@gsnContourNegLineDashPattern   = 1
res4@cnLineLabelsOn                 = True
res4@cnLineLabelPlacementMode       = "computed"
res4@cnFillPalette                  = "BlueDarkRed18"                                                           

; global

wks                                 = gsn_open_wks("pdf" ,dir+"/plots/moc_global_KCM") 
plot4                               = new(9,graphic)

res4@tiMainString                   = "P14"
plot4(0)                            = gsn_csm_contour(wks,P14_moc_glo_new,res4)
res4@tiMainString                   = "P18"                                    
plot4(1)                            = gsn_csm_contour(wks,P18_moc_glo_new,res4)     
res4@tiMainString                   = "P19"                                    
plot4(4)                            = gsn_csm_contour(wks,P19_moc_glo_new,res4)     
res4@tiMainString                   = "P20"                                    
plot4(7)                            = gsn_csm_contour(wks,P20_moc_glo_new,res4)     


delete(res4@cnLevels)
res4@cnLevels                       = ispan(-10,10,2)
res4@tiMainString                   = "P18 minus P14"
plot4(2)                            = gsn_csm_contour(wks,P18_P14_moc_glo_diff,res4)
res4@tiMainString                   = "P19 minus P14"
plot4(5)                            = gsn_csm_contour(wks,P19_P14_moc_glo_diff,res4)
res4@tiMainString                   = "P20 minus P14"
plot4(8)                            = gsn_csm_contour(wks,P20_P14_moc_glo_diff,res4)

delete(res4@cnLevels)
res4@cnLevels                       = ispan(-5,5,1)
res4@tiMainString                   = "P19 minus P18"
plot4(3)                            = gsn_csm_contour(wks,P19_P18_moc_glo_diff,res4)
res4@tiMainString                   = "P20 minus P18"
plot4(6)                            = gsn_csm_contour(wks,P20_P18_moc_glo_diff,res4)

resP                                = True
resP@gsnMaximize                    = True
resP@txString                       = "Global meridional overturning"
gsn_panel(wks,plot4,(/3,3/),resP)   

; Atlantic

wks                                 = gsn_open_wks("pdf" ,dir+"/plots/moc_atlantic_KCM") 
plot4                               = new(9,graphic)

delete(res4@cnLevels)
res4@cnLevels                       = ispan(-15,15,1)
res4@trXMinF                        = -35 

res4@tiMainString                   = "P14"
plot4(0)                            = gsn_csm_contour(wks,P14_moc_atl_new,res4)
res4@tiMainString                   = "P18"                                    
plot4(1)                            = gsn_csm_contour(wks,P18_moc_atl_new,res4)     
res4@tiMainString                   = "P19"                                    
plot4(4)                            = gsn_csm_contour(wks,P19_moc_atl_new,res4)     
res4@tiMainString                   = "P20"                                    
plot4(7)                            = gsn_csm_contour(wks,P20_moc_atl_new,res4)     


delete(res4@cnLevels)
res4@cnLevels                       = ispan(-50,50,5)/10.0
res4@tiMainString                   = "P18 minus P14"
plot4(2)                            = gsn_csm_contour(wks,P18_P14_moc_atl_diff,res4)
res4@tiMainString                   = "P19 minus P14"
plot4(5)                            = gsn_csm_contour(wks,P19_P14_moc_atl_diff,res4)
res4@tiMainString                   = "P20 minus P14"
plot4(8)                            = gsn_csm_contour(wks,P20_P14_moc_atl_diff,res4)


delete(res4@cnLevels)
res4@cnLevels                       = ispan(-50,50,5)/10.0
res4@tiMainString                   = "P19 minus P18"
plot4(3)                            = gsn_csm_contour(wks,P19_P18_moc_atl_diff,res4)
res4@tiMainString                   = "P20 minus P18"
plot4(6)                            = gsn_csm_contour(wks,P20_P18_moc_atl_diff,res4)

resP                                = True
resP@gsnMaximize                    = True
resP@txString                       = "Atlantic meridional overturning"
gsn_panel(wks,plot4,(/3,3/),resP)   

; Pacific

wks                                 = gsn_open_wks("pdf" ,dir+"/plots/moc_pacific_KCM") 
plot4                               = new(9,graphic)

delete(res4@cnLevels)
res4@cnLevels                       = ispan(-15,15,1)

res4@tiMainString                   = "P14"
plot4(0)                            = gsn_csm_contour(wks,P14_moc_pac_new,res4)
res4@tiMainString                   = "P18"                                    
plot4(1)                            = gsn_csm_contour(wks,P18_moc_pac_new,res4)     
res4@tiMainString                   = "P19"                                    
plot4(4)                            = gsn_csm_contour(wks,P19_moc_pac_new,res4)     
res4@tiMainString                   = "P20"                                    
plot4(7)                            = gsn_csm_contour(wks,P20_moc_pac_new,res4)     


delete(res4@cnLevels)
res4@cnLevels                       = ispan(-50,50,5)/10.0
res4@tiMainString                   = "P18 minus P14"
plot4(2)                            = gsn_csm_contour(wks,P18_P14_moc_pac_diff,res4)
res4@tiMainString                   = "P19 minus P14"
plot4(5)                            = gsn_csm_contour(wks,P19_P14_moc_pac_diff,res4)
res4@tiMainString                   = "P20 minus P14"
plot4(8)                            = gsn_csm_contour(wks,P20_P14_moc_pac_diff,res4)

delete(res4@cnLevels)
res4@cnLevels                       = ispan(-50,50,5)/10.0
res4@tiMainString                   = "P19 minus P18"
plot4(3)                            = gsn_csm_contour(wks,P19_P18_moc_pac_diff,res4)
res4@tiMainString                   = "P20 minus P18"
plot4(6)                            = gsn_csm_contour(wks,P20_P18_moc_pac_diff,res4)

resP                                = True
resP@gsnMaximize                    = True
resP@txString                       = "Pacific meridional overturning"
gsn_panel(wks,plot4,(/3,3/),resP)   


end if

end
