pro echo_int_GM11_V3, date, daynight, Flength
;
; echo integration for GM11 data
; first version uses 3 times sd of signal above mean signal as a threshold
; V2 uses 2 * median as a threshold
; V3 uses same threshold as original, but only top half of penetration depth range
;
pol = 'X'			;  CO, X
filter = 'median'

;date = '09-29'
;daynight = 'night'
;Flength = 100     ; median filter length (m)
print, date, '  ', daynight, '  ', Flength

gain = 1.0		; adjust gain to make schools more visible
gc = ''
loadct, 41
data = ''

plot_shots = 'NO'

; read track file
track = 'C:\Users\jchurnside\Documents\oil spills\flight tracks\final track '+ date +'.csv'
Nlines = file_lines(track) - 1
Ttime1 = fltarr(Nlines)
Tlon1 = fltarr(Nlines)
Tlat1 = fltarr(Nlines)
Tdepth1 = fltarr(Nlines)
Tturn1 = intarr(Nlines)
Tbin1 = intarr(Nlines)
close, 5
openr, 5, track
readf, 5, data
for i = 0, Nlines-2 do begin
    readf, 5, data
    pd = strsplit(data,",",/extract)
    Ttime1[i] = float(pd[0])
    Tlon1[i] = float(pd[1])
    Tlat1[i] = float(pd[2])
    Tdepth1[i] = float(pd[9])
    Tturn1[i] = fix(pd[10])
    Tbin1[i] = fix(pd[11])
endfor
close, 5

if daynight eq 'day' then begin
    good = where(Ttime1 gt 10.0, Nlines)
    Ttime = Ttime1[good]
    Tlon = Tlon1[good]
    Tlat = Tlat1[good]
    Tdepth = Tdepth1[good]
    Tturn = Tturn1[good]
    Tbin = Tbin1[good]    
endif else begin
    good = where(Ttime1 lt 10.0, Nlines)
    Ttime = Ttime1[good]
    Tlon = Tlon1[good]
    Tlat = Tlat1[good]
    Tdepth = Tdepth1[good]
    Tturn = Tturn1[good]
    Tbin = Tbin1[good]    
endelse
Nbins = max(Tbin) + 1
echo = fltarr(Nbins)
Necho = fltarr(Nbins)
; 
; get input files
files1 = file_search('C:\raw data\GM11\'+date+'\*.png', count=Nfiles1)
; files1 = file_search('C:\raw data\GM11\'+date+'\FL11273024830.png', count=Nfiles1)
q = intarr(Nfiles1)
for f = 0, Nfiles1-1 do begin
    p = strsplit(files1[f],'FL',/extract)
    q[f] = fix(strmid(p[1],5,1))
endfor
if daynight eq 'day' then good = where(q gt 0, Nfiles) else good = where(q eq 0, Nfiles)
files = strarr(Nfiles)
files = files1[good]
print, 'number of files:  ', nfiles

; open output file
close, 6
outfile = 'C:\Users\jchurnside\Documents\oil spills\results\echo int3 '+date+'_'+daynight+string(Flength)+'.csv'
openw, 6, outfile
printf, 6, 'time, lon, lat, depth, echo'

;define constants
nsamples = 1000
surf_type = 12			;0 is peak detection, 1 is max slope, >1 is peak/100 + peak
height = 300			;flight altitude (m)
z0 = -2					;top of linear fit (m)
plot_depth = -50		;maximum depth in plot
cal = 100.0				;calibration coefficient - photocathode current to volume backscatter coefficient
						; based on Table Mountain measurements of entire system

;define arrays
shottime = strarr(2000)	;time
lat = fltarr(2000)		;latitude
lon = fltarr(2000)		;longitude
d = fltarr(1999)		;distance between shots
icath = fltarr(1000)	;PMT cathode current for 1 shot
turn = intarr(2000)		;turn flag (0 is no turn)
i2 = fltarr(506)		;506 samples/shot after surface correction
i3 = fltarr(2000,506)	;[shot,sample] after noise subtraction
i4 = fltarr(2000,506)	;after correction for attenuation
lin_fit = fltarr(506)	;linear fit with r-squared correction
m = fltarr(506)
first0 = intarr(2000)	;index of first 0 in shot
z = fltarr(506)			;depth (m)
tvg = fltarr(506)		;r-squared loss
peak = fltarr(2000)		;peak value of i4

for i = 0, 505 do begin
  z[i] = 5.0 - 0.1089*i
  tvg[i] = (height/(height-z[i]))^2
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;loop over files
for file  = 0, Nfiles-1 do begin 
; print, files[file], '    ', file, '  of  ', nfiles-1

  queryStatus = QUERY_IMAGE(files[file], info)
  dimensions = info.dimensions
  nshots = dimensions[0]
  if nshots lt 2000 then continue

  ;read data
  rawdata = read_png(files[file], /order)

  ;loop over shots
  for shot = 0, 1999 do begin

    ; read auxiliary data
    sub_read_aux_GM11, RAWDATA, SHOT, TIME, SLAT, SLON, CO_GAIN, X_GAIN, TILT
    
    lat[shot] = SLAT		&		lon[shot] = SLON	&	shottime[shot] = time
    if shot gt 0 then d[shot-1] = sqrt((lat[shot]-lat[0])^2 + $
    	(lon[shot]-lon[0])^2*(cos(lat[shot]*3.14159/180))^2)*60*1852

	  sub_convert_shot_GM11, rawdata,shot,co_gain,x_gain,pol,icath
    sub_surface_correct_gm11, surf_type,icath,nsamples, i2,surfi
    i2 = tvg*i2

    noise = moment(icath[900:999],sdev=sdev)

    i3[shot,*] = i2[*] - noise[0]

    ;reduce noise
    i3[shot,*] = 0 > smooth(i3[shot,*],5)
     
    if plot_shots eq 'YES' then begin
        plot, -z, i3[shot,*], /ylog
        wait, 0.05
    endif

  endfor	;end of shot loop
  
  if min(lat) le 10 then continue     ; takes care of missing position data
  Nfilter = fix(d[1998]/Flength + 0.5)      ; number of median filters in a file
  Nfiltershots = fix(2000/Nfilter)
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; median filter
  if filter eq 'median' then begin
      
      ; loop over median filters
      for n = 0, Nfilter-1 do begin
          shot1 = n*Nfiltershots
          shot2 = shot1 + Nfiltershots-1
          mintime1 = min(abs(shottime[shot1]-Ttime), Tline1)
          mintime2 = min(abs(shottime[shot2]-Ttime), Tline2)
          zmax = 0.5*min(Tdepth[Tline1:Tline2])               ; *0.5 to use only top half of penetration depth
          if zmax lt 3 then continue
          izmax = fix((5+zmax)/0.1089)
          Fbin = median(Tbin[Tline1:Tline2])
          I4 = fltarr(506)
          m = median(I3[n*Nfiltershots:n*Nfiltershots+Nfiltershots-1,*],dimension=1)
          ave = mean(I3[n*Nfiltershots:n*Nfiltershots+Nfiltershots-1,*],dimension=1)
          sigma = stddev(I3[n*Nfiltershots:n*Nfiltershots+Nfiltershots-1,*],dimension=1)
          m = m > 1e-5*max(m)
          for shot = 0, Nfiltershots-1 do begin
              I4[*] = (I3[n*Nfiltershots+shot,*] - m[*])/m[*]
               if max((I3[n*Nfiltershots+shot,64:izmax]-ave[64:izmax])/sigma[64:izmax]) gt 3 then begin
                   good = where((I3[n*Nfiltershots+shot,64:izmax]-ave[64:izmax])/sigma[64:izmax] gt 3)
              ;if max(I4[64:izmax]) gt 1 then begin
              ;    good = where(I4[64:izmax] gt 1)
                  signal = 0
                  if max(Tturn[Tline1:Tline2]) eq 0 then signal = total(I4[64+good])/(z[64]-z[izmax])
                  echo[Fbin] = echo[Fbin] + signal
                  ;plot, -z[64:izmax], I3[n*Nfiltershots+shot,64:izmax], /ylog, background=-1, color=0, title=n*Nfiltershots+shot
                  ;oplot, -z[64:izmax], ave[64:izmax], color=255
                  ;oplot, -z[64+good], ave[64+good], color=128, psym=1
                  ;oplot, -z[64:izmax], sigma[64:izmax], color=255*255
                  ;oplot, -z[64:izmax], ave[64:izmax] + 3*sigma[64:izmax], color=255*255
                  ;stop
                  ;endif
                  ;plot, -z[0:izmax], I4[shot,0:izmax], background=-1, color=0, yrange=[-1,1], xrange=[0,zmax], title=n*Nfiltershots+shot 
                  ;oplot, [0,20], [0,0], color=255
                  ;stop
              endif    
          endfor
          if max(Tturn[Tline1:Tline2]) eq 0 then begin
              ;signal = total(I4[*,64:izmax])/(z[64]-z[izmax])
              ;print, signal
              ;if signal gt 0.0 then echo[Fbin] = echo[Fbin] + signal
              Necho[Fbin] ++
          endif
     ;;;;;;     
          ;plot, -z[0:izmax], m[0:izmax], background=-1, color=0, /ylog
          ;oplot, -z[0:izmax], mean(I3[n*Nfiltershots:n*Nfiltershots+Nfiltershots-1,0:izmax], dimension=1), color=255
          ;wait, 0.5
     ;;;;
      endfor
          
      ;plot, -z[0:izmax], m[0:izmax], /ylog, background=-1, color=0, thick=2
      ;stop
      ; oplot, -z[0:izmax], I3[n*Nfiltershots,*], color=128, thick=2
      ;plot,-z[0:zmax], mean(I4[*,0:zmax], dimension=1), background=-1, color=0, xrange=[0,40], yrange=[-0.01,0.5]
      ;oplot,-z[0:zmax], stddev(I4[*,0:zmax], dimension=1), color=128
      ;wait, 0.1
      ;printf, 6, -lon[(n+0.5)*Nfiltershots], lat[(n+0.5)*Nfiltershots], -z[izmax], total(I4[*,64:izmax]) / (z[64]-z[izmax]), $
      ;      format='(3(f15.5,","),f15.5)'
      ; if total(I4[*,64:izmax]) / (z[64]-z[izmax]) gt 1e4 then stop
  endif       ; end of median filter
  
endfor		; end of loop over files
     
; loop over bins
for b = 0, Nbins-1 do begin
    bin_lines = where(Tbin eq b)
    final_time = mean(Ttime[bin_lines])
    final_longitude = mean(Tlon[bin_lines])
    final_latitude = mean(Tlat[bin_lines])
    final_depth = mean(Tdepth[bin_lines])
    intecho = echo[b]/(Necho[b] > 1)   
    printf, 6, final_time, final_longitude, final_latitude, final_depth, intecho, format = '(4(f15.5,","),E15.5)'    
endfor

quit:
wdelete, 1
close, 6
print, 'done'

end
