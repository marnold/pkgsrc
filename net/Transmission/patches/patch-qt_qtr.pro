$NetBSD: patch-qt_qtr.pro,v 1.1.2.2 2012/07/30 22:12:18 tron Exp $

--- qt/qtr.pro.orig	2012-07-06 01:24:43.000000000 +0000
+++ qt/qtr.pro
@@ -8,7 +8,7 @@ target.path = /bin
 INSTALLS += target
 
 unix: INSTALLS += man
-man.path = /share/man/man1/
+man.path = /man/man1/
 man.files = transmission-qt.1
 
 CONFIG += qt qdbus thread debug link_pkgconfig
