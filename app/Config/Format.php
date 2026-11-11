<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;
use CodeIgniter\Format\JSONFormatter;

class Format extends BaseConfig
{
    public array $supportedResponseFormats = [
        'application/json',
    ];

    public array $formatters = [
        'application/json' => JSONFormatter::class,
    ];

    public array $formatterOptions = [
        'application/json' => JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES,
    ];

    public int $jsonEncodeDepth = 512;
}
