# Mod Manager
# psq95
Add-Type -Assembly System.Windows.Forms

$DefaultDir = Get-Location
$DefaultPrefix1 = 'mods'
$DefaultPrefix2 = 'storage'
$DefaultModSuffix = '.pak'
$FilterSeparator = '-'
$FilterPattern = '*'
$DefaultPack = $DefaultPrefix1 + $FilterPattern
$DefaultSave = $DefaultPrefix2 + $FilterPattern
$DefaultMod  = $FilterPattern + $DefaultModSuffix

function Select-ListItem(
  [System.Windows.Forms.ListBox] $List,
  [String] $Item) {
  $Index = $List.FindStringExact($Item)
  if ($Index -ge 0) {
    $List.SetSelected($Index, $true)
  }
}

function Get-Packs() {
  $PackList.Items.Clear()
  $SaveList.Items.Clear()
  $ModList.Items.Clear()
  if ($DirText.Text) {
    Push-Location $DirText.Text
    $Packs = Get-ChildItem `
      -Path $DirText.Text `
      -Directory `
      -Filter $PackText.Text
    $Saves = Get-ChildItem `
      -Path $DirText.Text `
      -Directory `
      -Filter $SaveText.Text
    Pop-Location
    if ($Packs) {
      $PackList.BeginUpdate()
      $PackList.Items.AddRange($Packs)
      $PackList.EndUpdate()
    }
    if ($Saves) {
      $SaveList.BeginUpdate()
      $SaveList.Items.AddRange($Saves)
      $SaveList.EndUpdate()
    }
  }
}

function Split-Filter(
  [String] $Filter) {
  $Array = $Filter `
    -Split $FilterSeparator
  Write-Output $Array
}

function Get-FilterPrefix(
  [String] $Filter) {
  $Prefix = $Filter `
    -Replace [Regex]::Escape($FilterPattern), ''
  Write-Output $Prefix
}

function Get-PackSave(
  [String] $Pack) {
  $SavePrefix = Get-FilterPrefix `
    $SaveText.Text
  # Couple Save with matching Pack
  if ($Pack -Match $FilterSeparator) {
    $PackArray = Split-Filter $Pack
    $Save = $SavePrefix + $FilterSeparator + $PackArray[1]
  }
  else {
    $Save = $SavePrefix
  }
  Write-Output $Save
}

function Get-Mods() {
  Push-Location $DirText.Text
  $FilterData = Get-ChildItem `
    -Path $PackList.SelectedItem `
    -File `
    -Filter $DefaultMod
  Pop-Location
  $ModList.Items.Clear()
  $ModList.BeginUpdate()
  if ($FilterData) {
    $ModList.Items.AddRange($FilterData)
  }
  $ModList.EndUpdate()

  $Save = Get-PackSave `
    $PackList.SelectedItem
  Select-ListItem $SaveList $Save
}

function Rename-Pack(
  [String] $NewPack,
  [String] $NewSave) {
  if ($NewPack) {
    Push-Location $DirText.Text
    Rename-Item $PackList.SelectedItem $NewPack
    if ($NewSave) {
      Rename-Item $SaveList.SelectedItem $NewSave
    }
    Pop-Location
    $NewPackText.Text = $PackList.SelectedItem
    Get-Packs
    Select-ListItem $PackList $NewPack
    Get-Mods
  }
}

function Save-Pack() {
  Get-Mods
  $PackPrefix = Get-FilterPrefix `
    $PackText.Text
  if (!$NewPackText.Text)
  {
    $NewPackText.Text = $PackPrefix
  }
  $Save = Get-PackSave `
    $NewPackText.Text
  Rename-Pack $NewPackText.Text $Save
}

$Location = New-Object System.Drawing.Point(0, 10)

$UnitSize = New-Object System.Drawing.Size(
  60, 20)
$LabelSize = New-Object System.Drawing.Size(
  $UnitSize.Width, $UnitSize.Height)
$ButtonSize = New-Object System.Drawing.Size(
  $UnitSize.Width, $UnitSize.Height)
$TextBoxHalfSize = New-Object System.Drawing.Size(
  (3 * $UnitSize.Width), $UnitSize.Height)
$ListBoxHalfSize = New-Object System.Drawing.Size(
  (3 * $UnitSize.Width), (4 * $UnitSize.Height))
$TextBoxFullSize = New-Object System.Drawing.Size(
  (2 * $TextBoxHalfSize.Width), $UnitSize.Height)
$ListBoxFullSize = New-Object System.Drawing.Size(
  (2 * $ListBoxHalfSize.Width), (10 * $UnitSize.Height))

$MainForm = New-Object System.Windows.Forms.Form
$MainForm.Text = 'Mod Manager'
$MainForm.AutoSize = $true

$DirLabel = New-Object System.Windows.Forms.Label
$DirLabel.Text = "Directory:"
$DirLabel.Location = $Location
$DirLabel.Size = $LabelSize
$MainForm.Controls.Add($DirLabel)
$Location.X += $DirLabel.Size.Width

$DirText = New-Object System.Windows.Forms.TextBox
$DirText.Location = $Location
$DirText.Size = $TextBoxFullSize
$DirText.Text = $DefaultDir
$MainForm.Controls.Add($DirText)
$Location.X += $DirText.Size.Width

$DirButton = New-Object System.Windows.Forms.Button
$DirButton.Location = $Location
$DirButton.Size = $ButtonSize
$DirButton.Text = "Load"
$DirButton.Add_Click({ Get-Packs })
$MainForm.Controls.Add($DirButton)

$Location.X = 0
$Location.Y += $LabelSize.Height

$FilterLabel = New-Object System.Windows.Forms.Label
$FilterLabel.Text = "Filters:"
$FilterLabel.Location = $Location
$FilterLabel.Size = $LabelSize
$MainForm.Controls.Add($FilterLabel)
$Location.X += $FilterLabel.Size.Width

$PackText = New-Object System.Windows.Forms.TextBox
$PackText.Location = $Location
$PackText.Size = $TextBoxHalfSize
$PackText.Text = $DefaultPack
$MainForm.Controls.Add($PackText)
$Location.X += $PackText.Size.Width

$SaveText = New-Object System.Windows.Forms.TextBox
$SaveText.Location = $Location
$SaveText.Size = $TextBoxHalfSize
$SaveText.Text = $DefaultSave
$MainForm.Controls.Add($SaveText)

$Location.X = 0
$Location.Y += $TextBoxHalfSize.Height

$PackLabel = New-Object System.Windows.Forms.Label
$PackLabel.Text = "Packs:"
$PackLabel.Location = $Location
$PackLabel.Size = $LabelSize
$MainForm.Controls.Add($PackLabel)
$Location.X += $PackLabel.Size.Width

$PackList = New-Object System.Windows.Forms.ListBox
$PackList.Location = $Location
$PackList.Size = $ListBoxHalfSize
$MainForm.Controls.Add($PackList)
$Location.X += $PackList.Size.Width

$SaveList = New-Object System.Windows.Forms.ListBox
$SaveList.Location = $Location
$SaveList.Size = $ListBoxHalfSize
$MainForm.Controls.Add($SaveList)
$Location.X += $SaveList.Size.Width

$PackButton = New-Object System.Windows.Forms.Button
$PackButton.Location = $Location
$PackButton.Size = $ButtonSize
$PackButton.Text = "Load"
$PackButton.Add_Click({ Get-Mods })
$MainForm.Controls.Add($PackButton)

$Location.X = 0
$Location.Y += $ListBoxHalfSize.Height

$NewPackLabel = New-Object System.Windows.Forms.Label
$NewPackLabel.Text = "New Pack:"
$NewPackLabel.Location = $Location
$NewPackLabel.Size = $LabelSize
$MainForm.Controls.Add($NewPackLabel)
$Location.X += $NewPackLabel.Size.Width

$NewPackText = New-Object System.Windows.Forms.TextBox
$NewPackText.Location = $Location
$NewPackText.Size = $TextBoxFullSize
$NewPackText.Text = $DefaultPrefix1
$MainForm.Controls.Add($NewPackText)
$Location.X += $NewPackText.Size.Width

$SaveButton = New-Object System.Windows.Forms.Button
$SaveButton.Location = $Location
$SaveButton.Size = $ButtonSize
$SaveButton.Text = "Save"
$SaveButton.Add_Click({ Save-Pack })
$MainForm.Controls.Add($SaveButton)

$Location.X = 0
$Location.Y += $LabelSize.Height

$ModLabel = New-Object System.Windows.Forms.Label
$ModLabel.Text = "Mods:"
$ModLabel.Location = $Location
$ModLabel.Size = $LabelSize
$MainForm.Controls.Add($ModLabel)
$Location.X += $ModLabel.Size.Width

$ModList = New-Object System.Windows.Forms.ListBox
$ModList.Location = $Location
$ModList.Size = $ListBoxFullSize
$MainForm.Controls.Add($ModList)

Get-Packs
$MainForm.ShowDialog()
