.( example: radix for number conversions )

decimal
: octal  8 base !  ;
: binary 2 base !  ;

.( try converting numbers among different radices: )
.( decimal 12345 hex .           => ) decimal 12345 hex  .
.( decimal 100 binary .          => ) decimal 100 binary  .
.( binary 101010101010 decimal . => ) binary 101010101010 decimal .
