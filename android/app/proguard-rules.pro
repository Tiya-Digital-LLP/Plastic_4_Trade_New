# Preserve Razorpay classes and methods
-keep class com.razorpay.** { *; }

# Preserve Google Pay classes used by Razorpay
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }

# Preserve classes for Protobuf
-keep class com.google.protobuf.** { *; }

# Preserve ProGuard annotations used by Razorpay
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Preserve extension registry loader classes
-keep class com.google.protobuf.GeneratedExtensionRegistryLoader { *; }

# Ensure R8 keeps gRPC services
-keep class io.grpc.ServiceProviders { *; }

# Suppress warnings for missing classes
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.PaymentsClient
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.Wallet
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.WalletUtils
-dontwarn com.google.protobuf.java_com_google_android_gmscore_sdk_target_granule__proguard_group_gtm_N1281923064GeneratedExtensionRegistryLite$Loader

# Add the following to suppress warnings and keep required classes
-dontwarn com.google.android.gms.auth.api.credentials.Credential$Builder
-dontwarn com.google.android.gms.auth.api.credentials.Credential
-dontwarn com.google.android.gms.auth.api.credentials.CredentialPickerConfig$Builder
-dontwarn com.google.android.gms.auth.api.credentials.CredentialPickerConfig
-dontwarn com.google.android.gms.auth.api.credentials.CredentialRequest$Builder
-dontwarn com.google.android.gms.auth.api.credentials.CredentialRequest
-dontwarn com.google.android.gms.auth.api.credentials.CredentialRequestResponse
-dontwarn com.google.android.gms.auth.api.credentials.Credentials
-dontwarn com.google.android.gms.auth.api.credentials.CredentialsClient
-dontwarn com.google.android.gms.auth.api.credentials.HintRequest$Builder
-dontwarn com.google.android.gms.auth.api.credentials.HintRequest

# Keep rules for the classes to avoid obfuscation and shrinking
-keep class com.google.android.gms.auth.api.credentials.** { *; }
