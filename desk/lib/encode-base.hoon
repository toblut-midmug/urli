|%
++  encode-base
  |=  [a=@ base-digits=tape]
  ^-  tape
  =/  b  (lent base-digits)
  =/  t  ""  
  =/  digit=@  (mod a b)
  =.  a  (div a b)
  =/  k=@  1
  |-  
    ~&  digit
  ?:  .=(a 0)  
    (weld (trip (snag digit base-digits)) t)
  %=  $
    k  +(k)
    a  (div a b)
    digit  (mod a b)
    t  (weld (trip (snag digit base-digits)) t)
  ==
--
