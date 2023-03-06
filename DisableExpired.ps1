$ExpiredUsers = Search-ADAccount -AccountExpired -UsersOnly

foreach ($User in $ExpiredUsers){
    $Enabled = $User.Enabled


    if ($Enabled -eq "True") {
        $User | Disable-ADAccount
    }
}