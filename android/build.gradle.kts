allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// file_picker 11.x and in_app_update 5.x skip the Kotlin Gradle Plugin on AGP 9+
// expecting built-in Kotlin, but this project runs KGP mode
// (android.builtInKotlin=false). Apply it manually and align jvmTarget with the
// plugin's Java compileOptions.
project(":file_picker") {
    pluginManager.apply("org.jetbrains.kotlin.android")
    plugins.withId("org.jetbrains.kotlin.android") {
        extensions.configure<org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension> {
            compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

project(":in_app_update") {
    // Apply KGP after AGP so the Android source sets are wired before Kotlin
    // configures its compile tasks.
    pluginManager.withPlugin("com.android.library") {
        pluginManager.apply("org.jetbrains.kotlin.android")
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

