$credentials = $host.UI.PromptForCredential('Login','Password','','')
$request = Invoke-WebRequest 'www.somesite.com' -SessionVariable session
$form = $request.Forms[0]
$form.fields['username'] = $credentials.UserName
$form.fields['password'] = $credentials.GetNetworkCredential().Password
$request = Invoke-WebRequest -Uri ('www.somesite.com' + $form.Action) -WebSession $session -Method POST -Body $form.Fields