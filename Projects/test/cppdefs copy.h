
/*#define USE_HEAT*/
/*#define LONGWAVE_IN*/

/*#define REEF_FLOW*/


/*----- CPP defines for coral module ----------------*/
/***  Biological model options. (Original CPP flags) ***/
#define MARINE_COMET

#if defined MARINE_COMET
# define BIOLOGY
# define ANA_BIOLOGY

/* compartments */
/*# define ORGANIC_MATTER*/
/*# define CARBON_ISOTOPE*/
/*# define NUTRIENTS*/

# define CORAL_POLYP  /* USE coral module */
/*# define SEAGRASS*/     /* USE seagrass module */
/*# define MACROALGAE*/        /* USE algae module  */
/*# define SEDIMENT_ECOSYS*/        /* USE sedecosys module  */
# if defined SEDIMENT_ECOSYS
#  define SEDIMENT_EMPIRICAL     /* USE empirical sediment module  */
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
#   define CORAL_INGESTION
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

