const path = require("path");

const destinationFilePath = path.join(__dirname, "esySolveCudfCommand.exe");

const copySolverExecutable = (sourceFile) => {
    const sourceFilePath = path.join(__dirname, sourceFile);
    fs.copyFileSync(sourceFilePath, destinationFilePath);
    fs.unlinkSync(sourceFilePath);
}

const setExecutablePermission = () => {
    // Set executable permission
    fs.chmodSync(destinationFilePath, 0755);
}

switch (process.platform) {
    case "linux":
        copySolverExecutable("esySolveCudfCommandLinux.exe");
        setExecutablePermission();
        break
    case "darwin":
        copySolverExecutable("esySolveCudfCommandDarwin.exe");
        setExecutablePermission();
        break;
    default:
        console.warn("[esy-solve-cudf] Unsupported operating system; dependent commands may not function correctly")
        break;
}
