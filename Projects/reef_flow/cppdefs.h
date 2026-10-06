
#define USE_HEAT
#define LONGWAVE_IN
/*#define INPUT_BOTTOM_PFD*/

#define REEF_FLOW
#define REEF_FLOW_TESTMODE

#define INPUT_ROMS_FRC
#define INPUT_SWAN
#define INPUT_ROMS_NCDUMP
/*----- CPP defines for coral module ----------------*/
/***  Biological model options. (Original CPP flags) ***/
#define MARINE_COMET

#if defined MARINE_COMET
# define BIOLOGY
# define ANA_BIOLOGY
# define ANA_TOBC_BIO   /*Original CPP flag */

/* compartments */
# define ORGANIC_MATTER
# define NUTRIENTS
/*# define CARBON_ISOTOPE*/
# if defined CARBON_ISOTOPE
#  define CARBON_TRACE
# endif

# define CORAL_POLYP  /* USE coral module */
# define SEAGRASS     /* USE seagrass module */
# define MACROALGAE        /* USE algae module  */
# define SEDIMENT_ECOSYS        /* USE sedecosys module  */
# if defined SEDIMENT_ECOSYS
/*#  define SEDIMENT_EMPIRICAL*/     /* mod_sedecosys_empirical.F is in no build script and is never USEd, so this path cannot compile */
# endif

# if defined ORGANIC_MATTER
#  define FOODWEB      /* USE foodweb module */
# endif

# define AIR_SEA_GAS_EXCHANGE

/*** Coral Polyp model options. ***/
# if defined CORAL_POLYP
#  define CORAL_ZOOXANTHELLAE
#  define CORAL_PHOTOINHIBITION
/*#  define CORAL_MUCUS*/           /*Mucus release from coral */
#  if defined ORGANIC_MATTER
/*#   define CORAL_INGESTION*/
#  endif
#  define CORAL_SIZE_DYNAMICS
#  if defined CARBON_ISOTOPE
#   define CORAL_CARBON_ISOTOPE
/*#   define CORAL_NONE_CO2_EQ*/
#  endif
#  if defined NUTRIENTS
/*#   define CORAL_NUTRIENTS*/
#  endif
/*#  define CORAL_BORON_ISOTOPE*/
# endif

#endif


/*** Box model option ***/

/* Set output interval for each model */
#define ECOSYS_OUTPUT_INTERVAL 60.0d0  /* Output interval (min) */
#define SEDECO_OUTPUT_INTERVAL 1440.0d0  /* Output interval (min) */
#define CORAL_OUTPUT_INTERVAL   5.0d0  /* Output interval (min) */
#define CORAL_AVERAGE_INTERVAL  1.0d0  /* Averaging interval (day) */
#define FLOW_OUTPUT_INTERVAL    5.0d0  /* Output interval (min) */
#define SEAGRASS_OUTPUT_INTERVAL 60.0d0  /* Output interval (min) */

#define ECOSYS_TESTMODE

#if defined CORAL_POLYP
# define CORAL_TESTMODE
#endif
#if defined SEDIMENT_ECOSYS
/*# define SEDIMENT_TESTMODE*/
#endif

/*** Chamber experiments option ***/
/*#define CHAMBER_SITE4*/

/*----------------------------------------------------*/

