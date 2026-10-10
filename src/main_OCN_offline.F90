
!!!=== Copyright (c) 2026 Takashi NAKAMURA  ===== 

#include "cppdefs.h"

#if defined ROMS_MODEL || defined JCOPE_MODEL
# define ARAKAWA_C_GRID
#endif
#if defined FORP_MODEL || defined MOVEJPN_MODEL || defined FORA_MODEL
# define MRICOM_MODEL
#endif 

PROGRAM main_OCN_offline
  use netcdf
  use mod_roms_netcdf
  use mod_calendar
  use mod_infile   ! shared T_INFILE / infile_check_time (input file + time list)

  implicit none

! ===== Output region (HIS: 1 region = whole domain; BRY: up to 4 boundaries) =====
  type T_region
    !----- (A) target-region sized: allocated once at region setup -----
    integer :: LBri, UBri, LBrj, UBrj            ! rho target bounds
    integer :: LBui, UBui, LBuj, UBuj            ! u   target bounds
    integer :: LBvi, UBvi, LBvj, UBvj            ! v   target bounds
    integer :: Nxr, Nyr, Nxu, Nyu, Nxv, Nyv      ! target sizes
    integer :: Nrbry, Nubry, Nvbry               ! (BRY) slice lengths
    real(8), allocatable :: zeta(:,:,:), ubar(:,:,:), vbar(:,:,:)
    real(8), allocatable :: u(:,:,:,:), v(:,:,:,:), t(:,:,:,:)
    real(8), allocatable :: ull(:,:,:,:), vll(:,:,:,:)
    real(8), allocatable :: uu(:,:,:,:), uv(:,:,:,:), vu(:,:,:,:), vv(:,:,:,:)
    integer, allocatable :: ID_cnt2Dr(:,:), ID_cnt2Du(:,:), ID_cnt2Dv(:,:)
    real(8), allocatable :: w_cnt2Dr(:,:),  w_cnt2Du(:,:),  w_cnt2Dv(:,:)
    integer, allocatable :: ID_cnt3Dr(:,:), ID_cnt3Du(:,:), ID_cnt3Dv(:,:)
    real(8), allocatable :: w_cnt3Dr(:,:),  w_cnt3Du(:,:),  w_cnt3Dv(:,:)
    real(8), allocatable :: zeta_bry(:,:), ubar_bry(:,:), vbar_bry(:,:)
    real(8), allocatable :: u_bry(:,:,:),  v_bry(:,:,:),  t_bry(:,:,:)
    !----- (B) donor-box sized: re-allocated on donor-file change -----
    integer :: Irdg_min, Irdg_max, Jrdg_min, Jrdg_max
    integer :: Iudg_min, Iudg_max, Judg_min, Judg_max
    integer :: Ivdg_min, Ivdg_max, Jvdg_min, Jvdg_max
    integer :: Nxr_dg, Nyr_dg, Nxu_dg, Nyu_dg, Nxv_dg, Nyv_dg
    real(8), allocatable :: zeta_dg(:,:,:), ubar_dg(:,:,:), vbar_dg(:,:,:)
    real(8), allocatable :: u_dg(:,:,:,:),  v_dg(:,:,:,:),  t_dg(:,:,:,:)
    real(8), allocatable :: ull_dg(:,:,:,:),  vll_dg(:,:,:,:)
    real(8), allocatable :: ullu_dg(:,:,:,:), ullv_dg(:,:,:,:)
    real(8), allocatable :: vllu_dg(:,:,:,:), vllv_dg(:,:,:,:)
    real(8), allocatable :: umask_wet_dg(:,:,:), vmask_wet_dg(:,:,:)
  end type T_region

  type(T_region), target, allocatable :: region(:)

! ---------------------------------------------------------------------
  integer :: Syear, Smonth, Sday
  integer :: Eyear, Emonth, Eday
  integer :: Ryear, Rmonth, Rday
  integer :: itime,ibry
  logical :: leaving_file  ! last step, or the next step uses a different donor file
  integer :: mode
  character(256) :: GRID_FILE

  character(256) :: HIS_prefix   ! used in HIS output
  integer :: N_s_rho
  integer :: Nzr
  integer :: spherical
  integer :: Vtransform, Vstretching
  real(8) :: THETA_S , THETA_B, TCLINE, DCRIT
  integer :: Nzr_dg
  integer :: Vtransform_dg, Vstretching_dg
  integer :: LBri, UBri, LBrj, UBrj
  integer :: LBui, UBui, LBuj, UBuj
  integer :: LBvi, UBvi, LBvj, UBvj

  character(33) :: TIME_ATT  = "seconds since 2000-01-01 00:00:00"

  character(13) :: ds_str, de_str   ! "YYYYMMDD.HHMM" start/end of the output period
  character(13) :: date_str         ! "YYYYMMDD.HHMM" progress print
  character(256) :: OUT_FILE                          ! unified output file name (BRY/HIS/INI)
  
  real(8), allocatable :: time_all(:)
  real(8), allocatable :: time(:)      ! merged julian-date list (the single time array;
                                       ! converted to "sec since &refdate" only at write)
  integer, allocatable :: iNCt(:)
  integer :: start1D(1), count1D(1)
  integer :: start2D(2), count2D(2)
  integer :: start3D(3), count3D(3)
  integer :: start4D(4), count4D(4)
  
  real(8), allocatable :: h(:,:)        ! depth (meter)
  real(8), allocatable :: rmask(:,:)    ! land mask
  real(8), allocatable :: umask(:,:)    ! land mask
  real(8), allocatable :: vmask(:,:)    ! land mask
  real(8), allocatable :: latr(:, :)
  real(8), allocatable :: lonr(:, :)
  real(8), allocatable :: latu(:, :)
  real(8), allocatable :: lonu(:, :)
  real(8), allocatable :: latv(:, :)
  real(8), allocatable :: lonv(:, :)
  real(8), allocatable :: cosAu(:,:)  ! angle differece between lat lon and ROMS coordinates (radian)
  real(8), allocatable :: sinAu(:,:)  ! angle differece between lat lon and ROMS coordinates (radian)
  real(8), allocatable :: cosAv(:,:)  ! angle differece between lat lon and ROMS coordinates (radian)
  real(8), allocatable :: sinAv(:,:)  ! angle differece between lat lon and ROMS coordinates (radian)
  real(8), allocatable :: cosA_i(:,:) ! rho-point rotation angle (i-axis) from rotation_angle
  real(8), allocatable :: sinA_i(:,:) ! rho-point rotation angle (i-axis) from rotation_angle
  real(8), allocatable :: cosA_j(:,:) ! rho-point rotation angle (j-axis) from rotation_angle
  real(8), allocatable :: sinA_j(:,:) ! rho-point rotation angle (j-axis) from rotation_angle
  real(8) :: hc
  real(8), allocatable :: sc_w(:)       
  real(8), allocatable :: sc_r(:)  
  real(8), allocatable :: Cs_w(:)       
  real(8), allocatable :: Cs_r(:)  
  real(8), allocatable :: z_r(:,:,:)
  real(8), allocatable :: z_w(:,:,:)
  real(8), allocatable :: z_u(:,:,:)
  real(8), allocatable :: z_v(:,:,:)
  real(8), allocatable :: dz_u(:,:,:)
  real(8), allocatable :: dz_v(:,:,:)
  real(8), allocatable :: hu(:,:)
  real(8), allocatable :: hv(:,:)
  
  ! (A) region-sized working/slice arrays: pointers aliased to region(ibry)%...
  real(8), pointer :: zeta(:,:,:)    ! free-surface (meter)
  real(8), pointer :: ubar(:,:,:)    ! vertically integrated u-momentum component (meter second-1)
  real(8), pointer :: vbar(:,:,:)    ! vertically integrated v-momentum component (milibar=hPa)
  real(8), pointer :: u(:,:,:,:)     ! u-momentum component (meter second-1)
  real(8), pointer :: v(:,:,:,:)     ! v-momentum component (meter second-1)
  real(8), pointer :: t(:,:,:,:)     ! tracer
  real(8), pointer :: ull(:,:,:,:)   ! u-momentum component on lat lon coordinate (meter second-1)
  real(8), pointer :: vll(:,:,:,:)   ! v-momentum component on lat lon coordinate (meter second-1)
  real(8), pointer :: uu(:,:,:,:)
  real(8), pointer :: uv(:,:,:,:)
  real(8), pointer :: vu(:,:,:,:)
  real(8), pointer :: vv(:,:,:,:)
  real(8), pointer :: zeta_bry(:,:)  ! free-surface (meter)
  real(8), pointer :: ubar_bry(:,:)  ! vertically integrated u-momentum component (meter second-1)
  real(8), pointer :: vbar_bry(:,:)  ! vertically integrated v-momentum component (milibar=hPa)
  real(8), pointer :: u_bry(:,:,:)   ! u-momentum component (meter second-1)
  real(8), pointer :: v_bry(:,:,:)   ! v-momentum component (meter second-1)
  real(8), pointer :: t_bry(:,:,:)   ! tracer

  real(8), allocatable :: h_dg(:,:)      ! depth (meter) of donor grid
  real(8), allocatable :: rmask_dg(:,:)  ! land mask of donor grid
  real(8), allocatable :: umask_dg(:,:)  ! land mask of donor grid
  real(8), allocatable :: vmask_dg(:,:)  ! land mask of donor grid
#if defined WET_DRY
  ! effective weight mask = static land mask x time-varying wetdry mask (ROMS+WET_DRY)
  real(8), allocatable :: umask_eff(:,:)
  real(8), allocatable :: vmask_eff(:,:)
#endif
  real(8), allocatable :: pmask_dg(:,:)  ! land mask of donor grid
  real(8), allocatable :: latr_dg(:,:)
  real(8), allocatable :: lonr_dg(:,:)
  real(8), allocatable :: latu_dg(:,:)
  real(8), allocatable :: lonu_dg(:,:)
  real(8), allocatable :: latv_dg(:,:)
  real(8), allocatable :: lonv_dg(:,:)
  real(8), allocatable :: cosAu_dg(:,:)  ! angle differece between lat lon and donor ROMS coordinates (radian)
  real(8), allocatable :: sinAu_dg(:,:)  ! angle differece between lat lon and donor ROMS coordinates (radian)
  real(8), allocatable :: cosAv_dg(:,:)  ! angle differece between lat lon and donor ROMS coordinates (radian)
  real(8), allocatable :: sinAv_dg(:,:)  ! angle differece between lat lon and donor ROMS coordinates (radian)
  real(8) :: hc_dg       
  real(8), allocatable :: sc_w_dg(:)       
  real(8), allocatable :: sc_r_dg(:)  
  real(8), allocatable :: Cs_w_dg(:)       
  real(8), allocatable :: Cs_r_dg(:)  
  real(8), allocatable :: z_r_dg(:,:,:)
  real(8), allocatable :: z_w_dg(:,:,:)
  real(8), allocatable :: z_u_dg(:,:,:)
  real(8), allocatable :: z_v_dg(:,:,:)
  real(8), allocatable :: sst(:,:)
  real(8), allocatable :: DHW(:,:)
  real(8), allocatable :: DCW(:,:)
  real(8), allocatable :: HS(:,:,:)
  real(8), allocatable :: CS(:,:,:)
  integer :: id_day(84)
  integer :: id_day_tmp
  real(8), parameter :: Fill_temp = 1.0d37   ! _FillValue of temp (ROMS convention)

  real(8) :: ocean_time(1)                ! Ocean time (sec)
  ! (B) donor-box arrays: pointers (HIS allocates directly; BRY aliases to region(ibry)%...)
  real(8), pointer :: zeta_dg(:,:,:)  ! free-surface (meter)
  real(8), pointer :: ubar_dg(:,:,:)  ! vertically integrated u-momentum component (meter second-1)
  real(8), pointer :: vbar_dg(:,:,:)  ! vertically integrated v-momentum component (milibar=hPa)
  real(8), pointer :: u_dg(:,:,:,:)   ! u-momentum component (meter second-1)
  real(8), pointer :: v_dg(:,:,:,:)   ! v-momentum component (meter second-1)
  real(8), pointer :: t_dg(:,:,:,:)   ! tracer
  real(8), pointer :: ull_dg(:,:,:,:) ! u-momentum component on lat lon coordinate (meter second-1)
  real(8), pointer :: vll_dg(:,:,:,:) ! v-momentum component on lat lon coordinate (meter second-1)
  real(8), pointer :: ullu_dg(:,:,:,:)
  real(8), pointer :: ullv_dg(:,:,:,:)
  real(8), pointer :: vllu_dg(:,:,:,:)
  real(8), pointer :: vllv_dg(:,:,:,:)
#if defined WET_DRY
  real(8), pointer :: umask_wet_dg(:,:,:)
  real(8), pointer :: vmask_wet_dg(:,:,:)
#endif
  integer, pointer :: ID_cnt2Dr(:,:)
  real(8), pointer :: w_cnt2Dr (:,:)
  integer, pointer :: ID_cnt2Du(:,:)
  real(8), pointer :: w_cnt2Du (:,:)
  integer, pointer :: ID_cnt2Dv(:,:)
  real(8), pointer :: w_cnt2Dv (:,:)
  integer, pointer :: ID_cnt3Dr(:,:)
  real(8), pointer :: w_cnt3Dr (:,:)
  integer, pointer :: ID_cnt3Du(:,:)
  real(8), pointer :: w_cnt3Du (:,:)
  integer, pointer :: ID_cnt3Dv(:,:)
  real(8), pointer :: w_cnt3Dv (:,:)

  integer :: i,j,k
  real(8) :: cff
  
  character(4) :: YYYY
  character(2) :: MM
  character(2) :: DD
  character(2) :: hh
  character(12) :: YYYYMMDDhhmm
  character(8) :: YYYYMMDD

  real(8) :: d_jdate
  integer :: N_days
  integer :: jdate_Start, jdate_End, jdate_Ref
  real(8) :: d_jdate_Start, d_jdate_Ref
  
  integer :: Nxr, Nyr, Nxu, Nyu, Nxv, Nyv
  integer :: L, M, N
  integer :: Ldg, Mdg, Ndg
  integer :: irg, jrg, krg
  integer :: Idg, Jdg, Kdg
  integer :: Nxr_dg, Nyr_dg, Nxu_dg, Nyu_dg, Nxv_dg, Nyv_dg
  integer :: Nt
  integer, allocatable :: idt(:)

  integer :: ncid,var_id
  integer :: ncid2,var_id2
  integer :: iNC, iNCm
!  integer :: ItS, ItE
  character(256) :: varname
  character(256) :: bryname
  character(2) :: varnum
  integer :: status, access


#if defined ROMS_MODEL
  ! input-file info (file names + time list) now lives in mod_infile's INFILE(:)
  real(8), allocatable :: time2(:)

  character(256) :: parent_grid
  integer :: parent_Imin, parent_Imax
  integer :: parent_Jmin, parent_Jmax
  integer :: refine_factor
  integer :: NCnum
  character(256), allocatable :: ROMS_HISFILE(:)
  integer :: romsvar(N_var)
#else
  integer :: romsvar(7)
#endif 

#if defined MRICOM_MODEL
  character(256) :: MRICOM_data_dir
  ! input-file info (file names + time list) now lives in mod_infile's INFILE(:)
!  real(8), allocatable :: time2(:)
  real(8), allocatable :: latst(:), lonst(:), latuv(:), lonuv(:)
  real(8), allocatable :: depth(:)
  integer :: NCnum
# if defined FORP_MODEL
  character(13) :: MRICOM_sufix  = "_dy_200601.nc"
  character(12) :: MRICOM_prefix = "forp-jpn-v4_"
# elif defined MOVEJPN_MODEL || defined FORA_MODEL
!  character(9) :: MRICOM_sufix(1000)  = ".20080101"
  character(12) :: MRICOM_sufix(30000)  = ".20080101.nc"
  character(3) :: MRICOM_prefix = "nc_"
  character(256), parameter :: MOVEJPN_VAR(5) = (/ &
!     "ssh" &  !  1
     "sst" &  !  1
    ,"u  " &  !  2 
    ,"v  " &  !  3
    ,"t  " &  !  4 
    ,"s  " &  !  5 
     /)
!  character(9) :: MRICOM_sufix_tmp  = ".20080101"
  character(12) :: MRICOM_sufix_tmp  = ".20080101.nc"
  character(256) :: MRICOM_FILE_tmp
  character(256) :: MRICOM_FILE(30000)
# endif
  ! FORP 'time' is "hours since 0001-01-01" counted in the standard calendar,
  ! whose year-1 epoch lies in the Julian calendar (JDN 1721424). Note that
  ! mod_calendar::jd() is proleptic-Gregorian, so jd(1,1,1)=1721426 — the two
  ! calendars differ by exactly 2 days at year 1. Reconstructing the epoch with
  ! jd() would therefore push every FORP date 2 days late; use the Julian epoch
  ! directly instead (this is what the old "d_jdate_00010101 - 2" did).
  real(8), parameter :: d_jdate_FORP_ref = 1721424.0d0  ! JDN of 0001-01-01 (Julian)
  integer :: iyear, imonth, iday
  integer :: ihour, imin
  integer :: idays,ihours,ijdate,Sjdate,Ejdate
  character(256), parameter :: MRICOM_VAR_NAME(5) = (/ &
     "zos   " &  !  1
    ,"uo    " &  !  2 
    ,"vo    " &  !  3
    ,"thetao" &  !  4 
    ,"so    " &  !  5 
     /)
#endif

#if defined ROMS_MODEL
  namelist/refinement/parent_grid
  namelist/refinement/parent_Imin, parent_Imax
  namelist/refinement/parent_Jmin, parent_Jmax
  namelist/refinement/refine_factor
  namelist/roms2roms1/NCnum
  namelist/roms2roms2/ROMS_HISFILE, romsvar
#endif
#if defined MRICOM_MODEL
  namelist/mricom/MRICOM_data_dir
#endif
  namelist/sdate/Syear, Smonth, Sday
  namelist/edate/Eyear, Emonth, Eday
  namelist/refdate/Ryear, Rmonth, Rday
  namelist/his/HIS_prefix

  ! Read parameters in namelist file
  
#if defined ROMS_MODEL
  read (5, nml=refinement)
  rewind(5)
  read (5, nml=roms2roms1)
  allocate( ROMS_HISFILE(NCnum) )
  rewind(5)
  read (5, nml=roms2roms2)
  rewind(5)
#endif
#if defined MRICOM_MODEL
  read (5, nml=mricom)
  rewind(5)
#endif
  read (*, nml=sdate)
  rewind(5)
  read (*, nml=edate)
  rewind(5)
  read (*, nml=refdate)
  rewind(5)
  read (*, nml=his)

!-Modify time-unit description ---------------------------------
  
  write (YYYY, "(I4.4)") Ryear
  write (MM, "(I2.2)") Rmonth
  write (DD, "(I2.2)") Rday
  TIME_ATT(15:18)=YYYY
  TIME_ATT(20:21)=MM
  TIME_ATT(23:24)=DD
  
!======= Set starting time and Ending time ========================

  call ndays(Emonth, Eday, Eyear, Smonth, Sday, Syear, N_days)
  call jd(Syear, Smonth, Sday, jdate_Start)

  jdate_End = jdate_Start + N_days
  
  write(*,*) jdate_Start, jdate_End, N_days

  call jd(Ryear, Rmonth, Rday, jdate_Ref)
  d_jdate_Ref = dble(jdate_Ref)
  write(*,*) d_jdate_Ref
  
!======= Read grid coorinate of Ocean model ========================

#if defined ROMS_MODEL
  write(*,*) "************ ROMS MODEL ************"


  !-Read ROMS parent grid netCDF file --------------------------------
  write(*,*) "OPEN: ", trim( parent_grid )
  
  ! Open NetCDF grid file
  call check( nf90_open(trim( parent_grid ), nf90_nowrite, ncid) )
  ! Get dimension data
  call get_dimension(ncid, 'xi_rho',  Nxr_dg)
  call get_dimension(ncid, 'eta_rho', Nyr_dg)
  Nxu_dg = Nxr_dg-1
  Nyu_dg = Nyr_dg
  Nxv_dg = Nxr_dg
  Nyv_dg = Nyr_dg-1
  Ldg = Nxr_dg-1
  Mdg = Nyr_dg-1
       
  allocate( latr_dg(0:Ldg, 0:Mdg) )
  allocate( lonr_dg(0:Ldg, 0:Mdg) )
  allocate( latu_dg(1:Ldg, 0:Mdg) )
  allocate( lonu_dg(1:Ldg, 0:Mdg) )
  allocate( latv_dg(0:Ldg, 1:Mdg) )
  allocate( lonv_dg(0:Ldg, 1:Mdg) )
  allocate( rmask_dg(0:Ldg, 0:Mdg) )
  allocate( umask_dg(1:Ldg, 0:Mdg) )
  allocate( vmask_dg(0:Ldg, 1:Mdg) )
  allocate( cosAu_dg(1:Ldg, 0:Mdg) )
  allocate( sinAu_dg(1:Ldg, 0:Mdg) )
  allocate( cosAv_dg(0:Ldg, 1:Mdg) )
  allocate( sinAv_dg(0:Ldg, 1:Mdg) )
  allocate( h_dg(0:Ldg, 0:Mdg) )
  
  ! Get variables
  call check( nf90_inq_varid(ncid, 'lat_rho', var_id) ) ! latitude at RHO-points (degree_east)
  call check( nf90_get_var(ncid, var_id, latr_dg) )
  call check( nf90_inq_varid(ncid, 'lon_rho', var_id) ) ! longitude at RHO-points (degree_east)
  call check( nf90_get_var(ncid, var_id, lonr_dg) )
  call check( nf90_inq_varid(ncid, 'lat_u', var_id) ) ! latitude at U-points (degree_east)
  call check( nf90_get_var(ncid, var_id, latu_dg) )
  call check( nf90_inq_varid(ncid, 'lon_u', var_id) ) ! longitude at U-points (degree_east)
  call check( nf90_get_var(ncid, var_id, lonu_dg) )
  call check( nf90_inq_varid(ncid, 'lat_v', var_id) ) ! latitude at V-points (degree_east)
  call check( nf90_get_var(ncid, var_id, latv_dg) )
  call check( nf90_inq_varid(ncid, 'lon_v', var_id) ) ! longitude at V-points (degree_east)
  call check( nf90_get_var(ncid, var_id, lonv_dg) )
  call check( nf90_inq_varid(ncid, 'h', var_id) ) 
  call check( nf90_get_var(ncid, var_id, h_dg) )
  call check( nf90_inq_varid(ncid, 'mask_rho', var_id) ) 
  call check( nf90_get_var(ncid, var_id, rmask_dg) )
  call check( nf90_inq_varid(ncid, 'mask_u', var_id) ) 
  call check( nf90_get_var(ncid, var_id, umask_dg) )
  call check( nf90_inq_varid(ncid, 'mask_v', var_id) ) 
  call check( nf90_get_var(ncid, var_id, vmask_dg) )
  ! Close NetCDF file
  call check( nf90_close(ncid) )

  do j=0,Mdg
    do i=0,Ldg
      if ( h_dg(i,j)<0.0d0 ) then
        rmask_dg(i,j) = 0.0d0
      end if
    end do
  end do
    
  write(*,*) "CLOSE: ", trim( parent_grid )

!-Read ROMS ocean_his netCDF file --------------------------------

  ! Open NetCDF file
  write(*,*) "OPEN: ", trim( ROMS_HISFILE(1) )
  call check( nf90_open(trim( ROMS_HISFILE(1) ), nf90_nowrite, ncid) )
!  call get_dimension(ncid, 'ocean_time', Nt)
  call get_dimension(ncid, 's_rho', Nzr_dg)

!  allocate(time_all(Nt))

  Ndg = Nzr_dg
  allocate( sc_w_dg(0:Ndg ) )
  allocate( sc_r_dg(1:Ndg ) )
  allocate( Cs_w_dg(0:Ndg ) )
  allocate( Cs_r_dg(1:Ndg ) )
  allocate( z_r_dg(0:Ldg, 0:Mdg, 1:Ndg ) )
  allocate( z_w_dg(0:Ldg, 0:Mdg, 0:Ndg ) )
  allocate( z_u_dg(1:Ldg, 0:Mdg, 1:Ndg ) )
  allocate( z_v_dg(0:Ldg, 1:Mdg, 1:Ndg ) )

!  call check( nf90_inq_varid(ncid, 'ocean_time', var_id) )
!  call check( nf90_get_var(ncid, var_id, time_all) )
  call check( nf90_inq_varid(ncid, 's_rho', var_id) )
  call check( nf90_get_var(ncid, var_id, sc_r_dg ) )
  call check( nf90_inq_varid(ncid, 's_w', var_id) )
  call check( nf90_get_var(ncid, var_id, sc_w_dg ) )
  call check( nf90_inq_varid(ncid, 'Cs_r', var_id) )
  call check( nf90_get_var(ncid, var_id, Cs_r_dg ) )
  call check( nf90_inq_varid(ncid, 'Cs_w', var_id) )
  call check( nf90_get_var(ncid, var_id, Cs_w_dg ) )
  call check( nf90_inq_varid(ncid, 'Vtransform', var_id) )
  call check( nf90_get_var(ncid, var_id, Vtransform_dg ) )
  call check( nf90_inq_varid(ncid, 'hc', var_id) )
  call check( nf90_get_var(ncid, var_id, hc_dg ) )
  call check( nf90_close(ncid) )

! Extract grid data

  call set_depth ( Nxr_dg, Nyr_dg, Nzr_dg, h_dg                      &
        , Vtransform_dg, hc_dg, sc_w_dg, sc_r_dg, Cs_w_dg, Cs_r_dg   &
!    output parameters
        , z_r_dg, z_w_dg)

  z_r_dg = -z_r_dg
  z_w_dg = -z_w_dg
  
  do k=1,Ndg
    do j=0,Mdg
      do i=1,Ldg
        z_u_dg(i,j,k)= (z_r_dg(i-1,j,k)+z_r_dg(i,j,k))*0.5d0
      enddo
    enddo
  enddo
  do k=1,Ndg
    do j=1,Mdg
      do i=0,Ldg
        z_v_dg(i,j,k)= (z_r_dg(i,j-1,k)+z_r_dg(i,j,k))*0.5d0
      enddo
    enddo
  enddo

  ! Donor-grid rotation angle at rho points, mapped to u/v points (see above).
  allocate( cosA_i(0:Ldg, 0:Mdg), sinA_i(0:Ldg, 0:Mdg) )
  allocate( cosA_j(0:Ldg, 0:Mdg), sinA_j(0:Ldg, 0:Mdg) )
  call rotation_angle(Ldg+1, Mdg+1, lonr_dg, latr_dg, cosA_i, sinA_i, cosA_j, sinA_j)
  do j=0,Mdg
    do i=1,Ldg
      cosAu_dg(i,j) = cosA_i(i-1,j)
      sinAu_dg(i,j) = sinA_i(i-1,j)
    enddo
  enddo
  do j=1,Mdg
    do i=0,Ldg
      cosAv_dg(i,j) = cosA_j(i,j-1)
      sinAv_dg(i,j) = sinA_j(i,j-1)
    enddo
  enddo
  deallocate( cosA_i, sinA_i, cosA_j, sinA_j )

! Check time
  allocate( INFILE(NCnum) )
  do iNC=1, NCnum
    write(*,*) 'CHECK: Time'
    ! Open NetCDF file
    write(*,*) "OPEN: ", trim( ROMS_HISFILE(iNC) )
    call check( nf90_open(trim( ROMS_HISFILE(iNC) ), nf90_nowrite, ncid) )
    call get_dimension(ncid, 'ocean_time', INFILE(iNC)%Nt)
    write(*,*) INFILE(iNC)%Nt
    allocate( INFILE(iNC)%NAME(1) )
    INFILE(iNC)%NAME(1) = ROMS_HISFILE(iNC)
    allocate( INFILE(iNC)%time_all(INFILE(iNC)%Nt) )
    allocate( time2(INFILE(iNC)%Nt) )
    call check( nf90_inq_varid(ncid, 'ocean_time', var_id) )
    call check( nf90_get_var(ncid, var_id, time2) )
    call check( nf90_close(ncid) )
    INFILE(iNC)%time_all = d_jdate_Ref + time2/86400.0d0  ! sec since ref -> julian date

    deallocate(time2)
  end do

  call infile_check_time( NCnum, dble(jdate_Start), dble(jdate_End), Nt, time, iNCt, idt )

  write(*,*) "*************************************"


#elif defined MRICOM_MODEL

!---- Read FORP netCDF file --------------------------------
# if defined FORP_MODEL

  write(*,*) "************ FORP MODEL ************"

  Nt = 0
  itime = 1
  ihours = 0
  iyear = Syear
  imonth = Smonth
  iday = Sday
  call jd(iyear, imonth, iday, Sjdate)

  NCnum = 12*(Eyear-Syear) + Emonth - Smonth + 1
  NCnum = min( NCnum, 12 )  ! FORP data limit to 1 year
  write(*,*) 'NCnum = ', NCnum
  allocate( INFILE(NCnum) )

  do iNC=1, NCnum
    write(*,*) 'CHECK: Time'
    ! Open NetCDF file
    write (YYYY, "(I4.4)") Syear
    write (MM, "(I2.2)") Smonth + iNC -1
    MRICOM_sufix = "_dy_"//YYYY//MM//".nc"
    allocate( INFILE(iNC)%NAME(5) )
    do i=1,5
      INFILE(iNC)%NAME(i) = &
        trim( MRICOM_data_dir )// MRICOM_prefix // &
        trim( MRICOM_VAR_NAME(i) )// MRICOM_sufix
    enddo
    write(*,*) "OPEN: ", trim( INFILE(iNC)%NAME(1) )
    call try_nf_open(INFILE(iNC)%NAME(1), nf90_nowrite, ncid)
    call get_dimension(ncid, 'time', INFILE(iNC)%Nt)
    write(*,*) INFILE(iNC)%Nt

    allocate( INFILE(iNC)%time_all(INFILE(iNC)%Nt) )
    call check( nf90_inq_varid(ncid, 'time', var_id) )
    call check( nf90_get_var(ncid, var_id, INFILE(iNC)%time_all) )
    call check( nf90_close(ncid) )
    write(*,*) "CLOSE: ", trim( INFILE(iNC)%NAME(1) )
    ! FORP 'time' is hours since the Julian-calendar 0001-01-01 -> julian date
    INFILE(iNC)%time_all = d_jdate_FORP_ref + INFILE(iNC)%time_all/24.0d0
  end do

  call infile_check_time( NCnum, dble(jdate_Start), dble(jdate_End), Nt, time, iNCt, idt )

# elif defined MOVEJPN_MODEL || defined FORA_MODEL

  write(*,*) "************ MOVE-JPN MODEL ************"

  allocate( time(30000) ) ! holds julian date during the scan
  Nt = 0
  itime = 1
  ihours = 0
  iyear = Syear
  imonth = Smonth
  iday = Sday
  call jd(iyear, imonth, iday, Sjdate)

  do
    ihour = mod(ihours,24)
    ijdate = Sjdate + int(ihours/24)
    call cdate( ijdate, iyear, imonth, iday )
    ! Check end date
    if(iyear==Eyear .and. imonth==Emonth .and. iday==Eday) then
      exit
    endif

    write (YYYY, "(I4.4)") iyear
    write (MM, "(I2.2)") imonth
    write (DD, "(I2.2)") iday
    write (hh, "(I2.2)") ihour
    call jd(iyear, imonth, iday, ijdate)

    ihours = ihours + 24  !!! Files exist daily interval
!    MRICOM_sufix_tmp = "."//YYYY//MM//DD
    MRICOM_sufix_tmp = "."//YYYY//MM//DD//".nc"
#  if defined MOVEJPN_MODEL
    MRICOM_FILE_tmp = &
        trim( MRICOM_data_dir )// MRICOM_prefix // &
        trim( MOVEJPN_VAR(1) )// MRICOM_sufix_tmp
    status = access( trim( MRICOM_FILE_tmp ), ' ' )
#  elif defined FORA_MODEL
    MRICOM_FILE_tmp = &
!        trim( MRICOM_data_dir )// "Basic-2D/" //YYYY// "/" // &
        trim( MRICOM_data_dir )//YYYY// "/" // &
        MRICOM_prefix // &
        trim( MOVEJPN_VAR(1) )// MRICOM_sufix_tmp
!    status = nf_exists( trim( MRICOM_FILE_tmp ) )
    status = access( trim( MRICOM_FILE_tmp ), ' ' )
#  endif

!    write(*,*) 'CHECK FILE: ', trim( MRICOM_FILE_tmp ), status !!!!!!!!!!!!! DEBUG
    if ( status /= 0 ) cycle
    Nt = Nt + 1
    MRICOM_FILE(Nt) = MRICOM_FILE_tmp
    time(Nt) = dble( ijdate ) + dble( ihour )/24.0d0  ! julian date
  enddo

  allocate(idt(Nt))
  allocate(iNCt(Nt))
  allocate( INFILE(Nt) )

  do iNC=1,Nt
    allocate( INFILE(iNC)%time_all(1) )
    INFILE(iNC)%time_all(1) = time(iNC)   ! julian date
    INFILE(iNC)%Nt = 1
    INFILE(iNC)%ItS = 1
    INFILE(iNC)%ItE = 1
    iNCt(iNC) = iNC
    idt(iNC)  = 1
    allocate( INFILE(iNC)%NAME(5) )
!    do i=1,5
    do i=1,1  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#  if defined MOVEJPN_MODEL
      INFILE(iNC)%NAME(i) = &
        trim( MRICOM_data_dir )// MRICOM_prefix // &
        trim( MOVEJPN_VAR(i) )// MRICOM_sufix(iNC)
#  elif defined FORA_MODEL
      if (i==1) then
        INFILE(iNC)%NAME(i) = MRICOM_FILE(iNC)
      else
        INFILE(iNC)%NAME(i) = &
          trim( MRICOM_data_dir )// "Basic-3D/" //YYYY// "/" // &
          MRICOM_prefix // &
          trim( MOVEJPN_VAR(i) )// MRICOM_sufix(iNC)
      endif
#  endif
    enddo
!    write(*,*) 'FILE ', iNC, trim( INFILE(iNC)%NAME(1) ) !!!!!!!!!!!!!!!!
  enddo

  write(*,*) "Total time step: ", Nt
  if( Nt <= 0 ) then
    write(*,*) "*** ERROR: No MOVE-JPN data file found for the requested period."
    write(*,*) "***   Check the date (&ini for INI_MODE, or &sdate/&edate) and"
    write(*,*) "***   MRICOM_data_dir = ", trim( MRICOM_data_dir )
    stop
  endif
  write(*,*) "Start file: ", trim( INFILE(1)%NAME(1) )
  write(*,*) "End file:   ", trim( INFILE(Nt)%NAME(1) )
# endif

  
  !---- Read FORP/MOVE-JPN netCDF grid cooredinate --------------------------------
!  write(*,*) "OPEN: ", trim( INFILE(iNCt(1))%NAME(4) )
!  call try_nf_open(trim( INFILE(iNCt(1))%NAME(4) ), nf90_nowrite, ncid)
  write(*,*) "OPEN: ", trim( INFILE(iNCt(1))%NAME(1) )
  call try_nf_open(trim( INFILE(iNCt(1))%NAME(1) ), nf90_nowrite, ncid)
  ! Get dimension data
  call get_dimension(ncid, 'lat', Nyr_dg)
  call get_dimension(ncid, 'lon', Nxr_dg)
# if defined FORP_MODEL
  call get_dimension(ncid, 'lev', Nzr_dg)
# elif defined MOVEJPN_MODEL || defined FORA_MODEL
!  call get_dimension(ncid, 'depth', Nzr_dg)
# endif
!  write(*,*) Nxr_dg, Nyr_dg, Nzr_dg
  write(*,*) Nxr_dg, Nyr_dg
 ! Allocate variable

  allocate( latst(Nyr_dg) )
  allocate( lonst(Nxr_dg) )
  allocate( depth(Nzr_dg) )

!  call readNetCDF_1d_safe(trim( INFILE(iNCt(1))%NAME(4) ), ncid, 'lat', Nyr_dg, latst)
!  call readNetCDF_1d_safe(trim( INFILE(iNCt(1))%NAME(4) ), ncid, 'lon', Nxr_dg, lonst)
  call readNetCDF_1d_safe(trim( INFILE(iNCt(1))%NAME(1) ), ncid, 'lat', Nyr_dg, latst)
  call readNetCDF_1d_safe(trim( INFILE(iNCt(1))%NAME(1) ), ncid, 'lon', Nxr_dg, lonst)
# if defined FORP_MODEL
  call readNetCDF_1d_safe(trim( INFILE(iNCt(1))%NAME(4) ), ncid, 'lev', Nzr_dg, depth)
# elif defined MOVEJPN_MODEL || defined FORA_MODEL
!  call readNetCDF_1d_safe(trim( INFILE(iNCt(1))%NAME(4) ), ncid, 'depth', Nzr_dg, depth)
# endif

  Nxr = 900
  Nyr = 1000
  allocate( sst(Nxr, Nyr) )
  allocate( DHW(Nxr, Nyr) )
  allocate( DCW(Nxr, Nyr) )
  allocate( HS(Nxr, Nyr, 84) )
  allocate( CS(Nxr, Nyr, 84) )
  DHW = 0.0d0
  DCW = 0.0d0
  HS = 0.0d0
  CS = 0.0d0

  call check( nf90_close(ncid) )
  write(*,*) "CLOSE: ", trim( INFILE(iNCt(1))%NAME(1) )

  write(*,*) "*************************************" 

#else
  write(*,*) "************ Please choose a OCEAN MODEL ************"
  Stop
#endif

! ----------------------------------------------------
!========================================================================
!  Output generation mode: select ONE of -DBRY_MODE / -DHIS_MODE / -DINI_MODE
!========================================================================
!-Output file name + creation (mode-specific) --------------------------------
!  Name the file by the data period (time is a julian date). BRY/HIS are time
!  series (<start>-<end>); INI is a single time.
  call jd2yyyymmddpHHMM( time(1),  ds_str )
  call jd2yyyymmddpHHMM( time(Nt), de_str )
  
  OUT_FILE = trim( HIS_prefix )//'_'//ds_str//'-'//de_str//'.nc'
  call createNetCDFcrl(  trim( OUT_FILE ), TIME_ATT, Nxr, Nyr, 1, 1, Fill_temp )
  ! Land points of temp are written as Fill_temp; declare it as _FillValue so
  ! readers (ncview, xarray, ...) mask them automatically.
  call check( nf90_open(trim( OUT_FILE ), NF90_WRITE, ncid2) )
  start1D = (/ 1 /)
  count1D = (/ Nxr /)
  call check( nf90_inq_varid(ncid2, 'lon', var_id) )
  call check( nf90_put_var(ncid2, var_id, lonst, start = start1D, count = count1D) )
  start1D = (/ 1 /)
  count1D = (/ Nyr /)
  call check( nf90_inq_varid(ncid2, 'lat', var_id) )
  call check( nf90_put_var(ncid2, var_id, latst, start = start1D, count = count1D) )

  call check( nf90_redef(ncid2) )
  call check( nf90_inq_varid(ncid2, 'DCW', var_id2) )
  call check( nf90_put_att(ncid2, var_id2, '_FillValue', Fill_temp) )
  call check( nf90_close(ncid2) )


!========================================================================
!  LOOP START      
!========================================================================
  iNC = 0

  ! initialize the day index for the 84-day output (1-based)
  do i=1, 84
    id_day(i) = i
  enddo

  ! ===== time loop (outer); regions (inner) write into one OUT_FILE =====
  do itime=1,Nt
    iNCm = iNC
    iNC  = iNCt(itime)

#if defined ROMS_MODEL
    if(iNCm < iNC) then
      ! ----- shared donor-grid load (boundary-independent; open file once) -----
      write(*,*) "OPEN: ", trim( ROMS_HISFILE(iNC) )
      call check( nf90_open(trim( ROMS_HISFILE(iNC) ), nf90_nowrite, ncid) )

    endif
#endif

    ! time(itime) is a julian date; convert to "sec since &refdate" for the ROMS file
    ocean_time(1) = ( time(itime) - d_jdate_Ref )*86400.0d0

    call jd2yyyymmddpHHMM( time(itime), date_str )
    Write(*,*) 'Time = ',date_str

    start1D = (/ itime /)
    count1D = (/ 1 /)
    call check( nf90_open(trim( OUT_FILE ), NF90_WRITE, ncid2) )
    call check( nf90_inq_varid(ncid2, 'time', var_id) )
    call check( nf90_put_var(ncid2, var_id, ocean_time, start = start1D, count = count1D) )
    call check( nf90_close(ncid2) )

#if defined WET_DRY
    ! ROMS+WET_DRY: read this step's wetdry mask (idt(itime)) and fold it into
    ! the u/v weight masks (static land mask x wetdry) so the weights follow the
    ! moving wet/dry front. The same mask is reused when masking the u/v data.
    start3D = (/ Iudg_min, Judg_min+1, idt(itime) /)
    count3D = (/ Nxu_dg,   Nyu_dg,     1          /)
    call check( nf90_inq_varid(ncid, 'wetdry_mask_u', var_id) )
    call check( nf90_get_var(ncid, var_id, umask_wet_dg, start3D, count3D)  )
    start3D = (/ Ivdg_min+1, Jvdg_min, idt(itime) /)
    count3D = (/ Nxv_dg,     Nyv_dg,   1          /)
    call check( nf90_inq_varid(ncid, 'wetdry_mask_v', var_id) )
    call check( nf90_get_var(ncid, var_id, vmask_wet_dg, start3D, count3D)  )
    if( .not. allocated(umask_eff) ) allocate( umask_eff, mold=umask_dg )
    if( .not. allocated(vmask_eff) ) allocate( vmask_eff, mold=vmask_dg )
    do j=Judg_min,Judg_max
      do i=Iudg_min,Iudg_max
        umask_eff(i,j) = umask_dg(i,j)*umask_wet_dg(i,j,1)
      enddo
    enddo
    do j=Jvdg_min,Jvdg_max
      do i=Ivdg_min,Ivdg_max
        vmask_eff(i,j) = vmask_dg(i,j)*vmask_wet_dg(i,j,1)
      enddo
    enddo
#endif

    !- zeta --------------------------------
#if defined ROMS_MODEL
    write(*,*) 'Read: '//trim( ROMS_HISFILE(iNC) )
    write(*,*) 'Read: zeta'
    start3D = (/ Irdg_min+1, Jrdg_min+1, idt(itime) /)
    count3D = (/ Nxr_dg,     Nyr_dg,     1          /)
    call check( nf90_inq_varid(ncid, 'zeta', var_id) )
    call check( nf90_get_var(ncid, var_id, zeta_dg, start3D, count3D)  )
#elif defined MRICOM_MODEL
    write(*,*) 'Read: '//trim( INFILE(iNC)%NAME(1) )
    write(*,*) 'Read: '//trim( MRICOM_VAR_NAME(4) )
    start3D = (/ 1,   1,   idt(itime) /)
    count3D = (/ Nxr, Nyr,     1      /)
    call readNetCDF_3d_mricom( trim( INFILE(iNC)%NAME(1) ), trim( MRICOM_VAR_NAME(4) )  &
          , Nxr, Nyr, 1, start3D, count3D, sst )

#endif

    ! Calculate DHW and DCW from sst
    HS(:,:,id_day(1)) = sst-29.0d0
    CS(:,:,id_day(1)) = 21.5d0 - sst
    where(HS(:,:,id_day(1))<1.0d0) HS(:,:,id_day(1)) = 0.0d0
    where(CS(:,:,id_day(1))<1.0d0) CS(:,:,id_day(1)) = 0.0d0  
    DHW = DHW + ( HS(:,:,id_day(1))-HS(:,:,id_day(84)) )/7.0d0
    DCW = DCW + ( CS(:,:,id_day(1))-CS(:,:,id_day(84)) )/7.0d0

    ! update  id_day for the 84-day output (1-based)
    id_day_tmp = id_day(84)
    do i=84, 2, -1
      id_day(i) = id_day(i-1)
!      write(*,*) 'itime = ', itime, ',', i, id_day(i)
    enddo
    id_day(1) = id_day_tmp
!    write(*,*) 'itime = ', itime, ',', 1, id_day(1)

    ! temp is (xi_rho, eta_rho, s_rho, ocean_time): time is the 4th dimension
    start3D = (/ 1,      1,      itime /)
    count3D = (/ Nxr, Nyr, 1     /)
    write(*,*)  'Write: sst', itime, Nxr, Nyr
    ! Mask land with the _FillValue declared on temp
    do j=1,Nyr
      do i=1,Nxr
        if( sst(i,j) < -300.0d0 ) then
          sst(i,j) = Fill_temp
          DHW(i,j) = Fill_temp
          DCW(i,j) = Fill_temp
        endif
      enddo
    enddo
    call check( nf90_open(trim( OUT_FILE ), NF90_WRITE, ncid2) )
    call check( nf90_inq_varid(ncid2, 'SST', var_id2) )
    call check( nf90_put_var(ncid2, var_id2, sst, start = start3D, count = count3D) )
    call check( nf90_inq_varid(ncid2, 'DCW', var_id2) )
    call check( nf90_put_var(ncid2, var_id2, DCW, start = start3D, count = count3D) )
    call check( nf90_inq_varid(ncid2, 'DHW', var_id2) )
    call check( nf90_put_var(ncid2, var_id2, DHW, start = start3D, count = count3D) )
    call check( nf90_close(ncid2) )

#if defined ROMS_MODEL
    ! ROMS keeps a persistent ncid per his file; close it whenever we leave the file
    if( leaving_file ) then
      call check( nf90_close(ncid) )
      write(*,*) "CLOSE: ", trim( ROMS_HISFILE(iNC) )
    endif
#endif

  enddo   ! itime

  write(*,*) '***************** extraction complete! *****************'

  write(*,*) 'FINISH!!'
      
END PROGRAM main_OCN_offline
      
