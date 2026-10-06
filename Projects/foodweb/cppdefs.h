
/*#define SEDIMENT*/

/*** submarine groundwater discharge ***/

/*#define SGD_ON*/    /*Original CPP flag */

/***  Biological model options. (Original CPP flags) ***/

#define MARINE_COMET

#if defined MARINE_COMET || defined SEDIMENT
# define ANA_TOBC_BIO 
# define ANA_TOBC_SED
/*# define BIO_VPROFILE_YAEYAMA*/
#endif

#if defined MARINE_COMET
# define BIOLOGY
# define DIAGNOSTICS_BIO
# define ANA_BIOLOGY

/*** Isotopes or tracer options ***/
/*# define CARBON_ISOTOPE*/
/*# define CARBON_TRACE*/
/*# define CLUMPED_ISOTOPE*/

/*# define NITROGEN_ISOTOPE*/
/*# define NITROGEN_TRACE*/

/*# define PHOSPHOROUS_TRACE*/

/*# define SULFUR_ISOTOPE*/
/*# define SULFUR_TRACE*/


/*** MARINE_COMET compartments ***/
/*# define CORAL_POLYP*/  /* USE coral module */
/*# define SEAGRASS*/     /* USE seagrass module */
/*# define MACROALGAE*/   /* USE algae module  */
# define FOODWEB      /* USE foodweb module */
/*# define SEDIMENT_ECOSYS*/   /* USE sedecosys module  */

/*# define AIR_SEA_GAS_EXCHANGE*/

/*# define DYNAMIC_COVERAGE*/ /* yt_edit not yet implemented in coawst */


/*** Coral Polyp model options. ***/
# if defined CORAL_POLYP
#  define CORAL_ZOOXANTHELLAE
#  define CORAL_MUCUS           /*Mucus release from coral */
#  define CORAL_INGESTION
/*#  define CORAL_NONE_CO2_EQ*/
/*#  define CORAL_NUTRIENTS*/
/*#  define CORAL_SIZE_DYNAMICS*/
/*#  define CORAL_BORON_ISOTOPE*/
# endif


/*** Seagrass model options. ***/
# if defined SEAGRASS
#  define SEAGRASS_LEAF_NUTRIENT_UPTAKE
#  if defined SEDIMENT_ECOSYS
/*#   define SEAGRASS_ROOT_CARBON_OXYGEN_EXCHANGE*/
#  endif
#  if defined SEDIMENT_ECOSYS
#   define SEAGRASS_ROOT_NUTRIENT_UPTAKE
#  endif
#  define SEAGRASS_LEAF_POM
#  if defined SEDIMENT_ECOSYS
#   define SEAGRASS_ROOT_POM
#  endif
# endif


/*** Sediment model options. ***/
/*#  define SEDIMENT_EMPIRICAL*/     /* USE empirical sediment module  */
# if defined SEDIMENT_ECOSYS  /* Masa_edits */
/*#  define SEDECO_CSV_RESTART*/  /* Restart from sedeco_rst.csv file if start_of_new_run = .true. */
#  if defined SEDIMENT
#   define SEDECO_BURIAL    /* For Burial term in sediment transport (massbalance) */
#  endif
#  if defined SGD_ON
#   define SEDECO_SGD    /* For Burial term in sediment transport (massbalance) */
#  endif
# endif

#endif

/*----------------------------------------------------*/
/*** Box model option ***/

/* Set output interval for each model */
#define ECOSYS_OUTPUT_INTERVAL 60.0d0  /* Output interval (min) */
#define SEDECO_OUTPUT_INTERVAL 60.0d0  /* Output interval (min) */
#define CORAL_OUTPUT_INTERVAL   5.0d0  /* Output interval (min) */
#define CORAL_AVERAGE_INTERVAL  1.0d0  /* Averaging interval (day) */
#define FLOW_OUTPUT_INTERVAL    5.0d0  /* Output interval (min) */
#define SEAGRASS_OUTPUT_INTERVAL 60.0d0  /* Output interval (min) */

/*#define USE_HEAT*/
/*#define LONGWAVE_IN*/
#define INPUT_BOTTOM_PFD
#define ANA_SWRAD_ZILLMAN

/*#define REEF_FLOW*/

#define ECOSYS_TESTMODE
#if defined CORAL_POLYP
# define CORAL_TESTMODE
#endif
#if defined SEDIMENT_ECOSYS
# define SEDIMENT_TESTMODE
#endif
#if defined FOODWEB 
# define FOODWEB_TESTMODE
#endif
#if defined SEAGRASS 
# define SEAGRASS_TESTMODE
#endif

/*** Chamber experiments option ***/
/*#define CHAMBER_SITE4*/

/*#define TRACER_TEST*/
#if defined TRACER_TEST
# define CARBON_TRACE
# define NITROGEN_TRACE
# define PHOSPHOROUS_TRACE
# define CPOM_TRACERS
/*# define OCN_NUTRIENT_TRACERS*/
/*# define SGD_NUTRIENT_TRACERS*/
#endif

/*----------------------------------------------------*/

