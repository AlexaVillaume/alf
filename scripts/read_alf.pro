FUNCTION READ_ALF_ONE, file, old=old, nwalker=nwalker

  ;library correction factors from Schiavon 2007 Table 6
  ;note that I have forced the library corrections factors to
  ;be zero for [Fe/H]=0.0,0.2
  libfeh  = [-1.6,-1.4,-1.2,-1.0,-0.8,-0.6,-0.4,-0.2,0.0,0.2]
  libofe  = [0.6,0.5,0.5,0.4,0.3,0.2,0.2,0.1,0.0,0.0]
  libmgfe = [0.4,0.4,0.4,0.4,0.29,0.20,0.13,0.08,0.0,0.0]
  libcafe = [0.32,0.3,0.28,0.26,0.20,0.12,0.06,0.02,0.0,0.0]

  sdir = getenv('SPECFIT_HOME')
  dir  = sdir+'/results/'
  openr,lun,dir+file,/get_lun
  ss = '#'
  WHILE strmid(ss,0,1) EQ '#' DO readf,lun,ss
  ts = strsplit(ss,' ',/extr)
  close,lun
  free_lun,lun

  IF n_elements(ts) EQ 49 THEN BEGIN
     readcol,dir+file,chi2,velz,sigma,logage,zh,feh,afe,cfe,$
             nfe,nafe,mgfe,sife,kfe,cafe,tife,vfe,crfe,mnfe,cofe,nife,$
             cufe,srfe,bafe,eufe,teff,imf1,imf2,logfy,sigma2,$
             velz2,logm7g,hotteff,loghot,fy_logage,logtrans,d1,d2,d3,d4,d5,$
             jitter,imf3,logsky,m2lr,m2li,m2lk,m2lmwr,m2lmwi,m2lmwk,/sil
  ENDIF ELSE IF n_elements(ts) EQ 48 THEN BEGIN
     readcol,dir+file,chi2,velz,sigma,logage,zh,feh,afe,cfe,$
             nfe,nafe,mgfe,sife,kfe,cafe,tife,vfe,crfe,mnfe,cofe,nife,$
             cufe,srfe,bafe,eufe,teff,imf1,imf2,logfy,sigma2,$
             velz2,logm7g,hotteff,loghot,fy_logage,logtrans,d1,d2,d3,d4,d5,$
             jitter,imf3,m2lr,m2li,m2lk,m2lmwr,m2lmwi,m2lmwk,/sil
     logsky = findgen(n_elements(chi2))
  ENDIF ELSE IF n_elements(ts) EQ 47 THEN BEGIN
     readcol,dir+file,chi2,velz,sigma,logage,zh,feh,afe,cfe,$
             nfe,nafe,mgfe,sife,kfe,cafe,tife,vfe,crfe,mnfe,cofe,nife,$
             cufe,srfe,bafe,eufe,teff,imf1,imf2,logfy,sigma2,$
             velz2,logm7g,hotteff,loghot,fy_logage,logtrans,d1,d2,d3,d4,d5,$
             jitter,m2lr,m2li,m2lk,m2lmwr,m2lmwi,m2lmwk,/sil
     imf3 = findgen(n_elements(chi2))
     logsky = findgen(n_elements(chi2))
  ENDIF ELSE IF n_elements(ts) EQ 46 THEN BEGIN
     readcol,dir+file,chi2,velz,sigma,logage,zh,feh,afe,cfe,$
             nfe,nafe,mgfe,sife,kfe,cafe,tife,vfe,crfe,mnfe,cofe,nife,$
             cufe,srfe,bafe,eufe,teff,imf1,imf2,logfy,sigma2,$
             velz2,logm7g,hotteff,loghot,fy_logage,logtrans,d1,d2,d3,d4,d5,$
             m2lr,m2li,m2lk,m2lmwr,m2lmwi,m2lmwk,/sil
     imf3 = findgen(n_elements(chi2))
     jitter = findgen(n_elements(chi2))
     logsky = findgen(n_elements(chi2))
  ENDIF ELSE IF n_elements(ts) EQ 45 THEN BEGIN
     readcol,dir+file,chi2,velz,sigma,logage,feh,afe,cfe,$
             nfe,nafe,mgfe,sife,kfe,cafe,tife,vfe,crfe,mnfe,cofe,nife,$
             cufe,srfe,bafe,eufe,teff,imf1,imf2,logfy,sigma2,$
             velz2,logm7g,hotteff,loghot,fy_logage,logtrans,d1,d2,d3,d4,d5,$
             m2lr,m2li,m2lk,m2lmwr,m2lmwi,m2lmwk,/sil
     imf3 = findgen(n_elements(chi2))
     zh = findgen(n_elements(chi2))
     jitter = findgen(n_elements(chi2))
     logsky = findgen(n_elements(chi2))
  ENDIF ELSE BEGIN
     print,'READ_ALF ERROR: file format not recognized, returning...'
     return,0
  ENDELSE 

  nhe  = fltarr(n_elements(chi2))
  yfe  = fltarr(n_elements(chi2))
  rbfe = fltarr(n_elements(chi2))
  zrfe = fltarr(n_elements(chi2))
  IF n_elements(logtrans) EQ 0 THEN logtrans=fltarr(n_elements(chi2))

  str = {name:'',ngc:0L,logage:0.0,zh:0.0,feh:0.0,afe:0.0,cfe:0.0,nfe:0.0,nafe:0.0,$
         mgfe:0.0,sife:0.0,cafe:0.0,tife:0.0,crfe:0.0,mnfe:0.0,bafe:0.0,$
         srfe:0.0,nife:0.0,cufe:0.0,cofe:0.0,eufe:0.0,kfe:0.0,vfe:0.0,$
         yfe:0.0,zrfe:0.0,rbfe:0.0,nhe:0.0,teff:0.0,imf1:0.0,imf2:0.0,$
         imf3:0.0,logfy:0.0,fy_logage:0.0,sigma:0.0,sigma2:0.0,tfeh:0.0,$
         velz:0.0,velz2:0.0,logm7g:0.0,hotteff:0.0,loghot:0.0,$
         logtrans:0.0,chi2:0.0,mlk:0.0,mli:0.0,mlr:0.0,mlk_mw:0.0,$
         mli_mw:0.0,mlr_mw:0.0,indgb:0.0,emline:fltarr(5),lsig:0.0,ml:0.0,$
         lage:99.0,vmag:99.,fuv:99.,nuv:99.,logemline_h:0.0,logemline_oiii:0.0,$
         logemline_sii:0.0,logemline_ni:0.0,logemline_nii:0.0,delafe:0.0,$
         delmgfe:0.0,delcafe:0.0,jitter:0.0,logsky:0.0,logm:0.0}

  ss = strpos(file,'errp')
  IF ss EQ -1 THEN BEGIN
     tfeh = feh
  ENDIF ELSE BEGIN
     tfeh = fltarr(n_elements(feh))
  ENDELSE

  res = replicate(str,n_elements(logage))

  res.chi2 = chi2
  res.zh   = zh
  res.tfeh = feh
  
  ;fold in the [Z/H] result into [Fe/H]
  IF ss EQ -1 THEN BEGIN
     res.feh = res.zh + feh
  ENDIF ELSE BEGIN
     res.feh = sqrt(res.zh^2+feh^2)
  ENDELSE

  ;compute the library enhancement factors
  IF ss EQ -1 THEN BEGIN
     delafe  = fltarr(n_elements(feh))
     delmgfe = delafe
     delcafe = delafe
     FOR i=0,n_elements(feh)-1 DO BEGIN
        delafe[i]  = mylinterp(libfeh,libofe,res[i].zh)
        delmgfe[i] = mylinterp(libfeh,libmgfe,res[i].zh)
        delcafe[i] = mylinterp(libfeh,libcafe,res[i].zh)
     ENDFOR
  ENDIF ELSE BEGIN
     delafe  = 0.0
     delmgfe = 0.0
     delcafe = 0.0
  ENDELSE

  res.delafe  = delafe
  res.delcafe = delcafe
  res.delmgfe = delmgfe

  res.afe  = afe-tfeh  + delafe
  res.mgfe = mgfe-tfeh + delmgfe

  ;assume that Ca~Ti~Si
  res.sife = sife-tfeh + delcafe
  res.cafe = cafe-tfeh + delcafe
  res.tife = tife-tfeh + delcafe

  ;these elements seem to show no net enhancement at low Z
  res.cfe = cfe-tfeh
  res.nfe = nfe-tfeh
  res.crfe = crfe-tfeh
  res.nife = nife-tfeh
  res.nafe = nafe-tfeh

  ;these have enhancements that I have not yet quantified
  res.bafe = bafe-tfeh
  res.eufe = eufe-tfeh
  res.srfe = srfe-tfeh
  res.cufe = cufe-tfeh
  res.cofe = cofe-tfeh
  res.kfe  = kfe-tfeh
  res.vfe  = vfe-tfeh
  res.mnfe = mnfe-tfeh

  res.nhe    = nhe
  res.teff   = teff
  res.imf1   = imf1
  res.imf2   = imf2
  res.imf3   = imf3
  res.logage = logage
  res.logfy  = logfy
  res.fy_logage = fy_logage
  res.sigma  = sigma
  res.velz   = velz
  res.sigma2 = sigma2
  res.velz2  = velz2
  res.logm7g = logm7g
  res.hotteff = hotteff
  res.loghot = loghot
  res.logtrans = logtrans
  res.mlr    = m2lr
  res.mli    = m2li
  res.mlk    = m2lk
  res.mlr_mw = m2lmwr
  res.mli_mw = m2lmwi
  res.mlk_mw = m2lmwk
  FOR i=0,n_elements(logage)-1 DO $
     res[i].emline = [d1[i],d2[i],d3[i],d4[i],d5[i]]
  
  res.logemline_h    = res.emline[0]
  res.logemline_oiii = res.emline[1]
  res.logemline_sii  = res.emline[2]
  res.logemline_ni   = res.emline[3]
  res.logemline_nii  = res.emline[4]

  res.jitter = jitter
  res.logsky = logsky

  IF keyword_set(old) THEN BEGIN
     res.yfe = yfe-tfeh
     res.zrfe = zrfe-tfeh
     res.rbfe = rbfe-tfeh
  ENDIF

  res.lsig = alog10(res.sigma)
  res.ml   = res.mli/res.mli_mw

  IF strpos(file,'errp') EQ -1 THEN BEGIN
     ;mass-weighted age
     res.lage = (1-10^res.logfy)*10^res.logage + 10^res.fy_logage*10^res.logfy
  ENDIF ELSE res.lage = -99.

  IF strpos(file,'simple') NE -1 THEN BEGIN
     ;in simple mode, we only have one component
     res.lage = 10^res.logage
  ENDIF

  ;split the chain into separate walkers
  IF keyword_set(nwalker) THEN BEGIN
     tres = replicate(res[0],nwalker,n_elements(res)/nwalker)
     FOR i=0,nwalker-1 DO BEGIN
        FOR j=0,n_elements(res)/nwalker-1 DO $
           tres[i,j] = res[j*nwalker+i]
     ENDFOR
     res = tres
  ENDIF

  RETURN,res

END

;----------------------------------------------------------------------;
;----------------------------------------------------------------------;

FUNCTION READ_ALF, file, old=old, nwalker=nwalker

  sdir = getenv('SPECFIT_HOME')
  IF sdir EQ '' THEN BEGIN
     print,'READ_ALF ERROR: SPECFIT_HOME environment '+$
           'variable not set, returning...'
     RETURN,0
  ENDIF

  IF n_elements(file) EQ 1 THEN BEGIN
     ff = findfile(sdir+'/results/'+file,count=ct)
     IF ct EQ 0 THEN print,'READ_ALF ERROR: no files found'
  ENDIF ELSE BEGIN
     ct = n_elements(file)
     ff = file
  ENDELSE

  FOR i=0,ct-1 DO BEGIN
     tf  = strsplit(ff[i],'/',/extr)
     tf  = tf[n_elements(tf)-1]
     one = read_alf_one(tf,old=old, nwalker=nwalker)
     all = (i EQ 0) ? one : [all,one]
  ENDFOR

  RETURN,all

END

