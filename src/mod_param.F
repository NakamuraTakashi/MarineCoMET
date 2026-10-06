
!!!=== Copyright (c) 2012-2025 Takashi NAKAMURA  =====

!--------------------------------------------------------------------------------
!
!  Parameter module
!
!--------------------------------------------------------------------------------

#include "cppdefs.h"

MODULE mod_param

  USE mod_marine_comet_param

  implicit none
!
!-----------------------------------------------------------------------
!  Grid nesting parameters.
!-----------------------------------------------------------------------

  real(8) :: time    !(day)
  
  real(8), allocatable :: swrad_data(:)
  real(8), allocatable :: swrad_time(:)
  real(8), allocatable :: dlwrad_data(:)
  real(8), allocatable :: dlwrad_time(:)
  real(8), allocatable :: Tair_data (:)
  real(8), allocatable :: Tair_time (:)
  real(8), allocatable :: Pair_data (:)
  real(8), allocatable :: Pair_time (:)
  real(8), allocatable :: Uwind_data(:)
  real(8), allocatable :: Vwind_data(:)
  real(8), allocatable :: wind_time (:)
  real(8), allocatable :: rain_data (:)
  real(8), allocatable :: rain_time (:)
  real(8), allocatable :: Rh_data   (:)
  real(8), allocatable :: Rh_time   (:)
  real(8), allocatable :: cloud_data(:)
  real(8), allocatable :: cloud_time(:)
  real(8) :: swrad
  real(8) :: dlwrad
  real(8) :: Tair
  real(8) :: Pair
  real(8) :: Uwind
  real(8) :: Vwind
  real(8) :: rain
  real(8) :: Rh
  real(8) :: cloud
  integer :: num_swrad
  integer :: num_dlwrad
  integer :: num_Tair
  integer :: num_Pair
  integer :: num_wind
  integer :: num_rain
  integer :: num_Rh
  integer :: num_cloud 
  
  real(8), allocatable :: PFD_time(:)
  real(8), allocatable :: PFD_data(:)
  real(8) :: PFD
  integer :: num_PFD
  real(8), allocatable :: wtemp_data(:)
  real(8), allocatable :: wtemp_time(:)
  real(8) :: wtemp
  integer :: num_wtemp
  
  real(8), allocatable :: tide_data(:)
  real(8), allocatable :: tide_time(:)
  real(8) :: tide
  integer :: num_tide
  
  real(8), allocatable :: wv_time(:)
  real(8), allocatable :: Hs_data(:)
  real(8), allocatable :: Tp_data(:)
  real(8) :: Hs
  real(8) :: Tp
  integer :: num_wv

  real(8), allocatable :: sgd_data(:)
  real(8), allocatable :: sgd_time(:)
  real(8) :: sgd
  integer :: num_sgd

  real(8), allocatable :: inpH_time(:)
  real(8), allocatable :: inpH_data(:)
  real(8) :: inpH
  integer :: num_inpH
  integer :: inpH_index
  real(8), allocatable :: inDO_time(:)
  real(8), allocatable :: inDO_data(:)
  real(8) :: inDO
  integer :: num_inDO
  integer :: inDO_index
  real(8), allocatable :: inDIC_time(:)
  real(8), allocatable :: inDIC_data(:)
  real(8) :: inDIC
  integer :: num_inDIC
  integer :: inDIC_index
  real(8), allocatable :: inTA_time(:)
  real(8), allocatable :: inTA_data(:)
  real(8) :: inTA
  integer :: num_inTA
  integer :: inTA_index
  real(8), allocatable :: inNH4_time(:)
  real(8), allocatable :: inNH4_data(:)
  real(8) :: inNH4
  integer :: num_inNH4
  integer :: inNH4_index
  real(8), allocatable :: inNOx_time(:)
  real(8), allocatable :: inNOx_data(:)
  real(8) :: inNOx
  integer :: num_inNOx
  integer :: inNOx_index
  real(8), allocatable :: inPO4_time(:)
  real(8), allocatable :: inPO4_data(:)
  real(8) :: inPO4
  integer :: num_inPO4
  integer :: inPO4_index

  integer, parameter :: iswrad  = 1
  integer, parameter :: idlwrad = 2
  integer, parameter :: iTair   = 3
  integer, parameter :: iPair   = 4
  integer, parameter :: iwind   = 5
  integer, parameter :: irain   = 6
  integer, parameter :: iRh     = 7
  integer, parameter :: icloud  = 8
  integer, parameter :: iPFD    = 9
  integer, parameter :: iwtemp  = 10
  integer, parameter :: itide   = 11
  integer, parameter :: iwv     = 12
  integer, parameter :: isgd    = 13
  integer, parameter :: iinpH   = 14
  integer, parameter :: iinDO   = 15
  integer, parameter :: iinDIC  = 16
  integer, parameter :: iinTA   = 17
  integer, parameter :: iinNH4  = 18
  integer, parameter :: iinNOx  = 19
  integer, parameter :: iinPO4  = 20
  
  integer :: id_swrad  = 1
  integer :: id_dlwrad = 1
  integer :: id_Tair   = 1
  integer :: id_Pair   = 1
  integer :: id_wind   = 1
  integer :: id_rain   = 1
  integer :: id_Rh     = 1
  integer :: id_cloud  = 1
  integer :: id_PFD    = 1
  integer :: id_wtemp  = 1
  integer :: id_tide   = 1
  integer :: id_wv     = 1
  integer :: id_sgd    = 1
  integer :: id_iinpH  = 1
  integer :: id_iinDO  = 1
  integer :: id_iinDIC = 1
  integer :: id_iinTA  = 1
  integer :: id_iinNH4 = 1
  integer :: id_iinNOx = 1
  integer :: id_iinPO4 = 1

  real(8), allocatable :: WQ_time(:)
  real(8), allocatable :: TA_data(:)
  real(8), allocatable :: DIC_data(:)
  real(8), allocatable :: DO_data(:)
  integer :: N_WQ
  integer :: i_WQ = 1


  real(8) :: PFDsurf    
  real(8) :: tau        

!  U_0: reference near-bottom current speed (cm s-1), read from the "initial"
!  namelist.  mod_input.F turns it into the bottom shear stress that drives the
!  mass-transfer coefficient S_i, so this is the single knob for flow speed:
!    tau = 0.5 * densSW * Cd * (U_0*0.01)^2   [N m-2]
!  Flow controls coral-seawater exchange and therefore almost everything else -
!  at U_0 = 0 the coelenteron DIC is drawn down 26% and calcification collapses,
!  at 20 cm s-1 the drawdown is 3.6%.  See doc/README.md section 18.
!  Default 5.0 so input files written before this knob existed keep their old
!  behaviour, which was a hard-coded 5 cm s-1.
  real(8) :: U_0 = 5.0d0
  real(8) :: pCO2air    
  real(8) :: U10        
  
  real(8) :: ssfCO2    
  real(8) :: ssCO2flux 
  real(8) :: ssO2flux  
  real(8) :: PFDbott   

  real(8) :: fvol_cre      ! volume flux through the reef crest (m3 m-2 s-1)
  real(8) :: fvol_cha      ! volume flux through the channel(m3 m-2 s-1)
  real(8) :: fvol_pre      ! Precipitation volume flux (m s-1)
!  real(8) :: dw_lwradi     ! Downward longwave radiation (W m-2)
  real(8) :: ereef         ! sea surface elevation on the reef flat (m)
  real(8), parameter :: z_crest = -0.15d0 ! reef crest position (m)
  real(8), parameter :: kvol_cre   = 5.0d-2 ! reef crest conductivity
  real(8), parameter :: kvol_cha = 1.0d-1 ! Channel conductivety
  real(8) :: wave_setup   ! wave setup (m)

  integer :: iTemp                  ! Temperature
  integer :: iSalt                  ! Salinity
  integer :: iSedi                  ! suspended sediment

  integer :: idCrl1                 ! Coral coverage
  integer :: idCrl2                 ! Coral2 coverage
  integer :: idSgrs                 ! Seagrass coverage
  integer :: idAlga                 ! Algal coverage
  integer :: idSand                 ! Sand coverage
  
  integer :: idd13C                 ! d13C of DIC

  integer, allocatable :: idbio(:)  ! Biological tracers
  integer :: iOxyg                  ! Dissolved oxygen concentration
  integer :: iTAlk                  ! Total alkalinity
  integer :: iTIC(N_Csp)                  ! Total inorganic carbon
  integer :: iNO3(N_Nsp)                  ! Nitrate concentration
  integer :: iNH4(N_Nsp)                  ! Ammonium concentration
  integer :: iPO4(N_Psp)                  ! Ammonium concentration
  integer :: iDOC(N_Csp,Ndom)            ! Dissolved organic C-concentration
  integer :: iPOC(N_Csp,Npom)            ! Particulate organic C-concentration
  integer :: iDON(N_Nsp,Ndom)            ! Dissolved organic N-concentration
  integer :: iPON(N_Nsp,Npom)            ! Particulate organic N-concentration
  integer :: iDOP(N_Psp,Ndom)            ! Dissolved organic P-concentration
  integer :: iPOP(N_Psp,Npom)            ! Particulate organic P-concentration
  integer :: iPhyC(N_Csp,Nphy)          ! Phytoplankton1 density
  integer :: iZooC(N_Csp,Nzoo)          ! Zooplankton density
  integer :: iPhyN(N_Nsp,Nphy)          ! Phytoplankton1 density
  integer :: iZooN(N_Nsp,Nzoo)          ! Zooplankton density
  integer :: iPhyP(N_Psp,Nphy)          ! Phytoplankton1 density
  integer :: iZooP(N_Psp,Nzoo)          ! Zooplankton density
  integer :: iPIC(N_Csp,Npim)            ! Particulate inorganic C-concentration
#if defined CARBON_ISOTOPE
  integer :: iT13C                  ! Corbon 13 of total inorganic carbon
  integer :: iDO13C(Ndom)          ! Dissolved organic 13C-concentration
  integer :: iPO13C(Npom)          ! Particulate organic 13C-concentration
  integer :: iPhyt13C(Nphy)       ! Phytoplankton1 13C-concentration
  integer :: iZoop13C(Nzoo)       ! Zooplankton 13C-concentration
  integer :: iPI13C(Npim)          ! Particulate inorganic 13C-concentration
#endif
#if defined NITROGEN_ISOTOPE
  integer :: i15NO3                  ! Nitrogen isotope concentration in Nitrate 
!  integer :: i15NO2                  ! Nitrogen isotope concentration in Nitrite
  integer :: i15NH4                  ! Nitrogen isotope concentration in Ammonium
  integer :: iDO15N(Ndom)          ! Dissolved organic 15N-concentration
  integer :: iPO15N(Npom)          ! Particulate organic 15N-concentration
  integer :: iPhyt15N(Nphy)       ! Phytoplankton 15N-concentration
  integer :: iZoop15N(Nzoo)       ! Zooplankton 15N-concentration
#endif
#if defined COT_STARFISH
  integer :: iCOTe                  ! Eggs of crown-of-thorns starfish
  integer :: iCOTl                  ! Larvae of crown-of-thorns starfish
#endif
#if defined BLUE_TIDE
  integer :: iH2S(N_Ssp)            ! Hydrogen sulfide
  integer :: iS0 (N_Ssp)            ! Elemental sulfur
#endif

  real(8), allocatable :: dz(:,:,:)    
  real(8), allocatable :: z_w(:,:,:)      ! Depth at w-point ((meters, negative); z_w(0)=-h, z_w(N)=0.0 
  real(8), allocatable :: z_r(:,:,:)      ! Depth at r-point ((meters, negative)
  real(8), allocatable :: t(:,:,:,:,:)
  real(8), allocatable :: dtrc_dt(:,:)
  real(8), allocatable :: pH(:,:,:)
  real(8), allocatable :: Warg(:,:,:)
  real(8), allocatable :: Wcal(:,:,:)
#if defined LIGHT_MODEL
  real(8), allocatable :: PFDk(:,:,:)  
#endif
  
  real(8), allocatable :: p_coral(:,:,:)
  real(8), allocatable :: p_sgrass(:,:,:)
  real(8), allocatable :: p_algae(:,:,:)
  real(8), allocatable :: p_sand(:,:)
#if defined AQUACULTURE
  real(8), allocatable :: dens_aqua(:,:,:)
  real(8) :: f_dens
#endif

#if defined SEDECO_SGD && defined SGD_ON
  real(8) :: sgd_flux        ! sumbarine groundwater discharge rate of grid (cm s-1)  
  real(8) :: sgd_Tmp         ! SGD concentration coming in through bottom: Tmp: Temperature (oC)
  real(8) :: sgd_Sal         ! SGD concentration coming in through bottom: Sal: Salinity (PSU)
  real(8) :: sgd_DIC(N_Csp)  ! SGD concentration coming in through bottom: DIC: Total dissolved inorganic carbon (DIC: umol kg-1)
  real(8) :: sgd_TA          ! SGD concentration coming in through bottom: TA : Total alkalinity (TA: umol kg-1)
  real(8) :: sgd_DOx         ! SGD concentration coming in through bottom: DOx: Dissolved oxygen (umol L-1)
  real(8) :: sgd_NO3(N_Nsp)  ! SGD concentration coming in through bottom: NO3: NO3 (umol L-1)
  real(8) :: sgd_NH4(N_Nsp)  ! SGD concentration coming in through bottom: NH4: NH4 (umol L-1)
  real(8) :: sgd_PO4(N_Psp)  ! SGD concentration coming in through bottom: PO4: PO4 (umol L-1)
  real(8) :: sgd_DOC(N_Csp,Ndom)  ! SGD concentration coming in through bottom: DOC: Total dissolved organic carbon (DOC: umol L-1)
  real(8) :: sgd_DON(N_Nsp,Ndom)  ! SGD concentration coming in through bottom: DOC: Total dissolved organic nitrogen (DON: umol L-1)
  real(8) :: sgd_DOP(N_Psp,Ndom)  ! SGD concentration coming in through bottom: DOC: Total dissolved organic phosphrous (DOP: umol L-1)
#endif
#if defined SEDECO_BURIAL
  real(8) :: Fdep_sed        ! Sedimentation rate (cm s-1) (Positive: sedimentation; Negative: erosion)
#endif

contains

!!! **********************************************************************
!!!  Set initial conditions
!!! **********************************************************************

  subroutine initialize_params(LBi, UBi, LBj, UBj, N, Nid)

    USE mod_marine_comet_param
    use mod_geochem
    Use mod_aquaculture
   
    implicit none
! input parameters
    integer, intent(in) :: LBi, UBi, LBj, UBj, N
    integer, intent(out) :: Nid
    real(8)  R13C
    integer i,j,k,nstp,m,isp
!  Local variable declarations JS_edit
!
    integer :: ic

!  Defaults for every variable in the "initial" namelist.
!  Fortran namelist input assigns ONLY the variables that appear in the file and
!  silently leaves the rest at whatever they held before - it is not an error to
!  omit one.  Without an initialiser that means an undefined value: a test with
!  an uninitialised real read back -1.14e+294, and an uninitialised integer read
!  back 0, neither with any diagnostic.  Giving every namelist variable a default
!  here turns an omission from silent corruption into a documented fallback, and
!  lets short .in files leave out what they do not need.  Anything present in the
!  .in file still overrides these, so existing input files behave exactly as before.
!  To catch the remaining cases, build with
!    -finit-real=snan -ffpe-trap=invalid,zero,overflow
!  which makes any use of an uninitialised real abort instead of propagating.
    real(8) :: T0 = 25.0d0, S0 = 34.0d0, Sed1_0 = 0.0d0
    real(8) :: TAlk0 = 2232.0d0, TIC_0 = 1915.0d0, Oxyg0 = 250.0d0
    real(8) :: NO3_0 = 0.2d0, NH4_0 = 0.26d0, PO4_0 = 0.04d0
    real(8) :: DOC_0(Ndom) = 0.0d0, POC_0(Npom) = 0.0d0
    real(8) :: PhyC_0(Nphy) = 0.0d0, ZooC_0(Nzoo) = 0.0d0, PIC_0(Npim) = 0.0d0
!    real(8) :: DON_0(Ndom), PON_0(Npom), PhyN_0(Nphy), ZooN_0(Nzoo)
!    real(8) :: DOP_0(Ndom), POP_0(Npom), PhyP_0(Nphy), ZooP_0(Nzoo)
    real(8) :: d13C_TIC0 = 0.0d0
    real(8) :: d13C_DOC_0(Ndom) = -15.0d0, d13C_POC_0(Npom) = -15.0d0
    real(8) :: d13C_PhyC_0(Nphy) = -15.0d0, d13C_ZooC_0(Nzoo) = -20.0d0
    real(8) :: d13C_PIC_0(Npim) = -5.0d0
    real(8) :: d15N_NO3_0 = 0.7d0, d15N_NH4_0 = 0.7d0
    real(8) :: d15N_DON_0(Ndom) = -15.0d0, d15N_PON_0(Npom) = -15.0d0
    real(8) :: d15N_PhyN_0(Nphy) = -15.0d0, d15N_ZooN_0(Nzoo) = -20.0d0
    real(8) :: p_coral_0(Ncl) = 0.0d0, p_algae_0(Nag) = 0.0d0
    real(8) :: p_sgrass_0(Nsg) = 0.0d0, p_sand_0 = 1.0d0
#ifdef AQUACULTURE
    real(8) :: dens_aqua0(5)
#endif
    namelist/initial/T0, S0, Sed1_0
    namelist/initial/TAlk0, TIC_0, Oxyg0
    namelist/initial/NO3_0, NH4_0, PO4_0
    namelist/initial/DOC_0, POC_0, PhyC_0, ZooC_0, PIC_0
!    namelist/initial/DON_0, PON_0, PhyN_0, ZooN_0
!    namelist/initial/DOP_0, POP_0, PhyP_0, ZooP_0
    namelist/initial/d13C_TIC0, d13C_DOC_0, d13C_POC_0
    namelist/initial/d13C_PhyC_0, d13C_ZooC_0, d13C_PIC_0
    namelist/initial/d15N_NO3_0, d15N_NH4_0, d15N_DON_0, d15N_PON_0
    namelist/initial/d15N_PhyN_0, d15N_ZooN_0
    namelist/initial/p_coral_0, p_algae_0, p_sgrass_0, p_sand_0
    namelist/initial/U_0
#ifdef AQUACULTURE
    namelist/aquaculture_config/dens_aqua0
    namelist/aquaculture_config/f_dens
#endif

    rewind(5)
    read (5, nml=initial)
#ifdef AQUACULTURE
    rewind(5)
    read (5, nml=aquaculture_config)
#endif

    inpH_index = 1
    inDO_index = 1
    inDIC_index = 1
    inTA_index = 1
    inNH4_index = 1
    inNOx_index = 1
    inPO4_index = 1

!
!-----------------------------------------------------------------------
!  Initialize tracer identification indices.
!-----------------------------------------------------------------------
!
    ic=0

    i=1
    iTemp=ic+i
    i=i+1
    iSalt=ic+i

    i=i+1
    iSedi=ic+i

! REEF_ECOSYS parameter IDs
    i=i+1
    iOxyg=ic+i
    i=i+1
    iTAlk=ic+i
    DO isp=1,N_Csp     
      i=i+1
      iTIC(isp)=ic+i
    END DO       
    DO isp=1,N_Nsp
      i=i+1     
      iNO3(isp)=ic+i
    END DO       
    DO isp=1,N_Nsp
      i=i+1    
      iNH4(isp)=ic+i       
    END DO       
    DO isp=1,N_Psp     
      i=i+1    
      iPO4(isp)=ic+i       
    END DO
    DO m=1,Ndom    
      DO isp=1,N_Csp     
        i=i+1    
        iDOC(isp,m)=ic+i
      END DO
    END DO 
    DO m=1,Ndom    
      DO isp=1,N_Nsp     
        i=i+1    
        iDON(isp,m)=ic+i 
      END DO
    END DO 
    DO m=1,Ndom    
      DO isp=1,N_Psp     
        i=i+1    
        iDOP(isp,m)=ic+i  
      END DO
    END DO 
    DO m=1,Npom    
      DO isp=1,N_Csp     
        i=i+1    
        iPOC(isp,m)=ic+i  
      END DO
    END DO 
    DO m=1,Npom    
      DO isp=1,N_Nsp     
        i=i+1    
        iPON(isp,m)=ic+i  
      END DO
    END DO 
    DO m=1,Npom    
      DO isp=1,N_Psp     
        i=i+1    
        iPOP(isp,m)=ic+i  
      END DO
    END DO 
    DO m=1,Nphy    
      DO isp=1,N_Csp     
        i=i+1    
        iPhyC(isp,m)=ic+i
      END DO
    END DO 
    DO m=1,Nphy    
      DO isp=1,N_Nsp     
        i=i+1    
        iPhyN(isp,m)=ic+i
      END DO
    END DO 
    DO m=1,Nphy    
      DO isp=1,N_Psp     
        i=i+1    
        iPhyP(isp,m)=ic+i
      END DO
    END DO 
    DO m=1,Nzoo    
      DO isp=1,N_Csp     
        i=i+1    
        iZooC(isp,m)=ic+i
      END DO
    END DO 
    DO m=1,Nzoo    
      DO isp=1,N_Nsp     
        i=i+1    
        iZooN(isp,m)=ic+i
      END DO
    END DO 
    DO m=1,Nzoo    
      DO isp=1,N_Psp     
        i=i+1    
        iZooP(isp,m)=ic+i
      END DO
    END DO 
    DO m=1,Npim    
      DO isp=1,N_Csp     
        i=i+1    
        iPIC(isp,m)=ic+i 
      END DO
    END DO 
#if defined COT_STARFISH
    i=i+1
    iCOTe=ic+i
    i=i+1
    iCOTl=ic+i
#endif
#if defined BLUE_TIDE
    DO isp=1,N_Ssp
      i=i+1
      iH2S(isp)=ic+i
    END DO
    DO isp=1,N_Ssp
      i=i+1
      iS0(isp)=ic+i
    END DO
#endif


!-----------------------------------------------------------------------
!  Determine number of biological tracers.
!-----------------------------------------------------------------------

    Nid=i
!---------------------------------------------------------------------


   allocate( dz (LBi:UBi,LBj:UBj,N) )
   allocate( z_w(LBi:UBi,LBj:UBj,0:N) )
   allocate( z_r(LBi:UBi,LBj:UBj,1:N) )

   allocate( t(LBi:UBi, LBj:UBj, N, 1, Nid) , &
             dtrc_dt(N, Nid)   )
   allocate( pH(LBi:UBi, LBj:UBj, N) )
   allocate( Warg(LBi:UBi, LBj:UBj, N) )
   allocate( Wcal(LBi:UBi, LBj:UBj, N) )
#if defined LIGHT_MODEL
   allocate( PFDk(LBi:UBi, LBj:UBj, N) )
#endif
   
   allocate( p_coral (2,LBi:UBi, LBj:UBj) , &  !!! To be updated... !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
             p_sgrass(1,LBi:UBi, LBj:UBj) , &  !!! To be updated... !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
             p_sand  (LBi:UBi, LBj:UBj) ,   &
             p_algae (1,LBi:UBi, LBj:UBj)   )  !!! To be updated... !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 

#if defined AQUACULTURE
   allocate( dens_aqua(Naq,LBi:UBi, LBj:UBj) )
#endif

!-----------------------------------------------------------------------
!  Set initial conditions
!-----------------------------------------------------------------------
    nstp=1
    t(:,:,:,:,:) = 0.0d0 ! Initialize all tracers to zero

    do j=LBj,UBj
      do i=LBi,UBi
        do k=1,N
        
          t(i,j,k,nstp,iTemp) = T0       
          t(i,j,k,nstp,iSalt) = S0

          t(i,j,k,nstp,iSedi) = Sed1_0    !Sediment concentration (g m-3) 0.e0, 1.e0

!          t(i,j,k,nstp,iOxyg) = Oxyg0      !DO  (umol L-1)
          t(i,j,k,nstp,iOxyg) = O2satu(t(i,j,k,nstp,iTemp)+273.15d0, t(i,j,k,nstp,iSalt))
          t(i,j,k,nstp,iTAlk) = TAlk0 *1.024d0      !TA  (umol L-1) 2232.0d0 2275.0d0, 2500.0d0, 2150.0d0, 2000.0d0, 1800.0d0, 1700.0d0, 1600.0d0 
          t(i,j,k,nstp,iTIC(iCt)) = TIC_0 *1.024d0  !DIC (umol L-1) 1915.0d0 1930.0d0, 1700.0d0, 2100.0d0, 2300.0d0, 2500.0d0, 2700.0d0, 3000.0d0 
          t(i,j,k,nstp,iNO3(iNt)) = NO3_0      !NO3  (umol L-1)  0.5d0, 10.0d0 control0.2d0 N1.8d0 N*2 3.5d0
          t(i,j,k,nstp,iNH4(iNt)) = NH4_0      !NH4  (umol L-1) 
          t(i,j,k,nstp,iPO4(iPt)) = PO4_0      !PO4  (umol L-1) 0.03d0 0.05d0, 2.0d0 control0.04d0 P0.2d0
          DO m=1,Ndom
            t(i,j,k,nstp,iDOC(iCt,m)) = DOC_0(m)       !DOC  (umol L-1) 
!            t(i,j,k,nstp,iDON(iNt,m)) = DON_0(m)     !DON  (umol L-1) 
!            t(i,j,k,nstp,iDOP(iPt,m)) = DOP_0(m)     !DOP  (umol L-1) 
            t(i,j,k,nstp,iDON(iNt,m)) = DOC_0(m)*16d0/106d0     !DON  (umol L-1) 
            t(i,j,k,nstp,iDOP(iPt,m)) = DOC_0(m)/106d0     !DOP  (umol L-1) 
          END DO
          DO m=1,Npom
            t(i,j,k,nstp,iPOC(iCt,m)) = POC_0(m)       !POC  (umol L-1) 
!            t(i,j,k,nstp,iPON(iNt,m)) = PON_0(m)     !PON  (umol L-1) 
!            t(i,j,k,nstp,iPOP(iPt,m)) = POP_0(m)      !POP  (umol L-1) 
            t(i,j,k,nstp,iPON(iNt,m)) = POC_0(m)*16d0/106d0     !PON  (umol L-1) 
            t(i,j,k,nstp,iPOP(iPt,m)) = POC_0(m)/106d0      !POP  (umol L-1) 
          END DO

#if defined CPOM_TRACERS
          ! ***CPOM TRACER TEST****
          t(i,j,k,nstp,iPOC(iC13,iCPOM)) = POC_0(iCPOM)       !POC  (umol L-1) 
          t(i,j,k,nstp,iPON(iN15,iCPOM)) = POC_0(iCPOM)*16d0/106d0     !PON  (umol L-1) 
          t(i,j,k,nstp,iPOP(iP1, iCPOM)) = POC_0(iCPOM)/106d0      !POP  (umol L-1)
#endif
          DO m=1,Nphy
            t(i,j,k,nstp,iPhyC(iCt,m)) = PhyC_0(m)     !Phytoplankton1 0.3(umolC L-1) all0.561 0.746-gC/gchla-1h 2.23-gC/gchla-30 4.47-gC/gchla-60	others
!            t(i,j,k,nstp,iPhyN(iNt,m)) = PhyN_0(m)     !Phytoplankton1 0.3(umolC L-1) all0.561 0.746-gC/gchla-1h 2.23-gC/gchla-30 4.47-gC/gchla-60	others
!            t(i,j,k,nstp,iPhyP(iPt,m)) = PhyP_0(m)     !Phytoplankton1 0.3(umolC L-1) all0.561 0.746-gC/gchla-1h 2.23-gC/gchla-30 4.47-gC/gchla-60	others
            t(i,j,k,nstp,iPhyN(iNt,m)) = PhyC_0(m)*rNCp(m)     !Phytoplankton1 0.3(umolC L-1) all0.561 0.746-gC/gchla-1h 2.23-gC/gchla-30 4.47-gC/gchla-60	others
            t(i,j,k,nstp,iPhyP(iPt,m)) = PhyC_0(m)*rPCp(m)     !Phytoplankton1 0.3(umolC L-1) all0.561 0.746-gC/gchla-1h 2.23-gC/gchla-30 4.47-gC/gchla-60	others
          END DO
          DO m=1,Nzoo
            t(i,j,k,nstp,iZooC(iCt,m)) = ZooC_0(m)     !Zooplankton (umol L-1)1.3
!            t(i,j,k,nstp,iZooN(iNt,m)) = ZooN_0(m)     !Zooplankton (umol L-1)1.3
!            t(i,j,k,nstp,iZooP(iPt,m)) = ZooP_0(m)     !Zooplankton (umol L-1)1.3
            t(i,j,k,nstp,iZooN(iNt,m)) = ZooC_0(m)*rNCz(m)     !Zooplankton (umol L-1)1.3
            t(i,j,k,nstp,iZooP(iPt,m)) = ZooC_0(m)*rPCz(m)     !Zooplankton (umol L-1)1.3
          END DO
          DO m=1,Npim
            t(i,j,k,nstp,iPIC (iCt,m)) = PIC_0 (m)     !Particulated inorganic carbon (umol L-1)1.3
          END DO
          t(i,j,k,nstp,iPIC (iCt,iLive)) = PhyC_0(iCcl)*rCaCp(iCcl)     !Particulated inorganic carbon (umol L-1)

#if defined CARBON_ISOTOPE
          t(i,j,k,nstp,iTIC(iC13)) = Ci_from_Ct_delta(t(i,j,k,nstp,iTIC(iCt)), d13C_TIC0, R13C_VPDB) !DI13C (umol L-1)
          DO m=1,Ndom
            t(i,j,k,nstp,iDOC(iC13,m)) = Ci_from_Ct_delta(t(i,j,k,nstp,iDOC(iCt,m)), d13C_DOC_0(m), R13C_VPDB)       !DOC  (umol L-1) 
          END DO
          DO m=1,Npom
            t(i,j,k,nstp,iPOC(iC13,m)) = Ci_from_Ct_delta(t(i,j,k,nstp,iPOC(iCt,m)), d13C_POC_0(m), R13C_VPDB)       !POC  (umol L-1) 
          END DO
          DO m=1,Nphy
            t(i,j,k,nstp,iPhyC(iC13,m)) = Ci_from_Ct_delta(t(i,j,k,nstp,iPhyC(iCt,m)), d13C_PhyC_0(m), R13C_VPDB)       !Phytoplankton  (umol L-1) 
          END DO
          DO m=1,Nzoo
            t(i,j,k,nstp,iZooC(iC13,m)) = Ci_from_Ct_delta(t(i,j,k,nstp,iZooC(iCt,m)), d13C_ZooC_0(m), R13C_VPDB)       !Zooplankton  (umol L-1) 
          END DO
          DO m=1,Npim
            t(i,j,k,nstp,iPIC(iC13,m)) = Ci_from_Ct_delta(t(i,j,k,nstp,iPIC(iCt,m)), d13C_PIC_0(m), R13C_VPDB)       !PIC  (umol L-1) 
          END DO
#endif
!!!!!!!!!!!!
#if defined NITROGEN_ISOTOPE            
!!!!!!!!!!!!
          t(i,j,k,nstp,i15NO3) =  0.2d0       !NO3  (umol L-1)  0.5d0, 10.0d0 control0.2d0 N1.8d0 N*2 3.5d0
          t(i,j,k,nstp,i15NH4) =  0.26d0       !NH4  (umol L-1) 

          t(i,j,k,nstp,iDO15N(1)) =   1.0d0 !3.0d0       !DON  (umol L-1) 
          t(i,j,k,nstp,iDO15N(2)) =  10.0d0 !3.0d0       !DON  (umol L-1) 
          t(i,j,k,nstp,iPO15N(1)) =  0.06d0 !0.05d0      !PON  (umol L-1) 
          t(i,j,k,nstp,iPO15N(2)) =  0.6d0 !0.05d0      !PON  (umol L-1) 
          t(i,j,k,nstp,iPhyt15N(1)) = 0.0d0     !Phytoplankton1 0.3(umolC L-1) all0.561 0.746-gC/gchla-1h 2.23-gC/gchla-30 4.47-gC/gchla-60	others
          t(i,j,k,nstp,iPhyt15N(2)) = 0.0d0       !Phytoplankton2 0.3(umolC L-1) 							diatom
          t(i,j,k,nstp,iPhyt15N(3)) = 0.0d0       !Phytoplankton2 0.3(umolC L-1) 							diatom
          t(i,j,k,nstp,iZoop15N(1)) = 0.0d0       !Zooplankton (umol L-1)1.3
#endif
#if defined COT_STARFISH
          t(i,j,k,nstp,iCOTe) =  0.0d0       !COTS eggs (umol L-1)
          t(i,j,k,nstp,iCOTl) =  0.0d0       !COTS larvae (umol L-1)
#endif
#if defined BLUE_TIDE
          t(i,j,k,nstp,iH2S(:)) = 0.0d0      !H2S (umol S L-1)
          t(i,j,k,nstp,iS0 (:)) = 0.0d0      !S0  (umol S L-1)
#endif
        enddo
          
#if defined CHAMBER_SITE4
        p_coral(1,i,j) = 0.208d0  ! Site4: 0.208d0, Site5: 0.265d0, Site6: 0.37d0, Site7: 0.231d0
        p_coral(2,i,j) = 0.0d0    ! Site9: 0.412d0, Site10: 0.486d0
        p_sand(i,j)  = 1.0d0-p_coral(1,i,j)
#elif defined CHAMBER_SITE5
        p_coral(1,i,j) = 0.265d0  ! Site4: 0.208d0, Site5: 0.265d0, Site6: 0.37d0, Site7: 0.231d0
        p_coral(2,i,j) = 0.0d0    ! Site9: 0.412d0, Site10: 0.486d0
        p_sand(i,j)  = 1.0d0-p_coral(1,i,j)
#elif defined CHAMBER_SITE6
        p_coral(1,i,j) = 0.37d0  ! Site4: 0.208d0, Site5: 0.265d0, Site6: 0.37d0, Site7: 0.231d0
        p_coral(2,i,j) = 0.0d0    ! Site9: 0.412d0, Site10: 0.486d0
        p_sand(i,j)  = 1.0d0-p_coral(1,i,j)
#elif defined CHAMBER_SITE7
        p_coral(1,i,j) = 0.231d0  ! Site4: 0.208d0, Site5: 0.265d0, Site6: 0.37d0, Site7: 0.231d0
        p_coral(2,i,j) = 0.0d0    ! Site9: 0.412d0, Site10: 0.486d0
        p_sand(i,j)  = 1.0d0-p_coral(1,i,j)
#elif defined CHAMBER_SITE9
        p_coral(1,i,j) = 0.0d0  ! Site4: 0.208d0, Site5: 0.265d0, Site6: 0.37d0, Site7: 0.231d0
        p_coral(2,i,j) = 0.412d0    ! Site9: 0.412d0, Site10: 0.486d0
        p_sand(i,j)  = 0.0d0
#elif defined CHAMBER_SITE10
        p_coral(1,i,j) = 0.0d0  ! Site4: 0.208d0, Site5: 0.265d0, Site6: 0.37d0, Site7: 0.231d0
        p_coral(2,i,j) = 0.486d0    ! Site9: 0.412d0, Site10: 0.486d0
        p_sand(i,j)  = 0.0d0

#else
        p_coral(1,i,j) = p_coral_0(1)
        p_coral(2,i,j) = p_coral_0(2)
        p_sand(i,j)  = p_sand_0
#endif
        p_algae(1,i,j) = p_algae_0(1)
        p_sgrass(1,i,j)= p_sgrass_0(1)

#if defined AQUACULTURE
        dens_aqua(1,i,j)= dens_aqua0(1)
        dens_aqua(2,i,j)= dens_aqua0(2)
        dens_aqua(3,i,j)= dens_aqua0(3)
        dens_aqua(4,i,j)= dens_aqua0(4)
#endif

        
      enddo
    enddo
    
    ereef = 0.0d0

    return
  end subroutine initialize_params

END MODULE mod_param

