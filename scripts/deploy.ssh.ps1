param(
	[string] [Parameter(Mandatory = $true)] $ResourceGroupName,
	[string] [Parameter(Mandatory = $true)] $Name,
	[securestring] [Parameter(Mandatory = $true)] $Password
)

# retrieve the SSH
$key = Get-AzSshKey  -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction Ignore
if ($null -eq $key) {
	# create the SSH
	$pass = ConvertFrom-SecureString -SecureString $Password
	ssh-keygen -b 4096 -C AZURE -f generated -N $pass
	$privateKey = Get-Content -Raw ./generated
	$publicKey = Get-Content -Raw ./generated.pub
	Remove-Item generated*
	$key = New-AzSshKey -ResourceGroupName $ResourceGroupName -Name $Name -PublicKey $publicKey
	$DeploymentScriptOutputs['privateKey'] = $privateKey
}
# return the public key in outputs
$DeploymentScriptOutputs['publicKey'] = $key.publicKey