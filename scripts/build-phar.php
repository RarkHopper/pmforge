<?php
declare(strict_types=1);

/**
 * @return array<string, string>
 */
function parsePluginYml(): array {
    if (!file_exists("plugin.yml")) {
        exit("Error: plugin.yml not found. Run this script from the plugin root directory.\n");
    }

    $pluginYml = yaml_parse_file("plugin.yml");
    if (!$pluginYml) {
        exit("Error: Failed to parse plugin.yml\n");
    }

    if (!isset($pluginYml["name"]) || !isset($pluginYml["version"])) {
        exit("Error: plugin.yml is missing required name or version fields\n");
    }

    return $pluginYml;
}

/**
 * Add files from a directory to the phar recursively
 */
function addDirectoryToPhar(Phar $phar, string $directory): void {
    if (!is_dir($directory)) {
        return;
    }

    $directoryIterator = new RecursiveDirectoryIterator($directory, FilesystemIterator::SKIP_DOTS);
    $iterator = new RecursiveIteratorIterator($directoryIterator);

    foreach ($iterator as $file) {
        if (!$file->isFile()) {
            continue;
        }

        $filePath = $file->getPathname();

        $absoluteCurrentDir = realpath('.');
        $absoluteFilePath = realpath($filePath);

        $relativePath = substr($absoluteFilePath, strlen($absoluteCurrentDir) + 1);
        $relativePath = str_replace('\\', '/', $relativePath);

        echo "Adding file: {$relativePath}\n";
        $phar->addFile($filePath, $relativePath);
    }
}

function createPhar(string $name, string $version): void {
    // Sanitize name for filename (remove spaces, etc.)
    $pharName = strtolower(preg_replace('/[^A-Za-z0-9_-]/', '', str_replace(' ', '-', $name)));

    // buildディレクトリを作成 (存在しない場合)
    $buildDir = "builds";
    if (!is_dir($buildDir)) {
        if (!mkdir($buildDir, 0755, true)) {
            exit("Error: Failed to create build directory\n");
        }
        echo "Created build directory\n";
    }

    $pharFile = "{$buildDir}/{$pharName}-{$version}.phar";

    // Delete existing phar
    if (file_exists($pharFile)) {
        unlink($pharFile);
    }

    echo "Building {$pharFile}...\n";

    // Create phar
    $phar = new Phar($pharFile);
    $phar->startBuffering();
    $phar->setSignatureAlgorithm(Phar::SHA1);

    // Set stub
    $phar->setStub(
        "<?php
        echo \"This file was packed with the {$name} v{$version} phar packer\\n\";
        __HALT_COMPILER();"
    );

    // Add src directory if it exists
    if (is_dir("src")) {
        echo "Adding src directory...\n";
        addDirectoryToPhar($phar, "src");
    } else {
        echo "Warning: src directory not found\n";
    }

    // Add resources directory if it exists
    if (is_dir("resources")) {
        echo "Adding resources directory...\n";
        addDirectoryToPhar($phar, "resources");
    } else {
        echo "Warning: resources directory not found\n";
    }

    // Add plugin.yml
    if (file_exists("plugin.yml")) {
        echo "Adding file: plugin.yml\n";
        $phar->addFile("plugin.yml");
    } else {
        exit("Error: plugin.yml not found. Cannot build phar without plugin.yml\n");
    }

    $phar->compressFiles(Phar::GZ);
    $phar->stopBuffering();

    echo "Successfully created {$pharFile}\n";
}

// Check if yaml extension is available
if (!extension_loaded("yaml")) {
    exit("Error: YAML extension is not available. Please install the YAML extension for PHP.\n");
}

// Check if phar.readonly is disabled
if (ini_get("phar.readonly") == 1) {
    exit("Error: phar.readonly is enabled. Please set phar.readonly=0 in your php.ini\n");
}

$pluginInfo = parsePluginYml();
createPhar($pluginInfo["name"], $pluginInfo["version"]);
