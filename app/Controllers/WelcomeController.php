<?php

namespace App\Controllers;

use CodeIgniter\Controller;

class WelcomeController extends Controller
{
    public function index(): string
    {
        return view('welcome_message');
    }
}
