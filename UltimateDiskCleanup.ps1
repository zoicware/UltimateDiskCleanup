If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit	
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Ultimate Cleanup'
$form.Size = New-Object System.Drawing.Size(450, 400)
$form.StartPosition = 'CenterScreen'
$form.BackColor = 'Black'

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(60, 10)
$label.Size = New-Object System.Drawing.Size(250, 25)
$label.Text = 'Disk Cleanup Options'
$label.ForeColor = 'White'
$label.Font = New-Object System.Drawing.Font('segoe ui', 10) 
$form.Controls.Add($label)

# Create the CheckedListBox
$checkedListBox = New-Object System.Windows.Forms.CheckedListBox
$checkedListBox.Location = New-Object System.Drawing.Point(40, 60)
$checkedListBox.Size = New-Object System.Drawing.Size(200, 300)
$checkedListBox.BackColor = 'Black'
$checkedListBox.ForeColor = 'White'
$options = @(
    'Active Setup Temp Folders'
    'Thumbnail Cache'
    'Delivery Optimization Files'
    'D3D Shader Cache'
    'Downloaded Program Files'
    'Internet Cache Files'
    'Setup Log Files'
    'Temporary Files'
    'Windows Error Reporting Files'
    'Offline Pages Files'
    'Recycle Bin'
    'Temporary Setup Files'
    'Update Cleanup'
    'Upgrade Discarded Files'
    'Windows Defender'
    'Windows ESD installation files'
    'Windows Reset Log Files'
    'Windows Upgrade Log Files'
    'Previous Installations'
    'Old ChkDsk Files'
    'Feedback Hub Archive log files'
    'Diagnostic Data Viewer database files'
    'Device Driver Packages'
)
foreach ($option in $options) {
    $checkedListBox.Items.Add($option, $false) | Out-Null
}

# Create the checkboxes
$checkBox1 = New-Object System.Windows.Forms.CheckBox
$checkBox1.Text = 'Clear Event Viewer Logs'
$checkBox1.Location = New-Object System.Drawing.Point(250, 70)
$checkBox1.ForeColor = 'White'
$checkBox1.AutoSize = $true

$checkBox2 = New-Object System.Windows.Forms.CheckBox
$checkBox2.Text = 'Clear Windows Logs'
$checkBox2.Location = New-Object System.Drawing.Point(250, 100)
$checkBox2.ForeColor = 'White'
$checkBox2.AutoSize = $true

$checkBox3 = New-Object System.Windows.Forms.CheckBox
$checkBox3.Text = 'Clear TEMP Cache'
$checkBox3.Location = New-Object System.Drawing.Point(250, 130)
$checkBox3.ForeColor = 'White'
$checkBox3.AutoSize = $true

# Create the Clean button
$buttonClean = New-Object System.Windows.Forms.Button
$buttonClean.Text = 'Clean'
$buttonClean.Location = New-Object System.Drawing.Point(250, 200)
$buttonClean.Size = New-Object System.Drawing.Size(100, 30)
$buttonClean.ForeColor = 'White'
$buttonClean.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$buttonClean.DialogResult = [System.Windows.Forms.DialogResult]::OK
$buttonClean.Add_MouseEnter({
        $buttonClean.BackColor = [System.Drawing.Color]::FromArgb(64, 64, 64)
    })

$buttonClean.Add_MouseLeave({
        $buttonClean.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    })
  
$checkALL = New-Object System.Windows.Forms.CheckBox
$checkALL.Text = 'Check All'
$checkALL.Location = New-Object System.Drawing.Point(40, 40)
$checkALL.ForeColor = 'White'
$checkALL.AutoSize = $true
$checkALL.add_CheckedChanged({
        if ($checkALL.Checked) {
            $i = 0
            foreach ($option in $options) {
                $checkedListBox.SetItemChecked($i, $true)
                $i++
            }
        }
        else {
            $i = 0
            foreach ($option in $options) {
                $checkedListBox.SetItemChecked($i, $false)
                $i++
            }
        }
    })
$form.Controls.Add($checkALL)
  
# Add controls to the form
$form.Controls.Add($checkedListBox)
$form.Controls.Add($checkBox1)
$form.Controls.Add($checkBox2)
$form.Controls.Add($checkBox3)
$form.Controls.Add($buttonClean)

# Show the form
$result = $form.ShowDialog()


if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $driveletter = $env:SystemDrive -replace ':', ''
    $drive = Get-PSDrive $driveletter
    $usedInGB = [math]::Round($drive.Used / 1GB, 4)
    Write-Host 'BEFORE CLEANING' -ForegroundColor Red
    Write-Host "Used space on $($drive.Name):\ $usedInGB GB" -ForegroundColor Red
    


    if ($checkBox1.Checked) {
        Write-Host 'Clearing Event Viewer Logs...'
        wevtutil el | Foreach-Object { wevtutil cl "$_" >$null 2>&1 } 
    }
    if ($checkBox2.Checked) {
        #CLEAR LOGS
        Write-Host 'Clearing Windows Log Files...'
        #Clear Distributed Transaction Coordinator logs
        Remove-Item -Path $env:SystemRoot\DtcInstall.log -Force -ErrorAction SilentlyContinue 
        #Clear Optional Component Manager and COM+ components logs
        Remove-Item -Path $env:SystemRoot\comsetup.log -Force -ErrorAction SilentlyContinue 
        #Clear Pending File Rename Operations logs
        Remove-Item -Path $env:SystemRoot\PFRO.log -Force -ErrorAction SilentlyContinue 
        #Clear Windows Deployment Upgrade Process Logs
        Remove-Item -Path $env:SystemRoot\setupact.log -Force -ErrorAction SilentlyContinue 
        Remove-Item -Path $env:SystemRoot\setuperr.log -Force -ErrorAction SilentlyContinue 
        #Clear Windows Setup Logs
        Remove-Item -Path $env:SystemRoot\setupapi.log -Force -ErrorAction SilentlyContinue 
        Remove-Item -Path $env:SystemRoot\Panther\* -Force -Recurse -ErrorAction SilentlyContinue 
        Remove-Item -Path $env:SystemRoot\inf\setupapi.app.log -Force -ErrorAction SilentlyContinue 
        Remove-Item -Path $env:SystemRoot\inf\setupapi.dev.log -Force -ErrorAction SilentlyContinue 
        Remove-Item -Path $env:SystemRoot\inf\setupapi.offline.log -Force -ErrorAction SilentlyContinue 
        #Clear Windows System Assessment Tool logs
        Remove-Item -Path $env:SystemRoot\Performance\WinSAT\winsat.log -Force -ErrorAction SilentlyContinue 
        #Clear Password change events
        Remove-Item -Path $env:SystemRoot\debug\PASSWD.LOG -Force -ErrorAction SilentlyContinue 
        #Clear DISM (Deployment Image Servicing and Management) Logs
        Remove-Item -Path $env:SystemRoot\Logs\CBS\CBS.log -Force -ErrorAction SilentlyContinue  
        Remove-Item -Path $env:SystemRoot\Logs\DISM\DISM.log -Force -ErrorAction SilentlyContinue  
        #Clear Server-initiated Healing Events Logs
        Remove-Item -Path "$env:SystemRoot\Logs\SIH\*" -Force -ErrorAction SilentlyContinue 
        #Common Language Runtime Logs
        Remove-Item -Path "$env:LocalAppData\Microsoft\CLR_v4.0\UsageTraces\*" -Force -ErrorAction SilentlyContinue 
        Remove-Item -Path "$env:LocalAppData\Microsoft\CLR_v4.0_32\UsageTraces\*" -Force -ErrorAction SilentlyContinue 
        #Network Setup Service Events Logs
        Remove-Item -Path "$env:SystemRoot\Logs\NetSetup\*" -Force -ErrorAction SilentlyContinue 
        #Disk Cleanup tool (Cleanmgr.exe) Logs
        Remove-Item -Path "$env:SystemRoot\System32\LogFiles\setupcln\*" -Force -ErrorAction SilentlyContinue 
        #Clear Windows update and SFC scan logs
        Remove-Item -Path $env:SystemRoot\Temp\CBS\* -Force -ErrorAction SilentlyContinue 
        #Clear Windows Update Medic Service logs
        takeown /f $env:SystemRoot\Logs\waasmedic /r -Value y *>$null
        icacls $env:SystemRoot\Logs\waasmedic /grant administrators:F /t *>$null
        Remove-Item -Path $env:SystemRoot\Logs\waasmedic -Recurse -ErrorAction SilentlyContinue 
        #Clear Cryptographic Services Traces
        Remove-Item -Path $env:SystemRoot\System32\catroot2\dberr.txt -Force -ErrorAction SilentlyContinue 
        Remove-Item -Path $env:SystemRoot\System32\catroot2.log -Force -ErrorAction SilentlyContinue 
        Remove-Item -Path $env:SystemRoot\System32\catroot2.jrs -Force -ErrorAction SilentlyContinue 
        Remove-Item -Path $env:SystemRoot\System32\catroot2.edb -Force -ErrorAction SilentlyContinue 
        Remove-Item -Path $env:SystemRoot\System32\catroot2.chk -Force -ErrorAction SilentlyContinue 
        #Windows Update Logs
        Remove-Item -Path "$env:SystemRoot\Traces\WindowsUpdate\*" -Force -ErrorAction SilentlyContinue 
    }
    if ($checkBox3.Checked) {
        Write-Host 'Clearing TEMP Files...'
        #cleanup temp files
        $temp1 = 'C:\Windows\Temp'
        $temp2 = $env:TEMP
        $tempFiles = (Get-ChildItem -Path $temp1 , $temp2 -Recurse -Force).FullName
        foreach ($file in $tempFiles) {
            Remove-Item -Path $file -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    if ($checkedListBox.CheckedItems) {
        $key = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches'
        foreach ($item in $checkedListBox.CheckedItems) {
            reg.exe add "$key\$item" /v StateFlags0069 /t REG_DWORD /d 00000002 /f >$nul 2>&1
        }
        Write-Host 'Running Disk Cleanup...'
        #nice
        Start-Process cleanmgr.exe -ArgumentList '/sagerun:69 /autoclean' -Wait
    }

    $drive = Get-PSDrive $driveletter
    $usedInGB = [math]::Round($drive.Used / 1GB, 4)
    Write-Host 'AFTER CLEANING' -ForegroundColor Green
    Write-Host "Used space on $($drive.Name):\ $usedInGB GB" -ForegroundColor Green
    
}

  
