<?php

/*
    lineDUBbed compiler installer library

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 */

declare(strict_types=1);

function main(string $driverName, int $argc, array $argv): int
{
    $console = new Console();

    if ($argc !== 2) {
        $console->printError(
            'Invalid number of arguments.', PHP_EOL,
            'Usage:', PHP_EOL,
            "\t", $argv[0], ' <version>',
        );
        return 1;
    }

    // determine compiler/driver
    switch($driverName) {
        default:
            throw new ErrorException('Missing driver: ' . $driver);

        case 'dmd':
            $driver = new DrvDMD();
            break;

        case 'ldc':
            $driver = new DrvLDC();
            break;
    }

    // determine verison to install
    $version = $argv[1];
    $console->print('Downloading ', strtoupper($driver->getCompilerName()), ' v', $version);

    // download
    $uri = $driver->getDownloadURI($version);
    $console->print('From: ', $uri);
    try {
        $archivePath = download($uri);
    } catch (Exception $ex) {
        $console->printError('Download failed', PHP_EOL, $ex->getMessage());
        return 1;
    }
    $console->print('Saved as: ', $archivePath);

    // unpack
    $targetPath = '/opt/d/' . $driver->getCompilerSlug() . '/' . $version;
    $console->print('Unpacking to: ', $targetPath);

    if (!mkdir($targetPath, 0755, true)) {
        $console->printError('Failed to create target directory');
        return 1;
    }

    if (!unpackArchive($archivePath, $targetPath)) {
        $console->printError('Unpacking failed');
        return 1;
    }

    // create symlink
    $linkPath = '/opt/d/bin/' . "{$driver->getCompilerSlug()}-{$version}";
    $console->print('Creating symlink: ', $linkPath);
    if (!file_exists('/opt/d/bin')) {
        mkdir('/opt/d/bin', 0755, true);
    }
    $driver->createSymlink($targetPath, $linkPath);

    // remove archive
    $console->print('Removing downloaded archive: ', $archivePath);
    unlink($archivePath);

    $console->print('Done.');
    return 0;
}

function download(string $uri): string
{
    // create temporary file to store the download
    $target = tempnam('/tmp', 'd-compiler_');
    $f = fopen($target, 'w');

    // download
    $c = curl_init($uri);
    curl_setopt($c, CURLOPT_FAILONERROR, true);
    curl_setopt($c, CURLOPT_FILE, $f);
    curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
    curl_exec($c);
    curl_close($c);
    fclose($f);

    if (curl_errno($c)) {
        throw new Exception(curl_error($c));
    }

    return $target;
}

function unpackTAR(string $path, string $target): bool
{
    $cmd = sprintf('tar -xf %s -C %s', escapeshellarg($path), escapeshellarg($target));
    $status = system($cmd);

    return ($status !== false);
}

function unpackArchive(string $path, string $target): bool
{
    return unpackTAR($path, $target);
}

final class Console
{
    private $stdout;
    private $stderr;

    public function __construct()
    {
        $this->stdout = fopen('php://stdout', 'w');
        $this->stderr = fopen('php://stderr', 'w');
    }

    public function __destruct()
    {
        fflush($this->stdout);
        fflush($this->stderr);

        fclose($this->stdout);
        fclose($this->stderr);
    }

    public function print(...$s): void
    {
        foreach ($s as $i)
            fwrite($this->stdout, (string) $i);

        fwrite($this->stdout, PHP_EOL);
        fflush($this->stdout);
    }

    public function printError(...$s): void
    {
        foreach ($s as $i)
            fwrite($this->stderr, (string) $i);

        fwrite($this->stderr, PHP_EOL);
        fflush($this->stderr);
    }
}

interface Driver
{
    function getCompilerName(): string;
    function getCompilerSlug(): string;
    function getDownloadURI(string $version): string;
    function createSymlink(string $path, string $link): void;
}

final class DrvDMD implements Driver
{
    function getCompilerName(): string
    {
        return 'DMD';
    }

    function getCompilerSlug(): string
    {
        return 'dmd';
    }

    function getDownloadURI(string $version): string
    {
        $v = urlencode($version);
        $platform = $this->getPlatform();
        return "https://downloads.dlang.org/releases/2.x/{$v}/dmd.{$v}.{$platform}.tar.xz";
    }

    function createSymlink(string $path, string $link): void
    {
        $compilerPath = $path . '/dmd2/linux/bin64/dmd';

        if (!file_exists($compilerPath)) {
            throw new Exception('Unsupported compiler package');
        }

        symlink($compilerPath, $link);
    }

    private function getPlatform(): string
    {
        switch (PHP_OS) {
            default:
                throw new ErrorException('Unsupported OS: ' . PHP_OS);
    
            case 'Linux':
                return 'linux';
        }
    }
}

final class DrvLDC implements Driver
{
    function getCompilerName(): string
    {
        return 'LDC';
    }

    function getCompilerSlug(): string
    {
        return 'ldc';
    }

    function getDownloadURI(string $version): string
    {
        $v = urlencode($version);
        $platform = $this->getPlatform();
        return "https://github.com/ldc-developers/ldc/releases/download/v{$v}/ldc2-{$v}-{$platform}.tar.xz";
    }

    function createSymlink(string $path, string $link): void
    {
        $contents = scandir($path, SCANDIR_SORT_ASCENDING);

        if (count($contents) !== 3) {
            throw new Exception('Unsupported compiler package: Root folder?');
        }

        $compilerPath = $path . '/' . $contents[2] . '/bin/ldc2';

        if (!file_exists($compilerPath)) {
            throw new Exception('Unsupported compiler package: ldc2 binary?');
        }

        symlink($compilerPath, $link);
    }

    private function getPlatform(): string
    {
        switch (PHP_OS) {
            default:
                throw new ErrorException('Unsupported OS: ' . PHP_OS);

            case 'Linux':
                $arch = php_uname('m');
                return "linux-{$arch}";
        }
    }
}