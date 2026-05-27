# ---------------------------------------------------------------------------
# SA Financial Modeler v2.0
# Optimized for SARS 2024/2025 Tax Year
# ---------------------------------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- SARS Constants 2024/2025 ---
$TAX_BRACKETS = @(
    @{ limit = 237100;  rate = 0.18; fixed = 0 }
    @{ limit = 370500;  rate = 0.26; fixed = 42678 }
    @{ limit = 512800;  rate = 0.31; fixed = 77362 }
    @{ limit = 673000;  rate = 0.36; fixed = 121475 }
    @{ limit = 857900;  rate = 0.39; fixed = 179147 }
    @{ limit = 1817000; rate = 0.41; fixed = 251258 }
    @{ limit = [double]::PositiveInfinity; rate = 0.45; fixed = 644489 }
)
$REBATES = @{ primary = 17235; secondary = 9444; tertiary = 3145 }

# --- Modern UI Theme ---
$ColorPrimary = [System.Drawing.Color]::FromArgb(79, 70, 229) # Indigo
$ColorBg = [System.Drawing.Color]::FromArgb(248, 250, 252)    # Slate 50
$ColorCard = [System.Drawing.Color]::White
$FontMain = New-Object System.Drawing.Font("Segoe UI", 10)
$FontBold = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$FontTitle = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)

# --- Main Form Setup ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "SA Financial Modeler"
$Form.Size = New-Object System.Drawing.Size(850, 600)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = $ColorBg
$Form.FormBorderStyle = "FixedDialog"
$Form.MaximizeBox = $false

# Header
$Header = New-Object System.Windows.Forms.Label
$Header.Text = "Tax Year 2024/25 Modeler"
$Header.Font = $FontTitle
$Header.ForeColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
$Header.Location = New-Object System.Drawing.Point(30, 20)
$Header.Size = New-Object System.Drawing.Size(400, 40)
$Form.Controls.Add($Header)

# --- Logic ---
function Calculate-Tax {
    try {
        $salary = [double]$txtSalary.Text
        $raMonthly = [double]$txtRA.Text
        
        $totalIncome = $salary
        $annualRA = $raMonthly * 12
        $raDeduction = [Math]::Min($annualRA, $totalIncome * 0.275)
        if ($raDeduction -gt 350000) { $raDeduction = 350000 }
        
        $taxableIncome = [Math]::Max(0, $totalIncome - $raDeduction)
        
        $grossTax = 0
        foreach ($b in $TAX_BRACKETS) {
            if ($taxableIncome -le $b.limit) {
                $index = [array]::IndexOf($TAX_BRACKETS, $b)
                $fixedTax = if ($index -gt 0) { $TAX_BRACKETS[$index-1].fixed } else { 0 }
                $lowerLimit = if ($index -gt 0) { $TAX_BRACKETS[$index-1].limit } else { 0 }
                $grossTax = $fixedTax + (($taxableIncome - $lowerLimit) * $b.rate)
                break
            }
        }
        
        $netTax = [Math]::Max(0, $grossTax - $REBATES.primary)
        $takeHome = $totalIncome - $netTax - $annualRA
        
        $txtDisplay.Clear()
        $txtDisplay.SelectionFont = $FontBold
        $txtDisplay.AppendText("ANNUAL SUMMARY`n")
        $txtDisplay.SelectionFont = $FontMain
        $txtDisplay.AppendText("Total Income: R $($totalIncome.ToString('N0'))`n")
        $txtDisplay.AppendText("RA Deduction: R $($raDeduction.ToString('N0'))`n")
        $txtDisplay.AppendText("Taxable Income: R $($taxableIncome.ToString('N0'))`n`n")
        
        $txtDisplay.SelectionFont = $FontBold
        $txtDisplay.AppendText("TAX BREAKDOWN`n")
        $txtDisplay.SelectionFont = $FontMain
        $txtDisplay.AppendText("Gross Tax: R $($grossTax.ToString('N0'))`n")
        $txtDisplay.AppendText("Primary Rebate: -R $($REBATES.primary.ToString('N0'))`n")
        $txtDisplay.AppendText("Net Tax: R $($netTax.ToString('N0'))`n`n")
        
        $txtDisplay.SelectionFont = $FontBold
        $txtDisplay.AppendText("CASH FLOW`n")
        $txtDisplay.SelectionFont = $FontMain
        $txtDisplay.AppendText("Monthly Net: R $(($takeHome/12).ToString('N0'))`n")
        $txtDisplay.AppendText("Effective Rate: $(($netTax/$totalIncome * 100).ToString('F2'))%")
    } catch {
        $txtDisplay.Text = "Error: Invalid numeric input."
    }
}

# --- Layout Panels ---
$MainPanel = New-Object System.Windows.Forms.TableLayoutPanel
$MainPanel.ColumnCount = 2
$MainPanel.RowCount = 1
$MainPanel.Location = New-Object System.Drawing.Point(30, 70)
$MainPanel.Size = New-Object System.Drawing.Size(780, 460)
$MainPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 45)))
$MainPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 55)))
$Form.Controls.Add($MainPanel)

# Input Card
$InputCard = New-Object System.Windows.Forms.Panel
$InputCard.BackColor = $ColorCard
$InputCard.Dock = "Fill"
$InputCard.Padding = New-Object System.Windows.Forms.Padding(20)
$MainPanel.Controls.Add($InputCard, 0, 0)

$lblS = New-Object System.Windows.Forms.Label
$lblS.Text = "Annual Gross Salary"
$lblS.Font = $FontBold
$lblS.Location = New-Object System.Drawing.Point(20, 20)
$lblS.Size = New-Object System.Drawing.Size(200, 20)
$InputCard.Controls.Add($lblS)

$txtSalary = New-Object System.Windows.Forms.TextBox
$txtSalary.Text = "850000"
$txtSalary.Font = $FontMain
$txtSalary.Location = New-Object System.Drawing.Point(20, 45)
$txtSalary.Size = New-Object System.Drawing.Size(260, 30)
$InputCard.Controls.Add($txtSalary)

$lblR = New-Object System.Windows.Forms.Label
$lblR.Text = "Monthly RA Contribution"
$lblR.Font = $FontBold
$lblR.Location = New-Object System.Drawing.Point(20, 100)
$lblR.Size = New-Object System.Drawing.Size(200, 20)
$InputCard.Controls.Add($lblR)

$txtRA = New-Object System.Windows.Forms.TextBox
$txtRA.Text = "7500"
$txtRA.Font = $FontMain
$txtRA.Location = New-Object System.Drawing.Point(20, 125)
$txtRA.Size = New-Object System.Drawing.Size(260, 30)
$InputCard.Controls.Add($txtRA)

$btnCalc = New-Object System.Windows.Forms.Button
$btnCalc.Text = "Run Analysis"
$btnCalc.Font = $FontBold
$btnCalc.FlatStyle = "Flat"
$btnCalc.BackColor = $ColorPrimary
$btnCalc.ForeColor = [System.Drawing.Color]::White
$btnCalc.Location = New-Object System.Drawing.Point(20, 200)
$btnCalc.Size = New-Object System.Drawing.Size(260, 45)
$btnCalc.Add_Click({ Calculate-Tax })
$InputCard.Controls.Add($btnCalc)

# Display Card
$DisplayCard = New-Object System.Windows.Forms.Panel
$DisplayCard.BackColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
$DisplayCard.Dock = "Fill"
$MainPanel.Controls.Add($DisplayCard, 1, 0)

$txtDisplay = New-Object System.Windows.Forms.RichTextBox
$txtDisplay.Dock = "Fill"
$txtDisplay.BackColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
$txtDisplay.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
$txtDisplay.BorderStyle = "None"
$txtDisplay.Padding = New-Object System.Windows.Forms.Padding(30)
$txtDisplay.ReadOnly = $true
$DisplayCard.Controls.Add($txtDisplay)

Calculate-Tax
$Form.ShowDialog()