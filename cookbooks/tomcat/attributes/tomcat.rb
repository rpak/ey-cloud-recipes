set_unless[:tomcat][:version]                 = "6.0.26"
set_unless[:tomcat][:with_native]             = true
set_unless[:tomcat][:java_home]               = "/usr/lib/jvm/java"
set_unless[:tomcat][:java_opts]               = ""
set_unless[:tomcat][:permgen_min_free_in_mb]  = 24
set_unless[:tomcat][:checksum]                = "f9eafa9bfd620324d1270ae8f09a8c89"