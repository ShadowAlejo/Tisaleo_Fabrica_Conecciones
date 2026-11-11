<?php

namespace App\Controllers;

use CodeIgniter\Controller;

class LoginController extends Controller
{
    public function index(): string
    {
        return view('auth/login');
    }
}
