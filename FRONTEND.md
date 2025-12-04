# Frontend Dependency Management

This project now uses NPM to manage frontend dependencies as part of the Gradle build process.

## How It Works

1. **NPM Dependencies**: Defined in [package.json](package.json)
2. **Gradle Integration**: The `com.github.node-gradle.node` plugin automatically downloads Node.js and NPM
3. **Automatic Build**: When you run `./gradlew build`, it will:
   - Download Node.js (v22.12.0) and NPM (v10.9.2) if not present
   - Run `npm install` to fetch dependencies
   - Copy ApexCharts from `node_modules` to `src/main/resources/static/js/vendor/`
   - Continue with the normal Java build process

## Updating Frontend Dependencies

### Update ApexCharts

Edit [package.json](package.json) and change the version:

```json
"dependencies": {
  "apexcharts": "^4.8.0"  // Change to desired version
}
```

Then rebuild:

```bash
./gradlew clean build
```

### Add New NPM Packages

1. Add the package to [package.json](package.json):

```json
"dependencies": {
  "apexcharts": "^4.7.0",
  "chart.js": "^4.4.0"  // Example: adding Chart.js
}
```

2. Update the `copyFrontendDependencies` task in [build.gradle](build.gradle) to copy the new library:

```gradle
task copyFrontendDependencies(type: Copy) {
    dependsOn 'npmInstall'
    from 'node_modules/apexcharts/dist'
    into 'src/main/resources/static/js/vendor'
    include 'apexcharts.min.js'

    // Add new library
    from 'node_modules/chart.js/dist'
    into 'src/main/resources/static/js/vendor'
    include 'chart.min.js'
}
```

3. Rebuild: `./gradlew clean build`

## Manual NPM Commands

You can also run NPM commands directly:

```bash
# Install dependencies
./gradlew npmInstall

# Update a specific package
./gradlew npm_update_--_apexcharts

# Check for outdated packages
./gradlew npm_outdated
```

## What's Ignored

The following are excluded from version control (see [.gitignore](.gitignore)):

- `node_modules/` - NPM dependencies
- `package-lock.json` - NPM lock file
- `src/main/resources/static/js/vendor/apexcharts.min.js` - Generated file

## Current Versions

- **Node.js**: 22.12.0
- **NPM**: 10.9.2
- **ApexCharts**: 4.7.0

## Benefits

1. **Version Control**: ApexCharts version is tracked in package.json
2. **Automatic Updates**: Easy to update by changing one line in package.json
3. **No Manual Downloads**: No need to manually download and commit JS files
4. **Security**: NPM will report vulnerabilities in frontend dependencies
5. **CI/CD Ready**: Build process is fully automated and reproducible
