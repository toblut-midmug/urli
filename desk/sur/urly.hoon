|%
+$  url-alias  @t
+$  url  @t
+$  mapping  (map url-alias url)
+$  state-0  [%0 =mapping]
+$  action 
  $%  [%shorten =url]
      [%shorten-custom =url-alias =url]
      [%delete =url-alias]
  ==
--
