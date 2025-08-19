allprojects {
    repositories {
        maven(url = "https://maven.aliyun.com/repository/google")
        maven(url = "https://maven.aliyun.com/repository/central")
        maven(url = "https://maven.aliyun.com/repository/gradle-plugin")
        maven(url = "https://jitpack.io")
        maven(url = "https://developer.huawei.com/repo/")
        maven(url = "https://developer.hihonor.com/repo/")
        flatDir {
            dirs("libs")
        }
        //Anythink(Core)
        maven(url = "https://jfrog.takuad.com/artifactory/china_sdk")
        maven(url = "https://artifact.bytedance.com/repository/pangle")
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
