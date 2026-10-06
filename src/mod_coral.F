
!!!=== Copyright (c) 2012-2026 Takashi NAKAMURA  =====

#include "cppdefs.h"

!!!**** MODULE OF CORAL POLYP MODEL ************************************

MODULE mod_coral
#if defined CORAL_POLYP
  implicit none

  TYPE T_CORAL

    real(8), pointer :: Pg(:,:,:) 
    real(8), pointer :: R (:,:,:) 
    real(8), pointer :: G (:,:,:) 
    real(8), pointer :: TAcal(:,:,:) 
    real(8), pointer :: TAcoe(:,:,:) 
    real(8), pointer :: DICcal(:,:,:,:)
    real(8), pointer :: DICcoe(:,:,:,:)
    real(8), pointer :: DOcoe(:,:,:) 
    real(8), pointer :: QCe(:,:,:,:)
    real(8), pointer :: QCv(:,:,:,:)
    real(8), pointer :: QCr(:,:,:,:)
    real(8), pointer :: QCh(:,:,:,:)
    real(8), pointer :: QCext(:,:,:,:)
    real(8), pointer :: CO2cal(:,:,:,:)
    real(8), pointer :: CO2coe(:,:,:,:)
# if defined CORAL_NUTRIENTS
!  Nutrients dynamics
    real(8), pointer :: NO3(:,:,:,:)
    real(8), pointer :: NH4(:,:,:,:)
    real(8), pointer :: PO4(:,:,:,:)
    real(8), pointer :: QNe(:,:,:,:)
    real(8), pointer :: QNv(:,:,:,:)
    real(8), pointer :: QNr(:,:,:,:)
    real(8), pointer :: QNh(:,:,:,:)
    real(8), pointer :: QPe(:,:,:,:)
    real(8), pointer :: QPv(:,:,:,:)
    real(8), pointer :: QPr(:,:,:,:)
    real(8), pointer :: QPh(:,:,:,:)
    real(8), pointer :: QNext(:,:,:,:)
    real(8), pointer :: QPext(:,:,:,:)
# endif
# if defined CORAL_ZOOXANTHELLAE
    real(8), pointer :: ROS(:,:,:)
# endif
# if defined CORAL_SIZE_DYNAMICS
    real(8), pointer :: growth(:,:,:)  ! growth rate
    real(8), pointer :: mort(:,:,:)  ! mortaliny rate
!    real(8), pointer :: dsed_coral(:,:,:)
# endif
  END TYPE T_CORAL

!-----------------------------------------------------------------------
# if defined CORAL_ZOOXANTHELLAE
!  zooxanthellae dynamics

  TYPE T_ZOOX

    real(8), pointer :: Pg(:,:,:) 
    real(8), pointer :: R (:,:,:) 
    real(8), pointer :: dens(:,:,:)
    real(8), pointer :: QCe(:,:,:,:)
    real(8), pointer :: QCv(:,:,:,:)
    real(8), pointer :: QCr(:,:,:,:)
    real(8), pointer :: QCh(:,:,:,:)
!  Photoinihibition model
    real(8), pointer :: QAo(:,:,:)
    real(8), pointer :: QAr(:,:,:)
    real(8), pointer :: QAi(:,:,:)
    real(8), pointer :: Chl(:,:,:)
    real(8), pointer :: SOx(:,:,:)
    real(8), pointer :: NADPHn(:,:,:)
    real(8), pointer :: RuBPn(:,:,:)
#  if defined CORAL_NUTRIENTS
    real(8), pointer :: QNe(:,:,:,:)
    real(8), pointer :: QNv(:,:,:,:)
    real(8), pointer :: QNr(:,:,:,:)
    real(8), pointer :: QNh(:,:,:,:)
    real(8), pointer :: QPe(:,:,:,:)
    real(8), pointer :: QPv(:,:,:,:)
    real(8), pointer :: QPr(:,:,:,:)
    real(8), pointer :: QPh(:,:,:,:)
    real(8), pointer :: NO3(:,:,:,:)
    real(8), pointer :: NH4(:,:,:,:)
    real(8), pointer :: PO4(:,:,:,:)
#  endif
  END TYPE T_ZOOX
# endif

  TYPE (T_CORAL), allocatable :: CORAL(:)
# if defined CORAL_ZOOXANTHELLAE
  TYPE (T_ZOOX), allocatable :: ZOOX(:)
# endif


CONTAINS


!!! **********************************************************************
!!!  allocate variables for coral polyp model (Nakamura et al. 2013)
!!! **********************************************************************

  SUBROUTINE allocate_coral(ng, Ngrids, LBi, UBi, LBj, UBj)

    USE mod_marine_comet_param

    implicit none
! input parameters
    integer, intent(in) :: ng, Ngrids, LBi, UBi, LBj, UBj

    IF (ng.eq.1) allocate ( CORAL(Ngrids) )

    allocate( CORAL(ng)%Pg(Ncl,LBi:UBi,LBj:UBj)     )
    allocate( CORAL(ng)%R (Ncl,LBi:UBi,LBj:UBj)     )
    allocate( CORAL(ng)%G (Ncl,LBi:UBi,LBj:UBj)     )
    allocate( CORAL(ng)%TAcal(Ncl,LBi:UBi,LBj:UBj)     )
    allocate( CORAL(ng)%TAcoe(Ncl,LBi:UBi,LBj:UBj)     )
    allocate( CORAL(ng)%DICcal(N_Csp,Ncl,LBi:UBi,LBj:UBj) )
    allocate( CORAL(ng)%DICcoe(N_Csp,Ncl,LBi:UBi,LBj:UBj) )
    allocate( CORAL(ng)%DOcoe(Ncl,LBi:UBi,LBj:UBj)     )
    allocate( CORAL(ng)%QCe(N_Csp,Ncl,LBi:UBi,LBj:UBj)     )
    allocate( CORAL(ng)%QCv(N_Csp,Ncl,LBi:UBi,LBj:UBj)     )
    allocate( CORAL(ng)%QCr(N_Csp,Ncl,LBi:UBi,LBj:UBj)     )
    allocate( CORAL(ng)%QCh(N_Csp,Ncl,LBi:UBi,LBj:UBj)     )
    allocate( CORAL(ng)%QCext(N_Csp,Ncl,LBi:UBi,LBj:UBj)   )
    allocate( CORAL(ng)%CO2cal(N_Csp,Ncl,LBi:UBi,LBj:UBj) )
    allocate( CORAL(ng)%CO2coe(N_Csp,Ncl,LBi:UBi,LBj:UBj) )
# if defined CORAL_NUTRIENTS
    allocate( CORAL(ng)%NO3(N_Nsp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( CORAL(ng)%NH4(N_Nsp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( CORAL(ng)%PO4(N_Psp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( CORAL(ng)%QNe(N_Nsp,Ncl,LBi:UBi,LBj:UBj)   )
    allocate( CORAL(ng)%QNv(N_Nsp,Ncl,LBi:UBi,LBj:UBj)   )
    allocate( CORAL(ng)%QNr(N_Nsp,Ncl,LBi:UBi,LBj:UBj)   )
    allocate( CORAL(ng)%QNh(N_Nsp,Ncl,LBi:UBi,LBj:UBj)   )
    allocate( CORAL(ng)%QPe(N_Psp,Ncl,LBi:UBi,LBj:UBj)   )
    allocate( CORAL(ng)%QPv(N_Psp,Ncl,LBi:UBi,LBj:UBj)   )
    allocate( CORAL(ng)%QPr(N_Psp,Ncl,LBi:UBi,LBj:UBj)   )
    allocate( CORAL(ng)%QPh(N_Psp,Ncl,LBi:UBi,LBj:UBj)   )
    allocate( CORAL(ng)%QNext(N_Nsp,Ncl,LBi:UBi,LBj:UBj) )
    allocate( CORAL(ng)%QPext(N_Psp,Ncl,LBi:UBi,LBj:UBj) )
# endif     
# if defined CORAL_ZOOXANTHELLAE
    allocate( CORAL(ng)%ROS(Ncl,LBi:UBi,LBj:UBj)  )
# endif
# if defined CORAL_SIZE_DYNAMICS
    allocate( CORAL(ng)%growth(Ncl,LBi:UBi,LBj:UBj)   )
    allocate( CORAL(ng)%mort(Ncl,LBi:UBi,LBj:UBj)   )
# endif

# if defined CORAL_ZOOXANTHELLAE
    IF (ng.eq.1) allocate ( ZOOX(Ngrids) )
    allocate( ZOOX(ng)%Pg(Ncl,LBi:UBi,LBj:UBj)     )
    allocate( ZOOX(ng)%R (Ncl,LBi:UBi,LBj:UBj)     )

    allocate( ZOOX(ng)%dens(Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%QCe(N_Csp,Ncl,LBi:UBi,LBj:UBj)    )
    allocate( ZOOX(ng)%QCv(N_Csp,Ncl,LBi:UBi,LBj:UBj)    )
    allocate( ZOOX(ng)%QCr(N_Csp,Ncl,LBi:UBi,LBj:UBj)    )
    allocate( ZOOX(ng)%QCh(N_Csp,Ncl,LBi:UBi,LBj:UBj)    )
    allocate( ZOOX(ng)%QAo(Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%QAr(Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%QAi(Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%Chl(Ncl,LBi:UBi,LBj:UBj)   )
    allocate( ZOOX(ng)%SOx(Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%NADPHn(Ncl,LBi:UBi,LBj:UBj) )
    allocate( ZOOX(ng)%RuBPn(Ncl,LBi:UBi,LBj:UBj)  )
#  if defined CORAL_NUTRIENTS
    allocate( ZOOX(ng)%NO3(N_Nsp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%NH4(N_Nsp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%PO4(N_Psp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%QNe(N_Nsp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%QNv(N_Nsp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%QNr(N_Nsp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%QNh(N_Nsp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%QPe(N_Psp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%QPv(N_Psp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%QPr(N_Psp,Ncl,LBi:UBi,LBj:UBj)  )
    allocate( ZOOX(ng)%QPh(N_Psp,Ncl,LBi:UBi,LBj:UBj)  )
#  endif
# endif

    RETURN

  END SUBROUTINE allocate_coral


!!! **********************************************************************
!!!  set initial conditions for coral polyp model (Nakamura et al. 2013)
!!! **********************************************************************

  SUBROUTINE initialize_coral(ng, LBi, UBi, LBj, UBj, start_of_new_run)

    USE mod_marine_comet_param
    USE mod_geochem
    
    implicit none
! input parameters
    integer, intent(in) :: ng, LBi, UBi, LBj, UBj
    logical, intent(in) :: start_of_new_run               ! TRUE = initialize coral, seagass, macroalgae, sediment from start; FALSE = continue from previous run
    real(8)  R13C
    real(8)  QAt
    integer i,j,n

!  Set initial conditions
    do j=LBj,UBj
      do i=LBi,UBi
        do n=1,Ncl
!      coral internal conditions
          CORAL(ng)%Pg(n,i,j)=0.d0
          CORAL(ng)%R (n,i,j)=0.d0
          CORAL(ng)%G (n,i,j)=0.d0
# if defined CORAL_SIZE_DYNAMICS
          CORAL(ng)%growth(n,i,j) = 0.0d0
          CORAL(ng)%mort(n,i,j) = 0.0d0
# endif
# if defined CORAL_ZOOXANTHELLAE
          ZOOX(ng)%Pg(n,i,j)=0.d0
          ZOOX(ng)%R (n,i,j)=0.d0
# endif
        enddo
      enddo
    enddo

! analytical start
    if( start_of_new_run ) then
      do j=LBj,UBj
        do i=LBi,UBi
          do n=1,Ncl
            CORAL(ng)%DICcal(:,n,i,j) = 0.0d0
            CORAL(ng)%DICcoe(:,n,i,j) = 0.0d0
            CORAL(ng)%CO2cal(:,n,i,j) = 0.0d0
            CORAL(ng)%CO2coe(:,n,i,j) = 0.0d0
            CORAL(ng)%QCe   (:,n,i,j) = 0.0d0
            CORAL(ng)%QCv   (:,n,i,j) = 0.0d0
            CORAL(ng)%QCr   (:,n,i,j) = 0.0d0
            CORAL(ng)%QCh   (:,n,i,j) = 0.0d0
            CORAL(ng)%QCext (:,n,i,j) = 0.0d0

!      coral internal conditions
            CORAL(ng)%TAcal (n,i,j)=2500.d0 *1.024d0 !(umol/L)
            CORAL(ng)%TAcoe (n,i,j)=2150.d0 *1.024d0 !(umol/L)
            CORAL(ng)%DOcoe (n,i,j)=120.d0 !(umol/L)

            CORAL(ng)%DICcal(iCt,n,i,j)=2000.d0 *1.024d0 !(umol/L)
            CORAL(ng)%DICcoe(iCt,n,i,j)=1950.d0 *1.024d0 !(umol/L)
!            CORAL(ng)%QC (n,i,j)=15.d0 !450 ug/cm2 = 15 umol cm-2 -> 5.e6 umol kg-1 
            CORAL(ng)%QCe   (iCt,n,i,j)=15.0d0 !290.d0 ! (umolC/cm2)
            CORAL(ng)%QCv   (iCt,n,i,j)=290.0d0 !290.d0 ! (umolC/cm2) Tanaka et al. 2018
            CORAL(ng)%QCr   (iCt,n,i,j)=0.0d0 !290.d0 ! (umolC/cm2)
            CORAL(ng)%QCh   (iCt,n,i,j)=0.0d0 !290.d0 ! (umolC/cm2)
                          ! QC0=250.0d0
            CORAL(ng)%CO2cal(iCt,n,i,j)= 9.d0
            CORAL(ng)%CO2coe(iCt,n,i,j)=33.d0

# if defined CARBON_ISOTOPE || defined CLUMPED_ISOTOPE
!   -14.0 permil: the equilibrium tissue d13C for aC_phot = 17 permil.  At steady
!   state F_Crest*R_QCe = (F_Cdec + F_Cmob)*R_QCv exactly, so the structural pool
!   converges on the reserve; the reserve sits at -14.00 with eps_phot = 17 and
!   the measured means are -13.8 (host) and -14.1 (symbiont, Nahon et al. 2013).
!   The previous -16.5 was itself read back off an earlier equilibrium and is now
!   stale.  It matters because k_decay = 4.8d-8 gives QCv a 259 d turnover, so a
!   badly placed initial value is dragged through a whole year of simulation.
            CORAL(ng)%QCe   (iC13,n,i,j)   &
                      = Ci_from_Ct_delta( CORAL(ng)%QCe   (iCt,n,i,j), -14.5d0, R13C_VPDB )
            CORAL(ng)%QCv   (iC13,n,i,j)   &
                      = Ci_from_Ct_delta( CORAL(ng)%QCv   (iCt,n,i,j), -14.5d0, R13C_VPDB )
            CORAL(ng)%QCr   (iC13,n,i,j)   &
                      = Ci_from_Ct_delta( CORAL(ng)%QCr   (iCt,n,i,j), -14.5d0, R13C_VPDB )
            CORAL(ng)%QCh   (iC13,n,i,j)   &
                      = Ci_from_Ct_delta( CORAL(ng)%QCh   (iCt,n,i,j), -14.5d0, R13C_VPDB )
            CORAL(ng)%DICcoe(iC13,n,i,j)   &
                      = Ci_from_Ct_delta( CORAL(ng)%DICcoe(iCt,n,i,j),  0.0d0, R13C_VPDB )
            CORAL(ng)%DICcal(iC13,n,i,j)   &
                      = Ci_from_Ct_delta( CORAL(ng)%DICcal(iCt,n,i,j),  0.0d0, R13C_VPDB )
            CORAL(ng)%CO2cal(iC13,n,i,j)   &
                      = Ci_from_Ct_delta( CORAL(ng)%CO2cal(iCt,n,i,j),  -8.d0, R13C_VPDB )
            CORAL(ng)%CO2coe(iC13,n,i,j)   &
                      = Ci_from_Ct_delta( CORAL(ng)%CO2coe(iCt,n,i,j),  -8.d0, R13C_VPDB )
#  if defined CLUMPED_ISOTOPE
            CORAL(ng)%QCe   (iD47,n,i,j) = ????
            CORAL(ng)%QCv   (iD47,n,i,j) = ????
            CORAL(ng)%QCr   (iD47,n,i,j) = ????
            CORAL(ng)%QCh   (iD47,n,i,j) = ????
            CORAL(ng)%DICcoe(iD47,n,i,j) = ????
            CORAL(ng)%DICcal(iD47,n,i,j) = ????
            CORAL(ng)%CO2cal(iD47,n,i,j) = ????
            CORAL(ng)%CO2coe(iD47,n,i,j) = ????
#  endif
# endif
# if defined CORAL_ZOOXANTHELLAE
            CORAL(ng)%ROS(n,i,j) = 2.08 !0.0d0
# endif
# if defined CORAL_NUTRIENTS
            CORAL(ng)%NO3(  :,n,i,j) = 0.0d0  !!!!!!!!!!!!!!!!!!!!!!!!!!
            CORAL(ng)%NH4(  :,n,i,j) = 0.0d0  !!!!!!!!!!!!!!!!!!!!!!!!!!
            CORAL(ng)%QNe(  :,n,i,j) = 0.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
            CORAL(ng)%QNv(  :,n,i,j) = 0.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
            CORAL(ng)%QNr(  :,n,i,j) = 0.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
            CORAL(ng)%QNh(  :,n,i,j) = 0.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1

            CORAL(ng)%NO3(iNt,n,i,j) = 0.0d0  !!!!!!!!!!!!!!!!!!!!!!!!!!
            CORAL(ng)%NH4(iNt,n,i,j) = 0.0d0  !!!!!!!!!!!!!!!!!!!!!!!!!!
            CORAL(ng)%QNe(iNt,n,i,j) = CORAL(ng)%QCe(iCt,n,i,j) *16.0d0/106.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
            CORAL(ng)%QNv(iNt,n,i,j) = CORAL(ng)%QCv(iCt,n,i,j) *16.0d0/106.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
            CORAL(ng)%QNr(iNt,n,i,j) = CORAL(ng)%QCr(iCt,n,i,j) *16.0d0/106.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
            CORAL(ng)%QNh(iNt,n,i,j) = CORAL(ng)%QCh(iCt,n,i,j) *16.0d0/106.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
#  if defined NITROGEN_ISOTOPE
            CORAL(ng)%NO3(iN15,n,i,j)  &
                  = Ci_from_Ct_delta( CORAL(ng)%NO3(iNt,n,i,j), 5.d0, R15N_AIR )  !!!??????????????????????????????
            CORAL(ng)%NH4(iN15,n,i,j)  &
                  = Ci_from_Ct_delta( CORAL(ng)%NH4(iNt,n,i,j), 5.d0, R15N_AIR )  !!!??????????????????????????????
            CORAL(ng)%QNe(iN15,n,i,j)  &
                  = Ci_from_Ct_delta( CORAL(ng)%QNe(iNt,n,i,j), 5.d0, R15N_AIR )  !!!??????????????????????????????
            CORAL(ng)%QNv(iN15,n,i,j)  &
                  = Ci_from_Ct_delta( CORAL(ng)%QNv(iNt,n,i,j), 5.d0, R15N_AIR )  !!!??????????????????????????????
            CORAL(ng)%QNr(iN15,n,i,j)  &
                  = Ci_from_Ct_delta( CORAL(ng)%QNr(iNt,n,i,j), 5.d0, R15N_AIR )  !!!??????????????????????????????
            CORAL(ng)%QNh(iN15,n,i,j)  &
                  = Ci_from_Ct_delta( CORAL(ng)%QNh(iNt,n,i,j), 5.d0, R15N_AIR )  !!!?????????????????????????????
#  endif
            CORAL(ng)%QNext(:,n,i,j) = 0.0d0
            CORAL(ng)%QPext(:,n,i,j) = 0.0d0
            CORAL(ng)%PO4(  :,n,i,j) = 0.0d0  !!!!!!!!!!!!!!!!!!!!!!!!!!
            CORAL(ng)%QPe(  :,n,i,j) = 0.0d0 ! (pmolP/cell)
            CORAL(ng)%QPv(  :,n,i,j) = 0.0d0 ! (pmolP/cell)
            CORAL(ng)%QPr(  :,n,i,j) = 0.0d0 ! (pmolP/cell)
            CORAL(ng)%QPh(  :,n,i,j) = 0.0d0 ! (pmolP/cell)

            CORAL(ng)%PO4(iPt,n,i,j) = 0.0d0  !!!!!!!!!!!!!!!!!!!!!!!!!!
            CORAL(ng)%QPe(iPt,n,i,j) = CORAL(ng)%QCe(iCt,n,i,j) *1.0d0/106.0d0 ! (pmolP/cell)
            CORAL(ng)%QPv(iPt,n,i,j) = CORAL(ng)%QCv(iCt,n,i,j) *1.0d0/106.0d0 ! (pmolP/cell)
            CORAL(ng)%QPr(iPt,n,i,j) = CORAL(ng)%QCr(iCt,n,i,j) *1.0d0/106.0d0 ! (pmolP/cell)
            CORAL(ng)%QPh(iPt,n,i,j) = CORAL(ng)%QCh(iCt,n,i,j) *1.0d0/106.0d0 ! (pmolP/cell)
# endif

# if defined CORAL_ZOOXANTHELLAE
            ZOOX(ng)%Pg(n,i,j)=0.d0
            ZOOX(ng)%R (n,i,j)=0.d0
            ZOOX(ng)%dens(n,i,j) = 1.0d6 ! (cell/cm2)
!            ZOOX(ng)%QC(n,i,j)   = 120.0d0  ! (pmolC/cell) 66 pmol/cell: Tanaka et al 2018;  600-1400 pgC cell-1: Muller-Parker et al., 1994)
                            ! QC0= 50.0d0
            ZOOX(ng)%Chl(n,i,j)  = 3.5 ! 2.0d0 ! (pg/cell) Suggett et al. 2008
!            QAt = ZOOX(ng)%Chl(n,i,j)*1.2d-6 ! (pmolRCII/cell) 1.2d-6 ~1.7d-6 -> Suggett et al. 2008
            QAt = 1.2d-4 ! (pmolRCII/cell) 1.2d-6 ~1.7d-6 -> Suggett et al. 2008
            ZOOX(ng)%QAo(n,i,j) = QAt*0.6d0 ! (pmolRCII/cell) 1.2d-6 ~1.7d-6 -> Suggett et al. 2008
            ZOOX(ng)%QAr(n,i,j) = 0.0d0
            ZOOX(ng)%QAi(n,i,j) = QAt*0.4d0
            ZOOX(ng)%SOx(n,i,j) = 0.5 !0.0d0 ! Superoxide (O2-)
            ZOOX(ng)%NADPHn(n,i,j) = 0.0d0 !0.0d0 ! normalized NADPH (no dim.) NADPH/(NADPH + NADP+) 
            ZOOX(ng)%RuBPn(n,i,j) = 0.0d0 !0.0d0  ! normalized RuBP  (no dim.) RuBP/(0.5*PGA + RuBP) 

            ZOOX(ng)%QCe(  :,n,i,j) = 0.0d0
            ZOOX(ng)%QCv(  :,n,i,j) = 0.0d0
            ZOOX(ng)%QCr(  :,n,i,j) = 0.0d0
            ZOOX(ng)%QCh(  :,n,i,j) = 0.0d0
            ZOOX(ng)%QCe(iCt,n,i,j) = 10.0d0  ! (pmolC/cell) 66 pmol/cell: Tanaka et al 2018;  600-1400 pgC cell-1: Muller-Parker et al., 1994)
            ZOOX(ng)%QCv(iCt,n,i,j) = 60.0d0  ! (pmolC/cell) 66 pmol/cell: Tanaka et al 2018;  600-1400 pgC cell-1: Muller-Parker et al., 1994)
            ZOOX(ng)%QCr(iCt,n,i,j) = 0.0d0  ! (pmolC/cell) 66 pmol/cell: Tanaka et al 2018;  600-1400 pgC cell-1: Muller-Parker et al., 1994)
            ZOOX(ng)%QCh(iCt,n,i,j) = 0.0d0  ! (pmolC/cell) 66 pmol/cell: Tanaka et al 2018;  600-1400 pgC cell-1: Muller-Parker et al., 1994)
#  if defined CARBON_ISOTOPE || defined CLUMPED_ISOTOPE
            ZOOX(ng)%QCe(iC13,n,i,j)  &
                  = Ci_from_Ct_delta( ZOOX(ng)%QCe(iCt,n,i,j), -20.d0, R13C_VPDB )  !!!??????????????????????????????
            ZOOX(ng)%QCv(iC13,n,i,j)  &
                  = Ci_from_Ct_delta( ZOOX(ng)%QCv(iCt,n,i,j), -20.d0, R13C_VPDB )  !!!??????????????????????????????
            ZOOX(ng)%QCr(iC13,n,i,j)  &
                  = Ci_from_Ct_delta( ZOOX(ng)%QCr(iCt,n,i,j), -20.d0, R13C_VPDB )  !!!??????????????????????????????
            ZOOX(ng)%QCh(iC13,n,i,j)  &
                  = Ci_from_Ct_delta( ZOOX(ng)%QCh(iCt,n,i,j), -20.d0, R13C_VPDB )  !!!??????????????????????????????
#   if defined CLUMPED_ISOTOPE
            ZOOX(ng)%QCe(iD47,n,i,j) = ?????  !!!??????????????????????????????
            ZOOX(ng)%QCv(iD47,n,i,j) = ?????  !!!??????????????????????????????
            ZOOX(ng)%QCr(iD47,n,i,j) = ?????  !!!??????????????????????????????
            ZOOX(ng)%QCh(iD47,n,i,j) = ?????  !!!??????????????????????????????
#   endif
#  endif
#  if defined CORAL_NUTRIENTS
            ZOOX(ng)%NO3(  :,n,i,j) = 0.0d0  !!!!!!!!!!!!!!!!!!!!!!!!!!
            ZOOX(ng)%NH4(  :,n,i,j) = 0.0d0  !!!!!!!!!!!!!!!!!!!!!!!!!!
            ZOOX(ng)%QNe(  :,n,i,j) = 0.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
            ZOOX(ng)%QNv(  :,n,i,j) = 0.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
            ZOOX(ng)%QNr(  :,n,i,j) = 0.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
            ZOOX(ng)%QNh(  :,n,i,j) = 0.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1

            ZOOX(ng)%NO3(iNt,n,i,j) = 0.0d0  !!!!!!!!!!!!!!!!!!!!!!!!!!
            ZOOX(ng)%NH4(iNt,n,i,j) = 0.0d0  !!!!!!!!!!!!!!!!!!!!!!!!!!
            ZOOX(ng)%QNe(iNt,n,i,j) = ZOOX(ng)%QCe(iCt,n,i,j)*16.0d0/106.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
            ZOOX(ng)%QNv(iNt,n,i,j) = ZOOX(ng)%QCv(iCt,n,i,j)*16.0d0/106.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
            ZOOX(ng)%QNr(iNt,n,i,j) = ZOOX(ng)%QCr(iCt,n,i,j)*16.0d0/106.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
            ZOOX(ng)%QNh(iNt,n,i,j) = ZOOX(ng)%QCh(iCt,n,i,j)*16.0d0/106.0d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
#   if defined NITROGEN_ISOTOPE
            ZOOX(ng)%NO3(iN15,n,i,j)  &
                  = Ci_from_Ct_delta( ZOOX(ng)%NO3(iNt,n,i,j), 5.d0, R15N_AIR )  !!!??????????????????????????????
            ZOOX(ng)%NH4(iN15,n,i,j)  &
                  = Ci_from_Ct_delta( ZOOX(ng)%NH4(iNt,n,i,j), 5.d0, R15N_AIR )  !!!??????????????????????????????
            ZOOX(ng)%QNe(iN15,n,i,j)  &
                  = Ci_from_Ct_delta( ZOOX(ng)%QNe(iNt,n,i,j), 5.d0, R15N_AIR )  !!!??????????????????????????????
            ZOOX(ng)%QNv(iN15,n,i,j)  &
                  = Ci_from_Ct_delta( ZOOX(ng)%QNv(iNt,n,i,j), 5.d0, R15N_AIR )  !!!??????????????????????????????
            ZOOX(ng)%QNr(iN15,n,i,j)  &
                  = Ci_from_Ct_delta( ZOOX(ng)%QNr(iNt,n,i,j), 5.d0, R15N_AIR )  !!!??????????????????????????????
            ZOOX(ng)%QNh(iN15,n,i,j)  &
                  = Ci_from_Ct_delta( ZOOX(ng)%QNh(iNt,n,i,j), 5.d0, R15N_AIR )  !!!??????????????????????????????
#   endif
            ZOOX(ng)%PO4(  :,n,i,j) = 0.0d0  !!!!!!!!!!!!!!!!!!!!!!!!!!
            ZOOX(ng)%QPe(  :,n,i,j) = 0.0d0 ! (pmolP/cell)
            ZOOX(ng)%QPv(  :,n,i,j) = 0.0d0 ! (pmolP/cell)
            ZOOX(ng)%QPr(  :,n,i,j) = 0.0d0 ! (pmolP/cell)
            ZOOX(ng)%QPh(  :,n,i,j) = 0.0d0 ! (pmolP/cell)

            ZOOX(ng)%PO4(iPt,n,i,j) = 0.0d0  !!!!!!!!!!!!!!!!!!!!!!!!!!
            ZOOX(ng)%QPe(iPt,n,i,j) = ZOOX(ng)%QCe(iCt,n,i,j)*1.0d0/106.0d0 ! (pmolP/cell)
            ZOOX(ng)%QPv(iPt,n,i,j) = ZOOX(ng)%QCv(iCt,n,i,j)*1.0d0/106.0d0 ! (pmolP/cell)
            ZOOX(ng)%QPr(iPt,n,i,j) = ZOOX(ng)%QCr(iCt,n,i,j)*1.0d0/106.0d0 ! (pmolP/cell)
            ZOOX(ng)%QPh(iPt,n,i,j) = ZOOX(ng)%QCh(iCt,n,i,j)*1.0d0/106.0d0 ! (pmolP/cell)
#  endif
# endif
          enddo
        enddo
      enddo
    endif

    RETURN

  END SUBROUTINE initialize_coral
      

!!! **********************************************************************
!!!  Main program of coral polyp model (Nakamura et al. 2013, 2018)
!!! **********************************************************************

  SUBROUTINE coral_polyp  &
!   input parameters
    ( ng, n, i, j    &   ! ng: nested grid number; n: coral compartment; i,j: position
    , date           &   ! Date (days since x or elapsed days)
    , dt             &   ! Time step (sec)
    , PFD            &   ! Photon flux density (umol m-2 s-1)
    , rho_sw         &   ! Density of seawater (g cm-3)
    , Tamb           &   ! Temperature (oC)
    , Samb           &   ! Salinity (PSU)
    , DOamb          &   ! Dissolved oxygen (umol L-1)
    , TAamb          &   ! Total alkalinity (TA: umol L-1)
    , DICamb         &   ! Total dissolved inorganic carbon (DIC: umol L-1)
# if defined CORAL_NUTRIENTS         
    , NO3amb         &   ! NO3 (umol L-1)
    , NH4amb         &   ! NH4 (umol L-1)
    , PO4amb         &   ! PO4 (umol L-1)
# endif
# if defined CORAL_INGESTION
    , ZooC           &   ! zooplankton C bomass(umol C L-1)
    , ZooN           &   ! zooplankton N bomass (umol N L-1)
    , ZooP           &   ! zooplankton P bomass (umol P L-1)
# endif
    , tau_amb        &   ! bottom shear stress (N m-2)
    , Fsed           &   ! sedimentation rate (??)
!   output parameters
    , Flux_DO        &   ! DO  flux (nmol cm-2 s-1)  * direction of water column to coral is positive
    , Flux_TA        &   ! TA  flux (nmol cm-2 s-1)  * direction of water column to coral is positive
    , Flux_DIC       &   ! DIC flux (nmol cm-2 s-1)  * direction of water column to coral is positive
# if defined CORAL_NUTRIENTS
    , Flux_NO3       &   ! NO3 flux (nmol cm-2 s-1)  * direction of water column to coral is positive
    , Flux_NH4       &   ! NH4 flux (nmol cm-2 s-1)  * direction of water column to coral is positive
    , Flux_PO4       &   ! PO4 flux (nmol cm-2 s-1)  * direction of water column to coral is positive
# endif
    , Flux_DOC       &   ! DOC flux (nmol cm-2 s-1) * direction of water column to coral is positive
    , Flux_POC       &   ! POC flux (nmol cm-2 s-1) * direction of water column to coral is positive
# if defined CORAL_NUTRIENTS
    , Flux_DON       &   ! DON flux (nmol cm-2 s-1) * direction of water column to coral is positive
    , Flux_PON       &   ! PON flux (nmol cm-2 s-1) * direction of water column to coral is positive
    , Flux_DOP       &   ! DOP flux (nmol cm-2 s-1) * direction of water column to coral is positive
    , Flux_POP       &   ! POP flux (nmol cm-2 s-1) * direction of water column to coral is positive
# endif
# if defined CORAL_INGESTION
    , Flux_ZooC      &   ! Zooplankton ingestion rate (nmol C cm-2 s-1)  * direction of water column to coral is positive
    , Flux_ZooN      &   ! Zooplankton ingestion rate (nmol N cm-2 s-1)  * direction of water column to coral is positive
    , Flux_ZooP      &   ! Zooplankton ingestion rate (nmol P cm-2 s-1)  * direction of water column to coral is positive
# endif
    )

!-----------------------------------------------------------------------

    USE mod_marine_comet_param
    USE mod_geochem
    USE mod_deb_model
    
    implicit none

! input parameters
    integer, intent(in) :: ng, n, i, j
    real(8), intent(in) :: date
    real(8), intent(in) :: dt
    real(8), intent(in) :: PFD      
    real(8), intent(in) :: rho_sw   
    real(8), intent(in) :: Tamb     
    real(8), intent(in) :: Samb     
    real(8), intent(in) :: DOamb    
    real(8), intent(in) :: TAamb    
    real(8), intent(in) :: DICamb(N_Csp)   
# if defined CORAL_NUTRIENTS
    real(8), intent(in) :: NO3amb(N_Nsp)
    real(8), intent(in) :: NH4amb(N_Nsp)   
    real(8), intent(in) :: PO4amb(N_Psp)
# endif
# if defined CORAL_INGESTION
    real(8), intent(in) :: ZooC(N_Csp,Nzoo)
    real(8), intent(in) :: ZooN(N_Nsp,Nzoo)
    real(8), intent(in) :: ZooP(N_Psp,Nzoo)
# endif
    real(8), intent(in) :: tau_amb  
    real(8), intent(in) :: Fsed
! output parameters
    real(8), intent(out) :: Flux_DO 
    real(8), intent(out) :: Flux_TA 
    real(8), intent(out) :: Flux_DIC(N_Csp)
# if defined CORAL_NUTRIENTS
    real(8), intent(out) :: Flux_NO3(N_Nsp)
    real(8), intent(out) :: Flux_NH4(N_Nsp)
    real(8), intent(out) :: Flux_PO4(N_Psp)
# endif
    real(8), intent(out) :: Flux_DOC(N_Csp,Ndom)
    real(8), intent(out) :: Flux_POC(N_Csp,Npom)
# if defined CORAL_NUTRIENTS
    real(8), intent(out) :: Flux_DON(N_Nsp,Ndom)
    real(8), intent(out) :: Flux_PON(N_Nsp,Npom)
    real(8), intent(out) :: Flux_DOP(N_Psp,Ndom)
    real(8), intent(out) :: Flux_POP(N_Psp,Npom)
# endif
# if defined CORAL_INGESTION
    real(8), intent(out) :: Flux_ZooC(N_Csp,Nzoo)
    real(8), intent(out) :: Flux_ZooN(N_Nsp,Nzoo)
    real(8), intent(out) :: Flux_ZooP(N_Psp,Nzoo)
# endif

!!!------------Set parameters  ----------------------------------

!----- Physical constants ------------------------
    real(8), parameter :: Rgas=8.314d0 ! Gas constant (J mol-1)

!------------Coral parameters ---------------------------------

!----- Coral basic parameters ----------------------------------------

    real(8), parameter :: hcoe=0.3d0    ! Tickness of coral tissue (cm) 3000 um Reviewer's suggestion: 1000-5000 um
    real(8), parameter :: hcal=0.0005d0 ! Tickness of coral calcifying fluid (cm) 5um Reviewer's suggestion: 5 um
    real(8), parameter :: htis=0.01d0   ! Tickness of coral tissue (cm) 100 um  !!!!!!!!!!!!!!!!!!!! Need check!!!

!----- for gross photosynthesi -------------------

!  Kuhl et al. 1995, MEPS 
!   Pg=Pgmax*tanh(I/Ik) for Acropora sp.

!    Pg=Pgmax(n)*tanh(PFDsurf/Ik(n))*(1-Br(i,j))
!          *HCO3coe/(K_HCO3+HCO3coe)
!          *hcoe

!   0.6 could not sustain QCv at QCv_max: it left Pg about 20% short of the
!   reserve carbon needed to cover Rc plus tissue maintenance, so QCv drifted
!   down to ~178 umolC cm-2.  Restored to the Kuhl et al. (1995) value.
    real(8), parameter :: Pgmax(2)=  [ 0.73d0, 0.73d0 ] !0.6d0 !0.91d0    !Maximum photosynthesis rate (nmol O2 cm-2 s-1) Kuhl et al. (1995) *Tuned
    real(8), parameter :: Ik(2)=     [ 275.d0, 275.d0 ]   !(275 uEin m-2 s-1) * refference value

!------ Goreau et al. (1996)------------------------------------------   
!                    Coral    FIZ    CZ
!          K_HCO3   408.    71.     178.   uM
!          V_HCO3     1.45   1.09    13.   nmol O2 (ug Chl a)-1 min-1
!          K_CO2aq    5.     0.67     2.7  uM
!          V_CO2aq    2.     1.15    12.5  nmol O2 (ug Chl a)-1 min-1
!---------------------------------------------------------------------
    real(8), parameter :: K_HCO3(2)= [ 408.d0, 408.d0 ] !uM
    real(8), parameter :: V_HCO3(2)= [ 1.45d0, 1.45d0 ] !nmol O2 (ug Chl a)-1 min-1
    real(8), parameter :: K_CO2(2)=[ 5.d0, 5.d0 ]     !uM
    real(8), parameter :: V_CO2(2)=[ 2.d0, 2.d0 ]     !nmol O2 (ug Chl a)-1 min-1

!   Temperature dependency parameters (tempcorr2, mod_deb_model.F)
!
!   tempcorr2 has the same functional form as the Sharpe-Schoolfield model, so
!   thermal-performance-curve parameters from the literature transfer directly:
!     T_A  = E   / k_B ,  T_AH = E_h / k_B ,  T_H = T_h ,  k_B = 8.617e-5 eV K-1
!   and tempcorr2 returns exactly 1 at T = Tref.
!
!   The previous values here were a copy of the oyster parameters in
!   mod_bivalve.F (Crassostrea gigas; van der Veer et al. 2006 / Bourles et al.
!   2009).  T_H = 298 K put the thermal optimum at 21 degC and cut Pg to 43% at
!   30 degC - backwards for a tropical coral.
!
!   Tref: 25 degC, the temperature at which Pgmax was tuned.  Because tempcorr2
!         is 1 at Tref, the existing calibration survives switching the flag on.
!   T_A : 4000 K = 0.345 eV.  Metabolic theory gives 0.32 eV for photosynthesis-
!         limited rates (Brown et al. 2004); coral TPC fits give 0.46 eV.  The
!         low end is taken because Pg is already light- and HCO3-limited by the
!         tanh and Michaelis-Menten terms, so T_A carries only the enzymatic part.
!   All six photosynthesis/respiration temperature parameters now come from one
!   source: Sci Rep 15:33181 (2025) "Thermal extremes likely trigger metabolic
!   imbalance in coral holobionts", Table 1, total dataset over 35 coral species,
!   fitted with Sharpe-Schoolfield at a reference temperature of 25 degC - the
!   same Tref this module uses, so the values transfer without rescaling:
!
!                    E (eV)          E_D (eV)        Topt (degC)
!     gross phot.    0.46 +/- 0.03   6.28 +/- 1.62   29.9 +/- 1.0
!     dark resp.     0.47 +/- 0.03   2.98 +/- 0.72   30.5 +/- 1.8
!
!   with T_A = E/k_B, T_AH = E_D/k_B and T_H solved from Topt via
!     T_H = 1/( 1/Topt + ln(T_A/(T_AH - T_A))/T_AH ).
!
!   History and the trade-off this choice makes.  Earlier settings were assembled
!   from several sources: T_A_pht = 4000 K from metabolic theory (0.32 eV, Brown
!   et al. 2004), T_A_rsp = 6155 K from Fujimura et al. (2008), and T_H/T_AH tuned
!   by hand.  The hand-tuned version (Topt_pht 26.4 degC, a steep 6.59 eV collapse)
!   gave a larger skeletal d13C annual amplitude - 1.261 permil against 0.704 here -
!   but was worse on everything else (365 d runs, seasonal SST 23.1-29.1 degC,
!   U_0 = 5 cm s-1):
!
!                                   hand-tuned    Sci Rep    observed
!     organic C release summer/winter   0.565       2.041      5.0 (Tanaka 2018)
!     annual-cycle fit R2               0.901       0.988
!     skeletal d13C peak day             72.2       164.6      ~172 = light max
!     QCe daily minimum                  2.20        7.70      > 0
!     skeletal d13C amplitude           1.261       0.704
!
!   The hand-tuned version had photosynthesis falling in summer while respiration
!   rose, which drained QCe and made mucus release run ANTI-phase with the season -
!   the opposite sign to Tanaka et al. (2018).  The Sci Rep values put both Topt
!   above the summer peak, so Pg rises 58% into summer, QCe roughly doubles and the
!   release comes out in phase.  Amplitude is the one thing given up; it should be
!   recovered through Rratio or flow speed, neither of which is yet tuned for it.
!   See doc/README.md section 22.
!
!   T_L : photosynthesis keeps 15 degC while respiration uses 276 K (2.85 degC).
!         The paper does not constrain the cold end.  Photosynthesis is far more
!         cold-sensitive than respiration - f_pht is 0.005 at 10 degC against
!         f_rsp 0.335 - which matches the temperature response of PAM-measured
!         photosynthetic activity (Fv/Fm).
    real(8), parameter :: Tref_pht(2) = [  298.15d0, 298.15d0] ! (K) Refernce temperature (25 degC)
    real(8), parameter :: T_A_pht(2)  = [ 5338.0d0, 5338.0d0 ] ! (K) = 0.46 eV  (Sci Rep 2025 Table 1)
    real(8), parameter :: T_H_pht(2)  = [ 306.28d0, 306.28d0 ] ! (K) -> Topt = 29.9 degC (Sci Rep 2025); 303.0d0 = 26.4 degC previously
    real(8), parameter :: T_AH_pht(2) = [72876.0d0, 72876.0d0] ! (K) = 6.28 eV  (Sci Rep 2025); 76420.0d0 = 6.59 eV previously
    real(8), parameter :: T_L_pht(2)  = [  288.15d0, 288.15d0] ! (K) Lower boundary tolerance range (15 degC)
    real(8), parameter :: T_AL_pht(2) = [75000.0d0, 75000.0d0] ! (K) Arrhenius temp. for lower boundary

!----- for respiration --------------------------

!    R= k_R(n)*CORAL(ng)%QC(n,i,j)/(K_QC(n)+CORAL(ng)%QC(n,i,j))
!       *CORAL(ng)%DOcoe(n,i,j)/(K_DO(n)+CORAL(ng)%DOcoe(n,i,j))

                                             !!! * Nakamura et al. 2013 setting; ** New setting

!   K_QC was carried over from Nakamura et al. (2013), where the Michaelis-Menten
!   term acted on QC, the whole tissue carbon pool (~290 umolC cm-2).  There
!   QC/(K_QC+QC) was ~0.98 and respiration was effectively DO-limited, which is
!   the intended physiology: respiration should be insensitive to the reserve and
!   controlled by oxygen.  Splitting QC into the reserve QCe and the structure QCv
!   left the same constant acting on QCe (2-4 umolC cm-2), which put respiration
!   on the steep part of the curve: with K_QC = 5 the DO branch of the min() never
!   controlled - 0.0% of the time over day 20-25.  At K_QC = 1 the DO branch
!   controls 33% of the time, restoring the intended behaviour.
!   Rmax is then reduced to keep P/R in its measured 1.5-2.5 band; it has always
!   been a tuning parameter.  0.15 gives a maximum of 0.54 and a realised
!   0.35 umol O2 cm-2 h-1, inside the measured range for coral dark respiration.
    real(8), parameter :: Rmax(2)   = [ 0.15d0, 0.15d0 ] !!!0.4d0 (with K_QC=5) 0.53d0*  0.37d0** !Maximum respiration rate (nmol O2 cm-2 s-1) *Tuned using Kuhl et al (1995), Al-Horani et al. (2003) data
    real(8), parameter :: K_QC(2)   = [  1.0d0,  1.0d0 ]     !!!5.0d0* umol cm-2 (for the pre-split QC)!!!
    real(8), parameter :: K_DO(2)   = [ 46.0d0, 46.0d0 ]   ! ca. 46 (umol kg-1) Newton & Atkinson (1991)

!   Rratio: fraction of host respiratory CO2 released into the coelenteron;
!   the remainder goes straight into the calcifying fluid.  Only the
!   calicoblastic epithelium can supply the sub-calicoblastic space directly,
!   and that layer is a small part of the tissue, so 1-Rratio should be ~0.1-0.2.
!   0.5 was needed only while the paracellular leak was written as a diffusive
!   gradient, which pinned the calcifying fluid to the isotopically heavy
!   coelenteron.  With the leak upwind, 0.85 gave skeletal d13C of -3.3 permil
!   and matched the anatomical expectation.  Raising a_surf to 3 then lifted
!   calcification into its measured band but drove the skeleton to -0.5 permil,
!   so Rratio was lowered again to restore d13C.
!   PROVISIONAL: set by skeletal d13C alone (measured -2 to -4 permil).  It
!   implies the calicoblastic layer accounts for 30% of host respiration, above
!   the 10-20% its thickness suggests, so the anatomical argument that justified
!   0.85 no longer supports this value.  The alternative is to hold 0.85 and
!   lighten the skeleton by cutting k_leak instead, which needs a_surf re-tuned
!   to hold pH_cal - a three-parameter search that has not been done.  Revisit
!   before publishing.
!
!   An 11-point sweep (1.00 to 0.50 in steps of 0.05, 365-day runs) showed the
!   annual mean is linear in Rratio to within 0.04 permil over a 6.25 permil span:
!
!     mean d13C = 12.489*Rratio - 11.962
!
!   so -3.0 permil fixes Rratio at 0.718 and the choice is unique.  0.70 is that
!   value rounded; it gives -3.24 permil at 23.1-29.1 degC.
!
!   The same sweep showed Rratio is a mean-offset knob and nothing else.  The
!   annual amplitude spans only 0.691-0.896 permil across the whole sweep, is
!   non-monotonic (minimum at 0.60), and is pinned to 0.69-0.73 once the mean is
!   held inside the measured band - a mean:amplitude sensitivity ratio near 30:1.
!   Lowering Rratio widens the coelenteron-to-calcifying-fluid d13C gradient
!   (4.20 -> 11.04 permil) but changes neither the pool size nor the exchange
!   rate, so it adds a constant offset rather than a seasonal signal.  Do not
!   reach for Rratio to fix the annual amplitude.
!
!   Note Rratio trades d13C without costing calcification: lowering it feeds
!   more respired CO2 to the calcifying fluid, which shrinks the coelenteron
!   gradient and cuts the leak by almost the same amount.  Over the full sweep
!   G moved 12.17 -> 12.59 umolC cm-2 d-1 (+3.4%) and P/R 1.887 -> 1.886, while
!   Pg, Pn and R are identical to within 0.15% at every point of the diel cycle.
    real(8), parameter :: Rratio(2) = [ 0.70d0, 0.70d0 ] !!!0.72d0 0.85d0 0.9d0** 0.8d0  !1.0d0* !!!

!   Temperature dependency parameters (tempcorr2, mod_deb_model.F)
!
!   T_A : 6155 K = Eact/Rgas with Eact = 5.117e4 J mol-1, the value estimated
!         from Fujimura et al. (2008) that this module already carried (the
!         commented-out line below).  It gives Q10 = 1.98, matching the measured
!         Q10 ~ 2 for Acropora tenuis and Pocillopora damicornis (Nakamura et al.
!         2015) and metabolic theory's 0.65 eV for respiration (Brown et al. 2004).
!         Three independent sources agree, so this is the best-constrained of the
!         temperature parameters.
!   T_H : set so that Topt = 34 degC.  Measured Topt for coral respiration is
!         29-40 degC (Jurriaans & Hoogenboom 2019), i.e. respiration rises
!         monotonically across the whole Ishigaki range, unlike photosynthesis.
!         Keeping T_A_rsp > T_A_pht and Topt_rsp > Topt_pht makes P/R fall with
!         warming, as observed by Coles & Jokiel (1977) over 18-31 degC.
!   T_L : 3 degC, not the 15 degC used for photosynthesis.  15 degC left f_rsp at
!         0.003 by 10 degC, i.e. respiration essentially switched off in cold
!         water, which is not what corals do - they keep respiring well below the
!         temperature at which photosynthesis stops.  3 degC puts f_rsp at 0.335
!         at 10 degC and 0.104 at 3 degC.  Above 20 degC the curve is unchanged
!         (25 degC: 1.000, 29.1: 1.307, 34: 1.587), so nothing in the Ishigaki
!         range moves; this only matters for cold-water scenarios.  276 K is the
!         value the oyster parameters carried (Bourles et al. 2009), which the
!         first pass of section 15 had replaced by 15 degC.
!
!    real(8), parameter :: Eact(2)   = [ 5.117d4, 5.117d4 ] !Activation energy (J mol-1)) *Tuned
    real(8), parameter :: Tref_rsp(2) = [  298.15d0, 298.15d0] ! (K) Refernce temperature (25 degC)
    real(8), parameter :: T_A_rsp(2)  = [ 5454.0d0, 5454.0d0 ] ! (K) = 0.47 eV  (Sci Rep 2025 Table 1); 6155.0d0 = Fujimura et al. 2008 previously
    real(8), parameter :: T_H_rsp(2)  = [ 308.18d0, 308.18d0 ] ! (K) -> Topt = 30.5 degC (Sci Rep 2025); 311.1d0 = 34 degC previously
    real(8), parameter :: T_AH_rsp(2) = [34582.0d0, 34582.0d0] ! (K) = 2.98 eV  (Sci Rep 2025); 45000.0d0 previously
    real(8), parameter :: T_L_rsp(2)  = [  276.0d0,  276.0d0 ] ! (K) Lower boundary tolerance range (2.85 degC) (288.15d0 = 15 degC previously)
    real(8), parameter :: T_AL_rsp(2) = [75000.0d0, 75000.0d0] ! (K) Arrhenius temp. for lower boundary

! ---- OC turnover ---------------------
!    real(8), parameter :: C_dec(2) = [ 0.02d0, 0.02d0 ] ! (nmol cm-2 s-1) ~0.1 (nmol cm-2 s-1) Tanaka et al., 2018
!   k_decay: Tissue decay rate constant (s-1)
!
!   The old value 3.4d-7 came from reading Tanaka et al. (2018) as 0.1 nmolC
!   cm-2 s-1 of organic carbon release.  That is 360 nmolC cm-2 h-1, but the
!   paper (PeerJ 6:e5728, Acropora tenuis) measured POC 47.7 + DOC 17.5 = 65
!   nmolC cm-2 h-1 in summer daytime, and a daily total organic carbon release
!   of 1094 (summer) and 219 (winter) nmolC cm-2 d-1 - 6.5% and 1.6% of net
!   carbon fixation.  The old constant produced 8.5 umolC cm-2 d-1, 7.8x the
!   summer measurement and 41% of gross photosynthesis.
!
!   Every unit of F_Cdec has to be rebuilt out of the reserve through F_Crest,
!   and F_rest_dmd does not depend on QCe, so the oversized decay imposed a
!   constant 24 h drain of 14.6 umolC cm-2 d-1 (70% of gross photosynthesis).
!   That emptied QCe about 5 h after sunset on every one of 345 days and left
!   E_ca at zero for 65% of the night (37% of all hours).
!
!   k_decay = 1094 nmolC cm-2 d-1 / 86400 s / (QCv ~ 264 umolC cm-2 * 1d3)
!           = 4.8d-8 s-1,  i.e. a tissue turnover time of 241 d.
    real(8), parameter :: k_decay(2) = [ 4.8d-8, 4.8d-8 ] ! (s-1) 3.4d-7 (old, 7.8x Tanaka et al. 2018)

!   Temperature dependency parameters (tempcorr1, mod_deb_model.F)
!
!   No direct measurement of the temperature dependence of coral tissue decay was
!   found.  It is kept equal to T_A_rsp, following the DEB convention that
!   maintenance and turnover share one Arrhenius temperature - so it moved from
!   6155 to 5454 K when respiration adopted the Sci Rep (2025) value.
!   The choice barely matters: a sweep over 4000 / 6155 / 8000 K (365 d, seasonal
!   SST) changed skeletal d13C by 0.001 permil and G by 0.02 umolC cm-2 d-1:
!
!     T_A_dec    F_Cdec   mucus   total release   skeletal d13C   G
!       4000      1.275   5.723       6.998          -3.362      12.52
!       6155      1.321   5.685       7.006          -3.362      12.51
!       8000      1.364   5.649       7.014          -3.361      12.50
!
!   Mucus absorbs the change: faster decay raises the repair demand, which draws
!   QCe down, and the release k_mucus*QCe falls by almost exactly the amount the
!   decay rose.  That is the self-stabilising behaviour section 17.6 relies on,
!   seen from the other side.  tempcorr1 has no upper deactivation, which is right
!   for a degradative process.  See doc/README.md section 22.
!   Validation target: Fitt et al. (2000) - tissue biomass peaks in spring and is
!   lowest in late summer.  NOTE k_rest and k_mob below are NOT temperature-
!   corrected, so the demand side of tissue repair is asymmetric with decay; if
!   the seasonal QCv swing comes out too large, that is the first thing to fix.
    real(8), parameter :: Tref_dec(2) = [  298.15d0, 298.15d0] ! (K) Refernce temperature (25 degC)
    real(8), parameter :: T_A_dec(2)  = [ 5454.0d0, 5454.0d0 ] ! (K) Arrhenius temperature (= T_A_rsp; 6155.0d0 previously)

!   QCv_max: target areal tissue carbon (umolC cm-2); 290 from Tanaka et al., 2018
!   QCv_min: structural floor that cannot be catabolised (umolC cm-2)
!   k_rest : rate constant for restoring QCv towards QCv_max (s-1)
!            1/k_rest = 39 d, i.e. the same order as the tissue turnover time
!   k_mob  : rate constant for mobilising structural C into the reserve when
!            the reserve runs short (s-1)
    real(8), parameter :: QC_eps = 1.0d-8   ! (umolC cm-2) guard for quota-ratio denominators
    real(8), parameter :: C_eps  = 1.0d-8   ! (umolC L-1)  guard for speciation-ratio denominators
    real(8), parameter :: QCv_max(2) = [ 290.0d0, 290.0d0 ] ! (umolC cm-2)
    real(8), parameter :: QCv_min(2) = [ 100.0d0, 100.0d0 ] ! (umolC cm-2)
!   k_rest is deliberately fast (1/k_rest = 5.8 d) so that the instantaneous
!   restoration demand exceeds the daytime energy supply while QCv is below
!   target.  F_Crest then absorbs the whole surplus and F_Cext stays near zero,
!   i.e. the colony does not extend while its tissue is still thin.  With a slow
!   k_rest the daytime surplus leaked into QCext and could not repay the
!   night-time decay, so QCv fell even when the daily budget allowed recovery.
    real(8), parameter :: k_rest(2)  = [ 2.0d-6, 2.0d-6 ]   ! (s-1)
    real(8), parameter :: k_mob(2)   = [ 1.0d-7, 1.0d-7 ]   ! (s-1)
!   K_QCmob: reserve level at which mobilisation is half its maximum
!            (umolC cm-2).  It must be well below the diel range of QCe,
!            otherwise the switch never closes and mobilisation degenerates
!            into a constant drain on the tissue.  Note it cannot be called
!            K_mob: Fortran is case-insensitive, so that would collide with
!            k_mob above.
    real(8), parameter :: K_QCmob(2) = [ 0.5d0, 0.5d0 ]     ! (umolC cm-2)
    real(8), parameter :: p2r = 0.25d0    ! molC respiration/(molC protain) required respiration rate for 1 molC biosynthesis
!    real(8), parameter :: Ebs = 5.29d5   ! (J molC-1), Energy content of reserves (Ren & Schiel, 2008)
!  C6H12O6 + 6 O2 + 30 ADP + 30 Pi -> 6 CO2 + 6 H2O + 30 ATP
!  ATP + H2O -> ADP + Pi  dG=-7.3kcal/mol=-30.5kJ/mol
    real(8), parameter :: E_rsp = 30.5d3 * 30.0d0/6.0d0   ! J/molC; Energy produced by respiration 
    real(8), parameter :: E_bio = p2r * E_rsp  ! = 38125 J/molC; ATP energy required for 1 molC biosynthesis. (p2r=0.25)

!----- for calcification ------------------------

!   eeff: thermodynamic efficiency of the Ca2+-ATPase, used as
!   E_rq_H_transport = 2.3*R*T*dpH / eeff.  It is the dominant control on the
!   calcifying-fluid pH: F_H = E_ca / E_rq_H_transport.
!   0.12 is the measured efficiency of reconstituted SERCA at its optimum
!   lipid composition (Lervik et al., 2012; 4.8-11% off-optimum), and it is
!   also what reproduces the observed calcifying-fluid pH.  Running 0.30 and
!   0.12 side by side as coral types 1 and 2 gave pH_cal peaks of 9.9 and 9.3
!   against a measured maximum of ~9.3 (Al-Horani et al., 2003), and skeletal
!   d13C of -1.5 and -2.9 permil against a measured -2 to -4.  Two independent
!   lines of evidence therefore point at 0.12, so both types now use it.
!   0.8 (Trevorrow & Haynes, 1983 - near-100% coupling) drove pH_cal past 11
!   and is kept only for reference.
!   NOTE: with both types identical, ctrl-crl01_* and ctrl-crl02_* must come
!   out byte-identical.  Any divergence means a type-dependent parameter was
!   left unequal somewhere.
!    real(8), parameter :: eeff(2)  = [ 0.3d0, 0.12d0 ]   !!! comparison run
!    real(8), parameter :: eeff(2)  = [ 0.8d0, 0.8d0 ]   !!! 100% Energy efficency (Trevorroe and Haynes, 1983)
    real(8), parameter :: eeff(2)  = [ 0.12d0, 0.12d0 ]   !!! Energy efficency of calcification (<12%, 4~7%?; Lervik et al., 2012)
!    real(8), parameter :: E_m(2)=[ 2.0d4, 2.0d4 ]   !!! 1.0d4** ! 5.0d3* Energy flux for maintenance (nJ cm-2 s-1)
    real(8) :: E_m

!   k_CO2i: CO2* permeability from the coelenteron to the calcifying fluid (cm s-1).
!
!   WEAKLY CONSTRAINED - treat as a tuning parameter, not as a measured value.
!     - The source, Sueltemeyer & Rinast (1996) Planta 200:358-368, measured the
!       plasma membrane of the green alga Chlamydomonas reinhardtii, not a coral.
!     - That paper does not report one number: 0.76, 1.21, 1.49 and 1.8d-3
!       depending on pH and CO2 acclimation.  1.49d-3 is the pH 7.8, high-CO2 case.
!     - Measured PCO2 across biological membranes spans 200-fold, from 0.0015
!       (guinea-pig colon apical) to 0.3 cm s-1 (human erythrocyte), controlled
!       mainly by membrane cholesterol and by protein gas channels (aquaporins,
!       RhAG).  This value sits at the very low end of that range.
!     - Whether low permeabilities are real or an unstirred-layer artefact is
!       still disputed (Missner et al. 2008 vs Endeward & Gros).
!     - Structurally this coefficient crosses the calicoblastic EPITHELIUM -
!       apical membrane, cytoplasm, basal membrane - so a single-membrane value
!       does not transfer directly; in series the effective value is lower.
!     - No measurement exists for coral calicoblastic cells, and the split
!       between CO2 diffusion and HCO3- transporters there is unknown.
!   See doc/README.md section 14 for the survey and sources.
!
!   Sensitivity is low: raising it 100-fold moved skeletal d13C by only 0.8
!   permil and left G (7.09 -> 7.11), pH_cal and P/R essentially unchanged,
!   because the leak and respiration dominate the calcifying-fluid carbon
!   supply.  It matters only when those two are shut off.
    real(8), parameter :: k_CO2i(2) =[ 1.5d-3, 1.5d-3 ]  ! 1.0d-4 (previous, 1/15 of the cited value)

!   k_leak: conductivity of the paracellular leak between the coelenteron and
!   the calcifying fluid (cm s-1).  ONE coefficient serves TA, DIC and CO2:
!   the pathway is assumed non-selective, which is also why the leak carries
!   the upstream isotopic composition (see Fpp_DIC) instead of a
!   per-isotopologue gradient.  Do not split it back into separate k_TA and
!   k_DIC - selective conductivities would contradict the upwind treatment.
!   1.0d-4 left pH_cal peaking at 10.2 (measured max ~9.3, Al-Horani et al.
!   2003); 3.0d-4 brings the peak to 9.5 while holding skeletal d13C at
!   -3.3 permil.  1.0d-3 overshoots: the extra TA loss forces so much proton
!   pumping that E_ca is exhausted and calcification collapses.
    real(8), parameter :: k_leak(2) =[ 3.0d-4, 3.0d-4 ]  !!! 1.0d-4  5.0d-5 !3.0d-3* !*Tuned

!   a_surf: ratio of the calcifying skeletal surface to the projected coral
!   area.  The rate coefficients in the calcification section come from
!   inorganic aragonite precipitation experiments, which normalise to *mineral*
!   surface area, while G here is per unit *projected* area.  The calcifying
!   interface follows the corallite relief (septa, walls, spines) and so
!   exceeds the plan-view area it covers.  It multiplies dissolution as well:
!   the same interface carries both.
!   Do NOT fold colony-scale rugosity (5-20 for branching forms) in here - the
!   model is already per unit polyp surface and P2R does the reef-scale
!   conversion, so that would double count.
!   a_surf = 1 left G at 4.1 umolC cm-2 d-1, below the measured 5-15 band.  It
!   is the only lever that raises G and lowers pH_cal together: reaching a
!   given G at lower omega shortens dpH, and E_ca/(2.3RT*dpH/eeff) then buys
!   more proton pumping.  Protons per CaCO3 fall from 4.6 to 2.5 at a_surf = 3.
    real(8), parameter :: a_surf(2) = [ 3.0d0, 3.0d0 ]  ! (-)

!   c2g = (calcification rate)/(net tissue growth rate).  CORAL_SIZE_DYNAMICS
!   defines the tissue side as netCgrowth = (growth-mort)*QCv, where growth and
!   mort are relative area rates (cm2 cm-2 s-1), so
!       c2g = G / ( mu * QCv ) ,   mu = relative rate of change of coral cover.
!   For a circular colony spreading at v cm yr-1, mu = 2v/r, and with G = 10.75
!   and QCv = 290 umolC cm-2 this gives c2g = 0.0371/mu (mu in d-1):
!
!     Acropora  r =  5 cm, v = 2.92 cm yr-1  -> mu = 1.17 yr-1 -> c2g = 12
!     Acropora  r = 15 cm, v = 2.92          -> mu = 0.39      -> c2g = 35
!     Acropora  r = 30 cm, v = 2.92          -> mu = 0.19      -> c2g = 70
!     Pocilloporidae r = 15 cm, v = 3.54     -> mu = 0.47      -> c2g = 29
!   (radial extension from structure-from-motion at Ningaloo Reef; Ross et al.
!   2019 J Exp Mar Biol Ecol.)  Because mu is the NET rate, a reef whose cover
!   has equilibrated implies c2g -> infinity; 12-70 is the gross-expansion end.
!
!   The old 3.0 implied mu = 4.51 yr-1, i.e. 33.8 cm yr-1 of radial extension for
!   a 15 cm colony - 11.6x the measured rate.  It was letting tissue extension
!   absorb 3.58 umolC cm-2 d-1 of photosynthate that a real coral cannot use that
!   way; that surplus now leaves as mucus instead (see k_mucus below).
    real(8), parameter :: c2g(2) = [ 35.0d0, 35.0d0 ]  ! (calcification rate)/(net tissue growth rate) (no dimension) 3.0d0 (old, 11.6x too fast)

# if defined CORAL_MUCUS
    !                  ForgC(Ncl,Ndom)      Coral1        Coral2     
    real(8), parameter :: ForgC(2,2)  = reshape(                          &
                                     [ 0.232d0/20.0d0, 0.073d0/2.5d0    & ! LDOM  !! Organic carbon release rate(+) or uptake rate(-) (nmol cm-2 s-1) *Tuned
                                     , 0.232d0/20.0d0, 0.073d0/2.5d0 ]  & ! RDOM  !! Organic carbon release rate(+) or uptake rate(-) (nmol cm-2 s-1) *Tuned
                                     , [2,2] ) !
    ! 200 mmol m-2 d-1 for 100% covered inner reef corals
    ! -63 mmol m-2 d-1 for 100% covered reef slope corals 
    ! For converting reef scale (mmol m-2 d-1) to polyp scale (nmol cm-2 s-1)
    !   1 mmol m-2 d-1 = 100/24/60/60/P2R(n) nmol cm-2 s-1 ~ 1.16d-3/P2R(n),
    !   Thus: 200*1.16d-3/P2R =  0.232/P2R nmol cm-2 s-1 for inner reef corals
    !!!       -63*1.16d-3/P2R = -0.073/P2R nmol cm-2 s-1 for reef slope corals  ****** To Be Confirmed

    !   F_Cmucus = k_mucus * QCe, so mucus release is the only sink proportional
    !   to the reserve and it is what closes the reserve budget.  Photosynthesis
    !   does not depend on QCe, respiration is DO-limited once K_QC = 1, tissue
    !   repair is capped at F_Cdec once QCv sits at QCv_max, and extension is
    !   capped at G/c2g.  Without mucus the surplus photosynthate (Pg 16.0 minus
    !   R 9.45, F_Crest 1.09 and F_Cext 3.59 = 1.9 umolC cm-2 d-1) had nowhere to
    !   go and QCe grew without bound.  The old 1.0d-7 released 0.019 umolC cm-2
    !   d-1, 1% of that surplus.
    !
    !   Steady state is QCe = surplus/(sum(k_mucus)*1d3).  With c2g = 35 the
    !   surplus is 5.15 umolC cm-2 d-1, so sum = 4.0d-6 puts the reserve at
    !   ~15 umolC cm-2, about one day of gross photosynthesis.  That release is
    !   32% of gross photosynthesis, inside the 5-45% of photosynthetically fixed
    !   carbon reported as DOC/mucus loss; Wild et al. (2004, Nature 428:66) put
    !   it at up to half of the carbon assimilated by the symbionts.  Tanaka et
    !   al. (2018) measured only 6.5%, but that is the fraction recoverable from
    !   incubation water, a lower bound.
    !   Being proportional to QCe it is self-stabilising: a seasonal rise in Pg
    !   raises QCe, which raises the release, with no retuning.
    !            k_mucus(Ncl,Ndom)    Coral1   Coral2
    real(8), parameter :: k_mucus(2,2)  = reshape(                          &
                                     [ 3.6d-6, 3.6d-6    & ! LDOM  !! Organic carbon release rate(+) or uptake rate(-) (s-1) *Tuned  (1.0d-7 old)
                                     , 3.6d-7, 3.6d-7 ]  & ! RDOM  !! Organic carbon release rate(+) or uptake rate(-) (s-1) *Tuned  (1.0d-8 old)
                                     , [2,2] ) !
# endif
# if defined CORAL_INGESTION
    real(8), parameter :: r_assim = 0.1d0 ! Assimilation ratio with ingesting zooplankton
# endif
# if defined CORAL_ZOOXANTHELLAE
!    real(8), parameter :: K_ROS(2)   = [ 10.0d0, 10.0d0 ]     !!! umol L !!! To Be Confirmed
!    real(8), parameter :: V_detox(2) = [ 2.0d0, 2.0d0 ]   ! 
    real(8), parameter :: k_detox(2) = [ 3.4d7, 3.4d7 ]     ! Rate constant of specific catalase activity (M-1 s-1): Ogura (1955), Mueller et al., (1997)
    real(8), parameter :: CAT(2)     = [ 5.0d-11, 5.0d-11 ]   ! Catalase concentration (M): !!!!!!! Tuning
    real(8), parameter :: k_dam(2)   = [ 0.0d-5, 0.0d-5 ]   ! Reaction rate constant (s-1): !!!!!!! Tuning
    real(8), parameter :: a_dam(2)   = [ 2.0d3,  2.0d3  ]   ! Constant ((nmol cm-2 s-1) -1): !!!!!!! Tuning
    real(8), parameter :: k_Zelm(2)  = [ 7.0d-9,  7.0d-9 ]   ! Reaction rate constant (cell cm-2 s-1): !!!!!!! Tuning
!    real(8), parameter :: F_cROS(2)  = [ 3.0d-1, 3.0d-1 ]   ! ROS production rate by coral (nmol cm-2 s-1): !!!!!!! Tuning
    real(8), parameter :: a_cROS(2)  = [ 1.0d-2, 1.0d-2 ]   ! ROS production rate by coral (nmol cm-2 s-1): !!!!!!! Tuning
# endif

# if defined CORAL_SIZE_DYNAMICS
    real(8), parameter :: g_max(2) = [ 1.0d-2, 1.0d-2 ] ! Maximum growth rate (nmol cm-2 s-1)  !!!!!! Tuning parameter
    real(8), parameter :: aC_m   = 2.0d-1   ! ((umol cm-2)-1)!!!!!!! Tuning parameter
    real(8), parameter :: km_dam = 1.0d-10  ! (s-1)!!!!!!!!!!!!!!!!! Tuning parameter
    real(8), parameter :: km_es(2) = [ 1.0d0, 1.0d0 ]   ! !!!!!!!!!!!!!! TBC
    real(8), parameter :: km(2) = [ 1.0d0, 1.0d0 ]   ! !!!!!!!!!!!!!! TBC
    real(8), parameter :: QC0(2) = [ 250.0d0, 250.0d0 ]   ! !!!!!!!!!!!!!! TBC
# endif

!--- Variables for summing mass fluxes (nmol cm-2 s-1) -----------------
    real(8) :: F_TAcal
    real(8) :: F_TAcoe 
    real(8) :: F_DICcal(N_Csp)
    real(8) :: F_DICcoe(N_Csp)
    real(8) :: F_DOcoe
    real(8) :: F_QCe(N_Csp)
    real(8) :: F_QCv(N_Csp)
    real(8) :: F_QCr(N_Csp)
    real(8) :: F_QCh(N_Csp)
    real(8) :: F_QCext(N_Csp)
    real(8) :: F_CO2cal(N_Csp)
    real(8) :: F_CO2coe(N_Csp)
# if defined CORAL_NUTRIENTS
!  Nutrients dynamics
    real(8) :: F_NO3(N_Nsp)
    real(8) :: F_NH4(N_Nsp)
    real(8) :: F_PO4(N_Psp)
    real(8) :: F_QNe(N_Nsp)
    real(8) :: F_QNv(N_Nsp)
    real(8) :: F_QNr(N_Nsp)
    real(8) :: F_QNh(N_Nsp)
    real(8) :: F_QPe(N_Psp)
    real(8) :: F_QPv(N_Psp)
    real(8) :: F_QPr(N_Psp)
    real(8) :: F_QPh(N_Psp)
    real(8) :: F_QNext(N_Nsp)
    real(8) :: F_QPext(N_Psp)
# endif
# if defined CORAL_ZOOXANTHELLAE
    real(8) :: F_ROS
# endif
!--- Variables of isotope ratio (R13C = 12C/13C) -----------------
    real(8) :: rDICcal(N_Csp)
    real(8) :: rDICcoe(N_Csp)
    real(8) :: rDICamb(N_Csp)
    real(8) :: rQCe(N_Csp)
    real(8) :: rQCv(N_Csp)
    real(8) :: rQCr(N_Csp)
    real(8) :: rQCh(N_Csp)
    real(8) :: rCO2cal(N_Csp)
    real(8) :: rCO2coe(N_Csp)
    real(8) :: rCO2amb(N_Csp)
# if defined CORAL_INGESTION
    real(8) :: rZooC(N_Csp,Nzoo)
# endif
# if defined CORAL_NUTRIENTS
!--- Variables of isotope ratio (R15N = 15N/14N) -----------------
    real(8) :: rNO3coe(N_Nsp)
    real(8) :: rNO3amb(N_Nsp)
    real(8) :: rNH4coe(N_Nsp)
    real(8) :: rNH4amb(N_Nsp)
    real(8) :: rQNe(N_Nsp)
    real(8) :: rQNv(N_Nsp)
    real(8) :: rQNr(N_Nsp)
    real(8) :: rQNh(N_Nsp)
    real(8) :: rPO4amb(N_Psp)
    real(8) :: rQPe(N_Psp)
    real(8) :: rQPv(N_Psp)
    real(8) :: rQPr(N_Psp)
    real(8) :: rQPh(N_Psp)
#  if defined CORAL_INGESTION
    real(8) :: rZooN(N_Nsp,Nzoo)
    real(8) :: rZooP(N_Psp,Nzoo)
#  endif
# endif

!--- Other variables -------------------------------------------
    real(8) :: Rc, Rz
!    real(8) :: Si   !Mass transfer coefficient (cm s-1)
    real(8) :: Si_DIC(N_Csp), Si_TA, Si_DO   !Mass transfer coefficient (cm s-1)
# if defined CORAL_INGESTION
    real(8) :: Si_PHY(N_Csp), Si_ZOO(N_Csp)
# endif
# if defined CORAL_NUTRIENTS
    real(8) :: Si_NO3(N_Nsp), Si_NH4(N_Nsp), Si_PO4(N_Psp)
# endif
# if defined CORAL_NONE_CO2_EQ
    real(8) :: Si_CO2(N_Csp)
# endif
# if defined CORAL_ZOOXANTHELLAE
    real(8) :: Si_ROS
# endif
    real(8) :: TKamb   !Temperature (K)
!----- for CO2 system dynamics -------------------
    real(8) :: pHcal,fCO2cal,CO2cal(N_Csp),HCO3cal(N_Csp),CO3cal(N_Csp),Wargcal
    real(8) :: pHcoe,fCO2coe,CO2coe(N_Csp),HCO3coe(N_Csp),CO3coe(N_Csp)
    real(8) :: pHamb,fCO2amb,CO2amb(N_Csp),HCO3amb(N_Csp),CO3amb(N_Csp),Wargamb  !!!!!
# if defined CORAL_NONE_CO2_EQ
    real(8) :: cHcoe,cOHcoe
    real(8) :: cHcal,cOHcal
    real(8) :: Fpp_CO2(N_Csp), Flux_CO2aq(N_Csp)
    real(8) :: kp1(N_Csp),km1(N_Csp),kp4(N_Csp),km4(N_Csp)
    real(8) :: a_eqbd                                    ! R(HCO3-)/R(CO2aq) at equilibrium
    real(8) :: a_los(N_Csp),b_gen(N_Csp),CO2ss(N_Csp)    ! for the exponential CO2* update
    integer, save :: n_CO2clip = 0                       ! count of negative-CO2* clips
# endif
!----- for gross photosynthesis -------------------
    real(8) :: PFDsurf
!     Temperature related factor
    real(8) :: f_temp
    real(8) :: f_min
!----- for respiration -------------------
    real(8) :: QCe_tmp, DOcoe_tmp
!----- for calcification ------------------------
    real(8) :: E_tot,E_ca,F_H
    real(8) :: E_rq_H_transport
    real(8) :: E_g  !!! Energy flux for growth (nJ cm-2 s-1)
    real(8) :: E_req  !!! Energy flux required for repair and growth (nJ cm-2 s-1)
    real(8) :: Fpm_CO2(N_Csp),Fpp_TA,Fpp_DIC(N_Csp)
    real(8) :: Fleak_DIC   ! total-C paracellular leak; its sign picks the upwind pool
# if defined CORAL_NONE_CO2_EQ
    real(8) :: Fleak_CO2
# endif
!    real(8) :: Fpp_CO2,Fpp_HCO3,Fpp_CO3
    real(8), save :: E0_cal(Ncl) = 0.d0 ! Eneryg required for 1 mol CaCO3 production (J molC-1)

!----- for tissue decay ------------------------
    real(8) :: F_Cdec
# if defined CORAL_NUTRIENTS
    real(8) :: F_Ndec
    real(8) :: F_Pdec
# endif

!----- for nutrients dynamics -------------------

    real(8) :: QCcr
    real(8) :: F_zDO
# if defined CORAL_ZOOXANTHELLAE
    real(8) :: F_Csec(N_Csp)
    real(8) :: F_Cwaste(N_Csp)
    real(8) :: F_Zelm
    real(8) :: F_Zmort
    real(8) :: F_zDIC(N_Csp), F_zROS
    real(8) :: F_detox
    real(8) :: F_dam
    real(8) :: F_cROS
    real(8) :: Damage
#  if defined CORAL_NUTRIENTS
    real(8) :: F_Nsec(N_Nsp)
    real(8) :: F_Nwaste(N_Nsp)
    real(8) :: F_Psec(N_Psp)
    real(8) :: F_Pwaste(N_Psp)
    real(8) :: F_zNO3(N_Nsp), F_zNH4(N_Nsp)
    real(8) :: F_zPO4(N_Psp)
    real(8) :: F_ONOO
#  endif
# endif

# if defined CORAL_MUCUS
    real(8) :: F_Cmucus
#  if defined CORAL_NUTRIENTS
    real(8) :: F_Nmucus
    real(8) :: F_Pmucus
#  endif
# endif
# if defined CORAL_INGESTION
    real(8) :: F_Cingest
#  if defined CORAL_NUTRIENTS
    real(8) :: F_Ningest
    real(8) :: F_Pingest
#  endif
# endif
!  Biosynthesis: F_bio is funded exactly by E_g and is split into the part that
!  restores areal tissue (F_Crest -> QCv) and the part that funds colony
!  extension (F_Cext -> QCext).  F_Cmob is the reverse transfer, structural
!  tissue catabolised back into the reserve under starvation.
    real(8) :: F_bio, F_bio_dmd, F_rest_dmd, F_Crest, F_Cext, F_Cmob
# if defined CORAL_NUTRIENTS
    real(8) :: rNC_v, rPC_v
    real(8) :: F_Nbio, F_Nrest, F_Next
    real(8) :: F_Pbio, F_Prest, F_Pext
# endif
# if defined CORAL_SIZE_DYNAMICS

    real(8) :: netCgrowth
    real(8) :: g2c_tmp   ! (net growth rate)/(calcification rate)
    real(8) :: mort_es
#  if defined CORAL_NUTRIENTS
    real(8) :: F_Nrepair, F_Ngrowth
    real(8) :: F_Prepair, F_Pgrowth
#  endif
# endif

# if defined CORAL_TESTMODE
!  Output
    real(8), save :: dsec(Ncl) = 0.d0 !sec
    real(8), save :: dday(Ncl) = 0.d0 !day
    real(8), save :: S_PFD_dt(Ncl)      = 0.0d0
    real(8), save :: S_Gn_dt(N_Csp,Ncl) = 0.0d0
    real(8), save :: S_Pg_dt(Ncl)       = 0.0d0
    real(8), save :: S_R_dt(Ncl)        = 0.0d0
!    real(8), save :: S_QC_dt(N_Csp,Ncl) = 0.0d0
#  if defined CARBON_ISOTOPE
    real(8) :: d13C_DICamb, d13C_CO2amb, d13C_HCO3amb, d13C_CO3amb
    real(8) :: d13C_DICcoe, d13C_CO2coe, d13C_HCO3coe, d13C_CO3coe
    real(8) :: d13C_DICcal, d13C_CO2cal, d13C_HCO3cal, d13C_CO3cal
    real(8) :: d13C_QCe, d13C_QCv, d13C_QCr, d13C_QCh, d13C_G, d13C_arg
#  endif
#  if defined CORAL_BORON_ISOTOPE
    real(8) :: d11Barg
    real(8), save :: S_d11BargxGn_dt(Ncl) = 0.0d0
#  endif
# endif
    real(8) :: k_CO2i_tmp(N_Csp)
    real(8) :: cff,cff2,cff3
    integer :: isp, m

!======================================================================
!   Preparation for calculation
!======================================================================
!   Set initial zeros for output mass fluxes (nmol cm-2 s-1)
    Flux_DIC = 0.0d0
    Flux_TA  = 0.0d0
    Flux_DO  = 0.0d0
    Flux_DOC = 0.0d0
    Flux_POC = 0.0d0
# if defined CORAL_INGESTION
!    Flux_PHY = 0.0d0
    Flux_ZooC = 0.0d0
# endif
# if defined CORAL_NUTRIENTS
    Flux_NO3 = 0.0d0
    Flux_NH4 = 0.0d0
    Flux_PO4 = 0.0d0
    Flux_DON = 0.0d0
    Flux_PON = 0.0d0
    Flux_DOP = 0.0d0
    Flux_POP = 0.0d0
# endif

!--- Set initial zeros for summing mass fluxes (nmol cm-2 s-1) -----------------
    F_DOcoe = 0.0d0
    F_TAcal = 0.0d0
    F_TAcoe = 0.0d0
    F_DICcal(:) = 0.0d0
    F_DICcoe(:) = 0.0d0
    F_CO2cal(:) = 0.0d0
    F_CO2coe(:) = 0.0d0
    F_QCe(:) = 0.0d0
    F_QCv(:) = 0.0d0
    F_QCr(:) = 0.0d0
    F_QCh(:) = 0.0d0
    F_QCext(:) = 0.0d0
# if defined CORAL_NUTRIENTS
    F_NO3(:) = 0.0d0
    F_NH4(:) = 0.0d0
    F_PO4(:) = 0.0d0
    F_QNe(:) = 0.0d0
    F_QNv(:) = 0.0d0
    F_QNr(:) = 0.0d0
    F_QNh(:) = 0.0d0
    F_QPe(:) = 0.0d0
    F_QPv(:) = 0.0d0
    F_QPr(:) = 0.0d0
    F_QPh(:) = 0.0d0
    F_QNext(:) = 0.0d0
    F_QPext(:) = 0.0d0
# endif
# if defined CORAL_ZOOXANTHELLAE
    F_ROS = 0.0d0
# endif
!---- Temperature (K) -------------------------------------
    TKamb=Tamb+273.15d0 !(oC->K)

!---- CO2 system parameters --------------------------------

    CO2amb (:) = 0.0d0
    HCO3amb(:) = 0.0d0
    CO3amb (:) = 0.0d0
!    CO2coe (:) = 0.0d0
    HCO3coe(:) = 0.0d0
    CO3coe (:) = 0.0d0
!    CO2cal (:) = 0.0d0
    HCO3cal(:) = 0.0d0
    CO3cal (:) = 0.0d0

!----CO2*+H2O <-> H+ +HCO3- is none equilibrium
# if defined CORAL_NONE_CO2_EQ
!--------- CO2 system in calcified fulid -------------------
    pHcal         = pH_fromATCTcCO2aq(CORAL(ng)%TAcal(n,i,j)/1.024d0      &
                                    , CORAL(ng)%DICcal(iCt,n,i,j)/1.024d0 &
                                    , CORAL(ng)%CO2cal(iCt,n,i,j)/1.024d0,TKamb, Samb)
    HCO3cal(iCt)  = cHCO3_noneq(CORAL(ng)%DICcal(iCt,n,i,j)/1.024d0      &
                               ,CORAL(ng)%CO2cal(iCt,n,i,j)/1.024d0,pHcal,TKamb, Samb)!! for Isotope; umol/kg
    CO3cal (iCt)  = cCO3_noneq(CORAL(ng)%DICcal(iCt,n,i,j)/1.024d0       &
                              ,CORAL(ng)%CO2cal(iCt,n,i,j)/1.024d0,pHcal,TKamb, Samb) ! umol/kg
    fCO2cal       = fCO2_fromcCO2aq(CORAL(ng)%CO2cal(iCt,n,i,j)/1.024d0,TKamb, Samb)  !! for output
    Wargcal       = Warg_fromcCO3cCa(CO3cal(iCt),10.4d0,TKamb, Samb)  !Calcifying fluid {Ca2+]=10.4 mmol kg-1   Assumed
    HCO3cal(iCt)  = HCO3cal(iCt)*1.024d0 ! umol/kg -> umol/L
    CO3cal (iCt)  = CO3cal (iCt)*1.024d0 ! umol/kg -> umol/L
!--------- CO2 system in coelenteron -------------------
    pHcoe         = pH_fromATCTcCO2aq(CORAL(ng)%TAcoe(n,i,j)/1.024d0      &
                                     ,CORAL(ng)%DICcoe(iCt,n,i,j)/1.024d0      &
                                     ,CORAL(ng)%CO2coe(iCt,n,i,j)/1.024d0,TKamb, Samb)
    HCO3coe(iCt)  = cHCO3_noneq(CORAL(ng)%DICcoe(iCt,n,i,j)/1.024d0      &
                               ,CORAL(ng)%CO2coe(iCt,n,i,j)/1.024d0,pHcoe,TKamb, Samb)
    CO3coe (iCt)  = cCO3_noneq(CORAL(ng)%DICcoe(iCt,n,i,j)/1.024d0       &
                              ,CORAL(ng)%CO2coe(iCt,n,i,j)/1.024d0,pHcoe,TKamb, Samb)!! for Isotope
    fCO2coe       = fCO2_fromcCO2aq(CORAL(ng)%CO2coe(iCt,n,i,j)/1.024d0,TKamb, Samb)  !! for output
    HCO3coe(iCt)  = HCO3coe(iCt)*1.024d0 ! umol/kg -> umol/L
    CO3coe (iCt)  = CO3coe (iCt)*1.024d0 ! umol/kg -> umol/L

!--------- CO2 system in ambient seawater ------------------- !! for output
    pHamb        = pH_fromATCT(TAamb/1.024d0,DICamb(iCt)/1.024d0,TKamb, Samb)
    CO2amb (iCt) = cCO2aq_fromCTpH(DICamb(iCt)/1.024d0,pHamb,TKamb, Samb) ! umol/kg
    HCO3amb(iCt) = cHCO3_fromCTpH (DICamb(iCt)/1.024d0,pHamb,TKamb, Samb) ! umol/kg
    CO3amb (iCt) = cCO3_fromCTpH  (DICamb(iCt)/1.024d0,pHamb,TKamb, Samb) ! umol/kg
    fCO2amb      = fCO2_fromcCO2aq(CO2amb(iCt),TKamb, Samb)  !! for output
    Wargamb      = Warg_fromcCO3  (CO3amb(iCt),TKamb, Samb)
    CO2amb (iCt) = CO2amb (iCt)*1.024d0 ! umol/kg -> umol/L
    HCO3amb(iCt) = HCO3amb(iCt)*1.024d0 ! umol/kg -> umol/L
    CO3amb (iCt) = CO3amb (iCt)*1.024d0 ! umol/kg -> umol/L
!----CO2 equilibrium
#  if defined CARBON_ISOTOPE || defined CLUMPED_ISOTOPE 
!----------- CO2 system in calcified fulid -------------------
    HCO3cal(iC13) = cH13CO3_noneq2(CORAL(ng)%DICcal(iC13,n,i,j), CORAL(ng)%CO2cal(iC13,n,i,j),HCO3cal(iCt),CO3cal(iCt),TKamb)
    CO3cal (iC13) = c13CO3_noneq2 (CORAL(ng)%DICcal(iC13,n,i,j), CORAL(ng)%CO2cal(iC13,n,i,j),HCO3cal(iCt),CO3cal(iCt),TKamb)
!----------- CO2 system in coelenteron -------------------
    HCO3coe(iC13) = cH13CO3_noneq2(CORAL(ng)%DICcoe(iC13,n,i,j), CORAL(ng)%CO2coe(iC13,n,i,j),HCO3coe(iCt),CO3coe(iCt),TKamb)
    CO3coe (iC13) = c13CO3_noneq2 (CORAL(ng)%DICcoe(iC13,n,i,j), CORAL(ng)%CO2coe(iC13,n,i,j),HCO3coe(iCt),CO3coe(iCt),TKamb)
!----------- CO2 system in ambient seawater -------------------
    CO2amb (iC13) = conc13CO2aq(DICamb(iC13),CO2amb(iCt),HCO3amb(iCt),CO3amb(iCt),TKamb)
#   if defined CLUMPED_ISOTOPE 
!----------- CO2 system in calcified fulid -------------------
    HCO3cal(iD47) = ???
    CO3cal (iD47) = ???
!----------- CO2 system in coelenteron -------------------
    HCO3coe(iD47) = ???
    CO3coe (iD47) = ???
!----------- CO2 system in ambient seawater -------------------
    CO2amb (iD47) = ???
#   endif
#  endif

!----CO2 system equilibrium is assumed
# else
!--------- CO2 system in calcified fulid -------------------
    pHcal        = pH_fromATCT(CORAL(ng)%TAcal(n,i,j)/1.024d0,CORAL(ng)%DICcal(iCt,n,i,j)/1.024d0,TKamb, Samb)
    CORAL(ng)%CO2cal(iCt,n,i,j) &
                 = cCO2aq_fromCTpH(CORAL(ng)%DICcal(iCt,n,i,j)/1.024d0,pHcal,TKamb, Samb)
    HCO3cal(iCt) = cHCO3_fromCTpH (CORAL(ng)%DICcal(iCt,n,i,j)/1.024d0,pHcal,TKamb, Samb)!! for Isotope
    CO3cal (iCt) = cCO3_fromCTpH  (CORAL(ng)%DICcal(iCt,n,i,j)/1.024d0,pHcal,TKamb, Samb)
    fCO2cal      = fCO2_fromcCO2aq(CORAL(ng)%CO2cal(iCt,n,i,j),TKamb, Samb)  !! for output
    Wargcal      = Warg_fromcCO3cCa(CO3cal(iCt),10.4d0,TKamb, Samb)  !Calcifying fluid {Ca2+]=10.4 mmol kg-1   Assumed
    CORAL(ng)%CO2cal(iCt,n,i,j) = CORAL(ng)%CO2cal(iCt,n,i,j)*1.024d0 ! umol/kg -> umol/L
    HCO3cal(iCt) = HCO3cal(iCt)*1.024d0 ! umol/kg -> umol/L 
    CO3cal (iCt) = CO3cal (iCt)*1.024d0 ! umol/kg -> umol/L
!--------- CO2 system in coelenteron -------------------
    pHcoe        = pH_fromATCT(CORAL(ng)%TAcoe(n,i,j)/1.024d0,CORAL(ng)%DICcoe(iCt,n,i,j)/1.024d0,TKamb, Samb)
    CORAL(ng)%CO2coe(iCt,n,i,j) &
                 = cCO2aq_fromCTpH(CORAL(ng)%DICcoe(iCt,n,i,j)/1.024d0,pHcoe,TKamb, Samb)!! for Isotope and output
    HCO3coe(iCt) = cHCO3_fromCTpH (CORAL(ng)%DICcoe(iCt,n,i,j)/1.024d0,pHcoe,TKamb, Samb)
    CO3coe (iCt) = cCO3_fromCTpH  (CORAL(ng)%DICcoe(iCt,n,i,j)/1.024d0,pHcoe,TKamb, Samb)!! for Isotope
    fCO2coe      = fCO2_fromcCO2aq(CORAL(ng)%CO2coe(iCt,n,i,j),TKamb, Samb)  !! for output
    CORAL(ng)%CO2coe(iCt,n,i,j) = CORAL(ng)%CO2coe(iCt,n,i,j)*1.024d0 ! umol/kg -> umol/L
    HCO3coe(iCt) = HCO3coe(iCt)*1.024d0 ! umol/kg -> umol/L
    CO3coe (iCt) = CO3coe (iCt)*1.024d0 ! umol/kg -> umol/L

#  if defined CARBON_ISOTOPE || defined CLUMPED_ISOTOPE 
!!! ----- Isotope calculation ----------------------------------------------------
    CORAL(ng)%CO2cal(iC13,n,i,j) &
                  = conc13CO2aq(CORAL(ng)%DICcal(iC13,n,i,j),CORAL(ng)%CO2cal(iCt,n,i,j),HCO3cal(iCt),CO3cal(iCt),TKamb)
    HCO3cal(iC13) = concH13CO3 (CORAL(ng)%DICcal(iC13,n,i,j),CORAL(ng)%CO2cal(iCt,n,i,j),HCO3cal(iCt),CO3cal(iCt),TKamb)
    CO3cal (iC13) = conc13CO3  (CORAL(ng)%DICcal(iC13,n,i,j),CORAL(ng)%CO2cal(iCt,n,i,j),HCO3cal(iCt),CO3cal(iCt),TKamb)
!----------- CO2 system in coelenteron -------------------
    CORAL(ng)%CO2coe(iC13,n,i,j) &
                  = conc13CO2aq(CORAL(ng)%DICcoe(iC13,n,i,j),CORAL(ng)%CO2coe(iCt,n,i,j),HCO3coe(iCt),CO3coe(iCt),TKamb)
    HCO3coe(iC13) = concH13CO3 (CORAL(ng)%DICcoe(iC13,n,i,j),CORAL(ng)%CO2coe(iCt,n,i,j),HCO3coe(iCt),CO3coe(iCt),TKamb)
    CO3coe (iC13) = conc13CO3  (CORAL(ng)%DICcoe(iC13,n,i,j),CORAL(ng)%CO2coe(iCt,n,i,j),HCO3coe(iCt),CO3coe(iCt),TKamb)
#   if defined CLUMPED_ISOTOPE 
!----------- CO2 system in calcified fulid -------------------
    HCO3cal(iD47) = ???
    CO3cal (iD47) = ???
!----------- CO2 system in coelenteron -------------------
    HCO3coe(iD47) = ???
    CO3coe (iD47) = ???
!----------- CO2 system in ambient seawater -------------------
    CO2amb (iD47) = ???
#   endif
#  endif
#  if defined CORAL_TESTMODE
!--------- CO2 system in ambient seawater ------------------- !! for output
    pHamb        = pH_fromATCT(TAamb/1.024d0,DICamb(iCt)/1.024d0,TKamb, Samb)
    CO2amb (iCt) = cCO2aq_fromCTpH(DICamb(iCt)/1.024d0,pHamb,TKamb, Samb) ! umol/kg
    HCO3amb(iCt) = cHCO3_fromCTpH (DICamb(iCt)/1.024d0,pHamb,TKamb, Samb) ! umol/kg
    CO3amb (iCt) = cCO3_fromCTpH  (DICamb(iCt)/1.024d0,pHamb,TKamb, Samb) ! umol/kg
    fCO2amb      = fCO2_fromcCO2aq(CO2amb(iCt),TKamb, Samb)  !! for output
    Wargamb      = Warg_fromcCO3  (CO3amb(iCt),TKamb, Samb)
    CO2amb (iCt) = CO2amb (iCt)*1.024d0 ! umol/kg -> umol/L
    HCO3amb(iCt) = HCO3amb(iCt)*1.024d0 ! umol/kg -> umol/L
    CO3amb (iCt) = CO3amb (iCt)*1.024d0 ! umol/kg -> umol/L
#  endif
# endif  /*end CORAL_NONE_CO2_EQ*/

!--- Carbon isotope or tracer ratio (R13C = 13C/12C) -----------------
    DO isp=1,N_Csp
      rQCe   (isp) = Iso_ratio( CORAL(ng)%QCe   (isp,n,i,j), CORAL(ng)%QCe   (iCt,n,i,j) )   !coral organism
      rQCv   (isp) = Iso_ratio( CORAL(ng)%QCv   (isp,n,i,j), CORAL(ng)%QCv   (iCt,n,i,j) )   !coral organism
      rQCr   (isp) = Iso_ratio( CORAL(ng)%QCr   (isp,n,i,j), CORAL(ng)%QCr   (iCt,n,i,j) )   !coral organism
      rQCh   (isp) = Iso_ratio( CORAL(ng)%QCh   (isp,n,i,j), CORAL(ng)%QCh   (iCt,n,i,j) )   !coral organism
      rDICcal(isp) = Iso_ratio( CORAL(ng)%DICcal(isp,n,i,j), CORAL(ng)%DICcal(iCt,n,i,j) ) !DIC in calcifying fluid
      rCO2cal(isp) = Iso_ratio( CORAL(ng)%CO2cal(isp,n,i,j), CORAL(ng)%CO2cal(iCt,n,i,j) )
      rDICcoe(isp) = Iso_ratio( CORAL(ng)%DICcoe(isp,n,i,j), CORAL(ng)%DICcoe(iCt,n,i,j) ) !DIC in coelenteron
      rCO2coe(isp) = Iso_ratio( CORAL(ng)%CO2coe(isp,n,i,j), CORAL(ng)%CO2coe(iCt,n,i,j) )
      rDICamb(isp) = Iso_ratio( DICamb(isp), DICamb(iCt) )!!!!!  DIC in ambient seawater  
      rCO2amb(isp) = Iso_ratio( CO2amb(isp), CO2amb(iCt) )
!      rHCO3cal(isp) = Iso_ratio( cH13CO3cal(isp), HCO3cal(isp) )  !!!!!!!!!!!!!????????
# if defined CORAL_INGESTION
      DO m=1,Nzoo
        rZooC(isp,m)  = Iso_ratio( ZooC(isp,m), ZooC(iCt,m) )
      END DO
# endif
    END DO

!   The iCt component of every ratio above is 1 by definition: it exists only as
!   an identity multiplier, so that one expression can carry both the bulk flux
!   and its isotope split.  Iso_ratio() returns 0 for a non-positive pool, which
!   switches the *bulk* flux off instead of merely guarding the isotope
!   division.  For the organic pools that gates tissue repair while decay keeps
!   running at full rate, so QCv ratchets down and can never recover, and the
!   total and 13C pools drift out of proportion once QCe crosses zero.  Restore
!   the identity explicitly.  This is only safe because every sink of QCe is now
!   limited by QCe_tmp below, so the reserve cannot be overdrawn.
    rQCe(iCt) = 1.0d0
    rQCv(iCt) = 1.0d0

!   Non-negative copies of the pools that drive Michaelis-Menten style limiters.
!   Every sink of QCe is scaled by one of these, so the reserve can only decay
!   towards zero asymptotically and never overshoots into negative values.
    QCe_tmp   = max(CORAL(ng)%QCe(iCt,n,i,j), 0.0d0)
    DOcoe_tmp = max(CORAL(ng)%DOcoe(n,i,j),   0.0d0)

# if defined CORAL_NUTRIENTS
!--- Nitrogen isotope or tracer ratio (R15N = 15N/14N) -----------------
    DO isp=1,N_Nsp
      rQN    (isp) = Iso_ratio( CORAL(ng)%QN (isp,n,i,j), CORAL(ng)%QN (iNt,n,i,j) )   !coral organism
      rNO3coe(isp) = Iso_ratio( CORAL(ng)%NO3(isp,n,i,j), CORAL(ng)%NO3(iNt,n,i,j) ) 
      rNH4coe(isp) = Iso_ratio( CORAL(ng)%NH4(isp,n,i,j), CORAL(ng)%NH4(iNt,n,i,j) ) 
      rNO3amb(isp) = Iso_ratio( NO3amb(isp), NO3amb(iNt) ) 
      rNH4amb(isp) = Iso_ratio( NH4amb(isp), NH4amb(iNt) ) 
#  if defined CORAL_INGESTION
      DO m=1,Nzoo
        rZooN(isp,m)  = Iso_ratio( ZooN(isp,m), ZooN(iNt,m) )  !!!!!!!!!!!!!!!!!!!!!!!
      END DO
#  endif
    END DO
!--- Phosphrous tracer ratio (R15N = 15N/14N) -----------------
    DO isp=1,N_Psp
      rQP    (isp) = Iso_ratio( CORAL(ng)%QP (isp,n,i,j), CORAL(ng)%QP (iPt,n,i,j) )   !coral organism
      rPO4coe(isp) = Iso_ratio( CORAL(ng)%PO4(isp,n,i,j), CORAL(ng)%PO4(iPt,n,i,j) ) 
      rPO4amb(isp) = Iso_ratio( PO4amb(isp), PO4amb(iPt) ) 
#  if defined CORAL_INGESTION
      DO m=1,Nzoo
        rZooP(isp,m)  = Iso_ratio( ZooP(isp,m), ZooP(iPt,m) )  !!!!!!!!!!!!!!!!!!!!!!!
      END DO
#  endif
    END DO

# endif

!=========================================================================
!     Mass fluxes between ambient seawater and coelenteron (nmol cm-2 s-1)
!=========================================================================

!---- calculate mass transfer velocity (cm s-1) ---------------------

!    Si = (65.7d0*tau_amb**0.4d0+4.7d0)*1.d-4
    
!    Si_DIC=(65.7d0*tau_amb**0.4d0+4.7d0)*1.d-4
!    Si_TA =(65.7d0*tau_amb**0.4d0+4.7d0)*1.d-4
!    Si_DO =(65.7d0*tau_amb**0.4d0+4.7d0)*1.d-4
    Si_DIC(:)=S_i(tau_amb,dif_HCO3,340.0d0,1.05d0)*1.0d2
    Si_TA =S_i(tau_amb,dif_HCO3,340.0d0,1.05d0)*1.0d2
    Si_DO =S_i(tau_amb,dif_O2  ,340.0d0,1.05d0)*1.0d2
# if defined CORAL_INGESTION
    Si_PHY(:)=(65.7d0*tau_amb**0.4d0+4.7d0)*1.d-4
    Si_ZOO(:)=(65.7d0*tau_amb**0.4d0+4.7d0)*1.d-4
# endif
# if defined CORAL_NUTRIENTS
    Si_NO3(:)=(65.7d0*tau_amb**0.4d0+4.7d0)*1.d-4
    Si_NH4(:)=(65.7d0*tau_amb**0.4d0+4.7d0)*1.d-4
    Si_PO4(:)=(65.7d0*tau_amb**0.4d0+4.7d0)*1.d-4
# endif
# if defined CORAL_NONE_CO2_EQ
!    Si_CO2=(65.7d0*tau_amb**0.4d0+4.7d0)*1.d-4
    Si_CO2(:)=S_i(tau_amb,dif_CO2 ,340.0d0,1.05d0)*1.0d2
# endif
# if defined CORAL_ZOOXANTHELLAE
    Si_ROS=S_i(tau_amb,dif_H2O2,340.0d0,1.05d0)*1.0d2
# endif

!------- Flux calculation (nmol cm-2 s-1) ------------------------

! DIC uptake (nmol cm-2 s-1)
    Flux_DIC(:) = Si_DIC(:)*(DICamb(:)-CORAL(ng)%DICcoe(:,n,i,j))!*rho_sw
# if defined CORAL_NONE_CO2_EQ
    Flux_CO2aq(:) = Si_CO2*(CO2amb(:)-CORAL(ng)%CO2coe(:,n,i,j))!*rho_sw
# endif
! TA uptake (nmol cm-2 s-1)
    Flux_TA  = Si_TA *(TAamb-CORAL(ng)%TAcoe(n,i,j))!*rho_sw
! DO uptake (nmol cm-2 s-1)
    Flux_DO  = Si_DO *(DOamb-CORAL(ng)%DOcoe(n,i,j))

!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
    F_TAcoe = F_TAcoe + Flux_TA
    F_DOcoe = F_DOcoe + Flux_DO
    F_DICcoe(:) = F_DICcoe(:) + Flux_DIC(:)
# if defined CORAL_NONE_CO2_EQ
    F_CO2coe(:) = F_CO2coe(:) + Flux_CO2aq(:)
# endif

# if defined CORAL_NUTRIENTS

! Coral carbon cell quoto

    c_SQC=min((Flux_NH4 +Flux_NO3 )*c_CNP(nC)/c_CNP(nN)
                 ,Flux_PO4 *c_CNP(nC)/c_CNP(nP))

    c_SQC=CORAL(ng)%QC(n,i,j)/(1000.+CORAL(ng)%QC(n,i,j))*c_SQC
    c_SQN=c_SQC*c_CNP(nN)/c_CNP(nC)
    c_SQP=c_SQC*c_CNP(nP)/c_CNP(nC)

    tempb=Flux_NH4 /(Flux_NH4 +Flux_NO3 )*c_SQN
    Flux_NO3 =Flux_NO3 /(Flux_NH4 +Flux_NO3 )*c_SQN
    Flux_NH4 =tempb
    Flux_PO4 =c_SQP
    Flux_NH4 =0.
! NO3 uptake
    Flux_NO3 =0.
! PO4 uptake
    Flux_PO4 =0.

! NH4 uptake (nmol cm-2 s-1) 
    Flux_NH4(:) = Si_NH4*NH4amb
! NO3 uptake (nmol cm-2 s-1) 
    Flux_NO3(:) = Si_NO3*NO3amb
! PO4 uptake (nmol cm-2 s-1) 
    Flux_PO4(:) = Si_PO4*PO4amb

!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
    F_NH4(:) = F_NH4(:) + Flux_NH4(:)
    F_NO3(:) = F_NO3(:) + Flux_NO3(:)
    F_PO4(:) = F_PO4(:) + Flux_PO4(:)

# endif

!----- Coral mucus release rate (nmol cm-2 s-1)--------------------------
# if defined CORAL_MUCUS
!
    DO m=1,Ndom
!      F_Cmucus = ForgC(n,m)  !!!! constant value is assumed
      F_Cmucus = k_mucus(n,m) * QCe_tmp*1.d3   ! QCe_tmp: never let a negative reserve reverse the flux
      Flux_DOC(:,m) = Flux_DOC(:,m) - F_Cmucus *rQCe(:) ! Ocean to coral is positive, coral to ocean is negative
!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
      F_QCe(:)  = F_QCe(:) - F_Cmucus *rQCe(:)
#  if defined CORAL_NUTRIENTS
      F_Nmucus = k_mucus(n,m) * CORAL(ng)%QNe(iNt,n,i,j)*1.d3
      F_Pmucus = k_mucus(n,m) * CORAL(ng)%QPe(iPt,n,i,j)*1.d3
      Flux_DON(:,m) = Flux_DON(:,m) - F_Nmucus *rQN(:)
      Flux_DOP(:,m) = Flux_DOP(:,m) - F_Pmucus *rQP(:)
!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
      F_QNe(:)  = F_QNe(:) - F_Nmucus *rQN(:)
      F_QPe(:)  = F_QPe(:) - F_Pmucus *rQP(:)
#  endif
    END DO
# endif

!----- Plankton ingestion (nmol cm-2 s-1)--------------------------
# if defined CORAL_INGESTION
!
    DO m=1,Nzoo
      Flux_ZooC(:,m) = Si_ZOO * ZooC(:,m) *rZooC(:,m)
      Flux_POC(:,iLPOM) = Flux_POC(:,iLPOM) + Flux_ZooC(:,m)*(1.0d0 - r_assim) *0.9d0
      Flux_POC(:,iRPOM) = Flux_POC(:,iRPOM) + Flux_ZooC(:,m)*(1.0d0 - r_assim) *0.1d0
!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
      F_QCe(:)  = F_QCe(:) + Flux_ZooC(:,m) * r_assim
#  if defined CORAL_NUTRIENTS
      Flux_ZooN(:) = Si_ZOO * ZooN(:)
      Flux_PON(:,iLPOM)  = Flux_PON(:,iLPOM) + Flux_ZooN(:,m)*(1.0d0 - r_assim) *0.9d0
      Flux_PON(:,iRPOM)  = Flux_PON(:,iRPOM) + Flux_ZooN(:,m)*(1.0d0 - r_assim) *0.1d0
      Flux_ZooP(:) = Si_ZOO * ZooP(:)
      Flux_POP(:,iLPOM)  = Flux_POP(:,iLPOM) + Flux_ZooP(:,m)*(1.0d0 - r_assim) *0.9d0
      Flux_POP(:,iRPOM)  = Flux_POP(:,iRPOM) + Flux_ZooP(:,m)*(1.0d0 - r_assim) *0.1d0
!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
      F_QNe(:)  = F_QNe(:) + Flux_ZooN(:,m) * r_assim
      F_QPe(:)  = F_QPe(:) + Flux_ZooP(:,m) * r_assim
#  endif
    END DO
# endif



!======================================================================
!     Gross photosynthesis rate (nmol cm-2 s-1)
!======================================================================

!   Sediment dependent term
    PFDsurf=PFD!*exp(-lamb*dsed)

!======================================================================
# if defined CORAL_ZOOXANTHELLAE
!-------- ROS release rate by mitochondria in coral  (nmol cm-2 s-1) ----------------------------
!    F_ROS = F_ROS -  a_cROS(n)*Tamb + b_cROS(n)
    F_ROS = F_ROS + a_cROS(n)*CORAL(ng)%R(n,i,j)

!-------- ROS detox rate (nmol cm-2 s-1) ----------------------------
!    F_ROS = F_ROS - V_detox(n)*CORAL(ng)%ROS(n,i,j)/(K_ROS(n)+CORAL(ng)%ROS(n,i,j))
    F_ROS = F_ROS - k_detox(n) * CORAL(ng)%ROS(n,i,j) * CAT(n)

!-------- ROS oxydation rate (damage rate) (nmol cm-2 s-1) ----------------------------
!    F_ROS = F_ROS -  k_dam(n) * CORAL(ng)%ROS(n,i,j)

!  Zooxanthellae release rate by host coral (cell cm-2 s-1)
!    Damage=exp(F_dam + 3.*F_ONOO)-1.   !Damage by ROS (F_dam) and peroxynitrite (F_ONOO)
!    Damage=exp(F_dam + F_ONOO)-1.   !Damage by ROS (F_dam) and peroxynitrite (F_ONOO)
!    Damage = exp( a_dam(n) * F_dam ) - 1.0d0   !Damage by ROS (F_dam)
!    F_Zelm  = k_Zelm(n) * Damage

    F_Zelm  = k_Zelm(n) * CORAL(ng)%ROS(n,i,j)*ZOOX(ng)%dens(n,i,j)
!    F_Zelm  = 0.0d0
    
!----- Zooxanthellae internal model -----

    CALL zooxanthellae             &
!     input parameters
      ( ng, n, i, j                & ! ng: nested grid number; n: coral compartment; i,j: position
      , date                       & ! Date (days since x or elapsed days)
      , dt                         & ! Time step (sec)
      , PFDsurf                    & ! Photon flux density (umol m-2 s-1)
      , Tamb                       & ! Temperature (oC)
      , CORAL(ng)%CO2coe(:,n,i,j)  & ! CO2* concentration in the coral tissue (umol kg-1)
      , CORAL(ng)%DOcoe (n,i,j)    & ! DO concentration in the coral tissue (umol L-1)
      , CORAL(ng)%QCe(iCt,n,i,j)   & ! Host reserve C pool (umolC cm-2)
      , F_Zelm                     & ! Zooxanthellae release rate by host coral (cell cm-2 s-1)
      , CORAL(ng)%ROS(n,i,j)       & ! ROS concentration in the coral tissue (umol L-1)
#  if defined CORAL_NUTRIENTS
      , CORAL(ng)%NO3(:,n,i,j)    & ! NO3 concentration in the coral tissue (umol kg-1)
      , CORAL(ng)%NH4(:,n,i,j)    & ! NH4 concentration in the coral tissue (umol kg-1)
      , CORAL(ng)%PO4(:,n,i,j)    & ! PO4 concentration in the coral tissue (umol kg-1)
#  endif
!   input and output parameters
      , F_QCe(:)                   & ! Organic C translocation (nmol C cm-2 s-1) *direction of Symbiont to host coral is positivell-1 s-1)
      , F_DICcoe(:)                & ! Flux of DIC (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
      , Flux_POC(:,:)              & ! Flux of POC as zooxanthellae release (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
#  if defined CORAL_NONE_CO2_EQ
      , F_CO2coe(:)                & ! Flux of DIC (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
#  endif
      , F_DOcoe                    & ! Flux of DO  (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
      , F_ROS                      & ! Flux of Reactive Oxygen Species (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
#  if defined CORAL_NUTRIENTS
      , F_QNe(:)                   & ! Organic N excretion controled by host coral (pmol cell-1 s-1)
      , F_QPe(:)                   & ! Organic P excretion controled by host coral (pmol cell-1 s-1)
      , F_NO3(:)                   & ! NO3 transport rate from host to Zooxanthellae (pmol cell-1 s-1)
      , F_NH4(:)                   & ! NH4 transport rate from host to Zooxanthellae (pmol cell-1 s-1)
      , F_PO4(:)                   & ! PO4 transport rate from host to Zooxanthellae (pmol cell-1 s-1)
      , Flux_PON(:,:)              & ! Flux of PON as zooxanthellae release (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
      , Flux_POP(:,:)              & ! Flux of POP as zooxanthellae release (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
  !      , F_ONOO                     & ! Flux of peroxynitrite  (pmol cell-1 s-1)
#  endif
!   output parameters
      , CORAL(ng)%Pg(n,i,j)        & ! Total gross photosynthetic rate (nmol cm-2 s-1)
      , Rz                         & ! Total respiration rate (nmol cm-2 s-1)
      )


!======================================================================
# else
!  ----- Gross photosynthetic rate (nmolC cm-2 s-1) ------------------------------------
!   Temperature dependent term
# if defined CORAL_TEMP_DEPENDENT
    f_temp = tempcorr2( Tamb+273.15d0, Tref_pht(n), T_A_pht(n), T_H_pht(n)  &
                      , T_AH_pht(n), T_L_pht(n), T_AL_pht(n))
# else
    f_temp = 1.d0
# endif

    CORAL(ng)%Pg(n,i,j) = Pgmax(n)*f_temp*tanh(PFDsurf/Ik(n))       &
                        * HCO3coe(iCt)/(K_HCO3(n)+HCO3coe(iCt))
    Rz = 0.0d0

!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
    F_DOcoe = F_DOcoe + CORAL(ng)%Pg(n,i,j)
    F_QCe(:)    = F_QCe(:)    + CORAL(ng)%Pg(n,i,j) *rDICcoe(:)*aC_phot_crl(1:N_Csp)
    F_DICcoe(:) = F_DICcoe(:) - CORAL(ng)%Pg(n,i,j) *rDICcoe(:)*aC_phot_crl(1:N_Csp)

# endif

!======================================================================
!     Tissue decay rate (nmol cm-2 s-1)
!======================================================================

!  Tissue decay rate (nmol cm-2 s-1)
!   Temperature dependent decay term (no dimension)
# if defined CORAL_TEMP_DEPENDENT
    f_temp = tempcorr1(Tamb+273.15d0, Tref_dec(n), T_A_dec(n) )
# else
    f_temp = 1.d0
# endif
!    f_temp=exp(Eact(n)*(TKamb-298.)/298./Rgas/TKamb)

!   QCv: Coral tissue carbon content (umolC cm-2)
!   k_decay: Tissue decay rate constant (s-1)
    F_Cdec = k_decay(n) * f_temp * CORAL(ng)%QCv(iCt,n,i,j)*1.d3 ! umolC cm-2 -> nmolC cm-2

!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
    F_QCv(:)    = F_QCv(:)    - F_Cdec *rQCv(:)
    Flux_POC(:,iLPOM) = Flux_POC(:,iLPOM) - F_Cdec *rQCv(:)*0.9d0
    Flux_POC(:,iRPOM) = Flux_POC(:,iRPOM) - F_Cdec *rQCv(:)*0.1d0

# if defined CORAL_NUTRIENTS
    F_Ndec = k_decay(n) * f_temp * CORAL(ng)%QNv(iNt,n,i,j)*1.d3 ! umolN cm-2 -> nmolN cm-2
    F_Pdec = k_decay(n) * f_temp * CORAL(ng)%QPv(iPt,n,i,j)*1.d3 ! umolP cm-2 -> nmolP cm-2
!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
    F_QNv(:)    = F_QNv(:)    - F_Ndec *rQNv(:)
    F_QPv(:)    = F_QPv(:)    - F_Pdec *rQPv(:)
    Flux_PON(:,iLPOM) = Flux_PON(:,iLPOM) - F_Ndec *rQNv(:)*0.9d0
    Flux_PON(:,iRPOM) = Flux_PON(:,iRPOM) - F_Ndec *rQNv(:)*0.1d0
    Flux_POP(:,iLPOM) = Flux_POP(:,iLPOM) - F_Pdec *rQPv(:)*0.9d0
    Flux_POP(:,iRPOM) = Flux_POP(:,iRPOM) - F_Pdec *rQPv(:)*0.1d0
# endif


!======================================================================
!     Mobilization of structural C under reserve shortage (nmol cm-2 s-1)
!======================================================================

!  Catabolism of structural tissue when the reserve runs short.  This is a pure
!  QCv -> QCe transfer, so it carries the tissue isotope ratio (rQCv) and
!  conserves carbon exactly.  The switch K_QCmob/(K_QCmob+QCe) is 1 at QCe = 0 and
!  falls towards 0 as the reserve fills, so it only acts on a starving polyp.
!  QCv_min is the structural floor that cannot be catabolised.
!  The energetic cost of autophagy itself is neglected.

    F_Cmob = k_mob(n) * max( CORAL(ng)%QCv(iCt,n,i,j)-QCv_min(n), 0.0d0 )*1.d3   &
                      * K_QCmob(n)/( K_QCmob(n) + QCe_tmp )

!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
    F_QCe(:) = F_QCe(:) + F_Cmob *rQCv(:)
    F_QCv(:) = F_QCv(:) - F_Cmob *rQCv(:)

!======================================================================
!     Respilation rate (nmol cm-2 s-1)
!======================================================================

!   Temperature dependent term
# if defined CORAL_TEMP_DEPENDENT
    f_temp = tempcorr2( Tamb+273.15d0, Tref_rsp(n), T_A_rsp(n), T_H_rsp(n)  &
                      , T_AH_rsp(n), T_L_rsp(n), T_AL_rsp(n))
# else
    f_temp = 1.d0
# endif

    f_min = min( QCe_tmp/(K_QC(n)+QCe_tmp),                      &
                 DOcoe_tmp/(K_DO(n)+DOcoe_tmp) )  !  Michaelis-Menten equation
!
    Rc = Rmax(n) * f_temp * f_min

    CORAL(ng)%R(n,i,j) = Rc + Rz

!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
    F_DOcoe = F_DOcoe - Rc
    F_QCe(:)    = F_QCe(:)    - Rc *rQCe(:)
!   Respired carbon leaves as CO2*, and CO2* is part of DIC, so it has to be
!   credited to both pools - not one or the other.  This used to be an if/else
!   that credited only F_CO2* under CORAL_NONE_CO2_EQ, leaving DIC unchanged;
!   the diagnosed HCO3- (= DIC - CO2* - CO3) then absorbed the whole
!   respiration as a loss, so carbon was created in CO2* and destroyed in
!   HCO3- every step.  In the 5 um calcifying fluid that drove CO2* to
!   178 umol L-1 against an equilibrium value near 1, and left skeletal d13C
!   6 permil off the equilibrium branch even with the kinetics run 100x fast.
    F_DICcoe(:) = F_DICcoe(:) + Rc *rQCe(:) *Rratio(n)
    F_DICcal(:) = F_DICcal(:) + Rc *rQCe(:) *(1.0d0-Rratio(n))
# if defined CORAL_NONE_CO2_EQ
    F_CO2coe(:) = F_CO2coe(:) + Rc *rQCe(:) *Rratio(n)
    F_CO2cal(:) = F_CO2cal(:) + Rc *rQCe(:) *(1.0d0-Rratio(n))
# endif
  

!======================================================================
!     Allocaion of energy produced by respiration (nJ cm-2 s-1)
!======================================================================

!   Total energy Flux supplied by respiration (nJ cm-2 s-1) 

    E_tot = E_rsp * Rc  !nJ cm-2 s-1

!  Biosynthetic demand (nmol C cm-2 s-1)
!    (1) F_Cdec  : replacement of the tissue lost to decay this step
!    (2) k_rest  : restoration of areal biomass towards QCv_max
!    (3) G/c2g   : tissue that must accompany newly deposited skeleton
!    E_bio: energy required for 1 molC biosynthesis (nJ nmol-1 = J mol-1)
!    G is clamped at zero so that dissolution (G<0) cannot credit the budget.

    F_rest_dmd = F_Cdec                                                          &
               + k_rest(n)*max( QCv_max(n)-CORAL(ng)%QCv(iCt,n,i,j), 0.0d0 )*1.d3
    F_bio_dmd  = F_rest_dmd + max( CORAL(ng)%G(n,i,j), 0.0d0 )/c2g(n)

    E_req = F_bio_dmd * E_bio ! nJ cm-2 s-1

!  Energy partition.  E_g + E_ca == E_tot holds exactly by construction, so the
!  energy budget closes whether or not respiration can meet the demand.
    E_g  = min( E_req, E_tot )   ! biosynthesis
    E_ca = E_tot - E_g           ! CaCO3 production (>= 0 since E_g <= E_tot)

!======================================================================
!     Mass fluxes related to growth (nmol cm-2 s-1)
!======================================================================

!  Total biosynthesis, funded exactly by E_g.  Deriving it from E_g (rather
!  than performing the repair unconditionally) is what keeps the mass and
!  energy budgets consistent when respiration falls short of the demand.
    F_bio   = E_g / E_bio

!  Restore areal tissue first; whatever is left funds colony extension.
    F_Crest = min( F_bio, F_rest_dmd )
    F_Cext  = F_bio - F_Crest

!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
    F_QCe  (:) = F_QCe  (:) - F_bio  *rQCe(:)
    F_QCv  (:) = F_QCv  (:) + F_Crest*rQCe(:)
    F_QCext(:) = F_QCext(:) + F_Cext *rQCe(:)

# if defined CORAL_NUTRIENTS
!  N and P follow the carbon fluxes stoichiometrically, at the current tissue
!  quota ratio.  E_bio is an energy per mol *carbon*, so it must not appear in
!  the N and P budgets.
    rNC_v  = CORAL(ng)%QNv(iNt,n,i,j)/max(CORAL(ng)%QCv(iCt,n,i,j), QC_eps)
    rPC_v  = CORAL(ng)%QPv(iPt,n,i,j)/max(CORAL(ng)%QCv(iCt,n,i,j), QC_eps)

    F_Nbio  = F_bio  *rNC_v
    F_Nrest = F_Crest*rNC_v
    F_Next  = F_Cext *rNC_v
    F_Pbio  = F_bio  *rPC_v
    F_Prest = F_Crest*rPC_v
    F_Pext  = F_Cext *rPC_v

!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
    F_QNe  (:) = F_QNe  (:) - F_Nbio  *rQNe(:)
    F_QNv  (:) = F_QNv  (:) + F_Nrest *rQNe(:)
    F_QNext(:) = F_QNext(:) + F_Next  *rQNe(:)
    F_QPe  (:) = F_QPe  (:) - F_Pbio  *rQPe(:)
    F_QPv  (:) = F_QPv  (:) + F_Prest *rQPe(:)
    F_QPext(:) = F_QPext(:) + F_Pext  *rQPe(:)
# endif

# if defined CORAL_SIZE_DYNAMICS
!!! TODO: this block still predates the F_bio / F_Crest / F_Cext split and does
!!!       not compile.  It indexes F_Cgrowth/F_Ngrowth/F_Pgrowth as arrays when
!!!       they no longer exist, reads E_m which is never assigned, divides by
!!!       CORAL(ng)%G without guarding G=0, and has a dangling line continuation
!!!       in the CORAL_NUTRIENTS branch below.  When it is reworked, QCext (and
!!!       QNext/QPext) is the pool that should fund the increase in coral cover.
    netCgrowth = ( CORAL(ng)%growth(n,i,j)-CORAL(ng)%mort(n,i,j) )  &
                   *CORAL(ng)%QCv(iCt,n,i,j)*1.0d3    ! growth rate (nmol cm-2 s-1)=(cm2 cm-2 s-1)*(umol cm-2)*1.d3
    g2c_tmp = netCgrowth/CORAL(ng)%G(n,i,j)
    mort_es = km_es(n)*( E_m - E_tot ) ! Mortality due to energy shortage
!
!---------- Coral growth (nmol cm-2 s-1) ------------
!
!    Droop model (1973) + Liebig's minimum law

#  if defined CORAL_NUTRIENTS

    F_Cgrowth(iCt) = g_max(n)*min( 1.0d0 - QC0(n)/CORAL(ng)%QCv(iCt,n,i,j) ,    &
                          min(1.0d0 - QN0(n)/CORAL(ng)%QNv(iNt,n,i,j),     &
                              1.0d0 - QP0(n)/CORAL(ng)%QPv(iPt,n,i,j) ) )  &
    F_Cgrowth(iCt) = max(F_Cgrowth(iCt), 0.0d0)
    
    F_Ngrowth(iNt) = F_Cgrowth(iCt)*CORAL(ng)%QNv(iNt,n,i,j)/CORAL(ng)%QCv(iCt,n,i,j)
    F_Pgrowth(iPt) = F_Cgrowth(iCt)*CORAL(ng)%QPv(iPt,n,i,j)/CORAL(ng)%QCv(iCt,n,i,j)

#  else
!    F_Cgrowth = g_max(n) * (1.0d0 - QC0(n)/CORAL(ng)%QC(n,i,j) )
    F_Cgrowth(iCt) = 5.0d-5 * (CORAL(ng)%QCv(iCt,n,i,j) - QC0(n))
    F_Cgrowth(iCt) = max(F_Cgrowth(iCt), 0.0d0)
#  endif
!
!----- Convert internal conditions to size dynamics parameters
!
!---------- Coral growth rate (cm cm-2 s-1) ------------
!
    CORAL(ng)%growth(n,i,j) = F_Cgrowth(iCt)/CORAL(ng)%QCv(iCt,n,i,j)*1.0d-3  ! growth rate (cm2 cm-2 s-1)
!   (cm2 cm-2 s-1)=(nmol cm-2 s-1)/(umol cm-2)*1.d-3
!
!---------- Coral mortality (cm cm-2 s-1) ------------
!
#  if defined CORAL_NUTRIENTS

    CORAL(ng)%mort(n,i,j) = km_CNP                                   &  ! mortality (cm2 cm-2 s-1) 
                    *exp(-am_CNP*                                    &  !!!!!!!!!!!!!!!!TBC
                        min( 1.0d0 - QC0(n)/CORAL(ng)%QC(iCt,n,i,j) ,    &
                         min(1.0d0 - QN0(n)/CORAL(ng)%QN(iNt,n,i,j),     &
                             1.0d0 - QP0(n)/CORAL(ng)%QP(iPt,n,i,j) )))  & 
                   +km_dam * Damage                                  & !!!!!!!!!!!!!!!TBC
                   +mort_es !!!!!!!!!!!!!!!TBC
#  else
    CORAL(ng)%mort(n,i,j) =                                   &
          km(n) *exp( aC_m*(QC0(n)-CORAL(ng)%QCv(iCt,n,i,j)) )     &
         +km_dam * Damage                                     & !!!!!!!!!!!!!!!!!TBC
         +mort_es

!    CORAL(ng)%mort(n,i,j) = min(CORAL(ng)%mort(n,i,j), 1.0d0)  !!! for Error handling

!-----------END CORAL_SIZE_DYNAMICS ------------------------------------
#  endif
# endif



!======================================================================
!     H+ flux through Ca2+ ATPase  (nmol cm-2 s-1)
!     (TA flux from coelenteron to calcifying fluid (nmol cm-2 s-1) )
!======================================================================

!  Energy for 1 mol H+ transport from coe. to cal.: E_rq_H_transport                        
    E_rq_H_transport = (2.3d0*8.31d0*(Tamb+273.15d0)                &
                       *max((pHcal-pHcoe)+0.01d0, 0.01d0)) / eeff(n)
!  Minimum energy for Ca2+ transport. ATP:Ca2+:H+ = 1:2:4
    E_rq_H_transport = max(E_rq_H_transport, 7.625d3) ! 30.5d3 J/mol /4.0d0 = 7.625d0 J/mol

!  H+ flux (nmol cm-2 s-1)
    F_H = E_ca / E_rq_H_transport

!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
    F_TAcoe = F_TAcoe - F_H
    F_TAcal = F_TAcal + F_H

!======================================================================
!     Mass fluxes between coelenteron and calcifying fluid (nmol cm-2 s-1)
!======================================================================

!   k_CO2i is a membrane permeability: CO2* crosses the lipid bilayer by
!   molecular diffusion, so each isotopologue follows its own gradient and
!   carries a kinetic fractionation.
!   k_leak is the conductivity of the paracellular leak, i.e. a bulk
!   flow.  Bulk flow does not fractionate and the carbon it carries has the
!   composition of the pool it leaves, so no per-species coefficient belongs
!   here; the composition is applied upwind below.
    k_CO2i_tmp(:) = k_CO2i(n)
# if defined CARBON_ISOTOPE
    k_CO2i_tmp(iC13) = k_CO2i_tmp(iCt)/1.0007d0
# endif
# if defined CLUMPED_ISOTOPE
    k_CO2i_tmp(iD47) = k_CO2i_tmp(iCt)/1.0007d0  !????????????????????????????????????
# endif

!   CO2* flux (nmol cm-2 s-1) through membrane permeation
!    Fpm_CO2(:)=k_CO2i(n)*(fCO2coe-fCO2cal)
    Fpm_CO2(:) = k_CO2i_tmp(:) *(CORAL(ng)%CO2coe(:,n,i,j)-CORAL(ng)%CO2cal(:,n,i,j))!*rho_sw

!   DIC leak flux (nmol cm-2 s-1) through the paracellular pathway.
!   Upwind, because this is a bulk leak rather than diffusion.  Applying the
!   per-isotopologue gradient here instead made the 13C transfer
!   disproportionate to the net carbon transfer: it pinned the calcifying fluid
!   to the photosynthetically enriched coelenteron and left the skeleton
!   several per mil too heavy.  The leak reverses within a day (DICcoe falls
!   below DICcal around midday), so the branch is genuinely exercised.
    Fleak_DIC = k_leak(n) *(CORAL(ng)%DICcoe(iCt,n,i,j)-CORAL(ng)%DICcal(iCt,n,i,j))!*rho_sw
    if ( Fleak_DIC >= 0.0d0 ) then
      Fpp_DIC(:) = Fleak_DIC *rDICcoe(:)   ! coelenteron -> calcifying fluid
    else
      Fpp_DIC(:) = Fleak_DIC *rDICcal(:)   ! calcifying fluid -> coelenteron
    end if
    Fpp_DIC(iCt) = Fleak_DIC   ! exact, whatever Iso_ratio returned for a spent pool
# if defined CORAL_NONE_CO2_EQ
!   CO2* carried by the same paracellular leak.  Because the leak is
!   non-selective, the CO2* it moves is the upstream CO2* fraction of the DIC
!   it moves - not an independent concentration gradient.  Driving it from its
!   own gradient would transport CO2* in a proportion unrelated to the bulk DIC
!   going through the same pores, and the leak's direction could even disagree
!   between the two.
    if ( Fleak_DIC >= 0.0d0 ) then
      Fleak_CO2  = Fleak_DIC * CORAL(ng)%CO2coe(iCt,n,i,j)                   &
                             / max( CORAL(ng)%DICcoe(iCt,n,i,j), C_eps )
      Fpp_CO2(:) = Fleak_CO2 *rCO2coe(:)
    else
      Fleak_CO2  = Fleak_DIC * CORAL(ng)%CO2cal(iCt,n,i,j)                   &
                             / max( CORAL(ng)%DICcal(iCt,n,i,j), C_eps )
      Fpp_CO2(:) = Fleak_CO2 *rCO2cal(:)
    end if
    Fpp_CO2(iCt) = Fleak_CO2
# endif
!   TA Leak flux (nmol cm-2 s-1) 
    Fpp_TA = k_leak(n) *(CORAL(ng)%TAcoe(n,i,j)-CORAL(ng)%TAcal(n,i,j))!*rho_sw

!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
    F_TAcoe = F_TAcoe - Fpp_TA
    F_TAcal = F_TAcal + Fpp_TA
    F_DICcoe(:) = F_DICcoe(:) - Fpm_CO2(:) - Fpp_DIC(:)
    F_DICcal(:) = F_DICcal(:) + Fpm_CO2(:) + Fpp_DIC(:)
# if defined CORAL_NONE_CO2_EQ
    F_CO2coe(:) = F_CO2coe(:) - Fpm_CO2(:) - Fpp_CO2(:)
    F_CO2cal(:) = F_CO2cal(:) + Fpm_CO2(:) + Fpp_CO2(:)
# endif

!======================================================================
!     Calcification rate (nmol cm-2 s-1)
!======================================================================
 
    if (Wargcal .ge. 1.d0) then
      CORAL(ng)%G(n,i,j)= a_surf(n)*1.1d-3*(Wargcal-1.d0)**1.63d0
    else
      CORAL(ng)%G(n,i,j)=-a_surf(n)*2.7d-2*(1.d0-Wargcal)**2.5d0
    endif

!----- Summing Fluxes (nmol cm-2 s-1)--------------------------
    F_TAcal = F_TAcal - 2.0d0*CORAL(ng)%G(n,i,j)
    F_DICcal(:) = F_DICcal(:) - CORAL(ng)%G(n,i,j) *aC_calc(1:N_Csp)*rDICcal(:)


!======================================================================
!     Time stepping (internal condition changes)
!======================================================================

!   CORAL(ng)%QC (umol cm-2)
!   Pg,R: nmol cm-2 s-1
    CORAL(ng)%QCe(:,n,i,j) = CORAL(ng)%QCe(:,n,i,j) + F_QCe(:)*1.d-3 *dt    !nmol cm-2 =1.e-3 umol cm-2
    CORAL(ng)%QCv(:,n,i,j) = CORAL(ng)%QCv(:,n,i,j) + F_QCv(:)*1.d-3 *dt    !nmol cm-2 =1.e-3 umol cm-2
    CORAL(ng)%QCr(:,n,i,j) = CORAL(ng)%QCr(:,n,i,j) + F_QCr(:)*1.d-3 *dt    !nmol cm-2 =1.e-3 umol cm-2
    CORAL(ng)%QCh(:,n,i,j) = CORAL(ng)%QCh(:,n,i,j) + F_QCh(:)*1.d-3 *dt    !nmol cm-2 =1.e-3 umol cm-2
!   QCext: carbon committed to colony extension.  Holding it in a pool (rather
!   than dropping it) keeps the organic carbon budget closed until
!   CORAL_SIZE_DYNAMICS consumes it to grow new coral cover.
    CORAL(ng)%QCext(:,n,i,j) = CORAL(ng)%QCext(:,n,i,j) + F_QCext(:)*1.d-3 *dt
# if defined CORAL_NUTRIENTS
    CORAL(ng)%QNext(:,n,i,j) = CORAL(ng)%QNext(:,n,i,j) + F_QNext(:)*1.d-3 *dt
    CORAL(ng)%QPext(:,n,i,j) = CORAL(ng)%QPext(:,n,i,j) + F_QPext(:)*1.d-3 *dt
# endif

!    DIC & TA (umol L-1) in calcified fulid
    CORAL(ng)%DICcal(:,n,i,j) = CORAL(ng)%DICcal(:,n,i,j)         &
                               + F_DICcal(:)/hcal *dt    !nmol cm-3 s-1 = 1./1.023 umol kg-1 s-1

    CORAL(ng)%TAcal (n,i,j) = CORAL(ng)%TAcal (n,i,j)             &
                               + F_TAcal/hcal *dt    !nmol cm-3 s-1 = 1./1.023 umol kg-1 s-1

!    DIC & TA (umol L-1) in coelectron
    CORAL(ng)%DICcoe(:,n,i,j) = CORAL(ng)%DICcoe(:,n,i,j)         &
                               + F_DICcoe(:)/hcoe *dt   !nmol cm-3 s-1 = 1./1.023 umol kg-1 s-1

    CORAL(ng)%TAcoe (n,i,j) = CORAL(ng)%TAcoe (n,i,j)             &
                               + F_TAcoe/hcoe *dt   !nmol cm-3 s-1 = 1./1.023 umol kg-1 s-1

!    DO (umol L-1) in coelectron
    CORAL(ng)%DOcoe (n,i,j) = CORAL(ng)%DOcoe (n,i,j)             &
                              + F_DOcoe/hcoe *dt   !nmol cm-3 s-1 = 1. umol L-1 s-1
    CORAL(ng)%DOcoe (n,i,j)=max( CORAL(ng)%DOcoe (n,i,j),0.d0) !Error handring

# if defined CORAL_NONE_CO2_EQ

    kp1(:)=kp1_Johnson1982(TKamb, Samb)
    km1(:)=km1_Johnson1982(TKamb, Samb)
    kp4(:)=kp4_Johnson1982(TKamb, Samb)
    km4(:)=km4_Johnson1982(TKamb, Samb)
#  if defined CARBON_ISOTOPE
!   Kinetic isotope effects on the CO2* <-> HCO3- interconversion.
!
!   Paths 1 (hydration) and 4 (hydroxylation) connect the same pair of species,
!   so the equilibrium fractionation they imply must agree with each other, and
!   with the equilibrium branch of this model (a_db_Zhang1995, which partitions
!   13C among the species when CORAL_NONE_CO2_EQ is off).  The published KIEs
!   are independent estimates and do not satisfy that: taken at face value they
!   give +8.9 permil for hydration but +15.8 permil for hydroxylation.  Path 4
!   overtakes path 1 above about pH 8.5, so the implied equilibrium would drift
!   from +11 permil in the coelenteron to +15 permil in the calcifying fluid,
!   against the +9.1 permil the equilibrium branch uses.  Switching
!   CORAL_NONE_CO2_EQ on and off would then measure that offset rather than the
!   disequilibrium effect being studied.
!
!   So keep the forward KIEs, which carry the kinetic signal, and derive the
!   reverse ones from the equilibrium fractionation - the same discipline the
!   bulk constants already follow (km1 = kp1/K1, km4 = kp4*Kw/K1).  The
!   published km1 of 1.022 already agrees with what this requires (1.0222);
!   only km4 (1.027 against 1.0202) was out of line.  Deriving them also makes
!   the temperature dependence follow a_db_Zhang1995 automatically.
    a_eqbd = 1.0d0/a_db_Zhang1995(TKamb-273.15d0)
    kp1(iC13)=kp1(iCt)/1.013d0
    kp4(iC13)=kp4(iCt)/1.011d0
    km1(iC13)=km1(iCt)/(1.013d0*a_eqbd)
    km4(iC13)=km4(iCt)/(1.011d0*a_eqbd)
#  endif
#  if defined CLUMPED_ISOTOPE
    kp1(iD47)=kp1(iCt)/1.013d0  !??????????????????????????????????????????????????????
    km1(iD47)=km1(iCt)/1.022d0  !??????????????????????????????????????????????????????
    kp4(iD47)=kp4(iCt)/1.011d0  !??????????????????????????????????????????????????????
    km4(iD47)=km4(iCt)/1.027d0  !??????????????????????????????????????????????????????
#  endif

    cHcoe =10.d0**(-pHcoe)
    cOHcoe=Kw_Millero1995(TKamb, Samb)/cHcoe
    
    cHcal =10.d0**(-pHcal)
    cOHcal=Kw_Millero1995(TKamb, Samb)/cHcal

!   [CO2*] (umol L-1), exponential update.
!
!   dC/dt = S - a*C  is integrated exactly for constant coefficients, where
!   a = kp1 + kp4*[OH-] is the loss rate and S collects the transport flux and
!   the production from HCO3-.  Explicit Euler was unconditionally unstable
!   here: a reaches 1.3 s-1 at pH 10.5 and 8 s-1 at pH 11.3, against a coral
!   substep of 0.05 s, and it drove CO2* negative into a hard Stop.  The
!   exponential form is stable at any pH and preserves positivity whenever
!   S >= 0.
!   Rate units: kp1 and km4 are s-1; kp4 and km1 are kg mol-1 s-1 and pair with
!   [OH-] and [H+] in mol kg-1, so every term is (s-1) x (carbon concentration)
!   and the umol L-1 carbon units carry through unchanged.

!    [CO2*] (umol L-1) in coelectron
    a_los(:) = kp1(:) + kp4(:)*cOHcoe
    b_gen(:) = ( km1(:)*cHcoe + km4(:) )*HCO3coe(:) + F_CO2coe(:)/hcoe
    CO2ss(:) = b_gen(:)/a_los(:)
    CORAL(ng)%CO2coe(:,n,i,j) = CO2ss(:)                                     &
        + ( CORAL(ng)%CO2coe(:,n,i,j) - CO2ss(:) )*exp( -a_los(:)*dt )

!    [CO2*] (umol L-1) in calcified fulid
    a_los(:) = kp1(:) + kp4(:)*cOHcal
    b_gen(:) = ( km1(:)*cHcal + km4(:) )*HCO3cal(:) + F_CO2cal(:)/hcal
    CO2ss(:) = b_gen(:)/a_los(:)
    CORAL(ng)%CO2cal(:,n,i,j) = CO2ss(:)                                     &
        + ( CORAL(ng)%CO2cal(:,n,i,j) - CO2ss(:) )*exp( -a_los(:)*dt )

!   A negative CO2* can now only come from a transport sink large enough to
!   make S negative, which is a physical over-draw rather than a time-step
!   problem.  Clamp instead of aborting a long run, but note that the clamp
!   breaks carbon conservation, so a non-zero counter here needs investigating.
    if( minval(CORAL(ng)%CO2coe(:,n,i,j))<0.0d0 .or.                         &
        minval(CORAL(ng)%CO2cal(:,n,i,j))<0.0d0 ) then
      n_CO2clip = n_CO2clip + 1
      if( n_CO2clip<=10 ) then
        write(*,*) 'WARNING: negative CO2* clipped at date',date,            &
                   ' coe',CORAL(ng)%CO2coe(iCt,n,i,j),                       &
                   ' cal',CORAL(ng)%CO2cal(iCt,n,i,j)
      endif
      CORAL(ng)%CO2coe(:,n,i,j) = max( CORAL(ng)%CO2coe(:,n,i,j), 0.0d0 )
      CORAL(ng)%CO2cal(:,n,i,j) = max( CORAL(ng)%CO2cal(:,n,i,j), 0.0d0 )
    endif
# endif

# if defined CORAL_ZOOXANTHELLAE
!!!
!!! ----- Zooxanthellae interaction ----------------------------------------------------
!!!
!    ROS (umol/L) mass balance

    CORAL(ng)%ROS(n,i,j)=CORAL(ng)%ROS(n,i,j) + F_ROS/htis *dt            !umol L-1
    CORAL(ng)%ROS(n,i,j)=max(CORAL(ng)%ROS(n,i,j),0.d0) !Error handring

# endif

!======== CORAL_TESTMODE ===============================================================
# if defined CORAL_TESTMODE

!------ Calculation of d13C -------------------------
#  if defined CARBON_ISOTOPE      
    d13C_DICamb  = delta_from_Ci_Ct( DICamb (iC13), DICamb (iCt), R13C_VPDB )
    d13C_CO2amb  = delta_from_Ci_Ct( CO2amb (iC13), CO2amb (iCt), R13C_VPDB )
    d13C_HCO3amb = delta_from_Ci_Ct( HCO3amb(iC13), HCO3amb(iCt), R13C_VPDB )
    d13C_CO3amb  = delta_from_Ci_Ct( CO3amb (iC13), CO3amb (iCt), R13C_VPDB )
    d13C_DICcoe  = delta_from_Ci_Ct( CORAL(ng)%DICcoe(iC13,n,i,j), CORAL(ng)%DICcoe(iCt,n,i,j), R13C_VPDB )
    d13C_CO2coe  = delta_from_Ci_Ct( CORAL(ng)%CO2coe(iC13,n,i,j), CORAL(ng)%CO2coe(iCt,n,i,j), R13C_VPDB )
    d13C_HCO3coe = delta_from_Ci_Ct( HCO3coe(iC13), HCO3coe(iCt), R13C_VPDB )
    d13C_CO3coe  = delta_from_Ci_Ct( CO3coe (iC13), CO3coe (iCt), R13C_VPDB )
    d13C_DICcal  = delta_from_Ci_Ct( CORAL(ng)%DICcal(iC13,n,i,j), CORAL(ng)%DICcal(iCt,n,i,j), R13C_VPDB )
    d13C_CO2cal  = delta_from_Ci_Ct( CORAL(ng)%CO2cal(iC13,n,i,j), CORAL(ng)%CO2cal(iCt,n,i,j), R13C_VPDB )
    d13C_HCO3cal = delta_from_Ci_Ct( HCO3cal(iC13), HCO3cal(iCt), R13C_VPDB )
    d13C_CO3cal  = delta_from_Ci_Ct( CO3cal (iC13), CO3cal (iCt), R13C_VPDB )

    d13C_QCe     = delta_from_Ci_Ct( CORAL(ng)%QCe(iC13,n,i,j), CORAL(ng)%QCe(iCt,n,i,j), R13C_VPDB )
    d13C_QCv     = delta_from_Ci_Ct( CORAL(ng)%QCv(iC13,n,i,j), CORAL(ng)%QCv(iCt,n,i,j), R13C_VPDB )
    d13C_QCr     = delta_from_Ci_Ct( CORAL(ng)%QCr(iC13,n,i,j), CORAL(ng)%QCr(iCt,n,i,j), R13C_VPDB )
    d13C_QCh     = delta_from_Ci_Ct( CORAL(ng)%QCh(iC13,n,i,j), CORAL(ng)%QCh(iCt,n,i,j), R13C_VPDB )

    d13C_G       = delta_from_Ci_Ct(  CORAL(ng)%G(n,i,j)*aC_calc(iC13)*rDICcal(iC13) &
                                    , CORAL(ng)%G(n,i,j), R13C_VPDB  )

#  endif

!------------------------------------------------------------------------
! Print section

#  if defined CORAL_BORON_ISOTOPE
    d11Barg = d11B_BOH4_frompHd11BT(pHcal, 39.5d0, TKamb, Samb)
#  endif

! Coral record calculation section
!   Must precede the print sections below, which output d13C_arg (and d11Barg)
!   as assigned here. With the accumulation placed after the prints, d13C_arg
!   was undefined on the first call and one substep stale on later ones.

    S_PFD_dt(n)  = S_PFD_dt(n)+PFD*dt
    S_Gn_dt(:,n) = S_Gn_dt(:,n)+CORAL(ng)%G (n,i,j)*aC_calc(1:N_Csp)*rDICcal(:) *dt
    S_Pg_dt(n)   = S_Pg_dt(n)+CORAL(ng)%Pg(n,i,j)*dt
    S_R_dt(n)    = S_R_dt(n) +CORAL(ng)%R(n,i,j) *dt
#  if defined CARBON_ISOTOPE
    d13C_arg = delta_from_Ci_Ct( S_Gn_dt(iC13,n), S_Gn_dt(iCt,n), R13C_VPDB)
#  endif
#  if defined CORAL_BORON_ISOTOPE
    S_d11BargxGn_dt(n)=S_d11BargxGn_dt(n)+d11Barg*CORAL(ng)%G (n,i,j)*dt
#  endif

    IF( date*86400.0d0 >= dsec(n) ) THEN
      if(dsec(n) == 0.0d0) then
        dsec(n)=date*86400.0d0+CORAL_OUTPUT_INTERVAL*60.0d0
        ! Write lavels at the first step
        write(10+n,'(*(g0:,", "))') 'time', 'PFD'               &
          ,'Pg', 'R', 'Pn', 'G','QCe','QCv','QCr','QCh'         &
          ,'TAcal',  'TAcoe',  'TAamb'                          &
          ,'DICcal', 'DICcoe', 'DICamb'                         &
          ,'DOcoe', 'DOamb'                                     &
          ,'pHcal','pHcoe','pHamb','Wacal','Waamb'              &
          ,'fCO2cal','fCO2coe','fCO2amb'                        &
          ,'CO2aqcal','HCO3cal','CO3cal'                        &
          ,'CO2aqcoe','HCO3coe','CO3coe'                        &
# if defined CARBON_ISOTOPE
          , 'd13C_DICamb', 'd13C_CO2amb', 'd13C_HCO3amb', 'd13C_CO3amb'           &
          , 'd13C_DICcoe', 'd13C_CO2coe', 'd13C_HCO3coe', 'd13C_CO3coe'           &
          , 'd13C_DICcal', 'd13C_CO2cal', 'd13C_HCO3cal', 'd13C_CO3cal'           &
          , 'd13C_QCe', 'd13C_QCv', 'd13C_QCr', 'd13C_QCh', 'd13C_G', 'd13C_arg'  &
# endif
# if defined CORAL_ZOOXANTHELLAE
          ,'ROS','Rz', 'F_Csec', 'F_ROS','F_detox','F_dam'      &
# endif
# if defined CORAL_BORON_ISOTOPE
          ,'d11Barg'                                            &
# endif
          ,'LDOCuptake','RDOCuptake'                            &
          ,'LPOCuptake','RPOCuptake','CPOCuptake'               &
# if defined CORAL_INGESTION
          ,'ZOOuptake'                                          &
# endif
# if defined CORAL_SIZE_DYNAMICS
          ,'growth','mort','Damage'                             &
# endif
          ,'E_ca','F_bio','F_Crest','F_Cext','F_Cmob','F_Cdec','QCext'  &
          ,'Si_DIC','Si_DO', 'F_H'

      else
        dsec(n)=dsec(n)+CORAL_OUTPUT_INTERVAL*60.0d0
      endif
       
      write(10+n,'(*(g0:,", "))') date, PFD                                      &
       , CORAL(ng)%Pg(n,i,j), CORAL(ng)%R (n,i,j)                                &
       , CORAL(ng)%Pg(n,i,j)-CORAL(ng)%R (n,i,j), CORAL(ng)%G (n,i,j)            &
       , CORAL(ng)%QCe(iCt,n,i,j), CORAL(ng)%QCv(iCt,n,i,j)                      &
       , CORAL(ng)%QCr(iCt,n,i,j), CORAL(ng)%QCh(iCt,n,i,j)                      &
       , CORAL(ng)%TAcal(n,i,j), CORAL(ng)%TAcoe(n,i,j),TAamb                    &
       , CORAL(ng)%DICcal(iCt,n,i,j), CORAL(ng)%DICcoe(iCt,n,i,j),DICamb(iCt)    &
       , CORAL(ng)%DOcoe(n,i,j), DOamb                                           &
       , pHcal, pHcoe, pHamb, Wargcal, Wargamb                                   &
       , fCO2cal, fCO2coe, fCO2amb                                               &
       , CORAL(ng)%CO2cal(iCt,n,i,j), HCO3cal(iCt),CO3cal(iCt)                   &
       , CORAL(ng)%CO2coe(iCt,n,i,j), HCO3coe(iCt),CO3coe(iCt)                   &
#  if defined CARBON_ISOTOPE
       , d13C_DICamb, d13C_CO2amb, d13C_HCO3amb, d13C_CO3amb                     &
       , d13C_DICcoe, d13C_CO2coe, d13C_HCO3coe, d13C_CO3coe                     &
       , d13C_DICcal, d13C_CO2cal, d13C_HCO3cal, d13C_CO3cal                     &
       , d13C_QCe, d13C_QCv, d13C_QCr, d13C_QCh, d13C_G, d13C_arg                &
#  endif
#  if defined CORAL_ZOOXANTHELLAE
! TODO アウトプット未検討
       , CORAL(ng)%ROS(n,i,j), Rz, F_Csec, F_zROS, F_detox, F_dam                &
#  endif
#  if defined CORAL_BORON_ISOTOPE
       , d11Barg                                                                 &
#  endif
       , Flux_DOC(iCt,:)                                                         &
       , Flux_POC(iCt,:)                                                         &
#  if defined CORAL_INGESTION
       , Flux_ZooC(iCt,:)                                                        &
#  endif
#  if defined CORAL_SIZE_DYNAMICS
       , CORAL(ng)%growth(n,i,j), CORAL(ng)%mort(n,i,j) , Damage                 &
#  endif
       , E_ca, F_bio, F_Crest, F_Cext, F_Cmob, F_Cdec                             &
       , CORAL(ng)%QCext(iCt,n,i,j), Si_DIC(iCt), Si_DO, F_H
    END IF

!    IF(mod(int(date*86400.0d0), int(CORAL_AVERAGE_INTERVAL*86400.0d0))==0) THEN
    IF( date >= dday(n) ) THEN   
      if(dday(n) == 0.0d0) then
        dday(n)=date+CORAL_AVERAGE_INTERVAL
        ! Write lavels at the first step
        write(20+n,'(*(g0:,", "))') 'day'     &
          ,'S_PFD_dt'                         &   ! Photon flux density (mol m-2 d-1)
# if defined CARBON_ISOTOPE
!          ,'S_d13CargxGn_dt'                  &
          ,'d13Carg'                          &   ! d13C
!          ,'S_d13C_QC_dt'                     &   ! 1 day avaraged value of d13C_QC
# endif
# if defined CORAL_BORON_ISOTOPE
          ,'d11Barg'                          & 
# endif
          ,'S_Pg_dt'                          &   ! Gross photosynthesis rate (umol cm-2 d-1)
          ,'S_R_dt'                           &   ! Respiration rate (umol cm-2 d-1)
          ,'S_Gn_dt'                          &   ! Calcification rate (umol cm-2 d-1)
# if defined CARBON_ISOTOPE
          ,'S_Gn_13C_dt'                      &   ! Calcification rate (umol cm-2 d-1)
# endif
          ,'S_Pn_dt'                              ! Net photosynthesis rate (umol cm-2 d-1)

      else
        dday(n)=dday(n)+CORAL_AVERAGE_INTERVAL
      endif

      write(20+n,'(*(g0:,", "))') date    &
       , S_PFD_dt(n)*1.d-6                &   ! Photon flux density (mol m-2 d-1)
#  if defined CARBON_ISOTOPE
       , d13C_arg                         &   ! 1 day avaraged value of d13C_QC
#  endif
#  if defined CORAL_BORON_ISOTOPE
       , S_d11BargxGn_dt(n)/S_Gn_dt(n)    & 
#  endif
       , S_Pg_dt(n)*1.d-3                 &   ! Gross photosynthesis rate (umol cm-2 d-1)
       , S_R_dt(n)*1.d-3                  &   ! Respiration rate (umol cm-2 d-1)
       , S_Gn_dt(:,n)*1.d-3               &   ! Calcification rate (umol cm-2 d-1)
       , (S_Pg_dt(n)-S_R_dt(n))*1.d-3         ! Net photosynthesis rate (umol cm-2 d-1)
       
      S_PFD_dt(n)=0.d0
      S_Gn_dt(:,n)=0.d0
      S_Pg_dt(n)=0.d0
      S_R_dt(n)=0.d0
#  if defined CARBON_ISOTOPE
!      S_d13CargxGn_dt(n)=0.d0
#  endif
#  if defined CORAL_BORON_ISOTOPE
      S_d11BargxGn_dt(n)=0.d0
#  endif
    END IF
# endif

    RETURN

  END SUBROUTINE coral_polyp
    
!!! **********************************************************************
!!!  Mass transfer function
!!! **********************************************************************
! Falter et al., (2016) Geophys. Res. Lett. 43: 9764-9772
! Chan et al., (2016) Frontiers in Marine Science 3:
! Shapiro et al., (2014) PNAS 111: 13391-13396

  real(8) function S_i(tau,D,ak,Eosc) ! (m s-1)
    implicit none
    real(8), intent(in) :: tau  ! Bottom shear stress (N m-2)
    real(8), intent(in) :: D    ! Molecular diffusion coefficient (m2 s-1)
    real(8), intent(in) :: ak   ! Scaling coefficient (Falter et al., 2016 eq.8)
                                ! 260 +- 20: most experimental reef communities
                                ! 300-400 (median 340): natural reef communities
    real(8), intent(in) :: Eosc ! Ratio of mass transfer rates under oscillatory
                                ! to unidirectional flow (Falter et al., 2016);
                                ! 1.1: pure wave-driven oscillatory flow
                                ! 1.0: pure unidirectional flow
!   S = ak * Eosc * tau^0.4 * Sc^-0.6   is equation (8) of Falter, Lowe & Zhang
!   (2016) GRL 43:9764-9771.  S comes out in m d-1, hence the /86400 below.
!   tau MUST be the Falter tau_bot = 0.5*rho*C_D*U_inf^2 (their equation (3));
!   see the comment on tau in mod_input.F - the factor 0.5 is part of the
!   calibration of ak and must not be removed.
    
    real(8), parameter :: vis_sw = 0.94d-6  ! kinematic viscosity   (m2 s-1)
    real(8), parameter :: d_DBL = 1.0d-3    ! Maximum boundary layer depth (m)
                                            ! ~1 mm: due to vortical ciliary flows (Shapiro et al., 2014)
    real(8) :: Sc               ! Schmidt number
    real(8) :: S_high,S_low
    
    Sc = vis_sw/D
    S_high = ak*Eosc*tau**0.4d0*Sc**(-0.6d0)/86400.0d0  !!! day to sec
    S_low  = D/d_DBL
    
    S_i=max(S_high, S_low)
    
    return
  end function S_i


# if defined CORAL_ZOOXANTHELLAE

!!! **********************************************************************
!!!  Zooxanthellae population dynamics
!!! **********************************************************************

  SUBROUTINE zooxanthellae &
!   input parameters
    ( ng, n, i, j  & ! ng: nested grid number; n: coral compartment; i,j: position
    , date         & ! Date (days since x or elapsed days)
    , dt           & ! Time step (sec)
    , PFDsurf      & ! Photon flux density (umol m-2 s-1)
    , Tamb         & ! Temperature (oC)
    , CO2coe       & ! CO2*(aq) concentration in the coral tissue (umol kg-1)
    , DOcoe        & ! DO concentration in the coral tissue (umol L-1)
    , QCcr         & ! Host reserve C pool (umolC cm-2)
    , F_Zelm       & ! Zooxanthellae release rate by host coral (cell cm-2 s-1)
    , ROS          & ! ROS concentration in the coral tissue (umol L-1)
#  if defined CORAL_NUTRIENTS
    , NO3          & ! NO3 concentration in the coral tissue (umol kg-1)
    , NH4          & ! NH4 concentration in the coral tissue (umol kg-1)
    , PO4          & ! PO4 concentration in the coral tissue (umol kg-1)
#  endif
!   input and output parameters
    , F_QCe        & ! Organic C translocation (nmol C cm-2 s-1) *direction of Symbiont to host coral is positive
    , F_DIC        & ! Flux of DIC (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
    , F_POC        & ! Flux of POC as zooxanthellae release (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
#  if defined CORAL_NONE_CO2_EQ
    , F_CO2        & ! Flux of CO2 (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
#  endif
    , F_DO         & ! Flux of DO  (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
    , F_ROS        & ! Flux of Reactive Oxygen Species (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
#  if defined CORAL_NUTRIENTS
    , F_QNe        & ! Organic N excretion controled by host coral (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
    , F_QPe        & ! Organic P excretion controled by host coral (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
    , F_NO3        & ! NO3 transport rate from host to Zooxanthellae (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
    , F_NH4        & ! NH4 transport rate from host to Zooxanthellae (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
    , F_PO4        & ! PO4 transport rate from host to Zooxanthellae (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
    , F_PON        & ! Flux of PON as zooxanthellae release (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
    , F_POP        & ! Flux of POP as zooxanthellae release (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
!    , F_ONOO       & ! Flux of peroxynitrite (nmol cm-2 s-1) *direction of Symbiont to host coral is positive
#  endif
!   output parameters
    , Pg           & ! Total gross photosynthetic rate (nmol cm-2 s-1)
    , Rz           & ! Total respiration rate (nmol cm-2 s-1)
    )
!-----------------------------------------------------------------------

    USE mod_marine_comet_param
    USE mod_geochem

    implicit none

!   input parameters
    integer, intent(in) :: ng, n, i, j
    real(8), intent(in) :: date
    real(8), intent(in) :: dt
    real(8), intent(in) :: PFDsurf
    real(8), intent(in) :: Tamb
    real(8), intent(in) :: CO2coe(N_Csp), DOcoe
    real(8), intent(in) :: QCcr
    real(8), intent(in) :: F_Zelm
    real(8), intent(in) :: ROS
#  if defined CORAL_NUTRIENTS
    real(8), intent(in) :: NO3(N_Nsp), NH4(N_Nsp)
    real(8), intent(in) :: PO4(N_Psp)
#  endif
!   input and output parameters
    real(8), intent(inout) :: F_QCe(N_Csp)
    real(8), intent(inout) :: F_DIC(N_Csp)
    real(8), intent(inout) :: F_POC(N_Csp,Npom)
#  if defined CORAL_NONE_CO2_EQ
    real(8), intent(inout) :: F_CO2(N_Csp)
#  endif
    real(8), intent(inout) :: F_DO, F_ROS
#  if defined CORAL_NUTRIENTS
    real(8), intent(inout) :: F_QNe(N_Nsp)
    real(8), intent(inout) :: F_QPe(N_Psp)
    real(8), intent(inout) :: F_NO3(N_Nsp), F_NH4(N_Nsp)
    real(8), intent(inout) :: F_PO4(N_Psp)
    real(8), intent(inout) :: F_PON(N_Nsp,Npom)
    real(8), intent(inout) :: F_POP(N_Psp,Npom)
!    real(8), intent(inout) :: F_ONOO
#  endif
!   output parameters
    real(8), intent(out) :: Pg
    real(8), intent(out) :: Rz
!    real(8), intent(out) :: F_Zmort

!------------Set Constants  ----------------------------------
!----- Zooxanthella physica condition ---------------------------
    real(8), parameter :: V_zoox = 5.0d-10   ! Volume of zooxanthellae (cm3/cells) ~300 um3 (Fujise et al. 2018)
                             ! ~500 um3 =5.e-10 cm3 (e.g. Jone 1997; Jones and Yellowlees 1997)
!----- Respitration constants ---------------------------
    real(8), parameter :: Rzmax  = 0.0d0!5.0d-6  ! Maximum respiration rate (pmol cell-1 s-1)
                                           ! ~0.1 (pmol cell-1 h-1) = 2.8d-5 (pmol cell-1 s-1) (Suggett et al., 2008)
    real(8), parameter :: K_zQCe = 50.0d0   ! (pmolC cell-1) (Asssumed)
    real(8), parameter :: K_DO   = 5.d0    ! ca. 10 (umolO2 L-1) Shick et al. (1990) *Tuned value

    real(8), parameter :: p2r   = 0.25d0    ! molC respiration/(molC protain) required respiration rate for 1 molC biosynthesis
    real(8), parameter :: C_dec = 1.0d-6   ! (pmol cell-1 s-1) Decay rate 

!----- C translocation constants ---------------------------
    real(8), parameter :: QC0 =  50.0d0    ! (pmolC/cell)  Minimal cell quota  ! 66 pmol/cell: Tanaka et al 2018;  600-1400 pgC cell-1: Muller-Parker et al., 1994)
    real(8), parameter :: QCm = 120.0d0    ! (pmolC/cell)  Maximum cell quota  ! 66 pmol/cell: Tanaka et al 2018;  600-1400 pgC cell-1: Muller-Parker et al., 1994)
    real(8), parameter :: u_z2c = 1.0d-6   ! (s-1)  Cell-quota specific carbon translocation rate from zoox to host (Assumed)
    real(8), parameter :: u_c2z = 5.0d-7   ! (pmolC cell-1 (umol cm-2)-1 s-1)  Cell-quota specific carbon translocation rate from host to zoox (Assumed)

!----- Chl dynamics constants ---------------------------
    real(8), parameter :: QCzr_max  = 20.0d0  ! Target QCr value (pmol cell-1)  (Asssumed)

#  if defined CORAL_NUTRIENTS
    real(8), parameter :: QN0 = 1.1d0  ! (pmolN/cell)  calculated from C:N:P = 116:16:1
    real(8), parameter :: QP0 = 0.07d0 ! (pmolP/cell) 
#  endif

#  if defined CORAL_NUTRIENTS
!----- Nutrients related parameters -------------------

#  endif

!----- Population dynamics parameters -------------------

    real(8), parameter :: u_max  = 5.0d-5 ! Maximum reproduction rate (pmol cell-1 s-1)       !!! Tuning
    real(8), parameter :: rg2c   = 2.0d0  ! Conversion factor from growth respiration to reproduction (no dimension)
    real(8), parameter :: kC_sec = 2.0d-6 ! Mass transfer velocity of secreted organic matter (s-1) !!! Tuning

    real(8), parameter :: km_CNP = 1.d-8 ! (cell cm-2 s-1)  !!!!!!!!!!!!! TBD
    real(8), parameter :: am_CNP = 1.d0
    real(8), parameter :: km_ROS = 1.d-11 !                  !!!!!!!!!!!! TBD
    real(8), parameter :: km_min = 1.d-14   ! (cell cm-2 s-1)  !!!!!!!!!! TBD
    real(8), parameter :: km = 1.d-2   ! (cell cm-2 s-1)  !!!!!!!!!!!!!! TBD

! ----------------------------------------------------------
    real(8) :: F_zQCe(N_Csp)
    real(8) :: F_zQCv(N_Csp)
    real(8) :: F_zQCr(N_Csp)
    real(8) :: F_zQCh(N_Csp)
    real(8) :: F_zROS, F_zCO2(N_Csp), F_zDO
    real(8) :: F_zdens
    real(8) :: F_zPOC(N_Csp,Npom)
#  if defined CORAL_NUTRIENTS
    real(8) :: F_zQNe(N_Nsp)
    real(8) :: F_zQNv(N_Nsp)
    real(8) :: F_zQNr(N_Nsp)
    real(8) :: F_zQNh(N_Nsp)
    real(8) :: F_zQPe(N_Psp)
    real(8) :: F_zQPv(N_Psp)
    real(8) :: F_zQPr(N_Psp)
    real(8) :: F_zQPh(N_Psp)
    real(8) :: F_zNO3(N_Nsp), F_zNH4(N_Nsp)
    real(8) :: F_zPO4(N_Psp)
    real(8) :: F_zPON(N_Nsp,Npom),F_zPOP(N_Psp,Npom)
!    real(8) :: F_ONOO
    real(8) :: rNC, rPC
#  endif
    real(8) :: rCO2(N_Csp)
    real(8) :: rQCe(N_Csp),rQCv(N_Csp),rQCr(N_Csp),rQCh(N_Csp)
    real(8) :: rQNe(N_Nsp),rQNv(N_Nsp),rQNr(N_Nsp),rQNh(N_Nsp)
    real(8) :: rQPe(N_Psp),rQPv(N_Psp),rQPr(N_Psp),rQPh(N_Psp)
!----- Zooxanthella physica condition ---------------------------
    real(8) :: Cg_bio  ! Gross biosyntesis rate (pmolC cell-1 s-1)
    real(8) :: Cn_bio  ! Net biosyntesis rate (pmolC cell-1 s-1)
    real(8) :: Rzm     ! Maximum respiration rate at the present condition (pmolC cell-1 s-1) 
    real(8) :: Rzrq    ! Required respiration rate for biosynthesis (pmolC cell-1 s-1) 
!    real(8) :: F_zSO   ! Flux of Superoxide (O2-) from photosystem (pmol cell-1 s-1)
    real(8) :: f_min    

#  if defined CORAL_NUTRIENTS
!----- Nutrients related parameters -------------------

#  endif
!----- Population dynamics parameters -------------------
    real(8) ::  Morta
    real(8) ::  Repro, Death

#  if defined CORAL_TESTMODE
!  Output
!    real(8), parameter :: CORAL_OUTPUT_INTERVAL  = 5.0d0    ! Output interval (min)
    real(8), save :: dsec(Ncl) = 0.d0 !sec
#  endif
    integer :: isp
    real(8) :: cff

!===============================================================

!---- Preparation --------------------
    F_zQCe(:) = 0.0d0
    F_zQCv(:) = 0.0d0
    F_zQCr(:) = 0.0d0
    F_zQCh(:) = 0.0d0
    F_zCO2(:) = 0.0d0
    F_zDO  = 0.0d0
    F_zROS = 0.0d0
    F_zdens = -F_Zelm
#  if defined CORAL_NUTRIENTS
    F_zQNe(:) = 0.0d0
    F_zQNv(:) = 0.0d0
    F_zQNr(:) = 0.0d0
    F_zQNh(:) = 0.0d0
    F_zQPe(:) = 0.0d0
    F_zQPv(:) = 0.0d0
    F_zQPr(:) = 0.0d0
    F_zQPh(:) = 0.0d0
    F_zNO3(:) = 0.0d0
    F_zNH4(:) = 0.0d0
    F_zPO4(:) = 0.0d0
!    F_ONOO = 0.0d0
    rNC = ZOOX(ng)%QN(iNt,n,i,j)/ZOOX(ng)%QC(iCt,n,i,j)
    rPC = ZOOX(ng)%QP(iPt,n,i,j)/ZOOX(ng)%QC(iCt,n,i,j)
#  endif
!----- Isotope ratio calculation ---------------------------
    DO isp=1,N_Csp
      rCO2(isp) = Iso_ratio( CO2coe(isp), CO2coe(iCt) )
      rQCe(isp) = Iso_ratio( ZOOX(ng)%QCe(isp,n,i,j), ZOOX(ng)%QCe(iCt,n,i,j) )
      rQCv(isp) = Iso_ratio( ZOOX(ng)%QCv(isp,n,i,j), ZOOX(ng)%QCv(iCt,n,i,j) )
      rQCr(isp) = Iso_ratio( ZOOX(ng)%QCr(isp,n,i,j), ZOOX(ng)%QCr(iCt,n,i,j) )
      rQCh(isp) = Iso_ratio( ZOOX(ng)%QCh(isp,n,i,j), ZOOX(ng)%QCh(iCt,n,i,j) )
    END DO
#  if defined CORAL_NUTRIENTS
    DO isp=1,N_Nsp
      rQNe(isp) = Iso_ratio( ZOOX(ng)%QNe(isp,n,i,j), ZOOX(ng)%QNe(iNt,n,i,j) )
      rQNv(isp) = Iso_ratio( ZOOX(ng)%QNv(isp,n,i,j), ZOOX(ng)%QNv(iNt,n,i,j) )
      rQNr(isp) = Iso_ratio( ZOOX(ng)%QNr(isp,n,i,j), ZOOX(ng)%QNr(iNt,n,i,j) )
      rQNh(isp) = Iso_ratio( ZOOX(ng)%QNh(isp,n,i,j), ZOOX(ng)%QNh(iNt,n,i,j) )
    END DO
    DO isp=1,N_Psp
      rQPe(isp) = Iso_ratio( ZOOX(ng)%QPe(isp,n,i,j), ZOOX(ng)%QPe(iPt,n,i,j) )
      rQPv(isp) = Iso_ratio( ZOOX(ng)%QPv(isp,n,i,j), ZOOX(ng)%QPv(iPt,n,i,j) )
      rQPr(isp) = Iso_ratio( ZOOX(ng)%QPr(isp,n,i,j), ZOOX(ng)%QPr(iPt,n,i,j) )
      rQPh(isp) = Iso_ratio( ZOOX(ng)%QPh(isp,n,i,j), ZOOX(ng)%QPh(iPt,n,i,j) )
    END DO
#  endif

!----- Zooxanthellae metabolism  ----------------------------------

    CALL photosystem            &
!        input parameters
      ( ng, n, i, j             & ! ng: nested grid number; n: coral compartment; i,j: position
      , date                    &   ! Date (days since x or elapsed days)
      , dt                      & ! Time step (sec)
      , PFDsurf                 & ! Photon flux density (umol m-2 s-1)
      , Tamb                    & ! Temperature (oC)
      , CO2coe(iCt)             & ! CO2 concentration in the coral tissue
      , DOcoe                   & ! DO concentration in the coral tissue
      , ROS                     & ! ROS concentration in Zooxanthellar cell
      , ZOOX(ng)%QCe(iCt,n,i,j) & ! Reserve OC pool (= QC - QC0 ) (pmolC/cell)
!        input and output parameters
      , ZOOX(ng)%QAo(n,i,j)    & ! 
      , ZOOX(ng)%QAr(n,i,j)    & ! 
      , ZOOX(ng)%QAi(n,i,j)    & ! 
      , ZOOX(ng)%Chl(n,i,j)    & ! 
      , ZOOX(ng)%SOx(n,i,j)    & ! Superoxide (O2-) concentration in Zooxanthellar cell
      , ZOOX(ng)%NADPHn(n,i,j) & ! normalized NADPH (no dim.) NADPH/(NADPH + NADP+) 
      , ZOOX(ng)%RuBPn(n,i,j)  & ! normalized RuBP  (no dim.) RuBP/(0.5*PGA + RuBP) 
!        output parameters
      , ZOOX(ng)%Pg(n,i,j)     & ! Gross photosynthetic rate (pmolC cell-1 s-1)
      , F_zDO                  & ! Flux of DO  (pmol cell-1 s-1)
      , F_zROS                 & ! Flux of Superoxide (O2-) from photosystem (pmol cell-1 s-1)
      )
      
!----- CO2 fixation rate (pmol cell-1 s-1) ---------------------------

    F_zCO2(:) = F_zCO2(:) - ZOOX(ng)%Pg(n,i,j) *aC_phot_zox(1:N_Csp)*rCO2(:)   ! rCO2: referenced to CO2(aq), not bulk DIC

!----- peroxynitrite (ONOO-) flux (nmol cm-2 s-1)------------------------------------
!
!    F_ONOO=1.e0 * ZOOX(ng)%NO2(n,i,j)*CORAL(ng)%ROS(n,i,j)   ! (pmol cell-1 s-1)!!!!!!!!!!!!!!!!!!�Ă��Ƃ�
!    F_ONOO=F_ONOO*ZOOX(ng)%dens(n,i,j)*1.d-3   ! (nmol cm-2 s-1)


!----- Respilation rate (pmol cell-1 s-1) ---------------------------
    f_min = min( ZOOX(ng)%QCe(iCt,n,i,j)/(K_zQCe+ZOOX(ng)%QCe(iCt,n,i,j)), DOcoe/(K_DO+DOcoe) )
    Rzm = Rzmax * f_min
    Rzrq = C_dec * p2r ! Gross biosyntesis rate (pmolC cell-1 s-1)

!    Cn_bio = Cg_bio - C_dec          ! Net biosyntesis rate (pmolC cell-1 s-1)
!    if (ZOOX(ng)%QC(n,i,j) >= QCm) then
    Cn_bio = (Rzm - Rzrq)/p2r
    ZOOX(ng)%R(n,i,j) = Rzm
!    else
!       Cn_bio = 0.0d0
!       ZOOX(ng)%R(n,i,j) = min(Rzm, Rzrq)
!    endif

    ! Summing fluxes
    F_zDO     = F_zDO     - ZOOX(ng)%R(n,i,j)
    F_zCO2(:) = F_zCO2(:) + ZOOX(ng)%R(n,i,j) *rQCe(:)
#  if defined CORAL_NUTRIENTS
    F_zNH4(:) = F_zNH4(:) + ZOOX(ng)%R(n,i,j)*rNC *rQNe(:)
    F_zPO4(:) = F_zPO4(:) + ZOOX(ng)%R(n,i,j)*rPC *rQPe(:)
#  endif

!----- interaction between zooxanthellae and coral -----------------
!    F_zQC(:) = F_zQC(:) + u_z2c*QCzr *rQC(:)      & !*(1.0d0-QC0/ZOOX(ng)%QC(n,i,j))    & !Simbiont secretion
!                        - u_c2z*QCcr        ! receive from the host
    F_zQCe(:) = F_zQCe(:) + u_z2c*ZOOX(ng)%QCe(iCt,n,i,j) *rQCe(:) !Simbiont secretion
#  if defined CORAL_NUTRIENTS
    F_zQNe(:) = F_zQNe(:) + u_z2c*ZOOX(ng)%QNe(iNt,n,i,j) *rQNe(:)
    F_zQPe(:) = F_zQPe(:) + u_z2c*ZOOX(ng)%QPe(iPt,n,i,j) *rQPe(:)
#  endif

!TODO 褐虫藻の増殖過程の再検討
!----- Convert cell conditions to population dynamics parameters

    Repro = max(Cn_bio, 0.0d0)      &
            /(ZOOX(ng)%QCe(iCt,n,i,j)+ZOOX(ng)%QCv(iCt,n,i,j))  ! Cell specific growth rate (s-1)

!  ----- Growth rate (cell cm-2 s-1) -----------------
    F_zdens = F_zdens + Repro * ZOOX(ng)%dens(n,i,j)

!  ----- Cell specific mortality rate (s-1) -----------------

#  if defined CORAL_NUTRIENTS
!
#  else
!    Morta = 0.0d0!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!    Morta = km * max( -Cn_bio, 0.0d0 )
    Morta = 1.0d-8
#  endif
!  ----- Mortality rate (cell cm-2 s-1) -----------------
    F_zdens = F_zdens - Morta*ZOOX(ng)%dens(n,i,j)

    F_POC(:,iLPOM) = F_POC(:,iLPOM) + Morta*ZOOX(ng)%dens(n,i,j)*1.0d-3 &
                     *(ZOOX(ng)%QCe(iCt,n,i,j)*rQCe(:) + ZOOX(ng)%QCv(iCt,n,i,j)*rQCv(:) )
#  if defined CORAL_NUTRIENTS
    F_PON(:,iLPOM) = F_PON(:,iLPOM) + Morta*ZOOX(ng)%dens(n,i,j)*1.0d-3 &
                     *(ZOOX(ng)%QNe(iNt,n,i,j)*rQNe(:) + ZOOX(ng)%QNv(iNt,n,i,j)*rQNv(:) )
    F_POP(:,iLPOM) = F_POP(:,iLPOM) + Morta*ZOOX(ng)%dens(n,i,j)*1.0d-3 &
                     *(ZOOX(ng)%QPe(iPt,n,i,j)*rQPe(:) + ZOOX(ng)%QPv(iPt,n,i,j)*rQPv(:) )
#  endif



! ==== Set output parameters ========================================================
!----- Convert (pmol cell-1 s-1) to (nmol cm-2 s-1)------------------------------------
!  ----- Zoox. total photosynthetic rate (nmolC cm-2 s-1) ---------------------------
    Pg = ZOOX(ng)%Pg(n,i,j) * ZOOX(ng)%dens(n,i,j)*1.0d-3  !=(pmol cell-1 s-1)*(cell cm-1)*1.e-3=(nmol cm-2 s-1) 

!  ----- Zoox. total respilation rate (nmolC cm-2 s-1) ---------------------------
    Rz = ZOOX(ng)%R (n,i,j) * ZOOX(ng)%dens(n,i,j)*1.0d-3  !=(pmol cell-1 s-1)*(cell cm-1)*1.e-3=(nmol cm-2 s-1) 

!  ----- Mass fluxes (nmol cm-2 s-1) ---------------------------
    F_DO  = F_DO  + F_zDO  * ZOOX(ng)%dens(n,i,j)*1.0d-3  !=(pmol cell-1 s-1)*(cell cm-1)*1.e-3=(nmol cm-2 s-1)
    F_ROS = F_ROS + F_zROS * ZOOX(ng)%dens(n,i,j)*1.0d-3  !=(pmol cell-1 s-1)*(cell cm-1)*1.e-3=(nmol cm-2 s-1)

    F_QCe(:) = F_QCe(:) + F_zQCe(:) * ZOOX(ng)%dens(n,i,j)*1.0d-3  !=(pmol cell-1 s-1)*(cell cm-1)*1.e-3=(nmol cm-2 s-1)
    F_DIC(:) = F_DIC(:) + F_zCO2(:) * ZOOX(ng)%dens(n,i,j)*1.0d-3  !=(pmol cell-1 s-1)*(cell cm-1)*1.e-3=(nmol cm-2 s-1)
#  if defined CORAL_NONE_CO2_EQ
    F_CO2(:) = F_CO2(:) + F_zCO2(:) * ZOOX(ng)%dens(n,i,j)*1.0d-3  !=(pmol cell-1 s-1)*(cell cm-1)*1.e-3=(nmol cm-2 s-1)
#  endif
   
#  if defined CORAL_NUTRIENTS

    F_QNe(:) = F_QNe(:) + F_zQNe(:) * ZOOX(ng)%dens(n,i,j)*1.0d-3  !=(pmol cell-1 s-1)*(cell cm-1)*1.e-3=(nmol cm-2 s-1)
    F_NO3(:) = F_NO3(:) + F_zNO3(:) * ZOOX(ng)%dens(n,i,j)*1.0d-3  !=(pmol cell-1 s-1)*(cell cm-1)*1.e-3=(nmol cm-2 s-1)
    F_NH4(:) = F_NH4(:) + F_zNH4(:) * ZOOX(ng)%dens(n,i,j)*1.0d-3  !=(pmol cell-1 s-1)*(cell cm-1)*1.e-3=(nmol cm-2 s-1)

    F_QPe(:) = F_QPe(:) + F_zQPe(:) * ZOOX(ng)%dens(n,i,j)*1.0d-3  !=(pmol cell-1 s-1)*(cell cm-1)*1.e-3=(nmol cm-2 s-1)
    F_PO4(:) = F_PO4(:) + F_zPO4(:) * ZOOX(ng)%dens(n,i,j)*1.0d-3  !=(pmol cell-1 s-1)*(cell cm-1)*1.e-3=(nmol cm-2 s-1)
!      F_Nwaste = F_Zmort*ZOOX(ng)%QN(n,i,j)*1.0d-3   !=(cell cm-2 s-1)*(pmol cell-1)*1.e-3=(nmol cm-2 s-1)
!      F_Pwaste = F_Zmort*ZOOX(ng)%QP(n,i,j)*1.0d-3   !=(cell cm-2 s-1)*(pmol cell-1)*1.e-3=(nmol cm-2 s-1)

#  endif

!==== Time step progressing =================================================
!-----Cell quota (pmol/cell) -----------------!!!!!
    ZOOX(ng)%QCe(:,n,i,j)=ZOOX(ng)%QCe(:,n,i,j) + F_zQCe(:) *dt
    ZOOX(ng)%QCv(:,n,i,j)=ZOOX(ng)%QCv(:,n,i,j) + F_zQCv(:) *dt
    ZOOX(ng)%QCr(:,n,i,j)=ZOOX(ng)%QCr(:,n,i,j) + F_zQCr(:) *dt
    ZOOX(ng)%QCh(:,n,i,j)=ZOOX(ng)%QCh(:,n,i,j) + F_zQCh(:) *dt

#  if defined CORAL_NUTRIENTS
!    Nutrients (pmol/cell)
    ZOOX(ng)%NO3(:,n,i,j)=ZOOX(ng)%NO3(:,n,i,j) + F_zNO3(:) *dt
    ZOOX(ng)%NH4(:,n,i,j)=ZOOX(ng)%NH4(:,n,i,j) + F_zNH4(:) *dt
    ZOOX(ng)%PO4(:,n,i,j)=ZOOX(ng)%PO4(:,n,i,j) + F_zPO4(:) *dt

    ZOOX(ng)%QNe(:,n,i,j)=ZOOX(ng)%QNe(:,n,i,j) + F_zQNe(:) *dt
    ZOOX(ng)%QNv(:,n,i,j)=ZOOX(ng)%QNv(:,n,i,j) + F_zQNv(:) *dt
    ZOOX(ng)%QNr(:,n,i,j)=ZOOX(ng)%QNr(:,n,i,j) + F_zQNr(:) *dt
    ZOOX(ng)%QNh(:,n,i,j)=ZOOX(ng)%QNh(:,n,i,j) + F_zQNh(:) *dt
    ZOOX(ng)%QPe(:,n,i,j)=ZOOX(ng)%QPe(:,n,i,j) + F_zQPe(:) *dt
    ZOOX(ng)%QPv(:,n,i,j)=ZOOX(ng)%QPv(:,n,i,j) + F_zQPv(:) *dt
    ZOOX(ng)%QPr(:,n,i,j)=ZOOX(ng)%QPr(:,n,i,j) + F_zQPr(:) *dt
    ZOOX(ng)%QPh(:,n,i,j)=ZOOX(ng)%QPh(:,n,i,j) + F_zQPh(:) *dt
#  endif

!----- Zooxanthellae density (cell cm-2) -----------------
!    ZOOX(ng)%dens ~ 1.e6 cells cm-2  (e.g. Higuchi et al., 2012)

    ZOOX(ng)%dens(n,i,j)=ZOOX(ng)%dens(n,i,j) + F_zdens *dt

!==============================================================================
! Print section (for debug)

#  if defined CORAL_TESTMODE

!    IF(mod(int(date*86400.0d0*100.0d0), int(CORAL_OUTPUT_INTERVAL*60.0d0*100.0d0))==0) THEN
    IF( date*86400.0d0 >= dsec(n) ) THEN
      if(dsec(n) == 0.0d0) then
        dsec(n)=date*86400.0d0+CORAL_OUTPUT_INTERVAL*60.0d0
        ! Write lavels at the first step
        write(30+n,'(*(g0:,", "))')              &
          'time', 'PFD'                          &
          ,'Pg','R','Pn','dens'                  &
          ,'QCe','QCv','QCr','QCh', 'Chl'        &
          ,'Cg_bio','Cn_bio','Repro','Morta','F_zROS','F_Csec' &
          ,'F_Zelm','Repro*dens','Morta*dens'    &
#  if defined CORAL_NUTRIENTS
          ,'QN','QP'                             &
          ,'N_repro','P_repro'                   &
          ,'NO3'                                 &
          ,'NH4','F_ONOO'                        &
          ,'NO3_trans','NH4_trans'               &
          ,'NO3_reduc'                           &
          ,'N_assim','N_dissim'                  &
          ,'PO4','PO4_trans','P_assim'           &
#  endif
          ,'ROS','ROS_pmol_cell-1'               &
          ,'Chl_ug_cm-2'
      else
        dsec(n)=dsec(n)+CORAL_OUTPUT_INTERVAL*60.0d0
      endif

      write(30+n,'(*(g0:,", "))')                                        &
         date, PFDsurf                                                   &
       , ZOOX(ng)%Pg(n,i,j), ZOOX(ng)%R(n,i,j)                           &
       , ZOOX(ng)%Pg(n,i,j)-ZOOX(ng)%R(n,i,j), ZOOX(ng)%dens(n,i,j)      &
       , ZOOX(ng)%QCe(iCt,n,i,j), ZOOX(ng)%QCv(iCt,n,i,j)                &
       , ZOOX(ng)%QCr(iCt,n,i,j), ZOOX(ng)%QCh(iCt,n,i,j)                &
       , ZOOX(ng)%Chl(n,i,j)                                             &
       , Cg_bio, Cn_bio, Repro, Morta, F_zROS,F_zQCe(iCt)                &
       , F_Zelm, Repro*ZOOX(ng)%dens(n,i,j), Morta*ZOOX(ng)%dens(n,i,j)  &
#   if defined CORAL_NUTRIENTS
       , ZOOX(ng)%QN(iNt,n,i,j), ZOOX(ng)%QP(iPt,n,i,j)                  &
       , N_repro, P_repro                                                &
       , ZOOX(ng)%NO3(iNt,n,i,j), ZOOX(ng)%NH4(iNt,n,i,j), F_ONOO        &
       , NO3_trans, NH4_trans,NO3_reduc, N_assim, N_dissim               &
       , ZOOX(ng)%PO4(iPt,n,i,j), PO4_trans, P_assim                     &
#   endif
       , CORAL(ng)%ROS(n,i,j), CORAL(ng)%ROS(n,i,j)*V_zoox*1.0d3         &
       , ZOOX(ng)%dens(n,i,j)*ZOOX(ng)%Chl(n,i,j)*1.0d-6
    
    END IF
#  endif
!---------------------------------------------------------------------

    RETURN

  END SUBROUTINE zooxanthellae

!!! **********************************************************************
!!!  Photoinihibition model (modified from Gustafsson et al. 2014)
!!! **********************************************************************

  SUBROUTINE photosystem  &
!   input parameters
    ( ng, n, i, j     & ! ng: nested grid number; n: coral compartment; i,j: position
    , date            &   ! Date (days since x or elapsed days)
    , dt              & ! Time step (sec)
    , PFDsurf         & ! Photon flux density (umol m-2 s-1)
    , Tamb            & ! Temperature (oC)
    , CO2             & ! CO2 concentration in the coral tissue
    , DO              & ! DO concentration in the coral tissue
    , ROS             & ! ROS concentration in the coral tissue
    , QCzr            & ! Reserve OC pool (= QC - QC0 ) (pmolC/cell)
!   input and output parameters
    , QAo             & ! 
    , QAr             & ! 
    , QAi             & ! 
    , Chl             & ! Chlorophyll concentration (pg cell-1)
    , SOx             & ! Superoxide (O2-) concentration in Zooxanthellar cell
    , NADPHn          & ! normalized NADPH (no dim.) NADPH/(NADPH + NADP+) 
    , RuBPn           & ! normalized RuBP  (no dim.) RuBP/(0.5*PGA + RuBP) 
!!   output parameters
    , Pg              & ! Gross photosynthetic rate (pmolC cell-1 s-1)
    , F_zDO           & ! Flux of DO  (pmolO2 cell-1 s-1)
    , F_zROS          & ! Flux of ROS from photosystem (pmol cell-1 s-1)
    )
!-----------------------------------------------------------------------
    USE mod_marine_comet_param

    implicit none
!   input parameters
    integer, intent(in) :: ng, n, i, j
    real(8), intent(in) :: date
    real(8), intent(in) :: dt
    real(8), intent(in) :: PFDsurf
    real(8), intent(in) :: Tamb
    real(8), intent(in) :: CO2, DO
    real(8), intent(in) :: ROS
    real(8), intent(in) :: QCzr
!   input and output parameters
    real(8), intent(inout) :: QAo
    real(8), intent(inout) :: QAr
    real(8), intent(inout) :: QAi
    real(8), intent(inout) :: Chl
    real(8), intent(inout) :: SOx
    real(8), intent(inout) :: NADPHn
    real(8), intent(inout) :: RuBPn
!   output parameters
    real(8), intent(out) :: Pg
    real(8), intent(out) :: F_zDO, F_zROS

!------------Set Constants  ----------------------------------
    real(8), parameter :: PI  = 3.14159265359d0
    real(8), parameter :: Rg  = 8.31d0    ! Gass constant (J K–1 mol–1)

    real(8), parameter :: s_0 = 2.3d0*1.2d0    ! Absorption cross-section (m2 (umol photon)-1); ~390 (ANGSTROM quanta-1) Suggett et al. (2008) * 6.02x10^23 quanta = 1 mol photon
    real(8) :: s_ab    ! Absorption cross-section (m2 (umol photon)-1); ~390 (ANGSTROM quanta-1) Suggett et al. (2008) * 6.02x10^23 quanta = 1 mol photon
    real(8), parameter :: phi_q = 1.0d0     ! quantum efficiency of charge separation at PSII(e- photon-1)  Ross et al. (2008) !!!!!!!!!!!!!check
!    real(8), parameter :: Trb = 33.8d0    ! (oC) estimated from Lilley et al. (2010)
!    real(8), parameter :: arb = 0.55d0    ! (K-1) estimated from Lilley et al. (2010)
    real(8), parameter :: e2o = 0.25d0    ! Yield of O2 per electron (mol O2 (mol e-)-1) 2H2O -> 4e- +4H+ + O2 
    real(8), parameter :: o2c = 1.0d0     ! Photosynthetic quotient (mol O2 (mol CO2)-1) !!!Assumed
    real(8), parameter :: e2c = e2o*o2c   ! (mol C (mol e-)-1)

    !   ---- RubisCO activity related parameters -----------------
    real(8), parameter :: Vcmax = 0.5d-2   ! maximum carboxylation rate (pmol cell-1 s-1) !!! Tuning
    real(8), parameter :: Vomax = 0.2d0*Vcmax   ! maximum oxygenation rate (pmol cell-1 s-1) 
    real(8), parameter :: Kco2  = 20.0d0  ! Half saturation constant (uM) !!! Tuning (Ref. von Caemmerer, 2000)
    real(8), parameter :: Ko2   = 300.0d0 ! Half saturation constant (uM) !!! Tuning (Ref. von Caemmerer, 2000)
    real(8), parameter :: Krupb = 0.2d0   ! Half saturation constant (no dim) !!! Tuning (Ref. von Caemmerer, 2000)
    real(8), parameter :: kphot = 1.0d-3   ! rate constant of photosynthesis **** Unknown *********** 

!    real(8), parameter :: A  = 3.0d11     ! !!! Tuning
    real(8), parameter :: Ea = 1.4d5      ! !!! Tuning
    real(8), parameter :: dS = 1.2d3     ! 
    real(8), parameter :: dH = 3.58d5     ! 

!    real(8), parameter :: f_RO = 1.0d0    ! ROS fraction from zoox. to host. !!!Assumed

    real(8), parameter :: ko = 1.04d3     ! Relaxation rate of QAr to QAo (s-1) : tau = 960 us; Suggett et al. (2008)
    real(8), parameter :: ki = 7.0d-7    ! Rate constant of photoinhibition (s-1 (umol m-2 s-1)-1)
                                          !      Tyystjarvi & Aro (1996): 6.11d-8 (s-1 (umol m-2 s-1)-1);
                                          !      Nishiyama et al. (2004): 1.7d-7  (s-1 (umol m-2 s-1)-1)
!    real(8), parameter :: di = 1.7d-4     ! Natural decay from QAa to QAi (s-1)  !!!Assumed
    real(8), parameter :: ka = 3.0d-4     ! Repair rate of QAi to QAa (s-1) estimated from Takahashi et al. (2009) !!! TBD
!    real(8), parameter :: ka = 5.0d-11     ! Repair rate of QAi to QAa (s-1) estimated from Takahashi et al. (2009) !!! TBD
    real(8), parameter :: kros = 0.2d0   ! 
    real(8), parameter :: kros2 = 1.0d0   !

    real(8), parameter :: Vsoxmax = 1.0d-2   ! maximum superoxide detox rate (pmol cell-1 s-1)  !!! Tuning !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    real(8), parameter :: Ksox = 1.0d0      ! Half saturation constant (pmo; cell-1) !!! Tuning !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    real(8), parameter :: kqap = 1.0d-11    ! rate constant for QAa production
    real(8), parameter :: QCzrm = 50.0d0    ! Threashold reserv QC value for Chl production 
    real(8), parameter :: uchl_max = 1.0d-4 ! Maximum Chl production rate (pg cell-1 s-1)  (Asssumed)
    real(8), parameter :: QAt = 1.2d-4      ! Total RCII (pmol RCII cell-1)
!---------------------------------------------------------------------
!    real(8) :: QAt       ! Total RCII (pmol RCII cell-1)
    real(8) :: QAa       ! Active RCII (pmol RCII cell-1)
    real(8) :: RubisCO   ! Active fraction of RubisCO
    real(8) :: Vc, Vo, f_temp, TK   
    real(8) :: Gamma
    real(8) :: J_ea      ! Electron absorption rate (pmol e- cell-1 s-1)
    real(8) :: J_ep      ! Rate of electrons leading to C fixation (pmol e- cell-1 s-1)
    real(8) :: J_ee      ! electrons diverted from C fixation (pmol e- cell-1 s-1)
    real(8) :: J_ep_max  ! maximum electron transport rate (pmol e- cell-1 s-1)
    real(8) :: J_ep_in   ! Input electron transport rate (pmol e- cell-1 s-1)
    real(8) :: J_RO      ! Rate of ROS formed by e- (pmol ROS cell-1 s-1)
    real(8) :: J_ROs     ! Rate of slow ROS formed by e- (pmol ROS cell-1 s-1)
    real(8) :: J_ROf     ! Rate of fast ROS formed by e- (pmol ROS cell-1 s-1)
    real(8) :: Jo2r, Jr2o, Jo2i, Jr2i, Ji2o, Ja2i, Ji2a
    real(8) :: kr       
    real(8) :: I2e       
    real(8) :: K_QAi
    real(8) :: F_QAd, F_QAp
    real(8) :: dChl_dt   ! Chl concentration (pg/cell/s)
    real(8) :: F_zSOx   ! Flux of Superoxide (O2-) from photosystem (pmol cell-1 s-1)
    real(8) :: F_NADPH  ! Flux of normalized NADPH (s-1)
    real(8) :: F_RuBP   ! Flux of normalized RuBP (s-1)
    real(8) :: phi      ! Vo/Vc
    
#  if defined CORAL_TESTMODE
!  Output
!    real(8), parameter :: CORAL_OUTPUT_INTERVAL  = 5.0d0    ! Output interval (min)
    real(8), save :: dsec(Ncl) = 0.d0 !sec
    real(8) :: FvFm       
    real(8) :: YII
    real(8) :: KF       
      
#  endif

!===== Photosynthetic rate calculation ==============================================
    
!---- electrons leading to C fixation (electron transfer rate (ETR)) (pmol e- cell-1 s-1) ---
    J_ep_in = ko * QAr

!---- Photosyenthetic rate (von Caemmerer, 2000; Eq.(2.34))
    TK = Tamb + 273.15 !(K)
    f_temp = exp(-(TK-298.15)*Ea/298.15/Rg/TK)* &
              (1.0d0+exp((298.15*dS-dH)/Rg/298.15))/(1.0d0+exp((TK*dS-dH)/Rg/TK))

    Vc = Vcmax * f_temp * CO2/(CO2+Kco2*(1.0d0+DO/Ko2))  &
                        * RuBPn/(RuBPn+Krupb)
!    Vo = Vomax*f_temp*DO/(DO+Ko2*(1.0d0+CO2/Kco2))
    phi = Vomax/Vcmax*(DO/Ko2)/(CO2/Kco2)
    Vo = phi*Vc

    Pg = Vc - 0.5d0*Vo
     
!---- Oxygen production rate  (pmol O2 cell-1 s-1) ---
    F_zDO = J_ep_in/4.0d0 - 0.5d0*Vo

!---- Electrons that form ROS  (pmol ROS cell-1 s-1) ---
!   NADP+ + H+ + 2 e- -> NADPH
    F_NADPH = 0.5d0*J_ep_in * (1.0d0-NADPHn) 

    F_RuBP = kphot*NADPHn*(1.0d0-RuBPn)

!   O2 + e- -> O2- 
    F_zSOx = NADPHn * J_ep_in

!   Superoxide desimutaze (SOD)     
!    2 O2- + 2 H+ -> H2O2 + O2
    F_zROS = Vsoxmax * SOx/(Ksox + SOx)

!   DO flux (pmol O2 cell-1 s-1) 
    F_zDO = F_zDO - F_zSOx + F_zROS

!===== Photoinhibition calculation ==============================================

!----- Active RCII -----------------
!    QAa = QAt - ZOOX(ng)%QAi(n,i,j)
    QAa  = QAo + QAr

!---- Photoinihibition rate of QAa to QAi  (pmol RCII cell-1 s-1) ---
    Ja2i = ki*PFDsurf * QAa
!    Ja2i = 0.0d0  ! No photidamage case

!---- Repair rate of QAi to QAo  (pmol RCII cell-1 s-1) --- !!!!!!!!!!!!!!!!! Need update
!    Ji2a = ka * QAi * exp(-kros2*ROS)  !!! ROS concentration dependent repair
!    Ji2a = ka * QAi * exp(-kros2*ROS) * (J_ep_in*1.0d4)  !!! ROS concentration dependent repair
    Ji2a = ka * QAi * exp(-kros2*ROS) * (tanh(PFDsurf/50.0d0)+0.05d0)  !!! ROS concentration dependent repair

! ----- QAa production rate (pmol RCII cell-1 s-1) -------
    F_QAp = kqap * (1.0d0-QCzr/QCzrm)

!===== Time step progressing ================================================

!-----Inhibited RCII -----------------
    QAi = QAi +( Ja2i - Ji2a )*dt

!-----Active RCII (updated) -----------------
    QAa = QAt - QAi

!---- electron absorption rate (s-1) 
!   = reduction of active QA (s-1) ---
!    s_ab = s_0*0.83d0*exp(-kros*ROS)  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    s_ab = s_0*0.83d0
!    s_ab = s_0*0.65d0
!    s_ab = s_0 * 0.80d0*exp(-kros*QAi/QAt)

    kr = s_ab * Chl * phi_q * PFDsurf

!-----Reduced RCII -----------------
    QAr = kr/(kr+ko) * QAa

!-----Oxidizes RCII -----------------
    QAo = QAa - QAr

!===== Chl dynamics calculation ==============================================
!    dChl_dt = uchl_max * (1.0d0 - QCzr/QCzr_max)
!    dChl_dt = - 3.0d-6*ROS + 3.0d-5
    dChl_dt = 1.0d-7*(3.0d0-ROS)
!-----Chl concentration (pg cell-1) -----------------
    Chl = Chl + dChl_dt *dt
    Chl = max(Chl,0.0d0) !!!Error handring

!-- NADPHn = NADPH/(NADPH + NADP+) concentration (no unit, (pmol cell-1)/(pmol cell-1) ) -----------------
!   Eq. (23) in Farquhar et al. (1980)
!    NADPHn = 1.0d0 - (4.0d0+3.0d0*phi)*Vc/J_ep_in
    NADPHn = NADPHn + (F_NADPH - F_RuBP) *dt

!-- RuBPn = RuBP/(0.5*PGA + RuBP) concentration (no unit, (pmol cell-1)/(pmol cell-1) ) -----------------
!   Eq. (27) in Farquhar et al. (1980)
!    RuBPn = 1.0d0 - (2.0d0+1.5d0*phi)*Vc/NADPHn/kphot
!    RuBPn = RuBPn + ( F_RuBP - (2.0d0+1.5d0*phi)*Vc ) *dt
    RuBPn = RuBPn + ( F_RuBP - (2.0d0+1.5d0*phi)*Vc *100.0d0 ) *dt

!-----Superoxide concentration (pmol cell-1) -----------------
!   F_zSOx: O2 + e- -> O2- 
!   F_zROS: 2 O2- + 2 H+ -> H2O2 + O2
!    
!     d SOx/dt = F_zSOx - 2*F_zROS = 0 (quasi steady state)
!   O2 + e- -> O2- 
!      F_zSOx = NADPHn * J_ep_in  
!   2 O2- + 2 H+ -> H2O2 + O2 (Superoxide desimutaze (SOD)) 
!      F_zROS = Vsoxmax * SOx/(Ksox + SOx)
!
!    SOx = NADPHn*J_ep_in*Ksox/(2.0d0*Vsoxmax - NADPHn*J_ep_in)
    SOx = SOx + ( F_zSOx - 2.0d0*F_zROS ) *dt

!------------------------------------------------------------------------
! Print section (for debug)

#  if defined CORAL_TESTMODE

    IF( date*86400.0d0 >= dsec(n) ) THEN
      if(dsec(n) == 0.0d0) then
        dsec(n)=date*86400.0d0+CORAL_OUTPUT_INTERVAL*60.0d0
        ! Write lavels at the first step
        write(40+n,'(*(g0:,", "))')                                 &
           'time','PFD','Tamb'                                      &
          ,'QAo','QAr','QAi'                                        &
          ,'QAt','QAa','Fv/Fm','Y(II)','J_ep_in'                    &
          ,'Ji2a','Ja2i','kr','s_ab','F_zSOx','SOx'                 &
          ,'Pg','Pgcal','Vc','Vo','phi','F_zDO'                     &
          ,'Chl','CO2','DO','F_QAp','NADPH','RuBP','F_zROS','ROS'
      else
        dsec(n)=dsec(n)+CORAL_OUTPUT_INTERVAL*60.0d0
      endif

      KF = s_0/s_ab - 1.0d0
      FvFm = (QAa/QAt)/(KF+(QAa/QAt))
      YII  = (QAo/QAt)/(KF+(QAo/QAt))
      
      write(40+n,'(*(g0:,", "))')                                   &
         date, PFDsurf, Tamb                                        &
       , QAo, QAr, QAi                                              &
       , QAt, QAa, FvFm, YII, J_ep_in                               &
       , Ji2a, Ja2i, kr, s_ab, F_zSOx, SOx                          &
       , Pg, J_ep_in*e2c, Vc, Vo, phi, F_zDO                        &
       , Chl, CO2, DO, F_QAp, NADPHn, RuBPn, F_zROS, ROS
      
    END IF
#  endif
!-----------------------------------------------------------------------
    RETURN

  END SUBROUTINE photosystem
# endif

#endif      
END MODULE mod_coral

