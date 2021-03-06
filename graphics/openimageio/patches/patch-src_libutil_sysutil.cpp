$NetBSD: patch-src_libutil_sysutil.cpp,v 1.1 2014/04/07 12:15:55 ryoon Exp $

--- src/libutil/sysutil.cpp.orig	2014-04-03 06:08:57.000000000 +0000
+++ src/libutil/sysutil.cpp
@@ -70,6 +70,12 @@
 # include <sys/ioctl.h>
 #endif
 
+#ifdef __NetBSD__
+# include <unistd.h>
+# include <sys/ioctl.h>
+# include <sys/sysctl.h>
+#endif
+
 #include "dassert.h"
 
 #include "sysutil.h"
@@ -109,6 +115,12 @@ Sysutil::memory_used (bool resident)
     return size;
 #endif
 
+#elif defined(__NetBSD__)
+    struct rusage ru;
+    if(getrusage (RUSAGE_SELF, &ru) == 0) {
+        return (size_t)ru.ru_maxrss * (size_t)1024;
+    }
+    exit(0);
 #elif defined(__APPLE__)
     // Inspired by:
     // http://miknight.blogspot.com/2005/11/resident-set-size-in-mac-os-x.html
@@ -193,7 +205,12 @@ Sysutil::physical_memory ()
     size_t length = sizeof(physical_memory);
     sysctl (mib, 2, &physical_memory, &length, NULL, 0);
     return physical_memory;
-
+#elif defined(__NetBSD__) || defined(__OpenBSD__)
+    int mib[1] = {HW_PHYSMEM64};
+    size_t physical_memory = 0;
+    size_t length = sizeof(physical_memory);
+    sysctl(mib, 2, &physical_memory, &length, NULL, 0);
+    return physical_memory;
 #else
     // No idea what platform this is
     ASSERT (0 && "Need to implement Sysutil::physical_memory on this platform");
@@ -245,6 +262,10 @@ Sysutil::this_program_path ()
     size_t cb = sizeof(filename);
     int r=1;
     sysctl(mib, 4, filename, &cb, NULL, 0);
+#elif defined(__NetBSD__)
+    unsigned int size = sizeof(filename);
+    int r = readlink ("/proc/curproc/exe", filename, size);
+    ASSERT(r < int(size)); // user won't get the right answer if the filename is too long to store
 #elif defined(__GNU__) || defined(__OpenBSD__)
     int r = 0;
 #else
@@ -276,7 +297,7 @@ Sysutil::terminal_columns ()
 {
     int columns = 80;   // a decent guess, if we have nothing more to go on
 
-#if defined(__linux__) || defined(__APPLE__) || defined(__FreeBSD__) || defined(__FreeBSD_kernel__) || defined(__GNU__)
+#if defined(__linux__) || defined(__APPLE__) || defined(__FreeBSD__) || defined(__FreeBSD_kernel__) || defined(__GNU__) || defined(__NetBSD__)
     struct winsize w;
     ioctl (0, TIOCGWINSZ, &w);
     columns = w.ws_col;
