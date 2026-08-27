allprojects {
    repositories {
        google()
        mavenCentral()
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
// Some Flutter plugins (e.g. sentry_flutter) pin Kotlin languageVersion 1.6,
// which the Kotlin 2.x compiler no longer accepts. Force 1.9 for all plugins.
subprojects {
    project.evaluationDependsOn(":app")
}

// Some Flutter plugins (e.g. sentry_flutter) pin Kotlin languageVersion 1.6,
// which the Kotlin 2.x compiler no longer accepts. Force 1.9 for all plugins
// via lazy configuration so project evaluation order stays irrelevant.
allprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>()
        .configureEach {
            compilerOptions {
                languageVersion =
                    org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_1_9
                apiVersion =
                    org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_1_9
            }
        }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
