allprojects {
    repositories {
        google()
        mavenCentral()
    }
    configurations.all {
        resolutionStrategy {
            force("androidx.glance:glance-appwidget:1.1.1")
            force("androidx.glance:glance:1.1.1")
        }
    }
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            if (android is com.android.build.gradle.BaseExtension) {
                android.compileSdkVersion(36)
            }
        }
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

subprojects {
    project.plugins.withId("com.android.library") {
        project.extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            if (namespace == null || namespace == "com.dsi.facebook_audience_network") {
                namespace = "com.facebook.ads.sdk.${project.name.replace("-", ".")}"
            }
        }
        
        // Patch manifest to remove 'package' attribute for AGP 8+ compatibility
        val patchManifestTask = project.tasks.register("patchManifest") {
            doFirst {
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val content = manifestFile.readText()
                    if (content.contains("package=\"")) {
                        println("Patching manifest for project: ${project.name}")
                        val newContent = content.replace(Regex("""package="[^"]*""""), "")
                        manifestFile.writeText(newContent)
                    }
                }
                // Also check for manifest in other locations if necessary
                val manifests = project.fileTree(project.projectDir).matching {
                    include("**/AndroidManifest.xml")
                }
                manifests.forEach { file ->
                    val content = file.readText()
                    if (content.contains("package=\"")) {
                        println("Patching additional manifest: ${file.absolutePath}")
                        val newContent = content.replace(Regex("""package="[^"]*""""), "")
                        file.writeText(newContent)
                    }
                }
            }
        }

        project.tasks.configureEach {
            if (name.contains("process", ignoreCase = true) && name.contains("Manifest", ignoreCase = true)) {
                dependsOn(patchManifestTask)
            }
        }
    }
}

subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
