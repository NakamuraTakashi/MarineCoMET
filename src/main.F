
!!!=== Copyright (c) 2012-2025 Takashi NAKAMURA  =====

#include "cppdefs.h"


PROGRAM main
! **********************************************************************
! *                                                                    *
! *   Test program of mod_marine_comet                                 *
! *                                                                    *
! **********************************************************************
!
  USE mod_marine_comet_param
  USE mod_param
  USE mod_marine_comet
#if defined USE_HEAT
  USE mod_heat
#endif
  USE mod_input
  USE mod_output
  USE mod_geochem
#if defined REEF_FLOW
  USE mod_reef_flow
#endif

  implicit none
  
  integer, parameter :: Ngrids = 1
  logical :: start_of_new_run = .true.
     
  integer :: i,j,k,id, ng, Nid, nstp, isp, m
  integer :: nheat
  
  integer :: ipcl =1       ! Step of the protocol for setting 5 (Incubation chamber condition simulated Nakamura & Nakamori (2009) experiments)
  integer :: inight = 1 ! Timer for setting 6
  integer :: iflag = 1 ! Timer for setting 6
  integer :: iclose = 0 ! Timer for setting 6
#if defined SAKAMAKI_ET_AL_2025
  real(8), parameter :: dx = 40.0d0  ! grid size in x-direction (m)
  real(8), parameter :: vel = 0.01d0 ! constant flow velocity (m s-1)
  real(8), parameter :: mgC2umolC = 1.0d3/12.0d0 ! conversion factor from mgC to umolC

#endif

  real(8), allocatable :: Tmp(:)               ! Temperature (oC)
  real(8), allocatable :: Sal(:)               ! Salinity (PSU)
  real(8), allocatable :: DOx(:)               ! Dissolved oxygen (umol L-1)
  real(8), allocatable :: TA (:)               ! Total alkalinity (TA: umol L-1)
  real(8), allocatable :: DIC(:,:)           ! Total dissolved inorganic carbon (DIC: umol kg-1)
  real(8), allocatable :: NO3(:,:)           ! NO3 (umol L-1)
  real(8), allocatable :: NH4(:,:)           ! NH4 (umol L-1)
  real(8), allocatable :: PO4(:,:)           ! PO4 (umol L-1)
  real(8), allocatable :: DOC(:,:,:)      ! Dissolved organic carbon (DOC: umol L-1)
  real(8), allocatable :: POC(:,:,:)      ! Particulate organic carbon (POC: umol L-1)
  real(8), allocatable :: DON(:,:,:)      ! Labile Dissolved organic nitrogen (DON: umol L-1)
  real(8), allocatable :: PON(:,:,:)      ! Particulate organic nitrogen (PON: umol L-1)
  real(8), allocatable :: DOP(:,:,:)      ! Labile Dissolved organic phosporius (DOP: umol L-1)
  real(8), allocatable :: POP(:,:,:)      ! Particulate organic phosporius (POP: umol L-1)
  real(8), allocatable :: PhyC(:,:,:)     ! phytoplankton C biomass (umol C L-1), dinoflagellate
  real(8), allocatable :: ZooC(:,:,:)     ! zooplankton C biomass (umol C L-1)
  real(8), allocatable :: PhyN(:,:,:)     ! phytoplankton N biomass (umol N L-1), dinoflagellate
  real(8), allocatable :: ZooN(:,:,:)     ! zooplankton N biomass (umol N L-1)
  real(8), allocatable :: PhyP(:,:,:)     ! phytoplankton P biomass (umol P L-1), dinoflagellate
  real(8), allocatable :: ZooP(:,:,:)     ! zooplankton P biomass (umol P L-1)
  real(8), allocatable :: PIC (:,:,:)     ! Particulate inorganic carbon (PIC: umol L-1), coccolith (CaCO3)
#if defined COT_STARFISH
  real(8), allocatable :: COTe(:)         ! COT starfish egg (umol L-1)
  real(8), allocatable :: COTl(:)         ! COT starfish larvae (umol L-1)
#endif
#if defined BLUE_TIDE
  real(8), allocatable :: H2S (:,:)       ! H2S(N_Ssp,N): (umol S L-1)
  real(8), allocatable :: S0  (:,:)       ! S0 (N_Ssp,N): (umol S L-1)
#endif

  real(8), allocatable :: dTemp_dt(:)            ! Tmp(N): Temperature (oC)
  real(8), allocatable :: dSalt_dt(:)            ! Sal(N): Salinity (PSU)
  real(8), allocatable :: dDOx_dt(:)             ! dDOx/dt  (umol L-1 s-1) 
  real(8), allocatable :: dTA_dt (:)             ! dTA/dt   (umol L-1 s-1) 
  real(8), allocatable :: dDIC_dt(:,:)       ! dDIC/dt  (umol L-1 s-1)  1 mmol m-3 = 1 umol L-1 = 1/1.024 umol kg-1
  real(8), allocatable :: dNO3_dt(:,:)       ! dNO3/dt (umol L-1 s-1)
  real(8), allocatable :: dNH4_dt(:,:)       ! dNH4/dt (umol L-1 s-1)
  real(8), allocatable :: dPO4_dt(:,:)       ! dPO4/dt (umol L-1 s-1)
  real(8), allocatable :: dDOC_dt(:,:,:)  ! dDOC/dt  (umol L-1 s-1) 
  real(8), allocatable :: dPOC_dt(:,:,:)  ! dPOC/dt  (umol L-1 s-1) 
  real(8), allocatable :: dDON_dt(:,:,:)  ! dDON/dt (umol L-1 s-1)
  real(8), allocatable :: dPON_dt(:,:,:)  ! dPON/dt (umol L-1 s-1)
  real(8), allocatable :: dDOP_dt(:,:,:)  ! dDOP/dt (umol L-1 s-1)
  real(8), allocatable :: dPOP_dt(:,:,:)  ! dPOP/dt (umol L-1 s-1)
  real(8), allocatable :: dPhyC_dt(:,:,:) ! dPhyC/dt  (umolC L-1 s-1)  
  real(8), allocatable :: dZooC_dt(:,:,:) ! dZooC/dt  (umolC L-1 s-1)  
  real(8), allocatable :: dPhyN_dt(:,:,:) ! dPhyN/dt  (umolN L-1 s-1)  
  real(8), allocatable :: dZooN_dt(:,:,:) ! dZooN/dt  (umolN L-1 s-1)  
  real(8), allocatable :: dPhyP_dt(:,:,:) ! dPhyP/dt  (umolP L-1 s-1)  
  real(8), allocatable :: dZooP_dt(:,:,:) ! dZooP/dt  (umolP L-1 s-1)  
  real(8), allocatable :: dPIC_dt (:,:,:) ! dPIC/dt  (umol L-1 s-1) 
#if defined COT_STARFISH
  real(8), allocatable :: dCOTe_dt(:)    ! dCOTe/dt (umol L-1 s-1)
  real(8), allocatable :: dCOTl_dt(:)    ! dCOTl/dt (umol L-1 s-1)
#endif
#if defined BLUE_TIDE
  real(8), allocatable :: dH2S_dt(:,:)   ! dH2S_dt(N_Ssp,N): dH2S/dt (umol S L-1 s-1)
  real(8), allocatable :: dS0_dt (:,:)   ! dS0_dt (N_Ssp,N): dS0/dt  (umol S L-1 s-1)
#endif

#if defined CARBON_ISOTOPE
  real(8) :: R13C
#endif
  real(8), allocatable :: XI_size (:,:)
  real(8), allocatable :: ETA_size(:,:)
  
!  For Output      
!  real(8), parameter :: ECOSYS_OUTPUT_INTERVAL = 60.0d0 !1d0/60d0 !60.0d0 !1.0d0     ! Output interval (min)
  real(8) :: dsec = 0.d0 !sec
  
  real(8) :: h1,h2
  real(8) :: fvol_rc, fvol_ch
  real(8) :: dtrc_dt_sgd

  integer :: in_file(20)
  real(8) :: Tmax, time0
  integer :: nSetting
  integer :: Im, Jm, N
  real(8) :: dt, depth
  integer :: isplitc, isplitsed

  character(256) :: OUTFILE_prefix

  real(8) :: Fdep_sed_in
  real(8) :: MnO2_sed_in, FeOOH_sed_in, FeS2_sed_in
  real(8) :: rCaCO3_sed_in, LPOC_sed_in, RPOC_sed_in
  real(8) :: sgd_flux_in, sgd_Tmp_in, sgd_Sal_in, sgd_DOx_in 
  real(8) :: sgd_TA_in, sgd_DIC_in, sgd_NO3_in, sgd_NH4_in 
  real(8) :: sgd_PO4_in
  real(8) :: sgd_DOC_in(Ndom), sgd_DON_in(Ndom), sgd_DOP_in(Ndom)
  real(8) :: XI_size_in, ETA_size_in
  real(8) :: Diff_w
  character(256) :: OUTFILE
  character(4) :: sFNUM
  integer :: ifnum

  namelist/input_info/in_file
  namelist/output/OUTFILE_prefix
  namelist/ecosys_config/Tmax, time0
  namelist/ecosys_config/nSetting
  namelist/ecosys_config/Im, Jm, N
  namelist/ecosys_config/dt, depth, isplitc, isplitsed

  namelist/sedeco_config/Fdep_sed_in
  namelist/sedeco_config/MnO2_sed_in, FeOOH_sed_in, FeS2_sed_in
  namelist/sedeco_config/rCaCO3_sed_in, LPOC_sed_in, RPOC_sed_in
  namelist/sedeco_config/sgd_flux_in, sgd_Tmp_in, sgd_Sal_in, sgd_DOx_in
  namelist/sedeco_config/sgd_TA_in, sgd_DIC_in, sgd_NO3_in, sgd_NH4_in
  namelist/sedeco_config/sgd_PO4_in
  namelist/sedeco_config/sgd_DOC_in, sgd_DON_in, sgd_DOP_in
  namelist/vprof_config/Diff_w
  namelist/sgrass_config/XI_size_in, ETA_size_in

! Most .in files still list only the first 12 entries of in_file, so clear the
! whole array first; otherwise the trailing entries are read uninitialised.
  in_file(:) = 0

  read (5, nml=input_info)
  rewind(5)
  read (5, nml=output)
  rewind(5)
  read (5, nml=ecosys_config)
  rewind(5)

#if defined SEDIMENT_ECOSYS
  read (5, nml=sedeco_config)
  rewind(5)
#endif
#if defined SEAGRASS
  read (5, nml=sgrass_config)
  rewind(5)
#endif

  if (nSetting .eq. 7) then
    read (5, nml=vprof_config)
    rewind(5)
  endif


  ng=1
  i=1
  j=1
  nstp=1
        
  allocate( Tmp(N)             ) ! Temperature (oC)
  allocate( Sal(N)             ) ! Salinity (PSU)
  allocate( DOx(N)             ) ! Dissolved oxygen (umol L-1)
  allocate( TA (N)             ) ! Total alkalinity (TA: umol kg-1)
  allocate( DIC(N_Csp,N)       )   ! Total dissolved inorganic carbon (DIC: umol kg-1)
  allocate( NO3(N_Nsp,N)       )   ! NO3 (umol L-1)
  allocate( NH4(N_Nsp,N)       )   ! NH4 (umol L-1)
  allocate( PO4(N_Nsp,N)       )   ! PO4 (umol L-1)
  allocate( DOC(N_Csp,Ndom,N)  )   ! Dissolved organic carbon (DOC: umol L-1)
  allocate( POC(N_Csp,Npom,N)  )   ! Particulate organic carbon (POC: umol L-1)
  allocate( DON(N_Nsp,Ndom,N)  )   ! Labile Dissolved organic nitrogen (DON: umol L-1)
  allocate( PON(N_Nsp,Npom,N)  )   ! Particulate organic nitrogen (PON: umol L-1)
  allocate( DOP(N_Psp,Ndom,N)  )   ! Labile Dissolved organic phosporius (DOP: umol L-1)
  allocate( POP(N_Psp,Npom,N)  )   ! Particulate organic phosporius (POP: umol L-1)
  allocate( PhyC(N_Csp,Nphy,N) )   ! phytoplankton C biomass (umol C L-1), dinoflagellate
  allocate( ZooC(N_Csp,Nzoo,N) )   ! zooplankton C biomass (umol C L-1)
  allocate( PhyN(N_Nsp,Nphy,N) )   ! phytoplankton N biomass (umol N L-1), dinoflagellate
  allocate( ZooN(N_Nsp,Nzoo,N) )   ! zooplankton N biomass (umol N L-1)
  allocate( PhyP(N_Psp,Nphy,N) )   ! phytoplankton P biomass (umol P L-1), dinoflagellate
  allocate( ZooP(N_Psp,Nzoo,N) )   ! zooplankton P biomass (umol P L-1)
  allocate( PIC (N_Csp,Npim,N) )   ! Particulate inorganic carbon (PIC: umol L-1), coccolith (CaCO3)
#if defined COT_STARFISH
  allocate( COTe(N)            )   ! COT starfish egg (umol L-1)
  allocate( COTl(N)            )   ! COT starfish larvae (umol L-1)
#endif
#if defined BLUE_TIDE
  allocate( H2S (N_Ssp,N)      )   ! H2S (umol S L-1)
  allocate( S0  (N_Ssp,N)      )   ! S0  (umol S L-1)
#endif

  allocate( dTemp_dt(N)            ) ! Tmp(N): Temperature (oC)
  allocate( dSalt_dt(N)            ) ! Sal(N): Salinity (PSU)
  allocate( dDOx_dt(N)             ) ! dDOx/dt  (umol L-1 s-1) 
  allocate( dTA_dt (N)             ) ! dTA/dt   (umol kg-1 s-1) 
  allocate( dDIC_dt(N_Csp,N)       ) ! dDIC/dt  (umol kg-1 s-1)  1 mmol m-3 = 1 umol L-1 = 1/1.024 umol kg-1
  allocate( dNO3_dt(N_Nsp,N)       ) ! dNO3/dt (umol L-1 s-1)
  allocate( dNH4_dt(N_Nsp,N)       ) ! dNH4/dt (umol L-1 s-1)
  allocate( dPO4_dt(N_Psp,N)       ) ! dPO4/dt (umol L-1 s-1)
  allocate( dDOC_dt(N_Csp,Ndom,N)  ) ! dDOC/dt  (umol L-1 s-1) 
  allocate( dPOC_dt(N_Csp,Npom,N)  ) ! dPOC/dt  (umol L-1 s-1) 
  allocate( dDON_dt(N_Nsp,Ndom,N)  ) ! dDON/dt (umol L-1 s-1)
  allocate( dPON_dt(N_Nsp,Npom,N)  ) ! dPON/dt (umol L-1 s-1)
  allocate( dDOP_dt(N_Psp,Ndom,N)  ) ! dDOP/dt (umol L-1 s-1)
  allocate( dPOP_dt(N_Psp,Npom,N)  ) ! dPOP/dt (umol L-1 s-1)
  allocate( dPhyC_dt(N_Csp,Nphy,N) ) ! dPhyC/dt  (umolC L-1 s-1)  
  allocate( dZooC_dt(N_Csp,Nzoo,N) ) ! dZooC/dt  (umolC L-1 s-1)  
  allocate( dPhyN_dt(N_Nsp,Nphy,N) ) ! dPhyN/dt  (umolN L-1 s-1)  
  allocate( dZooN_dt(N_Nsp,Nzoo,N) ) ! dZooN/dt  (umolN L-1 s-1)  
  allocate( dPhyP_dt(N_Psp,Nphy,N) ) ! dPhyP/dt  (umolP L-1 s-1)  
  allocate( dZooP_dt(N_Psp,Nzoo,N) ) ! dZooP/dt  (umolP L-1 s-1)  
  allocate( dPIC_dt (N_Csp,Npim,N) ) ! dPIC/dt  (umol L-1 s-1) 
#if defined COT_STARFISH
  allocate( dCOTe_dt(N)            ) ! dCOTe/dt (umol L-1 s-1)
  allocate( dCOTl_dt(N)            ) ! dCOTl/dt (umol L-1 s-1)
#endif
#if defined BLUE_TIDE
  allocate( dH2S_dt(N_Ssp,N)       ) ! dH2S/dt (umol S L-1 s-1)
  allocate( dS0_dt (N_Ssp,N)       ) ! dS0/dt  (umol S L-1 s-1)
#endif

!----- Open output files -------------------------

  CALL files_open(OUTFILE_prefix)
      
!----- Set initial conditions -------------------------

  CALL initialize_params(1, Im, 1, Jm, N, Nid)

  dz(:,:,:)=depth/dble(N) !(m)
  z_w(:,:,0)= -depth ! (m, negative)
  do k=1,N
    z_w(:,:,k)= z_w(:,:,k-1) + dz(:,:,k) ! (m, negative)
    z_r(:,:,k)= 0.5d0 * ( z_w(:,:,k-1) + z_w(:,:,k) ) ! (m, negative)
  end do

!----- Import data -----------------------------------

  CALL read_data(in_file)

  if (nSetting .eq. 5) then
    CALL read_chambercondition
  endif

!----- Set initial conditions -------------------------
  MnO2_sed  = MnO2_sed_in   !! Manganese oxide (MnO2) concentration in sediments [nmol/g(DW)]
  FeOOH_sed = FeOOH_sed_in  !! Iron hydroxide (FeOOH) concentration in sediments [nmol/g(DW)]
  FeS2_sed  = FeS2_sed_in   !! Iron sulfide (FeS2) concentration in sediments [nmol/g(DW)]
  LPOC_sed  = LPOC_sed_in   !! Labile Organic carbon in sediments [nmol/g(DW)]
  RPOC_sed  = RPOC_sed_in   !! Refractory Organic carbon in sediments [nmol/g(DW)]
  rCaCO3_sed = rCaCO3_sed_in ! Fraction of Calcium carbonate (CaCO3) in sediments [g/g(DW)]

#if defined USE_HEAT
  CALL initialize_heat(1, Ngrids, 1, Im, 1, Jm)
#endif
#if defined REEF_FLOW
  CALL initialize_reef_flow(1, Ngrids, 1, Im, 1, Jm)
#endif
  CALL allocate_marine_comet(1, Ngrids, N, 1, Im, 1, Jm)

#ifdef SEAGRASS
  allocate( XI_size (1:Im,1:Jm) ) ! grid size XI-direction (meters)
  allocate( ETA_size(1:Im,1:Jm) ) ! grid size ETA-direction (meters)
  XI_size (:,:) = XI_size_in
  ETA_size(:,:) = ETA_size_in
#endif
  CALL initialize_marine_comet(1, N, dz, 1, Im, 1, Jm      &
      , start_of_new_run    &   ! TRUE = initialize coral, seagass, macroalgae, sediment from start; FALSE = continue from previous run
#ifdef SEAGRASS
      , 1, Im, 1, Jm        &   ! grid size info
      , XI_size, ETA_size   &   ! grid size XI-direction (meters); grid size ETA-direction (meters)
      , p_sgrass            &   ! seagrass coverage (habitat area in grid / grid area)
#endif
# ifdef BIVALVE
      , dens_aqua           &   ! Aquaculture density
      , f_dens              &   ! Factor to adjust oyster density (default = 1.0)
# endif
)
!  call Coral_iniSizeDis
!  call Coral_Size2Cover

  time=time0
    
!----- Write data labels -------------------------
  CALL write_env_lavel(10)        
#if defined REEF_FLOW_TESTMODE
  CALL write_flow_lavel(45)
#endif

!----- Main loop -------------------------------------------
  
  DO

!------ Set environmental parameters ----------------------------

    CALL setdata(nSetting, in_file, dt, nstp)
        
#if defined REEF_FLOW
    if (nSetting .eq. 4) then
        

!----- Reef hydrodynamics model ----------------------------------------

      h1 = REEF(1)%el(i,j)+REEF(1)%Dir(i,j)
    
      CALL reef_flow         &
!      input parameters
              (1, 1, 1        &   ! ng: nested grid number; i,j: position
              ,time           &   ! Date (days since x or elapsed days) yt_edit best if in phase with clock to maintain consistency on restart
              ,dt             &   ! Time step (sec)
              ,Hs             &   ! Significant wave hight at offshore (m)
              ,Tp             &   ! Significant Wave period (s)
              ,tide           &   ! Sea surface elevation at offshore (m)
               )
        
      h2 = (REEF(1)%el(i,j)+REEF(1)%Dir(i,j))
      dz(i,j,:) =h2/N
    end if
#endif
        
#if defined USE_HEAT

!----- Heat & mass balance model ----------------------------------------

    CALL heat_mass_balance    &
!      input parameters
              (ng,i,j         &   ! ng: nested grid number; i,j: position
              ,N              &   ! Number of vertical grid (following ROMS vertical grid)
              ,dt             &   ! Time step (sec)
              ,dz(i,j,:)      &   ! dz(N): vertical grid size (m)
              ,swrad          &   ! Surface shortwave radiation (W m-2)
              ,Tair           &   ! air temperature (oC)
              ,Pair           &   ! atm pressure (hPa)
              ,Rh             &   ! vapor pressur (hPa)
              ,U10            &   ! wind speed (m s-1)
              ,rain           &   ! Precipitation volume flux (m s-1)
#ifdef LONGWAVE_IN
              ,dlwrad         &   ! Downward longwave radiation (W m-2)
#endif
              ,cloud          &   ! cloud cover (0-1)

              ,t(i,j,:,nstp,iTemp)     &   ! Tmp(N): Temperature (oC)
              ,t(i,j,:,nstp,iSalt)     &   ! Sal(N): Salinity (PSU)

!          output parameters
              ,dtrc_dt(:,iTemp)   &   ! dDIC_dt(N): dDIC/dt (umol kg-1 s-1)
               )
#endif

!----- Ecosystem model ----------------------------------------
!=== Import ROMS tracer arrays into REEF_ECOSYS model arrays ===
    Tmp(:) = t(i,j,:,nstp,iTemp)       
    Sal(:) = t(i,j,:,nstp,iSalt)       
    DOx(:) = t(i,j,:,nstp,iOxyg)       
    TA (:) = t(i,j,:,nstp,iTAlk)
    DO isp=1,N_Csp     
      DIC(isp,:) = t(i,j,:,nstp,iTIC(isp))
    END DO       
    DO isp=1,N_Nsp     
      NO3(isp,:) = t(i,j,:,nstp,iNO3(isp))       
    END DO       
    DO isp=1,N_Nsp     
      NH4(isp,:) = t(i,j,:,nstp,iNH4(isp))       
    END DO       
    DO isp=1,N_Psp     
      PO4(isp,:) = t(i,j,:,nstp,iPO4(isp))       
    END DO
    DO m=1,Ndom    
      DO isp=1,N_Csp     
        DOC(isp,m,:) = t(i,j,:,nstp,iDOC(isp,m))
      END DO
    END DO
    DO m=1,Ndom    
      DO isp=1,N_Nsp     
        DON(isp,m,:) = t(i,j,:,nstp,iDON(isp,m))  
      END DO
    END DO
    DO m=1,Ndom    
      DO isp=1,N_Psp     
        DOP(isp,m,:) = t(i,j,:,nstp,iDOP(isp,m))  
      END DO
    END DO 
    DO m=1,Npom    
      DO isp=1,N_Csp     
        POC(isp,m,:) = t(i,j,:,nstp,iPOC(isp,m))  
      END DO
    END DO 
    DO m=1,Npom    
      DO isp=1,N_Nsp     
        PON(isp,m,:) = t(i,j,:,nstp,iPON(isp,m))  
      END DO
    END DO 
    DO m=1,Npom    
      DO isp=1,N_Psp     
        POP(isp,m,:) = t(i,j,:,nstp,iPOP(isp,m))  
      END DO
    END DO 
    DO m=1,Nphy    
      DO isp=1,N_Csp     
        PhyC(isp,m,:) = t(i,j,:,nstp,iPhyC(isp,m))
      END DO
    END DO 
    DO m=1,Nphy    
      DO isp=1,N_Nsp     
        PhyN(isp,m,:) = t(i,j,:,nstp,iPhyN(isp,m))
      END DO
    END DO 
    DO m=1,Nphy    
      DO isp=1,N_Psp     
        PhyP(isp,m,:) = t(i,j,:,nstp,iPhyP(isp,m))
      END DO
    END DO 
    DO m=1,Nzoo    
      DO isp=1,N_Csp     
        ZooC(isp,m,:) = t(i,j,:,nstp,iZooC(isp,m))
      END DO
    END DO 
    DO m=1,Nzoo    
      DO isp=1,N_Nsp     
        ZooN(isp,m,:) = t(i,j,:,nstp,iZooN(isp,m))
      END DO
    END DO 
    DO m=1,Nzoo    
      DO isp=1,N_Psp     
        ZooP(isp,m,:) = t(i,j,:,nstp,iZooP(isp,m))
      END DO
    END DO 
    DO m=1,Npim    
      DO isp=1,N_Csp     
         PIC (isp,m,:) = t(i,j,:,nstp,iPIC(isp,m)) 
      END DO
    END DO 
#if defined COT_STARFISH
    COTe(:) = t(i,j,:,nstp,iCOTe)     &   ! COTe(N): COT starfish egg (umol L-1)
    COTl(:) = t(i,j,:,nstp,iCOTl)     &   ! COTl(N): COT starfish larvae (umol L-1)
#endif
#if defined BLUE_TIDE
    DO isp=1,N_Ssp
      H2S(isp,:) = t(i,j,:,nstp,iH2S(isp))   ! H2S(N_Ssp,N): (umol S L-1)
      S0 (isp,:) = t(i,j,:,nstp,iS0 (isp))   ! S0 (N_Ssp,N): (umol S L-1)
    END DO
#endif

#if defined SEDECO_SGD && defined SGD_ON
    ! sgd_flux  = sgd_flux_in
    sgd_flux  = sgd
    sgd_Tmp   = sgd_Tmp_in 
    sgd_Sal   = sgd_Sal_in 
    sgd_DOx   = sgd_DOx_in
    sgd_TA    = sgd_TA_in

    sgd_DIC(:)= 0.0d0     
    sgd_NO3(:)= 0.0d0 
    sgd_NH4(:)= 0.0d0 
    sgd_PO4(:)= 0.0d0 
    sgd_DOC(:,:)= 0.0d0
    sgd_DON(:,:)= 0.0d0
    sgd_DOP(:,:)= 0.0d0

    sgd_DIC(iCt)= sgd_DIC_in
    sgd_NO3(iNt)= sgd_NO3_in 
    sgd_NH4(iNt)= sgd_NH4_in 
    sgd_PO4(iPt)= sgd_PO4_in 
    sgd_DOC(iCt,:)= sgd_DOC_in
    sgd_DON(iNt,:)= sgd_DON_in
    sgd_DOP(iPt,:)= sgd_DOP_in
#endif
#if defined SEDECO_BURIAL
    Fdep_sed = Fdep_sed_in  ! 2.77d-8 g/cm2/s = 1.0 g/m2/h; Sedimentation rate (g cm-2 s-1) (Positive: sedimentation; Negative: erosion)
#endif

    CALL marine_comet          &
!      input parameters
     ( ng, i, j       &   ! ng: nested grid number; i,j: position
     , N              &   ! Number of vertical grid (following ROMS vertical grid)
     , isplitc        &   ! Internal loop counts of coral polyp model
     , isplitsed      &   ! Internal loop counts of sediment ecosystem model
     , time           &   ! Date (days since x or elapsed days) yt_edit best if in phase with clock to maintain consistency on restart
     , dt             &   ! Time step (sec)
     , dz(i,j,:)      &   ! dz(N): vertical grid size (m)
     , PFDsurf        &   ! Sea surface photon flux density (umol m-2 s-1)
     , tau            &   ! bottom shear stress (N m-2)
     , pCO2air        &   ! Air CO2 pertial pressure (uatm)
     , U10            &   ! wind speed (m s-1)
#ifdef CORAL_POLYP
      , p_coral(:,i,j)  &   ! Coral coverage (0-1)
#endif
#ifdef SEAGRASS
      , p_sgrass(:,i,j) &   ! seagrass coverage (0-1)
#endif
#ifdef MACROALGAE
      , p_algae(:,i,j)  &   ! algal coverage (0-1)
#endif
#ifdef SEDIMENT_ECOSYS
      , p_sand(i,j)     &   ! sediment coverage (0-1)
#endif
      , Tmp            &   ! Tmp(N): Temperature (oC)
      , Sal            &   ! Sal(N): Salinity (PSU)
      , DOx            &   ! DOx(N): Dissolved oxygen (umol O2 L-1)
      , TA             &   ! TA(N) : Total alkalinity (umol L-1)
      , DIC            &   ! DIC(N_Csp,N): Total dissolved inorganic carbon (umol C L-1)
      , NO3            &   ! NO3(N_Nsp,N): (umol N L-1)
      , NH4            &   ! NH4(N_Nsp,N): (umol N L-1)
      , PO4            &   ! PO4(N_Psp,N): (umol P L-1)
      , DOC            &   ! DOC(N_Csp,Ndom,N): Dissolved organic carbon       (umol C L-1)
      , POC            &   ! POC(N_Csp,Npom,N): Particulate organic carbon     (umol C L-1)
      , DON            &   ! DON(N_Nsp,Ndom,N): Dissolved organic nitrogen     (umol N L-1)
      , PON            &   ! PON(N_Nsp,Npom,N): Particulate organic nitrogen   (umol N L-1)
      , DOP            &   ! DOP(N_Psp,Ndom,N): Dissolved organic phosporius   (umol P L-1)
      , POP            &   ! POP(N_Psp,Npom,N): Particulate organic phosporius (umol P L-1)
      , PhyC           &   ! PhyC(N_Csp,Nphy,N): phytoplankton C biomass (umol C L-1)
      , ZooC           &   ! ZooC(N_Csp,Nzoo,N): zooplankton C biomass   (umol C L-1)
      , PhyN           &   ! PhyN(N_Nsp,Nphy,N): phytoplankton N biomass (umol N L-1)
      , ZooN           &   ! ZooN(N_Nsp,Nzoo,N): zooplankton N biomass   (umol N L-1)
      , PhyP           &   ! PhyP(N_Psp,Nphy,N): phytoplankton P biomass (umol P L-1)
      , ZooP           &   ! ZooP(N_Psp,Nzoo,N): zooplankton P biomass   (umol P L-1)
      , PIC            &   ! PIC (N_Csp,Npim,N): Particulate inorganic carbon (PIC: umolC L-1), coccolith (CaCO3)
#if defined BLUE_TIDE
      , H2S            &   ! H2S (N_Ssp,N)     : (umol S L-1)
      , S0             &   ! S0  (N_Ssp,N)     : (umol S L-1)
#endif
#if defined COT_STARFISH
      , COTe           &   ! COTe(N): COT starfish egg (umol L-1)
      , COTl           &   ! COTl(N): COT starfish larvae (umol L-1)
#endif
#if defined SEDECO_SGD && defined SGD_ON
      , sgd_flux       &   ! sumbarine groundwater discharge rate (cm s-1)  This flux is assumed to be the same throughout the sediment ecosystem layers (no compression/expansion) So volume flux doesn't change but concentrations of tracers do
      , sgd_Tmp        &   ! SGD concentration coming in through bottom: Tmp: Temperature (oC)
      , sgd_Sal        &   ! SGD concentration coming in through bottom: Sal: Salinity (PSU)
      , sgd_TA         &   ! SGD concentration coming in through bottom: TA : Total alkalinity (TA: umol kg-1)
      , sgd_DOx        &   ! SGD concentration coming in through bottom: DOx: Dissolved oxygen (umol L-1)
      , sgd_DIC        &   ! SGD concentration coming in through bottom: DIC: Total dissolved inorganic carbon (DIC: umol kg-1)
      , sgd_NO3        &   ! SGD concentration coming in through bottom: NO3: NO3 (umol L-1)
      , sgd_NH4        &   ! SGD concentration coming in through bottom: NH4: NH4 (umol L-1)
      , sgd_PO4        &   ! SGD concentration coming in through bottom: PO4: PO4 (umol L-1)
      , sgd_DOC        &   ! SGD concentration coming in through bottom: DOC: Total dissolved organic carbon (DOC: umol L-1)
      , sgd_DON        &   ! SGD concentration coming in through bottom: DOC: Total dissolved organic nitrogen (DON: umol L-1)
      , sgd_DOP        &   ! SGD concentration coming in through bottom: DOC: Total dissolved organic phosphrous (DOP: umol L-1)
#endif
#if defined SEDECO_BURIAL
      , Fdep_sed       &   ! Sedimentation rate (g cm-2 s-1) (Positive: sedimentation; Negative: erosion)
#endif
!   output parameters
      , dTemp_dt       &   ! dTemp_dt(N)           : Temperature (oC s-1)
      , dSalt_dt       &   ! dSalt_dt(N)           : Salinity (PSU s-1)
      , dDOx_dt        &   ! dDOx_dt(N)            : dDOx/dt  (umol O2 L-1 s-1) 
      , dTA_dt         &   ! dTA_dt(N)             : dTA/dt   (umol L-1 s-1) 
      , dDIC_dt        &   ! dDIC_dt(N_Csp,N)      : dDIC/dt  (umol C L-1 s-1)  1 mmol m-3 = 1 umol L-1 = 1/1.024 umol kg-1
      , dNO3_dt        &   ! dNO3_dt(N_Nsp,N)      : dNO3/dt  (umol N L-1 s-1)
      , dNH4_dt        &   ! dNH4_dt(N_Nsp,N)      : dNH4/dt  (umol N L-1 s-1)
      , dPO4_dt        &   ! dPO4_dt(N_Psp,N)      : dPO4/dt  (umol P L-1 s-1)
      , dDOC_dt        &   ! dDOC_dt(N_Csp,Ndom,N) : dDOC/dt  (umol C L-1 s-1) 
      , dPOC_dt        &   ! dPOC_dt(N_Csp,Npom,N) : dPOC/dt  (umol C L-1 s-1) 
      , dDON_dt        &   ! dDON_dt(N_Nsp,Ndom,N) : dDON/dt  (umol N L-1 s-1)
      , dPON_dt        &   ! dPON_dt(N_Nsp,Npom,N) : dPON/dt  (umol N L-1 s-1)
      , dDOP_dt        &   ! dDOP_dt(N_Psp,Ndom,N) : dDOP/dt  (umol P L-1 s-1)
      , dPOP_dt        &   ! dPOP_dt(N_Psp,Npom,N) : dPOP/dt  (umol P L-1 s-1)
      , dPhyC_dt       &   ! dPhyC_dt(N_Csp,Nphy,N): dPhyC/dt (umol C L-1 s-1)  
      , dZooC_dt       &   ! dZooC_dt(N_Csp,Nzoo,N): dZooC/dt (umol C L-1 s-1)  
      , dPhyN_dt       &   ! dPhyN_dt(N_Nsp,Nphy,N): dPhyN/dt (umol N L-1 s-1)  
      , dZooN_dt       &   ! dZooN_dt(N_Nsp,Nzoo,N): dZooN/dt (umol N L-1 s-1)  
      , dPhyP_dt       &   ! dPhyP_dt(N_Psp,Nphy,N): dPhyP/dt (umol P L-1 s-1)  
      , dZooP_dt       &   ! dZooP_dt(N_Psp,Nzoo,N): dZooP/dt (umol P L-1 s-1)  
      , dPIC_dt        &   ! dPIC_dt (N_Csp,Npim,N): dPIC/dt  (umol C L-1 s-1)
#if defined BLUE_TIDE
      , dH2S_dt        &   ! dH2S_dt (N_Ssp,N)     : dH2S/dt  (umol S L-1 s-1)
      , dS0_dt         &   ! dS0_dt(N_Ssp,N)       : dS0/dt   (umol S L-1 s-1)
#endif
#if defined COT_STARFISH
      , dCOTe_dt       &   ! dCOTe/dt(N): (umol L-1 s-1)
      , dCOTl_dt       &   ! dCOTl/dt(N): (umol L-1 s-1)
#endif
      , pH(i,j,:)      &   ! pH
      , Warg(i,j,:)    &   ! aragonite saturation state
      , Wcal(i,j,:)    &   ! calcite saturation state
      , ssfCO2         &   ! sea surface fCO2 (uatm)
      , ssCO2flux      &   ! sea surface CO2 flux (mmol m-2 s-1)
      , ssO2flux       &   ! sea surface O2 flux (mmol m-2 s-1)
      , PFDbott        &   ! Bottom photon flux density (umol m-2 s-1)
!!! mons light model >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>KM:Add
#if defined LIGHT_MODEL
      , PFDk(i,j,:)    &   ! Column PFD (umol m-2 s-1)
#endif
!!!<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<KM:Add
      )                    

!=== Export REEF_ECOSYS model arrays into ROMS tracer arrays ===
    dtrc_dt(:,iTemp) = dTemp_dt(:)        
    dtrc_dt(:,iSalt) = dSalt_dt(:)        
    dtrc_dt(:,iOxyg) = dDOx_dt(:)        
    dtrc_dt(:,iTAlk) = dTA_dt(:) 
    DO isp=1,N_Csp     
      dtrc_dt(:,iTIC(isp)) = dDIC_dt(isp,:)
    END DO       
    DO isp=1,N_Nsp     
      dtrc_dt(:,iNO3(isp)) = dNO3_dt(isp,:)        
    END DO       
    DO isp=1,N_Nsp     
      dtrc_dt(:,iNH4(isp)) = dNH4_dt(isp,:)        
    END DO       
    DO isp=1,N_Psp     
      dtrc_dt(:,iPO4(isp)) = dPO4_dt(isp,:)       
    END DO
    DO m=1,Ndom    
      DO isp=1,N_Csp     
        dtrc_dt(:,iDOC(isp,m)) = dDOC_dt(isp,m,:) 
      END DO
    END DO
    DO m=1,Ndom    
      DO isp=1,N_Nsp     
        dtrc_dt(:,iDON(isp,m)) = dDON_dt(isp,m,:)   
      END DO
    END DO
    DO m=1,Ndom    
      DO isp=1,N_Psp     
        dtrc_dt(:,iDOP(isp,m)) = dDOP_dt(isp,m,:)  
      END DO
    END DO 
    DO m=1,Npom    
      DO isp=1,N_Csp     
        dtrc_dt(:,iPOC(isp,m)) = dPOC_dt(isp,m,:)  
      END DO
    END DO 
    DO m=1,Npom    
      DO isp=1,N_Nsp     
        dtrc_dt(:,iPON(isp,m)) = dPON_dt(isp,m,:)  
      END DO
    END DO 
    DO m=1,Npom    
      DO isp=1,N_Psp     
        dtrc_dt(:,iPOP(isp,m)) = dPOP_dt(isp,m,:)   
      END DO
    END DO 
    DO m=1,Nphy    
      DO isp=1,N_Csp     
        dtrc_dt(:,iPhyC(isp,m)) = dPhyC_dt(isp,m,:) 
      END DO
    END DO 
    DO m=1,Nphy    
      DO isp=1,N_Nsp     
        dtrc_dt(:,iPhyN(isp,m)) = dPhyN_dt(isp,m,:)
      END DO
    END DO 
    DO m=1,Nphy    
      DO isp=1,N_Psp     
        dtrc_dt(:,iPhyP(isp,m)) = dPhyP_dt(isp,m,:)
      END DO
    END DO 
    DO m=1,Nzoo    
      DO isp=1,N_Csp     
        dtrc_dt(:,iZooC(isp,m)) = dZooC_dt(isp,m,:)
      END DO
    END DO 
    DO m=1,Nzoo    
      DO isp=1,N_Nsp     
        dtrc_dt(:,iZooN(isp,m)) = dZooN_dt(isp,m,:)
      END DO
    END DO 
    DO m=1,Nzoo    
      DO isp=1,N_Psp     
        dtrc_dt(:,iZooP(isp,m)) = dZooP_dt(isp,m,:) 
      END DO
    END DO 
    DO m=1,Npim    
      DO isp=1,N_Csp     
        dtrc_dt(:,iPIC(isp,m)) = dPIC_dt (isp,m,:)  
      END DO
    END DO 
#if defined COT_STARFISH
    dtrc_dt(:,iCOTe) = dCOTe_d(:)      &   ! COTe(N): COT starfish egg (umol L-1)
    dtrc_dt(:,iCOTl) = dCOTl_d(:)      &   ! COTl(N): COT starfish larvae (umol L-1)
#endif
#if defined BLUE_TIDE
    DO isp=1,N_Ssp
      dtrc_dt(:,iH2S(isp)) = dH2S_dt(isp,:)   ! dH2S/dt (umol S L-1 s-1)
      dtrc_dt(:,iS0 (isp)) = dS0_dt (isp,:)   ! dS0/dt  (umol S L-1 s-1)
    END DO
#endif

    do k=1,N
        

!---------- for Stable condition ---------------------------------
              
      if (nSetting .eq. 1) then
          
        ! nothing to calculate

!---------- for Closed Chamber condition -------------------------

      else if (nSetting .eq. 2) then
        
!        t(i,j,k,nstp,iTemp)=t(i,j,k,nstp,iTemp)+0.
!        t(i,j,k,nstp,iSalt)=t(i,j,k,nstp,iSalt)+0.
!        t(i,j,k,nstp,iSedi)=t(i,j,k,nstp,iSedi)+0.
        
        do id=1,Nid

          t(i,j,k,nstp,id)=t(i,j,k,nstp,id) + dtrc_dt(k,id)*dt
#if defined SEDECO_SGD && defined SGD_ON
          ! Overflowing of the SGD volume flux is assumed 
          dtrc_dt_sgd = -0.01d0*sgd_flux *t(i,j,k,nstp,id)/dz(i,j,1)/dble(N)
          t(i,j,k,nstp,id)=t(i,j,k,nstp,id) + dtrc_dt_sgd*dt
#endif
        end do

!---------- Constant Flow condition ------------------------------------

      else if (nSetting .eq. 3) then

#if defined SAKAMAKI_ET_AL_2025
        t(2,j,k,nstp,iTemp) = 15.0d0+7.0d0*cos(2.0d0*PI*(time-30.0d0)/365.0d0)
        t(i,j,k,nstp,iTemp) = t(2,j,k,nstp,iTemp)

!        t(2,j,k,nstp,iPhyC(iCt,iDtm)) = mgC2umolC*(0.15d0+0.05* cos(2.0d0*PI*time/365.0d0) )
        t(2,j,k,nstp,iPhyC(iCt,iDtm)) = mgC2umolC*(0.15d0+0.05* cos(2.0d0*PI*(time+30.0d0)/365.0d0) )*0.1d0 !10% of the POC assumed to be phytoplankton
        t(2,j,k,nstp,iPhyN(iCt,iDtm)) = t(2,j,k,nstp,iPhyC(iCt,iDtm))*rNCp(iDtm)
        t(2,j,k,nstp,iPhyP(iCt,iDtm)) = t(2,j,k,nstp,iPhyC(iCt,iDtm))*rPCp(iDtm)
#endif
        do id=1,Nid

#if defined SAKAMAKI_ET_AL_2025
          t(i,j,k,nstp,id)=t(i,j,k,nstp,id)           &
                           + ( dtrc_dt(k,id)          &
                              -vel*t(i,j,k,nstp,id)/dx  &
                              +vel*t(2,j,k,nstp,id)/dx )*dt
#endif
#if defined SEDECO_SGD && defined SGD_ON
          ! Overflowing of the SGD volume flux is assumed 
          dtrc_dt_sgd = -0.01d0*sgd_flux *t(i,j,k,nstp,id)/dz(i,j,1)/dble(N)
          t(i,j,k,nstp,id)=t(i,j,k,nstp,id) + dtrc_dt_sgd*dt
#endif
        end do


!---------- Reef condition ------------------------------------

      else if (nSetting .eq. 4) then
#if defined REEF_FLOW
        fvol_rc = REEF(1)%Qrc(i,j)*REEF(1)%Wrc(i,j)
        fvol_ch = REEF(1)%Qch(i,j)*REEF(1)%Wch(i,j)
        do id=1,Nid
          t(1,j,k,nstp,id) = t(1,j,k,nstp,id)*h1/h2                          &
                        +(0.5d0*(ABS(fvol_rc)+fvol_rc)* t(2,j,k,nstp,id)  &  !  (t unit) m s-1
                         -0.5d0*(ABS(fvol_rc)-fvol_rc)* t(1,j,k,nstp,id)  &  !  (t unit) m s-1
                         +0.5d0*(ABS(fvol_ch)+fvol_ch)* t(2,j,k,nstp,id)  &  !  (t unit) m s-1
                         -0.5d0*(ABS(fvol_ch)-fvol_ch)* t(1,j,k,nstp,id)  &  !  (t unit) m s-1
                         )/h2/REEF(1)%Air(i,j)*dt
          t(1,j,k,nstp,id)=t(1,j,k,nstp,id) + dtrc_dt(k,id)*dt
        end do
#endif

!---------- Incubation chamber condition ------------------------------------

      else if (nSetting .eq. 5) then
        if( ipcl == 1) then
          t(i,j,k,nstp,iTIC(iCt)) = DIC_data(1)
          t(i,j,k,nstp,iTAlk) = TA_data(1)
          t(i,j,k,nstp,iOxyg) = DO_data(1)
!          t(i,j,k,nstp,iOxyg) = O2satu(t(i,j,k,nstp,iTemp)+273.15d0, t(i,j,k,nstp,iSalt))
#if defined CARBON_ISOTOPE
          R13C=R13C_fromd13C(0.7d0)
          t(i,j,k,nstp,iTIC(iC13)) =R13C*t(i,j,k,nstp,iTIC(iCt)) !DI13C (umol kg-1) 
#endif
          ipcl = 2
        end if
      
        if (time >= 4.0d0 ) then
          do id=4,Nid
            t(i,j,k,nstp,id)=t(i,j,k,nstp,id) + dtrc_dt(k,id)*dt
          end do
          if (WQ_time(ipcl)-15.0d0/60.0d0 < time*24.0d0 .and. time*24.0d0 < WQ_time(ipcl)  ) then
            t(i,j,k,nstp,iTIC(iCt)) = DIC_data(ipcl)
            t(i,j,k,nstp,iTAlk) = TA_data(ipcl) 
            t(i,j,k,nstp,iOxyg) = DO_data(ipcl)
!            t(i,j,k,nstp,iOxyg) = O2satu(t(i,j,k,nstp,iTemp)+273.15d0, t(i,j,k,nstp,iSalt))
#if defined CARBON_ISOTOPE
            R13C=R13C_fromd13C(0.7d0)
            t(i,j,k,nstp,iTIC(iC13)) =R13C*t(i,j,k,nstp,iTIC(iCt)) !DI13C (umol kg-1) 
#endif
          else if (time*24.0d0 >= WQ_time(ipcl)  ) then
            ipcl = ipcl +1
            if(ipcl>N_WQ) ipcl = N_WQ
          end if
        end if

!---------- Flume simulation ------------------------------------

      else if (nSetting .eq. 6) then
      
        if (aint(time)+6.0d0/24.0d0 <= time .and.  &
            time <= aint(time)+18.0d0/24.0d0     ) then
          if (inight == 1 ) then
            iflag = 1
            inight = 0
          end if
        else
          if (inight == 0 ) then
            iflag = 1
            inight = 1
          end if
        end if
        
        if (7.0d0+ 6.0d0/24.0d0 < time ) then
          if (iclose == 0 ) then
            iflag = 1
            iclose = 1
          end if
        end if
        if (7.0d0+12.0d0/24.0d0 < time ) then
          if (iclose == 1 ) then
            iflag = 1
            iclose = 2
          end if
        end if
        if (7.0d0+18.0d0/24.0d0 < time ) then
          if (iclose == 2 ) then
            iflag = 1
            iclose = 3
          end if
        end if
        if (8.0d0+ 0.0d0/24.0d0 < time ) then
          if (iclose == 3 ) then
            iflag = 1
            iclose = 4
          end if
        end if
        if (8.0d0+ 6.0d0/24.0d0 < time ) then
          if (iclose == 4 ) then
            iflag = 1
            iclose = 0
          end if
        end if
        
        if( inight == 1 .and. iflag == 1 ) then  ! Night treatment ~pH -0.1 (18:00-06:00)
#if defined FLUME_AMBIENT
          t(i,j,k,nstp,iTIC(iCt)) = 2090.0d0
#elif defined FLUME_HPCO2
          t(i,j,k,nstp,iTIC(iCt)) = 2269.0d0
#endif
          t(i,j,k,nstp,iTAlk) = 2340.0d0
          t(i,j,k,nstp,iOxyg) = O2satu(t(i,j,k,nstp,iTemp)+273.15d0, t(i,j,k,nstp,iSalt))
#if defined CARBON_ISOTOPE
          R13C=R13C_fromd13C(0.7d0)
          t(i,j,k,nstp,iTIC(iC13)) =R13C*t(i,j,k,nstp,iTIC(iCt)) !DI13C (umol kg-1) 
#endif
          iflag = 0
        end if
        
        if( inight == 0 .and. iflag == 1 ) then
#if defined FLUME_AMBIENT
          t(i,j,k,nstp,iTIC(iCt)) = 2033.0d0
#elif defined FLUME_HPCO2
          t(i,j,k,nstp,iTIC(iCt)) = 2243.0d0
#endif
          t(i,j,k,nstp,iTAlk) = 2340.0d0
          t(i,j,k,nstp,iOxyg) = O2satu(t(i,j,k,nstp,iTemp)+273.15d0, t(i,j,k,nstp,iSalt))
#if defined CARBON_ISOTOPE
          R13C=R13C_fromd13C(0.7d0)
          t(i,j,k,nstp,iTIC(iC13)) =R13C*t(i,j,k,nstp,iTIC(iCt)) !DI13C (umol kg-1) 
#endif
          iflag = 0
        end if
        
        
        if( iclose >= 1 ) then  ! Closed
!          tau = 1024*0.14*0.02**2. *0.5  !densSW*Cd*Ub**2  (2 cm s-1)
!          tau = 1024*0.14*0.05**2. *0.5  !densSW*Cd*Ub**2  (5 cm s-1)
          tau = 1024*0.14*0.10**2. *0.5  !densSW*Cd*Ub**2  (10 cm s-1)
          do id=4,Nid
            t(i,j,k,nstp,id)=t(i,j,k,nstp,id) + dtrc_dt(k,id)*dt
          end do
        end if

!---------- for Vertical profile simulation -------------------------

      else if (nSetting .eq. 7) then
               
        do id=1,Nid
          ! Difusion term
          if(k==1) then
             t(i,j,k,nstp,id)=t(i,j,k,nstp,id)                        &
                             + (t(i,j,k,nstp,id)+t(i,j,k+1,nstp,id)   &
                                - 2.0d0*t(i,j,k,nstp,id))             &
                                *Diff_w/dz(i,j,k)/dz(i,j,k)*dt
          else if(k==N) then
             t(i,j,k,nstp,id)=t(i,j,k,nstp,id)                        &
                             + (t(i,j,k-1,nstp,id)+t(i,j,k,nstp,id)   &
                                - 2.0d0*t(i,j,k,nstp,id))             &
                                *Diff_w/dz(i,j,k)/dz(i,j,k)*dt
          else
            t(i,j,k,nstp,id)=t(i,j,k,nstp,id)                         &
                             + (t(i,j,k-1,nstp,id)+t(i,j,k+1,nstp,id) &
                                - 2.0d0*t(i,j,k,nstp,id))             &
                                *Diff_w/dz(i,j,k)/dz(i,j,k)*dt
          end if

          ! Reaction term
          t(i,j,k,nstp,id)=t(i,j,k,nstp,id) + dtrc_dt(k,id)*dt
#if defined SEDECO_SGD && defined SGD_ON
          ! Overflowing of the SGD volume flux is assumed 
          dtrc_dt_sgd = -0.01d0*sgd_flux *t(i,j,k,nstp,id)/dz(i,j,k)/dble(N)
          t(i,j,k,nstp,id)=t(i,j,k,nstp,id) + dtrc_dt_sgd*dt
#endif
        end do

!------------------------------------------------------------------------------

      else if (nSetting .eq. 8) then
        
        !        t(i,j,k,nstp,iTemp)=t(i,j,k,nstp,iTemp)+0.
        !        t(i,j,k,nstp,iSalt)=t(i,j,k,nstp,iSalt)+0.
        !        t(i,j,k,nstp,iSedi)=t(i,j,k,nstp,iSedi)+0.
                
        do id=1,Nid

          t(i,j,k,nstp,id)=t(i,j,k,nstp,id) + dtrc_dt(k,id)*dt
#if defined SEDECO_SGD && defined SGD_ON
          ! Overflowing of the SGD volume flux is assumed 
          dtrc_dt_sgd = -0.01d0*sgd_flux *t(i,j,k,nstp,id)/dz(i,j,1)/dble(N)
          t(i,j,k,nstp,id)=t(i,j,k,nstp,id) + dtrc_dt_sgd*dt
#endif
        end do


      end if
          
!------------------------------------------------------------------------------

!          depsed(i,j)=0.
!          radi(i,j,k)=-swrad

          
    enddo


!    p_coral(1,i,j)=p_coral(1,i,j)                         &
!          +(g_coral(1,i,j)-m_coral(1,i,j))*p_coral(1,i,j)
!
!    if (p_coral(1,i,j) .lt. 1.e-5) then
!      p_coral(1,i,j)=0.
!    end if

!------- Print section --------------------------------------

    if( time*86400.0d0 >= dsec ) THEN
      if(dsec == 0.0d0) then
        dsec=time*86400.0d0+ECOSYS_OUTPUT_INTERVAL*60.0d0
        ifnum = 0
      else
        dsec=dsec+ECOSYS_OUTPUT_INTERVAL*60.0d0
      endif
      
      write(*,*) 'Time (day): ', time  ! Output for standard out
      ! write(*,*) 'pH', pH  ! Output for standard out
      ! write(*,*) 'DOx', t(i,j,:,nstp,iOxyg)  ! Output for standard out
      write(sFNUM,'(I4.4)') ifnum
      CALL write_env_data(10)
#if defined SEDIMENT_TESTMODE
      OUTFILE=trim(OUTFILE_prefix)//'-sedeco_his_'//sFNUM//'.csv'
      CALL write_sedeco_his_data(OUTFILE, time)
      OUTFILE=trim(OUTFILE_prefix)//'-sedeco_dia_'//sFNUM//'.csv'
      CALL write_sedeco_dia_data(OUTFILE, time)
#endif
      if (nSetting .eq. 7) then
        OUTFILE=trim(OUTFILE_prefix)//'-env_vprof_'//sFNUM//'.csv'
        CALL write_env_vprof(OUTFILE, time, N)
#if defined BIVALVE_TESTMODE
        OUTFILE=trim(OUTFILE_prefix)//'-bivalve_vprof_'//sFNUM//'.csv'
        CALL write_bivalve_vprof(OUTFILE, time, N)
#endif
      endif

      ifnum = ifnum + 1

    endif

!------- Check end time -----------------------------------
    if( time >= time0 + Tmax ) Exit

!------- Update time --------------------------------------

    time=time+dt/86400.

  END DO
      
!----- End loop --------------------------------------


!----- Write sedeco restart data --------------------------------------
#if defined SEDIMENT_TESTMODE
  OUTFILE=trim(OUTFILE_prefix)//'-sedeco_rst.csv'
  CALL write_sedeco_his_data(OUTFILE,time)
#endif

!----- Close output files --------------------------------------

  CALL files_close

END PROGRAM main
!----------------------------------------------------------------------!

!     End of main program

!-----------------------------------------------------------------------

