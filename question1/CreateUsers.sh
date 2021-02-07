$PasswordProfile = "" | Select password, forceChangePasswordNextLogin
$PasswordProfile.password = "pass#123"
$PasswordProfile.forceChangePasswordNextLogin = $true
Connect-AzureAD -Confirm
for ($i=1;$i -le 20;$i++) {
   Try {
     New-AzureADUser -DisplayName "Test User$i" `
     -PasswordProfile $PasswordProfile `
     -UserPrincipalName "testuser$i@ofek88hotmail.onmicrosoft.com" `
     -AccountEnabled $true -MailNickName "TestUser$i"
     
     echo "User Test User$i created successfully ."
   }
   catch {
     "User Test User$i already exists"
   }
}


$GroupID = $(Get-AzureADGroup |grep "Varonis Assignment Group"|awk -F" " '{ print $1 }')
if ($GroupID -ne "") {
  $GroupID = $cmdOutput
  echo "group (Varonis Assignment Group) already exists "
} else {
 $GroupID=$(New-AzureADGroup -DisplayName "Varonis Assignment Group"`
  -MailEnabled $false -SecurityEnabled $true -MailNickName `
  "VaronisAssignmentGroup" |grep "Varonis Assignment Group" |awk '{print $1}')
   echo "group (Varonis Assignment Group) created "  
}

for ($i=1 ;$i -le 20;$i++) {
  $UserID = $(Get-AzureADUser |grep "testuser$i@ofek88hotmail.onmicrosoft.com" |awk '{print $1}')
  echo "attempting to assign the testuser$i to Varonis Assignment Group"
  echo $(date)
  try {
    Add-AzureADGroupMember -ObjectId $GroupID -RefObjectId $UserID
    echo "Status success"
    }
  catch {
    "Status : failure"
  }
}

