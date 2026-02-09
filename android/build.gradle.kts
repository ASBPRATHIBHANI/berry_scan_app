// 1. Define where to download libraries (Crucial for Appwrite/Flutter)
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 2. Configure Build Directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// 3. Ensure App evaluates first
subprojects {
    project.evaluationDependsOn(":app")
}

// 4. Clean Task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}