$NetBSD: patch-.._actionpack-3.0.4.gemspec,v 1.1.2.2 2011/02/25 10:50:46 tron Exp $

--- ../actionpack-3.0.4.gemspec.orig	2011-02-09 03:11:46.000000000 +0000
+++ ../actionpack-3.0.4.gemspec
@@ -56,7 +56,7 @@ dependencies: 
   requirement: &id003 !ruby/object:Gem::Requirement 
     none: false
     requirements: 
-    - - ~>
+    - - >=
       - !ruby/object:Gem::Version 
         hash: 15
         segments: 
