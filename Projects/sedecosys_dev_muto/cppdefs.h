/* -------------------------- */
/*      For SEDECOSYS_dev     */
/*  edited by Masa Muto 2023  */
/* -------------------------- */

/*#define USE_HEAT*/
/*#define LONGWAVE_IN*/
/*#define INPUT_BOTTOM_PFD*/

/*#define REEF_FLOW*/

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




/*----- sediment dev module --------------------*/

/*# define CORAL_POLYP*/  /* USE coral module */
/*# define SEAGRASS*/     /* USE seagrass module */
/*# define MACROALGAE*/        /* USE algae module  */
# define SEDIMENT_ECOSYS       /* USE sedecosys module  */

# if defined SEDIMENT_ECOSYS
/* #  define SEDIMENT_EMPIRICAL     /* USE empirical sediment module  */

/*#  define initialmode    /* For initial concentration determination */

#  define SULFATE      /* For manganese, iron, and sulfate reduction in sediment */
#  define Burial       /* For Burial term in sediment transport (massbalance) */
#  define adsorption 
/* #  define sedORP */    /* For primary reaction theory by free energy */
#  define sedBC_closed    /* closed boundary condition at the bottom sediment layer */
# endif
/*----------------------------------------------------*/






# if defined ORGANIC_MATTER
#  define FOODWEB     /* USE foodweb module */
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

#define ECOSYS_TESTMODE

#if defined CORAL_POLYP
# define CORAL_TESTMODE
#endif
#if defined SEDIMENT_ECOSYS
# define SEDIMENT_TESTMODE
#endif
#if defined MM_SEDIMENT_ECOSYS
# define SEDIMENT_TESTMODE
#endif
#if defined FOODWEB 
# define FOODWEB_TESTMODE
#endif
/*** Chamber experiments option ***/
/*#define CHAMBER_SITE4*/

/*----------------------------------------------------*/

