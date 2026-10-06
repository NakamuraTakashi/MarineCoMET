
!!!=== Copyright (c) 2017-2026 Takashi NAKAMURA  =====
!!!  edited by Masa Muto 2023

!--------------------------------------------------------------------------------
!
!              Output module
!
!--------------------------------------------------------------------------------

#include "cppdefs.h"

MODULE mod_output

contains

! **********************************************************************
!  Open files
! **********************************************************************
  SUBROUTINE files_open(OUTFILE_prefix)
    USE mod_marine_comet_param
  
    implicit none

    integer :: i
    character(len=*), intent( in) :: OUTFILE_prefix
    character(2) :: NUM
  
    open(10,file=trim(OUTFILE_prefix)//'-env_his.csv')
#if defined CORAL_TESTMODE
    do i=1,Ncl
      write (NUM, "(I2.2)") i
      open(10+i,file=trim(OUTFILE_prefix)//'-crl'//NUM//'_his.csv')
      open(20+i,file=trim(OUTFILE_prefix)//'-crl'//NUM//'_ave.csv')
# if defined CORAL_ZOOXANTHELLAE
      open(30+i,file=trim(OUTFILE_prefix)//'-zoo'//NUM//'_his.csv')
      open(40+i,file=trim(OUTFILE_prefix)//'-zphot'//NUM//'_his.csv')
# endif
    enddo
#endif
#if defined ECOSYS_TESTMODE
    open(40,file=trim(OUTFILE_prefix)//'-ecosys_his.csv')
#endif
#if defined REEF_FLOW_TESTMODE
    open(45,file=trim(OUTFILE_prefix)//'-flow_his.csv')
#endif

!    open(46,file=trim(OUTFILE_prefix)//'-vprof.csv') !!!! for vertical profile output
       ! moved to write_env_vprof routine
#if defined SEDIMENT_TESTMODE
    open(50,file=trim(OUTFILE_prefix)//'-sedeco_depth.csv',status='replace')!!!!!!!!!for debug
!    open(51,file='output/sedeco_his.csv') ! moved to write_sedeco_his_data routine
!    open(52,file='output/sedeco_dia.csv') ! moved to write_sedeco_dia_data routine
    open(53,file=trim(OUTFILE_prefix)//'-sedeco_calcheck0.csv',status='replace')!!!!!!!!!for debug
    open(54,file=trim(OUTFILE_prefix)//'-sedeco_calcheck1.csv',status='replace')!!!!!!!!!for debug
    open(55,file=trim(OUTFILE_prefix)//'-sedeco_flux_DO.csv',status='replace')!!!!!!!!!for debug
#endif
#if defined SEAGRASS_TESTMODE
    open(60,file=trim(OUTFILE_prefix)//'-sg_his.csv',status='replace')!!!!!!!!!for debug
#endif
#if defined FOODWEB_TESTMODE
    open(70,file=trim(OUTFILE_prefix)//'-foodweb_calcheck_Phy1.csv',status='replace')!!!!!!!!!for debug
    open(71,file=trim(OUTFILE_prefix)//'-foodweb_calcheck_Phy2.csv',status='replace')!!!!!!!!!for debug
    open(72,file=trim(OUTFILE_prefix)//'-foodweb_calcheck_Phy3.csv',status='replace')!!!!!!!!!for debug
    open(73,file=trim(OUTFILE_prefix)//'-foodweb_calcheck_Phy4.csv',status='replace')!!!!!!!!!for debug
#endif
#if defined BIVALVE_TESTMODE
    do i=1,Nbv
      write (NUM, "(I2.2)") i
      open(80+i,file=trim(OUTFILE_prefix)//'-bivalve'//NUM//'.csv',status='replace')!!!!!!!!!for debug
    enddo
#endif

    RETURN

END SUBROUTINE files_open

! **********************************************************************
!  Close files
! **********************************************************************
  SUBROUTINE files_close
  
    implicit none
    
    close(10)
#if defined CORAL_TESTMODE
    close(11)
    close(12)
    close(21)
    close(22)
# if defined CORAL_ZOOXANTHELLAE
    close(31)
    close(32)
    close(41)
    close(42)
# endif
#endif
#if defined ECOSYS_TESTMODE
    close(40)
#endif
#if defined REEF_FLOW_TESTMODE
    close(45)
#endif
#if defined SEDIMENT_TESTMODE
    close(50)
!    close(51)
!    close(52)
    close(53)
    close(54)
    close(55)
#endif
#if defined SEAGRASS_TESTMODE
    close(60)
#endif
#if defined FOODWEB_TESTMODE
    close(70)
    close(71)
    close(72)
    close(73)
#endif
#if defined BIVALVE_TESTMODE
    close(80)
!    close(81)
!    close(82)
!    close(83)
!    close(84)
#endif

    RETURN

END SUBROUTINE files_close

! **********************************************************************
!  Write lavel of environmental data
! **********************************************************************

  SUBROUTINE write_env_lavel(fid)
  
    USE mod_param
    
    implicit none
    
    integer, intent(in) :: fid
    
    write(fid,'(*(g0:,", "))') 'time', 'PFDsurf'  &
        ,'Temp','Salt','DO','TA'   &
#if defined CLUMPED_ISOTOPE 
        ,'DIC','DIC_13C','DIC_47D'    &
#elif defined CARBON_ISOTOPE  || defined CARBON_TRACE
        ,'DIC','DIC_13C'              &
#else
        ,'DIC'                        &
#endif
#if defined NITROGEN_ISOTOPE  || defined NITROGEN_TRACE
        ,'NO3','NO3_15N'  &
        ,'NH4','NH4_15N'  &
#else
        ,'NO3'            &
        ,'NH4'            &
#endif
#if defined PHOSPHOROUS_TRACE
        ,'PO4','PO4_P1'   &
#else
        ,'PO4'            &
#endif
#if defined CLUMPED_ISOTOPE 
        ,'LDOC','LDOC_13C','LDOC_47D' &
        ,'RDOC','RDOC_13C','RDOC_47D' &
        ,'LPOC','LPOC_13C','LPOC_47D' &
        ,'RPOC','RPOC_13C','RPOC_47D' &
        ,'CPOC','CPOC_13C','CPOC_47D' &
#elif defined CARBON_ISOTOPE || defined CARBON_TRACE
        ,'LDOC','LDOC_13C' &
        ,'RDOC','RDOC_13C' &
        ,'LPOC','LPOC_13C' &
        ,'RPOC','RPOC_13C' &
        ,'CPOC','CPOC_13C' &
#else
        ,'LDOC'            &
        ,'RDOC'            &
        ,'LPOC'            &
        ,'RPOC'            &
        ,'CPOC'            &
#endif
#if defined NITROGEN_ISOTOPE  || defined NITROGEN_TRACE
        ,'LDON','LDON_15N' &
        ,'RDON','RDON_15N' &
        ,'LPON','LPON_15N' &
        ,'RPON','RPON_15N' &
        ,'CPON','CPON_15N' &
#else
        ,'LDON'            &
        ,'RDON'            &
        ,'LPON'            &
        ,'RPON'            &
        ,'CPON'            &
#endif
#if defined PHOSPHOROUS_TRACE
        ,'LDOP','LDOP_P1'  &
        ,'RDOP','RDOP_P1'  &
        ,'LPOP','LPOP_P1'  &
        ,'RPOP','RPOP_P1'  &
        ,'CPOP','CPOP_P1'  &
#else
        ,'LDOP'            &
        ,'RDOP'            &
        ,'LPOP'            &
        ,'RPOP'            &
        ,'CPOP'            &
#endif
#if defined CLUMPED_ISOTOPE 
        ,'PhyC1','PhyC1_13C','PhyC1_47D' &
        ,'PhyC2','PhyC2_13C','PhyC2_47D' &
        ,'PhyC3','PhyC3_13C','PhyC3_47D' &
        ,'PhyC4','PhyC4_13C','PhyC4_47D' &
        ,'ZooC1','ZooC1_13C','ZooC1_47D' &
#elif defined CARBON_ISOTOPE || defined CARBON_TRACE
        ,'PhyC1','PhyC1_13C' &
        ,'PhyC2','PhyC2_13C' &
        ,'PhyC3','PhyC3_13C' &
        ,'PhyC4','PhyC4_13C' &
        ,'ZooC1','ZooC1_13C' &
#else
        ,'PhyC1'             &
        ,'PhyC2'             &
        ,'PhyC3'             &
        ,'PhyC4'             &
        ,'ZooC1'             &
#endif
#if defined NITROGEN_ISOTOPE  || defined NITROGEN_TRACE
        ,'PhyN1','PhyN1_15N' &
        ,'PhyN2','PhyN2_15N' &
        ,'PhyN3','PhyN3_15N' &
        ,'PhyN4','PhyN4_15N' &
        ,'ZooN1','ZooN1_15N' &
#else
        ,'PhyN1'             &
        ,'PhyN2'             &
        ,'PhyN3'             &
        ,'PhyN4'             &
        ,'ZooN1'             &
#endif
#if defined PHOSPHOROUS_TRACE
        ,'PhyP1','PhyP1_P1' &
        ,'PhyP2','PhyP2_P1' &
        ,'PhyP3','PhyP3_P1' &
        ,'PhyP4','PhyP4_P1' &
        ,'ZooP1','ZooP1_P1' &
#else
        ,'PhyP1'             &
        ,'PhyP2'             &
        ,'PhyP3'             &
        ,'PhyP4'             &
        ,'ZooP1'             &
#endif
#if defined CLUMPED_ISOTOPE 
        ,'PIC1','PIC1_13C','PIC1_47D' &
        ,'PIC2','PIC2_13C','PIC2_47D' &
#elif defined CARBON_ISOTOPE || defined CARBON_TRACE
        ,'PIC1','PIC1_13C' &
        ,'PIC2','PIC2_13C' &
#else
        ,'PIC1'             &
        ,'PIC2'             &
#endif
        ,'PhyC_Total'       &
#if defined CARBON_ISOTOPE
        ,'d13C_DIC'                                                        &
#endif
#if defined COT_STARFISH
        ,'COT','COTl'                                                      &
#endif
#if defined REEF_FLOW
        ,'Q_rc', 'Q_ch','el_reef'                                          &
#endif
        ,'dz', 'el'
      

    RETURN

  END SUBROUTINE write_env_lavel

! **********************************************************************
!  Write vertical profile of environmental data
! **********************************************************************

  SUBROUTINE write_env_vprof(OUT_FILE, date, N)

    USE mod_param
    USE mod_geochem, ONLY: d13C_fromR13C
#if defined REEF_FLOW
    USE mod_reef_flow
#endif

    implicit none
    
    character(len=*), intent( in) :: OUT_FILE
    real(8), intent( in) :: date
    integer, intent(in) :: N

    integer,parameter :: fid = 45

    real(8) :: depth_r
#if defined CARBON_ISOTOPE
    real(8) :: d13C_DIC
#endif
    integer :: i,j,k,nstp

    i=1
    j=1
!    k=1
    nstp=1
    
    open(fid,file=OUT_FILE)
    write(fid,'(*(g0:,", "))') 'Time=', date

    write(fid,'(*(g0:,", "))') 'Depth', 'PFDsurf'  &
        ,'Temp','Salt','DO','TA'   &
#if defined CLUMPED_ISOTOPE 
        ,'DIC','DIC_13C','DIC_47D'    &
#elif defined CARBON_ISOTOPE  || defined CARBON_TRACE
        ,'DIC','DIC_13C'              &
#else
        ,'DIC'                        &
#endif
#if defined NITROGEN_ISOTOPE  || defined NITROGEN_TRACE
        ,'NO3','NO3_15N'  &
        ,'NH4','NH4_15N'  &
#else
        ,'NO3'            &
        ,'NH4'            &
#endif
#if defined PHOSPHOROUS_TRACE
        ,'PO4','PO4_P1'   &
#else
        ,'PO4'            &
#endif
#if defined CLUMPED_ISOTOPE 
        ,'LDOC','LDOC_13C','LDOC_47D' &
        ,'RDOC','RDOC_13C','RDOC_47D' &
        ,'LPOC','LPOC_13C','LPOC_47D' &
        ,'RPOC','RPOC_13C','RPOC_47D' &
        ,'CPOC','CPOC_13C','CPOC_47D' &
#elif defined CARBON_ISOTOPE || defined CARBON_TRACE
        ,'LDOC','LDOC_13C' &
        ,'RDOC','RDOC_13C' &
        ,'LPOC','LPOC_13C' &
        ,'RPOC','RPOC_13C' &
        ,'CPOC','CPOC_13C' &
#else
        ,'LDOC'            &
        ,'RDOC'            &
        ,'LPOC'            &
        ,'RPOC'            &
        ,'CPOC'            &
#endif
#if defined NITROGEN_ISOTOPE  || defined NITROGEN_TRACE
        ,'LDON','LDON_15N' &
        ,'RDON','RDON_15N' &
        ,'LPON','LPON_15N' &
        ,'RPON','RPON_15N' &
        ,'CPON','CPON_15N' &
#else
        ,'LDON'            &
        ,'RDON'            &
        ,'LPON'            &
        ,'RPON'            &
        ,'CPON'            &
#endif
#if defined PHOSPHOROUS_TRACE
        ,'LDOP','LDOP_P1'  &
        ,'RDOP','RDOP_P1'  &
        ,'LPOP','LPOP_P1'  &
        ,'RPOP','RPOP_P1'  &
        ,'CPOP','CPOP_P1'  &
#else
        ,'LDOP'            &
        ,'RDOP'            &
        ,'LPOP'            &
        ,'RPOP'            &
        ,'CPOP'            &
#endif
#if defined CLUMPED_ISOTOPE 
        ,'PhyC1','PhyC1_13C','PhyC1_47D' &
        ,'PhyC2','PhyC2_13C','PhyC2_47D' &
        ,'PhyC3','PhyC3_13C','PhyC3_47D' &
        ,'PhyC4','PhyC4_13C','PhyC4_47D' &
        ,'ZooC1','ZooC1_13C','ZooC1_47D' &
#elif defined CARBON_ISOTOPE || defined CARBON_TRACE
        ,'PhyC1','PhyC1_13C' &
        ,'PhyC2','PhyC2_13C' &
        ,'PhyC3','PhyC3_13C' &
        ,'PhyC4','PhyC4_13C' &
        ,'ZooC1','ZooC1_13C' &
#else
        ,'PhyC1'             &
        ,'PhyC2'             &
        ,'PhyC3'             &
        ,'PhyC4'             &
        ,'ZooC1'             &
#endif
#if defined NITROGEN_ISOTOPE  || defined NITROGEN_TRACE
        ,'PhyN1','PhyN1_15N' &
        ,'PhyN2','PhyN2_15N' &
        ,'PhyN3','PhyN3_15N' &
        ,'PhyN4','PhyN4_15N' &
        ,'ZooN1','ZooN1_15N' &
#else
        ,'PhyN1'             &
        ,'PhyN2'             &
        ,'PhyN3'             &
        ,'PhyN4'             &
        ,'ZooN1'             &
#endif
#if defined PHOSPHOROUS_TRACE
        ,'PhyP1','PhyP1_P1' &
        ,'PhyP2','PhyP2_P1' &
        ,'PhyP3','PhyP3_P1' &
        ,'PhyP4','PhyP4_P1' &
        ,'ZooP1','ZooP1_P1' &
#else
        ,'PhyP1'             &
        ,'PhyP2'             &
        ,'PhyP3'             &
        ,'PhyP4'             &
        ,'ZooP1'             &
#endif
#if defined CLUMPED_ISOTOPE 
        ,'PIC1','PIC1_13C','PIC1_47D' &
        ,'PIC2','PIC2_13C','PIC2_47D' &
#elif defined CARBON_ISOTOPE || defined CARBON_TRACE
        ,'PIC1','PIC1_13C' &
        ,'PIC2','PIC2_13C' &
#else
        ,'PIC1'             &
        ,'PIC2'             &
#endif
        ,'PhyC_Total'       &
#if defined CARBON_ISOTOPE
        ,'d13C_DIC'                                                        &
#endif
#if defined COT_STARFISH
        ,'COT','COTl'                                                      &
#endif
#if defined REEF_FLOW
        ,'Q_rc', 'Q_ch','el_reef'                                          &
#endif
        ,'dz', 'el'

!-----------------------------------------------------------------------
#if defined CARBON_ISOTOPE
    d13C_DIC=d13C_fromR13C(t(i,j,k,nstp,iTIC(iC13))/t(i,j,k,nstp,iTIC(iCt)))
#endif

!    depth = 0.0d0
    Do k=N,1,-1

      if (k==N) then
        depth_r = dz(i,j,k)*0.5d0
      else
        depth_r = depth_r + dz(i,j,k)
      endif

      write(fid,'(*(g0:,", "))') depth_r, PFDsurf           &
           , t(i,j,k,nstp,iTemp), t(i,j,k,nstp,iSalt)  &
           , t(i,j,k,nstp,iOxyg), t(i,j,k,nstp,iTAlk)  &
           , t(i,j,k,nstp,iTIC(1):iTIC(N_Csp))          &
           , t(i,j,k,nstp,iNO3(1):iNO3(N_Nsp))          &
           , t(i,j,k,nstp,iNH4(1):iNH4(N_Nsp))          &
           , t(i,j,k,nstp,iPO4(1):iPO4(N_Psp))          &
           , t(i,j,k,nstp,iDOC(1,1):iDOC(N_Csp,Ndom))   &
           , t(i,j,k,nstp,iPOC(1,1):iPOC(N_Csp,Npom))   &
           , t(i,j,k,nstp,iDON(1,1):iDON(N_Nsp,Ndom))   &
           , t(i,j,k,nstp,iPON(1,1):iPON(N_Nsp,Npom))   &
           , t(i,j,k,nstp,iDOP(1,1):iDOP(N_Psp,Ndom))   &
           , t(i,j,k,nstp,iPOP(1,1):iPOP(N_Psp,Npom))   &
           , t(i,j,k,nstp,iPhyC(1,1):iPhyC(N_Csp,Nphy)) &
           , t(i,j,k,nstp,iZooC(1,1):iZooC(N_Csp,Nzoo)) &
           , t(i,j,k,nstp,iPhyN(1,1):iPhyN(N_Nsp,Nphy)) &
           , t(i,j,k,nstp,iZooN(1,1):iZooN(N_Nsp,Nzoo)) &
           , t(i,j,k,nstp,iPhyP(1,1):iPhyP(N_Psp,Nphy)) &
           , t(i,j,k,nstp,iZooP(1,1):iZooP(N_Psp,Nzoo)) &
           , t(i,j,k,nstp,iPIC(1,1):iPIC(N_Csp,Npim))   &
           , t(i,j,k,nstp,iPhyC(iCt,1))+t(i,j,k,nstp,iPhyC(iCt,2))  &
            +t(i,j,k,nstp,iPhyC(iCt,3))+t(i,j,k,nstp,iPhyC(iCt,4))  &
#if defined CARBON_ISOTOPE
           , d13C_DIC                                                      &
#endif
#if defined COT_STARFISH
           , t(i,j,k,nstp,iCOTe), t(i,j,k,nstp,iCOTl)                      &
#endif
#if defined REEF_FLOW
           , REEF(1)%Qrc(1,1), REEF(1)%Qch(1,1), REEF(1)%el (1,1)          &
#endif
           , dz(i,j,k), tide

      END DO

      close(fid)

    RETURN

  END SUBROUTINE write_env_vprof
! **********************************************************************
!  Write vertical profile of bivalve data
! **********************************************************************
#if defined BIVALVE_TESTMODE
  SUBROUTINE write_bivalve_vprof(OUT_FILE, date, N)
  
    USE mod_param
    Use mod_bivalve
    
    implicit none
    
    character(len=*), intent( in) :: OUT_FILE
    real(8), intent( in) :: date
    integer, intent(in) :: N

    integer,parameter :: fid = 85

    real(8) :: depth_r
    integer :: i,j,k,nstp
    integer :: ng

    ng=1

    i=1
    j=1
!    k=1
    nstp=1
    
    open(fid,file=OUT_FILE)
    write(fid,'(*(g0:,", "))') 'Time=', date

    write(fid,'(*(g0:,", "))') 'Depth'  &
        , 'dens','L','V','Ww','Wd','Wt' &
        , 'QCe','QCv','QCr','QCh'       &
        , 'QNe','QNv','QNr','QNh'       &
        , 'QPe','QPv','QPr','QPh'       &
        , 'CaCO3','Dead_CaCO3'

!-----------------------------------------------------------------------

!    depth = 0.0d0
    Do k=N,1,-1

      if (k==N) then
        depth_r = dz(i,j,k)*0.5d0
      else
        depth_r = depth_r + dz(i,j,k)
      endif

      write(fid,'(*(g0:,", "))') depth_r           &
       , BVLV(ng)%dens(1,k,i,j)    &
       , BVLV(ng)%L (1,k,i,j)      &
       , BVLV(ng)%V (1,k,i,j)      &
       , BVLV(ng)%Ww(1,k,i,j)      &
       , BVLV(ng)%Wd(1,k,i,j)      &
       , BVLV(ng)%Wt(1,k,i,j)      &
       , BVLV(ng)%QCe(:,1,k,i,j)   &
       , BVLV(ng)%QCv(:,1,k,i,j)   &
       , BVLV(ng)%QCr(:,1,k,i,j)   &
       , BVLV(ng)%QCh(:,1,k,i,j)   &
       , BVLV(ng)%QNe(:,1,k,i,j)   &
       , BVLV(ng)%QNv(:,1,k,i,j)   &
       , BVLV(ng)%QNr(:,1,k,i,j)   &
       , BVLV(ng)%QNh(:,1,k,i,j)   &
       , BVLV(ng)%QPe(:,1,k,i,j)   &
       , BVLV(ng)%QPv(:,1,k,i,j)   &
       , BVLV(ng)%QPr(:,1,k,i,j)   &
       , BVLV(ng)%QPh(:,1,k,i,j)   &
       , BVLV(ng)%CaCO3(:,1,k,i,j) &
       , BVLV(ng)%Dead_CaCO3(:,1,k,i,j)

      END DO

      close(fid)

    RETURN

  END SUBROUTINE write_bivalve_vprof
#endif


! **********************************************************************
!  Write lavel of reef_flow data
! **********************************************************************

  SUBROUTINE write_flow_lavel(fid)
  
    USE mod_param
    
    implicit none
    
    integer, intent(in) :: fid
    
    write(fid,'(*(g0:,", "))') 'time'   &
    , 'Hs_o', 'Tp', 'd_o', 'd_i'        & 
    , 'el_o', 'reef_el'                 &
    , 'Qrc', 'Qch'

    RETURN

  END SUBROUTINE write_flow_lavel

! **********************************************************************
!  Write timeseries environmental data
! **********************************************************************

  SUBROUTINE write_env_data(fid)
  
    USE mod_param
#ifdef CORAL_POLYP
    USE mod_coral
#endif
#ifdef SEAGRASS
    USE mod_seagrass
#endif
#ifdef MACROALGAE
    USE mod_macroalgae
#endif
#ifdef SEDIMENT_ECOSYS
    USE mod_sedecosys
#endif
#if defined CARBON_ISOTOPE
    USE mod_geochem
#endif
#if defined REEF_FLOW
      USE mod_reef_flow
#endif
      
    implicit none
      
    integer, intent(in) :: fid
#if defined CARBON_ISOTOPE
    real(8) :: R13C
    real(8) :: d13C_DIC
#endif
    integer :: i,j,k,nstp

    i=1
    j=1
    k=1
!    k=20
    nstp=1

#if defined CARBON_ISOTOPE
    d13C_DIC=delta_from_Ci_Ct( t(i,j,k,nstp,iTIC(iC13)), t(i,j,k,nstp,iTIC(iCt)), R13C_VPDB )
#endif
        
    write(fid,'(*(g0:,", "))') time, PFDsurf           &
           , t(i,j,k,nstp,iTemp), t(i,j,k,nstp,iSalt)  &
           , t(i,j,k,nstp,iOxyg), t(i,j,k,nstp,iTAlk)  &
           , t(i,j,k,nstp,iTIC(1):iTIC(N_Csp))          &
           , t(i,j,k,nstp,iNO3(1):iNO3(N_Nsp))          &
           , t(i,j,k,nstp,iNH4(1):iNH4(N_Nsp))          &
           , t(i,j,k,nstp,iPO4(1):iPO4(N_Psp))          &
           , t(i,j,k,nstp,iDOC(1,1):iDOC(N_Csp,Ndom))   &
           , t(i,j,k,nstp,iPOC(1,1):iPOC(N_Csp,Npom))   &
           , t(i,j,k,nstp,iDON(1,1):iDON(N_Nsp,Ndom))   &
           , t(i,j,k,nstp,iPON(1,1):iPON(N_Nsp,Npom))   &
           , t(i,j,k,nstp,iDOP(1,1):iDOP(N_Psp,Ndom))   &
           , t(i,j,k,nstp,iPOP(1,1):iPOP(N_Psp,Npom))   &
           , t(i,j,k,nstp,iPhyC(1,1):iPhyC(N_Csp,Nphy)) &
           , t(i,j,k,nstp,iZooC(1,1):iZooC(N_Csp,Nzoo)) &
           , t(i,j,k,nstp,iPhyN(1,1):iPhyN(N_Nsp,Nphy)) &
           , t(i,j,k,nstp,iZooN(1,1):iZooN(N_Nsp,Nzoo)) &
           , t(i,j,k,nstp,iPhyP(1,1):iPhyP(N_Psp,Nphy)) &
           , t(i,j,k,nstp,iZooP(1,1):iZooP(N_Psp,Nzoo)) &
           , t(i,j,k,nstp,iPIC(1,1):iPIC(N_Csp,Npim))   &
           , t(i,j,k,nstp,iPhyC(iCt,1))+t(i,j,k,nstp,iPhyC(iCt,2))  &
            +t(i,j,k,nstp,iPhyC(iCt,3))+t(i,j,k,nstp,iPhyC(iCt,4))  &
#if defined CARBON_ISOTOPE
           , d13C_DIC                                                      &
#endif
#if defined COT_STARFISH
           , t(i,j,k,nstp,iCOTe), t(i,j,k,nstp,iCOTl)                      &
#endif
#if defined REEF_FLOW
           , REEF(1)%Qrc(1,1), REEF(1)%Qch(1,1), REEF(1)%el (1,1)          &
#endif
           , dz(i,j,k), tide 


    RETURN

  END SUBROUTINE write_env_data
    
#if defined SEDIMENT_TESTMODE
! **********************************************************************
!  Write lavel of sedecosys
! **********************************************************************
  SUBROUTINE write_sedeco_lavel(fid)
  
    ! USE mod_param
    
    implicit none
    
    integer, intent(in) :: fid
    
    ! write(fid,'(*(g0:,", "))') 'time', 'Temp', 'Salt' , 'O2'                         &
    !     ,'Dw_O2','Ds_O2','Fd_O2','Fb_O2','Fc_O2','FT_O2','v1','R_O2'

    ! write(fid,'(*(g0:,", "))') 'time', 'Temp', 'Salt' , 'DOCf'                         &
    !     ,'Dw_DOCf','Ds_DOCf','Fd_DOCf','Fb_DOCf','Fc_DOCf','FT_DOCf','vdomf','R_DOCf'

    write(fid,'(*(g0:,", "))') 'time', 'Temp', 'vOM','v1', 'v2', 'v3', 'v4', 'v5'

    RETURN

  END SUBROUTINE write_sedeco_lavel
! **********************************************************************
!  Write last sediment data
! **********************************************************************

  SUBROUTINE write_sedeco_his_data(OUT_FILE, date)
  
    USE mod_marine_comet_param
    USE mod_geochem, ONLY: d13C_fromR13C
    USE mod_sedecosys
      
    implicit none
      
    character(len=*), intent( in) :: OUT_FILE
    real(8), intent( in) :: date

    integer,parameter :: fid = 51

    real(8) :: zr(0:Nsed)
    real(8) :: Ratio
    integer :: i,j,k,ng

    i=1
    j=1
    ng=1

    zr(0) = -1.0d0
    zr(1:Nsed) = SEDECO(1)%zr(:)

    open(51,file=OUT_FILE)
    write(fid,'(*(g0:,", "))') 'Time=', date

    write(fid,'(*(g0:,", "))') 'zr'   &
        , 'Tmp'                       &
        , 'Sal'                       & 
        , 'O2 '                       & 
        , 'TA '                       & 
# if defined CLUMPED_ISOTOPE 
        ,'DIC','DIC_13C','DIC_47D'    &
# elif defined CARBON_ISOTOPE  || defined CARBON_TRACE
        ,'DIC','DIC_13C'              &
# else
        ,'DIC'                        &
# endif
# if defined NITROGEN_ISOTOPE  || defined NITROGEN_TRACE
        ,'NO3','NO3_15N'  &
        ,'NH4','NH4_15N'  &
# else
        ,'NO3'            &
        ,'NH4'            &
# endif
# if defined PHOSPHOROUS_TRACE
        ,'PO4','PO4_P1'   &
# else
        ,'PO4'            &
# endif
# if defined CLUMPED_ISOTOPE 
        ,'LDOC','LDOC_13C','LDOC_47D' &
        ,'RDOC','RDOC_13C','RDOC_47D' &
        ,'LPOC','LPOC_13C','LPOC_47D' &
        ,'RPOC','RPOC_13C','RPOC_47D' &
        ,'CPOC','CPOC_13C','CPOC_47D' &
# elif defined CARBON_ISOTOPE || defined CARBON_TRACE
        ,'LDOC','LDOC_13C' &
        ,'RDOC','RDOC_13C' &
        ,'LPOC','LPOC_13C' &
        ,'RPOC','RPOC_13C' &
        ,'CPOC','CPOC_13C' &
# else
        ,'LDOC'            &
        ,'RDOC'            &
        ,'LPOC'            &
        ,'RPOC'            &
        ,'CPOC'            &
# endif
# if defined NITROGEN_ISOTOPE  || defined NITROGEN_TRACE
        ,'LDON','LDON_15N' &
        ,'RDON','RDON_15N' &
        ,'LPON','LPON_15N' &
        ,'RPON','RPON_15N' &
        ,'CPON','CPON_15N' &
# else
        ,'LDON'            &
        ,'RDON'            &
        ,'LPON'            &
        ,'RPON'            &
        ,'CPON'            &
# endif
# if defined PHOSPHOROUS_TRACE
        ,'LDOP','LDOP_P1'  &
        ,'RDOP','RDOP_P1'  &
        ,'LPOP','LPOP_P1'  &
        ,'RPOP','RPOP_P1'  &
        ,'CPOP','CPOP_P1'  &
# else
        ,'LDOP'            &
        ,'RDOP'            &
        ,'LPOP'            &
        ,'RPOP'            &
        ,'CPOP'            &
# endif
# if defined CLUMPED_ISOTOPE 
        ,'PIC','PIC_13C','PIC_47D'    &
# elif defined CARBON_ISOTOPE  || defined CARBON_TRACE
        ,'PIC','PIC_13C'              &
# else
        ,'PIC'                        &
# endif
        , 'Mn2 '           &
        , 'MnO2'           &
        , 'Fe2 '           &
# if defined SULFUR_ISOTOPE || defined SULFUR_TRACE
        ,'FeS2','FeS2_34S' &
# else
        ,'FeS2'            &
# endif
        , 'FeOOH'          &
# if defined PHOSPHOROUS_TRACE
        ,'FeOOH_PO4','FeOOH_PO4_P1'   &
# else
        ,'FeOOH_PO4'                  &
# endif
# if defined SULFUR_ISOTOPE || defined SULFUR_TRACE
        , 'H2S', 'H2S_34S' &
        , 'SO4', 'SO4_34S' &
        , 'S0 ', 'S0_34S'     
# else
        , 'H2S'            &
        , 'SO4'            &
        , 'S0 '   
# endif
    
    DO k=0,Nsed
      write(fid,'(*(g0:,", "))') zr(k)  &
        , SEDECO(ng)%Tmp(k,i,j)         &
        , SEDECO(ng)%Sal(k,i,j)         & 
        , SEDECO(ng)%O2 (k,i,j)         & 
        , SEDECO(ng)%TA (k,i,j)         & 
        , SEDECO(ng)%DIC(:,k,i,j)       & 
        , SEDECO(ng)%NO3(:,k,i,j)       &
        , SEDECO(ng)%NH4(:,k,i,j)       &
        , SEDECO(ng)%PO4(:,k,i,j)       &
        , SEDECO(ng)%DOC(:,:,k,i,j)     &
        , SEDECO(ng)%POC(:,:,k,i,j)     &
        , SEDECO(ng)%DON(:,:,k,i,j)     &
        , SEDECO(ng)%PON(:,:,k,i,j)     &
        , SEDECO(ng)%DOP(:,:,k,i,j)     &
        , SEDECO(ng)%POP(:,:,k,i,j)     &
        , SEDECO(ng)%PIC(:,k,i,j)       & 
        , SEDECO(ng)%Mn2 (k,i,j)        &
        , SEDECO(ng)%MnO2(k,i,j)        &
        , SEDECO(ng)%Fe2 (k,i,j)        &
        , SEDECO(ng)%FeS2(:,k,i,j)      &
        , SEDECO(ng)%FeOOH(k,i,j)       &
        , SEDECO(ng)%FeOOH_PO4(:,k,i,j) &
        , SEDECO(ng)%H2S(:,k,i,j)       &
        , SEDECO(ng)%SO4(:,k,i,j)       &
        , SEDECO(ng)%S0 (:,k,i,j)   
    END DO
    close(fid)
    
    RETURN

  END SUBROUTINE write_sedeco_his_data

  SUBROUTINE write_sedeco_dia_data(OUT_FILE, date)
  
    USE mod_marine_comet_param
    USE mod_geochem
    USE mod_sedecosys
     
    implicit none
      
    character(len=*), intent( in) :: OUT_FILE
    real(8), intent( in) :: date

    integer,parameter :: fid = 52

    real(8) :: zr(0:Nsed)
    real(8) :: pH, Warg, Wcal, CO3, T, S
    integer :: i,j,k,ng

    i=1
    j=1
    ng=1

    zr(0) = -1.0d0
    zr(1:Nsed) = SEDECO(1)%zr(:)

    open(fid,file=OUT_FILE)
    write(fid,'(*(g0:,", "))') 'Time=', date

    write(fid,'(*(g0:,", "))') 'zr'   &
# if defined CLUMPED_ISOTOPE 
        ,'d13C_DIC','D47_DIC'    &
# elif defined CARBON_ISOTOPE
        ,'d13C_DIC'              &
# endif
# if defined NITROGEN_ISOTOPE
        ,'d15N_NO3'  &
        ,'d15N_NH4'  &
# endif
# if defined CLUMPED_ISOTOPE 
        ,'d13C_LDOC','D47_LDOC' &
        ,'d13C_RDOC','D47_RDOC' &
        ,'d13C_LPOC','D47_LPOC' &
        ,'d13C_RPOC','D47_RPOC' &
        ,'d13C_CPOC','D47_CPOC' &
# elif defined CARBON_ISOTOPE
        ,'d13C_LDOC' &
        ,'d13C_RDOC' &
        ,'d13C_LPOC' &
        ,'d13C_RPOC' &
        ,'d13C_CPOC' &
# endif
# if defined NITROGEN_ISOTOPE
        ,'d15N_LDON' &
        ,'d15N_RDON' &
        ,'d15N_LPON' &
        ,'d15N_RPON' &
        ,'d15N_CPON' &
# endif
# if defined CLUMPED_ISOTOPE 
        ,'d13C_PIC','D47_PIC'    &
# elif defined CARBON_ISOTOPE
        ,'d13C_PIC'              &
# endif
# if defined SULFUR_ISOTOPE
        ,'d34S_FeS2' &
        ,'d34S_H2S'  &
        ,'d34S_SO4'  &
        ,'d34S_S0 '  &    
# endif
        ,'pH', 'Warg', 'Wcal'
    
    DO k=0,Nsed
      T = SEDECO(ng)%Tmp(k,i,j)+273.15d0
      S = SEDECO(ng)%Sal(k,i,j)
    
      pH = pH_fromATCT(SEDECO(ng)%TA (k,i,j)     &
                      ,SEDECO(ng)%DIC(iCt,k,i,j) &
                      ,T ,S  )
      CO3 = cCO3_fromCTpH(SEDECO(ng)%DIC(iCt,k,i,j), pH, T, S)
      Warg = Warg_fromcCO3(CO3, T, S)
      Wcal = Wcal_fromcCO3(CO3, T, S)
    
      write(fid,'(*(g0:,", "))') zr(k)  &
# if defined CLUMPED_ISOTOPE 
        ,delta_from_Ci_Ct(SEDECO(ng)%DIC(iC13,k,i,j),SEDECO(ng)%DIC(iCt,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%DIC(iD47,k,i,j),SEDECO(ng)%DIC(iCt,k,i,j),R13C_VPDB)   &
# elif defined CARBON_ISOTOPE
        ,delta_from_Ci_Ct(SEDECO(ng)%DIC(iC13,k,i,j),SEDECO(ng)%DIC(iCt,k,i,j),R13C_VPDB)   &
# endif
# if defined NITROGEN_ISOTOPE
        ,delta_from_Ci_Ct(SEDECO(ng)%NO3(iN15,k,i,j),SEDECO(ng)%NO3(iNt,k,i,j),R15N_AIR)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%NH4(iN15,k,i,j),SEDECO(ng)%NH4(iNt,k,i,j),R15N_AIR)   &
# endif
# if defined CLUMPED_ISOTOPE 
        ,delta_from_Ci_Ct(SEDECO(ng)%DOC(iC13,iLDOM,k,i,j),SEDECO(ng)%DOC(iCt,iLDOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%DOC(iD47,iLDOM,k,i,j),SEDECO(ng)%DOC(iCt,iLDOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%DOC(iC13,iRDOM,k,i,j),SEDECO(ng)%DOC(iCt,iRDOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%DOC(iD47,iRDOM,k,i,j),SEDECO(ng)%DOC(iCt,iRDOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%POC(iC13,iLPOM,k,i,j),SEDECO(ng)%POC(iCt,iLPOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%POC(iD47,iLPOM,k,i,j),SEDECO(ng)%POC(iCt,iLPOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%POC(iC13,iRPOM,k,i,j),SEDECO(ng)%POC(iCt,iRPOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%POC(iD47,iRPOM,k,i,j),SEDECO(ng)%POC(iCt,iRPOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%POC(iC13,iCPOM,k,i,j),SEDECO(ng)%POC(iCt,iCPOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%POC(iD47,iCPOM,k,i,j),SEDECO(ng)%POC(iCt,iCPOM,k,i,j),R13C_VPDB)   &
# elif defined CARBON_ISOTOPE
        ,delta_from_Ci_Ct(SEDECO(ng)%DOC(iC13,iLDOM,k,i,j),SEDECO(ng)%DOC(iCt,iLDOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%DOC(iC13,iRDOM,k,i,j),SEDECO(ng)%DOC(iCt,iRDOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%POC(iC13,iLPOM,k,i,j),SEDECO(ng)%POC(iCt,iLPOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%POC(iC13,iRPOM,k,i,j),SEDECO(ng)%POC(iCt,iRPOM,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%POC(iC13,iCPOM,k,i,j),SEDECO(ng)%POC(iCt,iCPOM,k,i,j),R13C_VPDB)   &
# endif
# if defined NITROGEN_ISOTOPE
        ,delta_from_Ci_Ct(SEDECO(ng)%DON(iN15,iLDOM,k,i,j),SEDECO(ng)%DON(iNt,iLDOM,k,i,j),R15C_AIR)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%DON(iN15,iRDOM,k,i,j),SEDECO(ng)%DON(iNt,iRDOM,k,i,j),R15C_AIR)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%PON(iN15,iLPOM,k,i,j),SEDECO(ng)%PON(iNt,iLPOM,k,i,j),R15C_AIR)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%PON(iN15,iRPOM,k,i,j),SEDECO(ng)%PON(iNt,iRPOM,k,i,j),R15C_AIR)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%PON(iN15,iCPOM,k,i,j),SEDECO(ng)%PON(iNt,iCPOM,k,i,j),R15C_AIR)   &
# endif
# if defined CLUMPED_ISOTOPE 
        ,delta_from_Ci_Ct(SEDECO(ng)%PIC(iC13,k,i,j),SEDECO(ng)%PIC(iCt,k,i,j),R13C_VPDB)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%PIC(iD47,k,i,j),SEDECO(ng)%PIC(iCt,k,i,j),R13C_VPDB)   &
# elif defined CARBON_ISOTOPE
        ,delta_from_Ci_Ct(SEDECO(ng)%PIC(iC13,k,i,j),SEDECO(ng)%PIC(iCt,k,i,j),R13C_VPDB)   &
# endif
# if defined SULFUR_ISOTOPE
        ,delta_from_Ci_Ct(SEDECO(ng)%FeS2(iS34,k,i,j),SEDECO(ng)%FeS2(iSt,k,i,j),R34S_VCDT)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%H2S (iS34,k,i,j),SEDECO(ng)%H2S (iSt,k,i,j),R34S_VCDT)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%SO4 (iS34,k,i,j),SEDECO(ng)%SO4 (iSt,k,i,j),R34S_VCDT)   &
        ,delta_from_Ci_Ct(SEDECO(ng)%S0  (iS34,k,i,j),SEDECO(ng)%S0  (iSt,k,i,j),R34S_VCDT)   &
# endif
        ,pH, Warg, Wcal
    END DO

    close(fid)

    RETURN

  END SUBROUTINE write_sedeco_dia_data
#endif

END MODULE mod_output

