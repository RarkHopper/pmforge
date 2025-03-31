<?php
declare(strict_types=1);

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

function createPhar(string $name, string $version): void {
    // Sanitize name for filename (remove spaces, etc.)
    $pharName = strtolower(preg_replace('/[^A-Za-z0-9_-]/', '', str_replace(' ', '-', $name)));

    // buildディレクトリを作成 (存在しない場合)
    $buildDir = "build";
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

    // Only include src directory and plugin.yml
    if (is_dir("src")) {
        $directory = new RecursiveDirectoryIterator("src", FilesystemIterator::SKIP_DOTS);
        $iterator = new RecursiveIteratorIterator($directory);

        foreach ($iterator as $file) {
            $filePath = $file->getPathname();
            // 現在の作業ディレクトリからの相対パスに変換
            $relativePath = str_replace(getcwd() . DIRECTORY_SEPARATOR, '', $filePath);
            // WindowsとLinuxのパス区切り文字を統一
            $relativePath = str_replace('\\', '/', $relativePath);

            if ($file->isFile()) {
                echo "Adding file: {$relativePath}\n";
                $phar->addFile($filePath, $relativePath);
            }
        }
    } else {
        echo "Warning: src directory not found\n";
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
