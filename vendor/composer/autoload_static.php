<?php

// autoload_static.php @generated by Composer

namespace Composer\Autoload;

class ComposerStaticInit6c7c0bed5858fd5cf5fb27a88cbbaf4a
{
    public static $classMap = array (
        'Composer\\InstalledVersions' => __DIR__ . '/..' . '/composer/InstalledVersions.php',
    );

    public static function getInitializer(ClassLoader $loader)
    {
        return \Closure::bind(function () use ($loader) {
            $loader->classMap = ComposerStaticInit6c7c0bed5858fd5cf5fb27a88cbbaf4a::$classMap;

        }, null, ClassLoader::class);
    }
}
