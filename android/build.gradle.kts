import org.gradle.api.file.Directory
import org.gradle.api.tasks.Delete

// Repositories for all modules
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Google Services classpath for Firebase
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Firebase Google Services Gradle plugin
        classpath("com.google.gms:google-services:4.4.2")
    }
}

// Flutter's custom build directory setup
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
