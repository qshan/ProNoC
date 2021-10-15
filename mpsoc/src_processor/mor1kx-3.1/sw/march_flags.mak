MARCH_MULTIPLIER=${FEATURE_MULTIPLIER}
MARCH_DIVIDER=${FEATURE_DIVIDER}


ifeq (${MARCH_MULTIPLIER},"NONE")
  MARCH_MUL_FLG=-msoft-mul
else
  MARCH_MUL_FLG=-mhard-mul
endif

ifeq (${MARCH_DIVIDER},"NONE")
  MARCH_DIV_FLG=-msoft-div
else
  MARCH_DIV_FLG=-mhard-div
endif



MARCH_FLAGS ?=${MARCH_MUL_FLG} ${MARCH_DIV_FLG} -msoft-float