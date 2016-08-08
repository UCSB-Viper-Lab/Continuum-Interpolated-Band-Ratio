pro CIBR

  ;;; INPUTS ;;;
  base_file = 'f130606t01p00r05_rdn_hpc18_v1_cropAG' ; Image to be calibrated
  base_folder = 'H:\users\swshivers\SodaStrawFlightlines\June2013\';folder in which to find the base file
  img = base_folder+base_file

  out_folder = 'H:\users\swshivers\SodaStrawFlightlines\June2013\CIBR\'
  out_img = out_folder+base_file+'_cibr'

  ;;; SETTING UP ENVI/IDL ENVIRONMENT ;;;
  COMPILE_OPT STRICTARR
  envi, /restore_base_save_files
  ENVI_BATCH_INIT ;Doesn't require having ENVI open - use with stand alone IDL 64 bit
  ;;; DONE SETTING UP ENVI/IDL ENVIRONMENT ;;;
  ;

  envi_open_file, img, R_FID = fidBase ;Open the basefile
  envi_file_query, fidBase, $ ;Get information about basefile
    NS = NS, $ ;Number of Samples
    NL = NL, $ ; Number of Lines
    NB = NB, $ ;Number of Bands
    dims=dims, $
    data_type = data_type, $
    interleave = 1, $
    bnames = BNAMES, $
    wl=WL, $
    map_info = map_info

  ;create empty array for DN image
  rad =   make_array(NS,NL,NB) ;radiance image
  rad55 = make_array(NS,NL);; radiance of band 55
  rad62 = make_array(NS,NL);; radiance of band 62
  rad68 = make_array(NS,NL);; radiance of band 68
  cibr =  make_array(NS,NL);; contiuum integrated band ratio
  ; populate empty array
  
  for z=0,NB-1 do begin
    rad[*,*,z] = ENVI_GET_DATA(fid = fidBase, dims = dims, pos = z)
  endfor
  
  ;; band weights
  w1 = (WL[67]-WL[61])/(WL[67]-WL[54])
  w2 = (WL[61]-WL[54])/(WL[67]-WL[54])

  for s=0,NS-1 do begin
    for b=0,NL-1 do begin
      rad55[s,b] = rad[s,b,54]
      rad62[s,b] = rad[s,b,61]
      rad68[s,b] = rad[s,b,67]
      cibr[s,b] = rad62[s,b]/((w1*rad55[s,b])+(w2*rad68[s,b]))
    endfor
  endfor
  
  
  openw,2,out_img
  writeu, 2, cibr
  close,2
  
  ENVI_SETUP_HEAD, fname= out_img+'.hdr', $
    NB = 1, NL = NL, NS = NS, data_type= 4, interleave=1,$
    map_info = map_info,/write


  print, 'DONE'

END