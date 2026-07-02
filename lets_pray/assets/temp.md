Launching lib/main.dart on SM A047F in debug mode...
e: The daemon has terminated unexpectedly on startup attempt #1 with error code: 0. The daemon process output:
    1. Kotlin compile daemon is ready
warning: [options] source value 8 is obsolete and will be removed in a future release
warning: [options] target value 8 is obsolete and will be removed in a future release
warning: [options] To suppress warnings about obsolete options, use -Xlint:-options.
3 warnings
warning: [options] source value 8 is obsolete and will be removed in a future release
warning: [options] target value 8 is obsolete and will be removed in a future release
warning: [options] To suppress warnings about obsolete options, use -Xlint:-options.
3 warnings
warning: [options] source value 8 is obsolete and will be removed in a future release
warning: [options] target value 8 is obsolete and will be removed in a future release
warning: [options] To suppress warnings about obsolete options, use -Xlint:-options.
3 warnings
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Error: ADB exited with exit code 1
Performing Streamed Install

adb: failed to install /Users/tech02/StudioProjects/Holy/lets_pray/build/app/outputs/flutter-apk/app-debug.apk: Failure [INSTALL_FAILED_UPDATE_INCOMPATIBLE: Existing package com.brellah.lets_pray signatures do not match newer version; ignoring!]
Uninstalling old version...
E/AndroidRuntime(17018): FATAL EXCEPTION: main
E/AndroidRuntime(17018): Process: com.brellah.lets_pray, PID: 17018
E/AndroidRuntime(17018): java.lang.RuntimeException: Unable to instantiate activity ComponentInfo{com.brellah.lets_pray/com.brellah.lets_pray.MainActivity}: java.lang.ClassNotFoundException: Didn't find class "com.brellah.lets_pray.MainActivity" on path: DexPathList[[zip file "/data/app/~~ofdDPtGNmgdS96Gyd6MSDA==/com.brellah.lets_pray-TPmAgv7PmaqeJIvT0iHQJA==/base.apk"],nativeLibraryDirectories=[/data/app/~~ofdDPtGNmgdS96Gyd6MSDA==/com.brellah.lets_pray-TPmAgv7PmaqeJIvT0iHQJA==/lib/arm64, /data/app/~~ofdDPtGNmgdS96Gyd6MSDA==/com.brellah.lets_pray-TPmAgv7PmaqeJIvT0iHQJA==/base.apk!/lib/arm64-v8a, /system/lib64]]
E/AndroidRuntime(17018): 	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:4047)
E/AndroidRuntime(17018): 	at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:4322)
E/AndroidRuntime(17018): 	at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:103)
E/AndroidRuntime(17018): 	at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:139)
E/AndroidRuntime(17018): 	at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:96)
E/AndroidRuntime(17018): 	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2685)
E/AndroidRuntime(17018): 	at android.os.Handler.dispatchMessage(Handler.java:106)
E/AndroidRuntime(17018): 	at android.os.Looper.loopOnce(Looper.java:230)
E/AndroidRuntime(17018): 	at android.os.Looper.loop(Looper.java:319)
E/AndroidRuntime(17018): 	at android.app.ActivityThread.main(ActivityThread.java:8919)
E/AndroidRuntime(17018): 	at java.lang.reflect.Method.invoke(Native Method)
E/AndroidRuntime(17018): 	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:578)
E/AndroidRuntime(17018): 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1103)
E/AndroidRuntime(17018): Caused by: java.lang.ClassNotFoundException: Didn't find class "com.brellah.lets_pray.MainActivity" on path: DexPathList[[zip file "/data/app/~~ofdDPtGNmgdS96Gyd6MSDA==/com.brellah.lets_pray-TPmAgv7PmaqeJIvT0iHQJA==/base.apk"],nativeLibraryDirectories=[/data/app/~~ofdDPtGNmgdS96Gyd6MSDA==/com.brellah.lets_pray-TPmAgv7PmaqeJIvT0iHQJA==/lib/arm64, /data/app/~~ofdDPtGNmgdS96Gyd6MSDA==/com.brellah.lets_pray-TPmAgv7PmaqeJIvT0iHQJA==/base.apk!/lib/arm64-v8a, /system/lib64]]
E/AndroidRuntime(17018): 	at dalvik.system.BaseDexClassLoader.findClass(BaseDexClassLoader.java:259)
E/AndroidRuntime(17018): 	at java.lang.ClassLoader.loadClass(ClassLoader.java:642)
E/AndroidRuntime(17018): 	at java.lang.ClassLoader.loadClass(ClassLoader.java:578)
E/AndroidRuntime(17018): 	at android.app.AppComponentFactory.instantiateActivity(AppComponentFactory.java:95)
E/AndroidRuntime(17018): 	at androidx.core.app.CoreComponentFactory.instantiateActivity(CoreComponentFactory.java:44)
E/AndroidRuntime(17018): 	at android.app.Instrumentation.newActivity(Instrumentation.java:1378)
E/AndroidRuntime(17018): 	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:4034)
E/AndroidRuntime(17018): 	... 12 more
