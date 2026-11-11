<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;

class Toolbar extends BaseConfig
{
    public array $collectors = [];
    public bool $collectVarData = false;
    public int $maxHistory = 20;
    public string $viewsPath = SYSTEMPATH . 'Debug/Toolbar/Views/';
    public int $maxQueries = 100;
    public array $watchedDirectories = ['app'];
    public array $watchedExtensions = ['php', 'css', 'js', 'html'];
    public array $disableOnHeaders = [
        'X-Requested-With' => 'xmlhttprequest',
    ];
}
